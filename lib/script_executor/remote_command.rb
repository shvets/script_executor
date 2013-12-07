require 'script_executor/output_buffer'
require 'net/ssh'
require "highline"

class RemoteCommand
  attr_reader :domain, :user, :password, :identity_file, :suppress_output,  :capture_output, :simulate

  def initialize params
    @domain = params[:domain]
    @user = params[:user]
    @password = params[:password]
    @identity_file = params[:identity_file]
    @suppress_output = params[:suppress_output]
    @capture_output = params[:capture_output]
    @simulate = params[:simulate]
  end

  def execute commands, line_action
    print commands, $stdout

    unless simulate
      storage = capture_output ? OutputBuffer.new : nil
      output = suppress_output ? nil : $stdout

      password = HighLine.new.ask("Enter password for #{user}: ") { |q| q.echo = '*' } if @password.nil?

      Net::SSH.start(domain, user, :password => password) do |session|
        session.exec(commands) do |channel, _, line|
          if ask_password?(line)
            channel.request_pty
            channel.send_data password + "\n"
          else
            output.print(line) if output
            storage.save(line.chomp) if storage

            line_action.call(line) if line_action
          end
        end

        session.loop # run the aggregated event loop
      end

      storage.buffer.join("\n") if storage
    end
  end

  private

  def print commands, output
    ssh_command = ssh_command(domain, user, identity_file)

    if simulate
      output.puts "Remote script: '#{ssh_command}'"
      output.puts "-------"

      lines = StringIO.new commands

      lines.each_line do |line|
        output.puts line
      end

      output.puts "-------"
    else
      output.puts "Remote execution on: '#{ssh_command}'"
      output.puts "-------"

      lines = StringIO.new commands

      lines.each_line do |line|
        output.puts line
      end

      output.puts "-------"
    end
  end

  def ssh_command domain, user, identity_file
    cmd = user.nil? ? domain : "#{user}@#{domain}"

    cmd << " -i #{identity_file}" if identity_file

    #cmd << " -t -t"

    "ssh #{cmd}"
  end

  def ask_password? line
    line =~ /^\[sudo\] password for user:/ || line =~ /sudo password:/ || line =~ /Password:/
  end
end

