module JsTestCore
  module Resources
    class Resource < LuckyLuciano::Resource
      protected
      
      def spec_root_path; server.spec_root_path; end
      def implementation_root_path; server.implementation_root_path; end
      def public_path; server.public_path; end
      def core_path; server.core_path; end
      def request; server.request; end
      def response; server.response; end
      def root_url; server.root_url; end

      def server
        JsTestCore::Server
      end

      def not_found
        body = Representations::NotFound.new(:path_info => request.path_info).to_s        
        [
          404,
          {
            "Content-Type" => "text/html",
            "Content-Length" => body.size.to_s
          },
          body
        ]
      end
    end
  end
end