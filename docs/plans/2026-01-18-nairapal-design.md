# NairaPal Design Document

**Created:** 2026-01-18

## Overview

NairaPal is a personal expense tracker focused on frictionless logging and beautiful presentation. The core philosophy: *logging should take 3 seconds, insights should be glanceable.*

## MVP Scope

### Free Tier
- Quick expense entry (amount first, optional category/note)
- Preset categories with customization
- Multi-currency support with user-selected default
- Home screen with pie chart + category spending summary
- Selectable timeframes (day/week/month/custom)
- Expense history with search/filter
- Local-only storage

### Premium Features (Yearly subscription)
- Budget limits per category with progress indicators
- Over-budget warnings
- Future: widgets, reminders, statement import

## Screen Structure

### 1. Home Screen
- Timeframe selector at top (Day / Week / Month toggle)
- Pie chart showing expense distribution by category
- Category spending cards below (list showing amount per category)
- Floating quick-entry button (bottom right, always accessible)

### 2. Entry Sheet (slides up)
- Large numpad for amount input
- Currency selector (subtle, shows current default)
- Category chips (tap to select, or skip)
- Note field (collapsed by default, tap to expand)
- "Done" saves and dismisses

### 3. History Screen
- Scrollable timeline of expenses
- Grouped by day with daily totals
- Each entry: amount, category icon, note preview, time
- Tap to edit/delete
- Search and filter by category/date range

### 4. Settings Screen
- Categories management (reorder, rename, icons, add/archive)
- Default currency selection
- Premium upgrade (budgets)
- Data export
- Theme (light/dark/system)

### Navigation
Bottom tab bar with 3 tabs: **Home | History | Settings**

## Visual Design System

### Color Palette (Soft & Warm)
| Token | Light Mode | Dark Mode |
|-------|------------|-----------|
| Background | #FAF8F5 | #1C1B1A |
| Primary accent | #D4847C (coral) | #D4847C |
| Secondary (positive) | #9CAF91 (sage) | #9CAF91 |
| Warning | #E6A959 (amber) | #E6A959 |
| Text primary | #2D2A26 | #FAF8F5 |

### Typography
- **Display/Numbers:** Distinctive serif or rounded sans (Nunito)
- **Body:** Clean sans-serif (Inter or system default)
- Hierarchy through weight and size, not color

### Micro-interactions
- Subtle spring animations on button presses
- Smooth sheet transitions (entry panel slides up with gentle ease)
- Pie chart animates segments growing outward on load
- Category cards have gentle press states
- Numbers tick up/down when totals change

### Icons
Rounded, friendly line icons (Phosphor Icons style)

## Data Model

### Expense
```dart
class Expense {
  int id;
  double amount;
  String currency;       // Currency code (NGN, USD, etc.)
  int? categoryId;       // Nullable for uncategorized
  String? note;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Category
```dart
class Category {
  int id;
  String name;
  String icon;
  String color;          // Hex color
  bool isDefault;
  int sortOrder;
  bool isArchived;
}
```

### Budget (Premium)
```dart
class Budget {
  int id;
  int categoryId;
  double amount;
  String period;         // 'monthly'
  String currency;
}
```

### UserSettings
```dart
class UserSettings {
  String defaultCurrency;
  String theme;          // 'light', 'dark', 'system'
  bool isPremium;
  DateTime? premiumExpiresAt;
}
```

## Preset Categories

| Category | Icon | Color |
|----------|------|-------|
| Food & Drinks | utensils | #D4847C |
| Transport | car | #6B9BD2 |
| Shopping | shopping-bag | #9B7ED9 |
| Bills & Utilities | file-text | #8B8B8B |
| Entertainment | film | #E091B8 |
| Health | pill | #9CAF91 |
| Education | book | #6BB5B5 |
| Gifts | gift | #E6A959 |
| Groceries | shopping-cart | #A8C97F |
| Other | pin | #A39E99 |

## Technical Architecture

### State Management
Riverpod - lightweight, good for local-only apps

### Local Database
Drift (SQLite wrapper) - type-safe queries, migrations built-in

### Project Structure
```
lib/
├── main.dart
├── app.dart                 # MaterialApp setup, theming
├── core/
│   ├── theme/               # Colors, typography, spacing
│   └── constants/           # Currency codes, category defaults
├── data/
│   ├── database/            # Drift database, DAOs
│   └── repositories/        # Data access layer
├── models/                  # Expense, Category, Budget, Settings
├── providers/               # Riverpod providers
├── screens/
│   ├── home/
│   ├── entry/
│   ├── history/
│   └── settings/
└── widgets/                 # Shared components
```

### Key Packages
- `drift` + `sqlite3_flutter_libs` - Database
- `flutter_riverpod` - State management
- `fl_chart` - Pie chart
- `intl` - Currency formatting
- `flutter_animate` - Micro-interactions

## Future Roadmap (Post-MVP)
- Reminder notifications (user-set times)
- Home screen widgets for budget alerts
- Auto-categorization from notes (ML-based)
- Statement/screenshot import
