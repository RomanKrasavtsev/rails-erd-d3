require 'json'

class RailsErdD3
  # Post.reflections["comments"].table_name # => "comments"
  # Post.reflections["comments"].macro # => :has_many
  # Post.reflections["comments"].foreign_key # => "message_id"

  def self.get_rails_version
    Rails::VERSION::MAJOR
  end

  def self.get_all_models
    version = get_rails_version

    case get_rails_version
    when 4
      klass = ActiveRecord::Base
    when 5
      klass = ApplicationRecord
    end

    Rails.application.eager_load!
    @@models = ObjectSpace.each_object(Class).select { |o| o.superclass == klass } || []
  end

  def self.get_data
    get_all_models

    nodes = []
    links = []
    models_list = {}

    @@models.each_with_index do |model, index|
      models_list[model.name] = index
    end

    @@models.each_with_index do |model, index|
      name = model.name.capitalize

      nodes << { label: name, r: 30 }
      model.reflections.keys.each do |key|
        links << { source: models_list[name], target: models_list[key.capitalize] }
      end
    end

    data = { nodes: nodes, links: links }
    data.to_json
  end

  def self.create_erd
    file = File.new("erd.html", "w")
    file.puts("
      <!DOCTYPE HTML>
      <html>
        #{get_head}
        <body>
          #{get_nav}
          <div id='erd'>
          </div>
          #{get_d3}
          #{get_modals}
        </body>
      </html>
    ")
    file.close
  end

  private

  def self.get_head
    "<head>
      <title>ERD</title>
      <meta charset='utf-8'>
      <script   src='https://code.jquery.com/jquery-3.1.1.min.js' integrity='sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8=' crossorigin='anonymous'></script>
      <script src='https://cdnjs.cloudflare.com/ajax/libs/d3/4.3.0/d3.min.js'></script>
      <script src='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js' integrity='sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa' crossorigin='anonymous'></script>
      <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css' integrity='sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u' crossorigin='anonymous'>
    </head>"
  end

  def self.get_nav
    "<nav class='navbar navbar-default'>
      <div class='container-fluid'>
        <div class='navbar-header'>
          <div class='navbar-brand'>
            <a href='https://github.com/RomanKrasavtsev/rails-erd-d3'>
              Rails-ERD-D3
            </a>
          </div>
        </div>
      </div>
    </nav>"
  end

  def self.get_d3
    "<script>
      var data = #{get_data};

      var width = window.innerWidth
        || document.documentElement.clientWidth
        || document.body.clientWidth;
      var height = window.innerHeight
        || document.documentElement.clientHeight
        || document.body.clientHeight;

      var colorScale = d3.scaleOrdinal(d3.schemeCategory20);

      var svg = d3.select('#erd').append('svg')
        .attr('height', height)
        .attr('width', width)
        .style('background', 'white');

      var simulation = d3.forceSimulation()
        .force('link', d3.forceLink().id(function(d) { return d.index }))
        .force('collide',d3.forceCollide( function(d){return d.r + 20 }).iterations(30) )
        .force('charge', d3.forceManyBody())
        .force('center', d3.forceCenter(width / 2, height / 2))
        .force('y', d3.forceY(0))
        .force('x', d3.forceX(0));

      var link = svg.append('g')
        .classed('links', true)
        .selectAll('line')
        .data(data.links)
        .enter()
        .append('line')
        .attr('stroke', 'black');

      var node = svg.selectAll('.node')
        .data(data.nodes)
        .enter()
        .append('g')
        .classed('node', true)
        .style('cursor', 'pointer')
        .attr('data-toggle', 'modal')
        .attr('data-target', function(d, i){ return '#' + data.nodes[i].label })
        .call(d3.drag()
          .on('start', dragstarted)
          .on('drag', dragged)
          .on('end', dragended));

      node.append('circle')
        .classed('circle', true)
        .attr('r', function(d){  return d.r })
        .attr('fill', function(d, i){ return colorScale(i) });

      node.append('text')
        .classed('text', true)
        .text(function(d) {
          return d.label;
        });

      var ticked = function() {
          link
            .attr('x1', function(d) { return d.source.x; })
            .attr('y1', function(d) { return d.source.y; })
            .attr('x2', function(d) { return d.target.x; })
            .attr('y2', function(d) { return d.target.y; });

          node
            .attr('transform', function(d) {
              return 'translate(' + [d.x, d.y] + ')';
            });
      }

      simulation
          .nodes(data.nodes)
          .on('tick', ticked);

      simulation.force('link')
          .links(data.links);

      function dragstarted(d) {
          if (!d3.event.active) simulation.alphaTarget(0.3).restart();
          d.fx = d.x;
          d.fy = d.y;
      }

      function dragged(d) {
          d.fx = d3.event.x;
          d.fy = d3.event.y;
      }

      function dragended(d) {
          if (!d3.event.active) simulation.alphaTarget(0);
          d.fx = null;
          d.fy = null;
      }
    </script>"
  end

  def self.get_modals
    modals = ""
    @@models.each do |model|
      modals += "<div class='modal fade' id='#{model.name.capitalize}' tabindex='-1' role='dialog'>
                  <div class='modal-dialog' role='document'>
                    <div class='modal-content'>
                      <div class='modal-header'>
                        <button type='button' class='close' data-dismiss='modal' aria-label='Close'><span aria-hidden='true'>&times;</span></button>
                        <h4 class='modal-title'>#{model.name.capitalize}</h4>
                      </div>
                      <div class='modal-body'>
                        <p>One fine body&hellip;</p>
                      </div>
                      <div class='modal-footer'>
                        <button type='button' class='btn btn-default' data-dismiss='modal'>Close</button>
                      </div>
                    </div>
                  </div>
                </div>"
    end

    modals
  end
end
