return {
  {
    -- Alpine.js support
    'akinsho/toggleterm.nvim',
    optional = true,
  },
  {
    -- Enhanced JavaScript/Alpine.js highlighting
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        'javascript',
        'typescript',
        'html',
        'css',
        'scss',
      })
    end,
  },
  {
    -- Alpine.js snippets and utilities
    'L3MON4D3/LuaSnip',
    optional = true,
    config = function()
      local ls = require('luasnip')
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node
      
      -- Alpine.js snippets
      ls.add_snippets('html', {
        s('x-data', {
          t('x-data="{ '),
          i(1, 'property: value'),
          t(' }"'),
        }),
        s('x-show', {
          t('x-show="'),
          i(1, 'condition'),
          t('"'),
        }),
        s('x-if', {
          t('x-if="'),
          i(1, 'condition'),
          t('"'),
        }),
        s('x-for', {
          t('x-for="'),
          i(1, 'item'),
          t(' in '),
          i(2, 'items'),
          t('"'),
        }),
        s('x-on', {
          t('x-on:'),
          i(1, 'event'),
          t('="'),
          i(2, 'handler'),
          t('"'),
        }),
        s('@click', {
          t('@click="'),
          i(1, 'handler'),
          t('"'),
        }),
        s('x-model', {
          t('x-model="'),
          i(1, 'property'),
          t('"'),
        }),
        s('x-text', {
          t('x-text="'),
          i(1, 'property'),
          t('"'),
        }),
        s('x-html', {
          t('x-html="'),
          i(1, 'property'),
          t('"'),
        }),
        s('x-bind', {
          t('x-bind:'),
          i(1, 'attribute'),
          t('="'),
          i(2, 'expression'),
          t('"'),
        }),
        s('alpine-component', {
          t('<div x-data="{ '),
          i(1, 'open: false'),
          t(' }">'),
          t({'', '    '}),
          i(2, '<!-- Alpine component content -->'),
          t({'', '</div>'}),
        }),
      })
      
      -- Livewire snippets
      ls.add_snippets('html', {
        s('wire:model', {
          t('wire:model="'),
          i(1, 'property'),
          t('"'),
        }),
        s('wire:click', {
          t('wire:click="'),
          i(1, 'method'),
          t('"'),
        }),
        s('wire:submit', {
          t('wire:submit.prevent="'),
          i(1, 'method'),
          t('"'),
        }),
        s('wire:loading', {
          t('wire:loading'),
          i(1, '.class="opacity-50"'),
        }),
        s('wire:target', {
          t('wire:target="'),
          i(1, 'method'),
          t('"'),
        }),
        s('wire:key', {
          t('wire:key="'),
          i(1, 'unique-key'),
          t('"'),
        }),
        s('wire:ignore', {
          t('wire:ignore'),
        }),
        s('livewire-component', {
          t('<div>'),
          t({'', '    '}),
          i(1, '<!-- Livewire component content -->'),
          t({'', '    @if($errors->any())'}),
          t({'', '        <div class="alert alert-danger">'}),
          t({'', '            @foreach($errors->all() as $error)'}),
          t({'', '                <p>{{ $error }}</p>'}),
          t({'', '            @endforeach'}),
          t({'', '        </div>'}),
          t({'', '    @endif'}),
          t({'', '</div>'}),
        }),
      })
      
      -- PHP Livewire snippets
      ls.add_snippets('php', {
        s('livewire-component', {
          t('<?php'),
          t({'', '', 'namespace App\\Livewire;'}),
          t({'', '', 'use Livewire\\Component;'}),
          t({'', '', 'class '}),
          i(1, 'ComponentName'),
          t(' extends Component'),
          t({'', '{'}),
          t({'', '    public function render()'}),
          t({'', '    {'}),
          t({'', '        return view(\'livewire.'}),
          f(function(args)
            return args[1][1]:lower():gsub('(%l)(%u)', '%1-%2'):lower()
          end, {1}),
          t('\');'),
          t({'', '    }'}),
          t({'', '}'}),
        }),
        s('livewire-property', {
          t('public $'),
          i(1, 'property'),
          t(';'),
        }),
        s('livewire-method', {
          t('public function '),
          i(1, 'methodName'),
          t('()'),
          t({'', '{'}),
          t({'', '    '}),
          i(2, '// Method logic'),
          t({'', '}'}),
        }),
        s('livewire-validation', {
          t('protected $rules = ['),
          t({'', '    \''}),
          i(1, 'property'),
          t('\' => \''),
          i(2, 'required|string'),
          t('\','),
          t({'', '];'}),
        }),
        s('livewire-mount', {
          t('public function mount('),
          i(1),
          t(')'),
          t({'', '{'}),
          t({'', '    '}),
          i(2, '// Mount logic'),
          t({'', '}'}),
        }),
      })
    end,
  },
  {
    -- Tailwind CSS support (commonly used with Alpine/Livewire)
    'williamboman/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        'tailwindcss-language-server',
        'emmet-ls',
      })
    end,
  },
}