require 'parslet'

require 'script_executor/scripts_transform'

class ScriptsParser < Parslet::Parser
  root :language

  # language
  rule(:language)   { (shebang.as(:shebang).maybe >> ignored.as(:ignored).maybe >> scripts.as(:scripts)).as(:language) }

  rule(:shebang)    { str('#') >> str('!') >> match['\w\d_/\s'].repeat(1) }
  rule(:ignored)    { comment.repeat }
  rule(:scripts)    { script_or_comment.repeat }
  rule(:script_or_comment) { script | comment }

  rule(:script)     { empty_lines >> (name >> comment.maybe >> empty_lines >> code).as(:script) }
  rule(:code)       { code_line.repeat.as(:code) }
  rule(:code_line)   { codeChars.repeat(1).as(:code_line) >> (newline.absent? >> any).repeat >> eol }
  rule(:codeChars)  { match['\w\d $_#"<>{}\'\/\.%=!\-+/\*|:~@'] }

  # rule(:unquoted_string) do
  #   ((((backslash | terminator).absent?) >> any).repeat(1).as(:left) >>
  #       backslash >> terminator).repeat(0) >>
  #       (terminator.absent? >> any).repeat(1).as(:right) >>
  #       terminator
  # end

  rule(:comment)     { comment_start >> spaces >> (comment_end.absent? >> any).repeat.as(:comment) >> spaces >> comment_end }
  rule(:comment_start) { (str(';') | str('#')) }
  rule(:comment_end) { eol }

  rule(:name)       { spaces >> name_start >> spaces >> spaces >> name_chars.as(:name) >> name_end }
  rule(:name_start) { str('[') }
  rule(:name_end)   { str(']') >> eol }
  rule(:name_chars)  { match['\w\d_'].repeat(1) }

  rule(:empty_lines) { empty_line.repeat }
  rule(:empty_line)  { spaces >> newline }
  rule(:newline)    { str("\n") >> match("\r").maybe }
  rule(:spaces)     { (match("\s") | str(' ')).repeat(0) }
  rule(:eof)        { any.absent? }
  rule(:eol) { (newline.repeat(0) | eof) }

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
