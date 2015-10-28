require 'parslet'

require 'script_executor/scripts_transform'

class ScriptsParser < Parslet::Parser
  root :language

  # language
  rule(:language)   { (shebang.as(:shebang).maybe >> ignored.as(:ignored).maybe >> script.repeat.as(:scripts)).as(:language) }

  rule(:shebang)    { str('#') >> str('!') >> match['\w\d_/\s'].repeat(1) }
  rule(:ignored)    { comment.repeat }

  # rule(:code_line)   { codeChars.repeat(1).as(:code_line) >> (newline.absent? >> any).repeat >> eol }
  # rule(:codeChars)  { match['\w\d $_#"<>{}\'\/\.%=!\-+/\*|:~@'] }

  rule(:script)     { (name >> comment.maybe >> empty_lines >> code).as(:script) }
  rule(:code)       { (match['\w\d $_#"<>{}\'\/\.%=!\-+/\*|:~@'].repeat(1).as(:code_line) >> (newline.absent? >> any).repeat >> eol).repeat.as(:code) }

  rule(:comment)     { (str(';') | str('#')) >> spaces >> (newline.absent? >> any).repeat.as(:comment) >> eol }

  rule(:name)       { spaces >> str('[') >> spaces >> name_chars.as(:name) >> str(']') >> eol }
  rule(:name_chars)  { match['\w\d_'].repeat(1) }

  rule(:empty_lines) { empty_line.repeat }
  rule(:empty_line)  { spaces >> newline }
  rule(:newline)    { str("\n") >> match("\r").maybe }
  rule(:spaces)     { (match("\s") | str(' ')).repeat }
  rule(:eof)        { any.absent? }
  rule(:eol) { (newline.repeat | eof) }

  rule(:terminator) do
    spaces >> (comment | newline | eof)
  end

  def parse content
    begin
      parsed_content = super content

      transformer = ScriptsTransform.new

      transformer.apply(parsed_content)[:scripts]
    rescue Parslet::ParseFailed => failure
      puts failure.cause.ascii_tree
    end
  end
end
