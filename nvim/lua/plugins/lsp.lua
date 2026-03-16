local util = require("lspconfig.util")

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
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
          cmd = { "go" },
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
        basedpyright = {
          cmd = { "basedpyright-langserver", "--stdio" },
          filetypes = { "python" },
          root_markers = {
            "pyrightconfig.json",
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "Pipfile",
            ".git",
          },
          settings = {
            basedpyright = {
              verboseOutput = true,
              disableOrganizeImports = true,
              analysis = {
                typeCheckingMode = "off",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
              },
            },
          },
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
      -- require statements are still necessary for setup
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")
      if not pcall(require, "blink.cmp") then
        return
      end
      local blink_cmp = require("blink.cmp")

      -- configure diagnostics
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- setup keymaps
      local K = require("config.lsp_keymaps")

      -- define on_attach
      local lsp_attach = function(client, bufnr)
        K.LspKeymaps(client, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
          vim.lsp.buf.format()
        end, { desc = "Format current buffer with LSP" })
        if client.name == "ruff" then
          client.server_capabilities.hoverProvider = false
        end
      end

      -- setup capabilities
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        blink_cmp.get_lsp_capabilities(),
        opts.capabilities or {}
      )

      -- Set global config for all servers
      vim.lsp.config("*", {
        capabilities = capabilities,
        on_attach = lsp_attach,
      })

      -- Get all servers that need to be configured and installed
      local servers = opts.servers

      -- Manual configs for omnisharp and clangd
      local omnisharp_bin = vim.fn.stdpath("data") .. "/mason/packages/omnisharp/OmniSharp"
      local omnisharp_config = {
        cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
        enable_roslyn_analysers = true,
        enable_import_completion = true,
        organize_imports_on_format = true,
        enable_decompilation_support = true,
        filetypes = { "cs", "vb", "csproj", "sln", "slnx", "props", "csx", "targets", "tproj", "slngen", "fproj" },
        handlers = {
          ["textDocument/definition"] = require("omnisharp_extended").definition_handler,
          ["textDocument/typeDefinition"] = require("omnisharp_extended").type_definition_handler,
          ["textDocument/references"] = require("omnisharp_extended").references_handler,
          ["textDocument/implementation"] = require("omnisharp_extended").implementation_handler,
        },
      }

      local clangd_config = {
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
      }

      -- Add manual configs to the main servers table to be handled uniformly
      servers["omnisharp"] = vim.tbl_deep_extend("force", servers["omnisharp"] or {}, omnisharp_config)
      servers["clangd"] = vim.tbl_deep_extend("force", servers["clangd"] or {}, clangd_config)

      -- Setup mason-lspconfig to ensure servers are installed
      local servers_to_install = {}
      for server_name, _ in pairs(servers) do
        if server_name ~= "*" then
          table.insert(servers_to_install, server_name)
        end
      end
      require("mason-lspconfig").setup({
        ensure_installed = servers_to_install,
      })

      -- Apply per-server configurations
      for server_name, server_opts in pairs(servers) do
        vim.lsp.config(server_name, server_opts or {})
      end
    end,
  },

  -- ~ Mason

  {
    "mason-org/mason.nvim",
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
      "mason-org/mason-lspconfig.nvim",
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
