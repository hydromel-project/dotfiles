-- Custom PHP snippets for function calls with parameters
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- Common PHP function patterns
  s("func", {
    i(1, "functionName"),
    t("("),
    i(2, "param1"),
    t(", "),
    i(3, "param2"),
    t(")"),
    i(0)
  }),
  
  -- Array functions
  s("array_map", {
    t("array_map("),
    i(1, "callback"),
    t(", "),
    i(2, "array"),
    t(")"),
    i(0)
  }),
  
  s("array_filter", {
    t("array_filter("),
    i(1, "array"),
    t(", "),
    i(2, "callback"),
    t(")"),
    i(0)
  }),
  
  -- Common Laravel patterns
  s("dd", {
    t("dd("),
    i(1, "variable"),
    t(")"),
    i(0)
  }),
}