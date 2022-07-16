# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

# The minimum version of Ruby required (by New Relic) to run SimpleCov
# NOTE: At the time that SimpleCov was introduced to this code base, it
# required Ruby >= 2.5.0 and Ruby 2.6.0 was marked for EOL
SIMPLECOV_MIN_RUBY_VERSION = '2.7.0'

require 'simplecov' if RUBY_VERSION >= SIMPLECOV_MIN_RUBY_VERSION

module SimpleCovHelper
  def self.command_name(suite_name)
    SimpleCov.command_name(suite_name) if RUBY_VERSION >= '2.7.0'
  end
end
