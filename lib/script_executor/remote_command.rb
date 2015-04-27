require 'script_executor/output_buffer'
require 'net/ssh'
require "highline"

class RemoteCommand
  attr_reader :host, :user, :options, :suppress_output,  :capture_output, :output_stream, :simulate

  def initialize params
    params = sanitize_parameters params

    @host = params.delete(:domain)
    @host = params.delete(:host) if host.nil? and params[:host]
    @user = params.delete(:user)

    @suppress_output = params.delete(:suppress_output)
    @capture_output = params.delete(:capture_output)
    @output_stream = params[:output_stream]
    @simulate = params.delete(:simulate)

    @options = params
  end

  def execute commands, line_action
    options[:password] = HighLine.new.ask("Enter password for #{options[:user]}: ") { |q| q.echo = '*' } if options[:password].nil?
    options[:user] = user

    print commands, $stdout

    unless simulate
      storage = capture_output ? OutputBuffer.new : nil
      output = if output_stream
          output_stream
        else
          suppress_output ? nil : $stdout
        end

      Net::SSH.start(host, user, options) do |session|
        session.exec(commands) do |channel, _, line|
          if ask_password?(line)
            channel.request_pty
            channel.send_data options[:password] + "\n"
          else
            if output
              output.write(line)
              output.flush
            end

            if storage
              storage.save(line.chomp)
            end

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

  def sanitize_parameters params
    params.each do |key, _|
      params.delete(key) unless permitted_params.include? key.to_sym
    end

    params
  end

  def permitted_params
    @permitted_params ||= [:script, :sudo, :remote, :line_action, :password,
                           :suppress_output, :capture_output, :output_stream, :simulate,
                           :domain, :host, :port, :user, :options]
  end
end

