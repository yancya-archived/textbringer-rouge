# frozen_string_literal: true

require_relative "rouge_adapter"
require_relative "rouge_config"

module Textbringer
  # Universal Rouge mode that supports all languages
  class RougeMode < Mode
    include RougeAdapter

    # Match common source file extensions
    # This pattern will match before Fundamental mode but after specific modes like RubyMode
    self.file_name_pattern = /\.(py|js|ts|jsx|tsx|json|yaml|yml|toml|xml|html|css|scss|sass|java|c|cpp|h|hpp|rs|go|php|rb|sh|bash|sql|md|txt)\z/i

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
