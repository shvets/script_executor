require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'script_executor'

describe ScriptExecutor do
  server_info = {
    :simulate => false,
    :domain => "localhost",
    :user => "user",
    :remote => true
  }

  subject { ScriptExecutor.new }

  it "should execute commands from :script parameter" do
    subject.execute server_info.merge(:script => "ls -al")

    #result.should include "file_utils/version.rb"
  end

  it "should execute commands from the block of code" do
    subject.execute server_info do
      %Q(
        ls -al
      )
    end
  end

  it "should execute commands locally from :script parameter" do
    subject.execute :script => "ls -al", :simulate => false
  end

  it "should execute commands locally from the block of code" do
    subject.execute do
      %Q(
        ls -al
        ls
      )
    end
  end

  it "should execute commands locally from the block of code as sudo" do
    subject.execute :sudo => true do
      %Q(
        cp /Users/oshvets/work/dev_contrib/installs/oracle-client/instantclient-basic-10.2.0.4.0-macosx-x86.zip /usr/local/oracle
        cp /Users/oshvets/work/dev_contrib/installs/oracle-client/instantclient-sdk-10.2.0.4.0-macosx-x86.zip /usr/local/oracle
      )
    end
  end

  it "should execute sudo command locally" do
    subject.execute :sudo => true, :simulate => false, :remote => false do
      %Q(
         ~/apache-tomcat-7.0.27/bin/shutdown.sh
      )
    end
  end

  it "should execute sudo command on remote side" do
    subject.execute server_info.merge(:sudo => true, :simulate => false, :remote => true) do
      %Q(
         /etc/init.d/tomcat5 restart
      )
    end
  end
end
