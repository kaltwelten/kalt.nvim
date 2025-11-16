local M = {}

M.sources = { { src = 'https://github.com/folke/which-key.nvim' } }

function M.setup()
  if M.loaded then return end
  M.loaded = true

  require('which-key').setup({
    delay = 0,
    icons = {
      keys = {
        F13 = "󰘶 󱊫",
        F14 = "󰘶 󱊬",
        F15 = "󰘶 󱊭",
        F16 = "󰘶 󱊮",
        F17 = "󰘶 󱊯",
        F18 = "󰘶 󱊰",
        F19 = "󰘶 󱊱",
        F20 = "󰘶 󱊲",
        F21 = "󰘶 󱊳",
        F22 = "󰘶 󱊴",
        F23 = "󰘶 󱊵",
        F24 = "󰘶 󱊶",
      },
      mappings = false,
    },
    preset = 'helix',
    win = { row = -4 },
  })

  local hl_component = require('util').hl_component
  vim.api.nvim_set_hl(0, 'WhichKeyTitle', { bg = hl_component('NormalFloat', 'bg'), fg = hl_component('Title', 'fg') })
end

return M
