require File.expand_path("#{File.dirname(__FILE__)}/../../../unit_spec_helper")

module JsTestCore
  module Resources
    describe Runners::FirefoxRunner do
      attr_reader :runner, :request, :response, :driver, :suite_id
      
      before do
        Thread.current[:connection] = connection
        @driver = "Selenium Driver"
        @suite_id = 12345
        stub(driver).session_id {suite_id}
        stub(Selenium::SeleniumDriver).new('localhost', 4444, '*firefox', 'http://0.0.0.0:8080') do
          driver
        end
        stub(EventMachine).add_timer
      end

      describe ".resume" do
        describe "when there is a runner for the passed in suite_id" do
          before do
            @request = Rack::Request.new( Rack::MockRequest.env_for('/runners/firefox') )
            @response = Rack::Response.new
            stub(Thread).start.yields
            
            stub(driver).start
            stub(driver).open
            stub(driver).stop
            stub(EventMachine).send_data
            stub(EventMachine).close_connection

            @runner = Runners::FirefoxRunner.post(request, response)
            runner.class.should == Runners::FirefoxRunner
            runner.suite_id.should == suite_id
          end

          it "removes and finalizes the instance that has the suite_id" do
            mock.proxy(runner).finalize("Browser output")
            Runners::FirefoxRunner.send(:instances)[suite_id].should == runner
            Runners::FirefoxRunner.resume(suite_id, "Browser output")
            Runners::FirefoxRunner.send(:instances)[suite_id].should be_nil
          end
        end

        describe "when there is not a runner for the passed in suite_id" do
          it "does nothing" do
            lambda do
              Runners::FirefoxRunner.resume("invalid", "nothing happens")
            end.should_not raise_error
          end
        end
      end

      describe ".post" do
        attr_reader :firefox_profile_path
        before do
          @request = Rack::Request.new( Rack::MockRequest.env_for('/runners/firefox') )
          @response = Rack::Response.new
          stub(Thread).start.yields
          stub(driver).start
          stub(driver).open
        end

        it "responds with a 302 and Location: to /runners/firefox/:runner_id" do
          Runners::FirefoxRunner.post(request, response)

          response.status.should == 302
          response['Location'].should == "/runners/firefox/#{suite_id}"
          response['Content-Length'].should == "0"
        end

        it "initializes and registers a new instance of FirefoxRunner" do
          Runners::FirefoxRunner.instances.should be_empty
          Runners::FirefoxRunner.post(request, response)
          Runners::FirefoxRunner.instances.length.should == 1
          runner = Runners::FirefoxRunner.instances.values.first
          runner.class.should == Runners::FirefoxRunner
        end
        
        describe "when a selenium_host parameter is passed into the request" do
          before do
            request['selenium_host'] = "another-machine"
          end

          it "starts the Selenium Driver with the passed in selenium_host" do
            mock(Selenium::SeleniumDriver).new('another-machine', 4444, '*firefox', 'http://0.0.0.0:8080') do
              driver
            end
            Runners::FirefoxRunner.post(request, response)
          end
        end

        describe "when a selenium_host parameter is not passed into the request" do
          before do
            request['selenium_host'].should be_nil
          end

          it "starts the Selenium Driver from localhost" do
            mock(Selenium::SeleniumDriver).new('localhost', 4444, '*firefox', 'http://0.0.0.0:8080') do
              driver
            end
            Runners::FirefoxRunner.post(request, response)
          end
        end

        describe "when a selenium_port parameter is passed into the request" do
          before do
            request['selenium_port'] = "4000"
          end

          it "starts the Selenium Driver with the passed in selenium_port" do
            mock(Selenium::SeleniumDriver).new('localhost', 4000, '*firefox', 'http://0.0.0.0:8080') do
              driver
            end
            Runners::FirefoxRunner.post(request, response)
          end
        end

        describe "when a selenium_port parameter is not passed into the request" do
          before do
            request['selenium_port'].should be_nil
          end

          it "starts the Selenium Driver from localhost" do
            mock(Selenium::SeleniumDriver).new('localhost', 4444, '*firefox', 'http://0.0.0.0:8080') do
              driver
            end
            Runners::FirefoxRunner.post(request, response)
          end
        end

        describe "when a spec_url is passed into the request" do
          before do
            request['spec_url'] = "http://another-host:8080/specs/subdir"
          end

          it "runs Selenium with the passed in host and part to run the specified spec suite in Firefox" do
            mock(Selenium::SeleniumDriver).new('localhost', 4444, '*firefox', 'http://another-host:8080') do
              driver
            end
            mock(driver).start
            mock(driver).open("http://another-host:8080/specs/subdir")

            Runners::FirefoxRunner.post(request, response)
          end
        end

        describe "when a spec_url is not passed into the request" do
          before do
            request['spec_url'].should be_nil
            mock(Selenium::SeleniumDriver).new('localhost', 4444, '*firefox', 'http://0.0.0.0:8080') do
              driver
            end
          end

          it "uses Selenium to run the entire spec suite in Firefox" do
            mock(driver).start
            mock(driver).open("http://0.0.0.0:8080/specs")

            Runners::FirefoxRunner.post(request, response)
          end
        end
      end

      describe ".locate" do
        context "when passed a registered suite_id" do
          before do
            @runner = Runners::FirefoxRunner.new(driver)
            Runners::FirefoxRunner.register_instance runner
          end

          it "returns the registered instance of FirefoxRunner" do
            Runners::FirefoxRunner.locate(runner.suite_id).should == runner
          end
        end
      end

      describe "#get" do
        before(:each) do
          @request = Rack::Request.new( Rack::MockRequest.env_for('/runners/firefox') )
          @response = Rack::Response.new
          @runner = Runners::FirefoxRunner.new(driver)
          Runners::FirefoxRunner.register_instance runner
        end

        it "responds with a 200 status" do
          runner.get(request, response)

          response.status.should == 200
        end

        context "when #finished? is true" do
          attr_reader :text
          before do
            stub(driver).start
            stub(driver).open
            stub(driver).stop
            @text = "The text"
            runner.finalize(text)
            runner.should be_finished
          end

          it "responds with #text as the body" do
            runner.get(request, response)
            response.body.should == text
          end

          it "unregisters itself" do
            Runners::FirefoxRunner.locate(runner.suite_id).should_not be_nil
            runner.get(request, response)
            Runners::FirefoxRunner.locate(runner.suite_id).should be_nil
          end

          it "does not set a timer" do
            dont_allow(EventMachine).add_timer(anything)
            runner.get(request, response)
          end
        end

        context "when #finished? is false" do
          before do
            runner.should_not be_finished
          end

          it "does not set the body" do
            dont_allow(response).body=(anything)
            runner.get(request, response)
          end

          it "does not unregister itself" do
            Runners::FirefoxRunner.locate(runner.suite_id).should_not be_nil
            runner.get(request, response)
            Runners::FirefoxRunner.locate(runner.suite_id).should_not be_nil
          end

          it "responds with a pending status" do
            mock(connection).close_connection(true)

            runner.get(request, response)

            JSON.parse(response.body).should == {'status' => 'pending'}
          end

#          it "sets a timer of 30 seconds" do
#            mock(EventMachine).add_timer(30)
#            runner.get(request, response)
#          end
#
#          context "when 30 seconds elapsed" do
#            attr_reader :result
#            before do
#              @result = ""
#              stub(EventMachine).send_data do |signature, data, data_length|
#                result << data
#              end
#            end
#
#            it "responds with a pending status and closes the connection" do
#              timer = nil
#              mock(EventMachine).add_timer(30) do |time, timer_arg|
#                timer = timer_arg
#              end
#              mock(connection).close_connection(true)
#
#              runner.get(request, response)
#
#              # 30 seconds elapse
#              timer.call
#
#              JSON.parse(result).should == {'status' => 'pending'}
#            end
#          end
        end

        describe "when #finalize is invoked" do
          it "responds with a finished status and closes the connection" do

          end
        end
      end

      describe "#finalize" do
        before do
          @request = Rack::Request.new( Rack::MockRequest.env_for('/runners/firefox') )
          @response = Rack::Response.new
          @runner = Runners::FirefoxRunner.new(driver)
          stub(driver).start
          stub(driver).open
          stub(driver).stop
          Runners::FirefoxRunner.post(request, response)
        end

        it "kills the browser" do
          mock(driver).stop

          runner.finalize("The text")
        end

        context "when passed in text is empty" do
          it "sets #payload to :status => success" do
            runner.finalize("")
            runner.payload.should == {'status' => 'success'}
          end
        end

        context "when passed in text is not empty" do
          it "sets #payload to :status => failure with passed in text" do
            runner.finalize("bad")
            runner.payload.should == {'status' => 'failure', 'reason' => "bad"}
          end
        end

        it "sets finished? to true" do
          runner.should_not be_finished
          runner.finalize("The text")
          runner.should be_finished
        end
      end
    end
  end
end
