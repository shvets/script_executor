require 'spec_helper'

require 'thor'
require 'script_executor/base_provision'

class ThorClass < Thor

end

describe BaseProvision do
  describe "#parse" do
    it "parses content from file" do
      provision = BaseProvision.new ThorClass, 'spec/support/base.conf.json', ['spec/support/big_script.sh']

      ap provision.script_list
    end
  end
end
