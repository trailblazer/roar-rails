source "http://rubygems.org"

# Specify your gem's dependencies in roar-rails.gemspec
gemspec

group :test do
  # gem 'roar', path: "../roar" #">= 0.11.17"
  # gem 'representable', path: "../representable"
  gem 'rake', '10.1.0'
end

respond_to?(:install_if) and
  install_if -> { RUBY_VERSION < '2.2.2' } do
  gem 'actionpack',   '~> 4.2.0'
  gem 'activemodel',  '~> 4.2.0'
  gem 'activerecord', '~> 4.2.0'
end

gem 'nokogiri', '~> 1.6.8'

gem 'appraisal'
