-- @description regionnamer: create pickup region named from markers inside time selection
-- @author Pablo Gallegos Noreña

-- ---------- CONFIG ----------
WIN_SEC = 600     -- search window (segs)
PREFIX  = ""      -- prefijo opcional de narrador (ej. "C"), para libros multinarrador

-- ---------- TEXT ----------
local function trim(s)
  if not s or s == "" then return "" end
  return (s:match("^%s*(.-)%s*$") or "")
end

local function is_p(s)
  return s and s:sub(1, 1):lower() == "p"
end

-- Devuelve: token, tipo ("a" = arabic, "r" = roman) o nil
local function tok(name)
  if not name or name == "" then return nil end

  local s = name
  if is_p(s) then s = s:sub(2) end
  s = trim(s)

  local d = s:match("^(%d%d?%d?)")
  if d and d ~= "" then
    local n = tonumber(d)
    if n then return string.format("%03d", n), "a" end
  end

  local r = s:match("^([IVXLCDMivxlcdm]+)")
  if r and #r <= 7 then return r, "r" end

  return nil
end

-- ---------- MARKERS ----------
local function all_marks()
  local out = {}
  local _, nm, nr = reaper.CountProjectMarkers(0)
  for i = 0, (nm + nr - 1) do
    local _, isr, pos, rend, name = reaper.EnumProjectMarkers2(0, i)
    out[#out + 1] = { r = isr, p = pos, e = rend, n = name or "" }
  end
  return out
end

local function in_sel(a, b)
  local m = {}
  for _, x in ipairs(all_marks()) do
    if (not x.r) and x.p >= a and x.p <= b then
      local t, k = tok(x.n)
      if t then m[#m + 1] = { p = x.p, t = t, k = k } end
    end
  end
  table.sort(m, function(u, v) return u.p < v.p end)
  return m
end

-- prev = duplicados detrás; fut = duplicados delante
local function dup(base_t, base_k, a, b)
  local prev, fut = {}, {}

  for _, x in ipairs(all_marks()) do
    if not x.r then
      if x.p < a and (a - x.p) <= WIN_SEC then
        local t, k = tok(x.n)
        if t and k == base_k then prev[#prev + 1] = { p = x.p, t = t } end
      elseif x.p > b and (x.p - b) <= WIN_SEC then
        local t, k = tok(x.n)
        if t and k == base_k then fut[#fut + 1] = { p = x.p, t = t } end
      end
    end
  end

  table.sort(prev, function(u, v) return u.p > v.p end)
  table.sort(fut,  function(u, v) return u.p < v.p end)

  local c = 0
  if base_k == "a" then
    local bn = tonumber(base_t) or 0
    for _, x in ipairs(prev) do
      local xn = tonumber(x.t) or 0
      if xn == bn then c = c + 1
      elseif xn < bn then break end
    end
  else
    for _, x in ipairs(prev) do
      if x.t == base_t then c = c + 1 else break end
    end
  end

  local has_f = false
  if c == 0 then
    if base_k == "a" then
      local bn = tonumber(base_t) or 0
      for _, x in ipairs(fut) do
        local xn = tonumber(x.t) or 0
        if xn == bn then has_f = true; break
        elseif xn > bn then break end
      end
    else
      if fut[1] and fut[1].t == base_t then has_f = true end
    end
  end

  return c, has_f
end

-- ---------- NAME ----------
local function letter(i)
  if i < 1 or i > 26 then return "" end
  return string.char(96 + i) -- 1 -> a
end

local function build(m, prev_n, has_f)
  local base = m[1].t
  local start = 0

  if prev_n > 0 then
    start = prev_n + 1
  elseif has_f then
    start = 1
  end

  if #m == 1 then
    return base .. letter(start)
  end

  local parts = {}
  for i = 1, #m do
    local l = letter(start + i)
    if i == 1 then parts[#parts + 1] = base .. l
    else parts[#parts + 1] = l end
  end
  return table.concat(parts, ", ")
end

-- ---------- EJECUCIÓN ----------
local function main()
  local a, b = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  if a == b then
    reaper.ShowMessageBox(
      "Selecciona un rango (time selection) para la oración del pickup.",
      "regionnamer",
      0
    )
    return
  end

  local m = in_sel(a, b)
  if #m == 0 then
    reaper.ShowMessageBox(
      "No hay marcadores válidos dentro del rango.\nEjemplos: P12, 12, IV, XII",
      "regionnamer",
      0
    )
    return
  end

  local prev_n, has_f = dup(m[1].t, m[1].k, a, b)
  local name = build(m, prev_n, has_f)

  local pre = trim(PREFIX)
  if pre ~= "" then name = pre .. name end

  reaper.Undo_BeginBlock()
  reaper.AddProjectMarker2(0, true, a, b, name, -1, 0)
  reaper.Undo_EndBlock("regionnamer: " .. name, -1)
end

main()
