require File.expand_path("#{File.dirname(__FILE__)}/unit_spec_helper")

module JsSpec
  describe Client do
    describe '.run' do
      describe 'when successful' do
        before do
          request = Object.new
          mock(request).post("/runners/firefox", {})
          response = Object.new
          mock(response).body {""}
          mock(Net::HTTP).start(DEFAULT_HOST, DEFAULT_PORT).yields(request) {response}
          stub(Client).puts
        end

        it "returns true" do
          Client.run.should be_true
        end

        it "prints 'SUCCESS'" do
          mock(Client).puts("SUCCESS")
          Client.run
        end
      end

      describe 'when unsuccessful' do
        before do
          request = Object.new
          mock(request).post("/runners/firefox", {})
          response = Object.new
          mock(response).body {"the failure message"}
          mock(Net::HTTP).start(DEFAULT_HOST, DEFAULT_PORT).yields(request) {response}
          stub(Client).puts
        end

        it "returns false" do
          Client.run.should be_false
        end

        it "prints 'FAILURE' and the error message(s)" do
          mock(Client).puts("FAILURE")
          mock(Client).puts("the failure message")
          Client.run
        end
      end

      describe "when passed a custom url" do
        attr_reader :request, :response
        before do
          @request = Object.new
          @response = Object.new
          mock(response).body {""}
          mock(Net::HTTP).start(DEFAULT_HOST, DEFAULT_PORT).yields(request) {response}
          stub(Client).puts
        end
        
        it "passes the url as a post parameter" do
          url = 'http://foobar.com/foo'
          mock(request).post("/runners/firefox", {:url => url})
          Client.run(url)
        end
      end
    end
  end
end
