local M = {}
local api, fn = vim.api, vim.fn
local is_started = false
local job_id = nil
local started_on_url = ""

-- init user commands
local init_commands = function()
  vim.api.nvim_create_user_command("ViteServerStart", M.start, {})
  vim.api.nvim_create_user_command("ViteServerStop", M.stop, {})
end

-- init configs
local init_configs = function(user_config)
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

-- ceho message to command line
local echo = function(msg)
  print(string.format("[vite-server]: %s", msg))
end

-- check command exists
local command_exists = function()
  return fn.executable("vite")
end

-- set status
local function set_status(status)
  if status then
    is_started = true
    started_on_url = M.gen_url(M.config.vite_cli_opts)
  else
    is_started = false
    started_on_url = ""
  end
end

-- vite command config
M.config = {
  -- show vite documention: https://vitejs.dev/guide/cli.html
  -- only supported port,open,force,cors,base
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
    -- run vite command root directory, like [~/Desktop/codes]
    return fn.expand("%:p:h")
  end,
  hooks = {
    on_started = nil, --- or function(job_id, config) end,
    on_stdout = nil,

    -- :h jobstart-options
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
}

-- local generate url
M.gen_url = function(config)
  return string.format("http://localhost:%s%s", config.port, config.base)
end

-- generate command
M.gen_command = function(config)
  local cmd = "vite "
  local fmt = string.format

  -- root path
  if type(config.root_path) == "function" then
    cmd = cmd .. config.root_path()
  else
    cmd = cmd .. fn.expand("%:p:h")
  end

  -- port / base
  local args = {
    port = config.port,
    base = config.base,
  }
  for key, value in pairs(args) do
    cmd = string.format("%s --%s=%s ", cmd, key, value)
  end

  -- open/force/cors
  local flags = {
    open = config.open,
    force = config.force,
    cors = config.cors,
  }
  for key, value in pairs(flags) do
    if value then
      cmd = string.format("%s --%s ", cmd, key)
    end
  end
  return cmd
end

-- start
M.start = function()
  if not command_exists() then
    echo("please install vite first!")
    return
  end

  if is_started then
    echo("server is running on: " .. started_on_url)
    return
  end

  -- generate commmand string && jobstart options
  local config, vite_cli_opts, hooks = M.config, M.config.vite_cli_opts, M.config.hooks
  local cmd = M.gen_command(config.vite_cli_opts)
  local opts = {
    detach = config.deatch_process_on_exit,
  }
  for key, value in pairs(hooks) do
    if key ~= "on_started" and type(value) == "function" then
      ---@diagnostic disable-next-line: assign-type-mismatch
      opts[key] = value
    end
  end

  -- start server
  job_id = fn.jobstart(cmd, opts)

  -- print tip messages
  set_status(true)
  local tips = "server started on: " .. started_on_url
  if config.show_cmd then
    tips = string.format("%s, command: %s", tips, cmd)
  end
  echo(tips)

  -- call on_started hook
  if type(hooks.on_started) == "function" then
    hooks.on_started(job_id, config)
  end
end

-- stop server
M.stop = function()
  if not is_started then
    echo("server is not started")
    return
  end
  fn.jobstop(job_id)
  set_status(false)
end

-- setup
M.setup = function(user_config)
  init_commands()
  init_configs(user_config)
end

return M
