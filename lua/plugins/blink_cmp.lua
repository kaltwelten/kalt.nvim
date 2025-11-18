local M = {}

M.sources = { { src = 'https://github.com/saghen/blink.cmp', version = 'v1.7.0' } }

function M.setup()
  if M.loaded then return end
  M.loaded = true

  require('blink.cmp').setup({
    completion = {
      documentation = {
        auto_show = true,
        window = { border = 'rounded' },
      },
      list = { selection = { auto_insert = false } },
      menu = {
        auto_show = false,
        border = 'rounded',
        draw = {
          columns = { { 'kind_icon', 'label', 'label_description', 'source_name', gap = 2 } }
        },
        max_height = 25,
      },
    },
    keymap = { preset = 'super-tab' },
    signature = {
      enabled = true,
      window = { border = 'rounded' },
    },
    sources = { providers = { lsp = { fallbacks = {} } } },
  })
end

return M
