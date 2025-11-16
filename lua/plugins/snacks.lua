local M = {}

M.sources = { { src = 'https://github.com/folke/snacks.nvim' } }

function M.setup()
  if M.loaded then return end
  M.loaded = true

  require('snacks').setup({
    explorer = { replace_netrw = true },
    indent = {
      indent = {
        char = '┊',
        hl = {
          'DevIconAwk',
          'DevIconDot',
          'DevIconCss',
          'DevIconTex',
          'DevIconTcl',
          'DevIconSuo',
        },
        only_current = true,
      },
      scope = { enabled = false },
    },
    notifier = { enabled = true },
    picker = { layout = { fullscreen = true } },
    scroll = {},
    styles = { notification = { wo = { wrap = true } } },
  })

  vim.keymap.set('', '<Leader>d', function() require('snacks').picker.diagnostics({ focus = 'list' }) end, { desc = 'Diagnostics (snacks)' })

  vim.keymap.set('', '<Leader>e', function()
    require('snacks').picker.explorer({
      auto_close = true,
      hidden = true,
      layout = { fullscreen = false },
      win = { list = { keys = { ['<C-c>'] = 'cancel' } } },
    })
  end, { desc = 'Explorer (snacks)' })

  vim.keymap.set('', '<Leader>h', function()
    require('snacks').picker.help({
      confirm = function(picker, item)
        require('snacks').picker.actions.help(picker, item, require('snacks').picker.actions.vsplit)
      end,
    })
  end, { desc = 'Help (snacks)' })

  vim.keymap.set('', '<Leader>H', function()
    require('snacks').picker.grep({
      confirm = function(picker, item)
        picker:close()
        if item then
          local path, file = item.file:match('(.*/)(.-%.txt).*')
          for line in vim.iter(vim.fn.readfile(path .. 'tags')) do
            local tag = line:match('(.-)\t' .. file:gsub('%p', '%%%1'))
            if tag then
              vim.cmd('vertical help ' .. tag)
              vim.api.nvim_win_set_cursor(0, item.pos)
              break
            end
          end
        end
      end,
      glob = '**/doc/*.txt',
      icons = { files = { enabled = false } },
      previewers = { file = { ft = 'help' } },
      rtp = true,
      title = 'Grep help',
      win = { preview = { minimal = true } },
    })
  end, { desc = 'Grep help (snacks)' })

  vim.api.nvim_set_hl(0, 'SnacksPickerBorder', { link = '@none' })
end

return M
