return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    -- disable default keymaps
    {
      "<leader>f",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = require("lazyvim.util").root.get() })
      end,
      desc = "Explorer NeoTree (root dir)",
    },
  },
}
