module LuckyLuciano
  class Resource
    class << self
      attr_reader :base_path

      def path(*sub_paths)
        params = sub_paths.last.is_a?(Hash) ? sub_paths.pop : nil
        full_path = "#{base_path}/#{sub_paths.join("/")}".gsub("//", "/").gsub(/\/$/, "")
        if params
          query = build_query(params)
          "#{full_path}?#{query}"
        else
          full_path
        end
      end

      def map(base_path)
        self.base_path = base_path
      end

      def recorded_http_handlers
        @recorded_http_handlers ||= []
      end

      def route_handler
        create_sinatra_handler
      end

      ["get", "put", "post", "delete"].each do |http_verb|
        class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{http_verb}(relative_path, opts={}, &block)
          recorded_http_handlers << [:#{http_verb}, relative_path, opts, block]
        end
        RUBY
      end
      
      protected
      attr_writer :base_path

      def build_query(params)
        params.to_a.inject([]) do |splatted_params, (key, value)|
          [value].flatten.each do |value_in_param|
            splatted_params << "#{URI.escape(key.to_s)}=#{URI.escape(value_in_param.to_s)}"
          end
          splatted_params
        end.join("&")
      end

      def create_sinatra_handler
        handlers = recorded_http_handlers
        resource_class = self
        Module.new do
          (class << self; self; end).class_eval do
            define_method(:registered) do |app|
              handlers.each do |handler|
                verb, relative_path, opts, block = handler
                app.send(verb, "#{resource_class.base_path}#{relative_path.gsub(/\/$/, "")}", opts) do
                  resource_class.new(app).instance_eval(&block)
                end
              end
            end
          end
        end
      end
    end

    attr_reader :app

    def initialize(app)
      @app = app
    end
  end
end