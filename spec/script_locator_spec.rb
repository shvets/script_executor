require 'spec_helper'

require 'script_locator'

RSpec.describe ScriptLocator do

  subject { Object.new.extend ScriptLocator }

  describe '#scripts' do
    it 'reads after __END__' do
      file = __FILE__

      scripts = subject.scripts(file)

      expect(scripts).not_to be_nil
    end

    it 'reads from file completely if it does not have __END__ tag' do
      file = File.expand_path('support/script4.sh', File.dirname(__FILE__))

      scripts = subject.scripts(file)

      expect(scripts).not_to be_nil
    end
  end

  describe '#evaluate_script_body' do
    it 'locates script inside current file' do
      scripts = subject.scripts(__FILE__)

      name = 'alisa'

      result = subject.evaluate_script_body(scripts[:test1][:code], binding)

      expect(result).to match /#{name}/

      expect(scripts[:test1][:comment]).to eq 'Some description'
    end

    it 'locates script inside external file and evaluates it as string' do
      file = File.expand_path('support/script4.sh', File.dirname(__FILE__))

      scripts = subject.scripts(file)

      env = {:name => 'alisa'}

      result = subject.evaluate_script_body(scripts[:test1][:code], env, :string)

      expect(result).to match /#{env[:name]}/
    end
  end

end

__END__

[test1]
# Some description

echo "<%= name %>"

[test2]

echo "test2"