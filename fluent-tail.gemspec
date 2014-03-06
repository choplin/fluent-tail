# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluent/tail/version'

Gem::Specification.new do |spec|
  spec.name          = "fluent-tail"
  spec.version       = Fluent::Tail::VERSION
  spec.authors       = ["OKUNO Akihiro"]
  spec.email         = ["okuno.akihiro@gmail.com"]
  spec.summary       = %q{Tools for tailing fluentd stream events}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/choplin/fluent-tail"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
