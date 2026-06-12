local colors = require("colors")
local settings = require("settings")

-- Claude Code Max のレート制限 (5h 枠 / 7d 枠) を 2 つの独立した box として表示する。
-- データは ~/.claude/statusline.sh が statusLine の stdin から rate_limits を抽出して
-- ~/.cache/claude-code-usage.json に書き出し、`claude_usage_update` イベントで push する。
-- フォールバックとして update_freq 経由の routine poll でも再読込する。
sbar.add("event", "claude_usage_update")

-- Simple Icons webfont (Brewfile: cask "font-simple-icons", v16.23.0)。
-- private-use codepoint はフォント版に依存するため、cask を上げたら再確認すること。
-- 5h=Claude ロゴ / 7d=Claude Code ロゴ。
-- glyph の見た目サイズを揃えるため metric ごとに font size を持つ
local SI_FONT_5H = "Simple Icons:Regular:13.0" -- si-claude
local SI_FONT_7D = "Simple Icons:Regular:14.0" -- si-claudecode (1px 大きめ)
local GLYPH_5H = utf8.char(0xec10) -- si-claude
local GLYPH_7D = utf8.char(0xec11) -- si-claudecode

-- 識別色 (Nord)。cpu→memory→5h→7d を frost1→frost4 のグラデーションにする (ユーザ指定)。
local COLOR_5H = colors.frost3 -- nord9
local COLOR_7D = colors.frost4 -- nord10

-- cache から 5h/7d の used_percentage と resets_at を tab 区切りで取り出す。
-- // "" でフィールド欠落時もポジションを維持する (cache 未生成時は全て空)。
local CMD = [[cat "$HOME/.cache/claude-code-usage.json" 2>/dev/null | jq -r ']]
	.. [[[ (.five_hour.used_percentage // ""), (.five_hour.resets_at // ""), ]]
	.. [[(.seven_day.used_percentage // ""), (.seven_day.resets_at // "") ] | @tsv' 2>/dev/null]]

-- resets_at が epoch 秒なら localtime に整形、ISO 文字列等ならそのまま返す。
local function fmt_reset(raw)
	if raw == nil or raw == "" then
		return "?"
	end
	local n = tonumber(raw)
	if n and n > 1000000000 then
		return os.date("%m/%d %H:%M", math.floor(n))
	end
	return raw
end

-- 共通の item 定義 (Simple Icons glyph + label、bracket span に乗らないよう member padding=0)
local function add_metric(name, color, glyph, font)
	return sbar.add("item", name, {
		position = "center",
		icon = {
			string = glyph,
			font = font,
			color = color,
			padding_left = 5, -- 枠内左余白
		},
		label = {
			string = "–",
			color = color,
			font = { family = settings.font.numbers },
			align = "right",
			padding_right = 5, -- 枠内右余白
		},
		padding_left = 0,
		padding_right = 0,
	})
end

-- gap to memory widget on the left
sbar.add("item", { position = "center", width = settings.widget_gap, padding_left = 0, padding_right = 0 })

local five_hour = add_metric("widgets.claude.five_hour", COLOR_5H, GLYPH_5H, SI_FONT_5H)
five_hour:set({ update_freq = 30 }) -- fallback poll 間隔 (routine event)
sbar.add("bracket", "widgets.claude.five_hour.bracket", { five_hour.name }, {
	background = { color = colors.tn_black3, border_color = COLOR_5H },
})

-- gap between 5h and 7d box
sbar.add("item", { position = "center", width = settings.widget_gap, padding_left = 0, padding_right = 0 })

local seven_day = add_metric("widgets.claude.seven_day", COLOR_7D, GLYPH_7D, SI_FONT_7D)
seven_day:set({
	popup = {
		align = "center",
		height = 22,
		background = { color = colors.tn_black3, border_color = COLOR_7D, border_width = 2 },
	},
})
sbar.add("bracket", "widgets.claude.seven_day.bracket", { seven_day.name }, {
	background = { color = colors.tn_black3, border_color = COLOR_7D },
})

-- popup rows (7d 側に集約)
local function add_popup_row(name, tag, color)
	return sbar.add("item", name, {
		position = "popup." .. seven_day.name,
		icon = { string = tag, color = color, width = 40, align = "left" },
		label = { string = "–", color = color, width = 170, align = "right" },
	})
end
local popup_5h = add_popup_row("widgets.claude.popup.5h", "5h", COLOR_5H)
local popup_7d = add_popup_row("widgets.claude.popup.7d", "7d", COLOR_7D)

-- 1 metric ぶんの bar item / popup row のラベルを更新する (色は固定なので触らない)
local function apply(item, popup_row, pct_str, reset_str)
	local pct = tonumber(pct_str)
	local label, poplabel
	if pct == nil then
		label, poplabel = "–", "no data"
	else
		pct = math.floor(pct + 0.5)
		label = pct .. "%"
		poplabel = pct .. "%  ·  resets " .. fmt_reset(reset_str)
	end
	item:set({ label = { string = label } })
	popup_row:set({ label = { string = poplabel } })
end

local function refresh()
	sbar.exec(CMD, function(result)
		result = (result or ""):gsub("[\r\n]+$", "")
		local f = {}
		local i = 1
		for field in (result .. "\t"):gmatch("(.-)\t") do
			f[i] = field
			i = i + 1
		end
		apply(five_hour, popup_5h, f[1], f[2])
		apply(seven_day, popup_7d, f[3], f[4])
	end)
end

-- 即時 push (statusline.sh) + フォールバック poll / 復帰時
five_hour:subscribe({ "claude_usage_update", "routine", "forced", "system_woke" }, function()
	refresh()
end)

-- どちらの box をクリックしても 7d の popup をトグル
local function toggle_popup()
	seven_day:set({ popup = { drawing = "toggle" } })
end
five_hour:subscribe("mouse.clicked", toggle_popup)
seven_day:subscribe("mouse.clicked", toggle_popup)
seven_day:subscribe("mouse.exited.global", function()
	seven_day:set({ popup = { drawing = false } })
end)

-- 初期描画
refresh()
