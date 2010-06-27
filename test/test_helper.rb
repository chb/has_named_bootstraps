require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'active_record/fixtures'
require 'shoulda'

require 'rr'
class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end

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

  create_table 'countries', :force => true do |t|
    t.column 'name', :string
  end
end

class Department < ActiveRecord::Base
  include HasNamedBootstraps
end

class Dog < ActiveRecord::Base
  include HasNamedBootstraps
end

class Part < ActiveRecord::Base
  include HasNamedBootstraps
end

class Country < ActiveRecord::Base
  include HasNamedBootstraps
end

# We're going to be redefining a lot of constants in the tests, so supress
# warnings of the same.

def quietly
  old_verbose = $VERBOSE
  $VERBOSE = nil
  yield
  $VERBOSE = old_verbose
end

# Dummy Rails logger, for testing warnings.
module Rails
  FAKE_LOGGER = Object.new

  def self.logger
    FAKE_LOGGER
  end
end
