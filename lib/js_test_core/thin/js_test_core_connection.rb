module Thin
  class JsTestCoreConnection < ThinRest::Connection
    protected
    def root_resource
      WebRoot
    end
  end
end