module JsTestCore
  class Configuration
    class << self
      attr_accessor :instance

      def method_missing(method_name, *args, &block)
        if Configuration.instance.respond_to?(method_name)
          Configuration.instance.send(method_name, *args, &block)
        else
          super
        end
      end
    end

    attr_accessor :host, :port, :spec_path, :root_path, :core_path

    def initialize(params={})
      params = {
        :spec_path => File.expand_path("./specs/javascripts"),
        :root_path => File.expand_path("./public"),
        :host => DEFAULT_HOST,
        :port => DEFAULT_PORT,
      }.merge(params)
      @spec_path = ::File.expand_path(params[:spec_path])
      @root_path = ::File.expand_path(params[:root_path])
      @host = params[:host]
      @port = params[:port]
      @core_path = params[:core_path]
    end

    def root_url
      "http://#{host}:#{port}"
    end
  end
end