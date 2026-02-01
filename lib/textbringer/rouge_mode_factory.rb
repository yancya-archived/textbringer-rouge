# frozen_string_literal: true

require_relative "rouge_adapter"
require_relative "rouge_config"
require_relative "rouge/version"

module Textbringer
  module RougeModeFactory
    @mode_cache = {}

    class << self
      # Create a Mode class for a specific Rouge lexer
      #
      # @param lexer_class [Class] Rouge lexer class (e.g., ::Rouge::Lexers::JSON)
      # @return [Class] A Mode subclass configured for that lexer
      def create_mode_for_lexer(lexer_class)
        # Cache modes to avoid recreating them
        @mode_cache[lexer_class] ||= begin
          # Create class name for the mode
          mode_class_name = "Rouge#{lexer_class.tag.capitalize}Mode"

          # Check if already defined
          if Textbringer.const_defined?(mode_class_name)
            return Textbringer.const_get(mode_class_name)
          end

          # Build file name pattern
          file_pattern_code = if lexer_class.filenames && !lexer_class.filenames.empty?
            patterns_code = lexer_class.filenames.map do |pattern|
              if pattern.start_with?("*.")
                ext = Regexp.escape(pattern[2..-1])
                "/\\.#{ext}\\z/i"
              elsif pattern.include?("*")
                regex_pattern = Regexp.escape(pattern).gsub('\*', '.*')
                "/#{regex_pattern}\\z/i"
              else
                "/#{Regexp.escape(pattern)}\\z/"
              end
            end.join(", ")
            "self.file_name_pattern = Regexp.union(#{patterns_code})"
          else
            ""
          end

          # Define the mode class using class_eval with a named class
          # This ensures Mode.inherited is called with a properly named class
          Textbringer.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            class #{mode_class_name} < Mode
              include RougeAdapter
              use_rouge #{lexer_class.inspect}, RougeConfig::DEFAULT_TOKEN_MAP

              #{file_pattern_code}

              def initialize(buffer)
                super(buffer)
                @buffer[:indent_tabs_mode] = false
                @buffer[:tab_width] = 2
              end
            end
          RUBY

          Textbringer.const_get(mode_class_name)
        end
      end

      # Create a Mode for a file based on its filename
      #
      # @param filename [String] The filename to guess the lexer for
      # @return [Class, nil] A Mode subclass, or nil if no lexer found
      def create_mode_for_file(filename)
        lexer_class = ::Rouge::Lexer.guess(filename: filename)
        create_mode_for_lexer(lexer_class)
      rescue ::Rouge::Guesser::Ambiguous => e
        # If multiple lexers match, pick the first one
        create_mode_for_lexer(e.alternatives.first)
      rescue
        # No lexer found
        nil
      end

      # Register all Rouge lexers with Textbringer
      #
      # This should be called when the plugin is loaded
      def register_all_lexers
        ::Rouge::Lexer.all.each do |lexer_class|
          # Skip lexers without file patterns
          next if lexer_class.filenames.nil? || lexer_class.filenames.empty?

          begin
            create_mode_for_lexer(lexer_class)
          rescue => e
            # Skip lexers that fail to initialize
            warn "Failed to register lexer #{lexer_class}: #{e.message}" if ENV["TEXTBRINGER_ROUGE_DEBUG"] == "1"
          end
        end
      end
    end
  end

  # Auto-register all lexers when the module is loaded
  RougeModeFactory.register_all_lexers
end
