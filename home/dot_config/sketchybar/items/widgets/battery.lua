local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local battery = sbar.add("item", "widgets.battery", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Regular"],
			size = 14.0,
		},
		color = colors.frost1,
		padding_left = 5, -- 枠内左余白 (cpu/memory と同値で統一)
		padding_right = 0,
	},
	label = {
		font = { family = settings.font.numbers },
		color = colors.frost1,
		padding_right = 5,  -- 枠内右余白 (member の padding_right=0 にしたため label 側で確保)
	},
	-- bracket span に乗らないよう padding_left=0, padding_right=0
	padding_left = 0,
	padding_right = 0,
	update_freq = 1,
	popup = {
		align = "center",
		background = { color = colors.tn_black3, border_color = colors.frost1, border_width = 2 },
	},
})

local remaining_time = sbar.add("item", {
	position = "popup." .. battery.name,
	icon = {
		padding_left = 0,
		padding_right = 0,
		string = "Charging:",
		color = colors.frost1,
		width = 55,
		align = "left",
		font = {
			size = 13.0,
		},
	},
	label = {
		string = "??:??h",
		width = 90,
		align = "right",
	},
})

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local label = "?"

		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			charge = tonumber(charge)
			label = charge .. "%"
		end

		local charging, _, _ = batt_info:find("AC Power")

		if charging then
			icon = icons.battery.charging
		else
			if found and charge > 80 then
				icon = icons.battery._100
			elseif found and charge > 60 then
				icon = icons.battery._75
			elseif found and charge > 40 then
				icon = icons.battery._50
			elseif found and charge > 20 then
				icon = icons.battery._25
			else
				icon = icons.battery._0
			end
		end

		local lead = ""
		if found and charge < 10 then
			lead = "0"
		end

		battery:set({
			icon = { string = icon },
			label = { string = lead .. label },
		})
	end)
end)

battery:subscribe("mouse.clicked", function(env)
	local drawing = battery:query().popup.drawing
	battery:set({ popup = { drawing = "toggle" } })

	if drawing == "off" then
		sbar.exec("pmset -g batt", function(batt_info)
			local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
			local label = found and remaining .. "h" or "No estimate"
			remaining_time:set({ label = { string = label, color = colors.frost1 } })
		end)
	end
end)

battery:subscribe("mouse.entered", function(env)
	interrupt = interrupt + 1
	animate_detail(true)
end)

battery:subscribe("mouse.exited", function(env)
	animate_detail(false)
end)

battery:subscribe("mouse.exited.global", function(env)
	battery:set({ popup = { drawing = false } })
end)

sbar.add("bracket", "widgets.battery.bracket", { battery.name }, {
	background = { color = colors.tn_black3, border_color = colors.frost1 },
})

-- sbar.add("item", "widgets.battery.padding", {
-- 	position = "right",
-- 	width = settings.group_paddings,
-- })

-- gap to next widget on the left
sbar.add("item", {
	position = "right",
	width = settings.widget_gap,
	padding_left = 0,
	padding_right = 0,
})
