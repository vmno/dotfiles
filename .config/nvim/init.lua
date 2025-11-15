-- file: init.lua
-- desc: nvim configuration

-- [[ leader key ]] --

-- set the leader key which should be done before most other things (I think)
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- [[ vim options ]] --

-- enable syntax highlighting
vim.opt.syntax = 'on'

-- enable line numbers and relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- default to case insensitive search but use case depending on pattern
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- don't highlight search results
vim.opt.hlsearch = false

-- fuck tabs
vim.opt.expandtab = true
vim.opt.smarttab = true

-- no. of columns used for indents and tabs
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- auto indent based on previous line indentation
vim.opt.autoindent = true

-- insert indentation in certain cases?
vim.opt.smartindent = true

-- column + row numbers in the status line
vim.opt.ruler = true
vim.opt.winborder = "rounded"

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeout = true
vim.opt.timeoutlen = 800

-- save undo history
vim.opt.undofile = true

-- enable mouse mode
vim.opt.mouse = 'a'

-- sync vim+OS clipboard
vim.opt.clipboard = 'unnamedplus'

-- autocomplete popup
vim.opt.completeopt = 'menu,popup,noselect'

-- [[ lazy bootstrapping ]] --

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)

-- [[ plugin management ]] --

require('lazy').setup({

    -- theme & look
    { 'slugbyte/lackluster.nvim',   lazy = false },
    { 'nvim-lualine/lualine.nvim' },
    { 'echasnovski/mini.pick',      version = '*' },
    { 'echasnovski/mini.extra',     version = '*' },
    -- will need to move to something else at some point
    { 'stevearc/dressing.nvim' },
    { 'Bishop-Fox/colorblocks.nvim' },

    -- lsp configuration
    { 'neovim/nvim-lspconfig' },
    { 'mason-org/mason.nvim' },
    {
        'nvim-telescope/telescope.nvim',
        version = '*',
        dependencies = 'nvim-lua/plenary.nvim',
    },
    { 'stevearc/conform.nvim' },

    { 'renerocksai/telekasten.nvim' },

    -- autocomplete
    { 'saghen/blink.cmp',           version = '1.*' },

    -- treesitter & syntax highlighting
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'master',
        lazy = false,
        build = ':TSUpdate',
    },

    {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = { file_types = { 'md', 'markdown' } },
        ft = { 'markdown' },
    },

    -- auto parens
    { 'windwp/nvim-autopairs' },

    -- copilot
    "zbirenbaum/copilot.lua",
    {
        "sotte/presenting.nvim",
        opts = {
            -- fill in your options here
            -- see :help Presenting.config
        },
        cmd = { "Presenting" },
    }

}, {})

require('copilot').setup({
    suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
            accept = '<C-J>'
        }
    },
    filetypes = {
        markdown = true,
    },
})

require('render-markdown').setup()

-- just changes some colors for markdown rendering
vim.api.nvim_set_hl(0, 'RenderMarkdownH1Bg', { fg = '#deeeed' })
vim.api.nvim_set_hl(0, 'RenderMarkdownH2Bg', { fg = '#789978' })
vim.api.nvim_set_hl(0, 'RenderMarkdownH3Bg', { fg = '#ffaa88' })
vim.api.nvim_set_hl(0, 'RenderMarkdownH4Bg', { fg = '#d70000' })
vim.api.nvim_set_hl(0, 'RenderMarkdownH5Bg', { fg = '#708090' })

local note_home = vim.fn.expand("$HOME/notes")

-- Note taking
require('telekasten').setup({
    -- home for all the notes
    home = note_home,
    extension = '.md',
    auto_set_syntax = true,
    auto_set_filetype = false,
    -- subdirectories for certain kinds of notes
    dailies = note_home .. '/' .. 'daily',
    templates = note_home .. '/' .. 'daily',
    -- following links to nonexistent notes creates them
    follow_creates_nonexisting = true,
    dailies_create_nonexisting = true,
    -- daily note template
    template_new_daily = note_home .. '/' .. 'templates/daily.md',
    -- how tags are defined, other options: :tag: and yaml-bare
    tag_notation = "#tag",
    -- create [[subdir/title]] links instead of [[title]] links
    subdirs_in_links = true,
    template_handling = "smart",
    new_note_location = "smart",
    rename_update_links = true
})

require('blink.cmp').setup({
    completion = {
        list = {
            selection = {
                preselect = true,
                auto_insert = true,
            }
        },
        menu = {
            draw = {
                treesitter = { 'lsp' }
            }
        }
    },
    keymap = {
        preset = 'default',

        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<Enter>'] = { 'accept', 'fallback' },
    }
})

require('conform').setup({
    formatters_by_ft = {
        lua = { 'lua_ls' },
        python = { 'ruff_format', 'ruff_organize_imports' },
        rust = { 'rustfmt' },
    },
    format_on_save = {
        timeout_ms = 500,
        lsp_format = 'fallback',
    },
    formatters = {
        ruff = {
            prepend_args = { '--line-length=100' }
        }
    }
})

require('mini.pick').setup({
    mappings = {
        move_up = '<C-K>',
        move_down = '<C-J>',
    }
})
require('mini.extra').setup({})
vim.ui.select = MiniPick.ui_select
vim.api.nvim_set_hl(0, 'MiniPickMatchCurrent', { bg = '#555555', fg = '#000000' })
require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
            },
        },
    },
}


-- [[ package setup / configuration ]] --

-- theme & look setup
--
local theme = require("lackluster")
local color = theme.color

theme.setup({
    tweak_syntax = {
        comment = color.gray6
    }
})

vim.cmd.colorscheme('lackluster-mint')

require('dressing').setup({
    input = { enabled = true },
    select = { enabled = false },
})


-- lualine setup
--

-- This shortens really long git branch names so they don't take up a ton of space
-- in lualine.
--
local function shorten_lualine_branch(name)
    if name:len() > 30 then
        return name:sub(1, 27) .. '...'
    end
    return name
end

local custom_luster = require('lualine.themes.lackluster')

custom_luster.normal.a.bg = '#708090'
custom_luster.normal.a.fg = '#dddddd'
custom_luster.insert.a.bg = '#789978'
custom_luster.insert.a.fg = '#000000'
custom_luster.command.a.bg = '#ffaa88'
custom_luster.command.a.fg = '#000000'

require('lualine').setup({
    options = {
        icons_enabled = true,
        --theme = 'lackluster',
        theme = custom_luster,
        component_separators = '|',
        section_separators = '',
    },
    sections = {
        lualine_b = {
            { 'branch', fmt = shorten_lualine_branch }
        }
    }
})

-- lsp setup
--
require('mason').setup()

vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set(
    'n',
    '<leader>ff',
    require('telescope.builtin').find_files,
    { desc = '[F]ind [F]iles' }
)
vim.keymap.set(
    'n',
    '<leader>g',
    require('telescope.builtin').live_grep,
    { desc = '[G]rep' }
)


-- lsp specific settings
--
vim.lsp.config('rust_analyzer', {
    settings = {
        checkOnSave = {
            command = 'clippy',
        },
        cargo = {
            buildScripts = {
                enable = true,
            }
        },
        diagnostics = {
            enable = true,
        },
        imports = {
            granularity = {
                group = 'module',
            },
            prefix = 'self',
        },
        inlayHints = {
            enable = true,
            typeHints = true,
            chainingHints = true,
            parameterHints = true,
            otherHints = true,
        },
        procMacro = {
            enable = true,
        }
    }
})

vim.diagnostic.config({
    virtual_text = {
        severity = { {
            max = vim.diagnostic.severity.ERROR,
            min = vim.diagnostic.severity.WARN,
        } },
    },
    underline = true,
    float = {
        border = 'solid',
    },
    severity_sort = true,
})

vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
            }
        }
    }
})

--vim.lsp.config('ts_ls', {
--    settings = {
--        root_dir = function() return vim.loop.cwd() end
--    }
--})

vim.lsp.enable({ "lua_ls", "rust_analyzer", "basedpyright", "ts_ls" })

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        -- inlay hints
        if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end

        -- auto completion
        if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end

        -- some additional keymaps
        --
        local nmap = function(keys, fn, desc)
            vim.keymap.set('n', keys, fn, { buffer = args.buf, desc = desc })
        end

        nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        --nmap('gr', '<cmd>Pick lsp scope="references"<CR>', '[G]oto [R]eferences')
        nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
        nmap('<leader>e', vim.diagnostic.open_float, '[E]rrors')
        --{ desc = '[E]rrors', noremap = true, silent = true, buffer = args.buf })
    end
})

-- fucking telescope has some deprecated features that emit warnings all the time
local og_notify = vim.notify
vim.notify = function(msg, ...)
    if msg and (msg:match('position_encoding param')) then
        return
    end
    return og_notify(msg, ...)
end

-- treesitter
--
require('nvim-treesitter.configs').setup({
    ensure_installed = { 'lua', 'python', 'rust' },
    auto_install = false,
    highlight = { enable = true },
    indent = { enable = true },
})


-- Restore the cursor position after closing a file
--
vim.api.nvim_create_autocmd('BufRead', {
    callback = function(opts)
        vim.api.nvim_create_autocmd('BufWinEnter', {
            once = true,
            buffer = opts.buf,
            callback = function()
                local ft = vim.bo[opts.buf].filetype
                local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
                if
                    not (ft:match('commit') and ft:match('rebase'))
                    and last_known_line > 1
                    and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
                then
                    vim.api.nvim_feedkeys([[g`"]], 'x', false)
                end
            end,
        })
    end,
})

require('colorblocks').setup()
