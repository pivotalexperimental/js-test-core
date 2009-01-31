module JsTestCore
  module Resources
    module Specs
      class SpecFileSuperclass < ::JsTestCore::Resources::File
        def get
          raise NotImplementedError, "#{self.class}#get_default_generated_spec needs to be implemented"
        end

        protected
        def get_default_generated_spec
          raise NotImplementedError, "#{self.class}#get_default_generated_spec needs to be implemented"
        end
      end

      class SpecFile < SpecFileSuperclass
        def spec_files
          [self]
        end
      end
    end
  end
end