#require "open3"
#@stdout, @stderr, @status = Open3.capture3(stdin)

class LocalCommand
  attr_accessor :simulate

  attr_reader :password, :suppress_output, :capture_output, :simulate

  def initialize params
    params = sanitize_parameters params

    @password = params[:password]
    @suppress_output = params[:suppress_output]
    @capture_output = params[:capture_output]
    @simulate = params[:simulate]
  end

  def execute commands, line_action
    print_commands commands, $stdout

    unless simulate
      storage = capture_output ? OutputBuffer.new : nil
      output = suppress_output ? nil : $stdout

      commands = commands + inline_password(password) if password

      IO.popen(commands) do |pipe|
        pipe.each("\r") do |line|
          output.print(line) if output
          storage.save(line.chomp) if storage

          line_action.call(line) if line_action
        end
      end

      storage.buffer.join("\n") if storage
    end
  end

  private

  def print_commands commands, output
    if simulate
      output.puts "Script:"
      output.puts "-------"

      lines = StringIO.new commands

      lines.each_line do |line|
        output.puts line
      end

      output.puts "-------"
    else
      output.puts "Local execution:"
      output.puts "-------"

      lines = StringIO.new commands

      lines.each_line do |line|
        output.puts line
      end

      output.puts "-------"
    end
  end

  def inline_password password
    password ? "<<EOF\n#{password}\nEOF" : ""
  end

  def sanitize_parameters params
    params.each do |key, _|
      params.delete(key) unless permitted_params.include? key.to_sym
    end
  end

  def permitted_params
    @permitted_params ||= [:script, :sudo, :remote, :line_action, :password,
                           :suppress_output, :capture_output, :simulate]
  end
end

#require 'shellwords'
#
#def bash(command)
#  escaped_command = Shellwords.escape(command)
#  system "bash -c #{escaped_command}"
#end


