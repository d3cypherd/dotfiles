return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      -- Customize or remove this keymap to your liking
      "<leader>f",
      function()
        require("conform").format({ async = true })
      end,
      mode = "",
      desc = "[F]ormat buffer",
    },
  },
  -- This will provide type hinting with LuaLS
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    notify_on_error = true,
    -- Define your formatters
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      c = { "clang-format" },
      go = { "goimports", "gofumpt" },
      cs = { "csharpier" },
    },
    -- Set default options
    default_format_opts = {
      lsp_format = "fallback",
    },
    -- Customize formatters
    formatters = {
      clang_format = {
        prepend_args = { "--style=file", "--fallback-style=LLVM" },
      },
      shfmt = {
        prepend_args = { "-i", "4" },
      },
      csharpier = {
        inherit = false,
        command = vim.fn.stdpath("data") .. "/mason/packages/csharpier/csharpier",
        args = { "format", "$FILENAME" },
        stdin = false,
        cwd = require("conform.util").root_file({ "sln", "csproj" }),
      },
    },
  },
}
