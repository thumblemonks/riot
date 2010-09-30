require 'teststrap'

context "The describe alias" do
  setup do
    Riot::Context.new("Foo") {}
  end

  asserts("any ol' object") { Object.new }.responds_to(:describe)
  asserts_topic.responds_to :describe
end # The describe alias

describe "This describe context" do
  setup { "another thing is my" }
  asserts_topic.kind_of(String)
end # This describe context

context "Using a describe sub-context" do
  setup do
    Riot::Context.new("Foo") do
      describe "using describe" do
        setup { "another thing is my" }
        asserts_topic.kind_of(String)
      end
    end.run(Riot::Reporter.new)
  end

  asserts("current context description") do
    topic.current_context.detailed_description
  end.equals("Foo using describe")

  asserts(:passes).equals(1)
  asserts(:failures).equals(0)
  asserts(:errors).equals(0)
end # Using a describe sub-context
