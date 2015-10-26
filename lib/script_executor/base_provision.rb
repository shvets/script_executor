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

    @terminal ||= HighLine.new
  end

  def run script_name, params={}, type=:string
      execute(server_info) do
      evaluate_script_body(script_list[script_name.to_sym][:codeLines].join("\n"), params, type)
    end
  end

  def ask_password message
    @terminal.ask(message) { |q| q.echo = "*" }
  end

  def read_config config_file_name
    hash = JSON.parse(File.read(config_file_name), :symbolize_names => true)

    result = interpolator.interpolate hash

    puts interpolator.errors if interpolator.errors.size > 0

    result
  end

  def create_script_methods
    script_list.keys.each do |name|
      singleton_class.send(:define_method, name.to_sym) do
        self.run name.to_s, env
      end
    end
  end

  def create_thor_methods parent_class
    provision = self

    provision.script_list.each do |name, value|
      title = value[:comment]

      title = title.nil? ? name : title

      parent_class.send(:desc, name, title) if parent_class.respond_to?(:desc)

      parent_class.send(:define_method, name.to_sym) do
        provision.send "#{name}".to_sym
      end
    end
  end

end
