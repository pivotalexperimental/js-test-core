require File.expand_path("#{File.dirname(__FILE__)}/../../unit_spec_helper")

module JsTestCore
  module Resources
    describe WebRoot do
      describe "GET /stylesheets" do
        it "returns a page with a of files in the directory" do
          response = get("/stylesheets")
          response.body.should include('<a href="example.css">example.css</a>')
        end
      end

      describe "GET /stylesheets/example.css" do
        it "returns a page with a of files in the directory" do
          path = "#{public_path}/stylesheets/example.css"
          response = get("/stylesheets/example.css")
          response.headers['Content-Type'].should == "text/css"
          response.headers['Content-Length'].should == ::File.size(path).to_s
          response.headers['Last-Modified'].should == ::File.mtime(path).rfc822
        end
      end
    end
  end
end
