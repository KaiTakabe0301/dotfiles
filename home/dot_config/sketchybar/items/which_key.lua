local colors = require("colors")
local settings = require("settings")

sbar.add("event", "aerospace_mode_change")

-- 各 row に mode タグを付与。MODE 変化時に該当 mode の row だけを drawing on にする。
local rows = {
	-- ops mode
	{ mode = "ops", key = "h j k l",      desc = "focus left / down / up / right" },
	{ mode = "ops", key = "⇧h ⇧j ⇧k ⇧l", desc = "move window" },
	{ mode = "ops", key = "\\  −",        desc = "split vertical / horizontal" },
	{ mode = "ops", key = "f",            desc = "toggle fullscreen" },
	{ mode = "ops", key = "⇧f",           desc = "toggle floating ⇄ tiling" },
	{ mode = "ops", key = "/  ,",         desc = "layout tiles / accordion" },
	{ mode = "ops", key = "s  w",         desc = "v_accordion / h_accordion" },
	{ mode = "ops", key = "1 ‥ 0",        desc = "switch to workspace 1-10" },
	{ mode = "ops", key = "⇧1 ‥ ⇧0",     desc = "move window to workspace 1-10" },
	{ mode = "ops", key = "tab",          desc = "next workspace" },
	{ mode = "ops", key = "r",            desc = "enter resize mode" },
	{ mode = "ops", key = "⇧c",           desc = "reload aerospace config" },
	{ mode = "ops", key = "enter / esc",  desc = "exit ops mode" },

	-- resize mode
	{ mode = "resize", key = "h  l",         desc = "width  −50 / +50" },
	{ mode = "resize", key = "j  k",         desc = "height +50 / −50" },
	{ mode = "resize", key = "enter / esc",  desc = "exit resize mode (back to main)" },
}

local anchor = sbar.add("item", "which_key.anchor", {
	position = "center",
	width = 0,
	icon = { drawing = false },
	label = { drawing = false },
	background = { drawing = false },
	padding_left = 0,
	padding_right = 0,
	popup = {
		align = "center",
		horizontal = false,
		y_offset = 4,
	},
})

local row_items = {}

for i, row in ipairs(rows) do
	local item = sbar.add("item", "which_key.row." .. i, {
		position = "popup." .. anchor.name,
		icon = {
			string = row.key,
			width = 130,
			align = "left",
			color = colors.yellow,
			padding_left = 14,
			padding_right = 0,
			font = {
				family = settings.font.text,
				style = settings.font.style_map["Bold"],
				size = 12.0,
			},
		},
		label = {
			string = row.desc,
			align = "left",
			color = colors.white,
			padding_left = 0,
			padding_right = 14,
			font = {
				family = settings.font.text,
				style = settings.font.style_map["Regular"],
				size = 12.0,
			},
		},
		background = { drawing = false },
	})
	table.insert(row_items, { item = item, mode = row.mode })
end

-- 現在 mode を lua 側に保持。aerospace_workspace_change 時に popup を
-- 出し直すために必要 (sketchybar の popup は focused display が変わると
-- content が空のまま表示されるため、drawing を off→on で強制再描画する)。
local current_mode = "main"

local function show_popup_for(mode)
	for _, r in ipairs(row_items) do
		r.item:set({ drawing = r.mode == mode })
	end
	local show = mode == "ops" or mode == "resize"
	anchor:set({ popup = { drawing = show } })
end

anchor:subscribe("aerospace_mode_change", function(env)
	current_mode = env.MODE
	show_popup_for(current_mode)
end)

-- workspace 切替で focused display が変わると popup 中身が消えるので、
-- popup 表示中なら off → on で再描画する。
anchor:subscribe("aerospace_workspace_change", function(_)
	if current_mode ~= "ops" and current_mode ~= "resize" then
		return
	end
	anchor:set({ popup = { drawing = false } })
	show_popup_for(current_mode)
end)
