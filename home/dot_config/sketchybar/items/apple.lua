local colors = require("colors")
local settings = require("settings")

-- Apple ロゴ (左端、クリックで System Settings 起動)
sbar.add("item", "apple", {
	position = "left",
	icon = {
		string = utf8.char(0xf179),
		font = {
			family = "Hack Nerd Font",
			style = settings.font.style_map["Bold"],
			size = 16.0,
		},
		color = colors.frost2,
		padding_left = 8,
		padding_right = 8,
	},
	label = { drawing = false },
	background = { drawing = false },
	click_script = "open -a 'System Settings'",
})
