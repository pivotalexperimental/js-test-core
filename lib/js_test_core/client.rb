module JsTestCore
  class Client
    class ClientException < Exception
    end

    class InvalidStatusResponse < ClientException
    end
    
    class << self
      def run(parameters={})
        new(parameters).run
      end

      def run_argv(argv)
        params = {}
        parser = OptionParser.new do |o|
          o.banner = "JsTestCore Runner"
          o.banner << "\nUsage: #{$0} [options] [-- untouched arguments]"

          o.on
          o.on('-h', '--selenium_host=SELENIUM_HOST', "The host name of the Selenium Server relative to where this file is executed") do |host|
            params[:selenium_host] = host
          end

          o.on('-p', '--selenium_port=SELENIUM_PORT', "The port of the Selenium Server relative to where this file is executed") do |port|
            params[:selenium_port] = port
          end

          o.on('-u', '--spec_url=SPEC_URL', "The url of the js spec server, relative to the browsers running via the Selenium Server") do |spec_url|
            params[:spec_url] = spec_url
          end

          o.on_tail
        end
        parser.order!(argv)
        run params
      end
    end

    RUNNING = 'running'
    SUCCESSFUL_COMPLETION = 'success'
    FAILURE_COMPLETION = 'failure'

    attr_reader :parameters, :http, :suite_start_response, :last_poll_result
    def initialize(parameters)
      @parameters = parameters
    end

    def run
      Net::HTTP.start(DEFAULT_HOST, DEFAULT_PORT) do |@http|
        start_firefox_runner
        wait_for_suite_to_finish
      end
      report_result
    end

    def parts_from_query(query)
      query.split('&').inject({}) do |acc, key_value_pair|
        key, value = key_value_pair.split('=')
        acc[key] = value
        acc
      end
    end
    
    protected
    def start_firefox_runner
      @suite_start_response = http.post('/runners/firefox', SeleniumServerConfiguration.query_string_from(parameters))
    end

    def wait_for_suite_to_finish
      poll while suite_not_completed?
    end

    def report_result
      case last_poll_result
      when SUCCESSFUL_COMPLETION
        STDOUT.puts "SUCCESS"
        true
      when FAILURE_COMPLETION
        STDOUT.puts "FAILURE"
        false
      else
        raise InvalidStatusResponse, "Invalid Status: #{last_poll_result}"
      end
    end

    def suite_not_completed?
      last_poll_result.nil? || last_poll_result == RUNNING
    end

    def poll
      @last_poll_result = parts_from_query(http.get("/suites/#{suite_id}").body)['status']
    end

    def suite_id
      @suite_id ||= parts_from_query(suite_start_response.body)['suite_id']
    end
  end
end