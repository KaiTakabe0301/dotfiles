local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
	-- topmost = "window",
	position = "bottom",
	height = 32,
	-- aerospace ウィンドウ風にコンパクトな矩形として浮かせる
	-- margin: 中身 (WS + CPU + memory) を覆う程度に画面の左右を大きく取る
	margin = 300,
	corner_radius = 8,
	-- NSWindow shadow を出すため bar 全体に opaque な背景色を入れる
	color = colors.black,
	y_offset = 0,
	padding_right = 8,
	padding_left = 8,
	-- macOS NSWindow のソフトシャドウ (Gaussian blur) を有効化
	shadow = true,
})
