---
description: sketchybar popup の行間 (vertical pitch) は parent.popup.height で決まる
paths:
  - "home/dot_config/sketchybar/items/spaces.lua"
  - "home/dot_config/sketchybar/items/widgets/*.lua"
  - "home/dot_config/sketchybar/items/calendar.lua"
  - "home/dot_config/sketchybar/items/*.lua"
  - "home/dot_config/sketchybar/default.lua"
---

# sketchybar popup の行間 (vertical pitch) 制御

## 結論

popup 内に複数の item を縦に並べたときの **各行の vertical pitch** は、**parent item の `popup.height`** プロパティ (sketchybar 内部名 `popup->cell_size`) で決まる。

未指定 (= -1) のとき default は **bar.height**。dotfiles 設定の bar.height では 1 行 ~80px もの slot を取り、間延びして見える。

## 仕組み

sketchybar 公式ソース (`src/popup.c::popup_calculate_bounds`) より、popup 内の各 row は次のように配置される:

```c
// src/popup.c (近似)
for (each child item) {
  cell_height = max(bar_item_get_height(item), popup->cell_size);
  item_height = cell_height;
  window->frame.origin.y = popup->anchor.y + running_y;
  window->frame.size.height = item_height;
  running_y += cell_height;
}
popup_background.height = running_y;
```

- `popup->cell_size` は parent の `popup.height` プロパティそのもの
- 各 row の height は **`max(item の自然高さ, popup.height)`**
- `running_y` を `cell_height` ずつ進めるため、これが **行ピッチ** になる
- popup 全体の bg 高さは `running_y` から計算される (auto-fit)

つまり `popup.height` を小さく設定すれば、子 item の自然高さがそれより小さい限り、その値が行ピッチとなる。

## 実装パターン

```lua
local item = sbar.add("item", "widgets.foo", {
  position = "right",
  -- ...
  popup = {
    align = "center",
    height = 20,  -- ← 各行の vertical pitch (px)
    background = {
      color = colors.tn_black3,
      border_color = colors.purple,
      border_width = 2,
    },
  },
})

-- popup 行
sbar.add("item", "widgets.foo.popup.1", {
  position = "popup." .. item.name,
  icon = { string = "...", font = { size = 11.0 } },
  label = { string = "...", font = { size = 11.0 } },
})
```

## ⚠️ よくある誤解

### ❌ 子 item の `background.height` を縮めれば行が詰まる

```lua
-- ダメな例
sbar.add("item", "popup.row", {
  position = "popup." .. parent.name,
  background = { drawing = false, height = 18, border_width = 0 },  -- 効かない
})
```

理由: `bar_item_get_height(item)` は背景描画が `drawing = off` なら text 高さしか参照しない。だが行ピッチは `max(自然高さ, popup->cell_size)` なので、`popup->cell_size` (= bar.height ~80) が支配的になる。**子 item の `background.height` をいじっても行間は縮まない**。

### ❌ `popup.y_offset` で行間を縮めようとする

`popup.y_offset` は **popup 全体の anchor を上下にずらすだけ** (`popup_set_anchor` で参照)。行間制御には無関係。

### ❌ item-level の `y_offset` で行間を縮めようとする

`item.y_offset` は **その row 内で content を上下シフトするだけ**。行ピッチには影響しない (`bar_item_calculate_bounds` で内部適用)。

## チェックリスト

popup の行間が思ったより広い場合の確認:

- [ ] parent item の `popup.height` を明示的に設定したか？
- [ ] `--query <parent>` で `"popup": { "height": <値> }` を確認したか？ (未指定だと `-1`)
- [ ] 子 item に大きな `font.size` や `background.height` (drawing=on) が混じっていないか？
- [ ] popup 自体の border_width が大きすぎないか？ (popup bg の border は外周のみで行ピッチには影響しないが、見た目の総高さに加算される)

## 参考実装

- `home/dot_config/sketchybar/items/widgets/github.lua` の `gh_item.popup.height = 20`

## 出典

- sketchybar 公式 docs: <https://felixkratz.github.io/SketchyBar/config/popups>
  > **height** — The vertical spacing between items in a popup. (default: bar height)
- ソース: `src/popup.c::popup_calculate_bounds` (cell_height / running_y)、`popup_set_cell_size` (PROPERTY_HEIGHT で popup.height にマップ)
