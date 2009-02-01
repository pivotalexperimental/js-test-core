module JsTestCore
  module Resources
    class FileNotFound < ThinRest::Resources::Resource
      property :name
      def get
        connection.send_head(404)
        connection.send_body(Representations::FileNotFound.new(self, :path => rack_request.path_info).to_s)
      end
    end
  end
end