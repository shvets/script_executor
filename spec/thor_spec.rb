require 'spec_helper'

require 'thor'
require 'script_executor/base_provision'

class ThorSpec < Thor
  class << self
    attr_reader :provision
  end

  @provision = BaseProvision.new 'spec/support/base.conf.json', ['spec/support/script0.sh']

  @provision.create_thor_methods(self)
end

describe ThorSpec do
  describe "#invoke" do
    it "executes thor without parameters" do
      ThorSpec.provision.env[:name] = 'name'

      subject.invoke :test2

      expect(ThorSpec.provision.errors).to be_empty
    end

    it "executes thor with parameters" do
      ThorSpec.provision.env[:name] = 'name'

      subject.invoke :test3, ['a', 'b','c']

      expect(ThorSpec.provision.errors).to be_empty
    end
  end
end
