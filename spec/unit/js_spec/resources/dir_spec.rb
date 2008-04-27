require File.expand_path("#{File.dirname(__FILE__)}/../../unit_spec_helper")

module JsTestCore
  module Resources
    describe Dir do
      attr_reader :dir, :absolute_path, :relative_path

      describe "in core dir" do
        before do
          @absolute_path = core_path
          @relative_path = "/core"
          @dir = Resources::Dir.new(absolute_path, relative_path)
        end

        describe "#locate when passed a name of a real file" do
          it "returns a Resources::File representing it" do
            file = dir.locate("JsTestCore.css")
            file.relative_path.should == "/core/JsTestCore.css"
            file.absolute_path.should == "#{core_path}/JsTestCore.css"
          end
        end
      end
    end
  end
end
