require 'net/ssh'
require "highline/import"

require 'script_executor/output_buffer'

module Executable

  def execute params={}, &code
    if params.class != Hash
      simple_commands = commands_from_object(params)
      params = {}
      script = simple_commands
    else
      script = params[:script]
    end

    commands = locate_commands script, &code

    if commands.nil?
      puts "No commands were provided!"
      return
    end

    commands = sudo(commands) if params[:sudo]

    remote         = params[:remote]
    domain         = params[:domain]
    user           = params[:user]
    password       = params[:password]
    capture_output = params[:capture_output]
    simulate       = params[:simulate]
    line_action    = params[:line_action]

    print_execution commands, remote, domain, user, nil, simulate

    unless simulate
      line_action = lambda { |line| print line } unless line_action
      storage = capture_output ? OutputBuffer.new : nil

      if remote
        execute_ssh commands, domain, user, password, line_action, storage
      else
        execute_command commands, password, line_action, storage
      end

      storage.buffer.join("\n") if storage
    end
  end

  private

  def print_execution commands, remote, domain, user, identity_file, simulate
    if remote
      ssh_command = ssh_command(domain, user, identity_file)

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
      end
    else
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
      end
    end
  end

  def print_commands commands
    lines = StringIO.new commands

    lines.each_line do |line|
      puts line
    end
  end

  def execute_command commands, password, line_action, storage
    commands = commands + inline_password(password) if password

    IO.popen(commands) do |pipe|
      pipe.each("\r") do |line|
        storage.save(line.chomp) if storage

        line_action.call(line)
      end
    end
  end

  def inline_password password
    password ? "<<EOF\n#{password}\nEOF" : ""
  end

  def execute_ssh commands, domain, user, password, line_action, storage
    if password.nil?
      password = ask("Enter password for #{user}: ") { |q| q.echo = '*' }
    end

    Net::SSH.start(domain, user, :password => password) do |session|
      session.exec "#{commands}" do |channel, _, line|
        if line =~ /^\[sudo\] password for user:/ || line =~ /sudo password:/
          #puts "Password request"
          channel.request_pty # <- problem must be here.
          channel.send_data password + "\n"
        else
          storage.save(line.chomp) if storage

          line_action.call(line)
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
    "sudo -S -p 'sudo password: ' -s -- '#{commands}'"
  end

end
