source :rubygems

group :default do
  gem "highline"
  gem "net-ssh"
end

group :development do
  gem "gemspec_deps_gen"
  gem "gemcutter"
end

group :test do
  gem "rspec"
  gem "mocha"
end

#group :debug do
#  if RUBY_VERSION.include? "1.9"
#    unless File.exist? "#{ENV['GEM_HOME']}/gems/linecache19-0.5.13/lib/linecache19.rb"
#      `curl -OL http://rubyforge.org/frs/download.php/75414/linecache19-0.5.13.gem`
#      `gem i linecache19-0.5.13.gem`
#    end
#
#    gem "linecache19", "0.5.13"
#    gem "ruby-debug-base19x", "0.11.30.pre10"
#    gem "ruby-debug-ide", "0.4.17.beta14"
#  end
#end

