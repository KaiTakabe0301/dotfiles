return {
	-- Nord palette (https://www.nordtheme.com/)
	-- nord0  = polar night darkest
	-- nord3  = polar night brightest (comments / inactive)
	-- nord4-6 = snow storm
	-- nord7-10 = frost
	-- nord11-15 = aurora
	black = 0xff2e3440, -- nord0
	bg1 = 0xff3b4252, -- nord1
	bg2 = 0xff434c5e, -- nord2
	grey = 0xff4c566a, -- nord3
	fg1 = 0xffd8dee9, -- nord4
	fg2 = 0xffe5e9f0, -- nord5
	white = 0xffeceff4, -- nord6
	frost1 = 0xff8fbcbb, -- nord7
	frost2 = 0xff88c0d0, -- nord8 (borders と一致)
	frost3 = 0xff81a1c1, -- nord9
	frost4 = 0xff5e81ac, -- nord10
	ice_blue = 0xffa3c0d9, -- frost 系の 5 色目 (Nord にはないが、frost3 より明るい muted sky blue)
	red = 0xffbf616a, -- nord11
	orange = 0xffd08770, -- nord12
	yellow = 0xffebcb8b, -- nord13
	green = 0xffa3be8c, -- nord14
	purple = 0xffb48ead, -- nord15

	cyan = 0xff88c0d0,
	magenta = 0xffb48ead,
	blue = 0xff81a1c1,

	transparent = 0x00000000,
	background = 0xff2e3440,
	foreground = 0xffd8dee9,

	pure_green = 0xffa3be8c,
	white_bright = 0xffeceff4,
	red_bright = 0xffbf616a,
	yellow_bright = 0xffebcb8b,
	purple_bright = 0xffb48ead,

	soft_red = 0xffbf616a,
	soft_white = 0xffeceff4,

	bar = {
		bg = 0xf02e3440,
		border = 0xff2e3440,
	},
	popup = {
		bg = 0xc02e3440,
		border = 0xff4c566a,
	},

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,

	-- Tokyo Night エイリアス (リファレンスのコードが参照するため Nord 値で再マップ)
	tn_red = 0xffbf616a,
	tn_orange = 0xffd08770,
	tn_yellow = 0xffebcb8b,
	tn_green = 0xffa3be8c,
	tn_light_green = 0xff8fbcbb,
	tn_white_green = 0xffa3be8c,
	tn_cyan = 0xff88c0d0,
	tn_skyblue = 0xff8fbcbb,
	tn_blue = 0xff81a1c1,
	tn_magenta = 0xffb48ead,
	tn_white1 = 0xffeceff4,
	tn_white2 = 0xffe5e9f0,
	tn_white3 = 0xffd8dee9,
	tn_black1 = 0xff4c566a,
	tn_black2 = 0xff434c5e,
	tn_black3 = 0xff3b4252,
	tn_black4 = 0xff2e3440,

	tn_dark_red = 0xff8b3a4a,
	tn_brown = 0xff6f4f3a,
	tn_dark_yellow = 0xff8a6b3a,
	tn_olive = 0xff5a5b3a,
	tn_dark_green = 0xff4a5b3a,
	tn_teal = 0xff3b6e6c,
	tn_aqua = 0xff3b7c8a,
	tn_navy = 0xff3b5b8a,
	tn_deep_blue = 0xff5e81ac,
	tn_purple = 0xff8a5b8a,
	tn_dark_gray = 0xff434c5e,
	tn_gray = 0xff4c566a,

	-- spaces.lua の cmap_1 〜 cmap_10 (Nord aurora + frost で 10 色循環)
	cmap_1 = 0xff88c0d0, -- frost2
	cmap_2 = 0xffa3be8c, -- green
	cmap_3 = 0xffd08770, -- orange
	cmap_4 = 0xffb48ead, -- purple
	cmap_5 = 0xff81a1c1, -- frost3
	cmap_6 = 0xffebcb8b, -- yellow
	cmap_7 = 0xffbf616a, -- red
	cmap_8 = 0xff8fbcbb, -- frost1
	cmap_9 = 0xff5e81ac, -- frost4
	cmap_10 = 0xff88c0d0, -- frost2

	accent = 0xff88c0d0,
	accent_bright = 0xff88c0d0,
	accent1 = 0xff88c0d0, -- frost2 (borders と一致)
	accent2 = 0xff8fbcbb, -- frost1
	accent3 = 0xff81a1c1, -- frost3
	accent4 = 0xff5e81ac, -- frost4
}
