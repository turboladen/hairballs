# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hairballs/version'

Gem::Specification.new do |spec|
  spec.name          = 'hairballs'
  spec.version       = Hairballs::VERSION
  spec.authors       = ['Steve Loveless']
  spec.email         = ['steve.loveless@gmail.com']
  spec.summary       = 'Like oh-my-zsh, but for IRB.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/turboladen/hairballs'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.1'
end
