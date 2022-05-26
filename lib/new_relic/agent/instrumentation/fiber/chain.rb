# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require_relative 'instrumentation'

module NewRelic::Agent::Instrumentation
  module MonitoredFiber
    module Chain
      def self.instrument!
        ::Fiber.class_eval do
          include NewRelic::Agent::Instrumentation::MonitoredFiber

          alias_method :initialize_without_new_relic, :initialize

          def initialize(*args, &block)
            traced_block = add_fiber_tracing(*args, &block)
            initialize_without_new_relic(*args, &traced_block)
          end
        end
      end
    end
  end
end
