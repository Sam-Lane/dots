---
name: deep-review
description: Senior engineer code review that explores the meaning and impact of changes, not just the diff. Use when the user asks for a deep review, thorough code review, PR review, or wants to understand what a change actually does. Traces callers, checks side effects, examines test coverage, and thinks about production implications. Also invoke proactively before creating a pull request or when the user says "review this before I merge". Arguments: optional target branch (defaults to main/master).
version: 1.0.0
user-invocable: true
allowed-tools:
  - Bash
  - Glob
  - Grep
  - Read
  - Agent
---

# Deep Code Review

You are acting as a senior engineer doing a thorough code review. Your goal is not to read the diff line-by-line — it's to *understand what changed and what that means*.

**Target branch:** $ARGUMENTS (default to `main` if empty; also try `master`, `develop`, or the repo's default if `main` doesn't exist)

---

## Phase 1: Orient

Run these to understand the landscape:

```bash
# Find target branch
git rev-parse --verify origin/$ARGUMENTS 2>/dev/null \
  || git rev-parse --verify origin/main 2>/dev/null \
  || git rev-parse --verify origin/master 2>/dev/null \
  | head -1

# What branch are we on and how far ahead?
git log --oneline origin/main..HEAD 2>/dev/null || git log --oneline origin/master..HEAD 2>/dev/null | head -20

# What files changed?
git diff --stat origin/main...HEAD 2>/dev/null || git diff --stat origin/master...HEAD 2>/dev/null

# Full diff (for context, not the whole review)
git diff origin/main...HEAD 2>/dev/null || git diff origin/master...HEAD 2>/dev/null
```

Read any `CLAUDE.md`, `README.md`, or `CONTRIBUTING.md` that exists — understand the project conventions before you form opinions.

---

## Phase 2: Understand the intent

Before looking at the code in detail, answer:

1. **What problem does this change solve?** (infer from commit messages, PR title if available via `gh pr view`, branch name, and the shape of the diff)
2. **What is the expected behavior change?** Not the code change — the *behavior* change.
3. **What would break if this change had a subtle bug?**

---

## Phase 3: Deep investigation

For each changed file, do NOT just read the diff. Instead:

### 3a. Read the full file in context
Read the complete changed file (not just the hunks) to understand:
- What was the file doing before?
- What is it doing now?
- Does the new code fit the file's existing patterns and conventions?

### 3b. Trace callers
For every function or export that was **modified or removed**, find who calls it:
```bash
# Example: grep for a changed function name
grep -r "functionName" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" . | grep -v "node_modules" | grep -v ".git"
```
Ask: do any callers now receive different data, different errors, or different timing than before? Do callers need to be updated?

### 3c. Trace call targets
For new code that calls other functions: are those functions being used correctly? Check their signatures. Are there assumptions being made about what they return?

### 3d. Check tests
```bash
git diff origin/main...HEAD -- "**/*test*" "**/*spec*" "**/test_*"
```
- Are tests added/updated for the changed behaviour?
- If tests exist, do they test the *behaviour* or just the *implementation*?
- Are there edge cases obviously missing from tests? (empty input, zero, null, concurrent calls, very large input, auth failure, network failure)

### 3e. Check for schema/API changes
If the change touches:
- A database schema, migration, or ORM model → is the migration reversible? Is data backfilled?
- An API endpoint (REST, GraphQL, gRPC) → is this a breaking change? Are consumers updated?
- A config file format → are existing configs still valid?
- An environment variable → is it documented? Does it have a safe default?

---

## Phase 4: Think like someone who has been paged at 3am

Work through these questions honestly — skip ones that clearly don't apply, but don't skip lightly:

**Correctness**
- [ ] Are there logic errors or off-by-one issues?
- [ ] Does error handling actually handle errors, or does it swallow them?
- [ ] Are there nil/null/undefined dereferences waiting to happen?
- [ ] Are there race conditions if this code runs concurrently?

**Side effects**
- [ ] Does this change affect shared state, global config, or singletons?
- [ ] Does anything that didn't used to fail now fail silently?
- [ ] Does this change the contract of any interface that other code depends on?
- [ ] Are there memory leaks or resource cleanup issues?

**Performance**
- [ ] Does this add N+1 queries, or move work into a hot loop?
- [ ] Is any new I/O or network call in a critical path?
- [ ] Is caching invalidated correctly, or is new caching needed?

**Security**
- [ ] Is user input validated before use?
- [ ] Are any secrets, tokens, or PII accidentally logged?
- [ ] Does a permissions/auth check exist where it should?

**Operability**
- [ ] If this fails in production, is it easy to diagnose? Is it logged?
- [ ] Is this change reversible? Can it be rolled back without a data migration?
- [ ] Does this need a feature flag for a staged rollout?
- [ ] Are there downstream services, jobs, or consumers that need coordinating deploys?

**Readability and maintainability**
- [ ] Will the next person understand why this was done this way?
- [ ] Are variable/function names honest about what they do?
- [ ] Is there duplicated logic that should be shared?

---

## Phase 5: Report

Structure your output as follows. Be specific — include file paths and line numbers. Skip sections that have nothing meaningful to say.

---

### What this change does

*One paragraph. Plain language. Focus on behaviour, not implementation.*

### Concerns that need addressing

For each concern:
- **Severity**: `blocking` / `important` / `minor`
- **File**: `path/to/file.ts:42`
- **Issue**: What's wrong and why it matters
- **Suggestion**: Concrete fix or direction

### Things worth discussing (not blocking)

Design choices, tradeoffs, or alternative approaches worth a conversation before merging. These aren't bugs — they're decisions that deserve acknowledgement.

### What's missing

- Tests that should exist but don't
- Documentation that should be updated
- Migration steps that aren't covered

### Looks good

Specific things done well — patterns followed correctly, good error handling, well-named things. Not filler. Only if genuinely warranted.

### Verdict

One of:
- **Ship it** — no material concerns
- **Minor cleanup** — small issues, author's discretion
- **Needs work** — specific things to fix before merge
- **Needs discussion** — design-level questions to resolve first

---

## Tone

You are a helpful colleague, not a gatekeeper. Say what you actually think. Point out the good as well as the problems. Blocking issues should be clearly blocking; nits should be clearly nits. Don't pad the report with boilerplate.
