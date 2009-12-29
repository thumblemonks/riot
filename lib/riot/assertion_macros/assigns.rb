module Riot
  # Asserts that an instance variable is defined for the result of the assertion. Value of instance
  # variable is expected to not be nil
  #   setup { User.new(:email => "foo@bar.baz") }
  #   topic.assigns(:email)
  #
  # If a value is provided in addition to the variable name, the actual value of the instance variable
  # must equal the expected value
  #   setup { User.new(:email => "foo@bar.baz") }
  #   topic.assigns(:email, "foo@bar.baz")
  class AssignsMacro < AssertionMacro
    register :assigns

    def evaluate(actual, *expectings)
      variable, expected_value = expectings
      variable_name = "@#{variable}"
      actual_value = actual.instance_variable_defined?(variable_name) ? actual.instance_variable_get(variable_name) : nil
      if actual_value.nil?
        fail("expected @#{variable} to be assigned a value")
      elsif !expected_value.nil? && expected_value != actual_value
        fail(%Q[expected @#{variable} to be equal to #{expected_value.inspect}, not #{actual_value.inspect}])
      else
        pass
      end
    end
  end
end
