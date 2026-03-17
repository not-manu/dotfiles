local null_ls = require("null-ls")
local cspell = require("cspell")

-- cspell configuration
local cspell_config = {
  -- Find cspell.json in project root or use global config
  find_json = function(cwd)
    -- Look for project-level cspell config (similar to .vscode/cspell.json)
    local project_configs = {
      cwd .. "/cspell.json",
      cwd .. "/.cspell.json",
      cwd .. "/cspell.config.json",
      cwd .. "/.vscode/cspell.json",
    }

    for _, path in ipairs(project_configs) do
      if vim.fn.filereadable(path) == 1 then
        return path
      end
    end

    -- Fall back to global config
    return vim.fn.expand("~/.config/cspell/cspell.json")
  end,

  -- Diagnostic severity (use HINT for less intrusive, INFO, WARN, or ERROR for more visible)
  diagnostic_severity = vim.diagnostic.severity.INFO,

  -- Custom actions for adding words
  on_add_to_json = function(payload)
    -- Notify the user when a word is added
    vim.notify(
      string.format("Added '%s' to %s dictionary", payload.word, payload.dictionary_name or "cspell"),
      vim.log.levels.INFO
    )
  end,

  on_add_to_dictionary = function(payload)
    vim.notify(
      string.format("Added '%s' to %s", payload.word, payload.dictionary_name or "dictionary"),
      vim.log.levels.INFO
    )
  end,
}

null_ls.setup({
  sources = {
    -- cspell diagnostics (shows spelling errors)
    cspell.diagnostics.with({
      config = cspell_config,
      -- Customize which files to check
      filetypes = {
        "markdown",
        "text",
        "gitcommit",
        "typescript",
        "typescriptreact",
        "javascript",
        "javascriptreact",
        "lua",
        "python",
        "html",
        "css",
        "json",
        "yaml",
        "toml",
        "astro",
        "tex",
        "latex",
      },
    }),

    -- cspell code actions (add to dictionary)
    cspell.code_actions.with({
      config = cspell_config,
    }),
  },
})
