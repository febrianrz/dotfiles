return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    -- nvim-notify adalah backend yang bagus untuk notifikasi
    'rcarriga/nvim-notify',
  },
  opts = {
    -- Konfigurasi tampilan command line di tengah
    cmdline = {
      enabled = true,
      view = 'cmdline_popup',
      opts = {
        border = {
          style = 'rounded',
        },
      },
      format = {
        cmdline = { icon = '', lang = 'vim' },
        search_down = { icon = ' ', lang = 'regex' },
        search_up = { icon = ' ', lang = 'regex' },
        filter = { icon = '', lang = 'vim' },
        lua = { icon = '', lang = 'lua' },
        help = { icon = '' },
      },
    },

    -- Integrasi dengan LSP untuk menampilkan pesan 'loading', 'hover', dll.
    lsp = {
      progress = {
        enabled = true,
        -- Opsi untuk menampilkan spinner di lualine
        view = {
          render = 'compact',
          position = { row = 1, col = '100%' },
        },
      },
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true,
      },
      hover = {
        enabled = true,
      },
    },

    -- Pesan notifikasi akan menggunakan nvim-notify sebagai backend
    messages = {
      enabled = true,
      view_error = 'notify',
      view_warn = 'notify',
      view_history = 'messages',
      view_search = 'virtualtext',
    },

    -- Preset untuk mendapatkan pengalaman out-of-the-box terbaik
    presets = {
      bottom_search = true, -- Pencarian tetap di bawah agar familiar
      command_palette = true, -- Tampilan command palette modern
      long_message_to_split = true, -- Pesan panjang akan di-split
      inc_rename = true, -- Tampilan live-rename saat mengganti nama variabel
      lsp_doc_border = true, -- Border untuk dokumentasi LSP
    },

    -- Aturan untuk mengarahkan pesan tertentu ke tampilan tertentu
    routes = {
      {
        -- Jangan tampilkan popup untuk pesan yang tidak penting
        filter = { event = 'msg_show', kind = 'search_count' },
        opts = { skip = true },
      },
    },
  },
  -- Tambahkan beberapa keymap yang berguna
  config = function(_, opts)
    require('noice').setup(opts)

    -- Keymap untuk melihat riwayat pesan noice
    vim.keymap.set('n', '<leader>so', function()
      require('noice').cmd 'history'
    end, { desc = 'Noice: History' })

    -- Keymap untuk menutup semua notifikasi
    vim.keymap.set('n', '<leader>sd', function()
      require('noice').cmd 'dismiss'
    end, { desc = 'Noice: Dismiss All' })
  end,
}
