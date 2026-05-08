---
description: sketchybar bracket の auto-fit と padding 制御に関するルール
paths:
  - "home/dot_config/sketchybar/items/spaces.lua"
  - "home/dot_config/sketchybar/items/widgets/*.lua"
  - "home/dot_config/sketchybar/items/calendar.lua"
  - "home/dot_config/sketchybar/items/*.lua"
  - "home/dot_config/sketchybar/default.lua"
  - "home/dot_config/sketchybar/settings.lua"
---

# sketchybar bracket の左右 padding 制御

## 前提

sketchybar の `bracket` は、内包する **member item の総幅 (item bg の左端〜右端) に auto-fit** する。
従って bracket の幅は members の `icon.padding_left/right` / `label.padding_left/right` / `padding_left/right` の合計で決まる。

## レイアウトモデル

```
[bracket bg ─────────────────────────────]
   ↑                                    ↑
   ├── item 1 ──┤├── item 2 ──┤
   |  [icon][lbl]||  [icon][lbl]|
   ↑     ↑            ↑       ↑
   A     B            C       D
```

| 部位 | 制御するプロパティ | 役割 |
|------|--------------------|------|
| **A** | item 1 の `icon.padding_left` | bracket bg 左端から最初の icon 開始までの余白 = **枠内 左 padding** |
| **B** | item 1 の `icon.padding_right` + `label.padding_left` | item 内部の icon ↔ label 間隔 |
| **C** | item 2 の `icon.padding_right` + `label.padding_left` | item 内部の余白 |
| **D** | 最後の item の `label.padding_right` | 最後の label 終端から bracket bg 右端までの余白 = **枠内 右 padding** |

## ルール

### 1. 枠内左右の padding を小さくしたいとき
→ **`icon.padding_left` (左端) と `label.padding_right` (右端)** を縮める。
ただし bracket bg は auto-fit で連動して縮む。**「枠内余白」と「bracket 全体サイズ」を独立に調整することはできない**。

### 2. bracket フレーム全体を縮めたいとき
→ 同じく `icon.padding_left` / `label.padding_right` を縮める。
あるいは icon/label の font size、それ以外の padding も含めて全方向で縮める。

### 3. bracket は同じ幅のまま、見た目の枠内余白だけ増やしたいとき
→ `bracket.background.padding_left/right` を **正の値** に設定 (bg が member 外側に拡張)。

### 4. bracket bg だけを縮めて content より小さくしたいとき
→ `bracket.background.padding_left/right` を **負の値** に設定。
ただし content が bracket からはみ出す不自然な見た目になるので非推奨。

## 重要な制約

**「枠内 padding だけを縮めて bracket は維持する」は構造上できない**。
bracket は auto-fit するため、content padding を変更すれば必ず bracket 全体サイズも変わる。同じ縮小比なら視覚的な「窮屈感」も大きく変わらない。

枠内余白を変えずに bracket だけ縮めたい場合は font size / 内部 padding (B, C 部位) を縮めて item 自体の表示幅を減らす必要がある。

## 実例

`home/dot_config/sketchybar/default.lua`:
```lua
sbar.default({
  icon = {
    padding_left = 3,    -- 枠内 左 padding (A)
    padding_right = 1,   -- icon ↔ label の左半分 (B)
    ...
  },
  label = {
    padding_left = settings.paddings,   -- icon ↔ label の右半分 (B)
    padding_right = settings.paddings,  -- 枠内 右 padding (D)
    ...
  },
  padding_left = 6,      -- item 間 (bracket 外、隣の bracket との距離)
  padding_right = 6,     -- 同上
  ...
})
```

`settings.paddings` は label の左右両方を共有するので、変更すると **B (icon↔label) と D (枠内 右)** が同時に変わる。
独立に動かしたい場合は default.lua で label.padding_left / padding_right を別々に明示する。

## 禁止事項

- bracket 全体サイズを変えずに枠内余白だけ縮める指示が来たら、構造上不可能であることを説明する (盲目的にハックを試みない)
- `bracket.background.padding` を負の値にして content を bracket 外に押し出す解決策は採用しない

## widget 間 gap の独立制御 (CSS flexbox gap 思想)

### sketchybar bracket span 計算の真実

sketchybar 公式ソース (`src/group.c::group_get_length`) を読むと、bracket bg の **描画幅は最左/最右 member の `background.padding_left/right` から計算される**:

```
length = (last_member.x + last_member.width + last_member.background.padding_right)
       - (first_member.x - first_member.background.padding_left)
```

加えて重要な事実:
- `padding_left/right` (top-level) と `background.padding_left/right` は **同じフィールド** (`bar_item.background.padding_*`)。`--query` の `geometry.padding_left` も `background.padding_left` を表示している。
- `default()` の `padding_left=6` は `bar_item_inherit_from_item` の memcpy で **新規 bracket / item にそのまま伝搬** する。
- **bracket 自身の `background.padding_left/right` は span 計算に使われない**。bracket span は member 由来。
- bracket の **border は bg rect の内側に描画** (`CGRectInset(region, line_width/2, line_width/2)`)。bg を外側に拡張しない。

つまり **「bracket 自身に `padding=0` を設定する」のは無意味** (前回の試行はこれを誤解していた)。

### 正しい設計原則

CSS flexbox の `gap` のように widget サイズと gap を独立制御するには、**bracket の最左 member と最右 member の `padding_left/right` を 0 にする**:

```lua
local foo_first = sbar.add("item", "widgets.foo.first", {
  position = "right",
  icon = { padding_left = 5 },  -- 枠内左余白を icon 側で確保
  -- ...
  padding_left = 0,   -- ← bracket span に乗らないよう 0
})

local foo_last = sbar.add("item", "widgets.foo.last", {
  position = "right",
  label = { padding_right = 5 },  -- 枠内右余白を label 側で確保
  -- ...
  padding_right = 0,  -- ← bracket span に乗らないよう 0
})

sbar.add("bracket", "widgets.foo.bracket", { foo_last.name, foo_first.name }, {
  background = { color = ..., border_color = ... },
  -- bracket 自身に padding=0 を書く必要なし (span 計算には使われない)
})
```

position="right" 系では addition 順 = 右→左 で並ぶので、**最初に追加した item が最右 = `padding_right=0` 対象**、**最後に追加した item が最左 = `padding_left=0` 対象**。

これにより:
- bracket bg は member 群の content にちょうど収まる
- bracket 間の **視覚的 gap = spacer item の width** (border は bg 内側描画なので border_width も控除しない)
- font size / icon padding / bracket bg.height を後から変えても gap は変動しない

### 枠内余白の確保

member.padding_left/right=0 にすると枠内の左右余白が消えるので、**member の `icon.padding_left` / `label.padding_right` で別途確保** する:

| 元の表現 | 修正後の表現 |
|---------|------------|
| `cpu.padding_left = 5` | `cpu.icon.padding_left = 5` + `cpu.padding_left = 0` |
| `battery.padding_right = 5` | `battery.label.padding_right = 5` + `battery.padding_right = 0` |

### gap の集中管理

各 widget 末尾の spacer は `width = settings.widget_gap, padding_left = 0, padding_right = 0` で固定:

```lua
sbar.add("item", { position = "right", width = settings.widget_gap, padding_left = 0, padding_right = 0 })
```

`settings.widget_gap` (現状 8) を変更すれば全 widget 間 gap が一括で変動する。spacer 自身の padding=0 を明示するのは、default 経由で `padding_left=6` が継承され spacer 横幅に乗ってしまうのを防ぐため。

### 例外: spaces.lua の monitor bracket

左側 (`group.builtin / ultragear / dell / dynamic`) は member (= space chip) 自身に `padding_left/right=GROUP_GAP` (= 4 の固定値) を入れて、bracket span に乗せる流儀になっている。これも結果として bracket bg を chip 群の左右に 4px ずつ拡張するが、用途 (chip の左右に色付き余白を出す) が widget bracket とは異なる。混在させない。

### 例外: bar 端の余白

bar の最右端 (battery 末尾の `width=6` spacer) は隣接 bracket がないため widget_gap とは別目的で維持。

## text overlay 設計の widget で bracket bg が text 全幅を覆わない問題

### 症状

graph 上に text label を overlay する設計 (例: wifi.lua の `wifi_up_graph` 上に `wifi_up.label` を `padding_left=-64.5, width=0` で重ねる) では、**text label の物理 width が 0 で graph の width=42 よりも実描画 string の幅が大きい** とき、text が graph の右端を超えて bracket bg の外に **はみ出して描画される**。

これは sketchybar の bracket span 計算が `member.x + member.width + member.padding_right` のみを見て、`label.string` の実描画幅を考慮しないため。

### 根本対処: 不可視固定幅 spacer member

**bracket member 配列に「不可視固定幅 spacer」を追加** して bracket 幅を強制的に伸ばす。これは sketchybar 公式 (felixkratz) が推奨する workaround で、`group_get_first/last_member` がこの spacer を最右 (or 最左) member として認識し、bracket span がその width まで広がる:

```lua
-- text overlay の右側 overhang を吸収する不可視 spacer
local foo_text_spacer = sbar.add("item", "widgets.foo.text_spacer", {
  position = "right",  -- addition 順で最初に追加 = 最右になる
  width = N,           -- text overhang ぶんの px
  background = { drawing = false },
  label = { drawing = false },
  icon = { drawing = false },
  padding_left = 0,
  padding_right = 0,
})

-- 続いて他の widget items
-- ...

-- bracket member 配列にこの spacer を含める
sbar.add("bracket", "widgets.foo.bracket", {
  -- 通常の members,
  foo_text_spacer.name,  -- ← 必須
}, { background = { ... } })
```

### nested bracket は使えない

CSS の「container 内に container」のような nested bracket は **sketchybar 仕様で不可能**。

`src/group.c::group_add_member` で「member が group head なら、その group の members[1..] を flatten して追加する」処理があるため、bracket を bracket の member にしても **平坦化** され、独立した nested 関係は作れない。

```c
// src/group.c
if (item is group head) {
  // add item->group->members[1..] instead of item itself
}
```

そのため flexbox container 風の固定幅 frame を実現する唯一の sketchybar-native な方法が上記の「不可視固定幅 spacer member」パターンとなる。

### 不可視 spacer の判定条件

- `background.drawing = false` (bg 描画なし)
- `label.drawing = false`, `icon.drawing = false` (text/icon 描画なし)
- ただし item の **`drawing` 自体は default の "on"** を維持 (off にすると bracket span 計算で skip される可能性)
- `padding_left = 0, padding_right = 0` で gap に乗らないようにする
- `width` で固定幅を指定 (これが bracket span に直接乗る)

## sketchybar API で**存在しない / 効かない** プロパティ (重要)

設計を立てる前に、以下の **存在しない** プロパティを目的に使わないこと。これらに頼った responsive layout は不可能:

| プロパティ | 状況 | 出典 |
|----------|------|------|
| `bar_item.x_offset` | **存在しない**。`y_offset` のみ | `bar_item.h` の struct |
| `graph.padding_left/right` | **存在しない**。graph 線描画位置を内部で動かす手段なし | `graph.h` の struct (color/fill_color/line_width のみ) |
| `graph.align` | **存在しない**。`rtl` フラグは bar の左右側面で自動判定される | `graph.h`、`bar.c` |
| `background.x_offset` | 存在するが**安全でない**。shadow offsets 経由で window frame を変えるため bracket span に影響する | `bar_item_calculate_shadow_offsets`、`bar.c` |
| `background.clip` | drawing をクリップするが**layout には影響しない**。bracket span 制御には使えない | `background_clip_bar`、`group_get_length` |

### 連鎖の本質: `group_get_length` の式

```c
// src/group.c::group_get_length
length = (last_window->origin.x + last_window->frame.size.width + last_item->background.padding_right)
       - (first_window->origin.x - first_item->background.padding_left)
```

`first_window->origin.x` は bar 全体の addition 順から連鎖的に決まる。**内部 member の padding を変えると、その左にある全 item の x 位置がドミノで移動し、最左 member の `window.origin.x` が変わる** → bracket span が変動する。

つまり **「内部 member の padding 変更が bracket span に影響しない」という分離は通常の addition 順 layout では実現できない**。

## 責務分離の唯一の手段: 固定幅 sub-items 構造

layout (bracket span) と visual (内部 item の x 位置) を独立に制御する唯一の方法は、**各 item に明示的な `width=N` を設定して内部 widths を固定する** こと。widths が固定なら内部の padding を変えても各 item の物理 width は不変、bracket span も不変。

### パターン

```lua
-- bracket member の addition 順 (visual 右→左):
-- [cap_right(width=0)] [item_A(width=W_A)] [item_B(width=W_B)] ... [cap_left(width=0)]

local cap_right = sbar.add("item", "widgets.foo.cap_right", {
  position = "right",
  width = 0,
  background = { drawing = false },
  label = { drawing = false },
  icon = { drawing = false },
  padding_left = 0, padding_right = 0,
})

local item_A = sbar.add("graph", "widgets.foo.A", N_DATA_POINTS, {
  position = "right",
  width = W_A,  -- 明示固定幅
  graph = { ... },
  background = { ... },
  padding_left = 0, padding_right = 0,
})

-- 上下 overlay する 2 item は同じ width で padding_left=-W で完全 overlap
local item_B_overlay = sbar.add("graph", "widgets.foo.B", N_DATA_POINTS, {
  position = "right",
  width = W_A,
  padding_left = -W_A,  -- item_A と縦 overlay (x 位置完全一致)
  ...
  y_offset = different,  -- y で上下分離
})

-- ... 他の固定幅 items
local cap_left = sbar.add("item", "widgets.foo.cap_left", {
  position = "right",
  width = 0,
  background = { drawing = false },
  ...
})

sbar.add("bracket", "widgets.foo.bracket", {
  cap_left.name,
  -- 中間 items を左→右の visual 順で,
  cap_right.name,
}, { background = { ... } })
```

### このパターンが responsive な理由

- 各 item の `width=N` が固定値 → bracket span = 全 widths の総和 (固定)
- 内部の `padding_left/right` 変更や上下 overlay 用の `padding_left=-W` は、各 item の物理 width を変えない → span 不変
- 内容 (label.string や graph data) が変わっても widths は不変 → span 不変

### 適用判断

| widget タイプ | 設計 |
|------------|------|
| 単純な icon + label (cpu/memory/volume/battery) | 通常の bracket member padding=0 設計で十分 |
| graph + text の overlay 設計 (wifi) | **固定幅 sub-items 構造が必須** |
| 複数 item を縦 overlay (上下 2 段) | 同じ width の item を `padding_left=-W` で重ねる |
| widget 全体を固定 width にしたい | cap_left / cap_right (width=0 不可視 cap) で範囲を明示 |
