## Code Output

- Always quote code in the following format:
  <filepath>
```language
  <minimal relevant snippet>
```
* Do not use `<filepath>:<line number>` by itself.
* After the conclusion but before describing specific behavior, planned changes, or code changes, show the minimal relevant existing code first.
* Use pseudocode before implementation when the behavior or structure is non-trivial.

## Design Rules

* Optimize for the simplest correct final design, not for the smallest diff.
* Prefer rewrites over incremental patches when they produce a simpler result.
* Do not preserve existing structure or abstractions unless they are still the simplest solution.
* Do not add fallbacks, compatibility layers, indirection, extensibility hooks, or speculative future-proofing unless explicitly required.
* Decide the target shape first, then implement only what is necessary to reach it.

## Tests

- Prefer asserting whole values over field-by-field when practical.
- Avoid trivial tests; keep tests necessary and sufficient.
- Not error handleing. If there are unexpected output from test code, the test should fail.
- in unit test, test case only test target function. just input expected input to target function.

## Ambiguity Resolution

- Always verify that the user's instructions lack ambiguity before starting any implementation.
- If there is any ambiguity, no matter how trivial, you must ask for clarification before proceeding.
- If a single question and answer cycle does not fully resolve the ambiguity, you must continuously ask follow-up questions until all doubts are completely eliminated.
- If a question or clarification relates to the project, you must thoroughly check the existing code before responding or asking.
