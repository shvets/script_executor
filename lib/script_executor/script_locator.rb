require 'erb'
require 'text_interpolator'

module ScriptLocator

  def scripts file
    data = extract_data file

    locate_scripts(data)
  end

  def evaluate_script_body content, env, type=:erb
    case type
      when :erb
        template = ERB.new content
        template.result(env).strip

      when :string
        interpolator = TextInterpolator.new

        result = interpolator.interpolate content, env

        puts interpolator.errors if interpolator.errors.size > 0

        result
      else
        interpolator = TextInterpolator.new

        result = interpolator.interpolate content, env

        puts interpolator.errors if interpolator.errors.size > 0

        result
    end
  end

  def script_title script
    if script[0] == '#'
      StringIO.new(script[1..-1]).readline.strip
    else
      nil
    end
  end

  private

  def extract_data file
    content = File.read(file)

    index = content.index("__END__\n")

    index.nil? ? content : content[index+9..-1]
  end

  def locate_scripts data
    scripts = {}

    current_key = nil

    stream = StringIO.new data

    stream.each_line do |line|
      if line =~ /^(\s)*\[[\w\d\s\-\_]*\](\s)*$/
        marker = line.strip.gsub(/\[[\w\d\s\-\_]*\]/).first

        if !marker.nil? and marker.strip.length > 0
          key = marker[1..marker.length-2]

          scripts[key] = ""
          current_key = key
        end
      else
        scripts[current_key] += line if current_key
      end
    end

    scripts
  end

end