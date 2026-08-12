# quarto-js-typst

English | [日本語](README_ja.md)

Quarto formats that reproduce the page layout of LaTeX's `jsarticle` / `jsbook`
in Typst. The typesetting is done by Haruhiko Okumura's Typst package
[`js`](https://github.com/okumuralab/typst-js); this extension wires Quarto's
metadata, cross-references, citations and code cells into it.

| Format | Use |
|:--|:--|
| `jsarticle-typst` | A single article or report |
| `jsbook-typst` | Quarto Book (the single-file Typst book of Quarto 1.9+) and single-file book-like documents |

## Installation

```bash
quarto add kazuyanagimoto/quarto-js-typst
```

To get the starter `.qmd` as well:

```bash
quarto use template kazuyanagimoto/quarto-js-typst
```

## jsarticle

```yaml
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
```

## jsbook

Set the format in `_quarto.yml` of a Quarto Book project.

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

The jsbook structures that are supported:

- **Title page** — title, subtitle, authors and date on a page of their own.
- **Front matter / main matter** — the title page, the table of contents and
  unnumbered chapters (a preface in `index.qmd`, say) are numbered in lowercase
  roman; the first numbered chapter (or the first part) restarts the count at
  arabic 1. This is LaTeX's `\frontmatter` / `\mainmatter`. Set
  `frontmatter: false` for arabic numbering throughout.
- **Parts** — a `part:` in `book.chapters` becomes a "第 I 部" part page and is
  listed in bold in the table of contents.
- **Appendices** — `book.appendices` switches to the equivalent of `\appendix`:
  chapter headings read "付録 A" and floats, equations and theorems are numbered
  `A.1`. Quarto's synthetic "Appendices" divider heading has no counterpart in
  jsbook, so it is dropped.
- **Running heads** — "第 1 章 章題" on verso pages, "1.1 節題" on recto pages,
  nothing on chapter and part openers, "付録 A" in the appendix.
- **Chapter-scoped numbers** — 図 1.1, 式 (1.1), 定理 1.1. Quarto itself resets
  the counters.

A single `.qmd` with `format: jsbook-typst` works the same way — title page,
table of contents and chapter openers included; the main matter starts at the
first level-1 heading.

## Options

Every argument of the `js` package can be set from YAML, with the defaults of
`js`. These apply to both formats.

| Key | Default | Description |
|:--|:--|:--|
| `papersize` | `a4` | `a3`–`a6`, `b4`–`b6` |
| `fontsize` | `10pt` | Base font size |
| `mainfont` | `New Computer Modern` | Latin serif (alias `seriffont`) |
| `CJKmainfont` | `Harano Aji Mincho` | CJK mincho (alias `seriffont-cjk`) |
| `sansfont` | `Source Sans Pro` | Latin sans (headings and strong) |
| `CJKsansfont` | `Harano Aji Gothic` | CJK gothic (alias `sansfont-cjk`) |
| `mathfont` | none | Font for math |
| `codefont` | none | Font for code (alias `monofont`) |
| `baselineskip` | `auto` | Leading; `auto` is `1.73 × fontsize` |
| `textwidth` | `auto` | Text block width, including the 2em column gutter |
| `lines-per-page` | `auto` | Lines per page |
| `columns` | `1` | Number of columns |
| `cjkheight` | `0.88` | Height of CJK glyphs in em, used to place the baseline |
| `table-style` | `booktabs` | Table rules: `booktabs` / `grid` / `plain` |

The font keys follow Quarto's Typst formats: `mainfont` / `sansfont` for latin,
`codefont` for code (Quarto's Typst-specific key; `monofont` works too) and
`mathfont` for math. The names used by `js` itself (`seriffont`,
`seriffont-cjk`, `sansfont-cjk`) are accepted as aliases.

Latin and CJK are separated with Typst's `covers`, so a latin font is never
asked to render CJK. When several families are given (as `_brand.yml` does),
they are used as the latin fallback chain in order.

### Table rules (`table-style`)

| Value | Look |
|:--|:--|
| `booktabs` (default) | No vertical rules. 0.08em above and below the table, 0.05em under the header. The column inset is 6pt, jsarticle's `\tabcolsep` |
| `grid` | The `js` default: 0.04em on every cell (jsarticle's `\arrayrulewidth`, 0.4pt) |
| `plain` | Same as the stock Quarto Typst format (`inset: 6pt, stroke: none`): the header rule only |

`booktabs` only wraps the table in a block with rules above and below, so a
table that breaks across pages gets them on both sides of the break. Tables with
an explicit stroke (a hand-written Typst table, say) are left alone.

`jsarticle-typst` only:

| Key | Default | Description |
|:--|:--|:--|
| `book` | `false` | `true` for a jsbook-like layout (a simplified one — prefer `jsbook-typst` for books) |

`jsbook-typst` only:

| Key | Default | Description |
|:--|:--|:--|
| `frontmatter` | `true` | Roman numerals in the front matter, restarting at 1 in the main matter |
| `chapter-prefix` / `chapter-suffix` | `第` / `章` | Chapter label on openers and running heads |
| `appendix-prefix` / `appendix-suffix` | `付録` / (empty) | Appendix chapter label |
| `part-prefix` / `part-suffix` | `第` / `部` | Part label on part pages and in the table of contents |

Quarto's own options (`toc`, `number-sections`, `section-numbering`,
`page-numbering`, `linkcolor`, `citecolor`, `filecolor`, `keywords`,
`bibliography`, `csl` and so on) work as usual.

The formats default to `lang: ja`, `number-sections: true` and
`section-numbering: "1.1.1"`, so sections are numbered as in jsarticle / jsbook
and references read 図 1, 表 1, 式 1.

## `_brand.yml` support

A `_brand.yml` in the project is honoured to the same extent as in the stock
Quarto Typst format.

| brand entry | Applied to |
|:--|:--|
| `typography.base.family` / `.size` | Latin body font and base size (CJK stays on `CJKmainfont`) |
| `typography.headings.family` / `.weight` / `.style` / `.color` | Headings and the title (CJK falls back to `CJKsansfont`) |
| `typography.monospace.family` | Font for code |
| `typography.monospace-inline` weight / size / colour / background | Inline code |
| `color.background` / `color.foreground` | Page and text colour (the running-head rule follows the text colour) |
| `color.primary` | Link colour |

Keys written directly in YAML (`mainfont`, `fontsize`, `codefont`, `linkcolor`,
…) take precedence over `_brand.yml`.

Because the page layout is left to `js`, these are not applied:

- `typography.base.line-height` / `typography.headings.line-height` — the
  leading is set by the `js` grid. Use `baselineskip` instead.
- `typography.base.weight` — body weight stays at the `450` of `js`.
- `typography.monospace-block.background-color` — the code block background
  stays at the `luma(240)` of `js`.
- `logo` — as in the stock Quarto Typst format, it is not picked up from
  `_brand.yml`. Write `logo: path/to/logo.png` in YAML to place one in the page
  background.

## The `js` macros

The Japanese typesetting macros of `js` are written as spans and divs in the
style of [typst-function](https://github.com/christopherkenny/typst-function):
the class names the macro and `argument` carries the rest. The logos take no
body, so they are shortcodes.

| Markup | Typst output |
|:--|:--|
| `[科]{.ruby argument="か"}` | `#ruby[科][か]` (group ruby) |
| `[超電磁砲]{.kintou argument="5em"}` | `#kintou(5em)[超電磁砲]` (evenly spread text) |
| `::: {.noindent}` … `:::` | `#noindent[…]` (no first-line indent) |
| `{{< tex >}}` / `{{< latex >}}` | `#TeX` / `#LaTeX` (`{{< TeX >}}`, `{{< LaTeX >}}` work too) |

`argument` can also be spelled `arguments`. Typst's special characters (`#`,
`$`, `@`, `<`, …) can be passed as they are (`[C#]{.ruby argument="シャープ"}`).
The `argument` of `.kintou` is read as a Typst length (`5em`, `3cm`, …).

```markdown
::: {.noindent}
この段落は字下げされません。
:::
```

They fall back so that the same source still renders in other formats:

| | HTML | LaTeX | Other |
|:--|:--|:--|:--|
| `.ruby` | `<ruby>科<rt>か</rt></ruby>` | base text only | base text only |
| `.kintou` | `<span>` with `text-align-last: justify` | body only | body only |
| `.noindent` | the div as-is (style it with CSS) | the div as-is | the div as-is |
| `tex` / `latex` | `TeX` / `LaTeX` | `\TeX` / `\LaTeX` | `TeX` / `LaTeX` |

Spans and divs are converted by a filter, and Quarto only applies a filter to
the format that declares it. So enable it in the other formats you render the
same source to (the shortcodes need no such setup):

```yaml
format:
  html:
    filters:
      - jsarticle # jsbook if you use jsbook-typst
  jsarticle-typst: default
```

The templates import `@preview/js` with `#import ...: *`, so other macros such
as `#scatter[...]` can be written as raw Typst.

## Design notes

What is changed from the `js` defaults to fit Quarto's Typst pipeline:

1. **`set ref(supplement: auto)` is restored** — `js` sets `supplement: none`,
   which would strip the 図 / 表 prefix from every cross-reference.
2. **The title block and title page are our own** — the `maketitle` of `js`
   takes neither a subtitle nor an `abstract-title`, so the templates carry a
   look-alike.
3. **The `page.typ` partial is disabled** — the page geometry is derived by `js`
   from `papersize` / `fontsize` / `baselineskip`, and Quarto's `us-letter` /
   `1.25in` defaults must not interfere.
4. **jsbook draws its own level-1 headings and running heads** — `book: true` in
   `js` hard-codes "第 N 章" chapter headings and cannot express parts or
   appendices. Level-2 and deeper headings, the leading, the letter spacing and
   the latin/CJK mixing are all still those of `js`.
5. **Tables default to a booktabs look** — Typst's `table` draws a full grid by
   default (`1pt + black`) and `js` only thins it to `0.04em` (jsarticle's
   `\arrayrulewidth`, 0.4pt). LaTeX's `tabular` draws nothing unless `\hline` or
   `|` asks for it, so the boxed look does not come from jsarticle. Use
   `table-style: grid` for the `js` look.

The `js` package itself is not vendored: it is fetched from
[Typst Universe](https://typst.app/universe/package/js) as `@preview/js:0.1.3`.
Only the first render needs the network; after that Typst's package cache is
used. For offline use, run this in the extension directory

```bash
cd _extensions/kazuyanagimoto/jsarticle   # likewise for jsbook
quarto call typst-gather
```

to vendor the package into that extension's `typst/packages/`.

## Known limitations

- The blank page a chapter opener creates still carries a running head (LaTeX's
  `\cleardoublepage` switches to the `empty` page style), because Typst has no
  way to tell whether a page is empty.
- Appendices read "A 記号一覧" in the table of contents, not "付録 A 記号一覧".
- `js` requires Typst 0.13 or later. Verified with the Typst 0.15 bundled with
  Quarto 1.10.

## Tests

- [tests/book/](tests/book/) — a Quarto Book with parts, appendices, citations
  and chapter-scoped float numbers
- [tests/brand/](tests/brand/) — fonts and colours from `_brand.yml`
- [tests/macros.qmd](tests/macros.qmd) — the ruby / kintou / noindent / TeX
  spans and shortcodes
- [tests/tables.qmd](tests/tables.qmd) — the three `table-style` values (switch
  with `-M table-style:grid` and so on)
- [tests/jsbook-single.qmd](tests/jsbook-single.qmd) — `jsbook-typst` outside a
  book project
- [tests/book-mode.qmd](tests/book-mode.qmd) — `book: true` in `jsarticle-typst`
- [template.qmd](template.qmd) — the `jsarticle-typst` demo

## Roadmap

- [x] `jsarticle-typst` (articles)
- [x] `jsbook-typst` (Quarto Book: parts, appendices, front/main matter,
      running heads)
- [ ] List of figures and tables (`lof` / `lot`)
- [ ] Index (the equivalent of `makeidx`)

## License

MIT License ([LICENSE](LICENSE)). The `js` package fetched at render time is
MIT-0 (Haruhiko Okumura).
