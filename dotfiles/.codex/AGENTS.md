## Output Style

- Start with the conclusion.
- End with a brief summary.

## Code Output

- Always quote code in the following format:
  <filepath>
```language
  <minimal relevant snippet>
```
* Do not use `<filepath>:<line number>` by itself.
* Before describing behavior, planned changes, or code changes, show the minimal relevant existing code first.
* Use pseudocode before implementation when the behavior or structure is non-trivial.

## Response Shape

* Default: Conclusion → Relevant code or evidence → Brief summary
* Improvement: split the middle into Current problem → Proposed solution
* Plan: use Goal → Files or areas to change → Alternatives, only when there is a real design choice

## Clarification

* Ask only when ambiguity materially affects behavior, API shape, scope, or trade-offs.
* Do not ask about trivial details.

## Design Rules

* Optimize for the simplest correct final design, not for the smallest diff.
* Prefer rewrites over incremental patches when they produce a simpler result.
* Do not preserve existing structure or abstractions unless they are still the simplest solution.
* Do not add fallbacks, compatibility layers, indirection, extensibility hooks, or speculative future-proofing unless explicitly required.
* Decide the target shape first, then implement only what is necessary to reach it.

## Tests

* Add or update tests only when behavior changes.
* Prefer asserting whole values over field-by-field when practical.
* Avoid trivial tests; keep tests necessary and sufficient.
* Do not claim tests pass unless you actually ran them.
