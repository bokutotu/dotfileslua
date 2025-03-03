require("avante").setup({
  provider = "copilot",
  copilot = {
    model = "o3-mini"
  }
})
require("avante_lib").load()
require("copilot").setup()
