
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mrubyc/test/version"

Gem::Specification.new do |spec|
  spec.name          = "mrubyc-test"
  spec.version       = Mrubyc::Test::VERSION
  spec.authors       = ["HASUMI Hitoshi"]
  spec.email         = ["hasumikin@gmail.com"]

  spec.summary       = %q{Test Framework for mruby/c}
  spec.description   = %q{mrubyc-test is an unit test framework for mruby/c, supporting basic assertions, stub and mock.}
  spec.homepage      = "https://github.com/mrubyc/mrubyc-test"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "thor", "~> 0.20"
  spec.add_dependency "activesupport", "~> 5.2"
  spec.add_dependency "rufo", "~> 0.4"
end
