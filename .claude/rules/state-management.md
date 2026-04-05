# state-management.md — Riverpod State Management Rules

## Provider Types

| Use Case | Provider Type |
|----------|--------------|
| Async data backed by Hive | `AsyncNotifierProvider` |
| Sync computed/derived state | `Provider` |
| Sync mutable state with logic | `NotifierProvider` |
| Simple UI toggle / selection | `StateProvider` |
| Stream of values | `StreamProvider` |

## Declaration

- Declare providers at the **top level** of their feature's `provider/` file, not inside classes or functions.
- One `Notifier` class + one `provider` constant per file (unless tightly related).
- All providers are exported via the feature barrel.

## Consumption

- `ref.watch(provider)` — in `build()` only; triggers rebuild on change.
- `ref.read(provider)` — in callbacks, `onPressed`, `initState`; no rebuild.
- `ref.listen(provider, callback)` — for side-effects (navigation, snackbars).
- Use `ref.watch(provider.select((v) => v.field))` to narrow rebuilds to a single field.

## Mutations

- Mutating methods live in the `Notifier` class, not in widget code.
- After an external mutation (e.g., Hive write), update `state` or call `ref.invalidate(provider)` to trigger a fresh read.
- Async mutations must `await` the operation before updating state.

## Anti-Patterns

- ❌ `ref.watch` inside `initState`, `dispose`, or event callbacks.
- ❌ Storing `BuildContext` or `Widget` inside a provider.
- ❌ Calling `state = ...` from inside `build()`.
- ❌ Creating a `ProviderContainer` inside a widget's `build` method.

## Testing

- Override providers in tests using `ProviderScope(overrides: [...])` or `ProviderContainer(overrides: [...])`.
- Never test implementation details of `Notifier` internals — test observable state transitions.
