local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "memory_update" for
-- the memory load data, which is fired every 1.0 second.
sbar.exec(
	"killall memory_load >/dev/null; $CONFIG_DIR/helpers/event_providers/memory_load/bin/memory_load memory_update 1.0"
)

-- 左隣 (cpu widget) との gap
sbar.add("item", { position = "center", width = settings.widget_gap, padding_left = 0, padding_right = 0 })

-- visual order (center, addition 順 = 左→右): [icon][label][graph]
local memory = sbar.add("item", "widgets.memory", {
	position = "center",
	background = {
		height = 17,
		color = { alpha = 0 },
		border_color = { alpha = 0 },
		drawing = true,
	},
	icon = {
		string = icons.memory,
		font = { size = 17 },
		color = colors.frost2,
		padding_left = 5, -- 枠内左余白
	},
	label = {
		string = "??%",
		color = colors.frost2,
		font = {
			family = settings.font.numbers,
		},
		align = "right",
	},
	-- bracket span に乗らないよう padding_left=0 (最左 member)
	padding_left = 0,
	padding_right = 0,
})

local memory_graph = sbar.add("graph", "widgets.memory.graph", 30, {
	position = "center",
	graph = {
		color = colors.frost2,
		fill_color = colors.with_alpha(colors.frost2, 0.4),
		line_width = 1.0,
	},
	background = { height = 22 },
	y_offset = 4,
	-- bracket span に乗らないよう padding_right=0 (最右 member)
	padding_right = 0,
	padding_left = -5,
})

-- Background around the memory item
sbar.add("bracket", "widgets.memory.bracket", { memory.name, memory_graph.name }, {
	background = { color = colors.tn_black3, border_color = colors.frost2 },
})

memory_graph:subscribe("memory_update", function(env)
	local used_percentage = tonumber(env.used_percentage)
	-- chart_height = push × bar.height (32px)
	-- 100% で graph 自身の background.height(=22) に収める
	-- divisor = 100 × bar.height / graph背景height = 100 × 32 / 22 ≈ 145
	memory_graph:push({ used_percentage / 145.0 })
	memory:set({ label = { string = string.format("%d", math.floor(used_percentage)) .. "%" } })
end)

memory:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'Activity Monitor'")
end)
