-- flexoki-alt: an accurate Flexoki Dark for NvChad/base46
-- Palette + syntax mapping mirrored 1:1 from the official Flexoki VS Code
-- theme (Flexoki-Dark-color-theme.json). https://stephango.com/flexoki

local c = {
  fg = "#CECDC3", -- base-200 (plain text / variables)
  orange = "#DA702C", -- orange-400
  yellow = "#D0A215", -- yellow-400
  green = "#879A39", -- green-400
  cyan = "#3AA99F", -- cyan-400
  blue = "#4385BE", -- blue-400
  purple = "#8B7EC8", -- purple-400
  red = "#D14D41", -- red-400
  magenta = "#CE5D97", -- magenta-400
  comment = "#878580", -- base-500
  doc = "#575653", -- base-700
}

local M = {}

M.base_30 = {
  white = "#CECDC3", -- base-200 (default fg)
  darker_black = "#0C0B0B",
  black = "#100F0F", -- nvim bg (Flexoki black)
  black2 = "#1C1B1A", -- base-950
  one_bg = "#1C1B1A",
  one_bg2 = "#282726", -- base-900
  one_bg3 = "#343331", -- base-850
  grey = "#403E3C", -- base-800
  grey_fg = "#575653", -- base-700
  grey_fg2 = "#6F6E69", -- base-600
  light_grey = "#878580", -- base-500
  red = c.red,
  baby_pink = "#E8705F", -- red-300
  pink = c.magenta,
  line = "#282726", -- vertsplit / borders
  green = c.green,
  vibrant_green = "#A0AF54", -- green-300
  nord_blue = c.blue,
  blue = c.blue,
  yellow = c.yellow,
  sun = "#E6BA1F", -- yellow-300
  purple = c.purple,
  dark_purple = "#5E409D", -- purple-600
  teal = c.cyan,
  orange = c.orange,
  cyan = c.cyan,
  statusline_bg = "#1C1B1A",
  lightbg = "#282726",
  pmenu_bg = c.blue,
  folder_bg = c.blue,
}

M.base_16 = {
  base00 = "#100F0F", -- default bg
  base01 = "#1C1B1A", -- lighter bg (status bars)
  base02 = "#282726", -- selection bg
  base03 = c.comment, -- comments
  base04 = "#6F6E69", -- dark fg
  base05 = c.fg, -- default fg
  base06 = "#E6E4D9", -- light fg (base-100)
  base07 = "#F2F0E5", -- lightest fg (base-50)
  -- syntax slots (base16 semantics, used by non-treesitter highlighting)
  base08 = c.fg, -- variables / identifiers
  base09 = c.purple, -- numbers / constants
  base0A = c.yellow, -- types / classes
  base0B = c.cyan, -- strings
  base0C = c.cyan, -- escapes / special
  base0D = c.orange, -- functions
  base0E = c.green, -- keywords
  base0F = c.magenta, -- labels / specials
}

M.type = "dark"

-- Exact Flexoki scope -> highlight mapping (mirrors the VS Code tokenColors).
M.polish_hl = {
  -- classic vim regex groups (fallback when treesitter is off)
  syntax = {
    Variable = { fg = c.fg },
    Identifier = { fg = c.fg },
    Constant = { fg = c.fg },
    String = { fg = c.cyan },
    Character = { fg = c.cyan },
    Number = { fg = c.purple },
    Float = { fg = c.purple },
    Boolean = { fg = c.yellow },
    Function = { fg = c.orange, bold = true },
    Keyword = { fg = c.green },
    Statement = { fg = c.green },
    Conditional = { fg = c.green },
    Repeat = { fg = c.green },
    Label = { fg = c.magenta },
    Operator = { fg = c.red },
    Exception = { fg = c.magenta },
    Type = { fg = c.yellow },
    Typedef = { fg = c.yellow },
    Structure = { fg = c.yellow },
    StorageClass = { fg = c.blue },
    Include = { fg = c.red },
    PreProc = { fg = c.magenta },
    Define = { fg = c.magenta },
    Macro = { fg = c.blue },
    Tag = { fg = c.blue },
    Delimiter = { fg = c.comment },
    Special = { fg = c.fg },
    SpecialChar = { fg = c.fg },
    Comment = { fg = c.comment },
  },

  treesitter = {
    -- variables / identifiers
    ["@variable"] = { fg = c.fg },
    ["@variable.parameter"] = { fg = c.fg },
    ["@variable.builtin"] = { fg = c.magenta }, -- this / self
    ["@variable.member"] = { fg = c.blue }, -- struct/object fields
    ["@variable.member.key"] = { fg = c.orange }, -- object-literal keys
    ["@property"] = { fg = c.blue },
    ["@constant"] = { fg = c.fg },
    ["@constant.builtin"] = { fg = c.yellow },
    ["@constant.macro"] = { fg = c.magenta },

    -- literals
    ["@boolean"] = { fg = c.yellow },
    ["@number"] = { fg = c.purple },
    ["@number.float"] = { fg = c.purple },
    ["@string"] = { fg = c.cyan },
    ["@string.regex"] = { fg = c.cyan },
    ["@string.escape"] = { fg = c.fg },
    ["@character"] = { fg = c.cyan },
    ["@character.special"] = { fg = c.fg },

    -- comments
    ["@comment"] = { fg = c.comment },
    ["@comment.documentation"] = { fg = c.doc },

    -- keywords
    ["@keyword"] = { fg = c.green },
    ["@keyword.function"] = { fg = c.green },
    ["@keyword.return"] = { fg = c.green },
    ["@keyword.conditional"] = { fg = c.green },
    ["@keyword.repeat"] = { fg = c.green },
    ["@keyword.exception"] = { fg = c.magenta }, -- try/catch/throw
    ["@keyword.import"] = { fg = c.red }, -- import / from
    ["@keyword.operator"] = { fg = c.red },
    ["@keyword.storage"] = { fg = c.blue }, -- storage.modifier / type
    ["@keyword.directive"] = { fg = c.magenta },
    ["@keyword.directive.define"] = { fg = c.magenta },
    ["@operator"] = { fg = c.red },

    -- functions
    ["@function"] = { fg = c.orange, bold = true },
    ["@function.call"] = { fg = c.orange, bold = true },
    ["@function.builtin"] = { fg = c.orange, bold = true },
    ["@function.method"] = { fg = c.green },
    ["@function.method.call"] = { fg = c.green },
    ["@function.macro"] = { fg = c.blue },
    ["@constructor"] = { fg = c.orange },

    -- types
    ["@type"] = { fg = c.yellow },
    ["@type.builtin"] = { fg = c.yellow },
    ["@type.definition"] = { fg = c.orange }, -- struct/enum/class names
    ["@attribute"] = { fg = c.yellow }, -- decorators / annotations
    ["@module"] = { fg = c.yellow }, -- namespaces
    ["@module.builtin"] = { fg = c.yellow },
    ["@label"] = { fg = c.magenta },

    -- tags (html/jsx)
    ["@tag"] = { fg = c.blue },
    ["@tag.attribute"] = { fg = c.yellow },
    ["@tag.delimiter"] = { fg = c.comment },

    -- punctuation
    ["@punctuation.bracket"] = { fg = c.comment },
    ["@punctuation.delimiter"] = { fg = c.comment },

    -- markup (markdown)
    ["@markup.heading"] = { fg = c.yellow, bold = true },
    ["@markup.raw"] = { fg = c.cyan },
    ["@markup.link"] = { fg = c.blue },
    ["@markup.link.url"] = { fg = c.blue },
    ["@markup.link.label"] = { fg = c.blue },
    ["@markup.italic"] = { fg = c.cyan, italic = true },
    ["@markup.strong"] = { fg = c.yellow, bold = true },
    ["@markup.quote"] = { fg = c.yellow },
    ["@markup.list"] = { fg = c.yellow },
  },

  nvimtree = {
    -- structure
    NvimTreeNormal = { bg = "#100F0F" }, -- match editor bg
    NvimTreeNormalNC = { bg = "#100F0F" },
    NvimTreeEndOfBuffer = { fg = "#100F0F" },
    NvimTreeWinSeparator = { fg = "#100F0F", bg = "#100F0F" }, -- invisible
    NvimTreeCursorLine = { bg = "#1C1B1A" },
    NvimTreeIndentMarker = { fg = "#282726" }, -- base-900, subtle

    -- folders / root
    NvimTreeFolderIcon = { fg = c.blue },
    NvimTreeFolderName = { fg = c.blue },
    NvimTreeOpenedFolderName = { fg = c.blue, bold = true },
    NvimTreeEmptyFolderName = { fg = c.comment },
    NvimTreeFolderArrowOpen = { fg = c.blue },
    NvimTreeFolderArrowClosed = { fg = "#6F6E69" },
    NvimTreeRootFolder = { fg = c.magenta, bold = true },
    NvimTreeSpecialFile = { fg = c.yellow, bold = true },
    NvimTreeExecFile = { fg = c.green },
    NvimTreeImageFile = { fg = c.purple },
    NvimTreeSymlink = { fg = c.cyan },

    -- git status (Flexoki: add=green, change=yellow, delete=red)
    NvimTreeGitNew = { fg = c.green }, -- untracked
    NvimTreeGitStaged = { fg = c.green },
    NvimTreeGitRenamed = { fg = c.orange },
    NvimTreeGitDirty = { fg = c.yellow }, -- modified
    NvimTreeGitMerge = { fg = c.orange },
    NvimTreeGitDeleted = { fg = c.red },
    NvimTreeGitIgnored = { fg = "#6F6E69" },

    -- file name git highlight (when renderer.highlight_git = "name")
    NvimTreeFileDirty = { fg = c.yellow },
    NvimTreeFileNew = { fg = c.green },
    NvimTreeFileStaged = { fg = c.green },
    NvimTreeFileDeleted = { fg = c.red },
    NvimTreeFileRenamed = { fg = c.orange },
    NvimTreeFileIgnored = { fg = "#6F6E69" },

    NvimTreeWindowPicker = { fg = "#100F0F", bg = c.blue, bold = true },
  },
}

M = require("base46").override_theme(M, "flexoki-alt")

return M
