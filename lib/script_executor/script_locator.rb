require 'erb'

module ScriptLocator

  def scripts file
    data = extract_data file

    locate_scripts(data)
  end

  def evaluate_script_body content, binding
    template = ERB.new content

    template.result(binding).strip
  end

  private

  def extract_data file
    content = File.read(file)

    index = content.index("__END__\n")

    content[index+9..-1]
  end

  def locate_scripts data
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

    scripts
  end

end