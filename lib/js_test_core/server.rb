module JsTestCore
  class Server
    class << self
      attr_accessor :instance

      def run(spec_root_path, implementation_root_path, public_path, server_options = {})
        server_options[:Host] ||= DEFAULT_HOST
        server_options[:Port] ||= DEFAULT_PORT
        @instance = new(spec_root_path, implementation_root_path, public_path, server_options[:Host], server_options[:Port])
        instance.run server_options
      end

      def spec_root_path; instance.spec_root_path; end
      def implementation_root_path; instance.implementation_root_path; end
      def public_path; instance.public_path; end
      def core_path; instance.core_path; end
      def test_dir_class; instance.test_dir_class; end
      def test_file_class; instance.test_file_class; end
      def request; instance.request; end
      def response; instance.response; end
      def root_url; instance.root_url; end
    end

    attr_reader :host, :port, :spec_root_path, :implementation_root_path, :public_path

    def initialize(spec_root_path, implementation_root_path, public_path, host=DEFAULT_HOST, port=DEFAULT_PORT)
      dir = ::File.dirname(__FILE__)
      @spec_root_path = ::File.expand_path(spec_root_path)
      @implementation_root_path = ::File.expand_path(implementation_root_path)
      @public_path = ::File.expand_path(public_path)
      @host = host
      @port = port
    end

    def run(options)
      server = ::Thin::Server.new(options[:Host], options[:Port])
      server.backend = ::Thin::Backends::JsTestCoreServer.new(options[:Host], options[:Port])
      server.backend.server = server
      server.start!
    end

    def root_url
      "http://#{host}:#{port}"
    end

    def core_path
      JsTestCore.core_path
    end

    def test_dir_class
      JsTestCore.adapter.test_dir_class
    end

    def test_file_class
      JsTestCore.adapter.test_file_class
    end
    
    protected
    def path_parts(req)
      request.path_info.split('/').reject { |part| part == "" }
    end

    def get_resource(request)
      path_parts(request).inject(Resources::WebRoot.new(:public_path => public_path)) do |resource, child_resource_name|
        resource.locate(child_resource_name)
      end
    rescue Exception => e
      detailed_exception = Exception.new("Error handling path #{request.path_info}\n#{e.message}")
      detailed_exception.set_backtrace(e.backtrace)
      raise detailed_exception
    end
  end
end