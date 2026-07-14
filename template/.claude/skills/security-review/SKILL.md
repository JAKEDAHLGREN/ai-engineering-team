---
name: security-review
description: Procedure for reviewing a change or diff for security issues, classifying findings by severity, and producing a clear PASS / CHANGES REQUIRED verdict. Use before any change touching auth, untrusted input, secrets, or external dependencies is declared done.
---

# Security Review

A reusable procedure — *how* to review a change for security risk. Any agent with
read access can run it; it does not belong to one identity. It turns "looks safe"
into a graded, defensible verdict.

## Steps

1. **Scope the change.** Read the diff and the surrounding code it touches. Note
   what it newly exposes: an endpoint, a query, a deserialization point, a
   credential, a dependency, a trust boundary crossed.

2. **Walk untrusted input to its sink.** For each input the change accepts, trace
   it to where it's used (DB query, shell, HTML, redirect, file path, template).
   Confirm it's validated server-side (allow-list) and encoded for that sink —
   parameterized queries, escaped output, safe redirects.

3. **Check the OWASP-class risks.** Injection (SQL/command/template), XSS, CSRF,
   SSRF, auth bypass, broken access control, insecure deserialization. For each
   relevant one, confirm the control exists and can't be bypassed at a lower layer.

4. **Check auth and access control.** Confirm the change enforces authentication
   and authorization at the server boundary, scoped to the acting user — not on the
   client and not assumed from a prior step.

5. **Check secrets and logging.** No keys, tokens, or credentials in code, config
   committed to the repo, or log lines. Confirm secrets come from the configured
   store and aren't echoed in errors or output.

6. **Audit touched dependencies.** For any added or bumped package, check for known
   vulnerabilities and whether it's maintained. Note the upgrade or mitigation path.

7. **Classify every finding: a category tag and a severity.** Tag with the exact
   strings from `.ai/organization/finding_vocabulary.md` (e.g. `[AUTH_SCOPE]`,
   `[INJECTION]`, `[SECRET_EXPOSURE]`, `[VULN_DEPENDENCY]`) — one tag per finding,
   so recurrence is detectable across rounds and features. Then grade severity:
   - **Critical / High** — exploitable: auth bypass, injection, secret exposure,
     remote code execution, broken access control. These block done.
   - **Medium** — real weakness that needs a fix but isn't directly exploitable in
     this change.
   - **Low / Info** — hardening or hygiene; record as technical debt.

8. **Report a verdict:**
   - **PASS** — no critical or high findings open. List any medium/low to track.
   - **CHANGES REQUIRED** — one or more critical/high findings. List each with the
     risk, the vulnerable location, and the specific control to add. Quote the code.

   When a work directory is in play, write the verdict to
   `{work_dir}/verdict-security.r{round}.md` using the verdict format in
   `.ai/work/README.md`, and return the path plus the one-line verdict.

## Rule
Never weaken a control to reach PASS, and never report PASS with an open critical
or high finding. A single exploitable issue means CHANGES REQUIRED — fix the code,
not the verdict.
