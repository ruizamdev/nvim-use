#!/usr/bin/env bash

# Modo estricto, obliga a que el script falle de inmediato
# ante cualquier comportamiento inesperado
set -euo pipefail

# Autorización root al inicio
if ! sudo -n true 2>/dev/null; then
	sudo -v
fi

# paquetes necesarios
packages=(
	"neovim"
	"git"
	"unzip"
	"ripgrep"
	"fd"
)

for package in "${packages[@]}"; do
	if pacman -Q "$package" &>/dev/null; then
		echo "$package ya está instalado"
	else
		echo "$package aún no está instalado"
		echo "Se procede a su instalación:"
		sudo pacman -S --noconfirm --needed "$package"
	fi
done

# Creación de rutas y ficheros
# Variables
# Directorios
NVIM_DIR="$HOME/.config/nvim"
LUA_DIR="$NVIM_DIR/lua"
CONFIG_DIR="$LUA_DIR/config"
PLUGINS_DIR="$LUA_DIR/plugins"

# Ficheros de configuracion e inicio
INIT_FILE="$NVIM_DIR/init.lua"
LAZY_FILE="$CONFIG_DIR/lazy.lua"

# Plugins
declare -A plugins=(
	[autopairs]="$PLUGINS_DIR/autopairs.lua"
	[cmp]="$PLUGINS_DIR/cmp.lua"
	[colorscheme]="$PLUGINS_DIR/colorscheme.lua"
	[gitsigns]="$PLUGINS_DIR/gitsigns.lua"
	[lsp]="$PLUGINS_DIR/lsp.lua"
	[lualine]="$PLUGINS_DIR/lualine.lua"
	[neotree]="$PLUGINS_DIR/neo-tree.lua"
	[telescope]="$PLUGINS_DIR/telescope.lua"
	[treesitter]="$PLUGINS_DIR/treesitter.lua"
)

# Creación de directorios y ficheros
mkdir -p "$CONFIG_DIR" "$PLUGINS_DIR"

create_if_missing() {
	local file=${1:?create_if_missing necesita una ruta como argumento}
	if [[ -f $file ]]; then
		echo "Ya existe: $file"
	else
		touch "$file"
		echo "Creado: $file"
	fi
}

create_if_missing "$INIT_FILE"
create_if_missing "$LAZY_FILE"

for plugin in "${plugins[@]}"; do
	create_if_missing "$plugin"
done

# Aplicando configuraciones dentro de ficheros
# init.lua
if [[ ! -s "$INIT_FILE" ]]; then
  echo "El fichero $INIT_FILE esta vacío"
cat > "$INIT_FILE" <<EOF
-- Configuración base
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Interfaz
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.scrolloff = 8
	
-- Indentación
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Búsqueda
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Comportamiento
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.splitright = true
vim.opt.splitbelow = true

require("config.lazy")
EOF
  echo "Se escribieron las configuraciones"
else
  echo "El fichero no esta vacío, ya hay una configuración previa"
fi

# lazy.lua
if [[ ! -s "$LAZY_FILE" ]]; then
  echo "El fichero $LAZY_FILE esta vacío"
cat > "$LAZY_FILE" <<EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
})
EOF
  echo "Se escribieron las configuraciones"
else
  echo "El fichero no está vacío, ya hay una configuración previa"
fi

# autopairs.lua
if [[ ! -s "${plugins[autopairs]}" ]]; then
  echo "El fichero ${plugins[autopairs]} esta vacío"
cat > "${plugins[autopairs]}" <<EOF
return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },
}
EOF
  echo "Se escribieron las configuraciones"
else
  echo "El fichero no está vacío, ya hay una configuración previa"
fi

# cmp.lua
if [[ ! -s "${plugins[cmp]}" ]]; then
  echo "El fichero ${plugins[cmp]} esta vacío"
cat > "${plugins[cmp]}" <<EOF
return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },

    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),

        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "buffer" },
        }),
      })
    end,
  },
}
EOF
  echo "Se escribieron las configuraciones"
else
  echo "El fichero no está vacío, ya hay una configuración previa"
fi

# colorscheme.lua
if [[ ! -s "${plugins[colorscheme]}" ]]; then
  echo "El fichero ${plugins[colorscheme]} esta vacío"
cat > "${plugins[colorscheme]}" <<EOF
return {
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("kanagawa-wave")
    end,
  },
}
EOF
  echo "Se escribieron las configuraciones"
else
  echo "El fichero no está vacío, ya hay una configuración previa"
fi

# gitsigns.lua
if [[ ! -s "${plugins[gitsigns]}" ]]; then
  echo "El fichero ${plugins[gitsigns]} esta vacío"
cat > "${plugins[gitsigns]}" <<EOF
return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
}
EOF
  echo "Se escribieron las configuraciones"
else
  echo "El fichero no está vacío, ya hay una configuración previa"
fi

# lsp.lua
if [[ ! -s "${plugins[lsp]}" ]]; then
  echo "El fichero ${plugins[lsp]} esta vacío"
cat > "${plugins[lsp]}" <<EOF
return {
  {
    "williamboman/mason.nvim",
    config = true,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls",
          "lua_ls",
          "html",
          "cssls",
          "jsonls",
        },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities =
        require("cmp_nvim_lsp").default_capabilities()

      local servers = {
        "ts_ls",
        "lua_ls",
        "html",
        "cssls",
        "jsonls",
      }

      for _, server in ipairs(servers) do
        vim.lsp.config(server, {
          capabilities = capabilities,
        })

        vim.lsp.enable(server)
      end

      vim.keymap.set("n", "K", vim.lsp.buf.hover)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
    end,
  },
}
EOF
  echo "Se escribieron las configuraciones"
else
  echo "El fichero no está vacío, ya hay una configuración previa"
fi

# lualine.lua
if [[ ! -s "${plugins[lualine]}" ]]; then
  echo "El fichero ${plugins[lualine]} esta vacío"
cat > "${plugins[lualine]}" <<EOF
return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lualine").setup()
    end,
  },
}
EOF
  echo "Se escribieron las configuraciones"
else
  echo "El fichero no está vacío, ya hay una configuración previa"
fi

# neotree.lua
if [[ ! -s "${plugins[neotree]}" ]]; then
  echo "El fichero ${plugins[neotree]} esta vacío"
cat > "${plugins[neotree]}" <<EOF
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>")
    end,
  },
}
EOF
  echo "Se escribieron las configuraciones"
else
  echo "El fichero no está vacío, ya hay una configuración previa"
fi

# telescope.lua
if [[ ! -s "${plugins[telescope]}" ]]; then
  echo "El fichero ${plugins[telescope]} esta vacío"
cat > "${plugins[telescope]}" <<EOF
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local builtin = require("telescope.builtin")

      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
      vim.keymap.set("n", "<leader>fb", builtin.buffers)
      vim.keymap.set("n", "<leader>fh", builtin.help_tags)
    end,
  },
}
EOF
  echo "Se escribieron las configuraciones"
else
  echo "El fichero no está vacío, ya hay una configuración previa"
fi

# treesitter.lua
if [[ ! -s "${plugins[treesitter]}" ]]; then
  echo "El fichero ${plugins[treesitter]} esta vacío"
cat > "${plugins[treesitter]}" <<EOF
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "javascript",
          "typescript",
          "tsx",
          "html",
          "css",
          "json",
          "bash",
          "lua",
        },
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
}
EOF
  echo "Se escribieron las configuraciones"
else
  echo "El fichero no está vacío, ya hay una configuración previa"
fi
