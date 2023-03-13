## introction

English | [中文](https://github.com/liaohui5/vite-server.nvim/blob/main/README_zh-CN.md)

start a [vite](https://vitejs.dev/) server, like VSCode [LiveServer Plugin](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer)

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
  -- only supported: port,open,force,cors,base
  vite_cli_opts = {
    port = 8888,
    open = true,
    force = true,
    cors = false,
    base = "/",
  },
  show_cmd = true, -- show execute command in message
  deatch_process_on_exit = true, -- deatch process on exit nvim
  root_path = function()
    -- run vite command root directory, like ~/Desktop/codes

    -- project root directory
    -- return table.remove(vim.fn.split(vim.fn.getcwd(), "/"))

    -- current file directory (default)
    return fn.expand("%:p:h")
  end,
  hooks = {
    -- after server started
    on_started = nil, --- or function(job_id, config) end,

    -- :h jobstart-options
    on_stdout = nil,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        echo("server stoped")
        return
      end
    end,

    on_stderr = function(_, data)
      if not data or data[1] == "" then
        echo("server start failed")
        return
      end
    end,
  },
})
```
