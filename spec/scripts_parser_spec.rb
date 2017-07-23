require 'spec_helper'

require 'script_executor/scripts_parser'
require 'script_executor/scripts_transform'

RSpec.describe ScriptsParser do

  describe '#parse' do
    it 'parses content from file 1' do
      content = File.read('spec/support/script1.sh')

      parsed_content = subject.parse(content)

      #ap parsed_content

      ap transform parsed_content
    end

    it 'parses content from file 2' do
      content = File.read('spec/support/script2.sh')

      parsed_content = subject.parse(content)

      #ap parsed_content

      ap transform parsed_content
    end

    it 'parses content from file 3' do
      content = File.read('spec/support/script3.sh')

      parsed_content = subject.parse(content)

      #ap parsed_content

      ap transform parsed_content
    end

    it 'parses content from file 4' do
      content = File.read('spec/support/script4.sh')

      parsed_content = subject.parse(content)

      #ap parsed_content

      ap transform parsed_content
    end

    it 'parses content from file 5' do
      content = File.read('spec/support/script5.sh')

      parsed_content = subject.parse(content)

      #ap parsed_content

      ap transform parsed_content
    end
#
#     it "test" do
#       content = <<-DATA
# #!/usr/bin/env bash
#
# #######################################
#
# # Some description
# # [name]
#
# # some comment
#
#       aaa
#       bbb
#
#       DATA
#
#       parsed_content = subject.parse(content)
#
#       ap parsed_content
#     end
  end

  def transform(content)
    script_transform = ScriptsTransform.new

    script_transform.transform content
  end
end
