return {
  -- fff.nvim — frecency-ranked, typo-resistant file index (used by filemention)
  {
    "dmtrKovalenko/fff.nvim",
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    lazy = false,
    opts = {},
  },

  -- filemention.nvim — @file mentions via completion
  {
    "not-manu/filemention.nvim",
    event = "InsertEnter",
    branch = "dev",
    dependencies = { "dmtrKovalenko/fff.nvim" },
    config = function(_, opts)
      require("filemention").setup(opts)
    end,
  },

  -- Add filemention as a cmp source
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "not-manu/filemention.nvim" },
    opts = function(_, opts)
      local cmp = require "cmp"
      opts.sources = opts.sources or {}
      table.insert(opts.sources, 1, { name = "filemention" })

      opts.mapping = opts.mapping or {}
      opts.mapping["<C-j>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end, { "i", "s" })
      opts.mapping["<C-k>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { "i", "s" })

      return opts
    end,
  },

  -- Override NvChad's nvim-tree config to auto-resize sidebar width
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      view = {
        adaptive_size = true,
      },
      auto_reload_on_write = true,
      filesystem_watchers = {
        enable = true,
        debounce_delay = 50,
      },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)
      local api = require "nvim-tree.api"
      vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
        callback = function()
          if package.loaded["nvim-tree"] then
            pcall(api.tree.reload)
          end
        end,
      })
    end,
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

  -- Telescope: add <C-j>/<C-k> to navigate results like fzf
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, conf)
      local actions = require "telescope.actions"
      conf.defaults = conf.defaults or {}
      conf.defaults.mappings = vim.tbl_deep_extend("force", conf.defaults.mappings or {}, {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
        },
      })
      return conf
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

  -- Persist editor state (buffers, layout) per project directory
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" },
    },
    init = function()
      -- Auto-restore session when nvim is opened with no arguments in a dir
      vim.api.nvim_create_autocmd("VimEnter", {
        nested = true,
        callback = function()
          if vim.fn.argc() == 0 and vim.fn.line2byte "$" == -1 then
            require("persistence").load()
          end
        end,
      })
    end,
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
