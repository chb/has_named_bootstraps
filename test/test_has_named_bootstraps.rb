require 'test_helper'

class HasNamedBootstrapsTest < ActiveSupport::TestCase
  DEPARTMENT_CONSTANT_HASH = {
    :R_AND_D         => 'R&D',
    :MARKETING       => 'Marketing', 
    :HANDSOME_DEVILS => 'Web Development' 
  }

  DOG_CONSTANT_HASH = {
    :FIDO  => 'Fido',
    :ROVER => 'Rover',
    :SPOT  => 'Spot'
  }

  def self.create_records_from_hash_values(klass, hash)
    klass.delete_all
    hash.values.each do |record_name|
      klass.create!(:name => record_name)
    end
  end

  setup do
    create_records_from_hash_values(Department, DEPARTMENT_CONSTANT_HASH)
    create_records_from_hash_values(Dog, DOG_CONSTANT_HASH)

    # Ignore "already initialized constant WHATEVER" warnings that we
    # would otherwise get due to load_named_bootstraps running before every
    # test, redefining constants as we go (which we want in this case)
    old_verbose = $VERBOSE
    $VERBOSE = nil

    Department.class_eval do
      include HasNamedBootstraps
      has_named_bootstraps(DEPARTMENT_CONSTANT_HASH)
    end

    Dog.class_eval do
      include HasNamedBootstraps
      has_named_bootstraps(
        DOG_CONSTANT_HASH,
        :master_list => :GOOD_DOGS # who's a good dog?
      )
    end

    $VERBOSE = old_verbose
  end

  context "#has_named_bootstraps" do
    should "create each expected constant" do
      DEPARTMENT_CONSTANT_HASH.each do |constant_name, department_name|
        bootstrapped_constant = Department.const_get(constant_name)
        expected_department = Department.find_by_name(department_name)
        
        assert expected_department # ensure not nil
        assert_equal expected_department, bootstrapped_constant
      end
    end

    context "when the :master_list option is set" do
      should "add each expected constant to the list of valid constants" do
        expected_objects = DOG_CONSTANT_HASH.keys.map{|hash_symbol| Dog.const_get(hash_symbol)}
        actual_objects = Dog::GOOD_DOGS

        expected_objects.each {|expected_object| assert expected_object} # ensure not nil
        assert_same_elements expected_objects, actual_objects
      end
    end
  end
end
