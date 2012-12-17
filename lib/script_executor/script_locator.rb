require 'erb'

module ScriptLocator

  def scripts file, binding
    data = extract_data file

    locate_scripts(data, binding)
  end

  private

  def extract_data file
    content = File.read(file)

    index = content.index("__END__\n")

    content[index+9..-1]
  end

  def locate_scripts data, binding
    scripts = {}

    stream = StringIO.new data

    current_key = nil

    stream.each_line do |line|
      if line =~ /^(\s)*\[[\w\d\s]*\](\s)*$/
        marker = line.strip.gsub(/\[[\w\d\s]*\]/).first

        if !marker.nil? and marker.strip.length > 0
          key = marker[1..marker.length-2]

          scripts[key] = ""
          current_key = key
        end
      else
        scripts[current_key] += line if current_key
      end
    end

    scripts.each do |key, script|
      scripts[key] = execute_template(script, binding).strip
    end

    scripts
  end

  def execute_template content, binding
    template = ERB.new content

    template.result(binding)
  end

end