-- js-macros.lua
-- Spans and divs that map onto the macros of the `js` Typst package, in the
-- spirit of christopherkenny/typst-function: the class names the macro and
-- `argument` carries what does not fit in the body.
--
--   [科]{.ruby argument="か"}          -> #ruby[科][か]
--   [超電磁砲]{.kintou argument="5em"} -> #kintou(5em)[超電磁砲]
--   ::: {.noindent} ... :::            -> #noindent[...]
--
-- Outside of Typst they fall back to the HTML equivalent where there is one,
-- and to the plain body otherwise, so the same source renders everywhere.

local function argument_of(el)
  local value = el.attributes["argument"] or el.attributes["arguments"]
  if value == nil or value == "" then
    return nil
  end
  return value
end

-- `ruby` and `kintou` read the `.text` field of what they are given, so the
-- body has to reach them as a single text element. Markup with escapes
-- (`C\#`) is a sequence and would fail, hence the detour through a Typst
-- string literal: `[#"C#"]` is one text element whatever the characters are.
local function typst_text(s)
  return '[#"' .. s:gsub("[\\\"]", "\\%0") .. '"]'
end

local function html_escape(s)
  return (s:gsub("[&<>\"]", {
    ["&"] = "&amp;",
    ["<"] = "&lt;",
    [">"] = "&gt;",
    ['"'] = "&quot;",
  }))
end

local function warn_missing(class, hint)
  quarto.log.warning("A ." .. class .. " span needs an argument, e.g. " .. hint)
end

-- [科]{.ruby argument="か"} -> #ruby[科][か]
-- Group ruby: the reading is spread over the whole body, as in `js`.
local function ruby(el)
  local base = pandoc.utils.stringify(el.content)
  local reading = argument_of(el)
  if reading == nil then
    warn_missing("ruby", '[科]{.ruby argument="か"}')
    return el.content
  end

  if quarto.doc.is_format("typst") then
    return pandoc.RawInline("typst", "#ruby" .. typst_text(base) .. typst_text(reading))
  elseif quarto.doc.is_format("html") then
    return pandoc.RawInline(
      "html",
      "<ruby>"
        .. html_escape(base)
        .. "<rp>(</rp><rt>"
        .. html_escape(reading)
        .. "</rt><rp>)</rp></ruby>"
    )
  end
  -- No ruby in the target format: the reading is a pronunciation aid, so
  -- dropping it leaves the sentence intact.
  return el.content
end

-- [超電磁砲]{.kintou argument="5em"} -> #kintou(5em)[超電磁砲]
local function kintou(el)
  local body = pandoc.utils.stringify(el.content)
  local width = argument_of(el)
  if width == nil then
    warn_missing("kintou", '[超電磁砲]{.kintou argument="5em"}')
    return el.content
  end

  if quarto.doc.is_format("typst") then
    -- The width is a Typst length, so it goes in as code rather than text.
    return pandoc.RawInline("typst", "#kintou(" .. width .. ")" .. typst_text(body))
  elseif quarto.doc.is_format("html") then
    return pandoc.RawInline(
      "html",
      '<span style="display: inline-block; width: '
        .. html_escape(width)
        .. '; text-align: justify; text-align-last: justify;">'
        .. html_escape(body)
        .. "</span>"
    )
  end
  return el.content
end

-- Typst cannot carry a paragraph across block math (typst/typst#3206): the
-- text after `$ ... $` is typeset as a fresh paragraph, and with the
-- all-paragraphs first-line indent of `js` it gains a 1em indent that the
-- LaTeX classes would not give it. Pandoc still keeps such a continuation
-- (no blank line after the closing `$$`) in the same Para as the math, so
-- the LaTeX semantics can be read off the AST: wrap the continuation in
-- `#noindent[...]`. Text after a blank line arrives as its own Para and
-- keeps its indent, as in LaTeX. An item of a tight list holds its text in
-- a Plain instead of a Para, and the continuation there is indented in the
-- same way, so both are handled.
--
-- By the post-quarto stage a labeled equation is no longer a bare Math: the
-- crossref filter has bracketed it as
--   RawInline "#math.equation(block: true, ..., ["  Math  RawInline " ])<eq-..>"
-- so that whole cluster has to be treated as one display-math unit, or the
-- `#noindent[` would land inside the wrapper and unbalance its delimiters.
local function is_display_math(inline)
  return inline.t == "Math" and inline.mathtype == "DisplayMath"
end

local function is_typst_raw(inline, pattern)
  return inline.t == "RawInline"
    and (inline.format == "typst" or inline.format == "typst-text")
    and inline.text:match(pattern) ~= nil
end

local function is_equation_open(inline)
  return is_typst_raw(inline, "^#math%.equation%(block: true")
end

local function is_equation_close(inline)
  return is_typst_raw(inline, "^%s*%]%)")
end

local function is_inline_space(inline)
  return inline.t == "Space" or inline.t == "SoftBreak" or inline.t == "LineBreak"
end

local function unindent_math_continuations(el)
  local content = el.content
  local result = pandoc.List()
  local open = false
  local changed = false
  local i = 1

  while i <= #content do
    local inline = content[i]
    if is_display_math(inline) or is_equation_open(inline) then
      -- Between two display maths the bracket has to close and reopen so
      -- that the math itself stays at the top level of the paragraph.
      if open then
        result:insert(pandoc.RawInline("typst", "]"))
        open = false
      end
      if is_equation_open(inline) then
        -- Copy the crossref wrapper through to its closing raw.
        repeat
          result:insert(content[i])
          i = i + 1
        until i > #content or is_equation_close(content[i - 1])
      else
        result:insert(inline)
        i = i + 1
      end
      while i <= #content and is_inline_space(content[i]) do
        result:insert(content[i])
        i = i + 1
      end
      if
        i <= #content
        and not is_display_math(content[i])
        and not is_equation_open(content[i])
      then
        result:insert(pandoc.RawInline("typst", "#noindent["))
        open = true
        changed = true
      end
    else
      result:insert(inline)
      i = i + 1
    end
  end

  if open then
    result:insert(pandoc.RawInline("typst", "]"))
  end

  if changed then
    el.content = result
    return el
  end
  return nil
end

return {
  Span = function(el)
    if el.classes:includes("ruby") then
      return ruby(el)
    elseif el.classes:includes("kintou") then
      return kintou(el)
    end
    return nil
  end,

  -- `#noindent[...]` turns off the one-em first-line indent for the
  -- paragraphs it wraps. Other formats keep the div, so it can be styled by
  -- class.
  Div = function(el)
    if not el.classes:includes("noindent") or not quarto.doc.is_format("typst") then
      return nil
    end

    local blocks = pandoc.List({ pandoc.RawBlock("typst", "#noindent[") })
    blocks:extend(el.content)
    blocks:insert(pandoc.RawBlock("typst", "]"))
    return blocks
  end,

  Para = function(el)
    if not quarto.doc.is_format("typst") then
      return nil
    end
    return unindent_math_continuations(el)
  end,

  Plain = function(el)
    if not quarto.doc.is_format("typst") then
      return nil
    end
    return unindent_math_continuations(el)
  end,
}
