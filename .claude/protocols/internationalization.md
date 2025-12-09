---
name: internationalization
description: >
  Internationalization (i18n) and localization (l10n) patterns for
  multi-language support, date/number formatting, and RTL layouts.
applies_to: [engineer]
load_when: >
  Implementing multi-language support, handling locale-specific formatting
  for dates, numbers, and currencies, or supporting RTL layouts.
---

# Internationalization Protocol

## When to Use This Protocol

Load this protocol when:

- Adding multi-language support
- Formatting dates, numbers, currencies by locale
- Handling pluralization
- Supporting RTL layouts
- Managing translation files

**Do NOT load this protocol for:**
- Content translation (human translators)
- SEO localization (different concern)
- Timezone handling alone

---

## Key Concepts

| Term | Meaning |
|------|---------|
| **i18n** | Internationalization - making app translatable |
| **l10n** | Localization - adapting for specific locale |
| **Locale** | Language + region (e.g., `en-US`, `fr-CA`) |
| **RTL** | Right-to-left languages (Arabic, Hebrew) |

---

## React i18n with react-i18next

### Setup

```typescript
// src/i18n/index.ts
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';
import Backend from 'i18next-http-backend';

i18n
  .use(Backend)
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    fallbackLng: 'en',
    supportedLngs: ['en', 'es', 'fr', 'de', 'ja'],
    debug: process.env.NODE_ENV === 'development',

    interpolation: {
      escapeValue: false,
    },

    backend: {
      loadPath: '/locales/{{lng}}/{{ns}}.json',
    },

    detection: {
      order: ['querystring', 'cookie', 'localStorage', 'navigator'],
      caches: ['cookie', 'localStorage'],
    },
  });

export default i18n;
```

### Translation Files

```json
// public/locales/en/common.json
{
  "welcome": "Welcome, {{name}}!",
  "items": {
    "one": "{{count}} item",
    "other": "{{count}} items"
  },
  "nav": {
    "home": "Home",
    "products": "Products",
    "cart": "Cart"
  },
  "errors": {
    "required": "This field is required",
    "invalid_email": "Invalid email address"
  }
}

// public/locales/es/common.json
{
  "welcome": "¡Bienvenido, {{name}}!",
  "items": {
    "one": "{{count}} artículo",
    "other": "{{count}} artículos"
  },
  "nav": {
    "home": "Inicio",
    "products": "Productos",
    "cart": "Carrito"
  }
}
```

### Usage in Components

```tsx
import { useTranslation } from 'react-i18next';

function Header() {
  const { t, i18n } = useTranslation();

  return (
    <header>
      <nav>
        <a href="/">{t('nav.home')}</a>
        <a href="/products">{t('nav.products')}</a>
        <a href="/cart">{t('nav.cart')}</a>
      </nav>

      <select
        value={i18n.language}
        onChange={(e) => i18n.changeLanguage(e.target.value)}
      >
        <option value="en">English</option>
        <option value="es">Español</option>
        <option value="fr">Français</option>
      </select>
    </header>
  );
}

function Welcome({ user }) {
  const { t } = useTranslation();

  return (
    <div>
      <h1>{t('welcome', { name: user.name })}</h1>
      <p>{t('items', { count: user.cartItems })}</p>
    </div>
  );
}
```

---

## Number and Currency Formatting

### Intl.NumberFormat

```typescript
// src/i18n/formatters.ts
export function formatNumber(value: number, locale: string): string {
  return new Intl.NumberFormat(locale).format(value);
}

export function formatCurrency(
  value: number,
  locale: string,
  currency: string
): string {
  return new Intl.NumberFormat(locale, {
    style: 'currency',
    currency,
  }).format(value);
}

export function formatPercent(value: number, locale: string): string {
  return new Intl.NumberFormat(locale, {
    style: 'percent',
    minimumFractionDigits: 1,
  }).format(value);
}

// Usage
formatNumber(1234567.89, 'en-US');  // "1,234,567.89"
formatNumber(1234567.89, 'de-DE');  // "1.234.567,89"

formatCurrency(99.99, 'en-US', 'USD');  // "$99.99"
formatCurrency(99.99, 'de-DE', 'EUR');  // "99,99 €"
formatCurrency(99.99, 'ja-JP', 'JPY');  // "￥100"
```

### React Hook

```tsx
// src/hooks/useFormatters.ts
import { useTranslation } from 'react-i18next';

export function useFormatters() {
  const { i18n } = useTranslation();
  const locale = i18n.language;

  return {
    formatNumber: (value: number) =>
      new Intl.NumberFormat(locale).format(value),

    formatCurrency: (value: number, currency = 'USD') =>
      new Intl.NumberFormat(locale, { style: 'currency', currency }).format(value),

    formatDate: (date: Date, options?: Intl.DateTimeFormatOptions) =>
      new Intl.DateTimeFormat(locale, options).format(date),

    formatRelativeTime: (value: number, unit: Intl.RelativeTimeFormatUnit) =>
      new Intl.RelativeTimeFormat(locale, { numeric: 'auto' }).format(value, unit),
  };
}
```

---

## Date Formatting

### Intl.DateTimeFormat

```typescript
// src/i18n/date-formatters.ts
export function formatDate(
  date: Date,
  locale: string,
  style: 'full' | 'long' | 'medium' | 'short' = 'medium'
): string {
  return new Intl.DateTimeFormat(locale, { dateStyle: style }).format(date);
}

export function formatDateTime(
  date: Date,
  locale: string,
  dateStyle: 'full' | 'long' | 'medium' | 'short' = 'medium',
  timeStyle: 'full' | 'long' | 'medium' | 'short' = 'short'
): string {
  return new Intl.DateTimeFormat(locale, { dateStyle, timeStyle }).format(date);
}

// Usage
const date = new Date('2024-12-25');

formatDate(date, 'en-US');      // "Dec 25, 2024"
formatDate(date, 'en-GB');      // "25 Dec 2024"
formatDate(date, 'de-DE');      // "25.12.2024"
formatDate(date, 'ja-JP');      // "2024/12/25"

formatDateTime(date, 'en-US');  // "Dec 25, 2024, 12:00 AM"
```

### Relative Time

```typescript
export function formatRelativeTime(
  date: Date,
  locale: string
): string {
  const rtf = new Intl.RelativeTimeFormat(locale, { numeric: 'auto' });
  const now = new Date();
  const diffInSeconds = Math.floor((date.getTime() - now.getTime()) / 1000);

  const units: [number, Intl.RelativeTimeFormatUnit][] = [
    [60, 'second'],
    [60, 'minute'],
    [24, 'hour'],
    [7, 'day'],
    [4, 'week'],
    [12, 'month'],
    [Infinity, 'year'],
  ];

  let value = diffInSeconds;
  for (const [divisor, unit] of units) {
    if (Math.abs(value) < divisor) {
      return rtf.format(Math.round(value), unit);
    }
    value /= divisor;
  }

  return rtf.format(Math.round(value), 'year');
}

// Usage
formatRelativeTime(yesterday, 'en-US');  // "yesterday"
formatRelativeTime(nextWeek, 'en-US');   // "in 7 days"
formatRelativeTime(lastMonth, 'de-DE');  // "letzten Monat"
```

---

## Pluralization

### ICU Message Format

```json
// locales/en/common.json
{
  "items": "{count, plural, =0 {No items} one {# item} other {# items}}",
  "messages": "{count, plural, =0 {No new messages} one {# new message} other {# new messages}}"
}
```

### With react-i18next

```tsx
// Simple plural
t('items', { count: 0 });   // "No items"
t('items', { count: 1 });   // "1 item"
t('items', { count: 5 });   // "5 items"

// JSON format (simpler)
{
  "items_zero": "No items",
  "items_one": "{{count}} item",
  "items_other": "{{count}} items"
}
```

---

## RTL Support

### Direction Detection

```typescript
// src/i18n/rtl.ts
const RTL_LANGUAGES = ['ar', 'he', 'fa', 'ur'];

export function isRTL(language: string): boolean {
  return RTL_LANGUAGES.includes(language.split('-')[0]);
}
```

### CSS Logical Properties

```css
/* Use logical properties for RTL support */

/* BAD: Physical properties */
.card {
  margin-left: 1rem;
  padding-right: 2rem;
  text-align: left;
  border-left: 1px solid #ccc;
}

/* GOOD: Logical properties */
.card {
  margin-inline-start: 1rem;
  padding-inline-end: 2rem;
  text-align: start;
  border-inline-start: 1px solid #ccc;
}
```

### Document Direction

```tsx
// src/components/App.tsx
import { useTranslation } from 'react-i18next';
import { isRTL } from '../i18n/rtl';

function App() {
  const { i18n } = useTranslation();
  const dir = isRTL(i18n.language) ? 'rtl' : 'ltr';

  useEffect(() => {
    document.documentElement.dir = dir;
    document.documentElement.lang = i18n.language;
  }, [dir, i18n.language]);

  return <div dir={dir}>{/* App content */}</div>;
}
```

---

## Server-Side i18n

### Next.js i18n

```typescript
// next.config.js
module.exports = {
  i18n: {
    locales: ['en', 'es', 'fr', 'de'],
    defaultLocale: 'en',
    localeDetection: true,
  },
};

// pages/index.tsx
import { GetStaticProps } from 'next';
import { serverSideTranslations } from 'next-i18next/serverSideTranslations';

export const getStaticProps: GetStaticProps = async ({ locale }) => ({
  props: {
    ...(await serverSideTranslations(locale ?? 'en', ['common'])),
  },
});
```

### Express i18n Middleware

```typescript
// src/middleware/i18n.ts
import { Request, Response, NextFunction } from 'express';

const SUPPORTED_LOCALES = ['en', 'es', 'fr', 'de'];
const DEFAULT_LOCALE = 'en';

export function i18nMiddleware(req: Request, res: Response, next: NextFunction) {
  // Check header, query, cookie in order
  const locale =
    req.query.locale as string ||
    req.cookies.locale ||
    parseAcceptLanguage(req.headers['accept-language']);

  req.locale = SUPPORTED_LOCALES.includes(locale) ? locale : DEFAULT_LOCALE;
  next();
}

function parseAcceptLanguage(header?: string): string {
  if (!header) return DEFAULT_LOCALE;

  const languages = header.split(',').map((lang) => {
    const [code] = lang.trim().split(';');
    return code.split('-')[0];
  });

  return languages.find((lang) => SUPPORTED_LOCALES.includes(lang)) || DEFAULT_LOCALE;
}
```

---

## Translation File Organization

```
locales/
├── en/
│   ├── common.json       # Shared translations
│   ├── auth.json         # Authentication pages
│   ├── products.json     # Product pages
│   └── errors.json       # Error messages
├── es/
│   ├── common.json
│   ├── auth.json
│   └── ...
└── fr/
    └── ...
```

---

## Checklist

Before completing i18n implementation:

- [ ] All user-facing text externalized
- [ ] Locale detection configured
- [ ] Language switcher implemented
- [ ] Date/number/currency formatters use locale
- [ ] Pluralization rules defined
- [ ] RTL layout support (if needed)
- [ ] Translation files organized by namespace
- [ ] Fallback language configured
- [ ] Meta tags include lang attribute

---

## Related

- `accessibility.md` - Language accessibility
- `frontend-architecture.md` - Component patterns

---

*Protocol created: 2025-12-08*
*Version: 1.0*
