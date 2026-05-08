local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "memory_update" for
-- the memory load data, which is fired every 1.0 second.
sbar.exec(
	"killall memory_load >/dev/null; $CONFIG_DIR/helpers/event_providers/memory_load/bin/memory_load memory_update 1.0"
)

local memory_graph = sbar.add("graph", "widgets.memory.graph", 60, {
	position = "right",
	graph = {
		color = colors.pure_green,
		-- fill_color = colors.pure_green,
		line_width = 1.0,
	},
	background = { height = 22 },
	y_offset = 10,
	-- bracket span に乗らないよう padding_right=0
	padding_right = 0,
	padding_left = -5,
})

local memory = sbar.add("item", "widgets.memory", {
	position = "right",
	background = {
		height = 17,
		color = { alpha = 0 },
		border_color = { alpha = 0 },
		drawing = true,
	},
	icon = {
		string = icons.memory,
		font = { size = 17 },
		color = colors.pure_green,
		padding_left = 5,  -- 枠内左余白
	},
	label = {
		string = "??%",
		color = colors.pure_green,
		font = {
			family = settings.font.numbers,
		},
		align = "right",
	},
	padding_right = 0,
	-- bracket span に乗らないよう padding_left=0
	padding_left = 0,
})

-- Background around the memory item
local bracket = sbar.add("bracket", "widgets.memory.bracket", { memory_graph.name, memory.name }, {
	background = { color = colors.tn_black3, border_color = colors.pure_green },
})
memory_graph:subscribe("memory_update", function(env)
	-- Fetch the used memory percentage from the event provider
	local used_percentage = tonumber(env.used_percentage)
	-- chart_height = push × bar_height (44px)
	-- bracket bg=26 用に divisor を比例拡大
	-- divisor = 150 × (34 / 26) = 196
	memory_graph:push({ used_percentage / 196.0 })

	local alpha = 0.4
	local color = colors.pure_green
	local fill_color = colors.with_alpha(colors.pure_green, alpha)
	if used_percentage > 30 then
		if used_percentage < 60 then
			color = colors.yellow
			fill_color = colors.with_alpha(colors.yellow, alpha)
		elseif used_percentage < 80 then
			color = colors.orange
			fill_color = colors.with_alpha(colors.orange, alpha)
		else
			color = colors.red
			fill_color = colors.with_alpha(colors.red, alpha)
		end
	end

	memory_graph:set({
		graph = { color = color, fill_color = fill_color },
	})
	memory:set({
		label = {
			string = string.format("%d", math.floor(used_percentage)) .. "%",
			color = color,
		},

		icon = { color = color },
	})
	bracket:set({ background = { border_color = color } })
end)

memory:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'Activity Monitor'")
end)

-- Padding around the memory item
sbar.add("item", "widgets.memory.padding", {
	position = "right",
	width = settings.group_paddings,
})

sbar.add("item", { position = "right", width = settings.widget_gap, padding_left = 0, padding_right = 0 })
