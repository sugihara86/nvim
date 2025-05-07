-- init.lua

-- エンコーディング設定
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- leaderキーをスペースに設定
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 基本設定
vim.opt.number = true        -- 行番号表示
vim.opt.relativenumber = false -- 相対行番号を無効に
vim.opt.autoindent = true    -- 自動インデント
vim.opt.smartindent = true   -- スマートインデント
vim.opt.hlsearch = true      -- 検索結果をハイライト
vim.opt.ignorecase = true    -- 検索時に大文字小文字を区別しない
vim.opt.smartcase = true     -- 検索パターンに大文字を含んでいたら大文字小文字を区別

-- 隠しバッファを有効にする（barbar用）
vim.opt.hidden = true

-- ウィンドウ間の移動をCtrl+hjklで行えるようにする
vim.keymap.set('n', '<C-h>', '<C-w>h', { silent = true, noremap = true, desc = "ウィンドウ左へ移動" })
vim.keymap.set('n', '<C-j>', '<C-w>j', { silent = true, noremap = true, desc = "ウィンドウ下へ移動" })
vim.keymap.set('n', '<C-k>', '<C-w>k', { silent = true, noremap = true, desc = "ウィンドウ上へ移動" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { silent = true, noremap = true, desc = "ウィンドウ右へ移動" })

-- leader+wで現在のファイルをツリーで表示
vim.keymap.set('n', '<leader>w', ':NvimTreeFindFile<CR>', { silent = true, noremap = true, desc = "現在のファイルをツリーで表示" })

-- leader+qで全てのウィンドウを閉じる
vim.keymap.set('n', '<leader>q', ':qa<CR>', { silent = true })

-- lazy.nvimのブートストラップ
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- 最新の安定版を使用
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- プラグインのセットアップ
require("lazy").setup({
  -- アイコン表示のためのプラグイン
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false, -- 遅延読み込みを無効化
  },

  -- nvim-tree.lua
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- アイコン表示のため
    },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 30,
          signcolumn = "yes",
        },
        renderer = {
          group_empty = true,
          highlight_git = true,
          highlight_opened_files = "name",
          indent_markers = {
            enable = true,
          },
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              default = "", -- デフォルトアイコンを変更（★を削除）
              symlink = "",
              bookmark = "",
              folder = {
                arrow_closed = "",
                arrow_open = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "◌", -- ★を削除
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        filters = {
          dotfiles = false, -- 隠しファイルを表示
        },
        actions = {
          open_file = {
            quit_on_open = false, -- ファイルを開いてもツリーを閉じない
          },
        },
      })
      
      -- leader + e でnvim-treeをトグル
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })
    end,
  },
  
  -- telescope
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4', -- または最新の安定バージョン
    dependencies = { 
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      -- Telescopeの設定
      require('telescope').setup {
        defaults = {
          -- 隠しファイルを表示する設定
          file_ignore_patterns = {},
          hidden = true,
        },
        pickers = {
          find_files = {
            hidden = true  -- 隠しファイルも検索対象に
          },
        },
      }
      
      -- leader + f でtelescope file browserをトグル
      vim.keymap.set('n', '<leader>f', ':Telescope find_files hidden=true<CR>', { silent = true })
      vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', { silent = true })
      vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', { silent = true })
      vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>', { silent = true })
    end,
  },
  
  -- barbar.nvim（タブ機能）
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'lewis6991/gitsigns.nvim', -- OPTIONAL: バッファに git 状態を表示
    },
    init = function()
      -- barbatとnvim-treeの互換性設定
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      -- barbar.nvimの設定
      animation = true,
      auto_hide = false,
      tabpages = true,
      clickable = true,
    },
    config = function(_, opts)
      require('barbar').setup(opts)
      
      -- alt+, で左のタブへ移動
      vim.keymap.set('n', '<A-,>', ':BufferPrevious<CR>', { silent = true })
      -- alt+. で右のタブへ移動
      vim.keymap.set('n', '<A-.>', ':BufferNext<CR>', { silent = true })
      -- alt+w でアクティブなタブを閉じる
      vim.keymap.set('n', '<A-w>', ':BufferClose<CR>', { silent = true })
      
      -- 追加の便利なキーマッピング
      -- alt+p でタブを固定/固定解除
      vim.keymap.set('n', '<A-p>', ':BufferPin<CR>', { silent = true })
      -- alt+1,2,3,...でタブ選択
      vim.keymap.set('n', '<A-1>', ':BufferGoto 1<CR>', { silent = true })
      vim.keymap.set('n', '<A-2>', ':BufferGoto 2<CR>', { silent = true })
      vim.keymap.set('n', '<A-3>', ':BufferGoto 3<CR>', { silent = true })
      vim.keymap.set('n', '<A-4>', ':BufferGoto 4<CR>', { silent = true })
      vim.keymap.set('n', '<A-5>', ':BufferGoto 5<CR>', { silent = true })
      vim.keymap.set('n', '<A-6>', ':BufferGoto 6<CR>', { silent = true })
      vim.keymap.set('n', '<A-7>', ':BufferGoto 7<CR>', { silent = true })
      vim.keymap.set('n', '<A-8>', ':BufferGoto 8<CR>', { silent = true })
      vim.keymap.set('n', '<A-9>', ':BufferGoto 9<CR>', { silent = true })
      vim.keymap.set('n', '<A-0>', ':BufferLast<CR>', { silent = true })
    end,
  },
})

-- カラースキームの設定
-- ファイルタイプに基づく色付けを有効化
vim.cmd([[
  if has('termguicolors')
    set termguicolors
  endif
  syntax enable
  filetype plugin indent on
]])

-- nvim-treeとbarbarの連携のための設定
-- nvim-treeが開いたときにバッファを右にずらす
local nvim_tree_events = require('nvim-tree.events')
local bufferline_api = require('barbar.api')

local function get_tree_size()
  return require'nvim-tree.view'.View.width
end

nvim_tree_events.subscribe('TreeOpen', function()
  bufferline_api.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe('Resize', function()
  bufferline_api.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe('TreeClose', function()
  bufferline_api.set_offset(0)
end)
