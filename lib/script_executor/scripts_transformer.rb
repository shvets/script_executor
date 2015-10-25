require 'parslet'

class ScriptsTransformer < Parslet::Transform
  rule(:language => subtree(:language)) do
    language.delete(:ignored)

    new_scripts = {}

    language[:scripts].each do |script|
      name = script[:script][:name].to_sym
      comment = script[:script][:comment].to_s
      code_lines = script[:script][:codeLines]

      code_lines.each_with_index do |codeLine, index|
        code_lines[index] = codeLine[:codeLine].to_s
      end

      new_scripts[name] = {comment: comment, codeLines: code_lines}
    end

    language[:scripts] = new_scripts

    language
  end
end