local M = {}

M.sources = {
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
}

M.parsers = {
  'awk',
  'bash',
  'css',
  'desktop',
  'diff',
  'fish',
  'git_config',
  'git_rebase',
  'gitattributes',
  'gitcommit',
  'gitignore',
  'html',
  'javascript',
  'jq',
  'json',
  'nix',
  'regex',
  'ssh_config',
  'toml',
  'typescript',
  'udev',
  'xml',
}

function M.setup()
  if M.loaded then return end
  M.loaded = true

  require('nvim-treesitter').install(M.parsers):await(function()
    local filetypes = {}
    for _, parser in ipairs(require('nvim-treesitter').get_installed()) do
      filetypes[#filetypes + 1] = vim.treesitter.language.get_filetypes(parser)
    end
    filetypes = require('util').dedup(vim.iter(filetypes):flatten():totable())
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter_autostart', { clear = true }),
      pattern = filetypes,
      callback = function(event) vim.treesitter.start(event.buf) end,
    })
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.list_contains(filetypes, vim.bo[b].filetype) then vim.treesitter.start(b) end
    end
  end)

  local swap = require('nvim-treesitter-textobjects.swap')
  vim.keymap.set('n', 'g<Right>', function() swap.swap_next('@parameter.inner') end, { desc = 'Swap w/ next (textobjects)' })
  vim.keymap.set('n', 'g<Left>', function() swap.swap_previous('@parameter.inner') end, { desc = 'Swap w/ previous (textobjects)' })
end

return M
