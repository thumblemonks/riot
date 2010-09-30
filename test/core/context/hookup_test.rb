require 'teststrap'

context "Using a hookup" do
  setup do
    situation = Riot::Situation.new
    a_context = Riot::Context.new("foobar") {}
    a_context.setup { "I'm a string" }.run(situation)
    a_context.hookup { topic.size }.run(situation)
    situation.topic
  end
  
  asserts_topic.equals("I'm a string")
end # Using a hookup
