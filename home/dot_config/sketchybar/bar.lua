local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
	-- topmost = "window",
	position = "bottom",
	height = 32,
	-- bar 自体は透明にして、各 bracket (spaces / cpu / memory) が独立した浮遊矩形として
	-- 中身ぴったりに見えるようにする (sketchybar には bar.width / 内容 auto-fit がないため)
	color = 0x00000000,
	margin = 0,
	-- bar 全体を 2px 上にシフト (positive = UP)
	y_offset = 2,
	padding_right = 8,
	padding_left = 8,
})
