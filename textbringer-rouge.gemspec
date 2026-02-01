# frozen_string_literal: true

require_relative "lib/textbringer/rouge/version"

Gem::Specification.new do |spec|
  spec.name = "textbringer-rouge"
  spec.version = Textbringer::Rouge::VERSION
  spec.authors = ["yancya"]
  spec.email = ["yancya@upec.jp"]

  spec.summary = "Rouge syntax highlighting integration for Textbringer"
  spec.description = "A Textbringer plugin that integrates Rouge syntax highlighter to provide automatic syntax highlighting for 200+ languages."
  spec.homepage = "https://github.com/yancya/textbringer-rouge"
  spec.license = "WTFPL"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/yancya/textbringer-rouge"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "textbringer", ">= 1.0"
  spec.add_dependency "rouge", ">= 4.0"
end
