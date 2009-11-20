# require 'teststrap'
# 
# context "matching assertion:" do
#   setup { Riot::Situation.new }
# 
#   asserts "result matches expression" do
#     Riot::Assertion.new("foo", topic) { "a" }.matches(%r[.])
#   end.equals(0)
# 
#   should "raise a Failure if result does not match" do
#     Riot::Assertion.new("foo", topic) { "" }.matches(%r[.])
#   end.kind_of(Riot::Failure)
# 
#   should "return the result of a matching operation" do
#     Riot::Assertion.new("foo", topic) { "a" }.matches("a")
#   end.equals(0)
# end # maching assertion
