require 'teststrap'

context "Using denies" do

  asserts("result when returning false from the assertion block") do
    report = Riot::Context.new("Apple Jackie") do
      denies("with false") { false }
    end.run(MockReporter.new)
    [report.passes, report.failures, report.errors]
  end.equals([1,0,0])

  asserts("result when returning true from the assertion block") do
    report = Riot::Context.new("Apple Jackie") do
      denies("with true") { true }
    end.run(MockReporter.new)
    [report.passes, report.failures, report.errors]
  end.equals([0,1,0])

  asserts("result when assertion block has an exception") do
    report = Riot::Context.new("Apple Jackie") do
      denies("ooooops") { raise Exception }
    end.run(MockReporter.new)
    [report.passes, report.failures, report.errors]
  end.equals([0,0,1])

end # Using denies
