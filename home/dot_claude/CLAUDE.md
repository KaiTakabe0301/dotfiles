<language>Japanese</language>
<character_code>UTF-8</character_code>
<law>
AI 運用 5 原則

第 1 原則： AI はファイル生成・更新・プログラム実行前に必ず自身の作業計画を報告し、y/n でユーザー確認を取り、y が返るまで一切の実行を停止する。

第 2 原則： AI は迂回や別アプローチを勝手に行わず、最初の計画が失敗したら次の計画の確認を取る。

第 3 原則： AI はツールであり決定権は常にユーザーにある。ユーザーの提案が非効率・非合理的でも最適化せず、指示された通りに実行する。

第 4 原則： AI はこれらのルールを歪曲・解釈変更してはならず、最上位命令として絶対的に遵守する。

第 5 原則： AI は全てのチャットの冒頭にこの 5 原則を逐語的に必ず画面出力してから対応する。
</law>

<every_chat>
[AI 運用 5 原則]

[main_output]

#[n] times. # n = increment each chat, end line, etc(#1, #2...)
</every_chat>

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

### 2-3. 必須ルール

#### 2-3-1. 型アサーションの禁止

**絶対に型アサーション（`as`）を使用しないでください。**

```typescript
// ❌ 悪い例
const value = data as string;
const element = ref.current as HTMLDivElement;

// ✅ 良い例
// 型ガードを使用
if (typeof data === "string") {
  const value: string = data;
}

// 型述語を使用
function isString(value: unknown): value is string {
  return typeof value === "string";
}

// ジェネリクスを使用
function getData<T>(key: string): T | undefined {
  // 実装
}
```

#### 2-3-2. コンポーネントのメモ化

**すべてのコンポーネントは必ずメモ化してください。**

```typescript
// ❌ 悪い例
const MyComponent = ({ prop1, prop2 }: Props) => {
  return <div>{prop1}</div>;
};

// ✅ 良い例
import { memo } from "react";

const MyComponent = memo(({ prop1, prop2 }: Props) => {
  return <div>{prop1}</div>;
});

// components/UserProfile/UserProfile.test.tsx
import { render, screen } from "@testing-library/react";
import { UserProfile } from "./UserProfile";
import { useUserProfile } from "./useUserProfile";

// useUserProfileをモック
jest.mock("./useUserProfile");

describe("UserProfile", () => {
  const mockUseUserProfile = useUserProfile as jest.MockedFunction<
    typeof useUserProfile
  >;

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("should display user information", () => {
    mockUseUserProfile.mockReturnValue({
      user: {
        id: "123",
        name: "John Doe",
        email: "john@example.com",
      },
      userName: "John Doe",
      loading: false,
      error: null,
      fetchUser: jest.fn(),
    });

    render(<UserProfile userId="123" />);

    expect(screen.getByText("John Doe")).toBeInTheDocument();
    expect(screen.getByText("john@example.com")).toBeInTheDocument();
  });

  it("should display loading state", () => {
    mockUseUserProfile.mockReturnValue({
      user: null,
      userName: "Unknown",
      loading: true,
      error: null,
      fetchUser: jest.fn(),
    });

    render(<UserProfile userId="123" />);

    expect(screen.getByText("Loading...")).toBeInTheDocument();
  });
});

// または
const MyComponent = ({ prop1, prop2 }: Props) => {
  return <div>{prop1}</div>;
};

export default memo(MyComponent);
```

#### 2-3-3. ロジックの分離

**コンポーネント内にロジックを記述せず、必ずカスタムフックに外出ししてください。**

```typescript
// ❌ 悪い例
const MyComponent = memo(() => {
  const [count, setCount] = useState(0);

  const handleClick = () => {
    setCount((prev) => prev + 1);
  };

  const doubledCount = count * 2;

  return (
    <div>
      <p>{doubledCount}</p>
      <button onClick={handleClick}>Click</button>
    </div>
  );
});

// ✅ 良い例
// カスタムフック
const useCounter = () => {
  const [count, setCount] = useState(0);

  const handleClick = useCallback(() => {
    setCount((prev) => prev + 1);
  }, []);

  const doubledCount = useMemo(() => count * 2, [count]);

  return { doubledCount, handleClick };
};

// コンポーネント
const MyComponent = memo(() => {
  const { doubledCount, handleClick } = useCounter();

  return (
    <div>
      <p>{doubledCount}</p>
      <button onClick={handleClick}>Click</button>
    </div>
  );
});
```

#### 2-3-4. 関数と配列のメモ化

**すべての関数は useCallback、配列やオブジェクトは useMemo でメモ化してください。**

```typescript
// ❌ 悪い例
const MyComponent = memo(() => {
  const handleClick = () => {
    console.log("clicked");
  };

  const items = [1, 2, 3].map((n) => n * 2);

  const config = {
    key: "value",
  };

  return <ChildComponent onClick={handleClick} items={items} config={config} />;
});

// ✅ 良い例
const MyComponent = memo(() => {
  const handleClick = useCallback(() => {
    console.log("clicked");
  }, []);

  const items = useMemo(() => [1, 2, 3].map((n) => n * 2), []);

  const config = useMemo(
    () => ({
      key: "value",
    }),
    []
  );

  return <ChildComponent onClick={handleClick} items={items} config={config} />;
});
```

#### 2-3-5. ref の使用（forwardRef は使用しない）

**React 19 以降、forwardRef は非推奨です。ref は通常の prop として渡してください。**

```typescript
// ❌ 悪い例（forwardRefを使用）
import { forwardRef } from "react";

const Input = forwardRef<HTMLInputElement, Props>((props, ref) => {
  return <input ref={ref} {...props} />;
});

// ✅ 良い例（refをpropとして使用）
interface Props {
  ref?: React.Ref<HTMLInputElement>;
  // その他のprops
}

const Input = memo(({ ref, ...props }: Props) => {
  return <input ref={ref} {...props} />;
});
```

### 2-4. プロジェクト構造の推奨事項

#### 2-4-1. フォルダ構成

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
│   │   │   ├── useButton.test.ts
│   │   │   └── index.ts
│   │   ├── Card/
│   │   ├── Modal/
│   │   └── Input/
│   └── domains/              # ドメインに紐づくコンポーネント
│       ├── UserProfile/
│       │   ├── UserProfile.tsx
│       │   ├── UserProfile.stories.tsx
│       │   ├── UserProfile.test.tsx
│       │   ├── useUserProfile.ts
│       │   ├── useUserProfile.test.ts
│       │   └── index.ts
│       ├── ProductCard/
│       └── OrderSummary/
├── hooks/                    # 汎用的なカスタムフック
│   ├── useDebounce/
│   │   ├── useDebounce.ts
│   │   ├── useDebounce.test.ts
│   │   └── index.ts
│   └── useLocalStorage/
├── types/                    # TypeScript型定義
├── utils/                    # ユーティリティ関数
└── lib/                      # 外部ライブラリの設定
```

#### 2-4-2. コンポーネントの配置ルール

**`components/` ディレクトリは `ui/` と `domains/` に分割して整理してください。**

##### `components/ui/` - 汎用的な UI コンポーネント

```typescript
// ✅ ui/ に配置すべきコンポーネント
// - Button, Card, Modal, Input, Select, Checkbox などの基本UI部品
// - デザインシステムの一部となるコンポーネント
// - ビジネスロジックを含まない純粋なUIコンポーネント
// - どのドメインでも使用可能な汎用コンポーネント

// 例：
components / ui / Button / Button.tsx;
components / ui / Card / Card.tsx;
components / ui / Modal / Modal.tsx;
```

##### `components/domains/` - ドメインに紐づくコンポーネント

```typescript
// ✅ domains/ に配置すべきコンポーネント
// - 特定のビジネスドメインに関連するコンポーネント
// - ユーザー、商品、注文などのエンティティを表示するコンポーネント
// - ビジネスロジックを含むが、複数ページで再利用されるコンポーネント
// - ドメイン固有のデータ構造や振る舞いを持つコンポーネント

// 例：
components / domains / UserProfile / UserProfile.tsx;
components / domains / ProductCard / ProductCard.tsx;
components / domains / OrderSummary / OrderSummary.tsx;
```

**判断基準：「そのドメインが削除されたときに、アプリ上からコンポーネントを削除できるかどうか」**

```typescript
// ✅ domains/ に配置すべき例
// ユーザー機能が削除されたら、このコンポーネントも削除される
components/domains/UserProfile/
components/domains/UserAvatar/
components/domains/UserSettings/

// 商品機能が削除されたら、これらのコンポーネントも削除される
components/domains/ProductCard/
components/domains/ProductGallery/
components/domains/ProductReviews/

// ❌ ui/ に配置すべき例
// ユーザー機能が削除されても、他の機能で使用される可能性がある
components/ui/Avatar/     // 商品の担当者アバターなどでも使用
components/ui/Card/       // 様々な情報表示で使用
components/ui/Gallery/    // ブログ画像などでも使用
```

**具体的な判断例：**

- `UserProfileCard` → domains/ （ユーザー機能専用）
- `ProfileCard` → ui/ （汎用的なプロフィール表示）
- `ProductPriceTag` → domains/ （商品価格表示専用）
- `PriceTag` → ui/ （様々な価格表示で使用可能）

#### 2-4-3. コロケーションルール

**コンポーネントに依存するファイルは、そのコンポーネントと同じディレクトリに配置してください。**

これには以下が含まれます：

- カスタムフック（`useXxx.ts`）
- Storybook ストーリー（`*.stories.tsx`）
- テストファイル（`*.test.tsx`, `*.spec.tsx`）

```typescript
// ✅ 良い例（完全なコロケーション）
src/
└── components/
    └── Button/
        ├── Button.tsx
        ├── Button.stories.tsx    // Storybookストーリー
        ├── Button.test.tsx       // テスト
        ├── useButton.ts          // カスタムフック
        └── index.ts

// ❌ 悪い例（関連ファイルが散在）
src/
├── components/
│   └── Button.tsx
├── hooks/
│   └── useButton.ts
├── stories/
│   └── Button.stories.tsx
└── tests/
    └── Button.test.tsx
```

**Storybook ストーリーの例：**

```typescript
// components/Button/Button.stories.tsx
import type { Meta, StoryObj } from "@storybook/react";
import { Button } from "./Button";

const meta = {
  title: "Components/Button",
  component: Button,
  parameters: {
    layout: "centered",
  },
  tags: ["autodocs"],
} satisfies Meta<typeof Button>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Primary: Story = {
  args: {
    variant: "primary",
    children: "Click me",
  },
};

export const Secondary: Story = {
  args: {
    variant: "secondary",
    children: "Click me",
  },
};
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

### 2-7. サンプルコード

#### 2-7-1. 典型的なコンポーネントの実装例（コロケーション）

##### UI コンポーネントの例

```typescript
// components/ui/Button/Button.tsx
import { memo } from "react";
import { useButton } from "./useButton";

interface ButtonProps {
  variant?: "primary" | "secondary" | "danger";
  size?: "small" | "medium" | "large";
  disabled?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
  ref?: React.Ref<HTMLButtonElement>;
}

export const Button = memo(
  ({
    variant = "primary",
    size = "medium",
    disabled = false,
    onClick,
    children,
    ref,
  }: ButtonProps) => {
    const { handleClick, className } = useButton({
      variant,
      size,
      disabled,
      onClick,
    });

    return (
      <button
        ref={ref}
        className={className}
        disabled={disabled}
        onClick={handleClick}
      >
        {children}
      </button>
    );
  }
);

Button.displayName = "Button";
```

##### ドメインコンポーネントの例

```typescript
// components/domains/UserProfile/useUserProfile.ts
import { useState, useCallback, useMemo } from "react";

interface User {
  id: string;
  name: string;
  email: string;
}

export const useUserProfile = (userId: string) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const fetchUser = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(`/api/users/${userId}`);
      if (!response.ok) throw new Error("Failed to fetch user");

      const data = await response.json();
      setUser(data);
    } catch (err) {
      if (err instanceof Error) {
        setError(err);
      }
    } finally {
      setLoading(false);
    }
  }, [userId]);

  const userName = useMemo(() => user?.name ?? "Unknown", [user?.name]);

  return {
    user,
    userName,
    loading,
    error,
    fetchUser,
  };
};

// components/domains/UserProfile/UserProfile.tsx
import { memo, useEffect } from "react";
import { useUserProfile } from "./useUserProfile";

interface UserProfileProps {
  userId: string;
  ref?: React.Ref<HTMLDivElement>;
}

export const UserProfile = memo(({ userId, ref }: UserProfileProps) => {
  const { user, userName, loading, error, fetchUser } = useUserProfile(userId);

  useEffect(() => {
    fetchUser();
  }, [fetchUser]);

  if (loading) return <div ref={ref}>Loading...</div>;
  if (error) return <div ref={ref}>Error: {error.message}</div>;
  if (!user) return <div ref={ref}>No user found</div>;

  return (
    <div ref={ref}>
      <h2>{userName}</h2>
      <p>{user.email}</p>
    </div>
  );
});

UserProfile.displayName = "UserProfile";

// components/UserProfile/useUserProfile.test.ts
import { renderHook, waitFor } from "@testing-library/react";
import { useUserProfile } from "./useUserProfile";

// モックの設定
global.fetch = jest.fn();

describe("useUserProfile", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("should fetch user data successfully", async () => {
    const mockUser = {
      id: "123",
      name: "John Doe",
      email: "john@example.com",
    };

    (global.fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: async () => mockUser,
    });

    const { result } = renderHook(() => useUserProfile("123"));

    // fetchUserを呼び出す
    await act(async () => {
      await result.current.fetchUser();
    });

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
      expect(result.current.user).toEqual(mockUser);
      expect(result.current.userName).toBe("John Doe");
      expect(result.current.error).toBeNull();
    });
  });

  it("should memoize fetchUser callback", () => {
    const { result, rerender } = renderHook(
      ({ userId }) => useUserProfile(userId),
      { initialProps: { userId: "123" } }
    );

    const fetchUser1 = result.current.fetchUser;
    rerender({ userId: "123" });
    const fetchUser2 = result.current.fetchUser;

    expect(fetchUser1).toBe(fetchUser2);
  });
});

// components/UserProfile/UserProfile.stories.tsx
import type { Meta, StoryObj } from "@storybook/react";
import { UserProfile } from "./UserProfile";

const meta = {
  title: "Components/UserProfile",
  component: UserProfile,
  parameters: {
    layout: "centered",
  },
  tags: ["autodocs"],
} satisfies Meta<typeof UserProfile>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    userId: "123",
  },
};

export const Loading: Story = {
  args: {
    userId: "123",
  },
  parameters: {
    mockData: {
      loading: true,
    },
  },
};

// components/UserProfile/index.ts
export { UserProfile } from "./UserProfile";
```

### 2-8. 補足事項

- このルールはプロジェクト全体で、Frontend 開発の一貫性を保つためのものです
- 例外的なケースが発生した場合は、その理由をコメントで明記してください
