require 'parslet'

class ScriptsParser < Parslet::Parser
  root :language

  rule(:language)     { (shebang.maybe >> ignored >> scripts).as(:language) }

  rule(:shebang)      { str('#') >> str('!') >> match['\w\d_/\s'].repeat(1).as(:shebang) }
  rule(:ignored)      { empty_lines >> (name.absent? >> comment).repeat(0).as(:ignored) >> empty_lines }

  rule(:comment)      { comment_char >> spaces >> (newline.absent? >> any).repeat(0).as(:comment) >> eol }
  rule(:comment_char) { str(';') | str('#') }

  rule(:scripts)      { script.repeat(0).as(:scripts) }
  rule(:script)       { (name >> empty_lines >> (name.absent? >> (comment | code_line)).repeat(0)).as(:script) }

  rule(:name)         { name_v1 |name_v2 }
  rule(:name_v1)      { spaces >> str('[') >> spaces >> name_chars.as(:name) >> str(']') >> spaces >> eol }
  rule(:name_v2)      { spaces >> comment_char >> spaces >> str('[') >> spaces >> name_chars.as(:name) >> str(']') >> spaces >> eol }
  rule(:name_chars)   { match['\w\d_'].repeat(1) }

  rule(:code_line)    { (newline.absent? >> code_chars).repeat(1).as(:code_line) >> eol }
  rule(:code_chars)   { any }

  rule(:empty_lines)  { empty_line.repeat(0) }
  rule(:empty_line)   { spaces >> newline }
  rule(:newline)      { str("\n") >> match("\r").maybe }
  rule(:spaces)       { match["\s\t "].repeat(0) }
  rule(:eol)          { (newline.repeat(0) | eof) }
  rule(:eof)          { any.absent? }
end
