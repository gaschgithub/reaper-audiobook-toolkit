-- @description setgap_paragraph: set silence gap to randomized duration (1240–1380 ms)
-- @author Pablo Gallegos Noreña

-- ---------- CONFIG ----------
MIN_GAP = 1.240
MAX_GAP = 1.380
SHIFT_MR = true   -- mover markers/regions
EPS      = 0.0005

-- ---------- RNG ----------
local function seed()
  math.randomseed(os.time() + math.floor(reaper.time_precise() * 1000))
  math.random(); math.random(); math.random()
end

local function rnd(a, b)
  return a + (math.random() * (b - a))
end

-- ---------- ITEMS ----------
local function ipos(it)
  return reaper.GetMediaItemInfo_Value(it, "D_POSITION")
end

local function iend(it)
  return ipos(it) + reaper.GetMediaItemInfo_Value(it, "D_LENGTH")
end

local function bounds(tr, cur)
  local pe, ns = -math.huge, math.huge
  local n = reaper.CountTrackMediaItems(tr)

  for i = 0, n - 1 do
    local it = reaper.GetTrackMediaItem(tr, i)
    local p, e = ipos(it), iend(it)

    if e <= cur + EPS and e > pe then pe = e end
    if p >= cur - EPS and p < ns then ns = p end
  end

  if pe == -math.huge or ns == math.huge then return nil, nil end
  return pe, ns
end

local function shift_items(t0, d)
  if math.abs(d) < EPS then return end

  local nt = reaper.CountTracks(0)
  for t = 0, nt - 1 do
    local tr = reaper.GetTrack(0, t)
    local ni = reaper.CountTrackMediaItems(tr)

    for i = 0, ni - 1 do
      local it = reaper.GetTrackMediaItem(tr, i)
      local p = ipos(it)
      if p >= t0 - EPS then
        reaper.SetMediaItemInfo_Value(it, "D_POSITION", p + d)
      end
    end
  end
end

local function shift_mr(t0, d)
  if (not SHIFT_MR) or math.abs(d) < EPS then return end

  local _, nm, nr = reaper.CountProjectMarkers(0)
  local tot = nm + nr

  for idx = 0, tot - 1 do
    local _, isr, pos, rend, name, num, col = reaper.EnumProjectMarkers3(0, idx)

    if not isr then
      if pos >= t0 - EPS then
        reaper.SetProjectMarkerByIndex2(0, idx, false, pos + d, 0, num, name, col, 0)
      end
    else
      local p2, e2 = pos, rend
      if pos >= t0 - EPS then
        p2, e2 = pos + d, rend + d
      elseif rend >= t0 - EPS then
        e2 = rend + d
      end

      if p2 ~= pos or e2 ~= rend then
        reaper.SetProjectMarkerByIndex2(0, idx, true, p2, e2, num, name, col, 0)
      end
    end
  end
end

-- ---------- EJECUCIÓN ----------
local function main()
  local tr = reaper.GetSelectedTrack(0, 0)
  if not tr then
    reaper.ShowMessageBox("Selecciona el track de narración.", "setgap_paragraph", 0)
    return
  end

  local cur = reaper.GetCursorPosition()
  local pe, ns = bounds(tr, cur)

  if not pe or not ns then
    reaper.ShowMessageBox("Pon el cursor en el silencio entre dos items.", "setgap_paragraph", 0)
    return
  end

  local gap = ns - pe
  if gap < -EPS then
    reaper.ShowMessageBox("No hay gap válido (items traslapados).", "setgap_paragraph", 0)
    return
  end

  seed()
  local tgt = rnd(MIN_GAP, MAX_GAP)
  local d = tgt - gap

  reaper.Undo_BeginBlock()
  shift_items(ns, d)
  shift_mr(ns, d)
  reaper.UpdateArrange()
  reaper.Undo_EndBlock(string.format("setgap_paragraph: %.3fs", tgt), -1)
end

main()
