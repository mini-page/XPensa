# pr-review — Full Pull Request Analysis

## Purpose
Perform a comprehensive review of a pull request covering UI correctness, logic, performance, and code quality before merge.

## Review Dimensions

### 1. Code Quality
- [ ] `flutter analyze` passes with zero issues.
- [ ] `dart format .` produces no diff.
- [ ] No `print()` calls — use `dev.log`.
- [ ] No hardcoded strings that should be constants.
- [ ] No `dynamic` types without justification.

### 2. Architecture
- [ ] Changes follow feature-driven Clean Architecture (`data/` → `domain/` → `presentation/`).
- [ ] Imports use feature barrel files, not deep internal paths.
- [ ] Data models have no Flutter/Riverpod imports.
- [ ] New screens follow the `screens/<name>/` sibling-directory convention for extracted widgets.

### 3. State Management
- [ ] New providers use appropriate Riverpod type (`AsyncNotifierProvider`, `NotifierProvider`, etc.).
- [ ] `ref.watch` only in `build()`; `ref.read` in callbacks.
- [ ] State mutations call `ref.invalidate` / update `state` correctly.

### 4. UI & UX
- [ ] No hardcoded pixel sizes — uses `MediaQuery` / `LayoutBuilder`.
- [ ] `const` constructors used where possible.
- [ ] No layout overflows on common screen sizes.
- [ ] Dark mode and light mode both tested.

### 5. Data & Dates
- [ ] New `ExpenseModel` / date fields stored as UTC.
- [ ] Filters compare local dates after `.toLocal()`.

### 6. Tests
- [ ] New business logic has unit tests.
- [ ] New widgets have widget tests (or justification for omission).
- [ ] All existing tests pass: `flutter test`.

### 7. Security
- [ ] No secrets or credentials added.
- [ ] No PII written to logs.
- [ ] New Android permissions are justified.

## Output Format
Provide a summary table (Pass / Fail / N/A) for each dimension, followed by specific line-level comments for any failures.
