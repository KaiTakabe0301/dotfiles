local colors = require("colors")
local settings = require("settings")

-- aerospace ワークスペース変更を購読するためのカスタムイベント
sbar.add("event", "aerospace_workspace_change")

-- ============================================================================
-- モニター / WS の動的検出
-- ============================================================================
-- 設計:
--   1. aerospace list-monitors で接続中モニターを取得
--   2. 各モニターの WS は aerospace list-workspaces --monitor <id> で取得
--      (force-assignment で無効モニターに割り当てられた WS は接続中モニターへ
--       aerospace 側で集約されるので、ここでは追加処理不要)
--   3. force-assignment に登録されていない WS (= dynamic WS, 例: 10) は
--      フォーカスのあるモニターに表示されるが、bar の表示上は独立した
--      "dynamic" グループにまとめる
--
-- 結果:
--   - 単一モニター時: [1..9] (= 接続モニター) + [10] (dynamic) の 2 グループ
--   - 複数モニター時: 各接続モニターの WS グループ + dynamic
--
-- リアクティブ更新:
--   非可視 watcher item を `display_change` に購読させ、モニター抜き挿し時に
--   既存の space.* / group.* / group.gap.* を `sketchybar --remove` で破棄して
--   build_layout() を再実行することで bar が自動追従する。
-- ============================================================================

local function shell(cmd)
	local f = io.popen(cmd)
	if not f then
		return ""
	end
	local out = f:read("*a") or ""
	f:close()
	return out
end

-- aerospace.toml の [workspace-to-monitor-force-assignment] から
-- force-assigned な WS 番号集合を返す。WS 番号 -> true のマップ。
local function parse_assigned_ws()
	local home = os.getenv("HOME") or ""
	local path = home .. "/.config/aerospace/aerospace.toml"
	local f = io.open(path, "r")
	if not f then
		return {}
	end
	local content = f:read("*a") or ""
	f:close()

	-- セクション本文を切り出す (次の [section] か EOF まで)
	local section = content:match("%[workspace%-to%-monitor%-force%-assignment%](.-)\n%[")
		or content:match("%[workspace%-to%-monitor%-force%-assignment%](.*)$")
	if not section then
		return {}
	end

	local assigned = {}
	-- 行例: 1 = 'Built-in Retina Display'
	for ws in section:gmatch("(%d+)%s*=%s*['\"][^'\"]+['\"]") do
		assigned[tonumber(ws)] = true
	end
	return assigned
end

-- 接続中モニター: { { id = 1, name = "Built-in Retina Display" }, ... }
local function get_monitors()
	local out = shell("aerospace list-monitors --format '%{monitor-id} %{monitor-name}'")
	local monitors = {}
	for line in out:gmatch("[^\r\n]+") do
		local id, name = line:match("^%s*(%d+)%s+(.-)%s*$")
		if id then
			table.insert(monitors, { id = tonumber(id), name = name or "" })
		end
	end
	return monitors
end

-- aerospace に存在する全 WS 番号 (sort 済み)
local function get_all_ws()
	local out = shell("aerospace list-workspaces --all")
	local list = {}
	for ws in out:gmatch("[^\r\n]+") do
		local n = tonumber(ws)
		if n then
			table.insert(list, n)
		end
	end
	table.sort(list)
	return list
end

-- 検出結果からグループ配列を組む
-- 戻り値: { { name = "monitor_1", members = {1,2,3}, kind = "monitor" }, ... ,
--          { name = "dynamic", members = {10}, kind = "dynamic" } }
local function build_groups()
	local assigned = parse_assigned_ws()
	local monitors = get_monitors()
	local all_ws = get_all_ws()

	-- dynamic = force-assignment に出てこない WS
	local dynamic_members = {}
	local dynamic_set = {}
	for _, n in ipairs(all_ws) do
		if not assigned[n] then
			table.insert(dynamic_members, n)
			dynamic_set[n] = true
		end
	end

	local groups = {}
	for _, m in ipairs(monitors) do
		local out = shell("aerospace list-workspaces --monitor " .. m.id)
		local members = {}
		for ws in out:gmatch("[^\r\n]+") do
			local n = tonumber(ws)
			-- dynamic は別グループに分ける
			if n and not dynamic_set[n] then
				table.insert(members, n)
			end
		end
		table.sort(members)
		if #members > 0 then
			table.insert(groups, {
				name = "monitor_" .. m.id,
				members = members,
				kind = "monitor",
			})
		end
	end

	if #dynamic_members > 0 then
		table.insert(groups, {
			name = "dynamic",
			members = dynamic_members,
			kind = "dynamic",
		})
	end

	-- aerospace list-monitors はモニターの物理配置順 (右→左) を返す場合があり、
	-- そのまま使うと bar のグループも逆順になる。
	-- WS 番号の昇順を保つため、各グループの最小メンバー番号で並べ替える。
	table.sort(groups, function(a, b)
		return a.members[1] < b.members[1]
	end)

	return groups
end

-- ============================================================================
-- WS チップ生成 / フォーカス更新
-- ============================================================================

-- 選択時の枠色 (全 WS で同一: cmap_1 = frost2)
local FOCUS_COLOR = colors.cmap_1

-- ws_id -> sbar item (再構築のたびに作り直し)
local spaces = {}
-- rebuild 時に削除すべきアイテム名を集める (watcher 自身は含めない)
local managed_items = {}

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
	for ws_id, space in pairs(spaces) do
		local selected = (tostring(ws_id) == focused_sid)
		space:set({
			icon = { color = selected and colors.black or colors.fg1 },
			label = { color = selected and colors.black or colors.fg1 },
			background = {
				color = selected and FOCUS_COLOR or colors.grey,
				border_color = selected and FOCUS_COLOR or colors.grey,
			},
		})
	end
end

-- ============================================================================
-- レイアウト構築
-- ============================================================================

-- グループ境界用のチップ余白 (sketchybar-bracket-padding.md 参照:
-- spaces.lua は member padding を bracket span に乗せる流儀)
local GROUP_GAP = 4
-- bracket 間に挿入する透明 spacer の幅
local BRACKET_GAP = 8

local function add_bracket_gap(name)
	sbar.add("item", name, {
		position = "center",
		width = BRACKET_GAP,
		label = { drawing = false },
		icon = { drawing = false },
		background = { drawing = false },
	})
	table.insert(managed_items, name)
end

local function build_layout()
	spaces = {}
	managed_items = {}

	local groups = build_groups()

	-- グループ単位で item を追加 (sketchybar の left サイドは追加順で並ぶ)
	for gi, g in ipairs(groups) do
		for mi, ws_id in ipairs(g.members) do
			-- グループ内の先頭 / 末尾チップだけ外側に GROUP_GAP の余白を確保
			local pad_left = (mi == 1) and GROUP_GAP or 2
			local pad_right = (mi == #g.members) and GROUP_GAP or 2

			local item_name = "space." .. ws_id
			local space = sbar.add("item", item_name, {
				position = "center",
				icon = {
					font = { family = "Hack Nerd Font", style = "Bold", size = 13.0 },
					string = tostring(ws_id),
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
					.. ws_id
					.. " && sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="
					.. ws_id,
			})
			table.insert(managed_items, item_name)

			spaces[ws_id] = space

			space:subscribe("aerospace_workspace_change", function(env)
				update_focus(env.FOCUSED_WORKSPACE)
				update_space_apps(space, ws_id)
			end)

			space:subscribe("front_app_switched", function(_)
				update_space_apps(space, ws_id)
			end)
		end

		-- グループ末尾以外には透明 spacer を挟んでグループ間 gap を作る
		if gi < #groups then
			add_bracket_gap("group.gap." .. gi)
		end
	end

	-- bracket 背景 (薄い暗背景) をグループ単位で被せる
	for _, g in ipairs(groups) do
		local member_names = {}
		for _, ws_id in ipairs(g.members) do
			table.insert(member_names, spaces[ws_id].name)
		end
		local bracket_name = "group." .. g.name
		sbar.add("bracket", bracket_name, member_names, {
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
		table.insert(managed_items, bracket_name)
	end
end

-- 初期フォーカス / アプリリストの再適用
local function refresh_state()
	sbar.exec("aerospace list-workspaces --focused", function(focused)
		local focused_sid = (focused or ""):gsub("%s+", "")
		if #focused_sid > 0 then
			update_focus(focused_sid)
		end
	end)
	for ws_id, space in pairs(spaces) do
		update_space_apps(space, ws_id)
	end
end

-- ============================================================================
-- リアクティブ rebuild (display_change)
-- ============================================================================
-- sbar.exec は async だが sketchybar に対するコマンド送信は順序が保たれる。
-- ここでは「全 remove を 1 本の shell コマンドにまとめ、その callback の中で
-- build_layout() を呼ぶ」ことで remove → add の順序を確実にする。
-- aerospace の list-monitors は OS の screen change を受けて即座に追従するが、
-- 念のため `sleep 0.3` を挟んで遅延を吸収する。
--
-- 重要: sketchybar の `display_change` は物理的なモニター抜き挿しだけでなく、
-- focused display の変化 (例: aerospace の `mouse-follows-focus` で WS 切替時に
-- マウスが別モニターへ飛ぶ) でも発火する。よって signature を比較し、本当に
-- モニター構成が変わったときだけ rebuild する。

-- "id:name|id:name|..." 形式のモニター signature
local last_monitor_signature = ""

local function compute_monitor_signature_async(callback)
	-- aerospace の追従待ちを兼ねて sleep 0.3
	sbar.exec(
		"sleep 0.3 && aerospace list-monitors --format '%{monitor-id}:%{monitor-name}' | tr '\\n' '|'",
		function(out)
			callback((out or ""):gsub("%s+$", ""))
		end
	)
end

local function rebuild_layout()
	compute_monitor_signature_async(function(sig)
		if sig == last_monitor_signature then
			-- focused display 変化のみ。レイアウト不変なので何もしない。
			return
		end
		last_monitor_signature = sig

		if #managed_items == 0 then
			build_layout()
			refresh_state()
			return
		end
		local cmd = "sketchybar"
		for _, name in ipairs(managed_items) do
			cmd = cmd .. " --remove " .. name
		end
		sbar.exec(cmd, function(_)
			build_layout()
			refresh_state()
		end)
	end)
end

-- ============================================================================
-- 初回構築 + display_change watcher
-- ============================================================================

build_layout()
refresh_state()
-- 初回 signature を保存 (これで起動直後の display_change が空打ちに)
compute_monitor_signature_async(function(sig)
	last_monitor_signature = sig
end)

-- display_change を購読するための非可視 watcher。
-- width=0 + drawing=false で bar の layout には影響しない。
-- watcher 自身は managed_items に入れず、永続させる。
local watcher = sbar.add("item", "spaces.watcher", {
	position = "center",
	width = 0,
	drawing = false,
	label = { drawing = false },
	icon = { drawing = false },
	background = { drawing = false },
})

watcher:subscribe("display_change", function(_)
	rebuild_layout()
end)
