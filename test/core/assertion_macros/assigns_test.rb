require 'teststrap'

context "An assigns assertion macro" do
  setup do
    item = Object.new
    item.instance_eval { @foo = 1; @nil_val = nil }
    Riot::Assertion.new("test") { item }
  end

  assertion_test_passes("when foo is defined") { topic.assigns(:foo) }
  assertion_test_passes("when foo is defined with expected value") { topic.assigns(:foo, 1) }

  assertion_test_fails("when foo does not match expectation", "expected :foo to be equal to 2, not 1") do
    topic.assigns(:foo, 2)
  end

  assertion_test_fails("when bar is not define", "expected :bar to be assigned a value") do
    topic.assigns(:bar)
  end

  assertion_test_fails("when var assigned nil value", "expected :nil_val to be assigned a value") do
    topic.assigns(:nil_val)
  end
end # An assigns assertion macro

context "A negative assigns assertion macro" do
  setup do
    item = Object.new
    item.instance_eval { @foo = 1; @nil_val = nil }
    Riot::Assertion.new("test", true) { item }
  end

  asserts(":pass when @bar is not defined") do
    topic.assigns(:bar).run(Riot::Situation.new)
  end.equals([:pass, ""])

  asserts(":pass when @nil_val is actually nil") do
    topic.assigns(:nil_val).run(Riot::Situation.new)
  end.equals([:pass, ""])

  asserts(":pass when @foo does not equal 2") do
    topic.assigns(:foo, 2).run(Riot::Situation.new)
  end.equals([:pass, ""])

  asserts(":fail when @foo is defined") do
    topic.assigns(:foo).run(Riot::Situation.new)[0..1]
  end.equals([:fail, "expected :foo to not be assigned a value"])

  asserts(":fail when @foo does equal 1") do
    topic.assigns(:foo, 1).run(Riot::Situation.new)[0..1]
  end.equals([:fail, "expected :foo to not be equal to 1"])
end # A negative assigns assertion macro
