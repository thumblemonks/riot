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
        fail expected_message(variable).to_be_assigned_a_value
      elsif !expected_value.nil? && expected_value != actual_value
        fail expected_message(variable).to_be_equal_to(expected_value).not(actual_value)
      else
        pass
      end
    end
  end
end
