-- Papa KOReader diagnostic capture.
-- Captures timestamped app-side events into independently shareable text files.
local DataStorage = require("datastorage")
local lfs = require("libs/libkoreader-lfs")
local Diagnostics = { active = false, session_dir = nil, handles = {}, buffers = {}, buffer_limit = 600 }
local parts = {
    android_window = "01_android_window.txt",
    reader = "02_reader_initialization.txt",
    crengine = "03_fonts_css_crengine.txt",
    ui_font = "04_ui_fonts.txt",
    altbar = "05_alt_status_bar.txt",
    errors = "06_performance_errors.txt",
}
local function safe(value)
    local s = tostring(value == nil and "" or value):gsub("[\r\n\t]", " ")
    if #s > 700 then s = s:sub(1, 700) .. "…" end
    return s
end
local function mkdir(path)
    if lfs.attributes(path, "mode") ~= "directory" then
        local ok = lfs.mkdir(path)
        return ok or lfs.attributes(path, "mode") == "directory"
    end
    return true
end
function Diagnostics:isActive() return self.active end
function Diagnostics:start()
    if self.active then return self.session_dir end
    local root = DataStorage:getDataDir() .. "/diagnostics"
    if not mkdir(root) then return nil, "cannot create diagnostics folder" end
    self.session_dir = root .. "/session_" .. os.date("%Y%m%d_%H%M%S")
    if not mkdir(self.session_dir) then return nil, "cannot create session folder" end
    self.active = true
    self.buffers = {}
    self:record("errors", "SESSION_START", "capture started; app-side diagnostics only")
    return self.session_dir
end
function Diagnostics:stop()
    if not self.active then return self.session_dir end
    self:record("errors", "SESSION_STOP", "capture stopped")
    self.active = false
    for _, handle in pairs(self.handles) do pcall(function() handle:flush(); handle:close() end) end
    self.handles = {}
    return self.session_dir
end
function Diagnostics:record(part, event, detail)
    if not self.active or not self.session_dir then return end
    local filename = parts[part] or parts.errors
    local line = os.date("!%Y-%m-%dT%H:%M:%SZ") .. "\t" .. safe(part) .. "\t"
        .. safe(event) .. "\t" .. safe(detail) .. "\n"
    local buffer = self.buffers[filename] or {}
    self.buffers[filename] = buffer
    buffer[#buffer + 1] = line
    if #buffer > self.buffer_limit then table.remove(buffer, 1) end
    local handle = self.handles[filename]
    if not handle then
        local ok, opened = pcall(io.open, self.session_dir .. "/" .. filename, "a")
        if not ok or not opened then return end
        handle = opened
        self.handles[filename] = handle
    end
    local ok = pcall(function() handle:write(line); handle:flush() end)
    if not ok then pcall(function() handle:close() end); self.handles[filename] = nil end
end
function Diagnostics:mark()
    self:record("errors", "USER_MARK", "manual marker from Papa KOReader Diagnostics menu")
end
function Diagnostics:exportInfo()
    if self.active then self:stop() end
    if not self.session_dir then return nil end
    local ok, handle = pcall(io.open, self.session_dir .. "/00_session_info.txt", "w")
    if not ok or not handle then return nil end
    handle:write("Papa KOReader Diagnostics\nSession folder: " .. self.session_dir .. "\n")
    handle:write("Each numbered file is an independently shareable diagnostic part.\n")
    handle:write("Times are UTC. Book contents are not intentionally recorded.\n")
    handle:close()
    return self.session_dir
end
return Diagnostics
