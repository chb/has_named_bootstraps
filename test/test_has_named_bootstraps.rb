require 'test_helper'

class HasNamedBootstrapsTest < ActiveSupport::TestCase
  CONSTANT_HASH = {
    :R_AND_D         => 'R&D',
    :MARKETING       => 'Marketing', 
    :HANDSOME_DEVILS => 'Web Development' 
  }

  setup do
    CONSTANT_HASH.values.each do |department_name|
      Department.create!(:name => department_name)
    end

    Department.class_eval do
      include HasNamedBootstraps

      # Ignore "already initialized constant WHATEVER" warnings that we
      # would otherwise get due to load_named_bootstraps running before every
      # test, redefining constants as we go (which we want in this case)
     
      old_verbose = $VERBOSE
      $VERBOSE = nil
      has_named_bootstraps(
        :VALID_DEPARTMENTS,
        CONSTANT_HASH
      )
      $VERBOSE = old_verbose
    end
  end

  context "#has_named_bootstraps" do
    should "create each expected constant" do
      CONSTANT_HASH.each do |constant_name, department_name|
        bootstrapped_constant = Department.const_get(constant_name)
        expected_department = Department.find_by_name(department_name)
        assert_equal expected_department, bootstrapped_constant
      end
    end

    should "add each expected constant to the list of valid constants" do
      expected_object_ids = CONSTANT_HASH.keys.map{|hash_symbol| Department.const_get(hash_symbol)}.map(&:id)
      actual_object_ids = Department::VALID_DEPARTMENTS.map(&:id)

      assert_same_elements expected_object_ids, actual_object_ids
    end
  end
end
