# frozen_string_literal: true

require_relative './lib/asciidoc_publishing_toolbox/version'

Gem::Specification.new do |s|
  s.name = 'asciidoc_publishing_toolbox'
  s.version = AsciiDocPublishingToolbox::VERSION
  s.license = 'GPL-3.0'
  s.summary = 'A publishing toolbox for AsciiDoc'
  s.description = 'An authoring and publishing system for the AsciiDoc markdown language'
  s.author = 'Andrea Esposito'
  s.email = 'esposito_andrea99@hotmail.com'
  s.files = Dir.glob('lib/**/*') + %w[LICENSE.md README.adoc]
  s.homepage = 'https://asciidoc-publishing-toolbox.github.io/'
  s.executables << 'adpt'
  s.metadata = {
    'source_code_uri' => 'https://github.com/AsciiDoc-Publishing-Toolbox/asciidoc_publishing_toolbox',
    'homepage_uri' => 'https://asciidoc-publishing-toolbox.github.io/',
    'documentation_uri' => 'https://rubydoc.info/github/AsciiDoc-Publishing-Toolbox/asciidoc_publishing_toolbox/master',
    'bug_tracker_uri' => 'https://github.com/AsciiDoc-Publishing-Toolbox/asciidoc_publishing_toolbox/issues'
  }

  s.add_runtime_dependency 'asciidoctor', '~> 2.0', '>= 2.0.10'
  s.add_runtime_dependency 'asciidoctor-pdf', '~> 1.5', '>= 1.5.3'
  s.add_runtime_dependency 'json_schemer', '~> 0.2', '>= 0.2.10'
  s.add_runtime_dependency 'i18n', '~> 1.8', '>= 1.8.1'
  s.add_runtime_dependency 'nokogiri', '~> 1.10'

  s.add_development_dependency 'faker', '~> 2.10', '>= 2.10.2'
  s.add_development_dependency 'minitest', '~> 5.14', '>= 5.14.0'
  s.add_development_dependency 'rake', '~> 13.0'
end
