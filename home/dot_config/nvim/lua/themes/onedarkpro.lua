-- OneDark Pro theme for NvChad
-- Based on https://github.com/olimorris/onedarkpro.nvim

local M = {}

M.base_30 = {
  white        = "#abb2bf",
  darker_black = "#1b1f27",
  black        = "#282c34",  -- nvim bg
  black2       = "#252931",
  one_bg       = "#282c34",  -- statusline bg
  one_bg2      = "#30343c",
  one_bg3      = "#32363e",
  grey         = "#5c6370",
  grey_fg      = "#636c77",
  grey_fg2     = "#6b7482",
  light_grey   = "#7f848e",
  red          = "#e06c75",
  baby_pink    = "#DE8C92",
  pink         = "#ff75a0",
  line         = "#2a2e36",  -- for lines like vertsplit
  green        = "#98c379",
  vibrant_green= "#7eca9c",
  nord_blue    = "#81A1C1",
  blue         = "#61afef",
  yellow       = "#e5c07b",
  sun          = "#EBCB8B",
  purple       = "#c678dd",
  dark_purple  = "#b668cd",
  teal         = "#519ABA",
  orange       = "#d19a66",
  cyan         = "#56b6c2",
  statusline_bg= "#22262e",
  lightbg      = "#2d3139",
  pmenu_bg     = "#98c379",
  folder_bg    = "#61afef",
  comment      = "#7f848e",  -- Binaryify OneDark-Pro comment color
}

M.base_16 = {
  base00 = "#282c34",
  base01 = "#353b45",
  base02 = "#3e4451",
  base03 = "#545862",
  base04 = "#565c64",
  base05 = "#abb2bf",
  base06 = "#b6bdca",
  base07 = "#c8ccd4",
  base08 = "#e06c75",
  base09 = "#d19a66",
  base0A = "#e5c07b",
  base0B = "#98c379",
  base0C = "#56b6c2",
  base0D = "#61afef",
  base0E = "#c678dd",
  base0F = "#be5046",
}

M.polish_hl = {
  syntax = {
    -- Traditional syntax highlighting
    Identifier = { fg = M.base_16.base08 }, -- red
    Function = { fg = M.base_16.base0D },   -- blue
    Operator = { fg = M.base_16.base05 },   -- fg (white)
    Keyword = { fg = M.base_16.base0E },    -- purple
    Comment = { fg = M.base_30.comment, italic = true },
  },
  
  treesitter = {
    -- Variables (red in onedarkpro)
    ["@variable"] = { fg = M.base_16.base08 },           -- red
    ["@variable.builtin"] = { fg = M.base_16.base0A },   -- yellow
    ["@variable.parameter"] = { fg = M.base_16.base08 }, -- red
    ["@variable.member"] = { fg = M.base_16.base08 },    -- red
    ["@property"] = { fg = M.base_16.base08 },           -- red
    ["@parameter"] = { fg = M.base_16.base08 },          -- red
    
    -- Functions (blue)
    ["@function"] = { fg = M.base_16.base0D },           -- blue
    ["@function.builtin"] = { fg = M.base_16.base0A },   -- yellow
    ["@function.call"] = { fg = M.base_16.base0D },      -- blue
    ["@function.method"] = { fg = M.base_16.base0D },    -- blue
    ["@function.method.call"] = { fg = M.base_16.base0D }, -- blue
    ["@method"] = { fg = M.base_16.base0D },             -- blue
    ["@method.call"] = { fg = M.base_16.base0D },        -- blue
    
    -- Keywords (purple)
    ["@keyword"] = { fg = M.base_16.base0E },            -- purple
    ["@keyword.import"] = { fg = M.base_16.base0E },     -- purple
    ["@keyword.function"] = { fg = M.base_16.base0E },   -- purple
    ["@keyword.conditional"] = { fg = M.base_16.base0E }, -- purple
    ["@keyword.repeat"] = { fg = M.base_16.base0E },     -- purple
    ["@keyword.return"] = { fg = M.base_16.base0E },     -- purple
    
    -- Constants (orange)
    ["@constant"] = { fg = M.base_16.base09 },           -- orange
    ["@constant.builtin"] = { fg = M.base_16.base09 },   -- orange
    ["@const"] = { fg = M.base_16.base09 },              -- orange
    
    -- Types (yellow)
    ["@type"] = { fg = M.base_16.base0A },               -- yellow
    ["@type.builtin"] = { fg = M.base_16.base0A },       -- yellow
    
    -- Strings (green)
    ["@string"] = { fg = M.base_16.base0B },             -- green
    
    -- Comments
    ["@comment"] = { fg = M.base_30.comment, italic = true },
    
    -- Operators (white/foreground)
    ["@operator"] = { fg = M.base_16.base05 },           -- white
    
    -- Numbers and Literals
    ["@number"] = { fg = M.base_16.base09 },             -- orange
    ["@float"] = { fg = M.base_16.base09 },              -- orange
    ["@boolean"] = { fg = M.base_16.base09 },            -- orange
    
    -- Special values
    ["@constant.null"] = { fg = M.base_16.base09 },      -- orange
    ["@constant.undefined"] = { fg = M.base_16.base09 }, -- orange
    
    -- Punctuation
    ["@punctuation.bracket"] = { fg = M.base_16.base05 }, -- white
    ["@punctuation.delimiter"] = { fg = M.base_16.base05 }, -- white
    ["@punctuation.special"] = { fg = M.base_16.base05 }, -- white
    
    -- Tags (HTML/JSX)
    ["@tag"] = { fg = M.base_16.base08 },                -- red
    ["@tag.attribute"] = { fg = M.base_16.base09 },      -- orange
    ["@tag.delimiter"] = { fg = M.base_16.base05 },      -- white
  },
}

M.type = "dark"

-- Use base46's override_theme if available
local present, base46 = pcall(require, "base46")
if present and base46.override_theme then
  M = base46.override_theme(M, "onedarkpro")
end

return M