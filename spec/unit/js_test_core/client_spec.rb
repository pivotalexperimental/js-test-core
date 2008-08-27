require File.expand_path("#{File.dirname(__FILE__)}/../unit_spec_helper")

module JsTestCore
  describe Client do
    describe '.run' do
      attr_reader :stdout
      before do
        @stdout = StringIO.new
        Client.const_set(:STDOUT, stdout)
      end

      after do
        Client.__send__(:remove_const, :STDOUT)
      end

      it "tells the server to start a suite run in Firefox" do
        request = "http request"
        mock(start_suite_response = Object.new).body {"suite_id=my_suite_id"}
        mock(request).post("/runners/firefox", "selenium_host=localhost&selenium_port=4444") do
          start_suite_response
        end
        mock(Net::HTTP).start(DEFAULT_HOST, DEFAULT_PORT).yields(request)

        stub(request).get do
          stub(suite_response = Object.new).body {"status=completed"}
          suite_response
        end
        Client.run
      end

      it "polls the status of the suite until the suite is complete" do
        request = "http request"
        stub(start_suite_response = Object.new).body {"suite_id=my_suite_id"}
        stub(request).post {start_suite_response}

        suite_statuses = ["status=running", "status=running", "status=completed"]
        mock(request).get("/suites/my_suite_id") do
          stub(suite_response = Object.new).body {suite_statuses.shift}
          suite_response
        end.times(3)
        mock(Net::HTTP).start(DEFAULT_HOST, DEFAULT_PORT).yields(request)

        Client.run
      end

#      context 'when successful' do
#        before do
#          request = Object.new
#          mock(request).post("/runners/firefox", "selenium_host=localhost&selenium_port=4444")
#          response = Object.new
#          mock(response).body {""}
#          mock(Net::HTTP).start(DEFAULT_HOST, DEFAULT_PORT).yields(request) {response}
#          stub(Client).puts
#        end
#
#        it "returns true" do
#          Client.run.should be_true
#        end
#
#        it "prints 'SUCCESS'" do
#          mock(Client).puts("SUCCESS")
#          Client.run
#        end
#      end
#
#      context 'when unsuccessful' do
#        before do
#          request = Object.new
#          mock(request).post("/runners/firefox", "selenium_host=localhost&selenium_port=4444")
#          response = Object.new
#          mock(response).body {"the failure message"}
#          mock(Net::HTTP).start(DEFAULT_HOST, DEFAULT_PORT).yields(request) {response}
#          stub(Client).puts
#        end
#
#        it "returns false" do
#          Client.run.should be_false
#        end
#
#        it "prints 'FAILURE' and the error message(s)" do
#          mock(Client).puts("FAILURE")
#          mock(Client).puts("the failure message")
#          Client.run
#        end
#      end

#      describe "arguments" do
#        attr_reader :request, :response
#        before do
#          @request = Object.new
#          @response = Object.new
#          mock(response).body {""}
#          mock(Net::HTTP).start(DEFAULT_HOST, DEFAULT_PORT).yields(request) {response}
#          stub(Client).puts
#        end
#
#        describe "when passed a custom spec_url" do
#          it "passes the spec_url as a post parameter" do
#            spec_url = 'http://foobar.com/foo'
#            mock(request).post(
#              "/runners/firefox",
#              "selenium_host=localhost&selenium_port=4444&spec_url=#{CGI.escape(spec_url)}"
#            )
#            Client.run(:spec_url => spec_url)
#          end
#        end
#
#        describe "when passed a custom selenium host" do
#          it "passes the selenium_host as a post parameter" do
#            selenium_host = 'test-runner'
#            mock(request).post(
#              "/runners/firefox",
#              "selenium_host=test-runner&selenium_port=4444"
#            )
#            Client.run(:selenium_host => selenium_host)
#          end
#        end
#
#        describe "when passed a custom selenium port" do
#          it "passes the selenium_port as a post parameter" do
#            selenium_port = 5000
#            mock(request).post(
#              "/runners/firefox",
#              "selenium_host=localhost&selenium_port=5000"
#            )
#            Client.run(:selenium_port => selenium_port)
#          end
#        end
#      end
    end
#    
#    describe ".run_argv" do
#      attr_reader :request, :response
#      before do
#          @request = Object.new
#          @response = Object.new
#          mock(response).body {""}
#          mock(Net::HTTP).start(DEFAULT_HOST, DEFAULT_PORT).yields(request) {response}
#          stub(Client).puts
#        end
#
#      describe "when passed a custom spec_url" do
#        it "passes the spec_url as a post parameter" do
#          spec_url = 'http://foobar.com/foo'
#          mock(request).post(
#            "/runners/firefox",
#            "selenium_host=localhost&selenium_port=4444&spec_url=#{CGI.escape(spec_url)}"
#          )
#          Client.run_argv(['--spec_url', spec_url])
#        end
#      end
#
#      describe "when passed a custom selenium host" do
#        it "passes the selenium_host as a post parameter" do
#          selenium_host = 'test-runner'
#          mock(request).post(
#            "/runners/firefox",
#            "selenium_host=test-runner&selenium_port=4444"
#          )
#          Client.run_argv(['--selenium_host', selenium_host])
#        end
#      end
#
#      describe "when passed a custom selenium port" do
#        it "passes the selenium_port as a post parameter" do
#          selenium_port = 5000
#          mock(request).post(
#            "/runners/firefox",
#            "selenium_host=localhost&selenium_port=5000"
#          )
#          Client.run_argv(['--selenium_port', selenium_port.to_s])
#        end
#      end
#    end

    describe '#parts_from_query' do
      attr_reader :client
      before do
        @client = Client.new(params_does_not_matter = {})
      end

      it "parses empty query into an empty hash" do
        client.parts_from_query("").should == {}
      end

      it "parses a single key value pair into a single-element hash" do
        client.parts_from_query("foo=bar").should == {'foo' => 'bar'}
      end

      it "parses a multiple key value pairs into a multi-element hash" do
        client.parts_from_query("foo=bar&baz=quux").should == {'foo' => 'bar', 'baz' => 'quux'}
      end
    end
  end
end
