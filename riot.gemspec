Gem::Specification.new do |s|
  s.name     = "riot"
  s.version  = "0.9.3"
  s.date     = "2009-10-06"
  s.summary  = "An extremely fast, expressive, and context-driven unit-testing framework"
  s.email    = %w[gus@gusg.us]
  s.homepage = "http://github.com/thumblemonks/protest"
  s.description = "An extremely fast, expressive, and context-driven unit-testing framework. A replacement for all other testing frameworks. Protest the slow test."
  s.authors  = %w[Justin\ Knowlden]

  s.has_rdoc = false
  s.rdoc_options = ["--main", "README.markdown"]
  s.extra_rdoc_files = ["README.markdown"]

  # run git ls-files to get an updated list
  s.files = %w[
    MIT-LICENSE
    README.markdown
    lib/riot.rb
    lib/riot/assertion.rb
    lib/riot/context.rb
    lib/riot/macros.rb
    lib/riot/report.rb
    riot.gemspec
  ]
  
  s.test_files = %w[
    Rakefile
    test/assertion_test.rb
    test/benchmark/simple_context_and_assertions.rb
    test/context_test.rb
    test/teststrap.rb
  ]
end
