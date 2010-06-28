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

  PART_CONSTANT_HASH = {
    :BANANA_GRABBER  => '423-GOB-127',
    :TURNIP_TWADDLER => 'ZOMG-6-5000',
    :MOLE_WHACKER    => '520-23-17X'
  }

  def self.create_records_from_hash_values(klass, hash, name_field_sym = :name)
    klass.delete_all
    hash.values.each do |record_name|
      klass.create!(name_field_sym => record_name)
    end
  end

  # Hack for Rails 3 compatibility.  Not sure why in 2.3.8 this is expected to
  # be a class method, and in 3.0.0.beta4 this is an instance method, but
  # there it is.
  
  def create_records_from_hash_values(klass, hash, name_field_sym = :name)
    self.class.create_records_from_hash_values(klass, hash, name_field_sym)
  end

  setup do
    create_records_from_hash_values(Department, DEPARTMENT_CONSTANT_HASH)
    create_records_from_hash_values(Dog, DOG_CONSTANT_HASH)
    create_records_from_hash_values(Part, PART_CONSTANT_HASH, :serial_number)

    quietly do
      Department.class_eval do
        has_named_bootstraps(DEPARTMENT_CONSTANT_HASH)
      end

      Dog.class_eval do
        has_named_bootstraps(
          DOG_CONSTANT_HASH,
          :master_list => :GOOD_DOGS # who's a good dog?
        )
      end

      Part.class_eval do
        has_named_bootstraps(
          PART_CONSTANT_HASH,
          :name_field => :serial_number
        )
      end
    end
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

    context "when an expected bootstrap is missing" do
      setup do
        @bad_country_name = "Erewhon"
        @bad_country_const_name = "EREWHON"
        @bad_bootstrap_hash_string = "{'#{@bad_country_const_name}' => '#{@bad_country_name}'}"

        stub(Rails.logger).warn
        assert_nil Country.find_by_name(@bad_country_const_name)
      end

      should "raise a HasNamedBootstraps::MissingBootstrapError" do
        assert_raise HasNamedBootstraps::MissingBootstrapError do
          # Using stringwise form of class_eval so we can interpolate
          # @bad_bootstrap_hash_string, which otherwise this wants to interpret 
          # as an instance variable of Department.

          quietly do
            Country.class_eval <<-END_CLASS_EVAL
              has_named_bootstraps(#{@bad_bootstrap_hash_string})
            END_CLASS_EVAL
          end
        end
      end

      context "when :handle_missing_bootstrap is set to :warn" do
        setup do
          quietly do
            Country.class_eval <<-END_CLASS_EVAL 
              has_named_bootstraps(#{@bad_bootstrap_hash_string}, :handle_missing_bootstrap => :warn)
            END_CLASS_EVAL
          end
        end

        should "log a warning" do
          assert_received(Rails.logger) {|logger| logger.warn(/#{@bad_country_name}/)}
        end

        should "leave that constant set to nil" do
          assert_nil Country.const_get(@bad_country_const_name)
        end
      end

      context "when :handle_missing_bootstrap is set to :silent" do
        setup do
          dont_allow(Rails.logger).warn

          quietly do
            Country.class_eval <<-END_CLASS_EVAL 
              has_named_bootstraps(#{@bad_bootstrap_hash_string}, :handle_missing_bootstrap => :silent)
            END_CLASS_EVAL
          end
        end

        should "leave that constant set to nil" do
          assert_nil Country.const_get(@bad_country_const_name)
        end
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

    context "when the :name_field option is set" do
      should "look up bootstrapped constants by that field" do
        PART_CONSTANT_HASH.each do |constant_name, serial_number|
          expected_constant = Part.find_by_serial_number(serial_number)
          actual_constant = Part.const_get(constant_name)

          assert_equal expected_constant, actual_constant
        end
      end
    end
  end
end
