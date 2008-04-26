module JsTestCore
  module Resources
    class WebRoot
      LOCATIONS = [
        ['core', lambda do
          Resources::Dir.new(JsTestCore::Server.core_path, "/core")
        end],
        ['implementations', lambda do
          Resources::Dir.new(JsTestCore::Server.implementation_root_path, "/implementations")
        end],
        ['suites', lambda do
          Resources::Suite
        end],
        ['runners', lambda do
          Resources::Runners.new
        end]
      ]

      class << self
        def dispatch_specs
          LOCATIONS.unshift(['specs', lambda do
            JsTestCore::Resources::Specs::SpecDir.new(JsTestCore::Server.spec_root_path, "/specs")
          end])
        end
      end

      attr_reader :public_path
      def initialize(public_path)
        @public_path = ::File.expand_path(public_path)
      end

      def locate(name)
        location, initializer = LOCATIONS.find do |location|
          location.first == name
        end
        if initializer
          initializer.call
        else
          potential_file_in_public_path = "#{public_path}/#{name}"
          if ::File.directory?(potential_file_in_public_path)
            Resources::Dir.new(potential_file_in_public_path, "/#{name}")
          elsif ::File.exists?(potential_file_in_public_path)
            Resources::File.new(potential_file_in_public_path, "/#{name}")
          else
            raise "Invalid path: #{name}"
          end
        end
      end
    end
  end
end