require 'teststrap'

context "A negative assertion test" do

  helper(:negative_assertion) do |definition|
    Riot::Assertion.new("foo", true) { definition }
  end

  asserts("response when evaluated with false result") do
    negative_assertion(false).run(Riot::Situation.new)
  end.equals([:pass, ""])
  
  asserts("response when evaluated with nil result") do
    negative_assertion(false).run(Riot::Situation.new)
  end.equals([:pass, ""])
  
  asserts("response when evaluated with true result") do
    negative_assertion(true).run(Riot::Situation.new)
  end.equals([:fail, "Expected non-true but got true instead", nil, nil])

  asserts("response when evaluated with \"bar\" result") do
    negative_assertion("bar").run(Riot::Situation.new)
  end.equals([:fail, "Expected non-true but got \"bar\" instead", nil, nil])

  asserts("response when evaluated with 0 result") do
    negative_assertion(0).run(Riot::Situation.new)
  end.equals([:fail, "Expected non-true but got 0 instead", nil, nil])

  helper(:big_exception) { @exception ||= Exception.new("blah") }

  asserts("response when evaluation errors") do
    exception = big_exception # :\
    Riot::Assertion.new("foo", true) { raise exception }.run(Riot::Situation.new)
  end.equals { [:error, big_exception] }

end # A negative assertion test
