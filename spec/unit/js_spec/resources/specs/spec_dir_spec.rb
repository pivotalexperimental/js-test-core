require File.expand_path("#{File.dirname(__FILE__)}/../../../unit_spec_helper")

module JsTestCore
  module Resources
    module Specs
      describe SpecDir do
        attr_reader :dir, :absolute_path, :relative_path
        before do
          @absolute_path = spec_root_path
          @relative_path = "/specs"
          @dir = Resources::Specs::SpecDir.new(absolute_path, relative_path)
        end

        it "has an absolute path" do
          dir.absolute_path.should == absolute_path
        end

        it "has a relative path" do
          dir.relative_path.should == relative_path
        end

        describe "#locate when passed the name with an extension" do
          it "when file exists, returns a Resources::File representing it" do
            file = dir.locate("failing_spec.js")
            file.relative_path.should == "/specs/failing_spec.js"
            file.absolute_path.should == "#{spec_root_path}/failing_spec.js"
          end

          it "when file does not exist, raises error" do
            lambda { dir.locate("nonexistent.js") }.should raise_error
          end
        end

        describe "#locate when passed a name without an extension" do
          it "when name corresponds to a subdirectory, returns a DirectoryRunner for the directory" do
            subdir = dir.locate("foo")
            subdir.should == spec_dir("/foo")
          end

          it "when name does not correspond to a .js file or directory, raises an error" do
            lambda do
              dir.locate("nonexistent")
            end.should raise_error
          end
        end

        describe Dir, "#glob" do
          it "returns an array of matching Files under this directory with the correct relative paths" do
            globbed_files = dir.glob("/**/*_spec.js")

            globbed_files.size.should == 3
            globbed_files.should contain_spec_file_with_correct_paths("/failing_spec.js")
            globbed_files.should contain_spec_file_with_correct_paths("/foo/failing_spec.js")
            globbed_files.should contain_spec_file_with_correct_paths("/foo/passing_spec.js")
          end
        end
      end
    end
  end
end
