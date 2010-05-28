require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'active_record/fixtures'
require 'shoulda'
require 'ruby-debug'

require 'lib/has_named_bootstraps'

ActiveRecord::Base.establish_connection(
  :adapter   => 'sqlite3',
  :database  => 'has_named_bootstraps_test.db'
)

ActiveRecord::Schema.define do
  create_table 'departments', :force => true do |t|
    t.column 'name', :string
  end
end

class Department < ActiveRecord::Base
end