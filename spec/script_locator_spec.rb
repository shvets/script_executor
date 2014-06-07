require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'script_locator'

class MyScriptLocator
  include ScriptLocator
end

describe MyScriptLocator do

  subject { MyScriptLocator.new }

  describe "#scripts" do
    it "reads after __END__" do
      file = __FILE__

      scripts = subject.scripts(file)

      expect(scripts).not_to be_nil
    end

    it "reads from file completely if it does not have __END__ tag" do
      file = File.expand_path('test.conf', File.dirname(__FILE__))

      scripts = subject.scripts(file)

      expect(scripts).not_to be_nil
    end
  end

  describe "#evaluate_script_body" do
    it "locates script inside current file" do
      scripts = subject.scripts(__FILE__)

      name = "alisa"

      result = subject.evaluate_script_body(scripts['test1'], binding)

      expect(result).to match /#{name}/
      expect(subject.script_title(scripts['test1'])).to eq "Some description"
    end

    it "locates script inside external file and evaluates it as string" do
      file = File.expand_path('test.conf', File.dirname(__FILE__))

      scripts = subject.scripts(file)

      env = {:name => "alisa"}

      result = subject.evaluate_script_body(scripts['test1'], env, :string)

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
