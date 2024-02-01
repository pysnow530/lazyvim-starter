local shell = {}

-- 尝试解析为shell命令并执行
function shell.try_run_shell(lines)
  local res = {}
  for _, line in ipairs(lines) do
    table.insert(res, line)
    if #line > 2 and string.sub(line, 1, 2) == "$ " then
      local cmd = string.sub(line, 3)
      local handle = io.popen(cmd)
      if not handle then
        return nil
      end
      local output = handle:read("*a")
      for outline in output:gmatch("([^\n]*)\n?") do
        table.insert(res, outline)
      end
    end
  end
  if #lines == #res then
    return nil
  else
    return res
  end
end

return shell
