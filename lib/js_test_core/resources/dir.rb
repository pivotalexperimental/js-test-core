module JsTestCore
  module Resources
    class Dir < File
      get "*" do
        process_path
        pass unless ::File.directory?(absolute_path)

        Representations::Dir.new(:relative_path => relative_path, :absolute_path => absolute_path).to_s
      end

      def glob(pattern)
        expanded_pattern = absolute_path + pattern
        ::Dir.glob(expanded_pattern).map do |absolute_globbed_path|
          relative_globbed_path = absolute_globbed_path.gsub(absolute_path, relative_path)
          File.new(env.merge(
            :absolute_path => absolute_globbed_path,
            :relative_path => relative_globbed_path
          ))
        end
      end
    end
  end
end