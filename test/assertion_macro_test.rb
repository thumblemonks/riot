require 'teststrap'

context "An AssertionMacro instance" do
  setup { Riot::AssertionMacro.new }

  asserts_topic.responds_to(:new_message)
  asserts_topic.responds_to(:expected_message)
  asserts_topic.responds_to(:should_have_message)
  asserts_topic.responds_to(:line)
  asserts_topic.responds_to(:line=)
  asserts_topic.responds_to(:file)
  asserts_topic.responds_to(:file=)

  context "receiving #new_message" do
    setup { topic.new_message("hope") }

    asserts_topic.kind_of(Riot::Message)
    asserts(:to_s).equals(%q["hope"])
  end

  context "receiving #should_have_message" do
    setup { topic.should_have_message("hope") }

    asserts_topic.kind_of(Riot::Message)
    asserts(:to_s).equals(%q[should have "hope"])
  end

  context "receiving #expected_message" do
    setup { topic.expected_message("hope") }

    asserts_topic.kind_of(Riot::Message)
    asserts(:to_s).equals(%q[expected "hope"])
  end
end # An AssertionMacro instance

context "AssertionMacro#fail" do
  setup do
    macro = Riot::AssertionMacro.new
    macro.line = 5
    macro.file = "foo"
    macro.fail("")
  end

  asserts_topic.includes(5)
  asserts_topic.includes("foo")
end # AssertionMacro#fail