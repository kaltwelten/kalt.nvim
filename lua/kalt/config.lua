require('kalt.core')
require('kalt.options')
require('kalt.plugins')
require('kalt.mappings')
require('kalt.autocmd')

local vim_lsp_util_open_floating_preview = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or 'rounded'
  return vim_lsp_util_open_floating_preview(contents, syntax, opts, ...)
end
