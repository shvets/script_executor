require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'script_locator'

class MyScriptLocator
  include ScriptLocator
end

describe MyScriptLocator do

  subject { MyScriptLocator.new }

  it "should read after __END__" do
    scripts = subject.scripts(__FILE__)

    scripts.should_not be_nil
  end

  it "should locate script" do
    scripts = subject.scripts(__FILE__)

    name = "alisa"
    result = subject.evaluate_script_body(scripts['test1'], binding)

    result.should =~ /#{name}/
  end

end

__END__

[test1]

echo "<%= name %>"

[test2]

echo "test2"
