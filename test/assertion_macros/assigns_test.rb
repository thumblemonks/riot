require 'teststrap'

# context "An assigns assertion macro" do
#   setup do
#     @fake_situation = Riot::Situation.new
#     object_with_instance_variables = Riot::Situation.new
#     object_with_instance_variables.instance_eval { @foo = "bar"; @bar = nil}
#     object_with_instance_variables
#   end
# 
#   asserts("an instance variable was assigned") do
#     test_object = topic
#     Riot::Assertion.new("duh", @fake_situation) { test_object }.assigns(:foo)
#   end
# 
#   asserts("an instance variable was never assigned") do
#     test_object = topic
#     Riot::Assertion.new("foo", @fake_situation) { test_object }.assigns(:baz)
#   end.kind_of(Riot::Failure)
#   
#   asserts "an instance variable was defined with nil value" do
#     test_object = topic
#     Riot::Assertion.new("foo", @fake_situation) { test_object }.assigns(:bar).message
#   end.matches(/expected @bar to be assigned a value/)
# 
#   asserts("an instance variable was assigned a specific value") do
#     test_object = topic
#     Riot::Assertion.new("duh", @fake_situation) { test_object }.assigns(:foo, "bar")
#   end
# 
#   asserts("failure when instance never assigned even when a value is expected") do
#     test_object = topic
#     Riot::Assertion.new("duh", @fake_situation) { test_object }.assigns(:bar, "bar").message
#   end.matches(/expected @bar to be assigned a value/)
# 
#   asserts("failure when expected value is not assigned to variable with a value") do
#     test_object = topic
#     Riot::Assertion.new("duh", @fake_situation) { test_object }.assigns(:foo, "baz").message
#   end.matches(/expected @foo to be equal to 'baz', not 'bar'/)
# end # An assigns assertion macro
