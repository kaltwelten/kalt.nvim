local M = {}

M.sources = { { src = 'https://github.com/jake-stewart/multicursor.nvim' } }

function M.setup()
  if M.loaded then return end
  M.loaded = true

  local mc = require('multicursor-nvim')
  mc.setup()

  mc.addKeymapLayer(function(layer)
    layer('n', '<Escape>', mc.clearCursors, { desc = 'Clear cursors (multicursor)' })
    layer('n', 'g<Space><Space>', function() if mc.cursorsEnabled() then mc.disableCursors() else mc.enableCursors() end end, { desc = 'Toggle multicursor mode (multicursor)' })
    layer('n', 'g<Space>a', mc.alignCursors, { desc = 'Align cursors (multicursor)' })
  end)

  vim.keymap.set({ 'n', 'x' }, 'g<Space>c', mc.toggleCursor, { desc = 'Add/delete cursor (multicursor)' })
  vim.keymap.set({ 'n', 'x' }, 'g<Space>*', mc.matchAllAddCursors, { desc = 'Match * with cursors (multicursor)' })
  vim.keymap.set('x', 'g<Space>m', mc.matchCursors, { desc = 'Match with cursors (multicursor)' })

  vim.keymap.set('x', 'ga', function()
    mc.matchCursors()
    mc.feedkeys('')
    vim.schedule(function()
      mc.alignCursors()
      mc.clearCursors()
    end)
  end, { desc = 'Align to match (multicursor)' })

  require('which-key').add({ { 'g<Space>', group = 'Multicursor' } })
end

return M
