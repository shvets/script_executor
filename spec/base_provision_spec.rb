require 'spec_helper'

require 'thor'
require 'script_executor/base_provision'

class ThorClass < Thor

end

describe BaseProvision do
  subject {
    BaseProvision.new ThorClass, 'spec/support/base.conf.json', ['spec/support/big_script.sh']
  }

  describe "#initialize" do
    it "parses content from file" do
      expect(subject.script_list.size).to equal(10)
    end
  end

  describe "#run" do
    it "parses content from file" do
      name = 'name'
      result = subject.run 'test1', binding, :erb

      ap result
    end
  end
end
