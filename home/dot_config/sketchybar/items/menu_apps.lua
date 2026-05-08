local colors = require("colors")
local settings = require("settings")

-- 駐在アプリ枠: クリックで対象アプリを起動 / 前面化
-- Nerd Font (Material Design Icons / Font Awesome) のグリフを utf8.char で指定
local menu_apps = {
	{ name = "claude", icon = utf8.char(0xf06ab), app = "Claude" }, -- mdi-robot-outline (代用)
	{ name = "onepassword", icon = utf8.char(0xf0306), app = "1Password" }, -- mdi-key-variant
	{ name = "docker", icon = utf8.char(0xf0868), app = "Docker Desktop" }, -- mdi-docker
	{ name = "ugreen", icon = utf8.char(0xf02ca), app = "UGREEN NAS" }, -- mdi-server
	{ name = "raycast", icon = utf8.char(0xf04ce), app = "Raycast" }, -- mdi-rocket-launch
	{ name = "hyperkey", icon = utf8.char(0xf030c), app = "HyperKey" }, -- mdi-keyboard-outline
}

for _, entry in ipairs(menu_apps) do
	sbar.add("item", "menu." .. entry.name, {
		position = "right",
		icon = {
			string = entry.icon,
			font = {
				family = "Hack Nerd Font",
				style = settings.font.style_map["Bold"],
				size = 16.0,
			},
			color = colors.fg1,
			padding_left = 6,
			padding_right = 6,
		},
		label = { drawing = false },
		background = { drawing = false },
		click_script = "open -a '" .. entry.app .. "'",
	})
end
