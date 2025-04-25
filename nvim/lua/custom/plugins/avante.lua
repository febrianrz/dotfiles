return {
{
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  opts = {
    -- add any opts here
    -- for example
    provider = "openrouter",
    vendors = {
      ["bullnium-ai"] = {
        endpoint = "https://ai.bullnium.com/api/chat/completions", -- The full endpoint of the provider
        model = "openai-large", -- The model name to use with this provider
        api_key_name = "sk-f8e872057cf548219ef36571540178a4", -- The name of the environment variable that contains the API key
        --- This function below will be used to parse in cURL arguments.
        --- It takes in the provider options as the first argument, followed by code_opts retrieved from given buffer.
        --- This code_opts include:
        --- - question: Input from the users
        --- - code_lang: the language of given code buffer
        --- - code_content: content of code buffer
        --- - selected_code_content: (optional) If given code content is selected in visual mode as context.
        ---@type fun(opts: AvanteProvider, code_opts: AvantePromptOptions): AvanteCurlOutput
        parse_curl_args = function(opts, code_opts) end,
        --- This function will be used to parse incoming SSE stream
        --- It takes in the data stream as the first argument, followed by SSE event state, and opts
        --- retrieved from given buffer.
        --- This opts include:
        --- - on_chunk: (fun(chunk: string): any) this is invoked on parsing correct delta chunk
        --- - on_complete: (fun(err: string|nil): any) this is invoked on either complete call or error chunk
        ---@type fun(data_stream: string, event_state: string, opts: ResponseParser): nil
        parse_response = function(data_stream, event_state, opts) end,
        --- The following function SHOULD only be used when providers doesn't follow SSE spec [ADVANCED]
        --- this is mutually exclusive with parse_response_data
        ---@type fun(data: string, handler_opts: AvanteHandlerOptions): nil
        parse_stream_data = function(data, handler_opts) end
      },
      openrouter = {
        __inherited_from = 'openai',
        endpoint = 'https://openrouter.ai/api/v1',
        api_key_name = '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',
        model = 'deepseek/deepseek-r1-distill-qwen-32b:free',
      },
    }
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
}
