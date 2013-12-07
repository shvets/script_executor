# ScriptExecutor - This library helps to execute code, locally or remote over ssh

## Installation

Add this line to your application's Gemfile:

```bash
gem 'script_executor'
```
And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install script_executor
```

## Usage

```ruby
# Create executor
executor = ScriptExecutor.new
```

* Execute local command:

```ruby
executor.execute "ls"
```

* Execute remote command:

```ruby
server_info = {
  :remote => true,
  :domain => "some.host",
  :user => "some.user",
}

executor.execute server_info.merge(:script => "ls -al")
```

* Execute remote command as 'sudo':

```ruby
executor.execute server_info.merge({:sudo => true, :script => "/etc/init.d/tomcat stop"})
```

* Execute remote command with code block:

```ruby
executor.execute server_info.merge(:sudo => true) do
  %Q(
    /etc/init.d/tomcat stop
    /etc/init.d/tomcat start
  )
end
```

* Execute remote command while capturing and suppressing output (default is 'false'):

```ruby
server_info.merge(:capture_output => true, :suppress_output => true)

result = executor.execute server_info.merge(:script => "whoami")

puts result # ENV['USER']
```

* Simulate remote execution:

```ruby
server_info.merge(:simulate => true)

executor.execute server_info.merge(:script => "whoami") # generate commands without actual execution
```

## Using ScriptLocator

You can keep scripts that needs to be executed embedded into your code (as in examples above),
move them into separate file or keep them in same file behind "__END__" Ruby directive.
The latter gives you the ability to keep command and code together thus simplifying
access to code.

For example, if you want to create script with 2 commands (command1, command2), you can use
"scripts" and "evaluate_script_body" methods:

```ruby
require 'script_locator'

include ScriptLocator

puts scripts(__FILE__) # [command1, command2]

name = "john"

result = evaluate_script_body(result['command1'], binding)

puts result # john
__END__

[command1]

echo "<%= name %>"

[command2]

echo "test2"
```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request