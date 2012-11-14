require 'shellwords'
require 'net/ssh'
require "highline/import"

class ScriptExecutor

  def execute params={}, &code
    if params.class != Hash
      simple_commands = commands_from_object(params)
      params = {}
      params[:script] = simple_commands
    end

    remote = params.delete(:remote)

    remote ? remote_execute(params, &code) : local_execute(params, &code)
  end

  def local_execute params={}, &code
    simulate = params.delete(:simulate)
    sudo = params.delete(:sudo)

    commands = locate_commands params[:script], &code

    if commands.nil?
      puts "No commands were provided!"
      return
    end

    commands = sudo(commands) if sudo

    if simulate
      puts "Script:"
      puts "-------"
      print_commands commands
      puts "-------"
    else
      puts "Local execution:"
      puts "-------"
      print_commands(commands)
      puts "-------"
      execute_command commands, params[:capture_output]
    end
  end

  def remote_execute params={}, &code
    simulate = params.delete(:simulate)
    sudo = params.delete(:sudo)

    commands = locate_commands params[:script], &code

    if commands.nil?
      puts "No commands were provided!"
      return
    end

    commands = sudo(commands) if sudo

    ssh_command = ssh_command(params[:domain], params[:user], params[:identity_file])

    if simulate
      puts "Remote script: '#{ssh_command}'"
      puts "-------"
      print_commands commands
      puts "-------"
    else
      puts "Remote execution on: '#{ssh_command}'"
      puts "-------"
      print_commands commands
      puts "-------"

      execute_ssh(params[:domain], params[:user], commands)
    end
  end

  private

  def print_commands commands
    lines = StringIO.new commands

    lines.each_line do |line|
      puts line
    end
  end

  def execute_command commands, capture_output=false
    if capture_output
      buffer = []

      IO.popen(commands).each_line do |line|
        buffer << line.chomp
      end

      buffer.join("\n")
    else
      IO.popen(commands).each_line do |line|
        print line
      end
    end
  end

  def execute_ssh domain, user, commands
    password = ask("Enter password for #{user}:  ") { |q| q.echo = '*' }

    Net::SSH.start(domain, user, :password => password) do |session|
      session.exec "#{commands}" do |channel, _, data|
        if data =~ /^\[sudo\] password for user:/ || data =~ /sudo password:/
          #puts "Password request"
          channel.request_pty # <- problem must be here.
          channel.send_data password + "\n"
        else
          print data
        end
      end

      # run the aggregated event loop
      session.loop
    end
  end

  def locate_commands script, &code
    if block_given?
      commands_from_block &code
    elsif script
      commands_from_object script
    else
      nil
    end
  end

  def commands_from_block &code
    s1 = code.call.split(/\n/)
    s2 = s1.reject {|el| el.strip.size == 0 || el.empty?}
    s3 = s2.collect {|el| el.strip}

    s3.join("\n")
  end

  def commands_from_object object
    if object.class == String
      object
    elsif object.class == Array
      object.join("\n")
    else
      object
    end
  end

  def ssh_command domain, user, identity_file
    cmd = user.nil? ? domain : "#{user}@#{domain}"

    cmd << " -i #{identity_file}" if identity_file

    #cmd << " -t -t"

    "ssh #{cmd}"
  end

  def sudo commands
    "sudo -S -p 'sudo password: ' #{commands}"
  end

end
