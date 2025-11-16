local M = {}

M.sources = { { src = 'https://github.com/nvim-lualine/lualine.nvim' } }

function M.setup()
  if M.loaded then return end
  M.loaded = true

  require('lualine').setup({
    sections = {
      lualine_a = {
        {
          function() return 'MULTI' end,
          cond = function()
            local mc = require('multicursor-nvim')
            return mc.cursorsEnabled() and mc.hasCursors()
          end,
          color = 'lualine_a_command',
          separator = { right = '' },
        },
        {
          'mode',
          separator = { right = '' },
        },
        {
          function() return 'RECORDING into ' .. vim.fn.reg_recording() end,
          cond = function() return vim.fn.reg_recording() ~= '' end,
          color = 'lualine_a_replace',
          separator = { right = '' },
        },
      },
      lualine_c = {},
      lualine_y = {
        {
          'lsp_status',
          color = 'lualine_b_normal',
        },
        {
          function() return vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] and '🌳' or '' end,
          color = 'lualine_b_normal',
        },
      },
      lualine_z = { 'progress' },
    },
  })
end

return M
