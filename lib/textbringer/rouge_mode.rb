# frozen_string_literal: true

require_relative "rouge_adapter"
require_relative "rouge_config"

module Textbringer
  # Universal Rouge mode that supports all languages
  class RougeMode < Mode
    include RougeAdapter

    # Dynamically build file_name_pattern from all Rouge lexers
    # This matches all file extensions that Rouge supports
    patterns = ::Rouge::Lexer.all.flat_map do |lexer|
      next [] unless lexer.filenames

      lexer.filenames.map do |pattern|
        if pattern.start_with?("*.")
          # "*.rb" -> /\.rb\z/i
          ext = Regexp.escape(pattern[2..-1])
          /\.#{ext}\z/i
        elsif pattern.include?("*")
          # "*.foo.bar" -> /\.foo\.bar\z/i
          regex_pattern = Regexp.escape(pattern.sub(/^\*/, '')).gsub('\\*', '.*')
          /#{regex_pattern}\z/i
        else
          # "Rakefile" -> /Rakefile\z/
          /#{Regexp.escape(pattern)}\z/
        end
      end
    end.compact

    self.file_name_pattern = Regexp.union(patterns)

    def initialize(buffer)
      super(buffer)

      # Auto-detect lexer from filename
      begin
        lexer_class = ::Rouge::Lexer.guess(filename: buffer.name)
        @rouge_lexer = lexer_class
        @token_map = RougeConfig::DEFAULT_TOKEN_MAP
      rescue ::Rouge::Guesser::Ambiguous => e
        # If multiple lexers match, use the first one
        @rouge_lexer = e.alternatives.first
        @token_map = RougeConfig::DEFAULT_TOKEN_MAP
      rescue
        # No lexer found, don't set lexer (will fallback to default highlighting)
        @rouge_lexer = nil
      end

      @buffer[:indent_tabs_mode] = false
      @buffer[:tab_width] = 2
    end
  end
end
