module JsTestCore
  module Resources
    class SuiteFinish < ThinRest::Resource
      attr_reader :suite
      def initialize(suite)
        @suite = suite
      end

      def post
        if suite.id == 'user'
          STDOUT.puts request['text']
        else
          Runners::FirefoxRunner.resume(suite.id, request['text'])
        end
        response.headers['Content-Length'] = "0"
      end
    end
  end
end