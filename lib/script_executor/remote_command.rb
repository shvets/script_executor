require 'script_executor/output_buffer'
require 'net/ssh'
require "highline"

class RemoteCommand
  attr_reader :host, :user, :options, :suppress_output,  :capture_output, :simulate

  def initialize params
    @host = params.delete(:domain)
    @user = params.delete(:user)

    @suppress_output = params.delete(:suppress_output)
    @capture_output = params.delete(:capture_output)
    @simulate = params.delete(:simulate)

    @options = params
  end

  def execute commands, line_action
    options[:password] = HighLine.new.ask("Enter password for #{options[:user]}: ") { |q| q.echo = '*' } if options[:password].nil?
    options[:user] = user

    print commands, $stdout

    unless simulate
      storage = capture_output ? OutputBuffer.new : nil
      output = suppress_output ? nil : $stdout

      Net::SSH.start(host, user, options) do |session|
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
    ssh_command = ssh_command(host, options)

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

  def ssh_command host, options
    cmd = options[:user].nil? ? host : "#{options[:user]}@#{host}"

    cmd << " -i #{options[:identity_file]}" if options[:identity_file]

    cmd << " -p #{options[:port]}" if options[:port]

    #cmd << " -t -t"

    "ssh #{cmd}"
  end

  def ask_password? line
    line =~ /^\[sudo\] password for user:/ || line =~ /sudo password:/ || line =~ /Password:/
  end
end

