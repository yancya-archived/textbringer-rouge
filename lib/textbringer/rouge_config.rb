# frozen_string_literal: true

module Textbringer
  module RougeConfig
    # Default mapping from Rouge token types to Textbringer faces
    DEFAULT_TOKEN_MAP = {
      # String literals
      "Literal.String" => :string,
      "Literal.String.Double" => :string,
      "Literal.String.Single" => :string,
      "Literal.String.Backtick" => :string,
      "Literal.String.Heredoc" => :string,
      "Literal.String.Regex" => :string,
      "Literal.String.Symbol" => :string,

      # Numeric literals
      "Literal.Number" => :number,
      "Literal.Number.Integer" => :number,
      "Literal.Number.Float" => :number,
      "Literal.Number.Hex" => :number,
      "Literal.Number.Oct" => :number,
      "Literal.Number.Bin" => :number,

      # Keywords
      "Keyword" => :keyword,
      "Keyword.Constant" => :keyword,
      "Keyword.Declaration" => :keyword,
      "Keyword.Namespace" => :keyword,
      "Keyword.Pseudo" => :keyword,
      "Keyword.Reserved" => :keyword,
      "Keyword.Type" => :keyword,

      # Comments
      "Comment" => :comment,
      "Comment.Single" => :comment,
      "Comment.Multiline" => :comment,
      "Comment.Doc" => :comment,
      "Comment.Preproc" => :comment,
      "Comment.PreprocFile" => :comment,

      # Names (functions, classes, variables)
      "Name.Function" => :function_name,
      "Name.Class" => :type,
      "Name.Constant" => :constant,
      "Name.Variable" => :variable,
      "Name.Variable.Instance" => :variable,
      "Name.Variable.Class" => :variable,
      "Name.Variable.Global" => :variable,
      "Name.Builtin" => :builtin,
      "Name.Label" => :label,

      # Operators and punctuation
      "Operator" => :operator,
      "Punctuation" => :punctuation,
    }.freeze

    # Define default faces for syntax highlighting
    def self.define_default_faces
      Face.define :string, foreground: "green"
      Face.define :number, foreground: "magenta"
      Face.define :keyword, foreground: "cyan", bold: true
      Face.define :comment, foreground: "brightblack"
      Face.define :function_name, foreground: "blue", bold: true
      Face.define :type, foreground: "yellow", bold: true
      Face.define :constant, foreground: "yellow"
      Face.define :variable, foreground: "default"
      Face.define :builtin, foreground: "cyan"
      Face.define :label, foreground: "yellow", bold: true
      Face.define :operator, foreground: "default"
      Face.define :punctuation, foreground: "default"
    end
  end

  # Define default faces when this module is loaded
  RougeConfig.define_default_faces
end
