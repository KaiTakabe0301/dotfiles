local settings = require("settings")
local colors = require("colors")

-- ============================================================================
-- calendar widget (2x2 grid)
--
-- レイアウト (visual 左→右、上→下):
--   ┌────────────────────────────────────┐
--   │ [month "Oct."] [clock "01:46"]    │  上 row
--   │ [day   "28"  ] [dow   "Mon."]     │  下 row
--   └────────────────────────────────────┘
--
-- 各 cell は同じ column 幅で label.align=center → 自動的に center 揃い。
-- 上下 row の overlay は wifi 流 (上 row item に width=0 で bar slot 0、下 row item が
-- 同 x で auto-width = bar slot 消費)。
--
-- bracket member 構成 (addition 順 = visual 右→左):
--   1. cal_clock (top-right, width=0)    ← 最右
--   2. cal_dow   (bottom-right, width=W_RIGHT)
--   3. cal_month (top-left, width=0)
--   4. cal_day   (bottom-left, width=W_LEFT)  ← 最左
-- ============================================================================

local W_LEFT = 26 -- 左 column 幅 (month / day)。"Oct." / "28" を center 配置する
local W_RIGHT = 30 -- 右 column 幅 (clock / dow)。"01:46" / "Mon." を center 配置する
local PAD_LEFT = 5 -- bracket 枠内左余白 (cap_left.width)。font 差による視覚補正で右より 1px 広め
local PAD_RIGHT = 4 -- bracket 枠内右余白 (cap_right.width)
local Y_TOP = 5 -- 上 row の y_offset (positive = UP)
local Y_BOTTOM = -5 -- 下 row の y_offset

local function cell_label(width)
	return {
		color = colors.ice_blue,
		width = width,
		align = "center",
		font = { family = settings.font.numbers, size = 8.0 },
		padding_left = 0,
		padding_right = 0,
	}
end

-- ----------------------------------------------------------------------------
-- 右 column (top: clock, bottom: dow)
-- ----------------------------------------------------------------------------

-- bracket 枠内右余白 (不可視固定幅 spacer、最右 member で bracket span を拡張)
local cap_right = sbar.add("item", "widgets.cal.cap_right", {
	position = "right",
	width = PAD_RIGHT,
	icon = { drawing = false },
	label = { drawing = false, padding_left = 0, padding_right = 0 },
	background = { drawing = false, padding_left = 0, padding_right = 0 },
	padding_left = 0,
	padding_right = 0,
})

local cal_clock = sbar.add("item", "widgets.cal.clock", {
	position = "right",
	width = 0, -- bar slot 0、cal_dow と x overlay
	icon = { drawing = false },
	label = cell_label(W_RIGHT),
	background = { padding_left = 0, padding_right = 0 },
	update_freq = 1,
	y_offset = Y_TOP,
})

local cal_dow = sbar.add("item", "widgets.cal.dow", {
	position = "right",
	width = W_RIGHT, -- bar slot を W_RIGHT 消費
	icon = { drawing = false },
	label = cell_label(W_RIGHT),
	background = { padding_left = 0, padding_right = 0 },
	update_freq = 1,
	y_offset = Y_BOTTOM,
})

-- ----------------------------------------------------------------------------
-- 左 column (top: month, bottom: day)
-- ----------------------------------------------------------------------------

local cal_month = sbar.add("item", "widgets.cal.month", {
	position = "right",
	width = 0,
	icon = { drawing = false },
	label = cell_label(W_LEFT),
	background = { padding_left = 0, padding_right = 0 },
	update_freq = 1,
	y_offset = Y_TOP,
})

local cal_day = sbar.add("item", "widgets.cal.day", {
	position = "right",
	width = W_LEFT,
	icon = { drawing = false },
	label = cell_label(W_LEFT),
	background = { padding_left = 0, padding_right = 0 },
	padding_left = 0,
	padding_right = 0,
	update_freq = 1,
	y_offset = Y_BOTTOM,
})

-- bracket 枠内左余白 (不可視固定幅 spacer、最左 member で bracket span を拡張)
local cap_left = sbar.add("item", "widgets.cal.cap_left", {
	position = "right",
	width = PAD_LEFT,
	icon = { drawing = false },
	label = { drawing = false, padding_left = 0, padding_right = 0 },
	background = { drawing = false, padding_left = 0, padding_right = 0 },
	padding_left = 0,
	padding_right = 0,
})

-- ----------------------------------------------------------------------------
-- bracket
-- ----------------------------------------------------------------------------

sbar.add("bracket", "widgets.cal.bracket", {
	cap_left.name,
	cal_day.name,
	cal_month.name,
	cal_dow.name,
	cal_clock.name,
	cap_right.name,
}, {
	background = {
		color = colors.tn_black3,
		height = 26,
		border_color = colors.ice_blue,
	},
})

-- ----------------------------------------------------------------------------
-- subscriptions
-- ----------------------------------------------------------------------------

cal_clock:subscribe({ "forced", "routine", "system_woke" }, function()
	cal_clock:set({ label = os.date("%H:%M") })
end)

cal_month:subscribe({ "forced", "routine", "system_woke" }, function()
	cal_month:set({ label = os.date("%b.") })
end)

cal_dow:subscribe({ "forced", "routine", "system_woke" }, function()
	cal_dow:set({ label = os.date("%a.") })
end)

cal_day:subscribe({ "forced", "routine", "system_woke" }, function()
	cal_day:set({ label = os.date("%d") })
end)

-- 左隣 widget (battery) との gap
sbar.add("item", { position = "right", width = settings.widget_gap, padding_left = 0, padding_right = 0 })
