local ticket = {}

local function fetch_ticket_rules(fromdate, todate)
  local curl = require("plenary/curl")
  local res = curl.get(
    "http://vsops.woa.com/api/ticket/rules/",
    { headers = { ["SECURITY-CODE"] = "32be9b5d5dfb313f843293e0cf5afd44" } }
  )
  -- 数据结构参考：https://vsops.woa.com/api/ticket/rules/
  local rules = vim.json.decode(res.body)["data"]
  local ret = {}
  table.insert(ret, "")
  table.insert(ret, "| 动作 | 规则编号 | 规则描述 | 规则维护人 |")
  table.insert(ret, "| ---- | -------- | -------- | ---------- |")
  for _, v in ipairs(rules) do
    local createdate = string.sub(v.created_time, 0, 10)
    local updatedate = string.sub(v.updated_time, 0, 10)
    if v.content_parsed.id and createdate >= fromdate and createdate <= todate then
      table.insert(
        ret,
        "| "
          .. table.concat(
            { "规则新建", v.content_parsed.id, v.content_parsed.title, v.content_parsed.owner },
            " | "
          )
          .. " |"
      )
    elseif v.content_parsed.id and updatedate >= fromdate and updatedate <= todate then
      table.insert(
        ret,
        "| "
          .. table.concat(
            { "规则优化", v.content_parsed.id, v.content_parsed.title, v.content_parsed.owner },
            " | "
          )
          .. " |"
      )
    end
  end
  return ret
end

local function filter(fun, tbl)
  local res = {}
  for _, v in ipairs(tbl) do
    if fun(v) then
      table.insert(res, v)
    end
  end
  return res
end

-- 尝试解析为CVM流程诊断助手规则更新信息
function ticket.try_parse_ticket_rules(lines)
  local matched_lines = filter(function(v)
    local _1, _2 = string.match(v, "%s*CVM流程诊断助手规则 (%d+/%d+/%d+) ~ (%d+/%d+/%d+)%s*")
    return _1 and _2
  end, lines)
  if #matched_lines == 0 then
    return nil
  end

  local line = matched_lines[1]
  local fromdt, todt = string.match(line, "%s*CVM流程诊断助手规则 (%d+/%d+/%d+) ~ (%d+/%d+/%d+)%s*")
  fromdt = string.gsub(fromdt, "/", "-")
  todt = string.gsub(todt, "/", "-")
  return fetch_ticket_rules(fromdt, todt)
end

return ticket
