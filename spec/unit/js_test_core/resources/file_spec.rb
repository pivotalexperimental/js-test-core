require File.expand_path("#{File.dirname(__FILE__)}/../../unit_spec_helper")

module JsTestCore
  module Resources
    describe File do
      describe "GET /stylesheets/example.css" do
        it "returns the example.css file content as a css file" do
          path = "#{public_path}/stylesheets/example.css"
          response = get("/stylesheets/example.css")
          response.headers['Content-Type'].should == "text/css"
          response.headers['Content-Length'].should == ::File.size(path).to_s
          response.headers['Last-Modified'].should == ::File.mtime(path).rfc822
        end
      end

      describe "GET /implementations/foo.js" do
        it "returns the foo.js file content as a javascript file" do
          path = "#{public_path}/javascripts/foo.js"
          response = get("/javascripts/foo.js")
          response.headers['Content-Type'].should == "text/javascript"
          response.headers['Content-Length'].should == ::File.size(path).to_s
          response.headers['Last-Modified'].should == ::File.mtime(path).rfc822
        end
      end

      describe "GET /javascripts/subdir/bar.js - Subdirectory" do
        it "returns the subdir/bar.js file content as a javascript file" do
          path = "#{public_path}/javascripts/subdir/bar.js"
          response = get("/javascripts/subdir/bar.js")
          response.headers['Content-Type'].should == "text/javascript"
          response.headers['Content-Length'].should == ::File.size(path).to_s
          response.headers['Last-Modified'].should == ::File.mtime(path).rfc822
        end
      end
    end
  end
end