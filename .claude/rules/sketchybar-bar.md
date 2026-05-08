---
description: sketchybar の bar (グローバル設定) の公式仕様。bar 全体の高さ、余白、表示位置などのプロパティ
paths:
  - "home/dot_config/sketchybar/bar.lua"
  - "home/dot_config/sketchybar/init.lua"
---

# sketchybar bar の公式仕様

出典: <https://felixkratz.github.io/SketchyBar/config/bar>

## bar 設定の方法

```bash
sketchybar --bar <setting>=<value> ... <setting>=<value>
```

SbarLua:
```lua
sbar.bar({
  height = 44,
  padding_left = 8,
  padding_right = 8,
  ...
})
```

## bar プロパティ一覧

| プロパティ | 型 | default | 役割 |
|-----------|----|---------|------|
| `color` | argb_hex | `0x44000000` | bar の色 |
| `border_color` | argb_hex | `0xffff0000` | border の色 |
| `position` | `top`, `bottom` | `top` | 画面上の位置 |
| `height` | int | `25` | bar の **高さ** (item の縦範囲はここに依存) |
| `notch_display_height` | int | `0` | notch ある display での bar 高さ override |
| `margin` | int | `0` | bar の周囲マージン |
| `y_offset` | int | `0` | bar 自身の縦方向オフセット |
| `corner_radius` | +int | `0` | bar の角丸 |
| `border_width` | +int | `0` | bar の border 幅 |
| `blur_radius` | +int | `0` | bar 背景のぼかし |
| **`padding_left`** | +int | `0` | bar 左端と最左 item の間の余白 |
| **`padding_right`** | +int | `0` | bar 右端と最右 item の間の余白 |
| `notch_width` | +int | `200` | 内蔵 display の notch 幅 |
| `notch_offset` | +int | `0` | notch 画面用の追加 y_offset |
| `display` | `main`, `all`, ids | `all` | 表示する display |
| `hidden` | bool, `current` | `off` | bar 非表示 |
| `topmost` | bool, `window` | `off` | window より前面 |
| `sticky` | bool | `on` | space 切替で sticky |
| `font_smoothing` | bool | `off` | フォントスムージング |
| `shadow` | bool | `off` | bar の影 |

## 重要な事実

- **bar.height は item の縦配置の基準**。`bar_item.y_offset` は bar.height と bar 中央 (y=bar.height/2) を基準に計算される
- **`bar.padding_left/right` は最も外側の item と bar 端の間の余白**。これは default 0 だが、SbarLua の reference 設定では 8 等が使われる
- **`bar.padding_left/right` は inter-item gap には影響しない** (それは各 item の `bg.padding_left/right` で制御)
- **`shadow=on`** で bar 全体に影。一般に `off` で十分

## 設定箇所

- `bar.lua` で `sbar.bar({...})` 経由で設定
- 通常は init.lua から `require("bar")` される
