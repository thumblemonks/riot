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
