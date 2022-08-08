
  local function float2bin(n)
    if math.abs(n) == math.huge then
      -- plus or minus infinity
      return n > 0 and 'inf' or '-inf'
    end
    if not n == n then
      -- nan
      return 'nan'
    end
  
    local m, e = math.frexp(n)
    local result = int2bin(math.abs(m * 2^53))
  
    local len = #result
    if e > 53 then
      -- big number, add zeros on the right
      result = result .. ('0'):rep(e - 53)
    elseif e < 1 then
      -- small number, add zeros on the left
      result = ('0'):rep(1 - e) .. result
      e = 1
    end
  
    -- Add the point
    result = result:sub(1, e) .. '.' .. result:sub(e + 1)
  
    -- remove zeros on the right including point
    result = result:gsub('%.?0*$', '')
  
    if n < 0 then
      return '-' .. result
    end
    return result
  end
  
math.frexp = (function (n)
    --decompose a number into tails and exponents. returns m and e so such that m * 2^e = n
    local m, e = 0, 0
    while n ~= 0 do
      m = m + n
      n = math.floor(n / 2)
      e = e + 1
    end
    return m, e
end)
  