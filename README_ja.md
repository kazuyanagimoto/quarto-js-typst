# quarto-js-typst

[English](README.md) | 日本語

LaTeX の `jsarticle` / `jsbook` 相当の版面を Typst で再現する Quarto フォーマットです。
組版の中核には奥村晴彦氏の Typst パッケージ
[`js`](https://github.com/okumuralab/typst-js) を使い、Quarto 側の
メタデータ・相互参照・引用・コードセルをそこに接続しています。

| フォーマット      | 用途                                                                                  |
| :---------------- | :------------------------------------------------------------------------------------ |
| `jsarticle-typst` | 単一の記事・レポート                                                                  |
| `jsbook-typst`    | Quarto Book（Quarto 1.9 以降の単一ファイル Typst book）および単一ファイルの書籍風文書 |

## インストール

```bash
quarto add kazuyanagimoto/quarto-js-typst
```

スターターの `.qmd` ごと取得する場合:

```bash
quarto use template kazuyanagimoto/quarto-js-typst
```

## jsarticle

```yaml
---
title: "タイトル"
author:
  - name: 柳本 和春
    affiliation: 神戸大学
    email: yanagimoto@econ.kobe-u.ac.jp
abstract: |
  概要をここに書きます。
format:
  jsarticle-typst: default
---
```

## jsbook

Quarto Book プロジェクトの `_quarto.yml` でフォーマットに指定します。

```yaml
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
```

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

| キー             | 既定値                | 説明                                            |
| :--------------- | :-------------------- | :---------------------------------------------- |
| `papersize`      | `a4`                  | `a3`〜`a6`, `b4`〜`b6`                          |
| `fontsize`       | `10pt`                | 基準文字サイズ                                  |
| `mainfont`       | `New Computer Modern` | 欧文明朝（別名 `seriffont`）                    |
| `CJKmainfont`    | `Harano Aji Mincho`   | 和文明朝（別名 `seriffont-cjk`）                |
| `sansfont`       | `Source Sans Pro`     | 欧文ゴシック（見出し・強調）                    |
| `CJKsansfont`    | `Harano Aji Gothic`   | 和文ゴシック（別名 `sansfont-cjk`）             |
| `mathfont`       | なし                  | 数式のフォント                                  |
| `codefont`       | なし                  | コードのフォント（別名 `monofont`）             |
| `baselineskip`   | `auto`                | 行送り。`auto` は `1.73 × fontsize`             |
| `textwidth`      | `auto`                | 版面幅。段間 2em を含む                         |
| `lines-per-page` | `auto`                | 1 ページの行数                                  |
| `columns`        | `1`                   | 段組の段数                                      |
| `cjkheight`      | `0.88`                | 和文の高さ（em 単位）。ベースライン位置の調整用 |
| `table-style`    | `booktabs`            | 表の罫線。`booktabs` / `grid` / `plain`         |

フォントのキーは Quarto の Typst フォーマット標準に合わせてあります。欧文は
`mainfont` / `sansfont`、コードは `codefont`（Quarto の Typst 用キー。`monofont`
と書いても同じ）、数式は `mathfont` です。`js` パッケージ側の名前
（`seriffont`, `seriffont-cjk`, `sansfont-cjk`）も別名として受け付けます。

和文と欧文は Typst の `covers` で切り分けているので、欧文フォントに和文が
混ざることはありません。`_brand.yml` のようにフォントを複数指定した場合は、
欧文側のフォールバック列として順に使われます。

### 表の罫線（`table-style`）

| 値                 | 見た目                                                                                                    |
| :----------------- | :-------------------------------------------------------------------------------------------------------- |
| `booktabs`（既定） | 縦罫なし。表の上下に太罫（0.08em）、見出し下に細罫（0.05em）。列間は jsarticle の `\tabcolsep` と同じ 6pt |
| `grid`             | `js` の既定。全セルに 0.04em（= jsarticle の `\arrayrulewidth` 0.4pt 相当）の罫線                         |
| `plain`            | Quarto 標準の Typst と同じ（`inset: 6pt, stroke: none`）。見出し下の罫線だけ                              |

`booktabs` は表を上下の罫線付きブロックで包むだけなので、改ページをまたぐ表でも
各断片の上下に罫が入ります。`#table(stroke: ...)` のように罫線を明示した表
（生の Typst で書いた表など）には手を触れません。

`jsarticle-typst` のみ:

| キー   | 既定値  | 説明                                                                |
| :----- | :------ | :------------------------------------------------------------------ |
| `book` | `false` | `true` で jsbook 風レイアウト（簡易版。書籍は `jsbook-typst` 推奨） |

`jsbook-typst` のみ:

| キー                                  | 既定値          | 説明                                        |
| :------------------------------------ | :-------------- | :------------------------------------------ |
| `frontmatter`                         | `true`          | 前付をローマ数字にし、本文で 1 から数え直す |
| `chapter-prefix` / `chapter-suffix`   | `第` / `章`     | 章扉と柱の章表記                            |
| `appendix-prefix` / `appendix-suffix` | `付録` / （空） | 付録の章表記                                |
| `part-prefix` / `part-suffix`         | `第` / `部`     | 部扉と目次の部表記                          |

Quarto 標準のオプション（`toc`, `number-sections`, `section-numbering`,
`page-numbering`, `linkcolor`, `citecolor`, `filecolor`, `keywords`,
`bibliography`, `csl` など）もそのまま使えます。

フォーマット既定として `lang: ja`、`number-sections: true`、
`section-numbering: "1.1.1"` を設定しています。jsarticle / jsbook と同じく節に
番号が付き、図表・数式の参照は「図 1」「表 1」「式 1」になります。

## `_brand.yml` 対応

プロジェクトに `_brand.yml` があれば、Quarto 標準の Typst フォーマットと同じ
範囲で反映されます。

| brand の項目                                                   | 反映先                                                     |
| :------------------------------------------------------------- | :--------------------------------------------------------- |
| `typography.base.family` / `.size`                             | 本文の欧文フォント・基準文字サイズ（和文は `CJKmainfont`） |
| `typography.headings.family` / `.weight` / `.style` / `.color` | 見出しとタイトル（和文は `CJKsansfont` にフォールバック）  |
| `typography.monospace.family`                                  | コードのフォント                                           |
| `typography.monospace-inline` の太さ・大きさ・色・地色         | インラインコード                                           |
| `color.background` / `color.foreground`                        | ページの地色・文字色（柱の罫線も文字色に追随します）       |
| `color.primary`                                                | リンク色                                                   |

YAML に直接書いたキー（`mainfont`, `fontsize`, `codefont`, `linkcolor` など）は
`_brand.yml` より優先されます。

版面を `js` に任せている都合で、次の項目は反映されません。

- `typography.base.line-height` / `typography.headings.line-height` —
  行送りは `js` のグリッドが決めます。変えたい場合は `baselineskip` を使ってください。
- `typography.base.weight` — 本文の太さは `js` の `450` のままです。
- `typography.monospace-block.background-color` — コードブロックの地色は
  `js` の `luma(240)` のままです。
- `logo` — Quarto 標準の Typst と同じく `_brand.yml` からは自動で入りません。
  YAML に `logo: path/to/logo.png` と書けばページ背景に配置されます。

## `js` のマクロ

`js` の日本語組版マクロは、クラスがマクロ名・`argument` が引数という
[typst-function](https://github.com/christopherkenny/typst-function) 流の
span / div で書けます。ロゴだけは本文を取らないので shortcode です。

| 書き方                               | Typst 出力                                               |
| :----------------------------------- | :------------------------------------------------------- |
| `[科]{.ruby argument="か"}`          | `#ruby[科][か]`（グループルビ）                          |
| `[超電磁砲]{.kintou argument="5em"}` | `#kintou(5em)[超電磁砲]`（均等割り）                     |
| `::: {.noindent}` … `:::`            | `#noindent[…]`（段落の字下げなし）                       |
| `{{< tex >}}` / `{{< latex >}}`      | `#TeX` / `#LaTeX`（`{{< TeX >}}`, `{{< LaTeX >}}` も可） |

`argument` は `arguments` と書いても同じです。`#`, `$`, `@`, `<` などの Typst の
特殊文字はそのまま渡せます（`[C#]{.ruby argument="シャープ"}`）。`.kintou` の
`argument` は Typst の長さ（`5em`, `3cm` など）として解釈されます。

```markdown
::: {.noindent}
この段落は字下げされません。
:::
```

Typst 以外のフォーマットでも壊れないよう、次のようにフォールバックします。

|                 | HTML                                   | LaTeX             | その他          |
| :-------------- | :------------------------------------- | :---------------- | :-------------- |
| `.ruby`         | `<ruby>科<rt>か</rt></ruby>`           | 親文字のみ        | 親文字のみ      |
| `.kintou`       | `text-align-last: justify` の `<span>` | 本文のみ          | 本文のみ        |
| `.noindent`     | div のまま（CSS で指定可）             | div のまま        | div のまま      |
| `tex` / `latex` | `TeX` / `LaTeX`                        | `\TeX` / `\LaTeX` | `TeX` / `LaTeX` |

span / div の変換はフィルタなので、同じ原稿を HTML などでも出す場合は、その
フォーマットでフィルタを有効にしてください（shortcode は指定不要です）。

```yaml
format:
  html:
    filters:
      - jsarticle # jsbook-typst を使っているなら jsbook
  jsarticle-typst: default
```

テンプレートは `@preview/js` を `#import ...: *` で読み込んでいるので、
`#scatter[...]` のような他のマクロは raw Typst として直接書けます。

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
5. **表は既定を booktabs 風にした** — Typst の `table` は既定で全セルに罫線
   （`1pt + black`）を引く仕様で、`js` はそれを `0.04em`（jsarticle の
   `\arrayrulewidth` = 0.4pt 相当）に細くしているだけです。LaTeX の `tabular` は
   `\hline` や `|` を書かない限り罫線を引かないので、全格子は jsarticle 由来では
   ありません。`js` の見た目に戻すには `table-style: grid` を指定してください。

`js` パッケージ本体は同梱しておらず、`@preview/js:0.1.3` として
[Typst Universe](https://typst.app/universe/package/js) から取得します。初回の
レンダリングだけネットワークが必要で、以降は Typst のパッケージキャッシュが
使われます。オフライン環境で使う場合は、拡張のディレクトリで

```bash
cd _extensions/kazuyanagimoto/jsarticle   # jsbook も同様
quarto call typst-gather
```

を実行すると、その拡張の `typst/packages/` にパッケージを取り込めます。

## 既知の制限

- 章起こしで生じる空白ページにも柱が入ります（LaTeX の `\cleardoublepage` は
  `empty` ページスタイルにします）。Typst 側にページが空かを判定する手段が無いためです。
- 目次の付録は「A 記号一覧」と出ます（「付録 A 記号一覧」ではありません）。
- `js` は Typst 0.13 以降が前提です。Quarto 1.10 同梱の Typst 0.15 で動作を確認しています。

## テスト

- [tests/book/](tests/book/) — 部・付録・引用・章ごとの図番号を含む Quarto Book
- [tests/brand/](tests/brand/) — `_brand.yml` のフォント・色の反映
- [tests/macros.qmd](tests/macros.qmd) — ruby / kintou / noindent / TeX の span と shortcode
- [tests/tables.qmd](tests/tables.qmd) — `table-style` の 3 種類（`-M table-style:grid` などで切り替え）
- [tests/jsbook-single.qmd](tests/jsbook-single.qmd) — book プロジェクトでない `jsbook-typst`
- [tests/book-mode.qmd](tests/book-mode.qmd) — `jsarticle-typst` の `book: true`
- [template.qmd](template.qmd) — `jsarticle-typst` のデモ

## ロードマップ

- [x] `jsarticle-typst`（論文）
- [x] `jsbook-typst`（Quarto Book。部・付録・前付/本文の切り替え・柱）
- [ ] 図目次・表目次（`lof` / `lot`）
- [ ] 索引（`makeidx` 相当）

## ライセンス

MIT License（[LICENSE](LICENSE)）。レンダリング時に取得する `js` パッケージは
MIT-0（Haruhiko Okumura）です。
