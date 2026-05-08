local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 1.0")

local cpu_graph = sbar.add("graph", "widgets.cpu.graph", 30, {
	position = "right",
	graph = {
		color = colors.frost3,
		fill_color = colors.with_alpha(colors.frost3, 0.4),
		line_width = 1.0,
	},
	background = { height = 22 },
	y_offset = 10,
	-- bracket span に乗らないよう padding_right=0 (= bg.padding_right=0)。枠内右余白は graph 内部の見た目で許容
	padding_right = 0,
	padding_left = -5,
})

local cpu = sbar.add("item", "widgets.cpu", {
	position = "right",
	background = {
		height = 17,
		color = { alpha = 0 },
		border_color = { alpha = 0 },
		drawing = true,
	},
	icon = {
		string = icons.cpu,
		color = colors.frost3,
		padding_left = 5,  -- 枠内左余白 (member の padding_left=0 にしたため icon 側で確保)
	},
	label = {
		string = "??%",
		color = colors.frost3,
		font = {
			family = settings.font.numbers,
		},
		align = "right",
	},
	padding_right = 0,
	-- bracket span に乗らないよう padding_left=0
	padding_left = 0,
})

-- Background around the cpu item
sbar.add("bracket", "widgets.cpu.bracket", { cpu_graph.name, cpu.name }, {
	background = { color = colors.tn_black3, border_color = colors.frost3 },
})

cpu_graph:subscribe("cpu_update", function(env)
	-- chart_height = push × bar_height (44px)
	-- bracket bg=26 用に divisor を比例拡大
	-- divisor = 150 × (34 / 26) = 196
	cpu_graph:push({ tonumber(env.total_load) / 196. })
	cpu:set({ label = { string = env.total_load .. "%" } })
end)

cpu:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'Activity Monitor'")
end)

-- 左隣 widget (memory) との gap
sbar.add("item", { position = "right", width = settings.widget_gap, padding_left = 0, padding_right = 0 })
