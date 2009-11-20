$: << File.join(File.dirname(__FILE__), "..", "lib")
require 'riot'

class MockReporter < Riot::Reporter
  def pass(description); end
  def fail(description, message); end
  def error(description, e); end
  def results; end
end
