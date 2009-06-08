module JsTestCore
  module Resources
    class SeleniumSessionFinish < Resource
      map("/selenium_sessions")

      post "/finish" do
        call
      end

      post "/:session_id/finish" do
        call
      end

      def call
        if selenium_session = Models::SeleniumSession.find(session_id)
          selenium_session.finish(request['text'])
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