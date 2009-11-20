# require 'teststrap'
# 
# context "respond to" do
#   setup do
#     Riot::Situation.new
#   end
# 
#   should "pass when object responds to expected method" do
#     Riot::Assertion.new("foo", topic) { "foo" }.respond_to(:each_byte)
#   end
# 
#   should "fail when object does not respond to expected method" do
#     Riot::Assertion.new("foo", topic) { "foo" }.respond_to(:goofballs).message
#   end.equals("foo: expected method :goofballs is not defined")
# 
# end # respond to
