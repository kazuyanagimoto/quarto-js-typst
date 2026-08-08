// jsarticle for Quarto/Typst
//
// The heavy lifting (baseline grid, text block, heading spacing, CJK font
// covers) comes from Haruhiko Okumura's `js` package, which is a Typst port of
// the LaTeX jsarticle/jsbook classes. This partial only
//   1. adapts Quarto's metadata to the `js` function's arguments,
//   2. re-implements the title block so that Quarto's subtitle / abstract-title
//      / thanks metadata is honoured, and
//   3. undoes the few `js` defaults that conflict with Quarto's Lua filters
//      (notably `set ref(supplement: none)`, which would strip the "図"/"表"
//      prefix from every crossref).
#import "@preview/js:0.1.3": *

// ---------------------------------------------------------------- utilities

// Flatten content to a plain string. Quarto's `content-to-string` returns
// `none` for empty content, which makes `.trim()` fail, so use our own.
#let _to-str(it) = {
  if it == none {
    ""
  } else if type(it) == str {
    it
  } else if type(it) == content {
    if it.has("text") {
      _to-str(it.text)
    } else if it.has("children") {
      it.children.map(_to-str).fold("", (a, b) => a + b)
    } else if it.has("body") {
      _to-str(it.body)
    } else {
      ""
    }
  } else {
    str(it)
  }
}

#let _blank(it) = _to-str(it).trim() == ""

// Quarto hands us (name, affiliation, email) dictionaries; `js` wants either a
// bare name or an array of lines that `boxtable` stacks under each other.
#let _js-author(author) = {
  let lines = ("name", "affiliation", "email")
    .map(k => author.at(k, default: none))
    .filter(v => not _blank(v))
  if lines.len() == 0 { none } else if lines.len() == 1 { lines.first() } else { lines }
}

#let _color(value) = if value == none { none } else { rgb(_to-str(value)) }

// ------------------------------------------------------------- title block

#let js-title-block(
  title: none,
  subtitle: none,
  authors: (),
  date: none,
  abstract: none,
  abstract-title: none,
  thanks: none,
) = {
  let has-any = (
    title != none or subtitle != none or authors.len() > 0 or date != none or abstract != none
  )
  if not has-any { return }

  place(top + center, scope: "parent", float: true, clearance: 2em)[
    #set align(center)
    #set par(first-line-indent: 0em, justify: false)
    #v(2em)
    #if title != none {
      text(1.7em)[#title#if thanks != none {
        footnote(thanks, numbering: "*")
        counter(footnote).update(n => n - 1)
      }]
    }
    #if subtitle != none {
      linebreak()
      v(0.4em)
      text(1.25em, subtitle)
    }
    #if authors.len() > 0 {
      v(1.5em)
      pad(x: 2em, authors.map(boxtable).join("      "))
    }
    #if date != none {
      v(1em)
      date
    }
    #if abstract != none {
      v(1.5em)
      block(width: 90%)[
        #set text(0.9em)
        #if abstract-title != none { emph(abstract-title) }
        #align(left, abstract)
      ]
    }
    #v(1.5em)
  ]
}

// ------------------------------------------------------------------ article

#let article(
  title: none,
  subtitle: none,
  authors: (),
  date: none,
  abstract: none,
  abstract-title: none,
  keywords: (),
  thanks: none,
  lang: "ja",
  region: "JP",
  paper: "a4",
  fontsize: 10pt,
  seriffont: "New Computer Modern",
  seriffont-cjk: "Harano Aji Mincho",
  sansfont: "Source Sans Pro",
  sansfont-cjk: "Harano Aji Gothic",
  mathfont: none,
  codefont: none,
  baselineskip: auto,
  textwidth: auto,
  lines-per-page: auto,
  cols: 1,
  book: false,
  cjkheight: 0.88,
  non-cjk: auto,
  sectionnumbering: none,
  page-numbering: "1",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: auto,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  doc,
) = {
  let js-authors = authors.map(_js-author).filter(a => a != none)

  set document(
    title: _to-str(title),
    keywords: keywords,
  )
  set document(
    author: js-authors.map(array2text).map(_to-str),
  ) if js-authors.len() > 0

  let js-args = (
    lang: lang,
    seriffont: seriffont,
    seriffont-cjk: seriffont-cjk,
    sansfont: sansfont,
    sansfont-cjk: sansfont-cjk,
    paper: paper,
    fontsize: fontsize,
    baselineskip: baselineskip,
    textwidth: textwidth,
    lines-per-page: lines-per-page,
    book: book,
    cols: cols,
    cjkheight: cjkheight,
  )
  if non-cjk != auto {
    js-args.insert("non-cjk", non-cjk)
  }

  js(
    ..js-args,
    {
      // --- Quarto compatibility fixes, applied after `js`'s own rules -------
      set text(region: region)
      set page(numbering: page-numbering)
      set heading(numbering: sectionnumbering)
      // `js` sets `supplement: none`; Quarto needs the 図/表/式 prefixes back.
      set ref(supplement: auto)

      show math.equation: set text(font: mathfont) if mathfont != none
      show raw: set text(font: codefont) if codefont != none

      show link: set text(fill: _color(linkcolor)) if linkcolor != none
      show ref: set text(fill: _color(citecolor)) if citecolor != none
      show link: it => {
        if filecolor != none and type(it.dest) == label {
          text(it, fill: _color(filecolor))
        } else {
          text(it)
        }
      }

      js-title-block(
        title: title,
        subtitle: subtitle,
        authors: js-authors,
        date: date,
        abstract: abstract,
        abstract-title: abstract-title,
        thanks: thanks,
      )

      if toc {
        outline(
          title: if toc_title == none { auto } else { toc_title },
          depth: toc_depth,
          indent: toc_indent,
        )
        v(1em)
      }

      doc
    },
  )
}
