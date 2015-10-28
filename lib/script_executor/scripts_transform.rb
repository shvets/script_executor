require 'parslet'

class ScriptsTransform < Parslet::Transform

  rule(:language => subtree(:language)) do
    language.delete(:ignored)

    new_scripts = {}

    language[:scripts].each do |el|
      script = el[:script]

      name = script[0][:name].to_sym

      has_main_comment = script[1][:comment] != nil

      main_comment = has_main_comment ? script[1][:comment].to_s : ''

      start_index = has_main_comment ? 2 : 1

      code = []

      (start_index..script.size-1).each do |index|
        script_node = script[index]

        comment = script_node[:comment]

        if comment && comment.to_s !~ /^[\s;#]+$/
          code << '# ' + comment.to_s
        end

        code_line = script_node[:code_line]

        if code_line
          code << code_line.to_s
        end
      end

      new_scripts[name] = {comment: main_comment, code: code}
    end

    language[:scripts] = new_scripts

    language
  end

  def transform content
    apply(content)[:scripts]
  end
end