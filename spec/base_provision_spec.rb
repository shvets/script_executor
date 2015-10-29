require 'spec_helper'

require 'thor'
require 'script_executor/base_provision'

class ThorClass < Thor; end

describe BaseProvision do
  subject { BaseProvision.new 'spec/support/base.conf.json', ['spec/support/script1.sh'] }

  describe "#initialize" do
    it "parses content from file" do
      expect(subject.script_list.size).to equal(9)
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
