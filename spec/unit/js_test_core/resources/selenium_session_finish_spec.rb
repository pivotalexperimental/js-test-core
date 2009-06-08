require File.expand_path("#{File.dirname(__FILE__)}/../../unit_spec_helper")

module JsTestCore
  module Resources
    describe SeleniumSessionFinish do
      attr_reader :stdout
      before do
        @stdout = StringIO.new
        SeleniumSessionFinish.const_set(:STDOUT, stdout)
      end

      after do
        SeleniumSessionFinish.__send__(:remove_const, :STDOUT)
      end

      describe "POST /selenium_sessions/finish" do
        context "when passed a :session_id parameter" do
          it "returns the text and writes the text to stdout" do
            text = "The text in the POST body"

            response = post(SeleniumSessionFinish.path("/finish", :session_id => 1), :text => text)
            response.should be_http(
              200,
              {},
              text
            )
            stdout.string.should == "#{text}\n"
          end
        end

        context "when the session_id cookie is set" do

        end
      end

      describe "POST /sessions/:session_id/finish" do
        it "returns the text and writes the text to stdout" do
          text = "The text in the POST body"

          response = post(SeleniumSessionFinish.path("/:session_id/finish", :session_id => 1), :text => text)
          response.should be_http(
            200,
            {},
            text
          )
          stdout.string.should == "#{text}\n"
        end
      end
    end
  end
end
