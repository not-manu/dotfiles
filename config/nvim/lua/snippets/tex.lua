local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

return {
  -- Document structure
  s("doc", fmta([[
    \documentclass{<>}

    \usepackage{<>}

    \title{<>}
    \author{<>}
    \date{<>}

    \begin{document}

    \maketitle

    <>

    \end{document}
  ]], {
    i(1, "article"),
    i(2, "amsmath"),
    i(3, "Title"),
    i(4, "Author"),
    i(5, "\\today"),
    i(0),
  })),

  -- Begin environment
  s("beg", fmta([[
    \begin{<>}
        <>
    \end{<>}
  ]], {
    i(1, "environment"),
    i(0),
    rep(1),
  })),

  -- Inline math
  s("mk", fmta("$<>$", { i(1) })),

  -- Display math
  s("dm", fmta([[
    \[
        <>
    \]
  ]], { i(1) })),

  -- Equation environment
  s("eq", fmta([[
    \begin{equation}
        <>
    \end{equation}
  ]], { i(1) })),

  -- Align environment
  s("ali", fmta([[
    \begin{align}
        <>
    \end{align}
  ]], { i(1) })),

  -- Fraction
  s("frac", fmta("\\frac{<>}{<>}", { i(1), i(2) })),

  -- Sum
  s("sum", fmta("\\sum_{<>}^{<>}", { i(1, "i=1"), i(2, "n") })),

  -- Integral
  s("int", fmta("\\int_{<>}^{<>}", { i(1, "a"), i(2, "b") })),

  -- Limit
  s("lim", fmta("\\lim_{<> \\to <>}", { i(1, "x"), i(2, "\\infty") })),

  -- Section
  s("sec", fmta("\\section{<>}", { i(1) })),

  -- Subsection
  s("ssec", fmta("\\subsection{<>}", { i(1) })),

  -- Subsubsection
  s("sssec", fmta("\\subsubsection{<>}", { i(1) })),

  -- Figure environment
  s("fig", fmta([[
    \begin{figure}[<>]
        \centering
        \includegraphics[width=<>\textwidth]{<>}
        \caption{<>}
        \label{fig:<>}
    \end{figure}
  ]], {
    i(1, "htbp"),
    i(2, "0.8"),
    i(3, "image.pdf"),
    i(4, "Caption"),
    i(5, "label"),
  })),

  -- Table environment
  s("tab", fmta([[
    \begin{table}[<>]
        \centering
        \begin{tabular}{<>}
            \hline
            <>
            \hline
        \end{tabular}
        \caption{<>}
        \label{tab:<>}
    \end{table}
  ]], {
    i(1, "htbp"),
    i(2, "c c c"),
    i(3, "Column 1 & Column 2 & Column 3 \\\\"),
    i(4, "Caption"),
    i(5, "label"),
  })),

  -- Itemize environment
  s("item", fmta([[
    \begin{itemize}
        \item <>
    \end{itemize}
  ]], { i(1) })),

  -- Enumerate environment
  s("enum", fmta([[
    \begin{enumerate}
        \item <>
    \end{enumerate}
  ]], { i(1) })),

  -- Bold text
  s("bf", fmta("\\textbf{<>}", { i(1) })),

  -- Italic text
  s("it", fmta("\\textit{<>}", { i(1) })),

  -- Emphasized text
  s("em", fmta("\\emph{<>}", { i(1) })),

  -- Typewriter text
  s("tt", fmta("\\texttt{<>}", { i(1) })),

  -- Reference
  s("ref", fmta("\\ref{<>}", { i(1) })),

  -- Cite
  s("cite", fmta("\\cite{<>}", { i(1) })),

  -- Label
  s("lab", fmta("\\label{<>}", { i(1) })),

  -- Greek letters (common ones)
  s("alpha", t("\\alpha")),
  s("beta", t("\\beta")),
  s("gamma", t("\\gamma")),
  s("delta", t("\\delta")),
  s("epsilon", t("\\epsilon")),
  s("theta", t("\\theta")),
  s("lambda", t("\\lambda")),
  s("mu", t("\\mu")),
  s("pi", t("\\pi")),
  s("sigma", t("\\sigma")),
  s("phi", t("\\phi")),
  s("omega", t("\\omega")),

  -- Common operators
  s("inf", t("\\infty")),
  s("implies", t("\\implies")),
  s("iff", t("\\iff")),
  s("forall", t("\\forall")),
  s("exists", t("\\exists")),
  s("in", t("\\in")),
  s("subset", t("\\subset")),
  s("cup", t("\\cup")),
  s("cap", t("\\cap")),

  -- Brackets
  s("lr(", fmta("\\left( <> \\right)", { i(1) })),
  s("lr[", fmta("\\left[ <> \\right]", { i(1) })),
  s("lr{", fmta("\\left\\{ <> \\right\\}", { i(1) })),
  s("lr|", fmta("\\left| <> \\right|", { i(1) })),

  -- Matrix
  s("mat", fmta([[
    \begin{<>matrix}
        <>
    \end{<>matrix}
  ]], {
    c(1, { t("p"), t("b"), t("v"), t("B"), t("V"), t("") }),
    i(2),
    rep(1),
  })),
}
