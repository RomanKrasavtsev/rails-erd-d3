require "json"
require "erb"

class RailsErdD3
  ASSOCIATIONS = %w(
    belongs_to
    has_one
    has_many
    has_many_through
    has_one_through
    has_and_belongs_to_many
    polymorphic
  )

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

    Rails.application.eager_load!
    klass.connection
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
        association = refl_data.macro.to_s + (refl_data.options[:through] ? "_through" : "")
        color_index = ASSOCIATIONS.index(association)

        links << {
          source: models_list[model.model_name.plural.capitalize],
          target: models_list[refl_model.pluralize.capitalize],
          color:  color_index
        }
      end
    end

    data = { nodes: nodes, links: links }
    data.to_json
  end

  def self.create
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
    ERB.new(
      File.read(
        File.expand_path(
          "templates/modals.html.erb",
          File.dirname(__FILE__)
        )
      )
    ).result(binding)
  end
end
