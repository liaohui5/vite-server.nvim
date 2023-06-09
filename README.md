## introction

English | [中文](https://github.com/liaohui5/vite-server.nvim/blob/main/README_zh-CN.md)

start a [vite](https://vitejs.dev/) server, like VSCode [LiveServer Plugin](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer)

## preview

https://user-images.githubusercontent.com/29266093/224965117-32174c6e-bb0d-4cef-aa3a-428d9972d0d2.mp4

## dependencies

- [vite](https://vitejs.dev/)

```js
npm i -g vite
```

## installation

```lua
-- use packer

use({ "liaohui5/vite-server.nvim" })
```

## configuration

```lua
require("vite-server").setup({
  -- read vite documention: https://vitejs.dev/guide/cli.html
  -- only supported: port,open,force,cors,base,strictPort
  vite_cli_opts = {
    -- Note: The --strictPort parameter is added, https://v3.vitejs.dev/config/server-options.html#server-strictport
    --       If the strictPort parameter is not added, the obtained url will be inaccurate.
    --       so please ensure that the port is not useing
    port = 8888,
    open = true,
    force = true,
    cors = false,
    strictPort = true,
    base = "/",
  },
  show_cmd = true, -- show execute command in message
  deatch_process_on_exit = false, -- see `:h jobstart-options` deatch option
  root_path = function()
    -- run vite command root directory, like ~/Desktop/codes

    -- project root directory
    -- return vim.fn.getcwd()

    -- current file directory (default)
    return vim.fn.expand("%:p:h")
  end,
  hooks = {
    -- after server started
    on_started = nil, --- or function(job_id, config) end,

    -- :h jobstart-options
    on_stdout = nil,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        print("server stoped")
      end
    end,

    on_stderr = function(_, data)
      print("an error has occurred")
    end,
  },
})
```

## use

- start vite server: `ViteServerStart` or `:lua require('vite-server').start()`
- stop vite server: `ViteServerStop` or `:lua require('vite-server').stop()`

## display status in lualine

- [lualine](https://github.com/nvim-lualine/lualine.nvim)

```lua
-- vite-server.nvim status
local function vite_server_status()
  local ok, vs = pcall(require, "vite-server")
  local str = ""
  if ok then
    str = ""
  end

  if vs.is_started then
    str = str .. " " .. vs.gen_url(vs.config.vite_cli_opts)
  end

  return str
end

-- lualine setup sections
require('lualine').setup({
-- ...
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = { vite_server_status , 'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
-- ...
})
```

## Q & A

- Q: How to display the output of vite to the nvim command line message

```lua
--- ...
  on_stdout = function(_, data)
    -- all output
    print(table.concat(data))
  end,
  on_stderr = function(_, data)
    -- error output
    print(table.concat(data))
  end
-- ...
```

- Q: After using the `:ViteServerStart` command, display `an error has occurred`
- A: Try another port, it may be that the port is occupied.

```lua
-- If the problem persists after changing the port, the following steps can be tried:
-- 1. Set show_cmd = true,
-- 2. Manually copy the command and execute it in the command line to see if the error can be resolved.
```
