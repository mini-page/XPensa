# Hero Section Enhancement - 2026-04-03

## Overview
Enhance the Hero section of `index.html` using the user's provided layout as a base, with realistic financial stats and an actionable "Icon Grid" in the floating app card.

## Design

### 1. Section Layout
- **Background**: Two large `blur-3xl` decorations (Blue at top-right, Purple at bottom-left) with `opacity-20`.
- **Text Content**: Standard hero title with `gradient-text`, body description, and 3 trust badges (Private, Open Source, Lightweight).
- **Primary Buttons**: "Get App" (gradient) and "GitHub" (secondary/outline).

### 2. Floating App Card (The "Mockup")
- **Base Style**: `bg-white rounded-2xl shadow-2xl p-8 space-y-4 transform hover:rotate-1 transition-transform duration-300`.
- **Entrance**: `animate-slideInRight stagger-2`.
- **Header**: "All Accounts" with a settings slider icon.
- **Financial Stats**:
    - Total Balance: `₹14,250` (Large bold text).
    - Grid (2 columns): 
        - **EXPENSES**: `₹2,800` (`bg-blue-50`, `text-blue-600`).
        - **INCOME**: `₹17,050` (`bg-green-50`, `text-green-600`).

### 3. Icon Grid (App Actions)
A 2x2 grid of quick-action buttons below the stats:
| Action | Icon | Color Theme |
| :--- | :--- | :--- |
| Split Bills | `fas fa-users-between-lines` | Teal (`teal-500` / `bg-teal-50`) |
| Recurring | `fas fa-repeat` | Amber (`amber-500` / `bg-amber-50`) |
| Scanner | `fas fa-barcode` | Indigo (`indigo-500` / `bg-indigo-50`) |
| Share/Export | `fas fa-share-nodes` | Rose (`rose-500` / `bg-rose-50`) |

- **Button Style**: Squircle-style buttons with centered icons, rounded-xl, providing a realistic mobile app UI feel.

## Success Criteria
- The Hero section looks professional and matches the new unified design system.
- Stats are realistic and visually clear.
- The action grid creates a sense of "interactivity" and functionality.
