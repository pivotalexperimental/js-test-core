module JsTestCore
  module Resources
    class Suite < ThinRest::Resource
      class Collection < ThinRest::Resource
        route ANY do |env, name|
          Suite.new(env.merge(:name => name))
        end
      end

      property :id

      route 'finish' do |env, name|
        SuiteFinish.new(env.merge(:suite => self))
      end
    end
  end
end