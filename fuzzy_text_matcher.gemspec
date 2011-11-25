# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fuzzy_text_matcher/version"

Gem::Specification.new do |s|
  s.name        = "fuzzy_text_matcher"
  s.version     = FuzzyTextMatcher::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jamis Buck", "Andrei Maxim", "Kevin Weil"]
  s.email       = ["jamis@jamisbuck.org", "andrei@seesmic.com", "kevinweil@gmail.com"]
  s.homepage    = "http://github.com/kevinweil/fuzzy_text_matcher"
  s.summary     = %q{Fuzzy text matcher}
  s.description = %q{An implementation of TextMate's Cmd-T non-contiguous match functionality}

  s.add_development_dependency "rake"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.require_paths = ["lib"]  
end
