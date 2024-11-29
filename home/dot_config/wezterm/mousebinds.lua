local wezterm = require("wezterm")
local act = wezterm.action


-- マウス操作の挙動設定
-- NOTE: tmuxをオンにすると、この設定は動作しなくなる
return {
    mouse_bindings = {
        -- 右クリックでクリップボードから貼り付け
        {
            event = { Down = { streak = 1, button = 'Right' } },
            mods = 'NONE',
            action = act.PasteFrom("Clipboard"),
        },
    }
}