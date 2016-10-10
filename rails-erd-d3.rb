tables = ActiveRecord::Base.connection.tables

tables.each_with_index do |table, index|
  klass = table.class_name
  puts klass.column_names
end

# Add all Models
classes = []
ObjectSpace.each_object(Class) do |c|
  classes << c if c.superclass == ActiveRecord::Base
end

classes[].reflections.keys.each do |key|
  Post.reflections["comments"].table_name # => "comments"
  Post.reflections["comments"].macro # => :has_many
  Post.reflections["comments"].foreign_key # => "message_id"
end

classes[0]
classes[0].reflections
# cards
classes[0].reflections["cards"].macro
# :has_many
