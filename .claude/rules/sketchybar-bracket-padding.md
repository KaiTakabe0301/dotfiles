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
