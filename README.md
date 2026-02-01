# Textbringer Rouge

Rouge syntax highlighting integration for Textbringer.

This plugin integrates the [Rouge](https://github.com/rouge-ruby/rouge) syntax highlighter into [Textbringer](https://github.com/shugo/textbringer), automatically providing syntax highlighting for 200+ programming languages without needing to write regex patterns for each language.

## Features

- **200+ Languages**: Automatic syntax highlighting for all languages supported by Rouge
- **Zero Configuration**: Works out of the box - just install and open any supported file
- **Smart Detection**: Automatically detects the language from file extensions
- **Fallback Support**: Falls back to regex-based highlighting if Rouge fails
- **Customizable**: Override default token mappings and colors for any language

## Installation

Install the gem by executing:

```bash
gem install textbringer-rouge
```

Or add it to your Gemfile:

```ruby
gem 'textbringer-rouge'
```

## Usage

The plugin is automatically loaded when you start Textbringer. Simply open any supported file and syntax highlighting will be applied automatically.

### Supported Languages

Rouge supports 200+ languages including:

- **Web**: HTML, CSS, JavaScript, TypeScript, JSX, Vue, Svelte
- **Programming**: Ruby, Python, Java, C, C++, C#, Go, Rust, Swift, Kotlin
- **Scripting**: Bash, PowerShell, Perl, Lua, R
- **Data**: JSON, YAML, TOML, XML, CSV
- **Markup**: Markdown, reStructuredText, AsciiDoc
- **Config**: Nginx, Apache, Dockerfile, .gitignore
- **And many more...**

See the [full list of supported languages](https://github.com/rouge-ruby/rouge/wiki/List-of-supported-languages-and-lexers).

### Customization

You can customize the colors by modifying Textbringer faces in your `~/.textbringer.rb`:

```ruby
# Change string color
Textbringer::Face.define :string, foreground: "lightgreen"

# Change keyword color
Textbringer::Face.define :keyword, foreground: "lightblue", bold: true

# Change comment color
Textbringer::Face.define :comment, foreground: "gray", italic: true
```

### Debug Mode

Enable debug logging to troubleshoot issues:

```bash
TEXTBRINGER_ROUGE_DEBUG=1 textbringer your_file.rb
```

Debug logs will be written to `/tmp/rouge_adapter_debug.log`.

## How It Works

Textbringer Rouge uses a clever technique to integrate Rouge with Textbringer:

1. **Window Monkey Patch**: Extends `Window#highlight` to support custom highlighting methods
2. **RougeAdapter**: A mixin module that provides Rouge-based highlighting for any Mode
3. **Token Mapping**: Maps Rouge's semantic tokens to Textbringer's Face system
4. **Fallback**: Falls back to regex-based highlighting if Rouge encounters errors

This approach maintains compatibility with existing Textbringer modes while adding powerful language support.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

### Running Tests

```bash
# Run all tests
bundle exec rake test

# Run a specific test file
bundle exec ruby -I lib:test test/textbringer/rouge_adapter_test.rb
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yancya/textbringer-rouge.

## License

The gem is available as open source under the terms of the [WTFPL](http://www.wtfpl.net/).

## Credits

- [Textbringer](https://github.com/shugo/textbringer) - The Emacs-like text editor in Ruby
- [Rouge](https://github.com/rouge-ruby/rouge) - The pure Ruby syntax highlighter
