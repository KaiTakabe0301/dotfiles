local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 1.0")

-- 左隣 (WorkSpace 10 / spaces 末尾) との gap
-- 命名済み: spaces.lua が display_change rebuild 後に space 群をこの gap の
-- 手前へ --move で戻すためのアンカー (center 追加順末尾に積まれる崩れを是正する)。
sbar.add(
	"item",
	"widgets.cpu.gap",
	{ position = "center", width = settings.widget_gap, padding_left = 0, padding_right = 0 }
)

-- visual order (center, addition 順 = 左→右): [icon][label][graph]
local cpu = sbar.add("item", "widgets.cpu", {
	position = "center",
	background = {
		height = 17,
		color = { alpha = 0 },
		border_color = { alpha = 0 },
		drawing = true,
	},
	icon = {
		string = icons.cpu,
		color = colors.frost1,
		padding_left = 5, -- 枠内左余白 (member の padding_left=0 にしたため icon 側で確保)
	},
	label = {
		string = "??%",
		color = colors.frost1,
		font = {
			family = settings.font.numbers,
		},
		align = "right",
	},
	-- bracket span に乗らないよう padding_left=0 (最左 member)
	padding_left = 0,
	padding_right = 0,
})

local cpu_graph = sbar.add("graph", "widgets.cpu.graph", 30, {
	position = "center",
	graph = {
		color = colors.frost1,
		fill_color = colors.with_alpha(colors.frost1, 0.4),
		line_width = 1.0,
	},
	background = { height = 22 },
	y_offset = 4,
	-- bracket span に乗らないよう padding_right=0 (最右 member)
	padding_right = 0,
	padding_left = -5,
})

-- Background around the cpu item
sbar.add("bracket", "widgets.cpu.bracket", { cpu.name, cpu_graph.name }, {
	background = { color = colors.tn_black3, border_color = colors.frost1 },
})

cpu_graph:subscribe("cpu_update", function(env)
	-- chart_height = push × bar.height (32px)
	-- 100% で graph 自身の background.height(=22) に収める
	-- divisor = 100 × bar.height / graph背景height = 100 × 32 / 22 ≈ 145
	cpu_graph:push({ tonumber(env.total_load) / 145. })
	cpu:set({ label = { string = env.total_load .. "%" } })
end)

cpu:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'Activity Monitor'")
end)
