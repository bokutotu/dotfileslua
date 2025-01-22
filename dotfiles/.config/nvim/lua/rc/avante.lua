require("avante").setup({
  provider = "deepseek",
  vendors = {
    deepseek = {
      __inherited_from = "openai",
      api_key_name = "DEEPSEEK_API_KEY",
      endpoint = "https://api.deepseek.com",
      model = "deepseek-reasoner",
    },
  },
})
require("avante_lib").load()
require("copilot").setup()
