# ScriptExecutor - This library helps to execute code, locally or remote over ssh

## Installation

Add this line to your application's Gemfile:

    gem 'script_executor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install script_executor

## Usage

```ruby
executor = ScriptExecutor.new

executor.execute "ls" # execute locally

executor.execute :remote => true, :script => "ls -al", :domain => "localhost", :user => "user" # execute remote

executor.remote_execute :script => "ls -al", :domain => "localhost", :user => "user" # execute remote

executor.remote_execute :sudo => true, :script => "/etc/init.d/tomcat stop", :domain => "somehost", :user => "user" # execute remote

server_info = {
  :domain => "some.host",
  :user => "some.user",
}

executor.remote_execute :sudo => true, server_info do # execute remote with sudo
  %Q(
    /etc/init.d/tomcat stop
    /etc/init.d/tomcat start
  )
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request