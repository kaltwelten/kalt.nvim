local M = {}

M.sources = { { src = 'https://github.com/b0o/incline.nvim' } }

M.defaults = { nc_blend_percent = 40 }

local _hl_component = require('util').hl_component

local function _blend_bg(group1, group2, blend)
  local helpers = require('incline.helpers')
  local bg_normal = helpers.hex_to_rgb(_hl_component(group1, 'bg'))
  local bg_nc = helpers.hex_to_rgb(_hl_component(group2, 'bg'))
  local b = blend / 100
  return helpers.rgb_to_hex({
    r = bg_normal.r - b * (bg_normal.r - bg_nc.r),
    g = bg_normal.g - b * (bg_normal.g - bg_nc.g),
    b = bg_normal.b - b * (bg_normal.b - bg_nc.b),
  })
end

local function _create_tab(filename, ft_icon, ft_color, hl_group)
  return {
    ft_icon and { '', guifg = ft_color } or '',
    ft_icon and { ft_icon, ' ', guibg = ft_color, guifg = require('incline.helpers').contrast_color(ft_color) } or '',
    ft_icon and { ' ', group = hl_group } or { '', guifg = _hl_component(hl_group, 'bg') },
    { filename, group = hl_group },
    { '', guifg = _hl_component(hl_group, 'bg') },
    ' ',
  }
end

function M.setup(opts)
  if M.loaded then return end
  M.loaded = true
  M.options = vim.tbl_deep_extend('force', {}, M.defaults, opts or {})

  local buffoo = require('buffoo')

  require('incline').setup({
    ignore = {
      buftypes = function(buf, buftype)
        return buftype ~= 'help' and (buftype ~= '' or not vim.bo[buf].buflisted)
      end,
      unlisted_buffers = false,
    },
    window = {
      padding = 0,
      placement = { vertical = 'bottom' },
      margin = {
        horizontal = 0,
        vertical = 2,
      },
    },
    highlight = {
      groups = {
        InclineNormal = 'Normal',
        InclineNormalNC = { guibg = _blend_bg('NormalFloat', 'Normal', M.options.nc_blend_percent) },
      },
    },
    render = function(props)
      local tabs = {}
      if vim.bo[props.buf].buftype == 'help' then
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
        local ft_icon, ft_color = require('nvim-web-devicons').get_icon_color(filename)
        local hl_group = 'lualine_' .. (props.focused and 'a_normal' or 'b_normal')
        tabs[#tabs + 1] = _create_tab(filename, ft_icon, ft_color, hl_group)
      else
        for _, b in ipairs(buffoo.buffers) do
          if props.focused or b.buf == props.buf then
            local filename = b.name.unique ~= '' and b.name.unique or '[No Name]'
            local ft_icon, ft_color = require('nvim-web-devicons').get_icon_color(filename)
            local modified = vim.bo[b.buf].modified
            local hl_group = 'lualine_' .. (
              props.focused and b.buf == props.buf and (modified and 'a_command' or 'a_normal') or
              modified and 'a_replace' or 'b_normal'
            )
            tabs[#tabs + 1] = _create_tab(filename, ft_icon, ft_color, hl_group)
          end
        end
      end
      return vim.iter(tabs):flatten():totable()
    end,
  })

  vim.keymap.set({ '', 'i' }, '<C-A-h>', function()
    buffoo.move(vim.api.nvim_get_current_buf(), -1, { cycle = true })
    require('incline').refresh()
  end, { desc = 'Move buffer left (buffoo)' })

  vim.keymap.set({ '', 'i' }, '<C-A-l>', function()
    buffoo.move(vim.api.nvim_get_current_buf(), 1, { cycle = true })
    require('incline').refresh()
  end, { desc = 'Move buffer right (buffoo)' })
end

return M
