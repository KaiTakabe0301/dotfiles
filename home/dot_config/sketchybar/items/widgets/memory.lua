local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "memory_update" for
-- the memory load data, which is fired every 1.0 second.
sbar.exec(
	"killall memory_load >/dev/null; $CONFIG_DIR/helpers/event_providers/memory_load/bin/memory_load memory_update 1.0"
)

-- visual order (center, addition 順 = 左→右): [icon][label] [graph]
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
	-- bar.height 32, bracket bg=26 で bracket 下端 (= 29) より 1px 上に graph 下端を置く
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
	-- chart_height = push × bar_height (32px)
	-- bracket bg=26 用: divisor = 100 × bar.height / bracket.bg.height = 100 × 32 / 26 ≈ 123
	memory_graph:push({ used_percentage / 123.0 })
	memory:set({ label = { string = string.format("%d", math.floor(used_percentage)) .. "%" } })
end)

memory:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'Activity Monitor'")
end)

-- widget 間 gap
sbar.add("item", { position = "center", width = settings.widget_gap, padding_left = 0, padding_right = 0 })
