return {
  -- Override NvChad's nvim-tree config to auto-resize sidebar width
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      view = {
        adaptive_size = true,
      },
    },
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- enable format on save
    opts = require "configs.conform",
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- TypeScript Tools (replaces typescript-language-server)
  {
    "pmizio/typescript-tools.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("typescript-tools").setup(require "configs.typescript-tools")
    end,
  },

  -- Auto close and rename HTML/JSX tags
  {
    "windwp/nvim-ts-autotag",
    ft = {
      "html",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "vue",
      "svelte",
      "astro",
      "xml",
      "php",
      "markdown",
      "mdx",
    },
    config = function()
      require "configs.nvim-ts-autotag"
    end,
  },

  -- VS Code-style pictograms for completion
  {
    "onsails/lspkind.nvim",
    config = function()
      require "configs.lspkind"
    end,
  },

  -- JSON schemas for better JSON LSP support
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },

  -- Diffview: file/branch git history and diffs
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Lazygit integration
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    init = function()
      -- Enable neovim-remote (nvr) integration
      -- This allows lazygit to open files in the existing nvim instance
      vim.g.lazygit_use_neovim_remote = 1
    end,
  },

  -- Treesitter with auto-install for web languages
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        -- Neovim
        "vim",
        "lua",
        "vimdoc",
        -- Web Development
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "astro",
        "json",
        "markdown",
        "markdown_inline",
        -- Python
        "python",
        -- LaTeX
        "latex",
        -- Additional useful parsers
        "bash",
        "gitignore",
      },
    },
  },

  -- Multiple cursors (like VSCode Cmd+D / Cmd+Shift+L)
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
  },

  -- GitHub Copilot
  {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
      -- Disable default Tab mapping
      vim.g.copilot_no_tab_map = true
      -- Map Shift-Tab to accept suggestion
      vim.keymap.set("i", "<S-Tab>", 'copilot#Accept("<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "Copilot accept",
      })
    end,
  },

  -- Snacks.nvim - UI components
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      input = {},
      picker = {},
      terminal = {},
    },
  },

  -- OpenCode AI Assistant
  {
    "NickvanDyke/opencode.nvim",
    lazy = false,
    priority = 900,
    dependencies = {
      "folke/snacks.nvim",
    },
    init = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- Default configuration works well
      }

      -- Required for automatic buffer reloading when opencode edits files
      vim.o.autoread = true
    end,
    config = function()
      local opencode = require "opencode"

      -- Keymaps
      -- Ask opencode with context
      vim.keymap.set({ "n", "x" }, "<C-a>", function()
        opencode.ask("@this: ", { submit = true })
      end, { desc = "Ask opencode" })

      -- Execute opencode actions (select from menu)
      vim.keymap.set({ "n", "x" }, "<C-x>", function()
        opencode.select()
      end, { desc = "Execute opencode action…" })

      -- Toggle opencode terminal
      vim.keymap.set({ "n", "t" }, "<C-.>", function()
        opencode.toggle()
      end, { desc = "Toggle opencode" })

      -- Operator for adding ranges to opencode
      vim.keymap.set({ "n", "x" }, "go", function()
        return opencode.operator "@this "
      end, { expr = true, desc = "Add range to opencode" })

      vim.keymap.set("n", "goo", function()
        return opencode.operator "@this " .. "_"
      end, { expr = true, desc = "Add line to opencode" })

      -- Scroll opencode output
      vim.keymap.set("n", "<S-C-u>", function()
        opencode.command "session.half.page.up"
      end, { desc = "opencode half page up" })

      vim.keymap.set("n", "<S-C-d>", function()
        opencode.command "session.half.page.down"
      end, { desc = "opencode half page down" })

      -- Remap increment/decrement since we're using <C-a> and <C-x>
      vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
      vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
    end,
  },

  -- LaTeX support with VimTeX
  {
    "lervag/vimtex",
    ft = "tex",
    init = function()
      -- Must be set BEFORE plugin loads
      vim.g.vimtex_compiler_enabled = 0
    end,
    config = function()
      require "configs.vimtex"
    end,
  },

  -- Spell checking with cspell (VSCode Code Spell Checker equivalent)
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "davidmh/cspell.nvim",
    },
    config = function()
      require "configs.none-ls"
    end,
  },

  -- Surround selections (add/delete/change surrounding pairs)
  {
    "kylechui/nvim-surround",
    version = "^3.0.0",
    event = "VeryLazy",
    opts = {},
  },

  -- Big file performance optimization
  {
    "LunarVim/bigfile.nvim",
    lazy = false,
    opts = {
      filesize = 0.5, -- 500KB in MiB
      features = {
        "indent_blankline",
        "illuminate",
        "lsp",
        "treesitter",
        "syntax",
        "matchparen",
        "vimopts",
        "filetype",
      },
    },
  },

  -- Snippet engine for LaTeX snippets
  {
    "L3MON4D3/LuaSnip",
    lazy = false,
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      local luasnip = require "luasnip"

      -- Load VSCode-style snippets from friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      -- Load custom LaTeX snippets
      require("luasnip.loaders.from_lua").lazy_load { paths = vim.fn.stdpath "config" .. "/lua/snippets" }

      -- Configure LuaSnip
      luasnip.config.set_config {
        history = true,
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true,
      }

      -- Keymaps for snippet navigation
      vim.keymap.set({ "i", "s" }, "<C-k>", function()
        if luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        end
      end, { desc = "Expand snippet or jump forward", silent = true })

      vim.keymap.set({ "i", "s" }, "<C-j>", function()
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        end
      end, { desc = "Jump backward in snippet", silent = true })
    end,
  },
}
