local web_filetypes = {
  "css",
  "html",
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "json",
  "jsonc",
  "astro",
  "mdx",
  "yaml",
  "graphql",
  "scss",
  "less",
}

local biome_filetypes = {
  css = true,
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
  json = true,
  jsonc = true,
  graphql = true,
}

local fallback_biome_config = vim.fn.expand "~/Documents/projects/not-manu/vactu/biome.json"

local function has_biome_config(bufnr)
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  if dir == "" then
    return false
  end
  local found = vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true, path = dir })
  return #found > 0
end

local formatters_by_ft = {
  lua = { "stylua" },
  python = { "ruff_format" },
}

for _, ft in ipairs(web_filetypes) do
  formatters_by_ft[ft] = function(bufnr)
    if biome_filetypes[ft] then
      if has_biome_config(bufnr) then
        return { "biome" }
      end
      if vim.fn.executable "biome" == 1 and vim.fn.filereadable(fallback_biome_config) == 1 then
        return { "biome_fallback" }
      end
    end
    return { "prettier" }
  end
end

return {
  formatters_by_ft = formatters_by_ft,
  formatters = {
    biome_fallback = {
      command = "biome",
      stdin = true,
      args = function(_, ctx)
        return {
          "format",
          "--config-path",
          fallback_biome_config,
          "--stdin-file-path",
          ctx.filename,
        }
      end,
    },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}
