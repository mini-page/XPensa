# Feature Cards Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Unify the "Features" section into a consistent 3x3 grid of vibrant, interactive cards.

**Architecture:** Replace the current mixed flex/grid layout with a single 3x3 Tailwind grid. Standardize the HTML structure for all 9 cards to match the "best" style identified by the user, using high-contrast icon backgrounds and unified hover effects.

**Tech Stack:** HTML5, Tailwind CSS, FontAwesome.

---

### Task 1: Clean up and Prepare Grid Container

**Files:**
- Modify: `index.html:560-670`

**Step 1: Clean up the features section**
Remove the redundant "Privacy Mode" card and the duplicate "Feature 6" comment. Ensure the grid container has the correct spacing.

**Step 2: Verify the grid structure**
Check that the container uses `grid md:grid-cols-3 gap-8`.

**Step 3: Commit**
```bash
git add index.html
git commit -m "refactor: prepare features grid and remove redundant cards"
```

### Task 2: Redesign Cards 1-3 (Logging, Analytics, Budgets)

**Files:**
- Modify: `index.html` (First 3 cards in the `#features` section)

**Step 1: Update Smart Expense Logging (Blue)**
Apply the vibrant style: `bg-blue-200`, `text-blue-700`, and `animate-fadeInUp`.

**Step 2: Update Visual Analytics (Emerald)**
Apply the vibrant style: `bg-emerald-200`, `text-emerald-700`, and `animate-fadeInUp`.

**Step 3: Update Budget Planning (Amber)**
Apply the vibrant style: `bg-amber-200`, `text-amber-700`, and `animate-fadeInUp`.

**Step 4: Commit**
```bash
git add index.html
git commit -m "feat: redesign first row of feature cards"
```

### Task 3: Redesign Cards 4-6 (Accounts, Recurring, Privacy)

**Files:**
- Modify: `index.html` (Next 3 cards in the `#features` section)

**Step 1: Update Multi-Account Support (Indigo)**
Apply the vibrant style: `bg-indigo-200`, `text-indigo-700`, and `animate-fadeInUp`.

**Step 2: Update Recurring Subscriptions (Pink)**
Apply the vibrant style: `bg-pink-200`, `text-pink-700`, and `animate-fadeInUp`.

**Step 3: Update 100% Private (Cyan)**
Ensure it matches the new standard (it's already close, but unify classes).

**Step 4: Commit**
```bash
git add index.html
git commit -m "feat: redesign second row of feature cards"
```

### Task 4: Redesign Cards 7-9 (Split Bills, Reminders, Export)

**Files:**
- Modify: `index.html` (Last 3 cards in the `#features` section)

**Step 1: Update Split Bills (Purple)**
Ensure it matches the new standard.

**Step 2: Update Smart Reminders (Rose)**
Ensure it matches the new standard.

**Step 3: Add Offline Backup/Export (Orange)**
Add the 9th card: `fas fa-file-export`, `bg-orange-200`, `text-orange-700`.

**Step 4: Commit**
```bash
git add index.html
git commit -m "feat: complete third row of feature cards"
```

### Task 5: Final Polish and Verification

**Files:**
- Modify: `index.html`

**Step 1: Check for inconsistencies**
Verify all cards have the same hover behavior, transitions, and entrance animations. Remove any remaining custom CSS classes that are no longer needed if they were only for these cards.

**Step 2: Verify responsiveness**
Ensure the 3x3 grid collapses correctly to 1 column on mobile.

**Step 3: Commit**
```bash
git add index.html
git commit -m "chore: final polish and consistency check for feature cards"
```
