module JsTestCore
  module Resources
    class FileNotFound < ThinRest::Resource
      property :name
      def get
        response.status = 404
        response.body = "Path #{name} not found. You may want to try the /#{WebRoot.dispatch_strategy} directory."
      end
    end
  end
end