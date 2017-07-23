# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/lib/script_executor/version')

Gem::Specification.new do |spec|
  spec.name          = "script_executor"
  spec.summary       = %q{This library helps to execute code, locally or remote over ssh}
  spec.description   = %q{This library helps to execute code, locally or remote over ssh.}
  spec.email         = "alexander.shvets@gmail.com"
  spec.authors       = ["Alexander Shvets"]
  spec.homepage      = "http://github.com/shvets/script_executor"

  spec.files         = `git ls-files`.split($\)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.version       = ScriptExecutor::VERSION
  spec.license       = "MIT"

  
  spec.add_runtime_dependency "highline", ["= 1.7.8"]
  spec.add_runtime_dependency "net-ssh", ["= 4.1.0"]
  spec.add_runtime_dependency "text-interpolator", ["= 1.1.9"]
  spec.add_runtime_dependency "json_pure", ["= 2.1.0"]
  spec.add_runtime_dependency "parslet", ["= 1.8.0"]
  spec.add_runtime_dependency "thor", ["= 0.19.4"]
  spec.add_runtime_dependency "rspec", ["= 3.6.0"]
  spec.add_development_dependency "gemspec_deps_gen", ["= 1.1.2"]
  spec.add_development_dependency "gemcutter", ["= 0.7.1"]
  spec.add_development_dependency "awesome_print", ["= 1.8.0"]

end

