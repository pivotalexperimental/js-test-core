module JsTestCore
  class Server
    class << self
      attr_accessor :rackup_path
      def start
        require "thin"
        Thin::Runner.new([
          "--port", "8080",
          "--rackup", File.expand_path(rackup_path),
          "start"]
        ).run!
      end

      def standalone_rackup(rack_builder, spec_path=nil, root_path=nil)
        require "sinatra"

        JsTestCore.spec_path = spec_path || File.expand_path("./spec/javascripts")
        if File.directory?(JsTestCore.spec_path)
          puts "Spec root path is #{JsTestCore.spec_path}"
        else
          raise ArgumentError, "#{spec_path} #{JsTestCore.spec_path} must be a directory"
        end

        JsTestCore.root_path = root_path || File.expand_path("./public")
        if File.directory?(JsTestCore.root_path)
          puts "Public path is #{JsTestCore.root_path}"
        else
          raise ArgumentError, "#{root_path} #{JsTestCore.root_path} must be a directory"
        end

        rack_builder.use JsTestCore::App
        rack_builder.run Sinatra::Application
      end
    end
  end
end