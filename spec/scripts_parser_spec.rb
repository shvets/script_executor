require 'spec_helper'

require 'script_executor/scripts_parser'
require 'script_executor/scripts_transformer'

describe ScriptsParser do
  describe "#parse" do
    it "parses content from file" do
      content = File.read('spec/support/big_script.sh')
      #content = File.read('spec/support/test.conf')

      parsed_content = subject.parse(content)

      ap parsed_content
    end
  end
end
