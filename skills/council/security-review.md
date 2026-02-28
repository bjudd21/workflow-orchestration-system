# Skill: Security Review

This document provides the Security Reviewer agent with a threat modeling methodology, security requirements checklist, attack surface analysis framework, and compliance-aware review patterns for PRD assessment.

---

## Threat Modeling Methodology (STRIDE)

Apply STRIDE to each significant component in the PRD's architecture before writing findings. This structures the review so no threat category is missed.

| Threat | Applies To | Key Questions |
|--------|-----------|--------------|
| **Spoofing** | Authentication | Can an attacker impersonate a legitimate user, service, or system? Is identity verified at every trust boundary? |
| **Tampering** | Data integrity | Can data be modified in transit or at rest without detection? Are checksums or signatures used for critical data? |
| **Repudiation** | Audit logging | Can a user deny performing an action? Is every sensitive action logged with attribution, timestamp, and IP? |
| **Information Disclosure** | Authorization, encryption | Can unauthorized users read data they shouldn't? Is sensitive data masked in logs, APIs, and UI? |
| **Denial of Service** | Rate limiting, resilience | Can the system be made unavailable by flooding it? Are rate limits and circuit breakers present? |
| **Elevation of Privilege** | Authorization | Can a user gain capabilities beyond what they're authorized for? Are authorization checks at the API layer, not just the UI? |

**For each PRD component, ask**: Which STRIDE threats apply? Does the PRD require mitigations?

---

## Security Requirements Checklist

### Authentication (Who You Are)

| Requirement | Priority | Notes |
|-------------|----------|-------|
| All users must authenticate before accessing protected resources | CRITICAL | If absent from PRD, flag CRITICAL |
| Passwords meet minimum complexity: 12+ chars, common password rejection | HIGH | Reference NIST 800-63B Memorized Secrets |
| Multi-factor authentication (MFA) required for privileged/admin accounts | HIGH | Required for all FISMA systems; recommended for any sensitive system |
| MFA required for all user accounts (not just admin) | MEDIUM | Depends on sensitivity of data |
| Account lockout after N failed attempts | HIGH | Specify N (recommend 5-10) and lockout duration (15+ min or until reset) |
| Password reset via secure out-of-band channel | HIGH | Email link with expiry, not security questions |
| Session invalidation on password change | HIGH | Old sessions must expire immediately |
| Brute force protection on auth endpoints | HIGH | Rate limiting, CAPTCHA, or account lockout |

### Authorization (What You Can Do)

| Requirement | Priority | Notes |
|-------------|----------|-------|
| Authorization enforced at API/service layer, not only in UI | CRITICAL | UI is client-controlled; never trust it for authz |
| Role-based or attribute-based access control defined | HIGH | Who can do what must be explicit in PRD |
| Principle of least privilege: default deny | HIGH | Users receive only the permissions they need |
| Privilege escalation paths are explicit and audited | HIGH | Admin promotion, role assignment must be logged |
| Horizontal access control: users cannot access other users' data | CRITICAL | Most common IDOR vulnerability |
| Service-to-service authentication | MEDIUM | Internal APIs should not be unauthenticated |

### Data Classification & Handling

| Data Sensitivity | Required Controls |
|-----------------|------------------|
| **Public** | No special handling required |
| **Internal / Non-Sensitive** | Access control; no public exposure |
| **Sensitive PII** (name, email, address) | Encrypt in transit; access logging; breach notification plan |
| **High-Sensitivity PII** (SSN, financial, health) | Encrypt at rest AND in transit; field-level masking in UI and logs; strict access control; audit log every access |
| **Credentials / Secrets** | Never stored in plaintext; hashed (passwords: bcrypt/Argon2; never MD5/SHA1); secrets manager for API keys |
| **CUI / Classified-adjacent** | NIST 800-171/800-53 controls; data handling rules apply |

### Encryption

| Surface | Standard |
|---------|---------|
| Data in transit | TLS 1.2 minimum; TLS 1.3 preferred; no SSLv3 or TLS 1.0/1.1 |
| Data at rest (sensitive) | AES-256 or equivalent; key management solution |
| Password storage | bcrypt (cost ≥12), Argon2id, or scrypt — never MD5/SHA/reversible |
| API keys / secrets | Secrets manager (AWS Secrets Manager, Vault, Doppler) — never .env in source control |
| Cookies | HttpOnly; Secure; SameSite=Strict or Lax |
| Signed tokens (JWT) | RS256 or ES256; never HS256 with weak shared secret; expiry required |

### Input Validation

| Input Type | Required Validation |
|-----------|-------------------|
| All user-supplied text | Validate length, character set, format before processing |
| File uploads | Validate type (magic bytes, not extension); scan for malware; enforce size limit |
| Numbers | Min/max range validation; integer overflow protection |
| Dates | Range validation; canonical format |
| URLs | Allowlist protocols (https only); SSRF protection for server-side fetches |
| SQL/query inputs | Parameterized queries or ORM — never string concatenation |
| HTML output | Context-aware output encoding (XSS prevention) |
| Redirects | Allowlist or validate target; open redirect vulnerability |

### Audit Logging

| Event | Must Log |
|-------|---------|
| Authentication | Login (success/failure), logout, MFA events, lockout |
| Authorization | Access denied events, privilege escalation |
| Data access | Read of sensitive records (PII, financial, health) |
| Data modification | Create, update, delete of any persistent data — log who, when, what changed, from what value to what value |
| Admin actions | Any action performed by an admin account |
| Security events | Password reset, MFA enrollment/removal, account suspension |
| System events | Service start/stop, configuration changes |

**Log requirements:**
- Logs must include: timestamp (UTC), user ID, IP address, action, resource, outcome
- Logs must NOT include: passwords, full credit card numbers, SSNs, session tokens
- Log integrity: write-once or append-only with tamper detection
- Retention: per compliance requirement (NIST 800-53 AU-11: 3 years for Moderate; many contracts require 7 years)

### Secrets Management

- [ ] Application secrets (DB passwords, API keys, certs) stored in secrets manager, not environment files
- [ ] Secrets rotated on schedule (90 days for non-rotated credentials, or automated rotation)
- [ ] Leaked secrets invalidated within 24 hours (rotation + audit)
- [ ] No secrets in version control, logs, or error messages
- [ ] Service accounts use least-privilege credentials with no shared accounts

---

## Attack Surface Analysis

### Exposure Inventory

For each exposed surface, assess:

| Surface | Who Can Reach It? | Authentication Required? | Rate Limited? |
|---------|------------------|------------------------|--------------|
| Public web UI | Anyone | Registration or login | Yes / No |
| Public API | Anyone with key | API key or OAuth | Yes / No |
| Internal API | Internal services | Service auth | Yes / No |
| Admin interface | Admins | MFA-protected | Yes / No |
| File upload endpoint | Authenticated users | Yes | Yes / No |
| Webhook endpoint | External systems | Signature validation | Yes / No |

**Rule**: The attack surface should be as small as the requirements allow. Every unauthenticated endpoint is a potential target.

### Common Attack Vectors for PRD Review

| Attack | Look For In PRD |
|--------|----------------|
| **SQL Injection** | ORM usage or parameterized queries required |
| **XSS** | Output encoding requirement; Content-Security-Policy header |
| **CSRF** | CSRF token or SameSite cookies for state-changing operations |
| **IDOR** | Authorization checks on every resource by owner |
| **SSRF** | Server-side URL fetching with allowlist |
| **Mass Assignment** | API endpoints accepting object updates must whitelist allowed fields |
| **Path Traversal** | File system access must validate paths |
| **Dependency Vulnerabilities** | Dependency scanning in CI pipeline |

---

## Security NFR Templates

When the PRD is missing security NFRs, recommend these:

```markdown
**NFR-SEC-1: Transport Security**
All communication between clients and the system shall use TLS 1.2 or higher. TLS 1.0, 1.1, and SSLv3 are not permitted.

**NFR-SEC-2: Authentication**
All user sessions shall require authentication. Session tokens shall expire after [30] minutes of inactivity and [8] hours absolute.

**NFR-SEC-3: Encryption at Rest**
All [sensitive data category] shall be encrypted at rest using AES-256 or equivalent.

**NFR-SEC-4: Audit Logging**
All user authentication events, data access events, and administrative actions shall be logged with user ID, timestamp (UTC), IP address, action performed, and outcome. Logs shall be retained for [N] years.

**NFR-SEC-5: Vulnerability Management**
Dependencies shall be scanned for known vulnerabilities as part of the CI pipeline. Critical and high-severity vulnerabilities shall be remediated within [30] days of disclosure.
```

---

## Compliance-Specific Security Checks

### FISMA / FedRAMP

When FISMA or FedRAMP applies, additionally verify:
- [ ] Impact level (Low/Moderate/High) is stated and drives control selection
- [ ] MFA required for all accounts (not just admin) at Moderate/High
- [ ] FIPS 140-2 validated cryptographic modules required at Moderate/High
- [ ] Continuous monitoring plan mentioned (monthly scanning, annual assessment)
- [ ] Plan of Action & Milestones (POA&M) process referenced for known gaps
- [ ] Privacy Impact Assessment (PIA) required if PII is collected

### HIPAA

When healthcare data applies:
- [ ] PHI explicitly identified and classified
- [ ] Business Associate Agreement (BAA) required for any vendor handling PHI
- [ ] Minimum necessary access principle explicitly stated
- [ ] Breach notification requirement (60-day HHS notification) referenced

### PCI DSS

When payment card data applies:
- [ ] Cardholder data environment (CDE) scope explicitly defined and minimized
- [ ] Tokenization or third-party payment processor used to avoid storing card data
- [ ] PCI SAQ or QSA assessment level specified

---

## PRD Review Checklist for Security Reviewer

Before writing findings:

- [ ] Is authentication explicitly required for all user-facing features?
- [ ] Is authorization defined (who can do what, enforced at API layer)?
- [ ] Is sensitive data identified and classified?
- [ ] Is encryption in transit required (TLS)?
- [ ] Is encryption at rest required for sensitive data?
- [ ] Is audit logging specified for security-relevant events?
- [ ] Is secrets management addressed?
- [ ] Are file uploads validated and scanned?
- [ ] Is the attack surface described and minimized?
- [ ] For FISMA/FedRAMP: is the impact level stated and is MFA required?
- [ ] Are there rate limiting or abuse prevention requirements?
