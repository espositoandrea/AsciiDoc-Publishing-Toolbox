# frozen_string_literal: true

require 'i18n'

module AsciiDocPublishingToolbox
  # A utility module
  module Utilities
    module_function

    # Get an input from the user
    #
    # @param [String] prompt A message to prompt to the user
    # @return [String] The value given by the user (chomped).
    def get_input(prompt = '')
      print prompt + ' '
      input = gets
      input.chomp
    end

    # Get a string in input.
    #
    # @param [String] prompt A prompt for the user
    # @param [String] error_message An error message to be printed in case of an
    #   empty string
    # @return [String] The given string (chomped).
    def gets_not_empty(prompt = '', error_message = 'No value inserted.')
      input = nil
      while input.nil? || input.empty?
        print error_message + ' ' unless input.nil?
        input = get_input prompt
      end
      input
    end

    # Get a list of author in input from the user
    #
    # @return [Array<DocumentConfiguration::Author>] An array containing the
    #   given authors
    def get_authors_input
      input = []
      loop do
        begin
          first_name = if input.empty?
                         gets_not_empty("Insert the #{input.length + 1}° author name:")
                       else
                         get_input("Insert the #{input.length + 1}° author name (leave empty to stop):")
                       end

          author = AsciiDocPublishingToolbox::Document::Author.from_string first_name
        rescue ArgumentError => e
          puts e.message
          retry
        end
        break if first_name.empty?

        unless author
          surname = gets_not_empty "Insert the #{input.length + 1}° author surname"
          middle_name = get_input "Insert the #{input.length + 1}° author middle name [default: '']:"
          email = get_input "Insert the #{input.length + 1}° author email [default: '']:"

          author = AsciiDocPublishingToolbox::Document::Author.new first_name, surname, email, middle_name
        end
        input.push author
      end

      input
    end

    # Check if a directory can be used to create a document.
    #
    # @param dir The target directory. If this directory does not exists
    #   it will be created.
    # @param [Boolean] overwrite Whether or not the files in an existing target
    #   directory can be eventually overwritten by the new document
    # @param [Boolean] create Whether or not the directory should be created (if
    #   it does not exist).
    # @raise [ArgumentError] if the given directory exists and overwrite is false.
    def check_target_directory(dir, overwrite = false, create = false)
      overwrite ||= false
      return if !create && !Dir.exist?(dir)

      FileUtils.mkdir_p dir
      return if overwrite || Dir.empty?(dir)

      raise ArgumentError, 'The given directory exists and is not empty'
    end

    # Get an ID from a string.
    #
    # @param string [String] The input string.
    # @return [String] The ID.
    def get_id(string)
      I18n.available_locales = [:en]
      string = string.strip
      string.downcase!
      string = I18n.transliterate string
      string.gsub! /[^a-zA-Z0-9\s]/, ''
      string.gsub /\s+/, '-'
    end
  end
end
