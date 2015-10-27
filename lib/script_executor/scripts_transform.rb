require 'parslet'

class ScriptsTransform < Parslet::Transform

  rule(:language => subtree(:language)) do
    language.delete(:ignored)

    new_scripts = {}

    language[:scripts].each do |script|
      name = script[:script][:name].to_sym
      comment = script[:script][:comment].to_s
      code = script[:script][:code]

      code.each_with_index do |code_line, index|
        code[index] = code_line[:code_line].to_s
      end

      new_scripts[name] = {comment: comment, code: code}
    end

    language[:scripts] = new_scripts

    language
  end
end