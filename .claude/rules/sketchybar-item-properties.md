---
description: sketchybar item の公式プロパティ仕様。padding / width / align / y_offset / icon / label など、layout に関わる全プロパティの定義
paths:
  - "home/dot_config/sketchybar/items/**/*.lua"
  - "home/dot_config/sketchybar/default.lua"
  - "home/dot_config/sketchybar/settings.lua"
---

# sketchybar item の公式プロパティ仕様

出典: <https://felixkratz.github.io/SketchyBar/config/items>

## 基本構造

item は以下の構成要素を持つ (詳細は `sketchybar-item-anatomy.md` 参照):
- **bg.padding_left/right**: bg と隣接 item の間の余白 (item box の外側)
- **bg**: visible background (緑枠)
- **icon.padding_left/right**: bg 内側、icon glyph と隣接の間
- **icon**: icon glyph
- **label.padding_left/right**: bg 内側、label glyph と隣接の間
- **label**: label glyph

## Geometry プロパティ (item-level)

| プロパティ | 型 | default | 役割 |
|-----------|----|---------|------|
| `position` | `left`, `right`, `center`, `q` (alias) | required | bar 内の配置位置 |
| `width` | int / `dynamic` | `dynamic` (auto-fit) | item の **layout width** (override)。`width=N` で固定、`width=0` で **bar slot 0 消費 = overlay 用** |
| `padding_left` | int | 0 | item の **外側左余白** (item box の外、隣接 item との関係) |
| `padding_right` | int | 0 | item の **外側右余白** |
| `y_offset` | int | 0 | 縦方向 offset。**positive = UP** (実機検証で確認、公式には未明記) |
| `update_freq` | int | 0 | event-driven 以外の自動更新間隔 (秒) |
| `updates` | bool | `on` | 更新の有無 |
| `drawing` | bool | `on` | 描画の有無。`off` で非表示 |
| `scroll_texts` | bool | `off` | 切り捨てた text の自動スクロール |
| `script` | str | "" | event 発火時のスクリプト |
| `click_script` | str | "" | クリック時スクリプト |

**重要**: **item-level の `align` プロパティは存在しない**。Geometry Properties に列挙されていない。`icon.align` / `label.align` は別物 (sub-text の alignment)。

## background プロパティ

| プロパティ | 型 | default | 役割 |
|-----------|----|---------|------|
| `color` | argb_hex | - | bg 色 |
| `border_color` | argb_hex | - | border 色 |
| `border_width` | +int | 0 | border 幅。**bg の内側に描画** (bg を外側に拡張しない) |
| `height` | +int | bar.height | bg の縦高さ。bar 中央 y=bar.height/2 を中心に上下に展開 |
| `corner_radius` | +int | 0 | bg の角丸 |
| `drawing` | bool | `off` | bg の描画 |
| **`padding_left`** | int | 0 | **bg と隣接 item bg の間の左余白**。`bg.padding_left + 隣 bg.padding_right = inter-item gap` (線形) |
| **`padding_right`** | int | 0 | bg の右余白 (同上) |
| `x_offset` | int | 0 | bg の x シフト (描画専用、layout には影響するので注意) |
| `y_offset` | int | 0 | bg の y シフト |
| `clip` | float | 0 | clipping fraction |
| `image` | image | - | bg 画像 |
| `shadow` | bool | `off` | bg の影 |

## icon / label プロパティ (text 共通)

icon と label は両方 "text" として扱われ、以下の共通プロパティを持つ:

| プロパティ | 型 | default | 役割 |
|-----------|----|---------|------|
| `string` | str | "" | 描画する文字列 |
| `font` | font | system | フォント (family / style / size) |
| `color` | argb_hex | - | 文字色 |
| `width` | int / `dynamic` | `dynamic` | text の **sub-box width**。`width=N` で固定 |
| `padding_left` | int | 0 | text glyph と sub-box edge の左余白 |
| `padding_right` | int | 0 | 同 右余白 |
| `align` | `left`, `center`, `right` | `left` | **sub-box 内の alignment**。**`text.width` が固定で content より大きいときのみ有効** |
| `y_offset` | int | 0 | text の縦シフト |
| `max_chars` | +int | -1 (無制限) | 最大文字数。超えると切り捨てまたは scroll |
| `drawing` | bool | `on` | text 描画。`off` で非表示 |
| `highlight` | argb_hex | - | highlight 色 |
| `highlight_color` | argb_hex | - | 同上 |
| `background` | bg | - | text 自身の bg (item bg とは別) |

## inter-item gap の式 (重要)

**visible gap between adjacent items = `prev_item.bg.padding_right + next_item.bg.padding_left`** (線形・加算)

`item-level の padding_left/right` も外側余白として加算される (公式仕様より)。

## item content の x 計算 (推測、公式に明記なし)

bg 内側で:
- icon 描画位置 = bg.x_left + icon.padding_left
- icon 描画範囲 = icon glyph 幅 (font による)
- label 描画位置 = icon 描画位置 + icon glyph 幅 + icon.padding_right + label.padding_left
- bg width = icon.padding_left + icon glyph 幅 + icon.padding_right + label.padding_left + label glyph 幅 + label.padding_right

## width=N の挙動

- `width=dynamic` (default): content_width で auto-fit
- `width=N` (N>=0): bar layout で **N 点を slot として確保**
  - N > content_width: content は左寄せ描画 (default)、右に余白
  - N == 0: **bar slot 0 消費** (cursor 進まず、次 item が同じ x で描画 = overlay 用)
  - N < content_width: 公式に未明記。実機では content が item box を超えて描画される模様

## y_offset の挙動

- positive y_offset = **UP** (実機検証で確認)
- 自然位置 = item.bottom が bar.bottom (y=bar.height)
- y_offset=N → item.bottom = bar.height - N

## 禁止事項

- **`item-level の align` プロパティを使用しない**。存在しないため、設定しても無効。alignment は `icon.align` / `label.align` で text-level でのみ動作 (固定 width 設定時のみ)
- **`bg.x_offset` は layout に影響しない** (描画位置のみシフト)。位置調整には別の手法を使う
