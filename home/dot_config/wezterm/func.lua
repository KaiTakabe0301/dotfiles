local utils = require("utils")
local wezterm = require("wezterm")
local M = {}

-- weztermでは、tmuxのsessionを削除するような機能がない
-- workspaceを削除する関数
-- @See: https://github.com/wez/wezterm/issues/3658#issuecomment-2241251539
M.kill_workspace = function(workspace)
	local success, stdout =
		wezterm.run_child_process({ "/opt/homebrew/bin/wezterm", "cli", "list", "--format=json" })

	if success then
		local json = wezterm.json_parse(stdout)
		if not json then
			return
		end

		local workspace_panes = utils.filter(json, function(p)
			return p.workspace == workspace
		end)

		for _, p in ipairs(workspace_panes) do
			wezterm.run_child_process({
				"/opt/homebrew/bin/wezterm",
				"cli",
				"kill-pane",
				"--pane-id=" .. p.pane_id,
			})
		end
	end
end
return M