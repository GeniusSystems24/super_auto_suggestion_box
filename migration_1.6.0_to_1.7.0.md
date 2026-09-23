# Migration: 1.6.0 to 1.7.0

Version `1.7.0` improves remote suggestion loading by making fetch callbacks
context-aware, applying debounce only to external fetch work, and adding
`minResult` to control when local-first sources should request more data.

It also fixes desktop/web focus traversal so `SuperAutoSuggestionsBox` behaves
as a single `Tab` stop.

## Remote fetch callbacks now receive BuildContext

Remote source callbacks now receive the active Flutter `BuildContext`.

### Async source

Before:

```dart
final source = SuperAutoSuggestionSources.async<Account>(
  (query) => repository.searchAccounts(query),
);
```

After:

```dart
final source = SuperAutoSuggestionSources.async<Account>(
  (context, query) => repository.searchAccounts(query),
);
```

### Hybrid source

Before:

```dart
final source = SuperAutoSuggestionSources.hybrid<Account>(
  initialItems: localAccounts,
  fetch: (query) => repository.searchAccounts(query),
);
```

After:

```dart
final source = SuperAutoSuggestionSources.hybrid<Account>(
  initialItems: localAccounts,
  fetch: (context, query) => repository.searchAccounts(query),
);
```

### Remote fallback source

Before:

```dart
final source = SuperAutoSuggestionSources.remoteFallback<Account>(
  initialItems: localAccounts,
  fetch: (query) => repository.searchAccounts(query),
);
```

After:

```dart
final source = SuperAutoSuggestionSources.remoteFallback<Account>(
  initialItems: localAccounts,
  fetch: (context, query) => repository.searchAccounts(query),
);
```

### Paged source

Before:

```dart
final source = SuperAutoSuggestionSources.paged<Account>(
  (query, page) => repository.searchAccountsPage(query, page),
);
```

After:

```dart
final source = SuperAutoSuggestionSources.paged<Account>(
  (context, query, page) => repository.searchAccountsPage(query, page),
);
```

The context belongs to the active `SuperAutoSuggestionsBox`, so a remote fetch
may use inherited values when necessary, for example localization, theme
extensions, or providers available from the widget tree.

Keep transport and repository logic independent from UI context where possible.
Use the context parameter only when the fetch operation genuinely needs values
from the active widget tree.

## Source query APIs now receive BuildContext

The source repository API has also changed.

Before:

```dart
source.query(query);
source.progressive(query);
source.fetchPage(query, page);
```

After:

```dart
source.query(context, query);
source.progressive(
  context,
  query,
  minResult: 0,
);
source.fetchPage(context, query, page);
```

Applications that only construct sources and pass them to
`SuperAutoSuggestionsBox` normally only need to update their `fetch` callback
signatures.

Code that directly calls `SuperAutoSuggestionsSource.query`,
`progressive`, or `fetchPage` must pass a `BuildContext`.

## Local matching is no longer debounced

In `1.7.0`, debounce applies only to work that communicates with an external
source.

Local matching is performed immediately whenever the query changes.

Conceptually, the flow is now:

```text
query changes
    |
    v
local matching
    |
    +--> show local results immediately
    |
    v
check whether remote data is needed
    |
    v
debounce
    |
    v
remote fetch
    |
    v
merge/update results
```

This means a large debounce duration does not delay results that are already
available locally.

For example:

```dart
SuperAutoSuggestionsBox<Account>(
  source: SuperAutoSuggestionSources.hybrid<Account>(
    initialItems: cachedAccounts,
    fetch: (context, query) => repository.searchAccounts(query),
  ),
  debounce: const Duration(milliseconds: 800),
  suggestionBuilder: accountSuggestion,
);
```

Matching against `cachedAccounts` happens immediately. Only
`repository.searchAccounts(query)` waits for the debounce interval.

## Async initial items and cache are matched locally

`SuperAutoSuggestionSources.async` can use its `initialItems` and cached remote
items for immediate local matching before another remote request is made.

You may configure that local matching with `match` and `caseSensitive`.

```dart
final source = SuperAutoSuggestionSources.async<Account>(
  (context, query) => repository.searchAccounts(query),
  initialItems: cachedAccounts,
  match: AutoSuggestionMatch.contains,
  caseSensitive: false,
);
```

The local result can therefore be shown immediately while the remote request,
when needed, remains debounced.

## New minResult option

`SuperAutoSuggestionsBox<T>` now includes:

```dart
final int minResult;
```

Its default value is:

```dart
minResult: 0
```

`minResult` controls when a local-first query should continue to the remote
fetch step.

The threshold is inclusive:

```dart
localResults.length <= minResult
```

For example:

```dart
SuperAutoSuggestionsBox<Account>(
  source: SuperAutoSuggestionSources.hybrid<Account>(
    initialItems: cachedAccounts,
    fetch: (context, query) => repository.searchAccounts(query),
  ),
  minResult: 2,
  debounce: const Duration(milliseconds: 300),
  suggestionBuilder: accountSuggestion,
);
```

With `minResult: 2`:

- `0` local results -> remote fetch is allowed.
- `1` local result -> remote fetch is allowed.
- `2` local results -> remote fetch is allowed.
- `3` or more local results -> the local result is sufficient and no remote
  fetch is needed.

The source's other remote conditions still apply, including values such as
`remoteMinChars`.

### Default behavior

The default:

```dart
minResult: 0
```

means a local-first source only needs a remote fetch when no local matches are
available.

Increase `minResult` when a small number of local matches should still be
supplemented by the external source.

## Debounce now delays the fetch itself

Earlier implementations could start asynchronous work before the debounce
window had completed.

In `1.7.0`, the external operation itself starts only after the debounce delay.

```dart
SuperAutoSuggestionsBox<Account>(
  source: source,
  debounce: const Duration(milliseconds: 500),
  minResult: 1,
  suggestionBuilder: accountSuggestion,
);
```

If the user continues typing during those `500ms`, the pending remote operation
is replaced instead of starting another request.

The package now uses `easy_debounce` internally for this scheduling.

No application-level `easy_debounce` setup is required.

## Loading state starts with remote work

Waiting for the debounce interval is no longer treated as an active network
load.

Loading state begins when the external fetch actually starts.

This prevents loading indicators from appearing while the user is still typing
and the request is only waiting for its debounce window.

## Combining minResult and debounce

`minResult` decides **whether** more remote data is needed.

`debounce` decides **when** that remote work starts.

For example:

```dart
SuperAutoSuggestionsBox<Account>(
  source: SuperAutoSuggestionSources.hybrid<Account>(
    initialItems: cachedAccounts,
    fetch: (context, query) => repository.searchAccounts(query),
    remoteMinChars: 2,
  ),
  minResult: 3,
  debounce: const Duration(milliseconds: 400),
  suggestionBuilder: accountSuggestion,
);
```

The behavior is:

```text
match cachedAccounts immediately
        |
        v
local results > 3
        |
        +--> yes: stop; use local results
        |
        +--> no:
               |
               v
         check remoteMinChars
               |
               v
          wait 400ms
               |
               v
          remote fetch
```

## Desktop and web Tab traversal

`SuperAutoSuggestionsBox` now participates in focus traversal as a single form
field.

Before this fix, internal focusable elements could cause desktop/web users to
press `Tab` twice before focus reached the next form field.

No API change is required.

The expected traversal is now:

```text
previous field
    |
   Tab
    v
SuperAutoSuggestionsBox
    |
   Tab
    v
next field
```

Internal suffix/prefix actions remain clickable, but they no longer consume an
extra `Tab` stop during normal form traversal.

`Shift + Tab` similarly returns to the previous form field in one traversal
step.

## Complete before/after example

Before `1.7.0`:

```dart
final source = SuperAutoSuggestionSources.hybrid<Account>(
  initialItems: cachedAccounts,
  fetch: (query) => repository.searchAccounts(query),
  remoteMinChars: 2,
);

SuperAutoSuggestionsBox<Account>(
  source: source,
  debounce: const Duration(milliseconds: 300),
  suggestionBuilder: accountSuggestion,
);
```

After `1.7.0`:

```dart
final source = SuperAutoSuggestionSources.hybrid<Account>(
  initialItems: cachedAccounts,
  fetch: (context, query) => repository.searchAccounts(query),
  remoteMinChars: 2,
);

SuperAutoSuggestionsBox<Account>(
  source: source,
  minResult: 2,
  debounce: const Duration(milliseconds: 300),
  suggestionBuilder: accountSuggestion,
);
```

Local matches are shown immediately. If there are `2` or fewer local matches
and the source's other remote conditions pass, the remote fetch starts after
the `300ms` debounce interval.

## Migration checklist

1. Update asynchronous source callbacks from `(query)` to
   `(context, query)`.
2. Update hybrid source `fetch` callbacks from `(query)` to
   `(context, query)`.
3. Update remote-fallback source `fetch` callbacks from `(query)` to
   `(context, query)`.
4. Update paged source callbacks from `(query, page)` to
   `(context, query, page)`.
5. If your code directly calls source APIs, pass `BuildContext` to `query`,
   `progressive`, and `fetchPage`.
6. Review `debounce` values knowing that local matching is now immediate and
   only remote work is delayed.
7. Add `minResult` where local-first sources should fetch remotely even when a
   small number of local matches exists.
8. Keep `minResult: 0` or omit it when remote fetch should occur only when no
   local result is available.
9. If using `SuperAutoSuggestionSources.async` with `initialItems`, optionally
   configure `match` and `caseSensitive` for immediate local matching.
10. No code change is required for the desktop/web `Tab` traversal fix.
