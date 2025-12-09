---
name: accessibility
description: >
  Web accessibility patterns for WCAG compliance including semantic HTML,
  ARIA attributes, keyboard navigation, and screen reader support.
applies_to: [engineer, ui-ux-designer]
load_when: >
  Implementing WCAG compliance, ensuring keyboard accessibility, adding
  screen reader support, or auditing accessibility of web applications.
---

# Accessibility Protocol

## When to Use This Protocol

Load this protocol when:

- Building accessible UI components
- Ensuring WCAG 2.1 compliance
- Adding keyboard navigation
- Implementing screen reader support
- Auditing accessibility issues
- Creating accessible forms

**Do NOT load this protocol for:**
- Visual design decisions (UI/UX Designer)
- Backend API accessibility
- Mobile native accessibility

---

## WCAG Principles (POUR)

| Principle | Requirement |
|-----------|-------------|
| **Perceivable** | Content can be perceived by all users |
| **Operable** | Interface can be operated by all users |
| **Understandable** | Content and operation are understandable |
| **Robust** | Content works with assistive technologies |

---

## Semantic HTML

### Document Structure

```html
<!-- Use semantic elements -->
<header>
  <nav aria-label="Main navigation">
    <ul>
      <li><a href="/">Home</a></li>
      <li><a href="/products">Products</a></li>
    </ul>
  </nav>
</header>

<main>
  <article>
    <h1>Page Title</h1>
    <section>
      <h2>Section Title</h2>
      <p>Content...</p>
    </section>
  </article>
</main>

<aside aria-label="Related content">
  <!-- Sidebar content -->
</aside>

<footer>
  <!-- Footer content -->
</footer>
```

### Heading Hierarchy

```html
<!-- GOOD: Proper hierarchy -->
<h1>Main Title</h1>
  <h2>Section 1</h2>
    <h3>Subsection 1.1</h3>
    <h3>Subsection 1.2</h3>
  <h2>Section 2</h2>

<!-- BAD: Skipping levels -->
<h1>Main Title</h1>
  <h3>Subsection</h3>  <!-- Skipped h2 -->
```

---

## ARIA Attributes

### Landmarks

```html
<nav aria-label="Primary">...</nav>
<nav aria-label="Footer">...</nav>

<main aria-labelledby="page-title">
  <h1 id="page-title">Dashboard</h1>
</main>

<aside aria-label="Filters">...</aside>

<section aria-labelledby="section-heading">
  <h2 id="section-heading">Recent Orders</h2>
</section>
```

### Live Regions

```tsx
// Announce dynamic content changes
<div aria-live="polite" aria-atomic="true">
  {message && <p>{message}</p>}
</div>

// For urgent announcements
<div role="alert" aria-live="assertive">
  {error && <p>{error}</p>}
</div>

// Status messages
<div role="status" aria-live="polite">
  {isLoading && <p>Loading...</p>}
  {itemCount && <p>{itemCount} items found</p>}
</div>
```

### States and Properties

```tsx
// Expanded/collapsed
<button aria-expanded={isOpen} aria-controls="menu">
  Menu
</button>
<ul id="menu" hidden={!isOpen}>...</ul>

// Selected
<li role="option" aria-selected={isSelected}>Option</li>

// Disabled
<button aria-disabled={isDisabled} disabled={isDisabled}>
  Submit
</button>

// Loading
<button aria-busy={isLoading} disabled={isLoading}>
  {isLoading ? 'Saving...' : 'Save'}
</button>

// Invalid
<input
  aria-invalid={hasError}
  aria-describedby={hasError ? 'error-msg' : undefined}
/>
{hasError && <span id="error-msg">Invalid email</span>}
```

---

## Keyboard Navigation

### Focus Management

```tsx
// src/hooks/useFocusTrap.ts
import { useEffect, useRef } from 'react';

export function useFocusTrap<T extends HTMLElement>() {
  const containerRef = useRef<T>(null);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const focusableElements = container.querySelectorAll<HTMLElement>(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );

    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];

    function handleKeyDown(e: KeyboardEvent) {
      if (e.key !== 'Tab') return;

      if (e.shiftKey && document.activeElement === firstElement) {
        e.preventDefault();
        lastElement?.focus();
      } else if (!e.shiftKey && document.activeElement === lastElement) {
        e.preventDefault();
        firstElement?.focus();
      }
    }

    container.addEventListener('keydown', handleKeyDown);
    firstElement?.focus();

    return () => container.removeEventListener('keydown', handleKeyDown);
  }, []);

  return containerRef;
}
```

### Skip Links

```tsx
// At the very top of the page
<a href="#main-content" className="skip-link">
  Skip to main content
</a>

<main id="main-content" tabIndex={-1}>
  {/* Main content */}
</main>

// CSS
.skip-link {
  position: absolute;
  left: -9999px;
  z-index: 999;
  padding: 1rem;
  background: white;
}

.skip-link:focus {
  left: 50%;
  transform: translateX(-50%);
}
```

### Keyboard Interactions

```tsx
// Arrow key navigation for lists
function handleKeyDown(e: KeyboardEvent, currentIndex: number) {
  switch (e.key) {
    case 'ArrowDown':
      e.preventDefault();
      focusItem(currentIndex + 1);
      break;
    case 'ArrowUp':
      e.preventDefault();
      focusItem(currentIndex - 1);
      break;
    case 'Home':
      e.preventDefault();
      focusItem(0);
      break;
    case 'End':
      e.preventDefault();
      focusItem(items.length - 1);
      break;
    case 'Enter':
    case ' ':
      e.preventDefault();
      selectItem(currentIndex);
      break;
    case 'Escape':
      closeMenu();
      break;
  }
}
```

---

## Accessible Forms

### Labels and Descriptions

```tsx
// Always associate labels
<label htmlFor="email">Email address</label>
<input id="email" type="email" />

// With description
<label htmlFor="password">Password</label>
<input
  id="password"
  type="password"
  aria-describedby="password-hint"
/>
<p id="password-hint">Must be at least 8 characters</p>

// Required fields
<label htmlFor="name">
  Name <span aria-hidden="true">*</span>
  <span className="sr-only">(required)</span>
</label>
<input id="name" required aria-required="true" />
```

### Error Handling

```tsx
function FormField({ label, error, ...props }) {
  const id = useId();
  const errorId = `${id}-error`;

  return (
    <div>
      <label htmlFor={id}>{label}</label>
      <input
        id={id}
        aria-invalid={!!error}
        aria-describedby={error ? errorId : undefined}
        {...props}
      />
      {error && (
        <p id={errorId} role="alert" className="error">
          {error}
        </p>
      )}
    </div>
  );
}
```

### Form Validation Summary

```tsx
function ValidationSummary({ errors }) {
  if (errors.length === 0) return null;

  return (
    <div role="alert" aria-labelledby="error-summary-title">
      <h2 id="error-summary-title">
        There are {errors.length} errors in this form
      </h2>
      <ul>
        {errors.map((error, i) => (
          <li key={i}>
            <a href={`#${error.fieldId}`}>{error.message}</a>
          </li>
        ))}
      </ul>
    </div>
  );
}
```

---

## Images and Media

### Alternative Text

```tsx
// Informative images
<img src="chart.png" alt="Sales increased 25% in Q4 2024" />

// Decorative images
<img src="decoration.svg" alt="" role="presentation" />

// Complex images
<figure>
  <img src="diagram.png" alt="System architecture diagram" />
  <figcaption>
    Figure 1: The system consists of three microservices...
  </figcaption>
</figure>
```

### Video and Audio

```tsx
<video controls>
  <source src="video.mp4" type="video/mp4" />
  <track kind="captions" src="captions.vtt" srclang="en" label="English" />
  <track kind="descriptions" src="descriptions.vtt" srclang="en" label="Audio descriptions" />
</video>
```

---

## Color and Contrast

### Minimum Contrast Ratios

| Element | Normal Text | Large Text |
|---------|-------------|------------|
| **AA** | 4.5:1 | 3:1 |
| **AAA** | 7:1 | 4.5:1 |

### Don't Rely on Color Alone

```tsx
// BAD: Color only
<span style={{ color: 'red' }}>Error</span>
<span style={{ color: 'green' }}>Success</span>

// GOOD: Color + icon/text
<span className="error">
  <ErrorIcon aria-hidden="true" />
  Error: Invalid email
</span>

<span className="success">
  <CheckIcon aria-hidden="true" />
  Success: Saved
</span>
```

---

## Screen Reader Only Content

```css
/* Visually hidden but accessible */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

```tsx
// Usage
<button>
  <TrashIcon aria-hidden="true" />
  <span className="sr-only">Delete item</span>
</button>

<a href="/cart">
  <CartIcon aria-hidden="true" />
  <span className="sr-only">Shopping cart, 3 items</span>
</a>
```

---

## Common Components

### Modal Dialog

```tsx
function Modal({ isOpen, onClose, title, children }) {
  const dialogRef = useFocusTrap<HTMLDivElement>();

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    }
    return () => {
      document.body.style.overflow = '';
    };
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
      ref={dialogRef}
    >
      <h2 id="modal-title">{title}</h2>
      {children}
      <button onClick={onClose}>Close</button>
    </div>
  );
}
```

### Tabs

```tsx
function Tabs({ tabs }) {
  const [activeIndex, setActiveIndex] = useState(0);

  return (
    <div>
      <div role="tablist" aria-label="Content tabs">
        {tabs.map((tab, i) => (
          <button
            key={i}
            role="tab"
            aria-selected={i === activeIndex}
            aria-controls={`panel-${i}`}
            id={`tab-${i}`}
            tabIndex={i === activeIndex ? 0 : -1}
            onClick={() => setActiveIndex(i)}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {tabs.map((tab, i) => (
        <div
          key={i}
          role="tabpanel"
          id={`panel-${i}`}
          aria-labelledby={`tab-${i}`}
          hidden={i !== activeIndex}
        >
          {tab.content}
        </div>
      ))}
    </div>
  );
}
```

---

## Testing Tools

```bash
# Automated testing
npm install -D axe-core @axe-core/playwright

# Playwright a11y testing
npx playwright test --grep a11y
```

```typescript
// tests/a11y.spec.ts
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('homepage has no a11y violations', async ({ page }) => {
  await page.goto('/');

  const results = await new AxeBuilder({ page }).analyze();

  expect(results.violations).toEqual([]);
});
```

---

## Checklist

Before completing accessibility implementation:

- [ ] Semantic HTML used throughout
- [ ] All images have alt text
- [ ] Color contrast meets WCAG AA (4.5:1)
- [ ] All interactive elements keyboard accessible
- [ ] Focus visible and trapped in modals
- [ ] Form inputs have labels
- [ ] Error messages are announced
- [ ] Skip link provided
- [ ] No content hidden from screen readers unintentionally
- [ ] Tested with screen reader

---

## Related

- `frontend-architecture.md` - Component patterns
- `testing-e2e.md` - Accessibility testing

---

*Protocol created: 2025-12-08*
*Version: 1.0*
