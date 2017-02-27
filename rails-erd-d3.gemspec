# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "rails-erd-d3"
  spec.authors       = ["Roman Krasavtsev"]
  spec.email         = ["mr.krasavtsev@gmail.com"]
  spec.version       = "0.9.3"
  spec.summary       = "Entity–relationship diagram with D3.js for Rails application"
  spec.description   = "This gem creates entity–relationship diagram with D3.js for your Rails application"
  spec.homepage      = "https://github.com/RomanKrasavtsev/rails-erd-d3"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
