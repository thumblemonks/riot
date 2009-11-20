require 'teststrap'

context "An assigns assertion macro" do
  setup do
    item = Object.new
    item.instance_eval { @foo = 1; @bar; @nil_val = nil }
    Riot::Assertion.new("test") { item }
  end

  context "asserting existing variable without checking value" do
    setup { topic.assigns(:foo) }

    topic_should_pass
  end

  context "asserting existing variable by correct value" do
    setup { topic.assigns(:foo,1) } 

    topic_should_pass
  end

  context "asserting existing variable by incorrect value" do
    setup { topic.assigns(:foo, 2) }

    topic_should_fail_with_message "foo"
  end

  context "asserting missing variable" do
    setup { topic.assigns(:bar) }

    topic_should_fail_with_message "bar"
  end
  
  context "asserting nil instance variable" do
    setup { topic.assigns(:nil_var) }

    topic_should_fail_with_message "nil_var", "nil"
  end
end
