# frozen_string_literal: true

require_relative "lib/put_rake/version"

Gem::Specification.new do |spec|
  spec.name = "put_rake"
  spec.version = PutRake::VERSION
  spec.authors = ["Shigeto R. Nishiani"]
  spec.email = ["daddygongon@users.noreply.github.com"]

  spec.summary = "Put a template of Rakefiles on the local dir."
  spec.description = "Put a template of Rakefiles on the local dir."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["source_code_uri"] = "https://github.com/daddygongon/put_rake"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_development_dependency "rspec"
  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "command_line"
  spec.add_runtime_dependency "colorize"
  #spec.add_development_dependency "aruba"
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
