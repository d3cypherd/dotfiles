return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
    { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview file history" },
    { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview branch history" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
  },
  opts = {
    view = {
      merge_tool = {
        layout = "diff3_mixed",
      },
    },
  },
}
