require 'spec_helper'

require 'script_executor/scripts_parser'
require 'script_executor/scripts_transform'

describe ScriptsParser do
  describe "#parse" do
    it "parses content from file 1" do
      content = File.read('spec/support/script1.sh')

      parsed_content = subject.parse(content)

      ap parsed_content
    end

    it "parses content from file 2" do
      content = File.read('spec/support/script2.sh')

      parsed_content = subject.parse(content)

      ap parsed_content
    end

    it "parses content from file 3" do
      content = File.read('spec/support/script3.sh')

      parsed_content = subject.parse(content)

      ap parsed_content
    end

    it "parses content from file 4" do
      content = File.read('spec/support/script4.sh')

      parsed_content = subject.parse(content)

      ap parsed_content
    end

    it "parses content from file 5" do
      content = File.read('spec/support/script5.sh')

      parsed_content = subject.parse(content)

      ap parsed_content
    end
  end
end
