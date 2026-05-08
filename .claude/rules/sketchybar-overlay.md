---
description: sketchybar / SbarLua で 2 つ以上の item を同じ x 位置に重ねる (overlay する) 唯一の正しい手法。第 1 item に width=0 を設定する
paths:
  - "home/dot_config/sketchybar/items/**/*.lua"
---

# sketchybar item overlay の正しい仕組み

## 結論

**2 つの item を同じ x 位置に重ねる (overlay する) には、第 1 item に `width = 0` を設定する**。

これは sketchybar / SbarLua 公式の唯一の overlay 手法 (専用フラグなし)。

## 仕組み

sketchybar の bar layout は **single-pass cursor advance**:
- bar 上で「次 item の x 位置」を表す cursor を持ち、各 item を配置するごとに cursor を進める
- 各 item の advance 量 = item の物理 width + bg.padding (item 種別による)

`width = 0` (item-level の custom_width override) を設定すると:
- item は **bar slot を 0 消費** (cursor 進まず)
- ただし **glyph / graph などの content は描画される** (display sizing は ignore_override=true で別計算)
- 結果: 次 item は同じ x から描画 = **overlay**

source: <https://github.com/FelixKratz/SketchyBar/blob/master/src/bar_item.c> (`bar_item_set_width`, `bar_item_get_length`)

## 実装パターン

### パターン 1: 2 つの graph を縦 overlay する

```lua
-- 第 1 graph: width=0 で bar slot 0、次 item と x overlay
local graph_up = sbar.add("graph", "name1", DATA_POINTS, {
  position = "right",
  width = 0,  -- ← bar slot 0、graph_down と x 完全 overlay
  background = { padding_left = 0, padding_right = 0 },  -- default 6 を撤回
  graph = { ... },
  y_offset = 21,
})

-- 第 2 graph: 通常の auto-width で配置 (graph_up と同じ x)
local graph_down = sbar.add("graph", "name2", DATA_POINTS, {
  position = "right",
  -- width 設定なし (auto-width = data points 数 + 内部余白 12)
  background = { padding_left = 0, padding_right = 0 },
  graph = { ... },
  y_offset = 9,
})
```

### パターン 2: 2 つの text を縦 overlay する

```lua
local text_up = sbar.add("item", "name1", {
  position = "right",
  width = 0,  -- bar slot 0、text_down と x overlay
  icon = { string = "↑", ... },
  label = { string = "??? Bps", ... },
  y_offset = 6,
})

local text_down = sbar.add("item", "name2", {
  position = "right",
  -- width 設定なし (auto-width)
  icon = { string = "↓", ... },
  label = { string = "??? Bps", ... },
  y_offset = -6,
})
```

## ⚠️ よくある失敗パターン

### ❌ `padding_right = -W` で overlay しようとする

```lua
-- ダメな例
local graph_down = sbar.add("graph", ..., {
  padding_right = -W_PHYSICAL,  -- これでは overlay しない
})
```

理由: `padding_right` は **その item の右側余白** (= 次 item との関係)。 cursor は前 item の advance で既に進んでいるため、自身の `padding_right` を負値にしても **既に進んだ cursor は戻せない** (隣接配置になるだけ)。

### ❌ `background.x_offset` で位置をずらそうとする

```lua
-- ダメな例
local graph_down = sbar.add("graph", ..., {
  background = { x_offset = -54 },  -- これは描画位置のみ動かす
})
```

理由: `bg.x_offset` は **描画位置の shift** で、layout cursor には影響しない。ただし sketchybar 内部で **shadow_offsets 経由で window frame に影響して bracket span を変える** 副作用がある。layout の overlay には使えない。

### ❌ graph item の data points を 0 にする

```lua
-- ダメな例
local graph = sbar.add("graph", "name", 0, { ... })  -- 第 3 引数を 0 にする
```

理由: 第 3 引数は graph の **sample count**。0 にすると `graph_push_back` で `modulo by zero` が発生して undefined / buggy 動作になる。**graph の data points は >= 1**、layout 上の overlay は **item-level の `width=0`** で実現する。

## チェックリスト

overlay が機能しない場合の確認:

- [ ] 第 1 item (visual で右の方) に `width = 0` を設定したか？
- [ ] 第 1 item の `background.padding_left = 0` か？ (default 6 が継承されると pre-step が発生)
- [ ] graph の場合、data points (第 3 引数) は 0 にしていないか？
- [ ] addition 順は「overlay したい 2 item を連続させているか」？

## 参考実装

- `home/dot_config/sketchybar/items/widgets/wifi.lua` の `graph_up` / `graph_down`、 `text_up` / `text_down` の overlay
