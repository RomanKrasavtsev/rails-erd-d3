require "active_record"
require "rails"
require_relative "models/application_record.rb"
require_relative "models/user.rb"
require_relative "../lib/rails-erd-d3"

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"

ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.data_sources.include? 'users'
    create_table :users do |table|
      table.column :firstname, :string
      table.column :lastname, :string
      table.column :sex, :string
      table.column :city, :string
      table.column :password, :string
    end
  end

  unless ActiveRecord::Base.connection.data_sources.include? 'projects'
    create_table :projects do |table|
      table.column :user_id, :integer
      table.column :name, :integer
      table.column :desciption, :string
    end
  end
end
