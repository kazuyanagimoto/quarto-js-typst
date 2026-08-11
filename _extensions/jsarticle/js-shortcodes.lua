-- js-shortcodes.lua
-- Quarto shortcodes for the inline macros of the `js` Typst package:
-- ruby, kintou, TeX and LaTeX. Outside of Typst they fall back to the HTML
-- or LaTeX equivalent where there is one, and to plain text otherwise, so
-- that the same source renders in every format.

local function text_of(arg)
  if arg == nil then
    return nil
  end
  local s = pandoc.utils.stringify(arg)
  if s == "" then
    return nil
  end
  return s
end

-- `ruby` and `kintou` read the `.text` field of what they are given, so the
-- argument has to be a single text element. Markup with escapes (`C\#`) is a
-- sequence and would fail, hence the detour through a Typst string literal:
-- `[#"C#"]` is one text element whatever the characters are.
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

local function typst_raw(s)
  return pandoc.RawInline("typst", s)
end

local function html_raw(s)
  return pandoc.RawInline("html", s)
end

local function usage(name, hint)
  quarto.log.warning("The " .. name .. " shortcode expects " .. hint)
  return pandoc.Inlines({})
end

-- {{< ruby 科 か >}} -> #ruby[科][か]
-- Group ruby: the reading is spread over the whole base, as in `js`.
local function ruby(args)
  local base = text_of(args[1])
  local reading = text_of(args[2])
  if base == nil or reading == nil then
    return usage("ruby", "two arguments, e.g. {{< ruby 科 か >}}")
  end

  if quarto.doc.is_format("typst") then
    return typst_raw("#ruby" .. typst_text(base) .. typst_text(reading))
  elseif quarto.doc.is_format("html") then
    return html_raw(
      "<ruby>"
        .. html_escape(base)
        .. "<rp>(</rp><rt>"
        .. html_escape(reading)
        .. "</rt><rp>)</rp></ruby>"
    )
  end
  -- No ruby in the target format: the reading is a pronunciation aid, so
  -- dropping it leaves the sentence intact.
  return pandoc.Str(base)
end

-- {{< kintou 5em 超電磁砲 >}} -> #kintou(5em)[超電磁砲]
local function kintou(args)
  local width = text_of(args[1])
  local body = text_of(args[2])
  if width == nil or body == nil then
    return usage("kintou", "a width and a body, e.g. {{< kintou 5em 超電磁砲 >}}")
  end

  if quarto.doc.is_format("typst") then
    return typst_raw("#kintou(" .. width .. ")" .. typst_text(body))
  elseif quarto.doc.is_format("html") then
    return html_raw(
      '<span style="display: inline-block; width: '
        .. html_escape(width)
        .. '; text-align: justify; text-align-last: justify;">'
        .. html_escape(body)
        .. "</span>"
    )
  end
  return pandoc.Str(body)
end

local function logo(typst_macro, latex_macro, plain)
  return function()
    if quarto.doc.is_format("typst") then
      return typst_raw("#" .. typst_macro)
    elseif quarto.doc.is_format("latex") then
      return pandoc.RawInline("tex", latex_macro .. "{}")
    end
    return pandoc.Str(plain)
  end
end

local tex = logo("TeX", "\\TeX", "TeX")
local latex = logo("LaTeX", "\\LaTeX", "LaTeX")

return {
  ["ruby"] = ruby,
  ["kintou"] = kintou,
  ["tex"] = tex,
  ["TeX"] = tex,
  ["latex"] = latex,
  ["LaTeX"] = latex,
}
