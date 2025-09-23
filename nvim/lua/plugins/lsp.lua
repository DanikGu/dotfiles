vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.cshtml" },
  callback = function()
    vim.bo.filetype = "razor"
  end,
})
return {
   {
        "neovim/nvim-lspconfig",
        opts = {
            on_attach = function(client, bufnr)
                if client.name == "svelte" then
                    vim.api.nvim_create_autocmd("BufWritePost", {
                        pattern = { "*.js", "*.ts" },
                        group = vim.api.nvim_create_augroup("svelte_ondidchangetsorjsfile", { clear = true }),
                        callback = function(ctx)
                            -- Here use ctx.match instead of ctx.file
                            client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
                        end,
                    })
                end

                -- attach keymaps if needed
            end,
        },
    },
    {
      "stevearc/conform.nvim",
      optional = true,
      opts = {
        formatters_by_ft = {
          ["handlebars"] = { "djlint" },
        },
        formatters = {
          djlint = {
            args = { "--reformat", "-" },
            cwd = require("conform.util").root_file({
              ".djlintrc",
            }),
          },
        },
      },
    },
    {
      "mfussenegger/nvim-lint",
      opts = {
        linters_by_ft = {
          handlebars = { "djlint" },
        },
      },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        vim.list_extend(opts.ensure_installed, {
          "glimmer",
        })
      end,
    }
}


