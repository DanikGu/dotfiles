-- require("catppuccin").setup {
--     custom_highlights = function(colors)
--         return {
--             NeoTreeNormal = {
--                 bg = "#24273a"
--             },
--             NeoTreeNormalNC = {
--                 bg = "#24273a"
--             },
--             NormalFloat = {
--                 bg = "#24273a"
--             }
--         }
--     end
-- }
vim.g.snacks_animate = false
return {
    {
        "catppuccin",
        opts = {
          transparent_background = true,
        },
    },
    {
        "LazyVim/LazyVim",
        opts = {
          colorscheme = "catppuccin",
        },
    }
}
