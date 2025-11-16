local plugins = {
  {
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  },
  require('plugins.blink_cmp').sources,
  require('plugins.incline').sources,
  require('plugins.lsp').sources,
  require('plugins.lualine').sources,
  require('plugins.multicursor').sources,
  require('plugins.onedark').sources,
  require('plugins.snacks').sources,
  require('plugins.treesitter').sources,
  require('plugins.treesj').sources,
  require('plugins.which-key').sources,
}

vim.pack.add(vim.iter(plugins):flatten():totable(), { confirm = false })

require('plugins.onedark').setup()
require('plugins.which-key').setup()
require('plugins.blink_cmp').setup()
require('plugins.buffoo').setup()
require('plugins.incline').setup()
require('plugins.lsp').setup()
require('plugins.lualine').setup()
require('plugins.multicursor').setup()
require('plugins.snacks').setup()
require('plugins.tintin').setup()
require('plugins.treesitter').setup()
require('plugins.treesj').setup()
