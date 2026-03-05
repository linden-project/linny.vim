{
  description = "Isolated NixVim environment for linny.vim development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixvim, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Use the flake's source directory - changes take effect on reload
      linnyPluginPath = self;

      nixvimModule = {
        extraPlugins = [
          # Plenary for testing
          pkgs.vimPlugins.plenary-nvim

          # Treesitter for syntax
          pkgs.vimPlugins.nvim-treesitter.withAllGrammars
        ];

        # Load linny from source path at runtime
        extraConfigLua = ''
          -- Add linny source to runtimepath (use env var set by shellHook)
          local linny_dev_path = vim.fn.getenv("LINNY_DEV_PATH")
          if linny_dev_path and linny_dev_path ~= vim.NIL then
            vim.opt.runtimepath:prepend(linny_dev_path)
          else
            -- Fallback to Nix store path for non-dev usage
            vim.opt.runtimepath:prepend("${linnyPluginPath}")
          end

          -- Development helpers
          vim.g.mapleader = " "

          -- Set linny paths for testing
          vim.g.linny_open_notebook_path = vim.fn.expand("~/LinnyNotebook")

          -- Quick reload function for development
          _G.reload_linny = function()
            -- Clear cached lua modules
            for name, _ in pairs(package.loaded) do
              if name:match("^linny") then
                package.loaded[name] = nil
              end
            end
            -- Re-source vimscript files
            vim.cmd("runtime! plugin/linny.vim")
            vim.cmd("runtime! autoload/linny.vim")
            vim.cmd("runtime! autoload/linny_*.vim")
            local path = vim.fn.getenv("LINNY_DEV_PATH") or "${linnyPluginPath}"
            print("Linny reloaded from: " .. path)
          end

          vim.keymap.set("n", "<leader>rr", reload_linny, { desc = "Reload Linny" })

          -- Run plenary tests
          vim.keymap.set("n", "<leader>rt", function()
            vim.cmd("PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}")
          end, { desc = "Run tests" })
        '';

        # Minimal sensible defaults
        opts = {
          number = true;
          relativenumber = true;
          expandtab = true;
          shiftwidth = 2;
          tabstop = 2;
          signcolumn = "yes";
          termguicolors = true;
        };

        # Colorscheme
        colorschemes.gruvbox.enable = true;

        # Basic plugins for comfortable editing
        plugins = {
          lualine.enable = true;
          web-devicons.enable = true;
          treesitter.enable = true;

          # LSP for Lua development
          lsp = {
            enable = true;
            servers = {
              lua_ls = {
                enable = true;
                settings = {
                  Lua = {
                    diagnostics = {
                      globals = [ "vim" "describe" "it" "before_each" "after_each" ];
                    };
                    workspace = {
                      library = [
                        "\${3rd}/luv/library"
                      ];
                      checkThirdParty = false;
                    };
                  };
                };
              };
            };
          };
        };
      };

      # Build the NixVim configuration
      nvim = nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        module = nixvimModule;
      };

    in
    {
      packages.${system} = {
        default = nvim;
        neovim = nvim;
      };

      # Development shell with the configured neovim
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          nvim
          pkgs.lua-language-server
          pkgs.stylua  # Lua formatter
        ];

        shellHook = ''
          echo ""
          echo "  Linny Development Environment"
          echo ""
          echo " Plugin source: $(pwd) (live reload enabled)"
          echo ""
          echo " Commands:"
          echo "   nvim                    - Start Neovim"
          echo "   nvim -c 'LinnyStart'    - Start with Linny menu"
          echo ""
          echo " Keymaps (inside Neovim):"
          echo "   <Space>rr  - Reload linny (clears Lua cache)"
          echo "   <Space>rt  - Run plenary tests"
          echo ""

          # Point to local source for live reloading
          export LINNY_DEV_PATH="$(pwd)"

          # Set XDG dirs to keep this isolated from main config
          export XDG_CONFIG_HOME="$(pwd)/.dev/config"
          export XDG_DATA_HOME="$(pwd)/.dev/share"
          export XDG_STATE_HOME="$(pwd)/.dev/state"
          export XDG_CACHE_HOME="$(pwd)/.dev/cache"

          mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"
        '';
      };

      # App for easy running: nix run
      apps.${system}.default = {
        type = "app";
        program = "${nvim}/bin/nvim";
      };
    };
}
