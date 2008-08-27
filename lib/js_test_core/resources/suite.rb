module JsTestCore
  module Resources
    class Suite < ThinRest::Resource
      class Collection < ThinRest::Resource
        route ANY do |env, name|
          Suite.new(env.merge(:name => name))
        end
      end

      class << self
        def locate(id)
          new id
        end
      end

      property :id
      
      def locate(name)
        if name == 'finish'
          SuiteFinish.new self
        else
          raise ArgumentError, "Invalid path: #{name}"
        end
      end
    end
  end
end