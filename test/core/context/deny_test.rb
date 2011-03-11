require 'teststrap'

context "Using denies" do

  helper(:denial_context) do |actual|
    report = Riot::Context.new("Apple Jackie") do
      denies("with false") { actual }
    end.run(MockReporter.new)

    [report.passes, report.failures, report.errors]
  end # denial_context

  asserts("result when returning false from the assertion block") do
    denial_context(false)
  end.equals([1,0,0])

  asserts("result when returning true from the assertion block") do
    denial_context(true)
  end.equals([0,1,0])

  asserts("result when assertion block has an exception") do
    Riot::Context.new("Apple Jackie") do
      denies("with false") { raise Exception }
    end.run(MockReporter.new).errors
  end.equals(1)

end # Using denies

context "Using should_not" do

  helper(:denial_context) do |actual|
    report = Riot::Context.new("Apple Jackie") do
      should_not("with false") { actual }
    end.run(MockReporter.new)

    [report.passes, report.failures, report.errors]
  end # denial_context

  asserts("result when returning false from the assertion block") do
    denial_context(false)
  end.equals([1,0,0])

  asserts("result when returning true from the assertion block") do
    denial_context(true)
  end.equals([0,1,0])

  asserts("result when assertion block has an exception") do
    Riot::Context.new("Apple Jackie") do
      should_not("with false") { raise Exception }
    end.run(MockReporter.new).errors
  end.equals(1)

end # Using should_not
