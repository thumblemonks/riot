# require 'teststrap'
# 
# context "same_elements assertion" do
#   setup { Riot::Situation.new }
# 
#   asserts "result contains same elements" do
#     Riot::Assertion.new("i will pass", topic) { ["foo", "bar", 69] }.same_elements([69, "foo", "bar"])
#   end
# 
#   should "raise a Failure if result contains different elements" do
#     Riot::Assertion.new("failure", topic) { ["foo", "bar", 69] }.same_elements([6, 9, "foo", "bar"])
#   end.kind_of(Riot::Failure)
# 
#   should "raise a Failure if actual is not an array" do
#     Riot::Assertion.new("failure", topic) { 6 }.same_elements([6, 9, "foo", "bar"])
#   end.kind_of(Riot::Failure)
# 
#   should "raise a Failure if expected is not an array" do
#     Riot::Assertion.new("failure", topic) { ["foo", "bar", 69] }.same_elements(9)
#   end.kind_of(Riot::Failure)
# 
# end # same_elements assertion
