local util = require("lspconfig.util")

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      { "Hoffs/omnisharp-extended-lsp.nvim" },
    },

    opts = {
      diagnostics = require("config.diagnostics"),
      inlay_hints = { enabled = false },
      autoformat = false,

      capabilites = {},

      servers = {
        bashls = {
          bashIde = {
            globPattern = "**/*@(.sh|.inc|.bash|.command|.zsh|.zshrc|.zshenv)",
          },
        },
        gopls = {
          cmd = { "/usr/bin/go" },
          filetypes = { "go", "gomod", "gowork", "gotmpl" },
          settings = {
            completeUnimported = true,
            env = {
              GOEXPERIMENT = "rangefunc",
            },
            gopls = {
              gofumpt = true,
            },
          },
          single_file_support = true,
        },
        ts_ls = {
          cmd = { "typescript-language-server", "--stdio" },
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          single_file_support = true,
        },
        biome = {
          cmd = { "biome", "lsp-proxy" },
          filetypes = {
            "astro",
            "css",
            "graphql",
            "javascript",
            "javascriptreact",
            "json",
            "jsonc",
            "svelte",
            "typescript",
            "typescript.tsx",
            "typescriptreact",
            "vue",
          },
          root_dir = util.root_pattern("biome.json", "biome.jsonc"),
          single_file_support = false,
        },
        --lua_ls = {
        --  Lua = {
        --    completion = {
        --      keywordSnippet = "Both",
        --      displayContext = 3,
        --    },
        --    diagnostics = {
        --      globals = { "vim" },
        --      neededFileStatus = "Opened",
        --    },
        --    runtime = {
        --      version = "LuaJIT",
        --    },
        --    workspace = {
        --      library = {
        --        vim.env.VIMRUNTIME,
        --        [vim.fn.expand("$VIMRUNTIME/lua")] = true,
        --        [vim.fn.stdpath("config") .. "/lua"] = true,
        --      },
        --      checkThirdParty = false,
        --    },
        --    telemetry = { enable = false },
        --    hint = {
        --      enable = true,
        --      setType = true,
        --    },
        --  },
        --},
        --pylsp = {
        --  pylsp = {
        --    plugins = {
        --      ruff = {
        --        enabled = true,
        --        extendSelect = { "I" },
        --        -- config = "/home/novakovic/.config/ruff/pyproject.toml"
        --      },
        --    }
        --  }
        --},
      },
    },

    config = function(_, opts)
      local has_lspconfig, lspconfig = pcall(require, "lspconfig")
      if not has_lspconfig then
        return
      end

      local has_mlspcfg, mason_lspconfig = pcall(require, "mason-lspconfig")
      if not has_mlspcfg then
        return
      end

      local has_cmp, blink_cmp = pcall(require, "blink.cmp")
      if not has_cmp then
        return
      end

      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      local K = require("config.lsp_keymaps")

      local lsp_attach = function(client, bufnr)
        K.LspKeymaps(client, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
          vim.lsp.buf.format()
        end, { desc = "Format current buffer with LSP" })
      end

      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and blink_cmp.get_lsp_capabilities(capabilities) or {},
        opts.capabilities or {}
      )

      mason_lspconfig.setup({
        ensure_installed = vim.tbl_keys(opts.servers),
      })

      mason_lspconfig.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
            on_attach = lsp_attach,
            settings = (opts.servers[server_name] or {}).settings,
          })
        end,
      })

      -- ~  Local (on machine) LSP settings

      -- OCaml
      --lspconfig.ocamllsp.setup({
      --  on_attach = lsp_attach,
      --  capabilities = capabilities,
      --  cmd = { "ocamllsp" },
      --  filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
      --  root_dir = lspconfig.util.root_pattern(
      --    "*.opam",
      --    "ocamlformat",
      --    "esy.json",
      --    "package.json",
      --    ".git",
      --    "dune-project",
      --    "dune-workspace"
      --  ),
      --})

      -- Rust
      --lspconfig.rust_analyzer.setup({
      --  on_attach = lsp_attach,
      --  capabilities = capabilities,
      --  settings = {
      --    ["rust-analyzer"] = {
      --      checkOnSave = {
      --        command = "clippy",
      --      },
      --    },
      --  },
      --})

      -- C#
      lspconfig.omnisharp.setup({
        on_attach = lsp_attach,
        capabilities = capabilities,
        enable_roslyn_analysers = true,
        enable_import_completion = true,
        organize_imports_on_format = true,
        enable_decompilation_support = true,
        filetypes = { "cs", "vb", "csproj", "sln", "slnx", "props", "csx", "targets", "tproj", "slngen", "fproj" },
        handlers = {
          ["textDocument/definition"] = require("omnisharp_extended").handler,
        },
      })

      -- Clangd
      lspconfig.clangd.setup({
        on_attach = lsp_attach,
        capabilities = capabilities,
        cmd = { "/usr/bin/clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        root_dir = lspconfig.util.root_pattern(
          ".clangd",
          ".clang-tidy",
          ".clang-format",
          "compile_commands.json",
          "compile_flags.txt",
          "configure.ac",
          ".git"
        ),
        single_file_support = true,
      })
    end,
  },

  -- ~ Mason

  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
  },

  -- ~  Rust tools
  --{
  --  "simrat39/rust-tools.nvim",
  --  event = "BufReadPost",
  --  config = function()
  --    local rt = require("rust-tools")

  --    rt.setup({
  --      server = {
  --        on_attach = function(client, bufnr)
  --          vim.keymap.set("n", "<leader>rh", rt.hover_actions.hover_actions, { buffer = bufnr })
  --          K.LspKeymaps(client, bufnr)
  --          vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
  --            vim.lsp.buf.format()
  --          end, { desc = "Format current buffer with LSP" })
  --        end,
  --      },
  --    })
  --  end,
  --},
}
