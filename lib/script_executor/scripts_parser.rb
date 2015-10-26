require 'parslet'

require 'script_executor/scripts_transformer'

class ScriptsParser < Parslet::Parser
  root :language

  # language
  rule(:language)   { (shebang.as(:shebang).maybe >> ignored.as(:ignored).maybe >> scripts.as(:scripts)).as(:language) }

  rule(:shebang)    { str('#') >> str('!') >> match['\w\d_/\s'].repeat(1) }
  rule(:ignored)    { comment.repeat }
  rule(:scripts)    { script.repeat }

  rule(:script)     { emptyLines >> (name >> comment.maybe >> code).as(:script) }
  rule(:comment)    { emptyLines >> spaces >> (str('#') >> spaces >> (newline.absent? >> any).repeat.as(:comment)) >> newline }
  rule(:name)       { spaces >> str('[') >> spaces >> spaces >> nameChars.as(:name) >> spaces >> str(']') >> spaces >> newline }

  rule(:code)  { (emptyLines >> codeLine.repeat.maybe >> emptyLines).as(:code) }
  rule(:codeLine)   { emptyLines >> codeChars.as(:codeLine) >> newline }

  rule(:nameChars)  { match['\w\d_'].repeat(1) }
  rule(:codeChars)  { match['(.*)\w\d $_#"<>{}\'\/\.%=!\-+/\*|:~@'].repeat(1) }

  rule(:emptyLines) { emptyLine.repeat }
  rule(:emptyLine)  { spaces >> newline }
  rule(:newline)    { str("\n") >> str("\r").maybe }

  rule(:spaces)     { str(' ').repeat }

  def parse content
    begin
      parsed_content = super content + "\n"

      transformer = ScriptsTransformer.new

      transformer.apply(parsed_content)[:scripts]
    rescue Parslet::ParseFailed => failure
      puts failure.cause.ascii_tree
    end
  end
end
