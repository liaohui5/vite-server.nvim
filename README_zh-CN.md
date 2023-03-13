## 介绍

[English](https://github.com/liaohui5/vite-server.nvim/blob/main/README.md) | 中文

启动一个 [vite](https://vitejs.dev/) 服务, 就像 VSCode [LiveServer](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) 插件的效果

## 依赖

- [vite](https://vitejs.dev/)

```js
npm i -g vite
```

## 安装

```lua
-- use packer

use({ "liaohui5/vite-server.nvim" })
```

## 配置

```lua
require("vite-server").setup({
  -- 查看 vite 文档: https://vitejs.dev/guide/cli.html
  -- 目前只支持: port,open,force,cors,base
  vite_cli_opts = {
    port = 8888,
    open = true,
    force = true,
    cors = false,
    base = "/",
  },
  show_cmd = true, -- 查看执行的命令如: vite . --port=888 xxxx
  deatch_process_on_exit = true, -- 退出编辑器时,停止 vite 服务
  root_path = function()
    -- vite 运行的目录, like ~/Desktop/codes

    -- 如果想要在项目根目录运行
    -- return table.remove(vim.fn.split(vim.fn.getcwd(), "/"))

    -- 当前执行目录的buffer所在的目录(默认值)
    return fn.expand("%:p:h")
  end,
  hooks = {
    -- 启动后执行
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
