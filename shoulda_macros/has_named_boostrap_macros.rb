class ActiveSupport::TestCase
  def self.should_have_bootstraps(klass, expected_bootstraps)
    context '' do
      should "have the correct bootstrapped values" do

        expected_bootstraps.each do |expected_bootstrap|
          assert klass.const_get(expected_bootstrap), "Constant #{klass.to_s}::#{expected_bootstrap.to_s} not set"
        end

        assert_equal expected_bootstraps.length, klass.count, "Extraneous bootstrap values in #{klass.to_s}"
      end
    end
  end
end

