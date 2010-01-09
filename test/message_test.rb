require 'teststrap'

context "A message object" do
  asserts("blank message on initialization") { Riot::Message.new.to_s }.equals("")

  asserts("opening phrase has inspected values") do
    Riot::Message.new("bar", nil, {:a => 2}).to_s
  end.equals(%q["bar" nil {:a=>2}])

  context "receiving calls for unbound methods" do
    asserts("message") do
      Riot::Message.new.bar.to_s
    end.equals(%q[bar])

    asserts("message with args") do
      Riot::Message.new("Foo").bar("baz").to_s
    end.equals(%q["Foo" bar "baz"])

    asserts("in a long chain with underscored words") do
      Riot::Message.new.bar.baz.your_mom.to_s
    end.equals(%q[bar baz your mom])
  end # unbound methods

  asserts("#comma with a message") { Riot::Message.new.comma("and").to_s }.equals(", and")

  asserts("#but") { Riot::Message.new.but.to_s }.equals(", but")

  asserts("#not") { Riot::Message.new.not.to_s }.equals(", not")
  asserts("#not with message") { Riot::Message.new("Foo").not("a").to_s }.equals(%q["Foo", not "a"])
end # A message object
