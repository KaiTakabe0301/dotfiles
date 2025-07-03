local wezterm = require("wezterm")
local act = wezterm.action

return {
  keys = {
    -- コマンドパレット表示
    { key = "p", mods = "SUPER", action = act.ActivateCommandPalette },

    -- 画面フルスクリーン切り替え
    { key = "Enter", mods = "ALT", action = act.ToggleFullScreen },

    -- アプリケーション終了
    { key = 'q', mods = "SUPER", action = act.QuitApplication },

    -- コピーモードは利用せず、tmuxのコピーモードを利用する
    -- { key = "[", mods = "LEADER", action = act.ActivateCopyMode },

    -- コピー
    { key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
    -- 貼り付け
    { key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },

    -- フォントサイズ切替
    { key = "+", mods = "CTRL", action = act.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = act.DecreaseFontSize },

    -- フォントサイズのリセット
    { key = "0", mods = "CTRL", action = act.ResetFontSize },

    -- コマンドパレット
    { key = "p", mods = "SHIFT|CTRL", action = act.ActivateCommandPalette },
    -- 設定再読み込み
    { key = "r", mods = "SHIFT|CTRL", action = act.ReloadConfiguration },

    -- claude codeなどのcliで改行する
    { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString('\n')}
  },
}