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
    local owner = v.content_parsed.owner
    local is_cvm = false
    if
      owner == "jelifzhang"
      or owner == "belleshen"
      or owner == "sherrzhang"
      or owner == "billychan"
      or owner == "oogwu"
      or owner == "wadezheou"
      or owner == "andylliu"
      or owner == "kbryanzhang"
    then
      is_cvm = true
    end
    if is_cvm and v.content_parsed.id and createdate >= fromdate and createdate <= todate then
      table.insert(
        ret,
        "| " .. table.concat({ "规则新建", v.content_parsed.id, v.content_parsed.title, owner }, " | ") .. " |"
      )
    elseif is_cvm and v.content_parsed.id and updatedate >= fromdate and updatedate <= todate then
      table.insert(
        ret,
        "| " .. table.concat({ "规则优化", v.content_parsed.id, v.content_parsed.title, owner }, " | ") .. " |"
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
    local _1, _2 = string.match(v, "%s*CVM流程诊断助手规则 (%d+-%d+-%d+) ~ (%d+-%d+-%d+)%s*")
    return _1 and _2
  end, lines)
  if #matched_lines == 0 then
    return nil
  end

  local line = matched_lines[1]
  local fromdt, todt = string.match(line, "%s*CVM流程诊断助手规则 (%d+-%d+-%d+) ~ (%d+-%d+-%d+)%s*")
  return fetch_ticket_rules(fromdt, todt)
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

-- 尝试解析为工单复盘信息写入sql
function ticket.try_parse_ticket_review(lines)
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

return ticket
