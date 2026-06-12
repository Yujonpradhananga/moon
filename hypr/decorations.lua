hl.config({
	decoration = {
		screen_shader = "/home/yujon/.config/hypr/Shaders/vibrant.glsl",
		rounding = 15,
		rounding_power = 3,
		active_opacity = 1.0,
		blur = {
			enabled = false,
			size = 5,
			passes = 3,
			ignore_opacity = false,
			noise = 0.03,
			xray = false,
			new_optimizations = true,
		},
		shadow = {
			enabled = true,
			range = 10,
			render_power = 3,
			color = "rgba(0,0,0,0.2)",
		},
	},
})
