module HasNamedBootstraps
  def self.included(other)
    other.extend(ClassMethods)
  end

  module ClassMethods
    # For each key/value pair in constant_hash, look up the record with the value in the "name" attribute, and assign it to the constant denoted by the key.  Assign a list of all such created constants to the constant named by valid_list_name.
    #
    # Example:
    #
    #   class Department < ActiveRecord::Base
    #     has_named_bootstraps(
    #       :VALID_DEPARTMENTS,    
    #       :R_AND_D         => 'R&D',
    #       :MARKETING       => 'Marketing', 
    #       :HANDSOME_DEVILS => 'Web Development' 
    #     )
    #   end
    #
    # Department::R_AND_D, Department::MARKETING and Department::HANDSOME_DEVILS are now all defined and point to an ActiveRecord object.  Deparment::VALID_DEPARTMENTS is a list of those constants.

    def has_named_bootstraps(valid_list_name, constant_hash)
      valid_list = []

      constant_hash.each do |constant_name, record_name|
        valid_list << self.const_set(constant_name, self.find_by_name(record_name).freeze)
      end

      self.const_set(valid_list_name, valid_list.freeze)
    end
  end
end
