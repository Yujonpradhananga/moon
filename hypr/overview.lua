-- layout-switcher.lua

local layouts = { "dwindle", "master", "scrolling", "monocle", "orbit" }
local current = 1

local function get_ws()
	return tostring(hl.get_active_workspace().id)
end

local function set_layout(name)
	hl.workspace_rule({ workspace = get_ws(), layout = name })
	hl.notification.create({ text = "Layout: " .. name, timeout = 1500, icon = "ok" })
end
hl.bind("SUPER + N", function()
	current = (current % #layouts) + 1
	set_layout(layouts[current])
end)

hl.bind("SUPER + SHIFT + N", function()
	current = ((current - 2) % #layouts) + 1
	set_layout(layouts[current])
end)
