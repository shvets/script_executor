require 'spec_helper'
require 'rspec/mocks'

require 'executable'

describe Executable do
  subject { Object.new.extend Executable }

  before :all do
    @password ||= HighLine.new.ask("Enter password for #{ENV['USER']}:  ") { |q| q.echo = '*' }
  end

  describe "local execution" do
    before :all do
      @local_info = {
        :capture_output => true
      }
    end

    it "executes commands from :script parameter" do
      result = subject.execute @local_info.merge(:script => "whoami")

      expect(result).to eq ENV['USER']
    end

    it "executes commands from the block of code" do
      result = subject.execute  @local_info do
        %Q(
          whoami
          whoami
      )
      end

      expect(result).to eq "#{ENV['USER']}\n#{ENV['USER']}"
    end

    it "executes commands from the block of code as sudo" do
      result = subject.execute @local_info.merge(:sudo => true, :password => @password) do
        %Q(
          whoami
          whoami
      )
      end

      expect(result).to eq "root\nroot"
    end
  end

  describe "remote execution" do
    before :all do
      @remote_info = {
          :simulate => false,
          :domain => "localhost",
          :user => ENV['USER'],
          :password => @password,
          :remote => true,
          :capture_output => true
      }
    end

    it "executes commands from :script parameter" do
      result = subject.execute @remote_info.merge(:script => "whoami")

      expect(result).to eq ENV['USER']
    end

    it "executes commands from the block of code" do
      result = subject.execute @remote_info do
        %Q(
          whoami
        )
      end

      expect(result).to eq ENV['USER']
    end

    it "executes commands with :host parameter instead of :domain parameter" do
      result = subject.execute @remote_info.merge(:script => "whoami", :host => 'localhost', :domain => nil)

      expect(result).to eq ENV['USER']
    end

    it "executes commands with :host parameter instead of :domain parameter" do
      result = subject.execute @remote_info.merge(:script => "whoami", :home => 'some_home')

      expect(result).to eq ENV['USER']
    end

    #it "should execute sudo command" do
    #  result = subject.execute @remote_info.merge(:sudo => true, :password => @password, :suppress_output => false) do
    #    %Q(
    #       ~/apache-tomcat-7.0.34/bin/shutdown.sh
    #    )
    #  end
    #
    #  p result
    #end
  end

  describe "vagrant" do
    before :all do
      @remote_info = {
          :domain => "22.22.22.22",
          :user => "vagrant",
          :password => "vagrant",
          :port => 2222,
          :remote => true,
          :capture_output => true
      }
    end

    it "should execute commands from :script parameter" do
      expect_any_instance_of(RemoteCommand).to receive(:execute).and_return 'vagrant'

      result = subject.execute @remote_info.merge(:script => "whoami")

      expect(result).to eq "vagrant"
    end
  end

end
