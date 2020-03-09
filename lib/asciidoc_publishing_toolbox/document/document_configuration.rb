# frozen_string_literal: true

require 'json'
require 'json_schemer'
require 'date'
require 'net/http'
require 'asciidoc_publishing_toolbox/document/author'

module AsciiDocPublishingToolbox
  module Document
    # The document configuration.
    #
    # This class exposes an interface to define a new configuration that's compliant
    # with the schema document.schema.json.
    class DocumentConfiguration
      attr_reader :title, :authors, :type, :chapters, :lang, :copyright, :version
      FILE_NAME = 'document.json'
      SCHEMA = 'https://espositoandrea.github.io/adpt-document-schema/schemas/document.schema.json'

      module DocumentType
        BOOK = 'book'
        ARTICLE = 'article'

        def self.value_for_name(name)
          const_get name.upcase, false
        end
      end

      # An error that should be raised if a configuration is invalid.
      class InvalidConfigurationError < StandardError
        # Initialize the error
        #
        # @param msg The message.
        def initialize(msg = 'The configuration file is not valid.')
          super
        end
      end
      # Create a new empty document configuration
      def initialize(opts = {title: nil, authors: nil})
        @title = validate_title opts[:title] unless opts[:title].nil?
        @authors = validate_author_list opts[:authors] unless opts[:authors].nil?
        @type = opts[:type] || DocumentType::BOOK
        @chapters = validate_chapter_list opts[:chapters]
        @lang = (opts[:lang] || 'en').strip.downcase
        @copyright = (opts[:copyright] || {fromYear: Date.today.year})
        @version = (opts[:version] || nil)
      end

      # Load an existing configuration
      # @param [String,Pathname,Hash] configuration The existing configuration. If
      #   it's a string, it's treated as a JSON string; if it's a Pathname it's
      #   treated as the path to the directory containing the configuration; if it's an
      #   Hash it's treated as the configuration itself.
      #
      # @raise [ArgumentError] if configuration is not of an accepted type
      # @return [DocumentConfiguration] The loaded configuration
      def self.load(configuration)
        case configuration
        when String
          configuration = JSON.parse configuration
        when Pathname
          configuration = File.read configuration + FILE_NAME
          configuration = JSON.parse configuration
        else
          raise ArgumentError, "Unsupported type (#{configuration.class.name}) for 'configuration'" unless configuration.is_a? Hash
        end

        schemer = JSONSchemer.schema(Net::HTTP.get(URI.parse(SCHEMA)), ref_resolver: 'net/http', insert_property_defaults: true, format: false)
        errors = schemer.validate(configuration).to_a
        raise InvalidConfigurationError, errors.to_s unless errors.empty?

        authors = []
        configuration['authors'].each do |author|
          authors << Author.new(author['name'], author['surname'], author['email'], author['middlename'])
        end
        version = configuration['version'].transform_keys(&:to_sym) rescue nil
        type = DocumentType.value_for_name configuration['type'] rescue DocumentType::BOOK
        DocumentConfiguration.new title: configuration['title'], authors: authors,
                                  type: type, chapters: configuration['chapters'],
                                  lang: configuration['lang'],
                                  copyright: configuration['copyright'].transform_keys(&:to_sym),
                                  version: version
      end

      # Check if the document is valid
      #
      # @return [Boolean] true if the object represents a valid object.
      def check_if_valid
        !@title.nil? && !@title.empty? && !@authors.nil? && !@authors.empty?
      end

      # Set the title of the document
      #
      # @param [String] title The new title
      # @raise [ArgumentError] if the title is nil or empty
      def title=(title)
        @title = validate_title title
      end

      # Set the authors' list of the document
      #
      # @param [Array<DocumentConfiguration::Author>] authors The new authors
      # @raise [ArgumentError] if the authors' list contains duplicates
      def authors=(authors)
        @authors = validate_author_list authors
      end

      def self.document?(dir)
        Dir.exist?(dir) && !Dir.empty?(dir) && File.exist?(File.join(dir, DocumentConfiguration::FILE_NAME))
      end

      def add_chapter(title, is_part = false)
        @chapters = validate_chapter_list @chapters, {title: title, part: is_part}
      end

      # Convert the configuration to an hash object
      #
      # @return [Hash] the hash representation of the configuration
      def to_hash
        hash = {
            '$schema': DocumentConfiguration::SCHEMA,
            title: @title,
            authors: @authors,
            chapters: @chapters,
            lang: @lang,
            copyright: @copyright,
        }
        hash[:version] = @version if @version
        hash
      end

      # Convert the configuration to JSON
      #
      # @param opts
      # @return [String] The JSON representation of the configuration
      def to_json(*opts)
        JSON.pretty_generate(to_hash, *opts)
      end

      # Write the configuration to a JSON file
      #
      # @param [String] directory The directory where the file will be stored
      def write_file(directory)
        File.open(File.join(directory, FILE_NAME), 'w') do |f|
          f.write to_json
        end
      end

      private

      def validate_chapter_list(chapters, new_chap = nil)
        if new_chap
          chapters.each do |ch|
            if ch[:title].downcase.gsub(' ', '-') == title.downcase.gsub(' ', '-')
              raise ArgumentError, 'The chapter "ID" must be unique (title in lower case, with spaces replaced by hypens "-")'
            end
          end
          chapters << new_chap
        else
          return chapters unless chapters.detect { |e| authors.count(e) > 1 }
        end
      end

      def validate_author_list(authors)
        return authors unless authors.detect { |e| authors.count(e) > 1 }

        raise ArgumentError, 'The authors list must not contain duplicates!'
      end

      def validate_title(title)
        return title.strip unless title.nil? || title.strip.empty?

        raise ArgumentError, "The title can't be empty"
      end
    end
  end
end