require 'teststrap'
require 'stringio'

context "StoryReporter" do
  setup do
    @out = StringIO.new
    Riot::StoryReporter.new(@out)
  end

  asserts("success message is stripped if nil") do
    topic.pass("foo", nil)
    @out.string
  end.matches(/\+ \e\[32mfoo\e\[0m\n/)

  asserts("failure message excludes line info if none provided") do
    @out.rewind
    topic.fail("foo", "bar", nil, nil)
    @out.string
  end.matches(/\- \e\[33mfoo: bar\e\[0m\n/)

  context 'reporting on an empty context' do
    setup do
      context = Riot::Context.new('empty context') {
        context("a nested empty context") {}
      }.run(topic)
    end
    should("not output context name") { @out.string }.empty
  end

  context "reporting on a non-empty context" do
    setup do
      Riot::Context.new('supercontext') {
        asserts("truth") { true }
      }.run(topic)
    end

    should('output context name') { @out.string }.matches(/supercontext/)
    should('output name of passed assertion') { @out.string }.matches(/truth/)
  end
end # StoryReporter

context "Plain StoryReporter" do
  setup do
    @out = StringIO.new
    Riot::StoryReporter.new(@out, {"plain" => true})
  end

  asserts("success message is stripped if nil") do
    topic.pass("foo", nil)
    @out.string
  end.matches(/\+ foo\n/)

  asserts("failure message excludes line info if none provided") do
    @out.rewind
    topic.fail("foo", "bar", nil, nil)
    @out.string
  end.matches(/\- foo: bar\n/)
end # Plain StoryReporter

