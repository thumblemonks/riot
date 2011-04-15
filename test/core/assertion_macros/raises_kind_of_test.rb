require 'teststrap'

class Whoops < Exception; end
class SubWhoops < Whoops; end

context "A raises_kind_of assertion macro" do
  helper(:asserts_raises) { |o| Riot::Assertion.new("foo") { raise Whoops, o } }

  assertion_test_passes("when expected exception is raised",
                        "raises kind of Whoops") do
    asserts_raises(nil).raises_kind_of(Whoops)
  end

  assertion_test_fails("when a superclass of the expected exception is raised",
                       "expected to raise kind of SubWhoops, not Whoops") do
    asserts_raises(nil).raises_kind_of(SubWhoops)
  end

  assertion_test_passes("when a subclass of the expected exception is raised",
                        "raises kind of Exception") do
    asserts_raises(nil).raises_kind_of(Exception)
  end

  assertion_test_fails("when nothing was raised",
                       "expected to raise kind of Whoops, but raised nothing") do
    assertion = Riot::Assertion.new("foo") { "barf" }.raises_kind_of(Whoops)
  end

  assertion_test_passes("when provided message equals expected message",
                        %Q{raises kind of Whoops with message "Mom"}) do
    asserts_raises('Mom').raises_kind_of(Whoops, 'Mom')
  end

  assertion_test_fails("when messages aren't equal",
                       %Q{expected "Mom" for message, not "Dad"}) do
    asserts_raises('Dad').raises_kind_of(Whoops, 'Mom')
  end

  assertion_test_passes("when provided message matches expected message",
                        %Q{raises kind of Whoops with message /Mom/}) do
    asserts_raises('Mom').raises_kind_of(Whoops, /Mom/)
  end

  assertion_test_fails("when messages don't match",
                       %Q{expected /Mom/ for message, not "Dad"}) do
    asserts_raises('Dad').raises_kind_of(Whoops, /Mom/)
  end
end # A raises_kind_of assertion macro

context "A negative raises_kind_of assertion macro" do
  helper(:deny_raises) { |o| Riot::Assertion.new("foo", true) { raise Whoops, o } }

  assertion_test_fails("when expected exception is raised",
                       "expected to not raise kind of Whoops") do
    deny_raises(nil).raises_kind_of(Whoops)
  end

  assertion_test_fails("when a subclass of the expected exception is raised",
                       "expected to not raise kind of Whoops") do
    Riot::Assertion.new("foo", true) { raise SubWhoops }.raises_kind_of(Whoops)
  end

  assertion_test_passes("when unexpected exception is raised",
                        "raises kind of SubWhoops") do
    deny_raises(nil).raises_kind_of(SubWhoops)
  end

  assertion_test_passes("when nothing was raised", "raises kind of Whoops") do
    Riot::Assertion.new("foo", true) { "barf" }.raises_kind_of(Whoops)
  end

  assertion_test_fails("when provided message equals expected message",
                       'expected to not raise kind of Whoops with message "Mom", but raised Whoops with message "Mom"') do
    deny_raises('Mom').raises_kind_of(Whoops, 'Mom')
  end

  assertion_test_passes("when messages and exception aren't equal",
                        'raises kind of ArgumentError with message "Dad"') do
    deny_raises('Mom').raises_kind_of(ArgumentError, 'Dad')
  end

  assertion_test_fails("when provided message matches expected message", 'expected to not raise kind of Whoops with message /Mom/, but raised Whoops with message "Mom"') do
    deny_raises('Mom').raises_kind_of(Whoops, /Mom/)
  end

  assertion_test_fails("when messages don't match", "expected to not raise kind of Whoops with message /Mom/, but raised Whoops with message \"Dad\"") do
    deny_raises('Dad').raises_kind_of(Whoops, /Mom/)
  end
end # A raises_kind_of assertion macro
