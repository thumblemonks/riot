require 'teststrap'

context "A situation" do
  setup do
    Riot::Situation.new
  end

  asserts("the topic is result of calling setup") do
    topic.setup { "foo" }
    topic.topic == "foo"
  end

  asserts("evaluate will return result of evaluation") do
    topic.evaluate { "foo" == "bar" } == false
  end
end # A situation
