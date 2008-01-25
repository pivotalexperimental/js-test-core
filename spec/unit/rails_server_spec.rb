require File.expand_path("#{File.dirname(__FILE__)}/unit_spec_helper")

module JsSpec
  describe RailsServer do
    it "subclasses Server" do
      RailsServer.superclass.should == Server
    end

    describe ".run" do
      attr_reader :rails_root
      before do
        @rails_root = "/rails/root"
        Server.instance = nil
      end

      it "initializes the RailsServer and runs the Mongrel Handler and sets Server.instance to the RailsServer instance" do
        host = Server::DEFAULT_HOST
        port = Server::DEFAULT_PORT
        server_instance = Object.new
        mock.proxy(RailsServer).new(
          rails_root,
          host,
          port
        ) do |new_instance|
          server_instance
        end
        mock(Rack::Handler::Mongrel).run(server_instance, {:Host => host, :Port => port})

        RailsServer.run(rails_root)
        Server.instance.should == server_instance
      end
    end

    describe "#initialize" do
      it "sets the server paths based on the passed in rails root" do
        rails_root = "/rails/root"
        server = RailsServer.new(rails_root)
        server.spec_root_path.should == "#{rails_root}/spec/javascripts"
        server.implementation_root_path.should == "#{rails_root}/public/javascripts"
        server.public_path.should == "#{rails_root}/public"
      end
    end
  end
end