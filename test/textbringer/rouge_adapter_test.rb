# frozen_string_literal: true

require "test_helper"

module Textbringer
  class RougeAdapterTest < Test::Unit::TestCase
    test "VERSION is defined" do
      assert do
        ::Textbringer::Rouge.const_defined?(:VERSION)
      end
    end

    test "RougeAdapter module exists" do
      assert do
        defined?(Textbringer::RougeAdapter)
      end
    end

    test "RougeAdapter provides use_rouge class method" do
      mode_class = Class.new(Mode) do
        include RougeAdapter
      end

      assert_respond_to mode_class, :use_rouge
    end

    test "RougeAdapter::use_rouge configures lexer and token_map" do
      mode_class = Class.new(Mode) do
        include RougeAdapter
        use_rouge ::Rouge::Lexers::Ruby, {
          "Keyword" => :keyword,
          "Literal.String" => :string,
        }
      end

      assert_equal ::Rouge::Lexers::Ruby, mode_class.rouge_lexer
      assert_equal({ "Keyword" => :keyword, "Literal.String" => :string }, mode_class.token_map)
    end

    test "RougeAdapter::custom_highlight tokenizes simple Ruby code" do
      mode_class = Class.new(Mode) do
        include RougeAdapter
        use_rouge ::Rouge::Lexers::Ruby, {
          "Keyword" => :keyword,
          "Literal.String" => :string,
        }
      end

      buffer = Buffer.new(name: "test.rb", content: 'puts "hello"')
      mode = mode_class.new(buffer)
      window = Window.new(buffer)

      mode.custom_highlight(window)

      highlight_on = window.instance_variable_get(:@highlight_on)
      assert_not_nil highlight_on
      assert_operator highlight_on.size, :>, 0
    end

    test "RougeAdapter::token_type_to_face maps tokens with parent fallback" do
      mode_class = Class.new(Mode) do
        include RougeAdapter
        use_rouge ::Rouge::Lexers::Ruby, {
          "Literal.String" => :string,
          "Keyword" => :keyword,
        }
      end

      buffer = Buffer.new(name: "test.rb")
      mode = mode_class.new(buffer)

      # Test exact match
      token = ::Rouge::Token["Keyword"]
      face = mode.send(:token_type_to_face, token)
      assert_equal :keyword, face

      # Test parent fallback (Literal.String.Double -> Literal.String)
      token = ::Rouge::Token["Literal.String.Double"]
      face = mode.send(:token_type_to_face, token)
      assert_equal :string, face
    end

    test "RougeConfig::DEFAULT_TOKEN_MAP is defined" do
      assert do
        RougeConfig::DEFAULT_TOKEN_MAP.is_a?(Hash)
      end
    end

    test "RougeConfig defines default faces" do
      assert_not_nil Face[:string]
      assert_not_nil Face[:number]
      assert_not_nil Face[:keyword]
      assert_not_nil Face[:comment]
    end
  end
end
