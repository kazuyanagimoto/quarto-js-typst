-- js-noindent.lua
-- `::: {.noindent}` becomes `#noindent[...]`, the `js` macro that turns off
-- the one-em first-line indent for the paragraphs it wraps. In every other
-- format the div is left alone, so it can still be styled by class.

return {
  Div = function(el)
    if not el.classes:includes("noindent") or not quarto.doc.is_format("typst") then
      return nil
    end

    local blocks = pandoc.List({ pandoc.RawBlock("typst", "#noindent[") })
    blocks:extend(el.content)
    blocks:insert(pandoc.RawBlock("typst", "]"))
    return blocks
  end,
}
