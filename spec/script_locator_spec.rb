require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'script_locator'

class MyScriptLocator
  include ScriptLocator
end

describe MyScriptLocator do

  subject { MyScriptLocator.new }

  it "should read after __END__" do
    result = subject.scripts(__FILE__, binding)

    result.should_not be_nil
  end

  it "should locate script" do
    result = subject.scripts(__FILE__, binding)

    result['test1'].should_not be_nil
  end

end

__END__

[test1]

echo "test1"

[test2]

echo "test2"
