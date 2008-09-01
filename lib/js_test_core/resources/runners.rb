dir = File.dirname(__FILE__)

module JsTestCore
  module Resources
    class Runners < ThinRest::Resource
      route 'firefox' do |env, name|
        Runner.new(env.merge(:selenium_browser_start_command => "*firefox"))
      end
      route 'iexplore' do |env, name|
        Runner.new(env.merge(:selenium_browser_start_command => "*iexplore"))
      end

      def post
        runner = Runner.new(env.merge(
          :selenium_browser_start_command => rack_request["selenium_browser_start_command"]
        ))
        runner.post
      end
    end
  end
end