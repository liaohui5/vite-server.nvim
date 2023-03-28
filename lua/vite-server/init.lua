local M = {}
local api, fn = vim.api, vim.fn
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
    M.is_started = true
    started_on_url = M.gen_url(M.config.vite_cli_opts)
  else
    M.is_started = false
    started_on_url = ""
  end
end

-- status
M.is_started = false

-- vite command config
M.config = {
  -- show vite documention: https://vitejs.dev/guide/cli.html
  -- only supported port,open,force,cors,base,strictPort
  vite_cli_opts = {
    port = 8888,
    open = true,
    force = true,
    strictPort = true,
    cors = false,
    base = "/",
  },
  show_cmd = true, -- show execute command in message
  deatch_process_on_exit = false, -- deatch process on exit nvim
  root_path = function()
    -- run vite command root directory, like [~/Desktop/codes]
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
      end
    end,

    on_stderr = function(_, data)
      echo("an error has occurred")
    end,
  },
}

-- local generate url
M.gen_url = function(config)
  return string.format("http://localhost:%s%s", config.port, config.base)
end

-- generate command
M.gen_command = function(config, path)
  local cmd = "vite "

  -- root path
  if type(path) == "string" then
    cmd = cmd .. path
  else
    -- not provide path use config root_dir function
    if type(config.root_path) == "function" then
      cmd = cmd .. config.root_path()
    else
      cmd = cmd .. fn.expand("%:p:h")
    end
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
    strictPort = config.strictPort,
  }
  for key, value in pairs(flags) do
    if value then
      cmd = string.format("%s --%s ", cmd, key)
    end
  end
  return cmd
end

-- start
M.start = function(path)
  if not command_exists() then
    echo("please install vite first!")
    return
  end

  if M.is_started then
    echo("server is running on: " .. started_on_url)
    return
  end

  -- generate commmand string && jobstart options
  local config, vite_cli_opts, hooks = M.config, M.config.vite_cli_opts, M.config.hooks
  local cmd = M.gen_command(vite_cli_opts, path)
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
  if not M.is_started then
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
