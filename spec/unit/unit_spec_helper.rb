require "rubygems"
require "spec"
require "spec/autorun"
require "rack/test"
ARGV.push("-b")

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift File.expand_path("#{dir}/../../lib")
require "js_test_core"
require "nokogiri"
require "guid"

Spec::Runner.configure do |config|
  config.mock_with :rr
end

module Spec
  module Matchers
    class Exist
      def matches?(actual)
        @actual = actual
        !@actual.nil?
      end
    end
  end
end

class JsTestCoreTestDir < JsTestCore::Resources::Dir
  def get

  end
end

class ShowTestExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    app.call(env)
  rescue StandardError, LoadError, SyntaxError => e
    body = [
        e.message,
        e.backtrace.join("\n\t")
      ].join("\n")
    [
      500,
      {"Content-Type" => "text",
       "Content-Length" => body.size.to_s},
      body
    ]
  end
end

Sinatra::Application.use ShowTestExceptions
Sinatra::Application.set :raise_errors, true
Sinatra::Application.register(JsTestCore::Resources::WebRoot.route_handler)
Sinatra::Application.register(JsTestCore::Resources::Runner.route_handler)
Sinatra::Application.register(JsTestCore::Resources::Session.route_handler)
Sinatra::Application.register(JsTestCore::Resources::SessionFinish.route_handler)
Sinatra::Application.register(JsTestCore::Resources::Specs::SpecDir.route_handler)
Sinatra::Application.register(JsTestCore::Resources::Specs::SpecFile.route_handler)
Sinatra::Application.register(JsTestCore::Resources::Dir.route_handler)
Sinatra::Application.register(JsTestCore::Resources::File.route_handler)

class Spec::ExampleGroup
  include Rack::Test::Methods
  class << self
    def thin_logging
      @thin_logging = true if @thin_logging.nil?
      @thin_logging
    end

    attr_writer :thin_logging
  end
  
  attr_reader :core_path, :spec_root_path, :implementation_root_path, :public_path, :server, :connection
  before(:all) do
    dir = File.dirname(__FILE__)
    @core_path = File.expand_path("#{dir}/../example_core")
    JsTestCore.core_path = core_path
    @spec_root_path = File.expand_path("#{dir}/../example_specs")
    @implementation_root_path = File.expand_path("#{dir}/../example_public/javascripts")
    @public_path = File.expand_path("#{dir}/../example_public")
    stub(Thread).start.yields
  end

  before(:each) do
    JsTestCore::Server.instance = JsTestCore::Server.new(spec_root_path, implementation_root_path, public_path)
  end

  after(:each) do
    JsTestCore::Resources::WebRoot.dispatch_strategy = nil
  end

  def app
    Sinatra::Application
  end

  def spec_dir(relative_path="")
    absolute_path = spec_root_path + relative_path
    JsTestCore::Resources::Specs::SpecDir.new(:connection => connection, :absolute_path => absolute_path, :relative_path => "/specs#{relative_path}")
  end

  def be_http(status, headers, body)
    SimpleMatcher.new(nil) do |given, matcher|
      description = (<<-DESC).gsub(/^ +/, "")
      be an http of
      expected status: #{status.inspect}
      actual status  : #{given.status.inspect}

      expected headers containing: #{headers.inspect}
      actual headers             : #{given.headers.inspect}

      expected body containing: #{body.inspect}
      actual body             : #{given.body.inspect}
      DESC
      matcher.failure_message = description
      matcher.negative_failure_message = "not #{description}"

      passed = true
      unless given.status == status
        passed = false
      end
      unless headers.all?{|k, v| given.headers[k] == headers[k]}
        passed = false
      end
      unless body.is_a?(Regexp) ? given.body =~ body : given.body.include?(body)
        passed = false
      end
      passed
    end
  end
end

class FakeSeleniumDriver
  SESSION_ID = "DEADBEEF"
  attr_reader :session_id

  def initialize
    @session_id = nil
  end

  def start
    @session_id = SESSION_ID
  end

  def stop
    @session_id = nil
  end

  def open(url)
  end

  def create_cookie(key_value, options="")

  end

  def session_started?
    !!@session_id
  end
end
