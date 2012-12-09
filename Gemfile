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

group :debug do
  if RUBY_VERSION.include? "1.9"
    #gem "ruby-debug-base19x", "0.11.30.pre11"
    #gem "ruby-debug-ide", "0.4.17.beta14"
  end
end

