local sre = {}

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

-- 尝试解析为数据库连接命令
function sre.try_parse_mysql(lines)
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

return sre
