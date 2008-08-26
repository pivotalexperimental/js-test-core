require File.expand_path("#{File.dirname(__FILE__)}/../../unit_spec_helper")

module JsTestCore
  module Resources
    describe SuiteFinish do
      attr_reader :stdout, :suite_finish, :suite
      before do
        @stdout = StringIO.new
        SuiteFinish.const_set(:STDOUT, stdout)
      end

      after do
        SuiteFinish.__send__(:remove_const, :STDOUT)
      end

      describe ".post" do
        describe "when Suite#id == 'user'" do
          before do
            @suite = Suite.new(:id => 'user')
            @suite_finish = SuiteFinish.new(:connection => connection, :suite => suite)
          end

          it "writes the body of the request to stdout" do
            body = "The text in the POST body"
            request = Rack::Request.new({'rack.input' => StringIO.new("text=#{body}")})
            request.body.string.should == "text=#{body}"
            response = Rack::Response.new

            suite_finish.post
            stdout.string.should == "#{body}\n"
          end

          it "sets the Content-Length to be 0" do
            request = Rack::Request.new('rack.input' => StringIO.new(""))
            response = Rack::Response.new

            response.headers.to_s.should_not include("Content-Length: ")
            suite_finish.post
            response.headers.to_s.should include("Content-Length: 0\r\n")
          end
        end

        describe "when Suite#id is not 'user'" do
          attr_reader :rack_request, :runner, :suite_id, :driver
          before do
            @rack_request = Rack::Request.new( Rack::MockRequest.env_for('/runners/firefox') )
            stub(connection).rack_request {rack_request}
            @suite_id = '12345'
            @driver = "Selenium Driver"
            stub(Selenium::SeleniumDriver).new('localhost', 4444, '*firefox', 'http://0.0.0.0:8080') do
              driver
            end
            stub(driver).start
            stub(driver).open
            stub(driver).session_id {suite_id}
            stub(Thread).start.yields

            @runner = Runners::FirefoxRunner.new(:connection => connection)
            runner.post

            @suite = Suite.new(:id => suite_id)
            @suite_finish = SuiteFinish.new(:connection => connection, :suite => suite)
          end

          it "resumes the FirefoxRunner" do
            body = "The text in the POST body"
            rack_request["text"] = body
            mock.proxy(Runners::FirefoxRunner).resume(suite_id, body)
            mock(driver).stop
            stub_send_data
            stub(connection).close_connection

            suite_finish.post
          end

          it "sets the Content-Length to be 0" do
            stub(Runners::FirefoxRunner).resume
            stub(driver).stop
            stub(connection).send_data
            stub(connection).close_connection

            connection.response.headers.to_s.should_not include("Content-Length:")
            suite_finish.post
            connection.response.headers.to_s.should include("Content-Length: 0\r\n")
          end
        end
      end
    end
  end
end
