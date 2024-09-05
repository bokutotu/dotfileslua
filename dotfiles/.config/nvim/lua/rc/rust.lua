vim.g.rustaceanvim = {
  tools = {
    -- Automatically run clippy checks on save
    enable_clippy = true,
  },
  server = {
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy",
          extraArgs = { "--", "-W", "clippy::pedantic" },
        },
      },
    },
  },
}
