tables = ActiveRecord::Base.connection.tables

tables.each_with_index do |table, index|
  klass = table.class_name
  puts klass.column_names
end

klass.reflections.keys.each do |key|
  Post.reflections["comments"].table_name # => "comments"
  Post.reflections["comments"].macro # => :has_many
  Post.reflections["comments"].foreign_key # => "message_id"
end
