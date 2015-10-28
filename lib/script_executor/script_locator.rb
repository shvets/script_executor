require 'erb'
require 'text_interpolator'

require 'script_executor/scripts_parser'
require 'script_executor/scripts_transform'

module ScriptLocator

  def scripts file
    data = extract_data file

    begin
      scripts_parser = ScriptsParser.new
      parsed_content = scripts_parser.parse data

      transformer = ScriptsTransform.new
      transformer.transform(parsed_content)
    rescue Parslet::ParseFailed => failure
      puts failure.cause.ascii_tree
    end
  end

  def evaluate_script_body content, env, type=:erb
    content = content.join("\n") if content.kind_of? Array

    case type
      when :erb
        template = ERB.new content
        template.result(env).strip
      else
        interpolator = TextInterpolator.new

        result = interpolator.interpolate content, env

        puts interpolator.errors if interpolator.errors.size > 0

        result
    end
  end

  private

  def extract_data file
    content = File.read(file)

    index = content.index("__END__\n")

    index.nil? ? content : content[index+9..-1]
  end

end