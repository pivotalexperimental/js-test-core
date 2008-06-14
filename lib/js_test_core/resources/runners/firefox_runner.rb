module JsTestCore
  module Resources
    class Runners
      class FirefoxRunner
        class << self
          def post(request, response)
            spec_url = (request && request['spec_url']) ? request['spec_url'] : spec_suite_url
            parsed_spec_url = URI.parse(spec_url)
            selenium_port = (request['selenium_port'] || 4444).to_i
            driver = Selenium::SeleniumDriver.new(
              request['selenium_host'] || 'localhost',
              selenium_port,
              '*firefox',
              "#{parsed_spec_url.scheme}://#{parsed_spec_url.host}:#{parsed_spec_url.port}"
            )
            runner = new(driver)
            begin
              driver.start
            rescue Errno::ECONNREFUSED => e
              raise Errno::ECONNREFUSED, "Cannot connect to Selenium Server on port #{selenium_port}. To start the selenium server, run `selenium`."
            end
            Thread.start do
              driver.open(spec_url)
            end
            response.status = 302
            response['Location'] = "/runners/firefox/#{runner.suite_id}"
            response['Content-Length'] = "0"
            FirefoxRunner.register_instance runner
            runner
          end

          def locate(id)
            instances[id]
          end

          def resume(suite_id, text)
            if instances[suite_id]
              runner = instances.delete(suite_id)
              runner.finalize(text)
            end
          end

          def register_instance(runner)
            instances[runner.suite_id] = runner
          end

          def unregister_instance(runner)
            instances.delete runner.suite_id
          end

          def instances
            @instances ||= {}
          end

          protected
          def spec_suite_url
            "#{Server.root_url}/specs"
          end
        end

        include FileUtils
        attr_reader :profile_dir, :connection, :driver, :text

        def initialize(driver)
          @driver = driver
          profile_base = "#{::Dir.tmpdir}/js_test_core/firefox"
          mkdir_p profile_base
          @profile_dir = "#{profile_base}/#{Time.now.to_i}"
          @finised = false
        end

        def get(request, response)
          response.status = 200
          if finished?
            response.body = text
            self.class.unregister_instance self
          else
#            response.body = {'status' => 'pending'}.to_json
#            EventMachine.add_timer(30) do
#              response.body = {'status' => 'pending'}.to_json
##              connection.send_body(response)
##              EventMachine.send_data(signature, data, data.length)
#            end
          end
        end

        def finalize(text)
          driver.stop
          @text = text
          @finished = true
        end

        def finished?
          @finished
        end

        def suite_id
          driver.session_id
        end
      end
    end
  end
end
