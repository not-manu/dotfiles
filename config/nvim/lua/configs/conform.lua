local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    -- Web Development
    css = { "prettier" },
    html = { "prettier" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    -- Astro
    astro = { "prettier" },
    -- MDX
    mdx = { "prettier" },
    -- Additional web formats
    yaml = { "prettier" },
    graphql = { "prettier" },
    scss = { "prettier" },
    less = { "prettier" },
    -- Python
    python = { "ruff_format" },
  },

  -- Format on save
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
