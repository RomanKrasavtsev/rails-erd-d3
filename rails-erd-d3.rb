# Rails 4 = ActiveRecord::Base
# Rails 5 = ApplicationRecord

# Post.reflections["comments"].table_name # => "comments"
# Post.reflections["comments"].macro # => :has_many
# Post.reflections["comments"].foreign_key # => "message_id"

def get_rails_version
  Rails::VERSION::MAJOR
end

def print_all_models version
  if ActiveRecord::Base.subclasses.size > 0
    models = []

    if version == 4
      # Rails 4
      models = ObjectSpace.each_object(Class).select { |o| o.superclass == ActiveRecord::Base }
    elsif version == 5
      # Rails 5
      models = ObjectSpace.each_object(Class).select { |o| o.superclass == ApplicationRecord }
    end

    models.each do |model|
      puts model
      model.reflections.keys.each do |key|
        puts "\t#{model.reflections[key].macro} #{key.capitalize} #{model.reflections[key].foreign_key}"
      end
    end
  else
    puts "There are no any models in this project!"
  end
end

def print_all_tables version
  if version == 4
    # Rails 4
    tables = ActiveRecord::Base.connection.tables

    tables.each_with_index do |table, index|
      puts table.class_name.column_names
    end
  end
end

print_all_models get_rails_version
