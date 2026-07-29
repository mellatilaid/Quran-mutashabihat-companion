---
name: theming-style
description: Write Flutter UI code that uses BuildContext extensions for theme access, semantic colors from ColorScheme, and text styles from TextTheme. Ensures consistent, dark/light-mode-aware theming across the Quran Mutashabihat app. Keywords: theme, colors, text styles, context extension, ColorScheme, dark mode, light mode.
---

# Theming Style Skill

Apply this skill when writing **any** Flutter UI code in the Quran Mutashabihat app to ensure consistent, theme-aware styling.

## Core Pattern: Context Extensions

Never use `Theme.of(context)`, `AppLocalizations.of(context)`, or `GoogleFonts` directly. Always use `BuildContext` extensions.

### Available Extensions

**File**: `lib/src/core/extensions/build_context_extensions.dart`

```dart
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  AppDimensionsTheme get dimensionsTheme =>
      theme.extension<AppDimensionsTheme>()!;
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
```

## Step-by-Step Workflow

### Step 1: Add Extensions Import

```dart
import 'package:quran_mutashibihat_app/src/core/extensions/build_context_extensions.dart';
import 'package:quran_mutashibihat_app/l10n/app_localizations.dart';
```

### Step 2: Choose Your Styling Task

Follow the decision tree below:

```
Do you need...
├─ Text/Typography?           → Go to Pattern 1: Text Styles
├─ Colors/Background?         → Go to Pattern 2: Semantic Colors
├─ Spacing/Dimensions?        → Go to Pattern 3: Dimensions
├─ Localized strings?         → Go to Pattern 4: Localization
└─ Dark/Light mode adapt?     → (Automatic via ColorScheme—no extra code needed)
```

---

## Pattern 1: Text Styles

**Rule**: Use `context.textTheme.<style>` for all text. Never hardcode `fontSize`, `fontWeight`, or use `GoogleFonts`.

### Available Styles

| Style                                              | Use Case                      | Example                    |
| -------------------------------------------------- | ----------------------------- | -------------------------- |
| `displayLarge`, `displayMedium`, `displaySmall`    | Hero headlines, page titles   | App name in AppBar         |
| `headlineLarge`, `headlineMedium`, `headlineSmall` | Section headers, list headers | "Surahs" header            |
| `titleLarge`, `titleMedium`, `titleSmall`          | Card titles, dialog titles    | Surah name in list item    |
| `bodyLarge`, `bodyMedium`, `bodySmall`             | Body text, paragraphs         | Ayah content, descriptions |
| `labelLarge`, `labelMedium`, `labelSmall`          | Tags, badges, button labels   | Verse count badge          |

### Example: AppBar Title (From Your Code)

```dart
// ✅ CORRECT (from index_view.dart)
AppBar(
  title: Text(
    context.l10n.mutashabihatCompanion,
    style: context.textTheme.displayMedium?.copyWith(
      color: context.colorScheme.onPrimary,
    ),
  ),
  elevation: 0,
  backgroundColor: context.colorScheme.primaryContainer,
)

// ❌ WRONG
AppBar(
  title: Text(
    'App Title',
    style: GoogleFonts.amiri(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
)
```

### When to Use `.copyWith()`

Use `.copyWith()` **only** for minor tweaks:

- ✅ `fontWeight`, `fontStyle`, `decoration` (emphasis)
- ✅ `color` (semantic color override)
- ✅ `letterSpacing` (readability adjustment)
- ❌ Never change `fontSize`, `fontFamily`, or base style

```dart
// ✅ CORRECT with minor tweaks
Text(
  surah.nameArabic,
  style: context.textTheme.titleLarge?.copyWith(
    fontWeight: FontWeight.w600,  // Minor tweak
  ),
)
```

---

## Pattern 2: Semantic Colors (ColorScheme)

**Rule**: Use `context.colorScheme.<semantic>` for all colors. Never hardcode hex values like `Color(0xFF1B5E20)`.

### Why Semantic Colors?

- **Automatic dark/light adaptation**: No `isDark` checks needed
- **Consistent theming**: Change colors once, update everywhere
- **Accessibility**: Colors meet Material 3 contrast standards
- **Semantic intent**: Code reads like "interactive element" not just "green"

### Available Semantic Colors

| Color                                                                    | Use Case                                       | Notes                                                   |
| ------------------------------------------------------------------------ | ---------------------------------------------- | ------------------------------------------------------- |
| `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`         | Main brand, interactive elements, app identity | Use `primary` for buttons, active links                 |
| `secondary`, `onSecondary`, `secondaryContainer`, `onSecondaryContainer` | Accents, alternative interactive states        | Use `secondary` for secondary buttons                   |
| `surface`, `onSurface`, `surfaceVariant`, `onSurfaceVariant`             | Cards, panels, default text                    | Use `surface` for card background, `onSurface` for text |
| `error`, `onError`, `errorContainer`, `onErrorContainer`                 | Error states, validation failures              | Use `errorContainer` for soft error backgrounds         |
| `tertiary`, `onTertiary`                                                 | Additional accents, decorative elements        | Use sparingly                                           |
| `outline`, `outlineVariant`                                              | Borders, dividers, subtle separators           | `outlineVariant` for softer borders                     |

### The `on*` Convention

- `onPrimary` = Text/elements **on top of** `primary` background
- `onPrimaryContainer` = Text/elements **on top of** `primaryContainer` background
- **Rule**: If you set a background color, also set the foreground text/icon color

```dart
// ✅ CORRECT
Container(
  color: context.colorScheme.primary,
  child: Text(
    'Interactive Element',
    style: context.textTheme.labelSmall?.copyWith(
      color: context.colorScheme.onPrimary,  // ← Always pair with `on*`
    ),
  ),
)

// ❌ WRONG (text won't be readable on dark theme)
Container(
  color: context.colorScheme.primary,
  child: Text(
    'Interactive Element',
    style: context.textTheme.labelSmall,  // No color—defaults to dark text
  ),
)
```

### Example: Card with Badges (From Your Code)

```dart
// ✅ CORRECT (from index_view.dart)
trailing: Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: context.colorScheme.primary.withValues(alpha: 0.15),  // Soft primary
    borderRadius: BorderRadius.circular(16),
  ),
  child: Text(
    surah.nameSimple,
    style: context.textTheme.labelSmall?.copyWith(
      color: context.colorScheme.primary,  // Text matches background color family
    ),
  ),
)
```

### Opacity & Variants with `.withValues(alpha: ...)`

Use `withValues(alpha: ...)` for soft/light variants (highlights, disabled states):

```dart
// ✅ CORRECT
Container(
  color: context.colorScheme.primary.withValues(alpha: 0.15),  // 15% opacity
  child: Text('Soft highlight'),
)

// ✅ CORRECT for disabled state
opacity: context.colorScheme.onSurface.withValues(alpha: 0.38),  // Disabled text
```

---

## Pattern 3: Spacing & Dimensions

**Rule**: Use `context.dimensionsTheme` for custom spacing tokens, or standard `EdgeInsets` constants.

```dart
// ✅ CORRECT with custom dimensions
Container(
  padding: context.dimensionsTheme.paddingHelpIndication,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(
      context.dimensionsTheme.radiusHelpIndication,
    ),
  ),
)

// ✅ CORRECT with standard spacing
Card(
  margin: const EdgeInsets.symmetric(vertical: 6),
  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
)
```

---

## Pattern 4: Localization

**Rule**: Use `context.l10n.<key>` for all user-visible strings. Never hardcode Arabic/English text.

```dart
// ✅ CORRECT (from index_view.dart)
Text(
  '${surah.versesCount} ${AppLocalizations.of(context).verses} • ${surah.mutashabihatAyahCount} ${AppLocalizations.of(context).mutashabihat}',
  style: context.textTheme.labelSmall,
)

// Even better:
Text(
  '${surah.versesCount} ${context.l10n.verses} • ${surah.mutashabihatAyahCount} ${context.l10n.mutashabihat}',
  style: context.textTheme.labelSmall,
)

// ❌ WRONG
Text(
  '${surah.versesCount} آيات',  // Hardcoded Arabic
  style: context.textTheme.labelSmall,
)
```

---

## Common Theming Tasks

### Task 1: Style an AppBar

```dart
AppBar(
  title: Text(
    context.l10n.pageTitle,
    style: context.textTheme.displayMedium?.copyWith(
      color: context.colorScheme.onPrimary,
    ),
  ),
  elevation: 0,
  backgroundColor: context.colorScheme.primaryContainer,
)
```

### Task 2: Create a Card with Semantic Styling

```dart
Card(
  child: Container(
    color: context.colorScheme.surface,  // Card surface
    child: Column(
      children: [
        Text(
          'Title',
          style: context.textTheme.titleLarge,
        ),
        Text(
          'Subtitle',
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,  // Secondary text
          ),
        ),
      ],
    ),
  ),
)
```

### Task 3: Color Button States

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: context.colorScheme.primary,
    foregroundColor: context.colorScheme.onPrimary,
  ),
  onPressed: () {},
  child: Text(context.l10n.buttonLabel),
)
```

### Task 4: Disabled/Secondary Text

```dart
Text(
  'Hint or secondary info',
  style: context.textTheme.bodySmall?.copyWith(
    color: context.colorScheme.onSurfaceVariant,  // Semantic secondary text
  ),
)
```

---

## Anti-Patterns (What NOT to Do)

| Anti-Pattern                                      | Problem                              | Solution                                         |
| ------------------------------------------------- | ------------------------------------ | ------------------------------------------------ |
| `Theme.of(context)`                               | Verbose, brittle                     | Use `context.textTheme`, `context.colorScheme`   |
| `GoogleFonts.amiri(fontSize: 18)`                 | Hardcoded, ignores theme             | Use `context.textTheme.labelSmall`               |
| `Color(0xFF1B5E20)`                               | Not theme-aware, breaks in dark mode | Use `context.colorScheme.primary`                |
| `isDark ? color1 : color2`                        | Duplicates theme logic, fragile      | Use `ColorScheme`—it's already aware             |
| `AppLocalizations.of(context)`                    | Verbose                              | Use `context.l10n` extension                     |
| `.copyWith(fontSize: 20, fontFamily: 'SomeFont')` | Breaks design system                 | Only use for `fontWeight`, `color`, `decoration` |

---

## Verification Checklist

Before committing UI code, verify:

- [ ] No `Theme.of(context)` or `AppLocalizations.of(context)` calls
- [ ] All text uses `context.textTheme.<style>`
- [ ] All colors use `context.colorScheme.<semantic>`
- [ ] No hardcoded `Color(0x...)` hex values
- [ ] No `isDark` checks—ColorScheme handles it
- [ ] `.copyWith()` used only for `fontWeight`, `color`, `decoration` tweaks
- [ ] All user strings use `context.l10n.<key>`
- [ ] Pair background colors with `on*` foreground colors
- [ ] Opacity/alpha uses `.withValues(alpha: value)`

---

## Quick Reference

| Task             | Code                                                  |
| ---------------- | ----------------------------------------------------- |
| Title text       | `style: context.textTheme.titleLarge`                 |
| Body text        | `style: context.textTheme.bodyMedium`                 |
| Small label      | `style: context.textTheme.labelSmall`                 |
| Primary color    | `context.colorScheme.primary`                         |
| Text on primary  | `context.colorScheme.onPrimary`                       |
| Surface/card     | `context.colorScheme.surface`                         |
| Secondary text   | `context.colorScheme.onSurfaceVariant`                |
| Soft highlight   | `context.colorScheme.primary.withValues(alpha: 0.15)` |
| Localized string | `context.l10n.stringKey`                              |
| Custom dimension | `context.dimensionsTheme.radiusKey`                   |

---

## Related Documentation

- **Extension Definition**: `lib/src/core/extensions/build_context_extensions.dart`
- **Theme Configuration**: `lib/src/core/theme/app_theme.dart`
- **Text Styles**: `lib/src/core/theme/custom_themes/app_text_theme.dart`
- **Localization Strings**: `lib/l10n/app_ar.arb`
- **Repo Memory**: `theme_access_patterns.md` (in session repo memory)
