require 'teststrap'

class SingletonArray
  def self.<<(value); values << value; end
  def self.values; @@values ||= []; end
end

context "A context with premium_setup" do
  setup do
    Riot::Context.new("Foo") do
      setup { SingletonArray << "baz" }
      setup(true) { SingletonArray << "bar" }
      setup(true) { SingletonArray << "foo" }
    end.run(MockReporter.new)
  end

  asserts("order of setups ensures topic") { SingletonArray.values }.equals(%w[foo bar baz])
end

