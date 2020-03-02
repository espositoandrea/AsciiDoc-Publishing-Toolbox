# frozen_string_literal: true

require 'net/http'
require 'uri'

module AsciiDocPublishingToolbox
  # A document
  #
  # @!attribute [r] config
  #   @return [DocumentConfiguration] The document configuration.
  class Document
    # Create a new document
    #
    # @param [DocumentConfiguration] config The document configuration
    def initialize(config)
      @config = config
    end

    def file_name
      @config.title.downcase.gsub(' ', '-')
    end

    # Get the document as string
    # @return [String] the document
    def to_s
      author_string = []
      @config.authors.each do |author|
        author_string << author.to_s
      end

      # TODO: Add copyright year
      # TODO: Add revision date
      # TODO: Add language
      lang_url = "https://raw.githubusercontent.com/asciidoctor/asciidoctor/master/data/locale/attributes-#{@config.lang}.adoc"
      <<~DOC
        = #{@config.title}
        #{author_string.join('; ')}
        :doctype: #{@config.type}
        :toc: left
        :sectnums:
        :partnums:
        :sectnumsdepth: 5
        :xrefstyle: short
        :copyright-year: 2019--2020
        :lang: #{@config.lang}
        #{Net::HTTP.get(URI.parse(lang_url))}

        include::src/colophon.adoc[]

        #{@config.chapters.map { |ch| "include::src/#{ch['title'].downcase.gsub(' ', '-')}.adoc[#{'leveloffset=+1' unless ch['part']}]" }.join("\n\n")}
      DOC
    end

    def self.default_colophon
      # TODO: Get colophon from JSON
      <<~COLOPHON
        [colophon#colophon%nonfacing]
        == {doctitle}

        Copyright (c) {copyright-year}, {author}.

        _Created using ADPT, the AsciiDoc Publishing Toolbox_.
      COLOPHON
    end
  end
end