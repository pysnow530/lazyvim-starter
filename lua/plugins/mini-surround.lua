return {
  "echasnovski/mini.surround",
  keys = function(plugin, keys)
    local opts = require("lazy.core.plugin").values(plugin, "opts", false)
    local mappings = {
      { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
      { opts.mappings.delete, desc = "Delete surrounding" },
      { opts.mappings.find, desc = "Find right surrounding" },
      { opts.mappings.find_left, desc = "Find left surrounding" },
      { opts.mappings.highlight, desc = "Highlight surrounding" },
      { opts.mappings.replace, desc = "Replace surrounding" },
      { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
    }
    return vim.list_extend(mappings, keys)
  end,
  opts = {
    mappings = {
      add = "ys",
      delete = "ds",
      -- find = "sf",
      -- find_left = "sF",
      -- highlight = "sh",
      replace = "cs",
      -- update_n_lines = "sn",
    },
  },
}
