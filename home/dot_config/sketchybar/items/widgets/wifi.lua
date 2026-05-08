local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

sbar.exec(
	"killall network_load >/dev/null; $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load en0 network_update 1.0"
)

local popup_width = 250

-- ============================================================================
-- wifi widget 設計 (公式仕様に従った clean 実装)
--
-- sketchybar 公式仕様 (https://felixkratz.github.io/SketchyBar/config/items):
--   - item は icon + label を 1 セットで持つ
--   - bg.padding_left/right = bg と隣接 item の間の余白 (inter-item gap)
--   - icon.padding_left/right = bg 内側、icon glyph と隣接 (label / bg edge) の間
--   - label.padding_left/right = bg 内側、label glyph と隣接 (icon / bg edge) の間
--   - item.align プロパティは存在しない (Geometry Properties に列挙されていない)
--   - inter-item gap = prev_item.bg.padding_right + next_item.bg.padding_left (線形)
--
-- レイアウト (visual 左→右):
--   ┌──────────────────────────────────────────┐
--   │ [wifi]  [↑ NNN Bps]   [赤 graph 線 ──]   │  上 row
--   │  icon   [↓ NNN Bps]   [青 graph 線 ──]   │  下 row
--   └──────────────────────────────────────────┘
--
-- bracket member 構成 (addition 順 = visual 右→左、reference Yamane 氏方式):
--   1. graph_up   (graph、最右)
--   2. graph_down (graph_up と x overlay)
--   3. text_up    (icon "↑" + label "NNN Bps", width=0 で bar slot 0 = 上 row overlay)
--   4. text_down  (icon "↓" + label "NNN Bps", auto-width = bar slot 消費)
--   5. wifi       (wifi connection icon、最左)
--
-- 各要素間 gap は line形に制御:
--   - wifi ↔ text:   wifi.bg.padding_right で線形 (1px = 1px gap)
--   - text ↔ graph: graph_down.bg.padding_left で線形
--   - icon "↑/↓" ↔ label "NNN Bps" (text item 内): icon.padding_right + label.padding_left で線形
--
-- 上下 row 重ね合わせ:
--   text_up.width=0 (bar slot 0)、text_up.padding_left=-8 (reference の値、x 位置調整)
--   text_down.padding_left=-5 (reference の値) で auto-width item を左にシフト
-- ============================================================================

local W_GRAPH = 42
local W_GRAPH_PHYSICAL = W_GRAPH + 12

-- 要素間 gap (線形・独立制御)
local GAP_ICON_TEXT = 4 -- wifi icon ↔ text の gap
local GAP_TEXT_GRAPH = -4 -- text ↔ graph の gap (bg.padding 負値で graph 側に寄せる)
local GAP_ARROW_LABEL = 2 -- text item 内、"↑/↓" と "NNN Bps" の間 (label.padding_left)

-- 縦位置 (positive=UP)
local Y_TEXT_UP = 5
local Y_TEXT_DOWN = -5
local Y_GRAPH_UP = 21
local Y_GRAPH_DOWN = 11

-- ----------------------------------------------------------------------------
-- graph 上下 (addition 順最初 = visual 最右)
-- ----------------------------------------------------------------------------

-- graph 上下の overlay は graph_up.width=0 で実現 (sketchybar 公式の overlay 手法)
-- 第一 item (graph_up) に width=0 を設定 → bar slot 0 消費、cursor 進まず
-- 次 item (graph_down) が同じ x 位置から描画される = 完全 overlay
local graph_up = sbar.add("graph", "widgets.wifi1_graph", W_GRAPH, {
	position = "right",
	width = 0, -- bar slot 0、graph_down と x 同位置で overlay
	align = "right",
	graph = { color = colors.frost2, fill_color = colors.frost2, fill = true, line_width = 1 },
	background = {
		height = 10,
		padding_left = 0,
		padding_right = 0,
	},
	y_offset = Y_GRAPH_UP,
})

local graph_down = sbar.add("graph", "widgets.wifi2_graph", W_GRAPH, {
	position = "right",
	align = "right",
	graph = { color = colors.frost2, fill_color = colors.frost2, fill = true, line_width = 1 },
	background = {
		height = 10,
		padding_left = 0,
		padding_right = 0,
	},
	y_offset = Y_GRAPH_DOWN,
})

-- ----------------------------------------------------------------------------
-- text 上 (icon "↑" + label "NNN Bps"、width=0 で bar slot 0 = 上 row overlay)
-- ----------------------------------------------------------------------------

local text_up = sbar.add("item", "widgets.wifi1", {
	position = "right",
	width = 0, -- bar slot 0、text_down と x overlay (sketchybar overlay 手法)
	padding_left = 0,
	background = { padding_right = GAP_TEXT_GRAPH }, -- graph 側との bg 間 gap (線形制御)
	icon = {
		padding_left = 0,
		padding_right = 0,
		font = { style = settings.font.style_map["Bold"], size = 8.0 },
		string = icons.wifi.upload,
	},
	label = {
		padding_left = GAP_ARROW_LABEL, -- "↑" と "NNN Bps" の間 (線形制御)
		padding_right = 0,
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 8.0,
		},
		color = colors.frost2,
		string = "??? Bps",
	},
	y_offset = Y_TEXT_UP,
})

-- ----------------------------------------------------------------------------
-- text 下 (icon "↓" + label "NNN Bps"、auto-width = bar slot 消費)
-- ----------------------------------------------------------------------------

local text_down = sbar.add("item", "widgets.wifi2", {
	position = "right",
	padding_left = 0, -- text_up.width=0 で overlay 済み、追加調整不要
	background = { padding_left = 0, padding_right = GAP_TEXT_GRAPH }, -- text_up と同じ値で完全 overlay
	icon = {
		padding_left = 0,
		padding_right = 0,
		font = { style = settings.font.style_map["Bold"], size = 8.0 },
		string = icons.wifi.download,
	},
	label = {
		padding_left = GAP_ARROW_LABEL,
		padding_right = 0,
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 8.0,
		},
		color = colors.frost2,
		string = "??? Bps",
	},
	y_offset = Y_TEXT_DOWN,
})

-- ----------------------------------------------------------------------------
-- wifi 接続 icon (左端)
-- ----------------------------------------------------------------------------

local wifi = sbar.add("item", "widgets.wifi.padding", {
	position = "right",
	icon = {
		padding_left = 5, -- 枠内左余白 (cpu/memory と同値で統一)
		padding_right = 0,
	},
	label = { drawing = false, padding_left = 0, padding_right = 0 },
	padding_left = 0, -- default 6 の継承を切って bracket 左端と icon の距離を cpu/memory に揃える
	background = {
		padding_right = GAP_ICON_TEXT, -- text 側との bg 間 gap (線形制御)
	},
})

-- ----------------------------------------------------------------------------
-- bracket
-- ----------------------------------------------------------------------------

local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", {
	wifi.name,
	text_down.name,
	text_up.name,
	graph_down.name,
	graph_up.name,
}, {
	background = {
		color = colors.tn_black3,
		border_color = colors.frost2,
		border_width = 2,
		height = 26,
	},
	popup = {
		align = "center",
		height = 30,
		background = { color = colors.tn_black3, border_color = colors.frost2, border_width = 2 },
	},
})

-- ============================================================================
-- popup items (省略なし、reference のまま)
-- ============================================================================

local ssid = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = { font = { size = 13.0, style = settings.font.style_map["Bold"] }, string = icons.wifi.router, color = colors.frost2 },
	width = popup_width,
	align = "center",
	label = { font = { style = settings.font.style_map["Bold"] }, max_chars = 18, string = "????????????", color = colors.frost2 },
	background = { height = 2, color = colors.grey, y_offset = -15, border_color = colors.frost2 },
})

local hostname = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = { font = { size = 13.0 }, align = "left", string = "Hostname:", width = popup_width / 2, color = colors.frost2 },
	label = { max_chars = 20, string = "????????????", width = popup_width / 2, align = "right", color = colors.frost2 },
})

local ip = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = { font = { size = 13.0 }, align = "left", string = "IP:", width = popup_width / 2, color = colors.frost2 },
	label = { string = "???.???.???.???", width = popup_width / 2, align = "right", color = colors.frost2 },
})

local mask = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = { font = { size = 13.0 }, align = "left", string = "Subnet mask:", width = popup_width / 2, color = colors.frost2 },
	label = { string = "???.???.???.???", width = popup_width / 2, align = "right", color = colors.frost2 },
})

local router = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = { font = { size = 13.0 }, align = "left", string = "Router:", width = popup_width / 2, color = colors.frost2 },
	label = { string = "???.???.???.???", width = popup_width / 2, align = "right", color = colors.frost2 },
})

-- ============================================================================
-- subscriptions
-- ============================================================================

text_up:subscribe("network_update", function(env)
	local upload_value, upload_unit = env.upload:match("^(%d+)%s*([KMG]?)")
	local download_value, download_unit = env.download:match("^(%d+)%s*([KMG]?)")

	upload_value = tonumber(upload_value)
	download_value = tonumber(download_value)

	local unit_multiplier = { K = 1024, M = 1024 ^ 2, G = 1024 ^ 3 }
	if upload_unit and unit_multiplier[upload_unit] then
		upload_value = upload_value * unit_multiplier[upload_unit]
	end
	if download_unit and unit_multiplier[download_unit] then
		download_value = download_value * unit_multiplier[download_unit]
	end

	local up_color = (upload_value == 0) and colors.tn_black1 or colors.frost2
	local down_color = (download_value == 0) and colors.tn_black1 or colors.frost2

	graph_up:push({ upload_value / (2 * 100 * 1024 ^ 2) })
	graph_down:push({ download_value / (2 * 100 * 1024 ^ 2) })

	text_up:set({
		icon = { color = up_color },
		label = { string = env.upload, color = up_color },
	})
	text_down:set({
		icon = { color = down_color },
		label = { string = env.download, color = down_color },
	})
end)

wifi:subscribe({ "wifi_change", "system_woke" }, function(env)
	sbar.exec("ipconfig getifaddr en0", function(ip_result)
		local connected = not (ip_result == "")
		wifi:set({
			icon = {
				string = connected and icons.wifi.connected or icons.wifi.disconnected,
				color = connected and colors.frost2 or colors.tn_black1,
			},
		})
	end)
end)

local function hide_details()
	wifi_bracket:set({ popup = { drawing = false } })
end

local function toggle_details()
	local should_draw = wifi_bracket:query().popup.drawing == "off"
	if should_draw then
		wifi_bracket:set({ popup = { drawing = true } })
		sbar.exec("networksetup -getcomputername", function(result)
			hostname:set({ label = result })
		end)
		sbar.exec("ipconfig getifaddr en0", function(result)
			ip:set({ label = result })
		end)
		sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
			ssid:set({ label = result })
		end)
		sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(result)
			mask:set({ label = result })
		end)
		sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(result)
			router:set({ label = result })
		end)
	else
		hide_details()
	end
end

text_up:subscribe("mouse.clicked", toggle_details)
text_down:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.exited.global", hide_details)

local function copy_label_to_clipboard(env)
	local label = sbar.query(env.NAME).label.value
	sbar.exec('echo "' .. label .. '" | pbcopy')
	sbar.set(env.NAME, { label = { string = icons.clipboard, align = "center" } })
	sbar.delay(1, function()
		sbar.set(env.NAME, { label = { string = label, align = "right" } })
	end)
end

ssid:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)

-- 左隣 widget (memory) との gap
sbar.add("item", { position = "right", width = settings.widget_gap, padding_left = 0, padding_right = 0 })
