require File.expand_path("#{File.dirname(__FILE__)}/../../unit_spec_helper")

module JsTestCore
  module Resources
    describe WebRoot do
      attr_reader :web_root
      before(:each) do
        @web_root = WebRoot.new(:connection => connection, :public_path => public_path)
      end

      describe "#locate" do
        describe "when passed ''" do
          it "returns self" do
            web_root.locate('').should == web_root
          end
        end

        describe "when passed 'core'" do
          it "returns a Dir representing the JsTestCore core directory" do
            runner = web_root.locate('core')
            runner.should == Resources::Dir.new(
              :connection => connection,
              :absolute_path => JsTestCore::Server.core_path,
              :relative_path => '/core'
            )
          end
        end

        describe "when passed 'implementations'" do
          it "returns a Dir representing the javascript implementations directory" do
            runner = web_root.locate('implementations')
            runner.should == Resources::Dir.new(
              :connection => connection,
              :absolute_path => JsTestCore::Server.implementation_root_path,
              :relative_path => '/implementations'
            )
          end
        end

        describe "when passed 'results'" do
          it "returns a Suite::Collection" do
            runner = web_root.locate('suites')
            runner.class.should == Resources::Suite::Collection
          end
        end

        describe "when passed 'runners'" do
          it "returns a Runner" do
            runner = web_root.locate('runners')
            runner.should be_instance_of(Resources::Runners)
          end
        end

        describe "when passed a directory that is in the public_path" do
          it "returns a Dir representing that directory" do
            runner = web_root.locate('stylesheets')
            runner.should == Resources::Dir.new(
              :connection => connection,
              :absolute_path => "#{JsTestCore::Server.public_path}/stylesheets",
              :relative_path => '/stylesheets'
            )
          end
        end

        describe "when passed a file that is in the public_path" do
          it "returns a File representing that file" do
            runner = web_root.locate('robots.txt')
            runner.should == Resources::File.new(
              :connection => connection,
              :absolute_path => "#{JsTestCore::Server.public_path}/robots.txt",
              :relative_path => '/robots.txt'
            )
          end
        end

        describe "when passed an invalid option" do
          it "returns a 404 response" do
            resource = web_root.locate('invalid')

          end
        end
      end

      describe ".dispatch_specs" do
        describe "#get" do
          attr_reader :request, :response
          before do
            @request = Rack::Request.new({'rack.input' => StringIO.new("")})
            @response = Rack::Response.new
          end

          it "redirects to /specs" do
            WebRoot.dispatch_specs
            mock(connection).send_head(301, :Location => '/specs')
            mock(connection).send_body("<script type='text/javascript'>window.location.href='/specs';</script>")

            web_root.get
          end
        end

        describe "#locate /specs" do
          it "dispatches to a Spec::SpecDir" do
            WebRoot.dispatch_specs

            resource = web_root.locate('specs')
            resource.should == spec_dir('')
          end
        end

      end

      describe "when .dispatch_specs is not called" do
        it "does not cause #locate to dispatch to /specs" do
          web_root.locate('specs').should be_instance_of(FileNotFound)
        end
      end
    end
  end
end
