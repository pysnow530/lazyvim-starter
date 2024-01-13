local Util = require("lazyvim.util")

return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<C-p>", Util.telescope("files"), desc = "Find Files (root dir)" },
    { "<leader>g", Util.telescope("live_grep"), desc = "Grep (root dir)" },
  },
}
