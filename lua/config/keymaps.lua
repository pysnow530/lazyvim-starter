-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local Util = require("lazyvim.util")
local ticket = require("my.ticket")

vim.keymap.set("i", "jk", "<esc>")

vim.keymap.set("n", "<leader>j", ":w<cr>")
vim.keymap.set("n", "<leader>k", ":q<cr>")
vim.keymap.set("n", "<leader>b", ":b#<cr>")

-- 剪切板操作 (for neovide)
-- ref: https://github.com/neovide/neovide/issues/113
vim.keymap.set("v", "<C-c>", '"+y')
vim.keymap.set({ "i", "c" }, "<C-v>", "<c-r>+")

-- 版本管理
vim.keymap.set("n", "<leader>v", function()
  Util.terminal({ "lazygit" }, { cwd = Util.root(), esc_esc = false, ctrl_hjkl = false })
end)

-- python
vim.keymap.set("n", "<localleader>r", function()
  if vim.bo.filetype == "python" then
    vim.api.nvim_command("!python3 %")
  elseif vim.bo.filetype == "lua" then
    vim.api.nvim_command("luafile %")
  end
end)
vim.keymap.set("v", "<localleader>r", ":!python3<cr>")

-- 解析配置格式的字典（支持toml、json、python字典）
-- host = "host1"\nport = 8888 转换为 { host = "host1", port = "8888"}
local function parse_config_table(lines)
  local tb = {}

  for _, line in ipairs(lines) do
    -- toml
    local k1, v1 = string.match(line, '%s*([%w_]+)%s*=%s*"(.*)"')
    local k2, v2 = string.match(line, "%s*([%w_]+)%s*=%s*'(.*)'")
    local k3, v3 = string.match(line, "%s*([%w_]+)%s*=%s*(.*)")
    -- python
    local k4, v4 = string.match(line, "%s*'([%w_]+)'%s*:%s*'(.*)',")
    local k5, v5 = string.match(line, "%s*'([%w_]+)'%s*:%s*(.*),")
    -- json
    local k6, v6 = string.match(line, '%s*"([%w_]+)"%s*:%s*"(.*)",')
    local k7, v7 = string.match(line, '%s*"([%w_]+)"%s*:%s*(.*),')
    local k8, v8 = string.match(line, '%s*"([%w_]+)"%s*:%s*"(.*)"')
    local k9, v9 = string.match(line, '%s*"([%w_]+)"%s*:%s*(.*)')
    if k1 and v1 then
      tb[k1] = v1
    elseif k2 and v2 then
      tb[k2] = v2
    elseif k3 and v3 then
      tb[k3] = v3
    elseif k4 and v4 then
      tb[k4] = v4
    elseif k5 and v5 then
      tb[k5] = v5
    elseif k6 and v6 then
      tb[k6] = v6
    elseif k7 and v7 then
      tb[k7] = v7
    elseif k8 and v8 then
      tb[k8] = v8
    elseif k9 and v9 then
      tb[k9] = v9
    end
  end

  return tb
end

local function parse_ticket_review(lines)
  local tb = {}

  for _, line in ipairs(lines) do
    local ticket_id = string.match(line, "%s*https://andon.woa.com/ticket/detail/%?id=(%d+)&sign=.*")
    if ticket_id then
      tb.ticket_id = ticket_id
    elseif string.find(line, "不合理原因") or string.find(line, "待办") then
      tb.remark = line
    else
      tb.tag_topic = line
    end
  end

  return tb
end

-- 尝试解析为数据库连接命令
local function try_parse_mysql(lines)
  local tb = parse_config_table(lines)

  if not tb.host or not tb.port or not tb.user then
    return nil
  end

  if not tb.passwd and not tb.password then
    return nil
  end

  if not tb.db and not tb.db_name then
    return nil
  end

  return "mysql -h"
    .. tb.host
    .. " -P"
    .. tb.port
    .. " -u"
    .. tb.user
    .. " -p'"
    .. (tb.passwd or tb.password)
    .. "' "
    .. (tb.db and tb.db or tb.db_name)
    .. " -Nse 'select 1'"
end

-- 尝试解析为工单复盘信息写入sql
local function try_parse_ticket_review(lines)
  local ticket_review = parse_ticket_review(lines)

  if not ticket_review.ticket_id then
    return nil
  end

  if not ticket_review.tag_topic and not ticket_review.remark then
    return nil
  end

  local set_fields = {}
  if ticket_review.tag_topic then
    table.insert(set_fields, 'tag_topic = "' .. ticket_review.tag_topic .. '"')
  end
  if ticket_review.remark then
    table.insert(set_fields, 'remark = "' .. ticket_review.remark .. '"')
    if string.find(ticket_review.remark, "不合理原因") then
      table.insert(set_fields, "unreasonable = 1")
    end
  end
  local sql = "UPDATE ticket_review SET "
    .. table.concat(set_fields, ", ")
    .. " WHERE ticket_id = "
    .. ticket_review.ticket_id
    .. ";"
  return sql
end

-- 获取选择范围及文本
-- 参考: https://github.com/neovim/neovim/pull/21115
local function get_selected_lines()
  local _, ls, _ = unpack(vim.fn.getpos("v"))
  local _, le, _ = unpack(vim.fn.getpos("."))
  local l1 = math.min(ls, le)
  local l2 = math.max(ls, le)
  local lines = vim.api.nvim_buf_get_lines(0, l1 - 1, l2, true)
  return lines
end

local function append_lines(lines)
  if type(lines) == "string" then
    lines = lines.split("\n")
  end

  local _, ls, _ = unpack(vim.fn.getpos("v"))
  local _, le, _ = unpack(vim.fn.getpos("."))
  local l1 = math.min(ls, le)
  local l2 = math.max(ls, le)

  local selected_lines = vim.api.nvim_buf_get_lines(0, l1 - 1, l2, true)

  for _, v in ipairs(lines) do
    table.insert(selected_lines, v)
  end

  vim.api.nvim_buf_set_lines(0, l1 - 1, l2, true, selected_lines)
end

-- 尝试文本转换
vim.keymap.set("v", "<leader>|", function()
  local lines = get_selected_lines()

  -- 尝试解析为数据库连接
  local res = try_parse_mysql(lines)
  if res then
    append_lines(res)
    return
  end

  -- 尝试解析为工单复盘结果写入sql
  local sql = try_parse_ticket_review(lines)
  if sql then
    append_lines(sql)
    return
  end

  -- 尝试解析为工具建设规则
  local rules = ticket.try_parse_ticket_rules(lines)
  if rules then
    append_lines(rules)
    return
  end

  append_lines("Not recognized!")
end)
