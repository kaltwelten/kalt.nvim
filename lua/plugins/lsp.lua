local M = {}

M.sources = { { src = 'https://github.com/neovim/nvim-lspconfig' } }

M.servers = {
  'bashls',
  'cssls',
  'fish_lsp',
  'html',
  'jsonls',
  'lua_ls',
  'nil_ls',
  'nixd',
  'systemd_ls',
  'ts_ls',
}

function M.setup()
  if M.loaded then return end
  M.loaded = true

  vim.lsp.config('lua_ls', {
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end
      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = {
            'lua/?.lua',
            'lua/?/init.lua',
          },
        },
        workspace = {
          checkThirdParty = false,
          library = { vim.env.VIMRUNTIME },
        },
      })
    end,
    settings = { Lua = {} }
  })

  vim.lsp.enable(M.servers)
end

return M
