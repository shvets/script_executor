require 'spec_helper'

require 'script_executor/base_provision'

RSpec.describe BaseProvision do
  subject { BaseProvision.new 'spec/support/base.conf.json', ['spec/support/script0.sh'] }

  describe '#initialize' do
    it 'parses content from file' do
      expect(subject.script_list.size).to equal(3)
    end
  end

  describe '#run' do
    it 'executes command with :erb type' do
      params = OpenStruct.new({name: 'some name', 'project': {'home': 'root'}})

      b = params.instance_eval { binding }

      result = subject.run 'test1', :erb, b

      ap result
    end

    it 'executes command with :string type' do
      params = {name: 'other name'}

      result = subject.run 'test2', :string, subject.env.merge(params)

      ap result
    end
  end
end
