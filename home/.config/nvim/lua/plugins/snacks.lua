return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          -- the explorer hides files via git status --ignored, not fd,
          -- so ~/.ignore does not apply here; include overrides all filters
          explorer = { hidden = true, include = { ".dev.vars" } },
          files = { hidden = true },
          grep = { hidden = true },
        },
      },
    },
  },
}
