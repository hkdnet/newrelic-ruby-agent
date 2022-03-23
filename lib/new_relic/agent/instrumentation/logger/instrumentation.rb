# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module Agent
    module Instrumentation
      module Logger
        def skip_instrumenting?
          defined?(@skip_instrumenting) && @skip_instrumenting
        end

        # We support setting this on loggers which might not have
        # instrumentation installed yet. This lets us disable in AgentLogger
        # and AuditLogger without them having to know the inner details.
        def self.mark_skip_instrumenting(logger)
          logger.instance_variable_set(:@skip_instrumenting, true)
        end

        def self.clear_skip_instrumenting(logger)
          logger.instance_variable_set(:@skip_instrumenting, false)
        end

        def mark_skip_instrumenting
          @skip_instrumenting = true
        end

        def clear_skip_instrumenting
          @skip_instrumenting = false
        end

        def self.enabled?
          NewRelic::Agent.config[:'instrumentation.logger'] != 'disabled'
        end

        def format_message_with_tracing(severity, datetime, progname, msg)
          formatted_message = yield
          return formatted_message if skip_instrumenting?

          begin
            # It's critical we don't instrument logging from metric recording
            # methods within NewRelic::Agent, or we'll stack overflow!!
            mark_skip_instrumenting

            unless ::NewRelic::Agent.agent.nil?
              logdev_id, logdev_file = nil, nil
              if @logdev
                logdev_id = @logdev.object_id
                dev = @logdev.instance_variable_get(:@dev)
                logdev_file = dev.path if dev
              end
              debug_info = "thread_id=#{Thread.current.object_id}~log_device_id=#{logdev_id}~file=#{logdev_file}"
              ::NewRelic::Agent.agent.log_event_aggregator.record(formatted_message, severity, debug_info)
              formatted_message = LocalLogDecorator.decorate(formatted_message)
            end

            formatted_message
          ensure
            clear_skip_instrumenting
          end
        end
      end
    end
  end
end
