module HasNamedBootstraps
  def self.included(other)
    other.extend(ClassMethods)
  end

  module ClassMethods
    # For each key/value pair in constant_hash, look up the record with the value in the "name" attribute, and assign it to the constant denoted by the key.
    #
    # Example:
    #
    #   class Department < ActiveRecord::Base
    #     has_named_bootstraps(
    #       :R_AND_D         => 'R&D',
    #       :MARKETING       => 'Marketing', 
    #       :HANDSOME_DEVILS => 'Web Development' 
    #     )
    #   end
    #
    # Department::R_AND_D, Department::MARKETING and Department::HANDSOME_DEVILS are now all defined and point to an ActiveRecord object.
    #
    # Valid options:
    #
    # +master_list+:: Assign to the given constant name a list of all constants that has_named_bootstraps creates.  Example:
    #
    #   class Dog < ActiveRecord::Base
    #     has_named_bootstraps(
    #       {:FIDO => 'Fido', :ROVER => 'Rover', :SPOT  => 'Spot'},
    #       :master_list => :GOOD_DOGS
    #     )
    #   end
    #
    # Dog::FIDO, Dog::ROVER, and Dog::SPOT are now defined as above, but there's also another constant, Dog::GOOD_DOGS, which contains a list of those three dogs.
    #
    #
    #
    # +name_field+:: Look up bootstrapped constants by the specified field, rather than +name+.  Example:
    #
    #   class Part < ActiveRecord::Base
    #     has_named_bootstraps(
    #       {
    #         :BANANA_GRABBER => '423-GOB-127', 
    #         :TURNIP_TWADDLER => 'ZOMG-6-5000', 
    #         :MOLE_WHACKER => '520-23-17X'
    #       },
    #       :name_field => :serial_number
    #     )
    #   end
    #
    #   >> Part.all
    #   => [#<Part id: 1, serial_number: "423-GOB-127">, #<Part id: 2, serial_number: "ZOMG-6-5000">, #<Part id: 3, serial_number: "520-23-17X">]
    #   >> Part::BANANA_GRABBER
    #   => #<Part id: 1, serial_number: "423-GOB-127">

    def has_named_bootstraps(constant_hash, options={})
      name_field = options[:name_field] || :name

      # If the master_list option isn't set, we're just going to throw this
      # list away, but it's clearer to just check once at the end if it's set
      # rather than check repeatedly.
      master_list = []

      constant_hash.each do |constant_name, record_name|
        bootstrapped_record = self.find(:first, :conditions => {name_field => record_name})
        master_list << self.const_set(constant_name, bootstrapped_record.freeze)
      end

      master_list_name = options[:master_list]
      if master_list_name
        self.const_set(master_list_name, master_list.freeze)
      end
    end
  end
end
