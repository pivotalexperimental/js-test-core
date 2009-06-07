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
      def root_url; instance.root_url; end
    end

    attr_accessor :host, :port, :spec_root_path, :implementation_root_path, :public_path

    def initialize(params={})
      params = {
        :spec_root_path => File.expand_path("./specs/javascripts"),
        :implementation_root_path => File.expand_path("./public/javascripts"),
        :public_path => File.expand_path("./public"),
        :host => DEFAULT_HOST,
        :port => DEFAULT_PORT,
      }.merge(params)
      @spec_root_path = ::File.expand_path(params[:spec_root_path])
      @implementation_root_path = ::File.expand_path(params[:implementation_root_path])
      @public_path = ::File.expand_path(params[:public_path])
      @host = params[:host]
      @port = params[:port]
    end

    def root_url
      "http://#{host}:#{port}"
    end

    def core_path
      JsTestCore.core_path
    end
  end
end