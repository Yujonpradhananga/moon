hl.plugin.load("/home/yujon/.local/lib/hypr/hyprglass.so")
-- Load pywal colors
-- Parse pywal colors from .conf file
local colors = {}
local f = io.open(os.getenv("HOME") .. "/.cache/wal/colors-hyprland.conf", "r")
if f then
	for line in f:lines() do
		local key, value = line:match("^%$(%w+)%s*=%s*(.+)")
		if key and value then
			colors[key] = value
		end
	end
	f:close()
end

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "eDP-1", mode = "1920x1080@165", position = "0x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1280x1024@60", position = "1920x0", scale = 1, transform = 1 })

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "foot"
local kterminal = "kitty"

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("HYPRCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_SIZE", "25")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "25")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("QT_LOGGING_RULES", "*.warning=false")

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("qs")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	xwayland = {
		enabled = true,
		use_nearest_neighbor = false,
		force_zero_scaling = true,
	},

	render = {
		cm_enabled = false,
	},

	general = {
		gaps_in = 5,
		gaps_out = { top = 12, right = 10, bottom = 10, left = 10 },

		border_size = 0,

		col = {
			active_border = colors.background,
			inactive_border = colors.background,
		},

		resize_on_border = false,
		allow_tearing = false,
		layout = "lua:orbit",
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},

	debug = {
		damage_tracking = 0,
	},
})

hl.config({
	input = {
		repeat_rate = 50,
		repeat_delay = 300,

		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,
		mouse_refocus = true,
		sensitivity = 0,

		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.device({
	name = "default",
	sensitivity = -0.5,
})

-- screen_shader = /home/yujon/.config/hypr/Shaders/liquidglass.frag

--------------------------------
---- HYPRGLASS PLUGIN --------
--------------------------------
if hl.plugin.hyprglass then
	local hg = hl.plugin.hyprglass
	hg.config({
		blur_strength = 0,
		blur_iterations = 1,
		refraction_strength = 2.5,
		chromatic_aberration = 0,
		lens_distortion = 1,
		edge_thickness = 0.018,
		fresnel_strength = 1,
		specular_strength = 1,
		tint_color = 0x00000000,
		glass_opacity = 1,
		brightness = 1,
		contrast = 1.0,
		saturation = 1.0,
		vibrancy = 0.0,
		adaptive_dim = 0.0,
		adaptive_boost = 0.0,
		layers = { enabled = true },
	})
	hg.layer("moon.powerscreen", { mask_threshold = 0.5 })
	hg.layer("moon.sidepanel", { mask_threshold = 0.05 })
	hg.layer("moon.phasebar", { mask_threshold = 0.05 })
	hg.layer("moon.volumebar", { mask_threshold = 0.02 })
end
--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

---------------------
---- Imports  ----
---------------------
require("keybinds")
require("decorations")
require("animations.diablo-2")
require("overview")
dofile(os.getenv("HOME") .. "/.config/hypr/shader_override.lua")

-- =============================================================================
--  ORBIT — Custom circular layout
--  • 1 window  → centred, large
--  • N windows → evenly spaced around a circle, starting at 12 o'clock
-- =============================================================================
