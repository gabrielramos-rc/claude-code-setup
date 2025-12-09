---
name: frontend-architecture
description: >
  Frontend technical architecture including component hierarchy patterns,
  state management approach, styling methodology, and code splitting strategy.
applies_to: [architect]
load_when: >
  Deciding how the user interface will be technically structured, including
  component hierarchy patterns, state management approach, styling methodology,
  and code splitting strategy.
---

# Frontend Architecture Protocol

## When to Use This Protocol

Load this protocol when your task involves:

- Designing component architecture for new frontend
- Choosing state management approach
- Defining styling methodology
- Planning code splitting and performance
- Technical specs for complex UI components
- Integrating with UI/UX Designer specifications

**Do NOT load this protocol for:**
- Backend API design (use `api-rest.md` or `api-realtime.md`)
- Database schema (use `data-modeling.md`)
- Simple component additions following existing patterns

---

## Coordination with UI/UX Designer

**UI/UX Designer provides:** WHAT the user experiences
- User flows and wireframes
- Visual design specifications
- Component design specs (visual, not technical)
- Design tokens (colors, typography, spacing)
- Accessibility requirements

**Architect provides:** HOW to build it technically
- Component architecture patterns
- State management strategy
- Styling implementation approach
- Performance optimization patterns
- Technical component specifications

Read UI/UX specs from:
- `.claude/specs/ui-ux-specs.md`
- `.claude/specs/design-system.md`
- `.claude/specs/accessibility.md`

---

## Component Architecture Patterns

### Pattern Selection

| Pattern | Use When | Structure |
|---------|----------|-----------|
| **Atomic Design** | Design system focus, shared components | atoms → molecules → organisms → templates |
| **Feature-Sliced** | Large apps, team scaling | features → shared → entities |
| **Module-Based** | Domain-driven, clear boundaries | modules with internal structure |

### Recommended: Feature-Sliced + Atomic

```
src/
├── components/           # Shared UI components (Atomic)
│   ├── atoms/            # Button, Input, Text, Icon
│   ├── molecules/        # FormField, SearchBar, Card
│   ├── organisms/        # Header, Sidebar, DataTable
│   └── templates/        # PageLayout, AuthLayout
├── features/             # Feature-specific code
│   └── {feature}/
│       ├── components/   # Feature-specific components
│       ├── hooks/        # Feature-specific hooks
│       ├── api/          # Feature API calls
│       ├── store/        # Feature state (if needed)
│       └── index.ts      # Public API
├── hooks/                # Shared custom hooks
├── stores/               # Global state management
├── services/             # API clients, external services
├── utils/                # Utility functions
├── types/                # Shared TypeScript types
└── styles/               # Global styles, theme config
```

### Component Hierarchy Rules

1. **Atoms** - No dependencies on other components
2. **Molecules** - Compose atoms only
3. **Organisms** - Compose atoms + molecules
4. **Features** - Can use any shared component
5. **No upward imports** - Lower levels never import from higher

---

## State Management Strategy

### State Categories

| Category | Solution | Examples |
|----------|----------|----------|
| **Server State** | React Query / SWR / TanStack Query | API data, cache |
| **Global UI State** | Zustand / Redux Toolkit / Jotai | Theme, auth, modals |
| **Local UI State** | useState / useReducer | Form inputs, toggles |
| **URL State** | Router (Next.js, React Router) | Filters, pagination, tabs |
| **Form State** | React Hook Form / Formik | Complex forms |

### Decision Tree

```
Is it from an API?
    └── Yes → React Query / SWR (server state)
    └── No ↓

Does it need to persist across pages?
    └── Yes ↓
        Is it in the URL?
            └── Yes → URL State (router)
            └── No → Global Store (Zustand)
    └── No → Local State (useState)
```

### State Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                      Components                          │
└─────────────────────────────────────────────────────────┘
         │              │              │              │
         ▼              ▼              ▼              ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ React Query │ │   Zustand   │ │   Router    │ │  useState   │
│ (server)    │ │ (global UI) │ │ (URL)       │ │ (local)     │
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
         │
         ▼
┌─────────────┐
│     API     │
└─────────────┘
```

### Recommended Stack

```markdown
## State Management

| Need | Solution | Package |
|------|----------|---------|
| Server state | TanStack Query | @tanstack/react-query |
| Global UI | Zustand | zustand |
| Forms | React Hook Form | react-hook-form + zod |
| URL state | Next.js router | next/navigation |
```

---

## Styling Architecture

### Approach Selection

| Approach | Pros | Cons | Best For |
|----------|------|------|----------|
| **Tailwind CSS** | Fast, consistent, small bundle | Verbose classes | Most projects |
| **CSS Modules** | Scoped, familiar CSS | No dynamic styles | Simple projects |
| **Styled Components** | Dynamic, co-located | Runtime cost, SSR complexity | Complex theming |
| **Vanilla Extract** | Type-safe, zero runtime | Build complexity | Large apps |

**Recommendation:** Tailwind CSS + CVA for most projects.

### Design Token Implementation

From UI/UX Designer's design system to code:

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss';

const config: Config = {
  theme: {
    extend: {
      colors: {
        // From specs/design-system.md
        primary: {
          50: 'var(--color-primary-50)',
          500: 'var(--color-primary-500)',
          900: 'var(--color-primary-900)',
        },
        semantic: {
          success: 'var(--color-success)',
          error: 'var(--color-error)',
          warning: 'var(--color-warning)',
        },
      },
      spacing: {
        // From design system spacing scale
        'xs': 'var(--spacing-1)',   // 4px
        'sm': 'var(--spacing-2)',   // 8px
        'md': 'var(--spacing-4)',   // 16px
        'lg': 'var(--spacing-6)',   // 24px
        'xl': 'var(--spacing-8)',   // 32px
      },
      fontFamily: {
        sans: ['var(--font-sans)', 'system-ui', 'sans-serif'],
        mono: ['var(--font-mono)', 'monospace'],
      },
    },
  },
};
```

### Component Variants with CVA

```typescript
// components/atoms/Button/variants.ts
import { cva } from 'class-variance-authority';

export const buttonVariants = cva(
  // Base styles
  'inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2',
  {
    variants: {
      variant: {
        primary: 'bg-primary-500 text-white hover:bg-primary-600',
        secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200',
        ghost: 'hover:bg-gray-100',
        destructive: 'bg-red-500 text-white hover:bg-red-600',
      },
      size: {
        sm: 'h-8 px-3 text-sm',
        md: 'h-10 px-4 text-sm',
        lg: 'h-12 px-6 text-base',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);
```

---

## Component Patterns

### Compound Components

Use for complex components with multiple related parts:

```typescript
// Pattern specification
<Card>
  <Card.Header>
    <Card.Title>Title</Card.Title>
    <Card.Description>Description</Card.Description>
  </Card.Header>
  <Card.Content>Content here</Card.Content>
  <Card.Footer>
    <Button>Action</Button>
  </Card.Footer>
</Card>
```

### Headless / Render Props

Use for logic reuse with flexible rendering:

```typescript
// Pattern specification
<Dropdown>
  {({ isOpen, toggle, items }) => (
    <div>
      <button onClick={toggle}>{isOpen ? 'Close' : 'Open'}</button>
      {isOpen && <ul>{items.map(...)}</ul>}
    </div>
  )}
</Dropdown>
```

### Controlled vs Uncontrolled

| Type | Use When | Example |
|------|----------|---------|
| **Controlled** | Need to react to every change | Form with validation |
| **Uncontrolled** | Only need final value | Simple search input |

**Recommendation:** Controlled with React Hook Form for forms.

---

## Performance Patterns

### Code Splitting Strategy

```typescript
// Route-based splitting (automatic with Next.js)
// pages/dashboard.tsx → separate chunk

// Component-based splitting
const DataTable = lazy(() => import('@/components/organisms/DataTable'));
const Chart = lazy(() => import('@/components/organisms/Chart'));

// Feature-based splitting
const AdminFeature = lazy(() => import('@/features/admin'));
```

### Rendering Optimization

| Technique | Use When |
|-----------|----------|
| `React.memo` | Pure component re-renders with same props |
| `useMemo` | Expensive calculation on every render |
| `useCallback` | Callback passed to memoized child |
| Virtual lists | Lists with 100+ items |

### Image Optimization

```typescript
// Next.js Image (automatic optimization)
import Image from 'next/image';

<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority        // LCP image
  placeholder="blur"
/>

// Lazy load below-fold images
<Image
  src="/feature.jpg"
  loading="lazy"  // default
/>
```

### Bundle Size Management

```markdown
## Performance Budgets

| Metric | Target | Max |
|--------|--------|-----|
| Initial JS | < 100KB | 150KB |
| Per-route JS | < 50KB | 75KB |
| Total CSS | < 50KB | 75KB |
| LCP | < 2.5s | 4s |
| FID | < 100ms | 300ms |
| CLS | < 0.1 | 0.25 |

## Bundle Analysis
- Use: `@next/bundle-analyzer` or `vite-bundle-visualizer`
- Run: `ANALYZE=true npm run build`
```

---

## API Integration

### Data Fetching Pattern

```typescript
// hooks/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export const useUsers = (filters?: UserFilters) => {
  return useQuery({
    queryKey: ['users', filters],
    queryFn: () => api.users.list(filters),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};

export const useCreateUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: api.users.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
};
```

### Error Boundaries

```typescript
// Error boundary hierarchy
<RootErrorBoundary>        {/* Catches crashes, shows fallback */}
  <Layout>
    <FeatureErrorBoundary>  {/* Isolates feature failures */}
      <Feature />
    </FeatureErrorBoundary>
  </Layout>
</RootErrorBoundary>
```

### Loading States

| State | Pattern | Example |
|-------|---------|---------|
| Initial load | Skeleton | Content placeholder shapes |
| Action pending | Spinner/disabled | Button with spinner |
| Background refresh | Subtle indicator | Faded content + corner spinner |
| Optimistic | Immediate update | Like button instant feedback |

---

## Technical Component Specs

For complex components from UI/UX specs, provide technical details:

```markdown
## Component: DataTable

### From UI/UX
See `specs/ui-ux-specs.md#data-table`

### Technical Specification

**Pattern:** Compound component + headless logic
**Library:** TanStack Table (headless)

**Props Interface:**
```typescript
interface DataTableProps<T> {
  data: T[];
  columns: ColumnDef<T>[];
  pagination?: { pageSize: number; pageSizeOptions: number[] };
  sorting?: { defaultSort?: SortingState };
  filtering?: { globalFilter?: boolean; columnFilters?: boolean };
  selection?: { mode: 'single' | 'multiple' };
  onRowClick?: (row: T) => void;
}
```

**Internal State:**
- Sort: `{ column: string, direction: 'asc' | 'desc' }`
- Filters: `Record<string, FilterValue>`
- Selection: `Set<string>`
- Pagination: `{ pageIndex: number, pageSize: number }`

**Performance:**
- Virtual scrolling for > 100 rows (react-virtual)
- Debounced filtering (300ms)
- Memoized row rendering
```

---

## Design Checklist

Before handing off to Engineer:

- [ ] Component architecture pattern chosen
- [ ] Directory structure defined
- [ ] State management strategy documented
- [ ] Styling approach selected (Tailwind + CVA recommended)
- [ ] Design tokens mapped to code
- [ ] Component patterns defined (compound, headless)
- [ ] Code splitting strategy planned
- [ ] Performance budgets set
- [ ] Complex components have technical specs
- [ ] API integration patterns defined

---

## Output

Write to `.claude/specs/frontend-architecture.md`:

```markdown
# Frontend Architecture

## Component Architecture
**Pattern:** Feature-Sliced + Atomic Design
**Directory Structure:** {tree}

## State Management
| Category | Solution |
|----------|----------|
| Server | TanStack Query |
| Global UI | Zustand |
| Forms | React Hook Form |
| URL | Next.js Router |

## Styling
**Approach:** Tailwind CSS + CVA
**Design Tokens:** See tailwind.config.ts

## Performance
**Code Splitting:** Route-based + lazy components
**Budgets:** Initial JS < 100KB, LCP < 2.5s

## Component Specifications
{Technical specs for complex components}
```

---

## Related

- `.claude/specs/ui-ux-specs.md` - UI/UX design specifications
- `.claude/specs/design-system.md` - Design tokens
- `.claude/patterns/performance.md` - Performance optimization

---

*Protocol created: 2025-12-08*
*Version: 1.0*
