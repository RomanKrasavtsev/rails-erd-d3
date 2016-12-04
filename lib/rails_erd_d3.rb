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
      nodes << { label: model.name, r: 30 }

      model.reflections.each do |refl_name, refl_data|
        next if refl_data.options[:polymorphic]
        refl_model = (refl_data.options[:class_name] || refl_name).underscore
        links << {
          source: models_list[model.model_name.plural.capitalize],
          target: models_list[refl_model.pluralize.capitalize]
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
    ERB.new(
      File.read(
        File.expand_path(
          "templates/d3.html.erb",
          File.dirname(__FILE__)
        )
      )
    ).result(binding)
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
