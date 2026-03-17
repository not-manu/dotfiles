local options = {
  opts = {
    -- Defaults
    enable_close = true, -- Auto close tags
    enable_rename = true, -- Auto rename pairs of tags
    enable_close_on_slash = false, -- Auto close on trailing </
  },
  -- Also override individual filetype configs, these take priority.
  -- Empty by default, useful if one of the "opts" global settings
  -- doesn't work well in a specific filetype
  per_filetype = {
    -- You can add per-filetype overrides here if needed
    -- ["html"] = {
    --   enable_close = false
    -- }
  },
}

require("nvim-ts-autotag").setup(options)
