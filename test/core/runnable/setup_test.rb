require 'teststrap'

context "A setup block" do
  setup do
    Riot::Setup.new { "fooberries" }
  end
  
  asserts("topic is set for situation when run") do
    situation = Riot::Situation.new
    topic.run(situation)
    situation.topic == "fooberries"
  end

  asserts(":setup is returned from calling run") do
    topic.run(Riot::Situation.new) == [:setup]
  end
end # A setup block
