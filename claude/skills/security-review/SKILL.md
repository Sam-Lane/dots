---
name: security-review
description: Perform a security review of code changes against OWASP Top 10, CWEs, and common vulnerability patterns. Use when the user asks for a security review, vulnerability scan, security audit, OWASP check, or when reviewing code that handles authentication, authorisation, user input, crypto, sessions, file access, or external calls. Also invoke proactively after writing or modifying security-sensitive code (auth flows, input handling, SQL queries, file I/O, secret management, deserialisation). Arguments: optional branch/diff target (defaults to unstaged changes).
version: 1.0.0
user-invocable: true
allowed-tools:
  - Bash
  - Glob
  - Grep
  - Read
  - Agent
---

# Security Review

You are performing a targeted security review. Your goal is high signal, low noise: every finding you report must be real, exploitable, and clearly explained. False positives waste the engineer's time and erode trust, so if you are not confident a vulnerability is genuine, do not report it.

**Arguments:** `$ARGUMENTS` (branch or diff target — default to unstaged + staged changes if empty)

---

## Phase 1 — Scope the Review

Determine what changed:

```bash
# Prefer a specific target if $ARGUMENTS is set
git diff $ARGUMENTS 2>/dev/null || git diff HEAD  # staged + unstaged if no target
git diff --name-only $ARGUMENTS 2>/dev/null || git diff --name-only HEAD
```

If no git context exists, ask the user which files or directories to review.

Note the language(s), frameworks, and entry points visible in the diff. This shapes which vulnerability classes are in scope — skip inapplicable ones rather than generating noise.

---

## Phase 2 — Vulnerability Analysis

Work through each OWASP Top 10 (2021) category that is relevant to the changed code. For a full checklist and CWE mappings, read `references/owasp-checklist.md`.

For each category, read the actual code — do not guess from filenames alone. Trace data flow: follow user-controlled input from entry point (request param, env var, file, message queue) through to every sink (query, command, template, serialiser, log).

### Key categories to check (adapt to stack)

| # | Category | Watch for |
|---|---|---|
| A01 | Broken Access Control | Missing ownership checks, IDOR, privilege escalation, insecure direct object refs |
| A02 | Cryptographic Failures | Weak algorithms (MD5, SHA1, DES), hardcoded keys/secrets, cleartext sensitive data, insecure TLS config |
| A03 | Injection | SQL, NoSQL, OS command, LDAP, XPath, template injection — any unsanitised input reaching a sink |
| A04 | Insecure Design | Business logic flaws, missing rate limiting, predictable tokens |
| A05 | Security Misconfiguration | Debug mode on, permissive CORS, verbose error responses, default creds, unnecessary features enabled |
| A06 | Vulnerable Components | Outdated deps with CVEs — run `npm audit`, `pip-audit`, `bundle audit`, `trivy`, or read manifests |
| A07 | Auth / Session Failures | Weak passwords accepted, no brute-force protection, insecure session tokens, missing MFA |
| A08 | Data Integrity Failures | Insecure deserialisation (`pickle`, `yaml.load`, `ObjectInputStream`), unsigned updates |
| A09 | Logging / Monitoring | Sensitive data in logs, missing security event logging, log injection |
| A10 | SSRF | User-controlled URLs fetched server-side without allowlist |

Also check:
- **Path traversal** — user input reaching `open()`, `fs.readFile`, `File()`, etc.
- **XSS / CSRF** — unescaped output in HTML, missing CSRF tokens (web targets)
- **Secret exposure** — secrets in source, `.env` committed, secrets in logs or error messages
- **Insecure randomness** — `Math.random()`, `random.random()` used for tokens or IDs

---

## Phase 3 — False Positive Reduction

Before reporting a finding, apply these checks. This is the most important phase.

**For each candidate finding, ask:**

1. **Is there mitigation elsewhere?** Check if there is an ORM, prepared statement, template engine auto-escaping, or framework-level sanitiser that neutralises the risk before it reaches the vulnerable code path. Read the surrounding code, not just the flagged line.

2. **Is user input actually reachable?** Trace the data flow end-to-end. If the "tainted" value only ever comes from a trusted internal config or another server-controlled source, downgrade or drop the finding.

3. **Would this be exploitable in practice?** Consider authentication requirements, network exposure, and whether the attacker can actually control the relevant input with sufficient precision.

4. **Is this a known-safe pattern?** E.g., a UUID used as a token looks "predictable" but is cryptographically acceptable for session IDs in most contexts. Don't flag correct usage of well-known libraries.

5. **Confidence score (0–100):**
   - 90–100: Clear vulnerability, exploitable, code read confirms taint flow end-to-end
   - 70–89: Likely vulnerable; some assumptions required but low likelihood of false positive
   - 50–69: Possible issue; context is ambiguous — note it as "Needs review" only
   - < 50: Probable false positive — do not report

**Only report findings with confidence ≥ 70.** Mention "Needs review" items separately if relevant.

---

## Phase 4 — PoC Plan (for High/Critical findings)

For every finding with confidence ≥ 85 and severity High or Critical, write a short **Proof of Concept Plan**. This is not working exploit code — it is a step-by-step description that a developer can use to verify the vulnerability is real before committing to a fix.

Structure each PoC plan as:

```
### PoC: [Finding ID] — [Vulnerability Name]

**Prerequisite:** What the tester needs (account type, network access, tooling)
**Step 1:** ...
**Step 2:** ...
**Expected outcome:** What happens if the vulnerability is real
**Distinguishing signal:** How to tell success from failure / false positive
**Remediation sketch:** One-paragraph fix direction
```

Keep PoC plans factual and minimal. They exist to help the engineer reproduce the issue, not to weaponise it.

---

## Phase 5 — Report

Use this exact structure:

```
# Security Review — [date]

## Scope
- Target: [branch/files]
- Language / framework: [...]
- OWASP categories checked: [list]
- Categories skipped (not applicable): [list with reason]

## Critical Findings (confidence ≥ 90)
[findings with PoC plans]

## High Findings (confidence 85–89)
[findings with PoC plans]

## Medium Findings (confidence 70–84)
[findings, no PoC plan required but remediation sketch required]

## Needs Review (confidence 50–69)
[brief notes on ambiguous items; engineer should confirm before acting]

## Dependency Scan
[output of npm audit / pip-audit / etc., summarised]

## No Issues Found In
[OWASP categories that were checked and passed cleanly]

## Summary
[2–3 sentences: overall risk posture and recommended first action]
```

### Finding format

Each finding entry:

| Field | Content |
|---|---|
| **ID** | SEC-NNN |
| **CWE** | CWE-XXX — name |
| **Severity** | Critical / High / Medium / Low |
| **Confidence** | NN/100 |
| **Location** | `file.ext:line` |
| **Description** | What is wrong and why it is exploitable |
| **Evidence** | The specific code snippet or config value that confirms it |
| **Fix** | Concrete remediation (code snippet where possible) |

---

## Behaviour notes

- Read the full OWASP checklist reference when you need detailed CWE numbers or stack-specific patterns: `references/owasp-checklist.md`
- Prefer `grep` / `Glob` to locate all instances of a pattern across the codebase, not just the diff — a sink may be called from many places
- Run dependency audit tools if a package manifest changed; include raw output verbatim then summarise
- If the codebase has a `CLAUDE.md` or `SECURITY.md`, read it first — project-specific controls may affect what is and isn't a finding
- Never report a vulnerability you cannot point to with a specific file and line
