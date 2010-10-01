require 'teststrap'

context "Using denies" do

  helper(:denial_context) do |&assertion_block|
    report = Riot::Context.new("Apple Jackie") do
      denies("with false", &assertion_block)
    end.run(MockReporter.new)

    [report.passes, report.failures, report.errors]
  end # denial_context

  asserts("result when returning false from the assertion block") do
    denial_context { false }
  end.equals([1,0,0])

  asserts("result when returning true from the assertion block") do
    denial_context { true }
  end.equals([0,1,0])

  asserts("result when assertion block has an exception") do
    denial_context { raise Exception }
  end.equals([0,0,1])

end # Using denies
