# frozen_string_literal: true

require "test_helper"
require "textbringer/rouge_mode"

module Textbringer
  class RougeModeTest < Test::Unit::TestCase
    test "RougeMode class exists" do
      assert do
        defined?(Textbringer::RougeMode)
      end
    end

    test "RougeMode has file_name_pattern" do
      assert_not_nil RougeMode.file_name_pattern
    end

    test "RougeMode file_name_pattern matches Python files" do
      assert_match RougeMode.file_name_pattern, "test.py"
    end

    test "RougeMode file_name_pattern matches JSON files" do
      assert_match RougeMode.file_name_pattern, "test.json"
    end

    test "RougeMode file_name_pattern matches JavaScript files" do
      assert_match RougeMode.file_name_pattern, "test.js"
    end

    test "RougeMode auto-detects Python lexer" do
      buffer = Buffer.new(name: "test.py")
      mode = RougeMode.new(buffer)

      assert_equal ::Rouge::Lexers::Python, mode.rouge_lexer
    end

    test "RougeMode auto-detects JSON lexer" do
      buffer = Buffer.new(name: "test.json")
      mode = RougeMode.new(buffer)

      assert_equal ::Rouge::Lexers::JSON, mode.rouge_lexer
    end

    test "RougeMode auto-detects Ruby lexer" do
      buffer = Buffer.new(name: "test.rb")
      mode = RougeMode.new(buffer)

      assert_equal ::Rouge::Lexers::Ruby, mode.rouge_lexer
    end

    test "RougeMode has default token_map" do
      buffer = Buffer.new(name: "test.py")
      mode = RougeMode.new(buffer)

      assert_not_nil mode.token_map
      assert_kind_of Hash, mode.token_map
    end
  end
end
