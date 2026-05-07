---
description: sketchybar の y_offset 方向ルール (positive = UP)
paths:
  - "home/dot_config/sketchybar/items/spaces.lua"
  - "home/dot_config/sketchybar/items/widgets/*.lua"
  - "home/dot_config/sketchybar/items/calendar.lua"
  - "home/dot_config/sketchybar/items/*.lua"
  - "home/dot_config/sketchybar/default.lua"
  - "home/dot_config/sketchybar/bar.lua"
---

# sketchybar `y_offset` の方向

## ルール

sketchybar における `y_offset` は **`positive = UP` (上方向にシフト)**。

- `y_offset = +N` → 自然位置から **N px 上にシフト**
- `y_offset = -N` → 自然位置から N px 下にシフト
- `y_offset = 0` → シフトなし (item の bottom が bar の bottom と一致)

## 自然位置の定義

各 item の自然位置は **item.bottom が bar.bottom (現状 y=44) に固定**。
y_offset で **bottom を基準に** 上方向にシフトする。

つまり:
```
item.bottom_actual = bar_height - y_offset
```

## 計算例 (現状の bar=44, bracket bg=30 の場合)

| 配置 | item.bottom 目標 | y_offset |
|------|------------------|----------|
| bracket 中央配置 | bar_center + bg.height/2 = 22 + 11 = 33 | 11 |
| bracket bottom より 1px 上 | 36 | 8 |
| bracket 上段配置 (bg.height=11) | 21 | 23 |
| bracket 下段配置 (bg.height=11) | 35 | 9 |

## 経緯

- 当初、直感で `positive y_offset = DOWN` と仮定して y_offset を下げる方向に調整したが、グラフが下にはみ出した
- CLI で `sketchybar --set widgets.cpu.graph y_offset=15` を実行して上下確認したところ、graph が **上** に動いたことから方向を確定
- リファレンス (`SoichiroYamane/dotfiles`) の `y_offset = 4 / 21 / 9` 等の値も全て **「上方向シフト」** として読むのが正しい
