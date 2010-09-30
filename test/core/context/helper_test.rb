require 'teststrap'

context "A context with a helper" do
  setup { "foo" }

  helper(:upcase) { topic.upcase }
  helper(:append) {|str| topic + str }

  asserts("executing the helper") { upcase }.equals("FOO")
  asserts("calling a helper with an argument") { append("bar") }.equals("foobar")
end
