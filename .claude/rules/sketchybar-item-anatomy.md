---
description: sketchybar item の構造図 (公式 docs の bar_item.jpg)。padding 各プロパティが item の中でどこに位置するかを完全に把握する
paths:
  - "home/dot_config/sketchybar/items/**/*.lua"
  - "home/dot_config/sketchybar/default.lua"
---

# sketchybar item の構造 (公式 docs より)

出典: <https://felixkratz.github.io/SketchyBar/config/items> の bar_item.jpg

## 構造図 (左→右)

```
┌─────────────────────────────────────────────────────────────────┐
│ [bg.padding_left][icon.padding_left][icon][icon.padding_right]  │
│   (purple, 外)    (red, bg 内)            (red, bg 内)            │
│                                                                  │
│ [label.padding_left][label][label.padding_right][bg.padding_right]│
│ (blue, bg 内)              (blue, bg 内)         (purple, 外)     │
└─────────────────────────────────────────────────────────────────┘
   └─ 外側余白 ─┘└──────────── bg (緑枠、可視) ──────────────┘└─ 外側余白 ─┘
```

## 4 種類の padding の意味

| padding | 図の枠色 | 位置 | 役割 |
|---------|---------|------|------|
| **`background.padding_left/right`** | **紫枠** | bg の **外側** | bg と隣接 item の間の余白。**inter-item gap 制御** |
| **`icon.padding_left/right`** | **赤枠** | bg の **内側** | icon glyph と隣接 (bg edge / label) の間 |
| **`label.padding_left/right`** | **青枠** | bg の **内側** | label glyph と隣接 (icon / bg edge) の間 |

## 重要な事実

### 1. item の box は 2 層構造

外側 (紫枠 = item slot) と 内側 (緑枠 = bg)。両者の間の余白が `bg.padding_left/right`。

### 2. icon と label の間の gap

```
icon glyph ↔ label glyph の間隔 = icon.padding_right + label.padding_left
```

両者を合わせて gap を作る。線形・加算。

### 3. inter-item gap (公式 docs と公式画像より)

```
item A の右 ↔ item B の左 の visible gap = A.bg.padding_right + B.bg.padding_left
```

これは bg 同士の間の余白。線形・加算。

### 4. 縦方向

`background.height` で bg の縦高さを制御。bar.height (bar 全体の高さ) は変えない。bg は bar 中央 y=bar.height/2 に center 配置 (y_offset で調整可能)。

## 設計原則

1. **icon ↔ label の gap 制御** = `icon.padding_right` または `label.padding_left` (item 内部、線形)
2. **item 同士の gap 制御** = `bg.padding_left/right` (item 間、線形)
3. **default.lua の継承で見えない padding がある可能性** に注意。 widget で意図する値は明示する

## 禁止事項

- 4 種類の padding の役割を混同しない
- `bg.padding_left/right` を「`padding_left/right` (item-level) と同じ」と思い込まない (両者は別フィールドで両方とも outer 余白だが、bg padding は bg edge 基準)
