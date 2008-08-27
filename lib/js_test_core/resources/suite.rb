module JsTestCore
  module Resources
    class Suite < ThinRest::Resource
      class Collection < ThinRest::Resource
        route ANY do |env, id|
          Suite.new(env.merge(:id => id))
        end
      end

      property :id

      route 'finish' do |env, name|
        SuiteFinish.new(env.merge(:suite => self))
      end
    end
  end
end