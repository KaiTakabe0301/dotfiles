---
description: memory_graph:push の正規化スケール (divisor) を bracket サイズから論理計算するルール
paths:
  - "home/dot_config/sketchybar/items/widgets/memory.lua"
---

# memory graph の正規化 divisor 計算ロジック

## ルール

`memory_graph:push({ used_percentage / N.0 })` の `N` (divisor) は **論理的に計算する**。経験則で適当な値を選ぶのは禁止。

## 仕様 (実機観察から判明)

sketchybar の graph 描画は次の式に従う:
```
chart_height = push_value × bar_height
             = (used_percentage / divisor) × bar_height
```

ここで `bar_height` は `bar.lua` の `height` (現状 32px)。
chart 描画は **bar 全体の高さ** を基準にスケーリングされる。

memory は `fill = true` 相当 (subscribe 内で `fill_color` を動的設定) のため、push 値が大きいと縦長の塗りつぶし矩形が目立ち、bracket からはみ出ると視認上のインパクトが大きい。慎重に scaling する。

## divisor の決め方

「100% メモリ使用時に chart top が graph 自身の背景上端ぴったりに収まる」ことを目標とする。
**分母は bracket の bg.height ではなく、graph item 自身の `background.height` (現状 22)** を使う
(bracket には `background.height` を設定していない = デフォルト bar.height のため、分母に使うと過大になり graph が枠からはみ出す):

```
chart_at_100% = graph.background.height
(100 / divisor) × bar_height = graph.background.height
divisor = 100 × bar_height / graph.background.height
        = 100 × 32 / 22 ≈ 145
```

### 再計算 (bar.height か graph.background.height が変わったとき)

どちらかを変えたら上式で再計算する。比例で書くと:
```
divisor_new = divisor_old × (bar_new / bar_old) × (graph_bg_old / graph_bg_new)
```

## 適用例

`home/dot_config/sketchybar/items/widgets/memory.lua`:
```lua
memory_graph:subscribe("memory_update", function(env)
  local used_percentage = tonumber(env.used_percentage)
  -- chart_height = push × bar.height (32px)
  -- 100% で graph 自身の background.height(=22) に収める
  -- divisor = 100 × bar.height / graph背景height = 100 × 32 / 22 ≈ 145
  memory_graph:push({ used_percentage / 145.0 })
  ...
end)
```

## 禁止事項

- 「とりあえず /200 にしておけば収まるだろう」など経験則で divisor を決めない
- **分母に bracket の bg.height を使わない** (bracket に background.height 未設定なら bar.height 扱いになり過大になる)
- bar.height / graph.background.height を変更したら **必ず** 上式で再計算する
- fill_color を強調表示にする際は、特に divisor を保守的に取る (memory が大きいと矩形が目立つため)

## graph item の水平 padding の扱い

graph item の `padding_left` / `padding_right` は **隣接 item (memory icon+label) との水平距離** を制御する。bracket の縦サイズや横サイズの変更とは **本来独立**。

| bracket 変更 | y_offset | divisor | graph 水平 padding |
|--------------|----------|---------|---------------------|
| 縦 (height) を変える | **必須** | **必須** | 不要 (連動なし) |
| 横 (内部 padding) を変える | 不要 | 不要 | 状況次第 (視覚的に窮屈/間延びしたら調整) |

bracket 横サイズ縮小時、graph item の水平位置は隣接 item に追随して自動的に詰まる (auto-fit)。手動調整が必要なのは以下のケースのみ:

- text と graph 左端が **詰まりすぎ** た → `padding_left` を負方向に小さく (例: `-8 → -5` で隙間広げる)
- text と graph 左端が **空きすぎ** た → `padding_left` をより負に大きく (例: `-5 → -10` で詰める)
- graph 右端が bracket 右端と接触した → `padding_right` を増やす

つまり「bracket サイズが変わったから機械的に調整する」のではなく、**実視認で違和感が出たときのみ** ケースバイケースで動かす。
