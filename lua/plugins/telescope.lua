local Util = require("lazyvim.util")

return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<C-p>", Util.telescope("files"), desc = "Find Files (root dir)" },
  },
}
