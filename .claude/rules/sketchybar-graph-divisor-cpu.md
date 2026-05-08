---
description: cpu_graph:push の正規化スケール (divisor) を bracket サイズから論理計算するルール
paths:
  - "home/dot_config/sketchybar/items/widgets/cpu.lua"
---

# cpu graph の正規化 divisor 計算ロジック

## ルール

`cpu_graph:push({ load / N. })` の `N` (divisor) は **論理的に計算する**。経験則で適当な値を選ぶのは禁止。

## 仕様 (実機観察から判明)

sketchybar の graph 描画は次の式に従う:
```
chart_height = push_value × bar_height
             = (load / divisor) × bar_height
```

ここで `bar_height` は `bar.lua` の `height` (現状 44px)。
graph item の `background.height` は描画範囲の上限ではなく、**chart 描画は bar 全体を基準にスケーリングされる**。

## divisor の決め方

「100% 入力時に chart top が bracket の上端ぴったりに到達する」ことを目標とすると:

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

`home/dot_config/sketchybar/items/widgets/cpu.lua`:
```lua
cpu_graph:subscribe("cpu_update", function(env)
  local load = tonumber(env.total_load)
  -- chart_height = push × bar_height (44px)
  -- リファレンス /150 は bracket=34 用なので、bracket=30 へ縮めた分だけ divisor を拡大
  -- divisor = 150 × (34 / 30) = 170
  cpu_graph:push({ load / 170. })
  ...
end)
```

## 禁止事項

- 「とりあえず /200 にしておけば収まるだろう」など経験則で divisor を決めない
- bracket サイズを変更したら **必ず** 上記の式で再計算する
- リファレンス値 /150 をそのまま流用しない (bracket サイズが違えば破綻する)

## graph item の水平 padding の扱い

graph item の `padding_left` / `padding_right` は **隣接 item (cpu icon+label) との水平距離** を制御する。bracket の縦サイズや横サイズの変更とは **本来独立**。

| bracket 変更 | y_offset | divisor | graph 水平 padding |
|--------------|----------|---------|---------------------|
| 縦 (height) を変える | **必須** | **必須** | 不要 (連動なし) |
| 横 (内部 padding) を変える | 不要 | 不要 | 状況次第 (視覚的に窮屈/間延びしたら調整) |

bracket 横サイズ縮小時、graph item の水平位置は隣接 item に追随して自動的に詰まる (auto-fit)。手動調整が必要なのは以下のケースのみ:

- text と graph 左端が **詰まりすぎ** た → `padding_left` を負方向に小さく (例: `-8 → -5` で隙間広げる)
- text と graph 左端が **空きすぎ** た → `padding_left` をより負に大きく (例: `-5 → -10` で詰める)
- graph 右端が bracket 右端と接触した → `padding_right` を増やす

つまり「bracket サイズが変わったから機械的に調整する」のではなく、**実視認で違和感が出たときのみ** ケースバイケースで動かす。
