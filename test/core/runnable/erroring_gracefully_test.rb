require 'teststrap'

context "Executing setup with an error" do
  setup do
    Riot::Setup.new { raise "Error in setup" }.run(Riot::Situation.new)
  end

  asserts("result") { topic[0] }.equals(:setup_error)
  asserts("result object") { topic[1] }.kind_of(Exception)
  asserts("error message") { topic[1].message }.equals("Error in setup")
  
end # Executing setup with an error

context "Executing a context" do
  context "that errors during setup" do
    setup do
      Riot::Context.new("A") {
        setup { raise "Whoopsie!" } # error
        asserts("foo") { true }     # success
        asserts("bar") { false }    # failure
      }.run(Riot::SilentReporter.new)
    end

    asserts(:errors).equals(1)
    asserts(:failures).equals(0)
    asserts(:passes).equals(0)
  end # that errors during setup
  
  context "that errors in a parent setup" do
    setup do
      Riot::Context.new("A") {
        setup { raise "Whoopsie!" } # error

        context "B" do
          asserts("foo") { true }     # success
          asserts("bar") { false }    # failure
        end
      }.run(Riot::SilentReporter.new)
    end

    asserts(:errors).equals(2) # Same setup fails twice
    asserts(:failures).equals(0)
    asserts(:passes).equals(0)
  end # that errors in a parent setup
  
end # Executing a cotext

