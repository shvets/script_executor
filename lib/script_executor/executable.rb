require 'script_executor/local_command'
require 'script_executor/remote_command'

module Executable

  def execute params={}, &code
    params = params.clone # try not to destroy external hash

    if params.class != Hash
      simple_commands = commands_from_object(params)
      params = {}
      script = simple_commands
    else
      script = params.delete(:script)
    end

    commands = locate_commands script, &code

    if commands.nil?
      output.puts "No command was provided!"
    else
      commands = sudo(commands) if params[:sudo]

      params.delete(:sudo)

      remote = params.delete(:remote)
      line_action = params.delete(:line_action)

      if remote
        command = RemoteCommand.new params
      else
        command = LocalCommand.new params
      end

      command.execute commands, line_action
    end
  end

  private

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

  def sudo commands
    "sudo -S -p 'sudo password: ' -s -- '#{commands}'"
  end

end
