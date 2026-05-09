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
	table.insert(row_items, { item = item, mode = row.mode, key = row.key, desc = row.desc })
end

-- 現在 mode を lua 側に保持。workspace 切替時に popup を出し直すために必要
-- (sketchybar の popup は focused display が変わると content が空のまま
-- 表示されるため、drawing を off→on で強制再描画する)。
local current_mode = "main"

-- show_popup_for は drawing だけでなく icon/label の string も毎回 re-set する。
-- focused display 移動後の popup window では drawing 値が同じだと content が
-- 再描画されないことがあるため、string まで含めて明示的に設定し直す。
local function show_popup_for(mode)
	for _, r in ipairs(row_items) do
		r.item:set({
			drawing = r.mode == mode,
			icon = { string = r.key },
			label = { string = r.desc },
		})
	end
	local show = mode == "ops" or mode == "resize"
	anchor:set({ popup = { drawing = show } })
end

anchor:subscribe("aerospace_mode_change", function(env)
	current_mode = env.MODE
	show_popup_for(current_mode)
end)

-- workspace 切替で focused display が変わると popup 中身が消えるので、
-- popup 表示中なら off → on で再描画する。連続 set は sketchybar 側で
-- バッチング合体されることがあるため、shell の sleep を挟んで確実に
-- off → on の 2 段階で発行する。
local function refresh_popup(source)
	-- どの event 経由で refresh が走ったかを Console.app / `log show` で
	-- 追えるようにロガー出力。再現できなくなったら削除可。
	sbar.exec("logger -t which_key 'refresh source=" .. source .. " mode=" .. current_mode .. "'")
	if current_mode ~= "ops" and current_mode ~= "resize" then
		return
	end
	anchor:set({ popup = { drawing = false } })
	sbar.exec("sleep 0.1", function(_)
		show_popup_for(current_mode)
	end)
end

-- aerospace の `exec-on-workspace-change` 経由で発火するカスタムイベント
anchor:subscribe("aerospace_workspace_change", function(_)
	refresh_popup("aerospace_workspace_change")
end)

-- focused display が変わったとき (sketchybar 組み込み)。aerospace で別ディスプレイの
-- WS に切り替わるケースを確実に拾う。
anchor:subscribe("display_change", function(_)
	refresh_popup("display_change")
end)

-- focused アプリが切り替わったとき (sketchybar 組み込み)。shift-N で空 WS から
-- 自動退避し WS が切り替わったケースで focused window が変わるため、これも拾う。
anchor:subscribe("front_app_switched", function(_)
	refresh_popup("front_app_switched")
end)
