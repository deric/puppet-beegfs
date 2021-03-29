source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || ['> 3.3.0','< 7.0']
  gem 'rspec-puppet'
  gem 'rspec-puppet-facts'
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'
  gem 'librarian-puppet'
  gem 'semantic_puppet'
  gem 'puppetlabs_spec_helper'
  # newer versions require ruby 2.2
  if RUBY_VERSION < "2.2.0"
    gem 'listen', '~> 3.0.0'
  end
  gem "nokogiri", ">= 1.8.5"
  gem "puppet-lint-absolute_classname-check"
  gem "puppet-lint-leading_zero-check"
  gem "puppet-lint-trailing_comma-check"
  gem "puppet-lint-version_comparison-check"
  gem "puppet-lint-classes_and_types_beginning_with_digits-check"
  gem "puppet-lint-unquoted_string-check"
  gem 'puppet-lint-resource_reference_syntax'
  gem 'metadata-json-lint'
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem 'puppet-blacksmith', git: 'https://github.com/deric/puppet-blacksmith', branch: 'tag-order'
  gem "guard-rake"
  # CVE-2017-8418
  gem "rubocop", "~> 0.70.0"
  gem 'mry'
end

group :system_tests do
  if RUBY_VERSION >= '2.2.5'
    gem 'beaker'
  else
    gem 'beaker', '< 3'
  end
  gem 'pry-byebug', '> 3.7'
  gem 'beaker-rspec'
  gem 'beaker-docker'
  gem "beaker-puppet_install_helper"
end
