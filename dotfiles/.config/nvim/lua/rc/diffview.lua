local function get_hl(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if ok and hl and next(hl) ~= nil then
    return hl
  end

  local legacy_ok, legacy = pcall(vim.api.nvim_get_hl_by_name, name, true)
  if legacy_ok and legacy then
    return {
      fg = legacy.foreground,
      bg = legacy.background,
      sp = legacy.special,
    }
  end
end

local function color_to_rgb(color)
  local r = math.floor(color / 0x10000) % 0x100
  local g = math.floor(color / 0x100) % 0x100
  local b = color % 0x100
  return r, g, b
end

local function blend_color(base, accent, mix)
  local base_r, base_g, base_b = color_to_rgb(base)
  local accent_r, accent_g, accent_b = color_to_rgb(accent)

  local function channel(base_value, accent_value)
    return math.floor((base_value * (1 - mix)) + (accent_value * mix) + 0.5)
  end

  return string.format(
    '#%02x%02x%02x',
    channel(base_r, accent_r),
    channel(base_g, accent_g),
    channel(base_b, accent_b)
  )
end

local function apply_diff_highlights()
  local normal = get_hl('Normal') or {}
  local default_bg = vim.o.background == 'light' and 0xffffff or 0x000000
  local base_bg = normal.bg or default_bg

  local function set_subtle_diff(name, mix, opts)
    local source = get_hl(name)
    if not source then
      return
    end

    local accent = source.bg or source.fg
    if not accent then
      return
    end

    local spec = {
      bg = blend_color(base_bg, accent, mix),
    }

    if opts and opts.underline then
      spec.underline = true
    end
    if opts and opts.bold then
      spec.bold = true
    end

    vim.api.nvim_set_hl(0, name, spec)
  end

  set_subtle_diff('DiffAdd', 0.18)
  set_subtle_diff('DiffChange', 0.16)
  set_subtle_diff('DiffDelete', 0.20)
  set_subtle_diff('DiffText', 0.28, { underline = true })

  pcall(function()
    require('diffview.hl').update_diff_hl()
  end)
end

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = apply_diff_highlights,
})

require('diffview').setup({
  view = {
    default = {
      layout = 'diff2_horizontal',
    },
    file_history = {
      layout = 'diff2_horizontal',
    },
  },
  hooks = {
    diff_buf_read = function(_)
      -- Disable folding so unchanged context always stays visible in Diffview.
      vim.opt_local.foldenable = false
    end,
  },
})

apply_diff_highlights()
