vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('close_utility_window_shortcut', { clear = true }),
  pattern = {
    'checkhealth',
    'help',
    'lspinfo',
    'notify',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      for _, key in ipairs({ '<Escape>', 'q' }) do
        vim.keymap.set('n', key, function()
          vim.api.nvim_win_close(0, false)
          pcall(vim.api.nvim_buf_delete, event.buf, { unload = true })
        end, { buffer = event.buf, desc = 'Close window', silent = true })
      end
    end)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('split_vertical_by_default', { clear = true }),
  pattern = {
    'help',
    'man',
  },
  command = 'wincmd L',
})
