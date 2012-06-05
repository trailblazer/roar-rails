# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "roar/rails/version"

Gem::Specification.new do |s|
  s.name        = "roar-rails"
  s.version     = Roar::Rails::VERSION
  s.authors     = ["Nick Sutterer"]
  s.email       = ["apotonick@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Use Roar in Rails.}
  s.description = %q{Rails extensions for using Roar in the popular web framework.}

  s.rubyforge_project = "roar-rails"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency "roar", "~> 0.10"
  s.add_runtime_dependency "test_xml"
  s.add_runtime_dependency "actionpack",    "~> 3.0"
  s.add_runtime_dependency "railties",    "~> 3.0"
  
  s.add_development_dependency "minitest",	">= 2.8.1"
  s.add_development_dependency "tzinfo" # FIXME: why the hell do we need this for 3.1?
end
