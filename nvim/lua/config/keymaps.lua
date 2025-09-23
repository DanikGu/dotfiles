-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>cp", function()
    vim.fn.setreg("+", vim.fn.expand("%:p"))
    print("File path copied to clipboard")
end, { desc = "Copy file path to clipboard" })

vim.keymap.set("n", "<leader>as", function()
        local current_line = vim.api.nvim_get_current_line()
        if not current_line:match(";$") then
          vim.api.nvim_set_current_line(current_line .. ";")
        end
    print("File path copied to clipboard")
end, { desc = "Add a semicolon at the end of the line" })

local TerminalCount = 0
vim.keymap.set(
    "n",
    "<C-t>",
    function()
        local input = vim.fn.input("Enter buffer name: ")
        local prevFile = vim.fn.expand('%')
        prevFile = string.gsub(prevFile, "/", "//")
        prevFile = string.gsub(prevFile, "\\", "\\\\")
        TerminalCount = TerminalCount + 1
        if input == nil or input == "" then
            input = "t" .. TerminalCount
        end
        local fileName = input .. "_terminal"
        vim.cmd("terminal")
        vim.cmd("file " .. fileName)
        -- if (prevFile ~= nil and prevFile ~= "") then
        --   vim.cmd('let @# = ' .. '"' ..  prevFile .. '"')
        -- else
        --   vim.cmd('let @# = "' .. fileName .. '"')
        -- end
        -- vim.fn.feedkeys("i")
        -- vim.fn.feedkeys("clear")
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true))
    end,
    {noremap = true, silent = true}
)

vim.api.nvim_set_keymap("t", "<Esc><Esc>", "<C-\\><C-n><CR>", {noremap = true, silent = true})


