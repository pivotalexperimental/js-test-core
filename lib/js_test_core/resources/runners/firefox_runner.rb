module JsTestCore
  module Resources
    class Runners
      class FirefoxRunner < ThinRest::Resource
        class << self
          def resume(suite_id, text)
            if instances[suite_id]
              runner = instances.delete(suite_id)
              runner.finalize(text)
            end
          end

          def register_instance(runner)
            instances[runner.suite_id] = runner
          end

          protected
          def instances
            @instances ||= {}
          end
        end

        include FileUtils
        attr_reader :profile_dir, :driver

        def after_initialize
          profile_base = "#{::Dir.tmpdir}/js_test_core/firefox"
          mkdir_p profile_base
          @profile_dir = "#{profile_base}/#{Time.now.to_i}"
        end

        def post
          spec_url = (rack_request && rack_request['spec_url']) ? rack_request['spec_url'] : spec_suite_url
          parsed_spec_url = URI.parse(spec_url)
          selenium_port = (rack_request['selenium_port'] || 4444).to_i
          @driver = Selenium::SeleniumDriver.new(
            rack_request['selenium_host'] || 'localhost',
            selenium_port,
            '*firefox',
            "#{parsed_spec_url.scheme}://#{parsed_spec_url.host}:#{parsed_spec_url.port}"
          )
          begin
            driver.start
          rescue Errno::ECONNREFUSED => e
            raise Errno::ECONNREFUSED, "Cannot connect to Selenium Server on port #{selenium_port}. To start the selenium server, run `selenium`."
          end
          Thread.start do
            driver.open(spec_url)
          end
          response.status = 200
          FirefoxRunner.register_instance self
        end

        def finalize(text)
          driver.stop
          connection.send_body(text)
        end

        def suite_id
          driver.session_id
        end

        protected

        def spec_suite_url
          "#{Server.root_url}/specs"
        end
      end
    end
  end
end
