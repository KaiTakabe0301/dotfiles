local colors = require("colors")
local settings = require("settings")

-- aerospace ワークスペース変更を購読するためのカスタムイベント
sbar.add("event", "aerospace_workspace_change")

local spaces = {}

-- 選択時の枠色 (全 WS で同一: cmap_1 = frost2)
local FOCUS_COLOR = colors.cmap_1

-- 各 WS の中身 (アプリアイコン) を aerospace + icon_map.sh 経由で更新
-- icon_map.sh の __icon_map 関数で「アプリ名 → 単一グリフ」に変換するため
-- ここでは sbar.exec で 1 つのシェルパイプラインを丸ごと実行する
local function update_space_apps(space, sid)
	local cmd = string.format(
		[[bash -c 'source "$HOME/.config/sketchybar/icon_map.sh"; apps=$(aerospace list-windows --workspace %d --format "%%{app-name}" 2>/dev/null | sort -u); line=""; while IFS= read -r a; do [ -n "$a" ] && { __icon_map "$a"; line="$line $icon_result"; }; done <<< "$apps"; printf "%%s" "$line"']],
		sid
	)
	sbar.exec(cmd, function(result)
		local label = result or ""
		space:set({
			label = { string = label, drawing = #label > 0 },
		})
	end)
end

-- フォーカス WS のハイライトを全アイテムに反映
local function update_focus(focused_sid)
	for i = 1, 10 do
		local selected = (tostring(i) == focused_sid)
		spaces[i]:set({
			icon = { color = selected and colors.black or colors.fg1 },
			label = { color = selected and colors.black or colors.fg1 },
			background = {
				color = selected and FOCUS_COLOR or colors.grey,
				border_color = selected and FOCUS_COLOR or colors.grey,
			},
		})
	end
end

-- WS チップ本体を 10 個生成
-- 数字は左右均等の padding で中央配置
-- 各モニタグループの先頭/末尾の chip 内余白を微調整できるよう関数化しておく
-- (グループ間の gap 自体は bracket 間の spacer item で作るので 0 でも問題ない)
local GROUP_GAP = 4
local function chip_pad(i)
	local left = 2
	local right = 2
	if i == 1 or i == 4 or i == 7 or i == 10 then
		left = GROUP_GAP
	end
	if i == 3 or i == 6 or i == 9 or i == 10 then
		right = GROUP_GAP
	end
	return left, right
end

-- グループ (bracket) 間に挿入する透明 spacer の幅
local BRACKET_GAP = 8

-- bracket 間に挟む透明 spacer (sketchybar の left サイドアイテムは追加順で並ぶので、
-- for ループ内で space と同時に挿入する必要がある)
local function add_bracket_gap(name)
	sbar.add("item", name, {
		position = "left",
		width = BRACKET_GAP,
		label = { drawing = false },
		icon = { drawing = false },
		background = { drawing = false },
	})
end

for i = 1, 10, 1 do
	local pad_left, pad_right = chip_pad(i)
	local space = sbar.add("item", "space." .. i, {
		position = "left",
		icon = {
			font = { family = "Hack Nerd Font", style = "Bold", size = 13.0 },
			string = tostring(i),
			color = colors.fg1,
			padding_left = 10,
			padding_right = 10,
		},
		label = {
			drawing = false,
			font = "sketchybar-app-font:Regular:16.0",
			color = colors.fg1,
			padding_left = 0,
			padding_right = 8,
			y_offset = -1,
		},
		padding_left = pad_left,
		padding_right = pad_right,
		background = {
			color = colors.grey,
			border_color = colors.grey,
			border_width = 0,
			corner_radius = 6,
			height = 22,
		},
		click_script = "aerospace workspace "
			.. i
			.. " && sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="
			.. i,
	})

	spaces[i] = space

	space:subscribe("aerospace_workspace_change", function(env)
		update_focus(env.FOCUSED_WORKSPACE)
		update_space_apps(space, i)
	end)

	space:subscribe("front_app_switched", function(_)
		update_space_apps(space, i)
	end)

	-- モニタ境界 (1-3 / 4-6 / 7-9 / 10) の直後に gap を挟む
	if i == 3 or i == 6 or i == 9 then
		add_bracket_gap("group.gap." .. (i // 3))
	end
end

-- モニター別グルーピング (内蔵 1-3 / ULTRAGEAR 4-6 / DELL 7-9 / 動的 10)
-- 各グループに薄い暗背景の bracket を被せ、bracket 間にスペーサーを挟む
local function add_monitor_bracket(name, members)
	sbar.add("bracket", name, members, {
		background = {
			color = colors.bg1,
			border_color = colors.bg1,
			border_width = 0,
			corner_radius = 8,
			height = 28,
			-- default から継承される padding を 0 にしないと bg が member 外側へ拡張され、
			-- 隣接 bracket と接触する
			padding_left = 0,
			padding_right = 0,
		},
	})
end

-- bracket は item 配置とは独立 (member 名だけで bg を被せる)
add_monitor_bracket("group.builtin", { spaces[1].name, spaces[2].name, spaces[3].name })
add_monitor_bracket("group.ultragear", { spaces[4].name, spaces[5].name, spaces[6].name })
add_monitor_bracket("group.dell", { spaces[7].name, spaces[8].name, spaces[9].name })
add_monitor_bracket("group.dynamic", { spaces[10].name })

-- 起動時にフォーカスとアプリリストを初期化
sbar.exec("aerospace list-workspaces --focused", function(focused)
	local focused_sid = (focused or ""):gsub("%s+", "")
	if #focused_sid > 0 then
		update_focus(focused_sid)
	end
end)
for i = 1, 10 do
	update_space_apps(spaces[i], i)
end
