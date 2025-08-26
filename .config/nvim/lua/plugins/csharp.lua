return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = {
          cmd = {
            "dotnet",
            vim.fn.stdpath("data") .. "/mason/packages/omnisharp/libexec/OmniSharp.dll",
          },

          -- Configuración de capacidades básica (sin nvim-cmp)
          capabilities = (function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            -- Deshabilitar capacidades problemáticas
            capabilities.textDocument.semanticTokens = nil
            capabilities.workspace.didChangeWatchedFiles = nil
            return capabilities
          end)(),

          -- Root pattern mejorado
          root_dir = function(fname)
            local lspconfig = require("lspconfig")
            return lspconfig.util.root_pattern("*.sln", "*.csproj", "omnisharp.json", "function.json")(fname)
              or lspconfig.util.find_git_ancestor(fname)
          end,

          -- Configuraciones específicas para OmniSharp
          settings = {
            FormattingOptions = {
              EnableEditorConfigSupport = false,
              OrganizeImports = false,
            },
            RoslynExtensionsOptions = {
              EnableAnalyzersSupport = false,
              EnableImportCompletion = false,
              AnalyzeOpenDocumentsOnly = true,
            },
            Sdk = {
              IncludePrereleases = false,
            },
          },

          -- Configuración de inicialización
          on_init = function(client)
            -- Deshabilitar funcionalidades problemáticas después de la inicialización
            client.server_capabilities.semanticTokensProvider = nil
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,

          -- Configuración adicional para reducir ruido
          flags = {
            debounce_text_changes = 500,
          },

          -- Tipos de archivo soportados
          filetypes = { "cs", "vb" },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, { "c_sharp" })
    end,
  },
}
