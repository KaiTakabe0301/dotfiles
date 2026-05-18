local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 1.0")

-- 左隣 (spaces) との gap (default.lua の padding=6 を継承して spaces.lua の add_bracket_gap と同じ visible gap を作る)
sbar.add("item", { position = "center", width = settings.widget_gap })

-- visual order (center, addition 順 = 左→右): [icon][label] [graph]
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
		color = colors.frost3,
		padding_left = 5, -- 枠内左余白 (member の padding_left=0 にしたため icon 側で確保)
	},
	label = {
		string = "??%",
		color = colors.frost3,
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
		color = colors.frost3,
		fill_color = colors.with_alpha(colors.frost3, 0.4),
		line_width = 1.0,
	},
	background = { height = 22 },
	-- bar.height 32, bracket bg=26 で bracket 下端 (= 29) より 1px 上に graph 下端を置く
	y_offset = 4,
	-- bracket span に乗らないよう padding_right=0 (最右 member)
	padding_right = 0,
	padding_left = -5,
})

-- Background around the cpu item
sbar.add("bracket", "widgets.cpu.bracket", { cpu.name, cpu_graph.name }, {
	background = { color = colors.tn_black3, border_color = colors.frost3 },
})

cpu_graph:subscribe("cpu_update", function(env)
	-- chart_height = push × bar_height (32px)
	-- bracket bg=26 用: divisor = 100 × bar.height / bracket.bg.height = 100 × 32 / 26 ≈ 123
	cpu_graph:push({ tonumber(env.total_load) / 123. })
	cpu:set({ label = { string = env.total_load .. "%" } })
end)

cpu:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'Activity Monitor'")
end)

-- widget 間 gap (default.lua の padding=6 を継承して spaces.lua の add_bracket_gap と同じ visible gap を作る)
sbar.add("item", { position = "center", width = settings.widget_gap })
