require("nvchad.configs.lspconfig").defaults()

-- Override gd to use Telescope after all LspAttach handlers have run
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.schedule(function()
      vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", { buffer = args.buf, desc = "LSP Go to definition" })
    end)
  end,
})

-- LSP servers to enable
-- Note: typescript-tools.nvim handles TypeScript/JavaScript instead of tsserver
local servers = { "html", "cssls", "tailwindcss", "jsonls", "texlab", "basedpyright", "astro", "mdx_analyzer" }
vim.lsp.enable(servers)

-- Optional: Configure specific LSP servers
-- Tailwind CSS configuration
vim.lsp.config("tailwindcss", {
  -- Tailwind CSS will auto-detect project roots with tailwind.config.js/ts
  -- You can customize settings here if needed
  settings = {
    tailwindCSS = {
      experimental = {
        classRegex = {
          -- Add support for various class attribute patterns
          { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
          { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
        },
      },
    },
  },
})

-- JSON configuration with schema support
vim.lsp.config("jsonls", {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
})

-- Astro LSP configuration
vim.lsp.config("astro", {
  cmd = { "astro-ls", "--stdio" },
  filetypes = { "astro" },
  init_options = {
    typescript = {},
  },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
})

-- LaTeX LSP configuration
vim.lsp.config("texlab", {
  settings = {
    texlab = {
      build = {
        executable = "tectonic",
        args = { "-X", "compile", "%f", "--synctex", "--keep-logs" },
        onSave = false,
        forwardSearchAfter = false,
      },
      chktex = {
        onOpenAndSave = true,
        onEdit = false,
      },
      forwardSearch = {
        executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
        args = { "-r", "%l", "%p", "%f" },
      },
    },
  },
})

-- MDX analyzer configuration
vim.lsp.config("mdx_analyzer", {
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  init_options = {
    typescript = {
      tsdk = vim.fn.stdpath("data") .. "/mason/packages/typescript-language-server/node_modules/typescript/lib",
    },
  },
})

-- read :h vim.lsp.config for changing options of lsp servers
