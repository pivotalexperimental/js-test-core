dir = File.dirname(__FILE__)

module JsTestCore
  module Resources
    class Runners < ThinRest::Resource
      def locate(name)
        if name == 'firefox'
          FirefoxRunner.new
        else
          raise "Invalid path #{name}"
        end
      end
    end
  end
end