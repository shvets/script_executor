require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'executable'

class MyExecutable
  include Executable
end

describe MyExecutable do

  subject { MyExecutable.new }

  before :all do
    @password ||= ask("Enter password for #{ENV['USER']}:  ") { |q| q.echo = '*' }
  end

  describe "local execution" do
    before :all do
      @local_info = {
        :capture_output => true
      }
    end

    it "should execute commands locally from :script parameter" do
      result = subject.execute @local_info.merge(:script => "whoami")

      result.should == ENV['USER']
    end

    it "should execute commands locally from the block of code" do
      result = subject.execute  @local_info do
        %Q(
          whoami
          whoami
      )
      end

      result.to_s.should == "#{ENV['USER']}\n#{ENV['USER']}"
    end

    it "should execute commands locally from the block of code as sudo" do
      result = subject.execute @local_info.merge(:sudo => true, :password => @password) do
        %Q(
          whoami
          whoami
      )
      end

      puts "2 #{@password}"
      result.to_s.should == "root\nroot"
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

    it "should execute commands from :script parameter" do
      result = subject.execute @remote_info.merge(:script => "whoami")

      result.should == ENV['USER']
    end

    it "should execute commands from the block of code" do
      result = subject.execute @remote_info do
        %Q(
          whoami
        )
      end

      result.should == ENV['USER']
    end

    it "should execute sudo command" do
      result = subject.execute @remote_info.merge(:sudo => true, :password => @password, :suppress_output => false) do
        %Q(
           ~/apache-tomcat-7.0.34/bin/shutdown.sh
        )
      end

      p result
    end
  end

end
