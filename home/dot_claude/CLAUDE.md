# 必須対応

## 1. 日本語で対応すること

プロンプトのやり取りは、全て日本語で行うこと

## 2. 「Stream idle timeout - partial response received」を回避するための対応

- ファイルへの書き込みは複数回に分割し、1回あたり最大150行までにする
- grep や find の出力が大量になる場合は head で件数を絞る
- 各タスクは1つずつ完結させてから次へ進む（複数の大きな操作を同時に行わない）
- セッションが長くなったら `/compact` でコンテキストを圧縮する

# Project Rules for Claude AI

## 1. プロジェクト全体のルール

以下のルールは、frontend、backend、infra など、プロジェクト全体で適用される基本的なルールです。

### 1-1. 技術スタック

- **パッケージマネージャー**: pnpm
- **プロジェクト構成**: monorepo
- **ビルドシステム**: Turborepo
- **言語**: TypeScript
- **linter**: ESLint
- **formatting**: Prettier
- **CI/CD**: GitHub Actions

## 2. Frontend Project Rules for Claude AI

このファイルは、Claude AI が Frontend のコードを生成・修正する際に従うべきルールを定義します。

### 2-1. 基本原則

Frontend を実装する際は、すべてのコード生成において、以下のルールを厳守してください。

### 2-2. 技術スタック

- **フレームワーク**: React 19
- **テストフレームワーク**: Vitest, React Testing Library
- **API Mocking**: MSW (Mock Service Worker)

### 2-3. プロジェクト構造の推奨事項

#### 2-3-1. フォルダ構成

利用するフレームワークによって異なる場合がありますが、以下のような構成を推奨します。

```
src/
├── components/                 # コンポーネントのルートディレクトリ
│   ├── ui/                    # 汎用的なUIコンポーネント
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.stories.tsx
│   │   │   ├── Button.test.tsx
│   │   │   ├── Button.module.css
│   │   │   ├── useButton.ts
│   │   │   └── useButton.test.ts
│   │   ├── Card/
│   │   ├── Modal/
│   │   └── Input/
│   └── domains/              # ドメインに紐づくコンポーネント
│       ├── UserProfile/
│       │   ├── UserProfile.tsx
│       │   ├── UserProfile.stories.tsx
│       │   ├── UserProfile.test.tsx
│       │   ├── useUserProfile.ts
│       │   └── useUserProfile.test.ts
│       ├── ProductCard/
│       └── OrderSummary/
├── hooks/                    # 汎用的なカスタムフック
│   ├── useDebounce/
│   │   ├── useDebounce.ts
│   │   └── useDebounce.test.ts
│   └── useLocalStorage/
├── types/                    # TypeScript型定義
├── utils/                    # ユーティリティ関数
└── lib/                      # 外部ライブラリの設定
```

**判断基準：**

- そのファイルが特定のコンポーネントに関連する → コンポーネントと同じディレクトリ
- 複数のコンポーネントで共有される → 適切な共有ディレクトリ（`hooks/`, `utils/` など）

### 2-5. ファイル命名規則

- コンポーネント: PascalCase (例: `UserCard.tsx`)
- カスタムフック: camelCase with 'use' prefix (例: `useUserData.ts`)
- ユーティリティ: camelCase (例: `formatDate.ts`)
- 型定義: PascalCase (例: `User.ts`)
- テストファイル: `*.test.ts` または `*.test.tsx` (例: `Button.test.tsx`, `useButton.test.ts`)

### 2-6. コード生成時の注意事項

1. **型安全性を最優先**
   - 明示的な型定義を行う
   - unknown や any の使用を避ける
   - 型推論が効く場合でも、複雑な型は明示的に定義する

2. **パフォーマンスを考慮**
   - 不要な再レンダリングを防ぐ
   - 適切なメモ化を行う
   - 依存配列を正確に指定する

3. **可読性とメンテナンス性**
   - 単一責任の原則に従う
   - 適切な名前付けを行う
   - コメントは必要最小限に留める（コードで意図を表現）

### 2-7. 補足事項

- このルールはプロジェクト全体で、Frontend 開発の一貫性を保つためのものです
- 例外的なケースが発生した場合は、その理由をコメントで明記してください
