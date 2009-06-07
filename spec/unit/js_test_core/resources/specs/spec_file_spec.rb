require File.expand_path("#{File.dirname(__FILE__)}/../../../unit_spec_helper")

module JsTestCore
  module Resources
    module Specs
      describe SpecFile do
        describe "GET" do
          describe "GET /specs/failing_spec" do
            it "renders a suite only for failing_spec.js as text/html" do
              absolute_path = "#{spec_root_path}/failing_spec.js"

              response = get(SpecFile.path("failing_spec"))

              response.status.should == 200
              response.headers["Content-Type"].should == "text/html"
              response.headers["Last-Modified"].should == ::File.mtime(absolute_path).rfc822
              doc = Nokogiri::HTML(response.body)
              js_files = doc.search("script").map {|script| script["src"]}
              js_files.should include("/specs/failing_spec.js")
            end
          end

          describe "GET /specs/failing_spec.js" do
            it "renders the contents of failing_spec.js as text/javascript" do
              absolute_path = "#{spec_root_path}/failing_spec.js"

              response = get(SpecFile.path("failing_spec.js"))

              response.status.should == 200
              response.headers["Content-Type"].should == "text/javascript"
              response.headers["Last-Modified"].should == ::File.mtime(absolute_path).rfc822
              response.body.should == ::File.read(absolute_path)
            end
          end

          describe "GET /specs/custom_suite" do
            it "renders the custom_suite.html file" do
              path = "#{spec_root_path}/custom_suite.html"

              response = get(SpecFile.path("custom_suite.html"))
              response.status.should == 200
              response.headers["Content-Type"].should == "text/html"
              response.headers["Last-Modified"].should == ::File.mtime(path).rfc822
              response.body.should == ::File.read(path)
            end
          end
        end
      end
    end
  end
end
