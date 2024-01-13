return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    -- disable default keymaps
    {
      "<leader>f",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = require("lazyvim.util").get_root() })
      end,
      desc = "Explorer NeoTree (root dir)",
    },
  },
}
