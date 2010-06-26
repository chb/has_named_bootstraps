require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'active_record/fixtures'
require 'shoulda'
begin
  require 'ruby-debug'
rescue LoadError
end

require 'lib/has_named_bootstraps'

ActiveRecord::Base.establish_connection(
  :adapter   => 'sqlite3',
  :database  => 'has_named_bootstraps_test.db'
)

ActiveRecord::Schema.define do
  create_table 'departments', :force => true do |t|
    t.column 'name', :string
  end

  create_table 'dogs', :force => true do |t|
    t.column 'name', :string
  end

  create_table 'parts', :force => true do |t|
    t.column 'serial_number', :string
  end
end

class Department < ActiveRecord::Base
end

class Dog < ActiveRecord::Base
end

class Part < ActiveRecord::Base
end
