require("avante").setup({
  provider = "deepseek",
  vendors = {
    deepseek = {
      __inherited_from = "openai",
      api_key_name = "default",
      endpoint = "https://api.deepseek.com",
      model = "deepseek-reasoner",
    },
  },
})
require("avante_lib").load()
require("copilot").setup()
