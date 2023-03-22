## 介绍

[English](https://github.com/liaohui5/vite-server.nvim/blob/main/README.md) | 中文

启动一个 [vite](https://vitejs.dev/) 服务, 就像 VSCode [LiveServer](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) 插件的效果

## 预览

https://user-images.githubusercontent.com/29266093/224965117-32174c6e-bb0d-4cef-aa3a-428d9972d0d2.mp4

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
    -- Note: 默认是加了 --strictPort 参数的,
    --       如果不加这个参数, 会导致 url 获取不准确
    --       所以,请确保 port 是没有被使用的
    port = 8888,
    open = true,
    force = true,
    cors = false,
    base = "/",
  },
  show_cmd = true, -- 查看执行的命令如: vite . --port=888 xxxx
  deatch_process_on_exit = false, -- 查看 `:h jobstart-options` detach
  root_path = function()
    -- vite 运行的目录, like ~/Desktop/codes

    -- 如果想要在项目根目录运行
    -- return return vim.fn.getcwd()

    -- 当前执行目录的buffer所在的目录(默认值)
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

## 使用

- 启动服务: `ViteServerStart` or `:lua require('vite-server').start()`
- 停止服务: `ViteServerStop` or `:lua require('vite-server').stop()`

## 在状态栏中显示状态

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

## 常见问题

- Q: 如何将 vite 的命令行输出, 显示到 nvim 的命令行中

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

- Q: 使用 `:ViteServerStart` 显示 `an error has occurred`
- A: 换另外一个端口试一下, 可能是端口被占用了

```lua
-- 如果换端口之后, 依然没有解决, 可以尝试以下操作
-- 1. 设置 show_cmd = true,
-- 2. 手动复制命令到命令行执行一下, 看报错解决
```
