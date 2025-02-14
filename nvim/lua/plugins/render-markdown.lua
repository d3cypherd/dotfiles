-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/render-markdown.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/render-markdown.lua

-- https://github.com/MeanderingProgrammer/markdown.nvim
--
-- When I hover over markdown headings, this plugins goes away, so I need to
-- edit the default highlights
-- I tried adding this as an autocommand, in the options.lua
-- file, also in the markdownl.lua file, but the highlights kept being overriden
-- so the inly way is the only way I was able to make it work was loading it
-- after the config.lazy in the init.lua file lamw25wmal

return {
  "MeanderingProgrammer/render-markdown.nvim",
  enabled = true,
  -- Moved highlight creation out of opts as suggested by plugin maintainer
  -- There was no issue, but it was creating unnecessary noise when ran
  -- :checkhealth render-markdown
  -- https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/138#issuecomment-2295422741
  opts = {
    bullet = {
      -- Turn on / off list bullet rendering
      enabled = true,
    },
    heading = {
      sign = false,
      icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
      backgrounds = {
        "Headline1Bg",
        "Headline2Bg",
        "Headline3Bg",
        "Headline4Bg",
        "Headline5Bg",
        "Headline6Bg",
      },
      foregrounds = {
        "Headline1Fg",
        "Headline2Fg",
        "Headline3Fg",
        "Headline4Fg",
        "Headline5Fg",
        "Headline6Fg",
      },
    },
  },
}
