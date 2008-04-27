module JsTestCore
  module Resources
    module Specs
      class SpecFile < File
        def spec_files
          [self]
        end

        def get(request, response)
          raise NotImplementedError, "#{self.class}#get needs to be implemented"
        end
      end
    end
  end
end