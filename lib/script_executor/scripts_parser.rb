require 'parslet'

class ScriptsParser < Parslet::Parser
  root :language

  rule(:language)    { (shebang.as(:shebang).maybe >> empty_lines >> comment.repeat(0).as(:ignored) >> empty_lines >> scripts).as(:language) }

  rule(:shebang)     { str('#') >> str('!') >> match['\w\d_/\s'].repeat(1) }

  rule(:comment)     { (str(';') | str('#')) >> spaces >> (newline.absent? >> any).repeat(0).as(:comment) >> eol }

  rule(:scripts)     { script.repeat(0).as(:scripts) }

  rule(:name)        { spaces >> str('[') >> spaces >> name_chars.as(:name) >> str(']') >> eol }
  rule(:name_chars)  { match['\w\d_'].repeat(1) }

  rule(:script)      { (name >> empty_lines >> (name.absent? >> (comment | code_line)).repeat(0)).as(:script) }
  rule(:code_line)   { (newline.absent? >> code_chars).repeat(1).as(:code_line) >> eol }
  rule(:code_chars)  { any }

  rule(:empty_lines) { empty_line.repeat(0) }
  rule(:empty_line)  { spaces >> newline }
  rule(:newline)     { str("\n") >> match("\r").maybe }
  rule(:spaces)      { match["\s\t "].repeat(0) }
  rule(:eol)         { (newline.repeat(0) | eof) }
  rule(:eof)         { any.absent? }
end
