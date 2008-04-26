module JsTestCore
  module Resources
    module Specs
      class SpecFile < File
        def spec_files
          [self]
        end

        def get(request, response)
          raise NotImplementedError, "get"
        end
      end
    end
  end
end