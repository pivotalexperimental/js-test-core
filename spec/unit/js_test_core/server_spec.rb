require File.expand_path("#{File.dirname(__FILE__)}/../unit_spec_helper")

module JsTestCore
  describe Server do
    describe ".cli" do
      attr_reader :server, :builder, :stdout
      before do
        @server = Server.new
        @builder = "builder"

        @stdout = StringIO.new
        Server.const_set(:STDOUT, stdout)
      end

      after do
        Server.__send__(:remove_const, :STDOUT)
      end

      
      context "when the --framework-name and --framework-path are set" do
        it "starts the server" do
          project_spec_dir = File.expand_path("#{File.dirname(__FILE__)}/../..")

          mock.instance_of(Thin::Runner).run!

          stub.proxy(Rack::Builder).new do |builder|
            mock.proxy(builder).use(JsTestCore::App)
            stub.proxy(builder).use
            mock(builder).run(is_a(JsTestCore::App))
          end

          server.cli(
            "--framework-name", "screw-unit",
            "--framework-path", "#{project_spec_dir}/example_framework",
            "--root-path", "#{project_spec_dir}/example_root",
            "--spec-path", "#{project_spec_dir}/example_spec"
          )
        end
      end

      context "when the --framework-name or --framework-path are not set" do
        it "raises an ArgumentError" do
          lambda do
            server.cli
          end.should raise_error(ArgumentError)

          lambda do
            server.cli("--framework-name", "screw-unit")
          end.should raise_error(ArgumentError)

          lambda do
            server.cli("--framework-path", "/path/to/framework")
          end.should raise_error(ArgumentError)
        end
      end
    end
  end
end