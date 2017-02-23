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
    @@models = ObjectSpace.each_object(Class).select { |o| o.ancestors.include? klass } || []
    @@models = @@models - [klass] if @@models.include? klass
  end

  def self.get_data
    get_all_models

    models_list = {}
    @@models.each_with_index do |model, index|
      models_list[model.model_name.plural.capitalize] = index
    end

    puts "Generating data..."

    nodes = []
    links = []
    @@models.each do |model|
      nodes << { label: model.name, r: 30 }

      puts " - #{model.name}"
      model.reflections.each do |refl_name, refl_data|
        next if refl_data.options[:polymorphic]

        refl_model = (refl_data.options[:class_name] || refl_name).to_s.underscore
        association = refl_data.macro.to_s + (refl_data.options[:through] ? "_through" : "")
        color_index = ASSOCIATIONS.index(association)

        targeted_model = refl_model
        targeted_model = targeted_model[1..-1] if targeted_model.starts_with?("/")
        targeted_model = targeted_model.tr("/", "_").pluralize.capitalize

        links << {
          source: models_list[model.model_name.plural.capitalize],
          target: models_list[targeted_model],
          color:  color_index
        }
      end
    end
    puts "Data were successfully generated."

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
          "#{get_js}"\
        "</body>"\
      "</html>"
    )
    file.close

    puts "File erd.html was successfully created!"
  end

  private

  def self.get_head
    read_file("templates/head.html")
  end

  def self.get_nav
    read_file("templates/nav.html")
  end

  def self.get_d3
    puts "Generating JS..."

    content = ERB.new(
      read_file("templates/d3.html.erb")
    ).result(binding)

    puts "JS was successfully generated."
    content
  end

  def self.get_js
    read_file("templates/js.html")
  end

  def self.get_modals
    puts "Generating modals..."

    content = ERB.new(
      read_file("templates/modals.html.erb")
    ).result(binding)

    puts "Modals were successfully generated."
    content
  end

  def self.read_file(path)
    File.read(
      File.expand_path(path, File.dirname(__FILE__))
    )
  end
end
