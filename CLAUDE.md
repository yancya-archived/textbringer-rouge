# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

**textbringer-rouge** は、Textbringer エディタに Rouge シンタックスハイライトライブラリを統合し、200+ の言語に自動でシンタックスハイライトを提供する Ruby gem。

### 背景と目的

- 各言語ごとに正規表現ベースのシンタックスルールを手書きするのはメンテコストが高い
- Rouge（デファクトスタンダードなシンタックスハイライター）を統合することで、上流のメンテに任せられる
- 一つの gem で全言語をサポートする方が、言語ごとに個別の gem を作るよりも有用

## 開発コマンド

```bash
# 依存関係のインストール
bundle install

# テスト実行
bundle exec rake test

# 単一テストファイルの実行
bundle exec ruby -I lib:test test/textbringer/rouge_adapter_test.rb

# gem のビルド
bundle exec rake build

# ローカルインストール
bundle exec rake install
```

## アーキテクチャ

### コア設計原則

Textbringer のシンタックスハイライトは、**Window クラス**が Mode クラスの `syntax_table` を直接参照して処理する。Mode の `highlight` メソッドは呼ばれない。そのため、Rouge を使ったカスタムハイライトを実現するには、**Window クラスのモンキーパッチ**が必要。

### Window モンキーパッチの仕組み

```ruby
# Window#highlight をオーバーライド
class Window
  alias_method :original_highlight, :highlight

  def highlight
    if @buffer.mode.respond_to?(:custom_highlight)
      @buffer.mode.custom_highlight(self)  # Mode に委譲
    else
      original_highlight  # デフォルトの正規表現ベース
    end
  end
end
```

Mode が `custom_highlight` メソッドを実装していれば、それを使う。そうでなければ従来の正規表現ベースのハイライトにフォールバック。

### RougeAdapter モジュール

Mode に include することで、Rouge を使ったハイライトを提供する:

```ruby
module RougeAdapter
  # Window から呼ばれる
  def custom_highlight(window)
    lexer = self.class.rouge_lexer.new
    text = @buffer.to_s

    position = @buffer.point_min
    lexer.lex(text).each do |token, value|
      face_name = token_type_to_face(token)
      # face_name に対応する Face の attributes を適用
      position += value.bytesize
    end
  end

  private

  def token_type_to_face(token)
    # Rouge のトークン階層を利用してマッピング
    # Literal.String.Double → Literal.String → Literal
    # 完全一致がなければ親トークンタイプへフォールバック
  end
end
```

### トークンマッピングの階層

Rouge のトークンは階層構造を持つ（例: `Literal.String.Double` → `Literal.String` → `Literal`）。`token_type_to_face` メソッドは、完全一致がない場合に親トークンタイプへフォールバックすることで、すべてのトークンを適切にマッピングする。

## 技術的な重要ポイント

### 1. パフォーマンス考慮

- Textbringer は `CONFIG[:highlight_buffer_size_limit]` でハイライトするバッファサイズを制限（デフォルト 1024 バイト）
- Rouge のトークナイズは正規表現より遅い可能性があるため、パフォーマンステストが必要
- 大きいファイルでは部分的にハイライト

### 2. エラーハンドリング

- Rouge が失敗した場合は、デフォルトの正規表現ベースにフォールバック
- 不正な構文のファイルでもクラッシュしないようにする

### 3. デフォルトトークンマッピング

標準的な Rouge トークンを Textbringer のフェイスにマッピング:

```ruby
DEFAULT_TOKEN_MAP = {
  'Literal.String' => :string,
  'Literal.Number' => :number,
  'Keyword' => :keyword,
  'Comment' => :comment,
  'Name.Function' => :function_name,
  'Name.Class' => :type,
}
```

### 4. デフォルトフェイス定義

```ruby
Face.define :string, foreground: "green"
Face.define :number, foreground: "magenta"
Face.define :keyword, foreground: "cyan", bold: true
Face.define :comment, foreground: "brightblack"
Face.define :function_name, foreground: "blue", bold: true
Face.define :type, foreground: "yellow", bold: true
```

## PoC 実装の参照先

完全動作版の PoC 実装は `/Users/yancya/.ghq/github.com/yancya/textbringer-json/` にある:

- `lib/textbringer/rouge_adapter.rb` - RougeAdapter の完全実装
- `test/rouge_adapter_test.rb` - テストコード（全部通過）
- 実際に JSON ファイルでハイライトが動作確認済み（79 トークン処理、50 ハイライトエントリ適用）

新しいコードを書く際は、この PoC 実装を参考にすること。

## プロジェクト構造（予定）

```
textbringer-rouge/
├── lib/
│   ├── textbringer/
│   │   ├── rouge_adapter.rb      # Window モンキーパッチ + RougeAdapter
│   │   ├── rouge_mode_factory.rb # 動的 Mode 生成
│   │   └── rouge_config.rb       # デフォルトトークンマッピング
│   └── textbringer_plugin.rb     # プラグインエントリポイント
├── test/
├── README.md
└── CLAUDE.md
```

## 自動言語検出の実装方針

ファイル拡張子や shebang から適切な Rouge lexer を選択し、動的に Mode を生成:

```ruby
class RougeModeFactory
  def self.create_mode_for_file(filename)
    lexer = Rouge::Lexer.guess(filename: filename)
    create_mode_for_lexer(lexer)
  end

  def self.create_mode_for_lexer(lexer_class)
    mode_class = Class.new(Textbringer::Mode) do
      include RougeAdapter
      use_rouge lexer_class, default_token_map
    end
    mode_class
  end
end
```

## テストの方針

- RougeAdapter 自体の単体テスト
- 複数言語（Ruby, Python, JavaScript など）のハイライトテスト
- パフォーマンステスト（大きいファイル、トークン数の多いファイル）
- エラーハンドリングのテスト（不正な構文のファイル）

## 参考リンク

- [Rouge GitHub](https://github.com/rouge-ruby/rouge)
- [Textbringer GitHub](https://github.com/shugo/textbringer)
- [Rouge Lexers 一覧](https://github.com/rouge-ruby/rouge/wiki/List-of-supported-languages-and-lexers)
