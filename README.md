# quarto-js-typst

LaTeX の `jsarticle` / `jsbook` 相当の版面を Typst で再現する Quarto フォーマットです。
組版の中核には奥村晴彦氏の Typst パッケージ
[`js`](https://github.com/okumuralab/typst-js) を使い、Quarto 側の
メタデータ・相互参照・引用・コードセルをそこに接続しています。

| フォーマット | 用途 |
|:--|:--|
| `jsarticle-typst` | 単一の記事・レポート |
| `jsbook-typst` | Quarto Book（Quarto 1.9 以降の単一ファイル Typst book）および単一ファイルの書籍風文書 |

## インストール

```bash
quarto add kazuyanagimoto/quarto-js-typst
```

スターターの `.qmd` ごと取得する場合:

```bash
quarto use template kazuyanagimoto/quarto-js-typst
```

## jsarticle

````yaml
---
title: "タイトル"
author:
  - name: 柳本 和春
    affiliation: CEMFI
    email: kazuharu.yanagimoto@cemfi.edu.es
abstract: |
  概要をここに書きます。
format:
  jsarticle-typst: default
---
````

## jsbook

Quarto Book プロジェクトの `_quarto.yml` でフォーマットに指定します。

````yaml
project:
  type: book

book:
  title: "本のタイトル"
  author: "柳本 和春"
  chapters:
    - index.qmd
    - part: "第一部のタイトル"
      chapters:
        - intro.qmd
        - methods.qmd
  appendices:
    - notation.qmd

format: jsbook-typst
````

対応している jsbook 的な構造は次のとおりです。

- **扉** — タイトル・副題・著者・日付を独立ページに組みます。
- **前付 / 本文** — 扉と目次、および番号のない章（`index.qmd` のまえがきなど）は
  小文字ローマ数字、最初の番号付き章（または最初の部）から算用数字に戻して 1 から
  数え直します。LaTeX の `\frontmatter` / `\mainmatter` に相当します。
  `frontmatter: false` にすると通しの算用数字になります。
- **部** — `book.chapters` の `part:` が「第 I 部」の扉ページになり、目次にも
  太字で入ります。
- **付録** — `book.appendices` から `\appendix` 相当に切り替わり、章見出しが
  「付録 A」、図表・数式・定理番号が `A.1` 形式になります。
  Quarto が挿入する "Appendices" の仕切り見出しは jsbook には無いので落とします。
- **柱（ヘッダ）** — 偶数ページに「第 1 章 章題」、奇数ページに「1.1 節題」。
  章扉・部扉には付きません。付録では「付録 A」と出ます。
- **章ごとの番号** — 図 1.1、式 (1.1)、定理 1.1。カウンタのリセットは Quarto 本体が
  行います。

単一の `.qmd` に `format: jsbook-typst` を指定した場合も、扉・目次・章起こしは
同じように動きます（最初のレベル 1 見出しから本文扱いになります）。

## オプション

`js` パッケージの引数はすべて YAML から指定できます。既定値は `js` に準拠します。
両フォーマット共通です。

| キー | 既定値 | 説明 |
|:--|:--|:--|
| `papersize` | `a4` | `a3`〜`a6`, `b4`〜`b6` |
| `fontsize` | `10pt` | 基準文字サイズ |
| `seriffont` | `New Computer Modern` | 欧文明朝（`mainfont` でも可） |
| `seriffont-cjk` | `Harano Aji Mincho` | 和文明朝（`CJKmainfont` でも可） |
| `sansfont` | `Source Sans Pro` | 欧文ゴシック |
| `sansfont-cjk` | `Harano Aji Gothic` | 和文ゴシック（`CJKsansfont` でも可） |
| `baselineskip` | `auto` | 行送り。`auto` は `1.73 × fontsize` |
| `textwidth` | `auto` | 版面幅。段間 2em を含む |
| `lines-per-page` | `auto` | 1 ページの行数 |
| `columns` | `1` | 段組の段数 |
| `cjkheight` | `0.88` | 和文の高さ（em 単位）。ベースライン位置の調整用 |
| `mathfont` / `codefont` | なし | 数式・コードのフォント |

`jsarticle-typst` のみ:

| キー | 既定値 | 説明 |
|:--|:--|:--|
| `book` | `false` | `true` で jsbook 風レイアウト（簡易版。書籍は `jsbook-typst` 推奨） |

`jsbook-typst` のみ:

| キー | 既定値 | 説明 |
|:--|:--|:--|
| `frontmatter` | `true` | 前付をローマ数字にし、本文で 1 から数え直す |
| `chapter-prefix` / `chapter-suffix` | `第` / `章` | 章扉と柱の章表記 |
| `appendix-prefix` / `appendix-suffix` | `付録` / （空） | 付録の章表記 |
| `part-prefix` / `part-suffix` | `第` / `部` | 部扉と目次の部表記 |

Quarto 標準のオプション（`toc`, `number-sections`, `section-numbering`,
`page-numbering`, `linkcolor`, `citecolor`, `filecolor`, `keywords`,
`bibliography`, `csl` など）もそのまま使えます。

フォーマット既定として `lang: ja`、`number-sections: true`、
`section-numbering: "1.1.1"` を設定しています。jsarticle / jsbook と同じく節に
番号が付き、図表・数式の参照は「図 1」「表 1」「式 1」になります。

### `js` パッケージのマクロ

テンプレートが `@preview/js` を `#import ...: *` で読み込むため、本文中で
raw Typst として次のマクロが使えます。

- `#ruby[科][か]` — ルビ
- `#kintou(5em)[超電磁砲]` — 均等割り
- `#noindent[...]` — 字下げなし
- `#TeX`, `#LaTeX`

## 設計メモ

Quarto の Typst パイプラインとの接続で、`js` の既定から変更している点です。

1. **`set ref(supplement: auto)` に戻す** — `js` は `supplement: none` を設定
   しますが、これを残すと相互参照から「図」「表」の接頭辞が消えます。
2. **タイトルブロック / 扉を自前で持つ** — `js` の `maketitle` は subtitle や
   `abstract-title` を受け取らないため、同じ見た目のものをテンプレート側に置いています。
3. **`page.typ` パーシャルを無効化** — 版面は `js` が
   `papersize` / `fontsize` / `baselineskip` から決めるので、Quarto 既定の
   `us-letter` / `1.25in` が干渉しないようにしています。
4. **jsbook はレベル 1 見出しと柱を自前で描く** — `js` の `book: true` は章見出しを
   「第 N 章」に固定しており、部・付録を表現できないためです。レベル 2 以降の
   見出し・行送り・字送り・和欧混植は `js` のものをそのまま使っています。

`js` パッケージ本体は各拡張の `typst/packages/` に
`quarto call typst-gather` で同梱してあり、オフラインでもバージョン固定で
レンダリングできます。

## 既知の制限

- 章起こしで生じる空白ページにも柱が入ります（LaTeX の `\cleardoublepage` は
  `empty` ページスタイルにします）。Typst 側にページが空かを判定する手段が無いためです。
- 目次の付録は「A 記号一覧」と出ます（「付録 A 記号一覧」ではありません）。
- `js` は Typst 0.13 以降が前提です。Quarto 1.10 同梱の Typst 0.15 で動作を確認しています。

## テスト

- [tests/book/](tests/book/) — 部・付録・引用・章ごとの図番号を含む Quarto Book
- [tests/jsbook-single.qmd](tests/jsbook-single.qmd) — book プロジェクトでない `jsbook-typst`
- [tests/book-mode.qmd](tests/book-mode.qmd) — `jsarticle-typst` の `book: true`
- [template.qmd](template.qmd) — `jsarticle-typst` のデモ

## ロードマップ

- [x] `jsarticle-typst`（記事）
- [x] `jsbook-typst`（Quarto Book。部・付録・前付/本文の切り替え・柱）
- [ ] 図目次・表目次（`lof` / `lot`）
- [ ] 索引（`makeidx` 相当）
- [ ] `js` に依存しない独自実装への移行の検討

## ライセンス

MIT License. 同梱している `js` パッケージは MIT-0 (Haruhiko Okumura) です。
