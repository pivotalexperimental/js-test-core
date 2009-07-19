module JsTestCore
  class Server
    class << self
      attr_writer :instance
      def instance
        @instance ||= new
      end
    end

    def cli(*argv)
      opts = Trollop.options(argv) do
        opt(
          :framework_name,
          "The name of the test framework you want to use. e.g. --framework-name=jasmine",
          :type => String
        )
        opt(
          :framework_path,
          "The name of the test framework you want to use. e.g. --framework-path=./specs/jasmine_core",
          :type => String
        )
        opt(
          :spec_path,
          "The path to the spec files. e.g. --spec-path=./specs",
          :default => "./spec/javascript"
        )
        opt(
          :root_path,
          "The root path of the server. e.g. --root-path=./public",
          :default => "./public"
        )
      end
      JsTestCore.framework_name = opts[:framework_name]
      JsTestCore.framework_path = opts[:framework_path]
      JsTestCore.spec_path = opts[:spec_path]
      JsTestCore.root_path = opts[:root_path]

      STDOUT.puts "root-path is #{JsTestCore.root_path}"
      STDOUT.puts "spec-path is #{JsTestCore.spec_path}"
      start
    end

    def start
      require "thin"
      Thin::Runner.new([
        "--port", "8080",
        "--rackup", File.expand_path(rackup_path),
        "start"]
      ).run!
    end

    def standalone_rackup(rack_builder)
      require "sinatra"

      rack_builder.use JsTestCore::App
      rack_builder.run Sinatra::Application
    end

    protected

    def rackup_path
      dir = File.dirname(__FILE__)
      File.expand_path("#{dir}/../../standalone.ru")
    end
  end
end