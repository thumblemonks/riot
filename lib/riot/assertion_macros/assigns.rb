module Riot
  # In the positive case, asserts that an instance variable is defined for the result of the assertion.
  # Value of instance variable is expected to not be nil.
  #
  #   setup { User.new(:email => "foo@bar.baz") }
  #   asserts_topic.assigns(:email)
  #
  # If a value is provided in addition to the variable name, the actual value of the instance variable
  # must equal the expected value.
  #
  #   setup { User.new(:email => "foo@bar.baz") }
  #   asserts_topic.assigns(:email, "foo@bar.baz")
  #
  # In the negative case, asserts that an instance variables *is not* defined or has a nil value. If a value
  # is provided in addition to the name, then ensure that the actual value does not equal the expected value.
  #
  #   setup { User.new(:email => "foo@bar.baz") }
  #   denies("topic") { topic }.assigns(:first_name)
  #   denies("topic") { topic }.assigns(:email, "bar@baz.boo")
  class AssignsMacro < AssertionMacro
    register :assigns

    # (see Riot::AssertionMacro#evaluate)
    # @param [Symbol, String] variable name of instance variable to look for
    # @param [Object, nil] expected_value an optional value to validate for the variable
    def evaluate(actual, *expectings)
      prepare(actual, *expectings) do |variable, expected_value, actual_value|
        if actual_value.nil?
          fail expected_message(variable).to_be_assigned_a_value
        elsif !expected_value.nil? && expected_value != actual_value
          fail expected_message(variable).to_be_assigned_with(expected_value).not(actual_value)
        else
          if expected_value && actual_value
            pass new_message.assigns(variable).with(expected_value)
          else
            pass new_message.assigns(variable)
          end
        end
      end
    end

    # (see Riot::AssertionMacro#devaluate)
    # @param [Symbol, String] variable name of instance variable to look for
    # @param [Object, nil] expected_value an optional value to validate for the variable
    def devaluate(actual, *expectings)
      prepare(actual, *expectings) do |variable, expected_value, actual_value|
        if actual_value.nil? || (expected_value && expected_value != actual_value)
          if expected_value && actual_value
            pass new_message.assigns(variable).with(expected_value)
          else
            pass new_message.assigns(variable)
          end
        else
          message = expected_message(variable).to_not_be
          fail(expected_value.nil? ? message.assigned_a_value : message.assigned_with(expected_value))
        end
      end
    end

  private

    def prepare(actual, *expectings, &block)
      variable, expected_value = expectings
      yield(variable, expected_value, actual.instance_variable_get("@#{variable}"))
    end
  end # AssignsMacro
end # Riot
