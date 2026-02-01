# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

# Mock Textbringer for testing without the actual dependency
module Textbringer
  class Face
    @faces = {}

    def self.define(name, **options)
      @faces[name] = new(name, options)
    end

    def self.[](name)
      @faces[name]
    end

    attr_reader :name, :attributes

    def initialize(name, attributes)
      @name = name
      @attributes = attributes
    end
  end

  class Mode
    attr_reader :buffer

    def initialize(buffer)
      @buffer = buffer
    end

    def self.define_syntax(face, pattern)
      # Mock define_syntax
    end

    def self.file_name_pattern
      @file_name_pattern
    end

    def self.file_name_pattern=(pattern)
      @file_name_pattern = pattern
    end
  end

  class Window
    @@has_colors = true

    def self.class_variable_get(name)
      @@has_colors if name == :@@has_colors
    end

    attr_reader :buffer, :columns, :lines

    def initialize(buffer, columns: 80, lines: 24)
      @buffer = buffer
      @columns = columns
      @lines = lines
    end

    def highlight
      # Mock highlight method (will be overridden by RougeAdapter)
    end

    def instance_variable_set(name, value)
      super(name, value)
    end

    def instance_variable_get(name)
      super(name)
    end
  end

  class Buffer
    attr_reader :name, :bytesize, :point_min, :point

    def initialize(name:, content: "", bytesize: nil)
      @name = name
      @content = content
      @bytesize = bytesize || content.bytesize
      @point_min = 0
      @point = 0
      @vars = {}
    end

    def to_s
      @content
    end

    def binary?
      false
    end

    def substring(start_pos, end_pos)
      @content[start_pos...end_pos]
    end

    def []=(key, value)
      @vars[key] = value
    end

    def [](key)
      @vars[key]
    end
  end

  CONFIG = {
    syntax_highlight: true,
    highlight_buffer_size_limit: 1024 * 1024,
  }
end

# Load Rouge before loading our code
require "rouge"

# Now load our code
require "textbringer/rouge_adapter"
require "textbringer/rouge_config"

require "test/unit"
