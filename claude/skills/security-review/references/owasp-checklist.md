# OWASP Top 10 (2021) — Security Review Checklist

Reference for the security-review skill. Read the relevant sections during Phase 2.

---

## A01 — Broken Access Control

**CWEs:** CWE-22 (path traversal), CWE-284 (improper access control), CWE-285 (improper authorisation), CWE-639 (IDOR), CWE-732 (incorrect permission assignment)

**Check for:**
- Routes or API endpoints reachable without authentication
- Missing ownership check: `GET /orders/{id}` returns any user's order
- Privilege escalation: user can set their own `role` field
- `../` sequences in file paths derived from user input
- CORS policy too permissive (`Access-Control-Allow-Origin: *` on credentialed endpoints)
- JWT `alg: none` accepted, or secret not validated
- Horizontal privilege: user A can view/modify user B's resources

**False positive traps:**
- Admin-only endpoints behind middleware that checks role — confirm the middleware is actually applied
- Internal-only endpoints not reachable from the public network

---

## A02 — Cryptographic Failures

**CWEs:** CWE-259 (hardcoded password), CWE-321 (hardcoded crypto key), CWE-326 (inadequate encryption strength), CWE-327 (broken algorithm), CWE-328 (weak hash), CWE-330 (insufficient randomness), CWE-916 (weak password hash)

**Check for:**
- MD5 / SHA1 used for password hashing (not just integrity checksums)
- DES, 3DES, RC4, ECB mode AES
- Hardcoded secrets: API keys, passwords, private keys in source
- Sensitive data (PAN, SSN, health data) stored or logged in plaintext
- TLS < 1.2 configured, or certificate validation disabled
- Session tokens / CSRF tokens generated with `Math.random()` or `random.random()`
- Passwords stored with unsalted or fast hash (MD5, SHA256 without bcrypt/argon2/scrypt)

**False positive traps:**
- SHA1 for git object IDs, checksums, or non-security uses is fine
- `secrets.token_urlsafe()` / `crypto.randomBytes()` are cryptographically secure — don't flag them
- Encrypted values in config files are not "hardcoded secrets" if the key is externally managed

---

## A03 — Injection

**CWEs:** CWE-77 (command injection), CWE-78 (OS command injection), CWE-79 (XSS), CWE-89 (SQL injection), CWE-90 (LDAP injection), CWE-91 (XML injection), CWE-94 (code injection), CWE-643 (XPath injection)

### SQL Injection
- String concatenation or `%s` / `format()` in SQL queries
- `WHERE id = ' + userId + '` patterns in any language
- Raw queries with unparameterised input even when using an ORM (`.raw()`, `.execute()`)

### OS Command Injection
- `subprocess.call(shell=True)` / `exec()` / `system()` with user-controlled input
- Template strings passed to shell: `` `git clone ${repo}` ``

### Template Injection (SSTI)
- User input rendered directly in Jinja2 / Twig / Handlebars / Pebble templates
- `render_template_string(user_input)` patterns

### XSS
- `innerHTML = userValue`, `document.write(userValue)`, `eval(userValue)`
- Framework auto-escaping disabled (`| safe`, `dangerouslySetInnerHTML`, `{!! !!}`)
- `v-html`, `ng-bind-html` with unescaped data

**False positive traps:**
- Parameterised queries (`?` / `:name` placeholders, prepared statements) are safe even if the query string is built dynamically
- Framework template engines escape by default — only flag if auto-escape is explicitly disabled
- `subprocess` with a list argument (no `shell=True`) is not injectable

---

## A04 — Insecure Design

**CWEs:** CWE-73 (external control of file name), CWE-183 (permissive allowlist), CWE-209 (info exposure in error), CWE-256 (plaintext storage of password), CWE-257 (storing recoverable password), CWE-840 (business logic errors)

**Check for:**
- Password reset tokens that are predictable or reusable
- No rate limiting on login, registration, password reset, or OTP endpoints
- Business logic: can a user skip payment, apply a discount twice, or place a negative-quantity order?
- Recovery flows (forgot password, OTP) that reveal whether an account exists (user enumeration)
- File upload without type/size restriction or storage outside webroot

**False positive traps:**
- Rate limiting implemented at the load balancer / API gateway level won't appear in application code

---

## A05 — Security Misconfiguration

**CWEs:** CWE-2 (environmental security), CWE-16 (configuration), CWE-209 (error info exposure), CWE-732 (incorrect permission)

**Check for:**
- `DEBUG = True` or equivalent in production config files
- Stack traces / detailed error messages exposed to users
- Default credentials left in config (`admin`/`admin`, `root`/`root`)
- Unnecessary features enabled (e.g., directory listing, unused HTTP methods)
- Permissive file permissions on sensitive files (`chmod 777`)
- Security headers missing: `Content-Security-Policy`, `X-Frame-Options`, `Strict-Transport-Security`
- S3 buckets / blob containers set to public
- XML external entity (XXE) processing enabled

**False positive traps:**
- `DEBUG` in a file clearly used only in local dev/test environments
- Verbose errors in internal-only admin panels with strong access control

---

## A06 — Vulnerable and Outdated Components

**CWEs:** CWE-1104 (use of unmaintained third-party components)

**Tools to run:**
```bash
npm audit --audit-level=high        # Node
pip-audit                           # Python
bundle audit                        # Ruby
mvn dependency-check:check          # Java (OWASP plugin)
trivy fs .                          # multi-ecosystem
```

**Check for:**
- Packages with known CVEs in `package.json`, `requirements.txt`, `Gemfile.lock`, `pom.xml`, `go.sum`
- Dependencies pinned to versions with published vulnerabilities
- Direct use of libraries with known vulnerabilities (e.g., Log4Shell, Spring4Shell)

**False positive traps:**
- `npm audit` reports transitive dev-only dependencies that never reach production — mark severity accordingly
- CVEs with no exploitable path in the application's usage pattern are Low/Informational

---

## A07 — Identification and Authentication Failures

**CWEs:** CWE-287 (improper authentication), CWE-294 (replay attack), CWE-295 (certificate validation), CWE-297 (cert validation with host mismatch), CWE-384 (session fixation), CWE-521 (weak password policy), CWE-613 (insufficient session expiration)

**Check for:**
- No account lockout after repeated failed login attempts
- Passwords accepted without minimum length / complexity
- Session tokens that don't rotate after login (session fixation)
- Sessions that never expire or have excessively long TTLs
- "Remember me" tokens stored insecurely or not rotated
- Multi-factor not enforced for privileged actions
- Certificate validation disabled (`verify=False`, `InsecureSkipVerify: true`)

**False positive traps:**
- Internal service-to-service tokens with short TTL and mutual TLS may intentionally skip MFA

---

## A08 — Software and Data Integrity Failures

**CWEs:** CWE-345 (insufficient verification of data authenticity), CWE-353 (missing protection against replay), CWE-426 (untrusted search path), CWE-494 (download without integrity check), CWE-502 (deserialisation of untrusted data), CWE-565 (reliance on cookies without validation)

**Check for:**
- `pickle.loads(user_data)` / `yaml.load(input)` (not `safe_load`) — arbitrary code execution
- Java `ObjectInputStream.readObject()` with untrusted data
- `eval()` / `exec()` on user-provided strings
- Updates downloaded over HTTP without hash verification
- npm install from unverified sources without lockfile
- Signed JWT signature not verified before trusting claims

**False positive traps:**
- `yaml.safe_load()` is safe — only flag `yaml.load()` without `Loader=yaml.SafeLoader`
- `pickle` on data that provably never comes from an external source

---

## A09 — Security Logging and Monitoring Failures

**CWEs:** CWE-117 (improper output neutralisation for logs), CWE-223 (omission of security-relevant information), CWE-532 (insertion of sensitive information into log file), CWE-778 (insufficient logging)

**Check for:**
- Passwords, tokens, or PII logged at any level
- Log injection: user input written to logs without newline stripping
- Failed login / access denied events not logged
- Audit trail missing for privileged actions (user deletion, role change, data export)
- Logs written to a location with world-readable permissions

**False positive traps:**
- Structured logging libraries that automatically redact sensitive keys are fine
- Debug-level logs gated behind a flag that is off in production

---

## A10 — Server-Side Request Forgery (SSRF)

**CWEs:** CWE-918 (SSRF)

**Check for:**
- Any endpoint that fetches a URL supplied by the user
- Webhooks, link previews, PDF generators, image proxies
- Internal metadata endpoints reachable: `http://169.254.169.254/` (AWS), `http://metadata.google.internal/`
- DNS rebinding: URL validated once but fetched later

**False positive traps:**
- URLs restricted to an allowlist of trusted domains (check the allowlist is strict — not just prefix match)
- Fetch to a fixed, developer-controlled URL that happens to be passed as a config value

---

## Additional Patterns (not in OWASP Top 10 but commonly critical)

### Path Traversal (CWE-22)
`open(basedir + userInput)` without `os.path.abspath` / `realpath` check against basedir.

### Insecure File Upload (CWE-434)
No MIME type or extension validation; files stored in a web-accessible directory; no size limit.

### Open Redirect (CWE-601)
`redirect(request.args['next'])` without validating the URL is relative or on an allowlist.

### Hardcoded Credentials (CWE-798)
Any literal that looks like a password, API key, or private key in source.

```
grep -rE "(password|passwd|secret|api.?key|private.?key)\s*=\s*['\"][^'\"]{6,}" .
```

### Timing Attacks (CWE-208)
`==` comparison of HMAC or token values instead of `hmac.compare_digest()` / `crypto.timingSafeEqual()`.
