module JsTestCore
  module Resources
    class SessionFinish < Resources::Resource
      map("/sessions")

      post "/finish" do
        call
      end

      post "/:session_id/finish" do
        call
      end

      def call
        if runner = SeleniumSession.find(session_id)
          runner.finalize(request['text'])
        else
          STDOUT.puts request['text']
        end
        [200, {}, request['text']]
      end

      protected
      def session_id
        params["session_id"]
      end
    end
  end
end