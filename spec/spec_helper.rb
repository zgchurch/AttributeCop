require 'rubygems'
gem 'actionpack', '2.3.4'
gem 'activerecord', '2.3.4'
require 'active_record'
require 'action_view'
require 'action_controller'
require 'spec'
require 'fileutils'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")
require "activerecord-attribute_cop"

# define schema
db_file = File.join(File.dirname(__FILE__), 'test.db')
FileUtils.rm(db_file) if File.exist?(db_file)
ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => db_file

ActiveRecord::Schema.define do
  create_table :people do |t|
    t.string :first_name
    t.string :last_name
  end
end

module SpecHelper
  def people_path
    '/people'
  end
  def protect_against_forgery?
    false
  end
  def self.extended(base)
    base.instance_eval do
      def output_buffer
        @output_buffer ||= ''
        @output_buffer
      end
      extend ActionView::Helpers
      extend ActionController::PolymorphicRoutes
    end
  end
end