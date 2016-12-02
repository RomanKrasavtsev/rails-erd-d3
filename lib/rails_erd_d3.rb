require "json"
require "erb"

class RailsErdD3
  def self.get_rails_version
    Rails::VERSION::MAJOR
  end

  def self.get_all_models
    case get_rails_version
    when 4
      klass = ActiveRecord::Base
    when 5
      klass = ApplicationRecord
    end

    @@models = ObjectSpace.each_object(Class).select { |o| o.superclass == klass } || []
  end

  def self.get_data
    get_all_models

    models_list = {}
    @@models.each_with_index do |model, index|
      models_list[model.model_name.plural.capitalize] = index
    end

    nodes = []
    links = []
    @@models.each do |model|
      nodes << { label: model.name.capitalize, r: 30 }
      model.reflections.keys.each do |key|
        links << {
          source: models_list[model.model_name.plural.capitalize],
          target: models_list[key.pluralize.capitalize]
        }
      end
    end

    data = { nodes: nodes, links: links }
    data.to_json
  end

  def self.create
    Rails.application.eager_load!

    file = File.new("erd.html", "w")
    file.puts(
      "<!DOCTYPE HTML>"\
      "<html>"\
        "#{get_head}"\
        "<body>"\
          "#{get_nav}"\
          "<div id='erd'>"\
          "</div>"\
          "#{get_d3}"\
          "#{get_modals}"\
        "</body>"\
      "</html>"
    )
    file.close

    "File erd.html was successfully created!"
  end

  private

  def self.get_head
    File.read(
      File.expand_path(
        "templates/head.html",
        File.dirname(__FILE__)
      )
    )
  end

  def self.get_nav
    File.read(
      File.expand_path(
        "templates/nav.html",
        File.dirname(__FILE__)
      )
    )
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

  simulation.nodes(data.nodes)
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
</script>
"
  end

  def self.get_modals
    modals = ""
    @@models.each do |model|
      name = model.name.capitalize
      modals += "<div class='modal fade' id='#{name}' tabindex='-1' role='dialog'>"\
                  "<div class='modal-dialog' role='document'>"\
                    "<div class='modal-content'>"\
                      "<div class='modal-header'>"\
                        "<button type='button' class='close' data-dismiss='modal' aria-label='Close'><span aria-hidden='true'>&times;</span></button>"\
                        "<h4 class='modal-title'>#{name}</h4>"\
                      "</div>"\
                      "<div class='modal-body'>"\
                        "<div class='panel panel-primary'>"\
                          "<div class='panel-heading'>Associations</div>"\
                          "<table class='table table-hover'>"\
                            "<thead>"\
                              "<tr>"\
                                "<th>#</th>"\
                                "<th>name</th>"\
                                "<th>macro</th>"\
                                "<th>foreign_key</th>"\
                              "</tr>"\
                            "</thead>"\
                            "<tbody>"

      model.reflections.each_with_index do |r, index|
        name = r[0]
        modals += "<tr>"\
                    "<th>#{index + 1}</th>"\
                    "<td>#{name.capitalize}</td>"\
                    "<td>#{model.reflections[name].macro}</td>"\
                    "<td>#{model.reflections[name].foreign_key}</td>"\
                  "</tr>"
      end

      modals += "</tbody>"\
              "</table>"\
            "</div>"\
          "</div>"\
        "<div class='modal-footer'>"\
          "<button type='button' class='btn btn-default' data-dismiss='modal'>Close</button>"\
        "</div>"\
      "</div>"\
    "</div>"\
  "</div>"
    end

    modals
  end
end
