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

ここで `bar_height` は `bar.lua` の `height` (現状 44px)。
graph item の `background.height` は描画範囲の上限ではなく、**chart 描画は bar 全体を基準にスケーリングされる**。

memory は `fill = true` 相当 (subscribe 内で `fill_color` を動的設定) のため、push 値が大きいと縦長の塗りつぶし矩形が目立ち、bracket からはみ出ると視認上のインパクトが大きい。慎重に scaling する。

## divisor の決め方

「100% メモリ使用時に chart top が bracket の上端ぴったりに到達する」ことを目標とすると:

```
chart_at_100% = bracket.bg.height
(100 / divisor) × bar_height = bracket.bg.height
divisor = 100 × bar_height / bracket.bg.height
```

### 比例縮小での再計算 (bracket サイズが変わったとき)

リファレンスの初期値 `divisor = 150` は **bracket bg = 34 用** に調整されている。
`bracket.bg.height` を変更したら、divisor も比例調整する:

```
divisor_new = divisor_old × (bracket_old / bracket_new)
```

例: bracket を 34 → 30 に縮めた場合:
```
divisor = 150 × (34 / 30) = 170
```

## 適用例

`home/dot_config/sketchybar/items/widgets/memory.lua`:
```lua
memory_graph:subscribe("memory_update", function(env)
  local used_percentage = tonumber(env.used_percentage)
  -- chart_height = push × bar_height (44px)
  -- リファレンス /150 は bracket=34 用なので、bracket=30 へ縮めた分だけ divisor を拡大
  -- divisor = 150 × (34 / 30) = 170
  memory_graph:push({ used_percentage / 170.0 })
  ...
end)
```

## 禁止事項

- 「とりあえず /200 にしておけば収まるだろう」など経験則で divisor を決めない
- bracket サイズを変更したら **必ず** 上記の式で再計算する
- リファレンス値 /150 をそのまま流用しない (bracket サイズが違えば破綻する)
- fill_color を強調表示にする際は、特に divisor を保守的に取る (memory が大きいと矩形が目立つため)
