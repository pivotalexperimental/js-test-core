module JsTestCore
  module Resources
    module Specs
      class SpecFileSuperclass < ::JsTestCore::Resources::File
        include Spec
        
        def get
          if ::File.exists?(absolute_path) && ::File.extname(absolute_path) != ".js"
            super
          else
            get_generated_spec
          end
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