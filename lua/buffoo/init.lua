local function _bin_by_result(l, f)
  local bins = {}
  for i, x in ipairs(l) do
    local r = f and f(x) or x
    if bins[r] then
      bins[r][#bins[r] + 1] = i
    else
      bins[r] = { i }
    end
  end
  return bins
end

local function _make_names_unique(buffers)
  for _, b in ipairs(buffers) do b.name.unique = b.name.tail end
  local tails = _bin_by_result(buffers, function(b) return b.name.tail end)
  for _, same_tail in vim.iter(pairs(tails)):filter(function(_, l) return #l > 1 end) do
    for _, b in ipairs(same_tail) do
      buffers[b].name.unique = nil
      if not buffers[b].name.segments then
        buffers[b].name.segments = vim.iter(buffers[b].name.full:gmatch('~?/?[^/]*/')):totable()
      end
    end
    local sweep = {}
    local s = 1
    while vim.tbl_contains(buffers, function(b) return not b.name.unique end, { predicate = true }) do
      for i, b in ipairs(same_tail) do
        if s >= #buffers[b].name.segments and not buffers[b].name.unique then
          buffers[b].name.unique = buffers[b].name.full
        end
        sweep[i] = buffers[b].name.segments[s] or buffers[b].name.unique
      end
      local bins = _bin_by_result(sweep)
      vim.iter(pairs(bins)):filter(function(_, l) return #l == 1 and not buffers[same_tail[l[1]]].name.unique end):each(function(_, l)
        local b = same_tail[l[1]]
        local segments = buffers[b].name.segments
        buffers[b].name.unique = vim.iter(segments):rskip(#segments - s):join('') .. '…/' .. buffers[b].name.tail
      end)
      s = s + 1
    end
  end
end

local function _idx(buf, buffers)
  for i, b in ipairs(buffers) do
    if b.buf == buf then return i end
  end
end

local function _buf_considered(buf)
  return vim.bo[buf].buflisted and vim.bo[buf].buftype == ''
end

local function _bufs_considered()
  return vim.tbl_filter(function(buf) return _buf_considered(buf) end, vim.api.nvim_list_bufs())
end

local function _populate(buffers)
  for i, b in ipairs(_bufs_considered()) do
    buffers[i] = {
      buf = b,
      name = {
        full = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ':~:.'),
        tail = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ':t'),
      },
    }
  end
  _make_names_unique(buffers)
end

local _last_buf = nil

local M = {}

function M.setup()
  if M.loaded then return end
  M.loaded = true
  M.buffers = {}
  local augroup = vim.api.nvim_create_augroup('buffoo', { clear = true })
  if vim.v.vim_did_enter == 1 then
    _populate(M.buffers)
  else
    vim.api.nvim_create_autocmd('VimEnter', {
      group = augroup,
      callback = function() _populate(M.buffers) end,
      once = true,
    })
  end
  vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    callback = function(event)
      local b = M.buffers[_idx(event.buf, M.buffers)]
      if b then
        _last_buf = b
        if b.view then vim.fn.winrestview(b.view) end
      end
    end,
  })
  vim.api.nvim_create_autocmd('BufLeave', {
    group = augroup,
    callback = function(event)
      for _, b in ipairs(M.buffers) do
        if b.buf == event.buf then
          b.view = vim.fn.winsaveview()
          break
        end
      end
    end,
  })
  vim.api.nvim_create_autocmd('BufAdd', {
    group = augroup,
    callback = vim.schedule_wrap(function(event)
      if _buf_considered(event.buf) then
        local i = _idx(_last_buf, M.buffers) or #M.buffers
        i = math.min(i + 1, #M.buffers + 1)
        table.insert(M.buffers, i, {
          buf = event.buf,
          name = {
            full = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(event.buf), ':~:.'),
            tail = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(event.buf), ':t'),
          },
        })
        _make_names_unique(M.buffers)
      end
    end),
  })
  vim.api.nvim_create_autocmd('BufDelete', {
    group = augroup,
    callback = function(event)
      if _buf_considered(event.buf) then
        table.remove(M.buffers, _idx(event.buf, M.buffers))
        _make_names_unique(M.buffers)
      end
    end,
  })
  _last_buf = vim.api.nvim_get_current_buf()
end

function M.switch(buf, direction, opts)
  if not _buf_considered(buf) or #M.buffers < 2 then return end
  local cycle = opts and opts.cycle
  direction = direction < 0 and -1 or 1
  local i = _idx(buf, M.buffers) + direction
  if cycle then
    if i < 1 then
      i = #M.buffers - i
    elseif i > #M.buffers then
      i = i - #M.buffers
    end
  else
    if i < 1 or i > #M.buffers then return end
  end
  vim.api.nvim_win_set_buf(0, M.buffers[i].buf)
end

function M.move(buf, direction, opts)
  if not _buf_considered(buf) or #M.buffers < 2 then return end
  local cycle = opts and opts.cycle
  direction = direction < 0 and -1 or 1
  local i = _idx(buf, M.buffers)
  local j = i + direction
  if cycle then
    if j < 1 then
      j = #M.buffers - j
    elseif j > #M.buffers then
      j = j - #M.buffers
    end
  else
    if j < 1 or j > #M.buffers then return end
  end
  M.buffers[i], M.buffers[j] = M.buffers[j], M.buffers[i]
end

function M.nearest(buf)
  local i = _idx(buf, M.buffers)
  local direction = i == 1 and 1 or -1
  local j = i + direction
  if j < 1 or j > #M.buffers then return end
  vim.api.nvim_win_set_buf(0, M.buffers[j].buf)
end

function M.close(args)
  local force = args and args.force
  local buf = vim.api.nvim_get_current_buf()
  if not force and vim.bo[buf].modified then
    vim.notify('Won\'t close a modified buffer unless forced', vim.log.levels.WARN)
    return
  end
  if #_bufs_considered() <= 1 then
    vim.cmd.quit({ bang = force })
  else
    if
      not _buf_considered(buf) or
      vim.fn.win_gettype(vim.api.nvim_get_current_win()) ~= '' or
      vim.iter(ipairs(vim.api.nvim_list_wins())):filter(function(_, w) return _buf_considered(vim.api.nvim_win_get_buf(w)) end):nth(2)
    then
      vim.api.nvim_win_close(0, force)
    else
      M.nearest(buf)
    end
    if #vim.fn.win_findbuf(buf) < 1 then
      vim.api.nvim_buf_delete(buf, { force = force })
    end
  end
end

return M
