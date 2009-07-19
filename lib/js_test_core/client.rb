module JsTestCore
  class Client
    RUNNING_RUNNER_STATE = "running"
    PASSED_RUNNER_STATE = "success"
    FAILED_RUNNER_STATE = "failed"
    FINISHED_RUNNER_STATES = [PASSED_RUNNER_STATE, FAILED_RUNNER_STATE]

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
          o.on('-b', '--selenium_browser=selenium_browser', "The Selenium browser (e.g. *firefox). See http://selenium-rc.openqa.org/") do |selenium_browser|
            params[:selenium_browser] = selenium_browser
          end

          o.on('-h', '--selenium_host=SELENIUM_HOST', "The host name of the Selenium Server relative to where this file is executed") do |host|
            params[:selenium_host] = host
          end

          o.on('-p', '--selenium_port=SELENIUM_PORT', "The port of the Selenium Server relative to where this file is executed") do |port|
            params[:selenium_port] = port
          end

          o.on('-u', '--spec_url=SPEC_URL', "The url of the js spec server, relative to the browsers running via the Selenium Server") do |spec_url|
            params[:spec_url] = spec_url
          end

          o.on('-t', '--timeout=TIMEOUT', "The timeout limit of the test run") do |timeout|
            params[:timeout] = Integer(timeout)
          end

          o.on_tail
        end
        parser.order!(argv)
        run params
      end
    end

    attr_reader :parameters, :selenium_client, :current_status, :flushed_console
    def initialize(parameters)
      @parameters = parameters
      @flushed_console = ""
    end

    def run
      if parameters[:timeout]
         Timeout.timeout(parameters[:timeout]) {do_run}
      else
        do_run
      end
    end

    protected
    def do_run
      start_selenium_client
      wait_for_session_to_finish
      flush_console
      suite_passed?
    end

    def start_selenium_client
      uri =  URI.parse(parameters[:spec_url] || "http://localhost:8080/specs")
      @selenium_client = Selenium::Client::Driver.new(
        :host => parameters[:selenium_host] || "0.0.0.0",
        :port => parameters[:selenium_port] || 4444,
        :browser => parameters[:selenium_browser] || "*firefox",
        :url => "#{uri.scheme}://#{uri.host}:#{uri.port}"
      )
      selenium_client.start
      selenium_client.open([uri.path, uri.query].compact.join("?"))
    end

    def wait_for_session_to_finish
      while !suite_finished?
        poll
        flush_console
        sleep 0.25
      end
    end

    def poll
      raw_status = selenium_client.get_eval("window.JsTestServer.status()")
      unless raw_status.to_s == ""
        @current_status = JSON.parse(raw_status)
      end
    end

    def suite_finished?
      current_status && FINISHED_RUNNER_STATES.include?(runner_state)
    end

    def flush_console
      if current_status
        STDOUT.print console.gsub(flushed_console)
        @flushed_console = console
      end
    end

    def suite_passed?
      runner_state == PASSED_RUNNER_STATE
    end

    def runner_state
      current_status["runner_state"]
    end

    def console
      current_status["console"]
    end
  end
end
