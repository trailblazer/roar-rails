require "bundler/gem_tasks"
require 'rake/testtask'
require "rails/version"

task :default => [:test]

Rake::TestTask.new(:test) do |test|
  test.libs << 'test'

  # Do not test generators for Rails < 3.2
  test.test_files = FileList['test/*_test.rb'].reject do |file|
    file.include?('generator') && Rails::VERSION::STRING < '3.2'
  end

  test.verbose = true
end
