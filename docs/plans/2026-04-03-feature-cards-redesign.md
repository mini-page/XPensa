# Feature Cards Redesign - 2026-04-03

## Overview
Unify the "Features" section in `index.html` into a consistent 3x3 grid using the "best" styling from the current last 3 cards. This will fix styling inconsistencies and redundant content.

## Design

### 1. Grid Structure
- **Layout**: 3 columns on medium/large screens (`md:grid-cols-3`), 1 column on mobile.
- **Section**: `<section id="features" class="py-20 px-6 bg-white">`.

### 2. Card Component Style
Each feature card will use the following structure:
- **Base**: `bg-white rounded-2xl p-6 border-2 border-transparent animate-fadeInUp hover:border-[COLOR]-500/30 shadow-sm hover:shadow-xl group reveal relative overflow-hidden`.
- **Background Gradient**: `absolute inset-0 bg-gradient-to-br from-[COLOR]-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity`.
- **Icon Container**: `w-14 h-14 rounded-xl bg-[COLOR]-200 text-[COLOR]-700 flex items-center justify-center text-2xl mb-4 group-hover:scale-110 group-hover:-rotate-6 transition-transform`.
- **Content**: Bold headings (`text-xl font-bold`) and gray descriptive text (`text-gray-600 text-sm leading-relaxed`).

### 3. Feature Mapping (3x3 Grid)
| Feature | Icon | Primary Color |
| :--- | :--- | :--- |
| Smart Expense Logging | `fas fa-receipt` | Blue (`blue`) |
| Visual Analytics | `fas fa-chart-pie` | Emerald (`emerald`) |
| Budget Planning | `fas fa-bullseye` | Amber (`amber`) |
| Multi-Account Support | `fas fa-wallet` | Indigo (`indigo`) |
| Recurring Subscriptions | `fas fa-repeat` | Pink (`pink`) |
| 100% Private | `fas fa-lock` | Cyan (`cyan`) |
| Split Bills | `fas fa-users` | Purple (`purple`) |
| Smart Reminders | `fas fa-bell` | Rose (`rose`) |
| Offline Backup/Export | `fas fa-file-export` | Orange (`orange`) |

### 4. Cleanup Items
- **Redundancy**: Merge "Privacy Mode" and "100% Private".
- **Consistency**: Remove `active` class from `reveal` elements (let the script handle it).
- **Comments**: Ensure Feature 1-9 numbering is correct.

## Success Criteria
- All 9 feature cards have identical styling behavior (hover, entrance, icons).
- No duplicate features or broken layouts.
- Grid is fully responsive.
