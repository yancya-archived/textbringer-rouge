# frozen_string_literal: true

require "rouge"

module Textbringer
  # Monkey patch Window to support custom highlight methods in modes
  class Window
    unless method_defined?(:original_highlight)
      alias_method :original_highlight, :highlight

      def highlight
        # If the mode has a custom highlight method, use it
        if @buffer.mode.respond_to?(:custom_highlight)
          @buffer.mode.custom_highlight(self)
        else
          # Otherwise use the default regex-based highlighting
          original_highlight
        end
      end
    end
  end

  # Adapter module to use Rouge lexers for syntax highlighting in Textbringer.
  #
  # This allows modes to leverage Rouge's extensive language support (200+ languages)
  # instead of manually writing regex patterns.
  #
  # Usage:
  #   class MyMode < Mode
  #     include RougeAdapter
  #     use_rouge Rouge::Lexers::JSON, {
  #       'Literal.String' => :string,
  #       'Literal.Number' => :number,
  #     }
  #   end
  module RougeAdapter
    DEBUG = ENV["TEXTBRINGER_ROUGE_DEBUG"] == "1"

    attr_accessor :rouge_lexer, :token_map

    def custom_highlight(window)
      window.instance_variable_set(:@highlight_on, {})
      window.instance_variable_set(:@highlight_off, {})

      if DEBUG
        File.open("/tmp/rouge_adapter_debug.log", "a") do |f|
          f.puts "[#{Time.now}] RougeAdapter#custom_highlight called"
          f.puts "  has_colors: #{Window.class_variable_get(:@@has_colors)}"
          f.puts "  syntax_highlight: #{CONFIG[:syntax_highlight]}"
          f.puts "  binary: #{@buffer.binary?}"
          f.puts "  buffer: #{@buffer.name}"
        end
      end

      return if !Window.class_variable_get(:@@has_colors) || !CONFIG[:syntax_highlight] || @buffer.binary?

      # Use instance-level lexer if available, otherwise use class-level
      lexer_class = @rouge_lexer || self.class.rouge_lexer
      lexer = lexer_class&.new

      if DEBUG
        File.open("/tmp/rouge_adapter_debug.log", "a") do |f|
          f.puts "  lexer: #{lexer ? lexer.class : 'nil'}"
        end
      end

      unless lexer
        # Fallback to regex-based highlighting
        window.send(:original_highlight)
        return
      end

      # Get text to highlight (same logic as original)
      if @buffer.bytesize < CONFIG[:highlight_buffer_size_limit]
        base_pos = @buffer.point_min
        text = @buffer.to_s
      else
        base_pos = @buffer.point
        len = window.columns * (window.lines - 1) / 2 * 3
        text = @buffer.substring(@buffer.point, @buffer.point + len).scrub("")
      end

      return unless text.valid_encoding?

      # Tokenize using Rouge
      highlight_on = {}
      position = base_pos
      token_count = 0
      lexer.lex(text).each do |token, value|
        token_count += 1
        face_name = token_type_to_face(token)

        # Apply highlight at token start position
        if face_name && (attributes = Face[face_name]&.attributes)
          # Skip if position is before buffer point (same logic as original)
          token_end = position + value.bytesize
          if position < @buffer.point && @buffer.point < token_end
            position = @buffer.point
          end

          highlight_on[position] = attributes
        end

        position += value.bytesize
      end

      window.instance_variable_set(:@highlight_on, highlight_on)

      if DEBUG
        File.open("/tmp/rouge_adapter_debug.log", "a") do |f|
          f.puts "  tokens processed: #{token_count}"
          f.puts "  highlight_on entries: #{highlight_on.size}"
        end
      end
    rescue ::Rouge::Guesser::Ambiguous, StandardError => e
      # Fallback to regex-based highlighting if Rouge fails
      if DEBUG
        File.open("/tmp/rouge_adapter_debug.log", "a") do |f|
          f.puts "  ERROR: #{e.class}: #{e.message}"
          f.puts "  Falling back to regex-based highlighting"
        end
      end
      window.send(:original_highlight)
    end

    private

    def token_type_to_face(token)
      # Convert Rouge token to face name using the configured mapping
      # Use instance-level token_map if available, otherwise use class-level
      token_map = @token_map || self.class.token_map || {}
      token_qualname = token.qualname

      # Try exact match first
      return token_map[token_qualname] if token_map[token_qualname]

      # Try parent token types (e.g., Literal.String.Double -> Literal.String -> Literal)
      parent = token.token_chain.find { |t| token_map[t.qualname] }
      token_map[parent&.qualname]
    end

    module ClassMethods
      attr_accessor :rouge_lexer, :token_map

      # Configure this mode to use a Rouge lexer for syntax highlighting.
      #
      # @param lexer_class [Class] Rouge lexer class (e.g., Rouge::Lexers::JSON)
      # @param token_map [Hash] Mapping from Rouge token qualnames to Textbringer face names
      #
      # Example:
      #   use_rouge Rouge::Lexers::JSON, {
      #     'Literal.String' => :string,
      #     'Literal.Number' => :number,
      #     'Keyword.Constant' => :keyword,
      #   }
      def use_rouge(lexer_class, token_map = {})
        include RougeAdapter unless included_modules.include?(RougeAdapter)
        self.rouge_lexer = lexer_class
        self.token_map = token_map
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
