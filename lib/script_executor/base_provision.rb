require 'json'
require "highline"

require 'text_interpolator'
require 'script_executor/executable'
require 'script_executor/script_locator'

class BaseProvision
  include Executable, ScriptLocator

  attr_reader :interpolator, :env, :script_list, :server_info

  def initialize parent_class, config_file_name, scripts_file_names
    @interpolator = TextInterpolator.new

    @env = read_config(config_file_name)

    @script_list = {}

    scripts_file_names.each do |name|
      @script_list.merge!(scripts(name))
    end

    create_script_methods

    create_thor_methods(parent_class) if parent_class.ancestors.collect(&:to_s).include?('Thor')

    @server_info = env[:node] ? env[:node] : {}
  end

  protected

  def create_script_methods
    script_list.keys.each do |name|
      singleton_class.send(:define_method, name.to_sym) do
        self.send :run, server_info, name.to_s, env
      end
    end
  end

  def create_thor_methods parent_class
    provision = self

    provision.script_list.each do |name, value|
      title = provision.script_title(value)

      title = title.nil? ? name : title

      parent_class.send(:desc, name, title) if parent_class.respond_to?(:desc)

      parent_class.send(:define_method, name.to_sym) do
        provision.send "#{name}".to_sym
      end
    end
  end

  def read_config config_file_name
    hash = JSON.parse(File.read(config_file_name), :symbolize_names => true)

    interpolator.interpolate hash
  end

  def terminal
    @terminal ||= HighLine.new
  end

  def ask_password message
    terminal.ask(message) { |q| q.echo = "*" }
  end

  def run server_info, script_name, params
    execute(server_info) { evaluate_script_body(script_list[script_name], params, :string) }
  end

  def run_command server_info, command
    execute(server_info.merge({script: command}))
  end

end
