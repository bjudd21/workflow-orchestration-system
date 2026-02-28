# Skill: FISMA Compliance Check

This document provides the Security Reviewer agent with FISMA-specific review guidance: control family checklist, impact level assessment, and inherited vs. system-specific control identification.

---

## When This Skill Applies

Include FISMA review content when the PRD or interview mentions:
- Federal government agency as the deploying or operating organization
- Federal agency as the primary user or data owner
- "ATO" (Authority to Operate) — any mention requires FISMA context
- NIST 800-53 — the control catalog for FISMA
- FedRAMP (both FISMA and FedRAMP may apply if a cloud service is used by federal agencies)
- CUI (Controlled Unclassified Information) — triggers FISMA for the system handling it

---

## Impact Level Assessment (FIPS 199)

Before assessing controls, the system must be categorized. The PRD should state this; if it doesn't, flag it.

### Categorization Formula

Each information type is assessed for Confidentiality (C), Integrity (I), and Availability (A):
- **Low**: Loss would have limited adverse effect
- **Moderate**: Loss would have serious adverse effect
- **High**: Loss would have severe or catastrophic effect

The overall system categorization is the **high watermark** across all three:

| System Category | C | I | A |
|----------------|---|---|---|
| Low | Low | Low | Low |
| Moderate | Moderate (or any Mod) | — | — |
| High | High (any) | — | — |

### Common Federal System Categories

| System Type | Typical Category |
|-------------|----------------|
| Internal HR / employee portal | Low |
| Benefits payment system | Moderate |
| Citizen-facing tax or benefits portal | Moderate |
| Law enforcement records | High |
| Emergency response systems | High |
| Healthcare records (federal) | Moderate-High |
| Financial management system | Moderate-High |

---

## NIST 800-53 Control Family Review

NIST 800-53 Rev 5 defines 20 control families. For PRD review, focus on the families most likely to require engineering decisions.

### Engineering-Relevant Control Families

| Family | Code | PRD Check |
|--------|------|-----------|
| **Access Control** | AC | Is role-based access control defined? Are privileged actions restricted? Is least privilege stated? |
| **Audit and Accountability** | AU | Are security events logged? Log retention stated? Tamper-evident? |
| **Identification and Authentication** | IA | Is authentication required? MFA for privileged accounts? Password complexity? |
| **System and Communications Protection** | SC | TLS required? Boundary protection? Session management? |
| **System and Information Integrity** | SI | Malware protection for file uploads? Input validation? Patch management? |
| **Configuration Management** | CM | Baseline configuration required? Configuration change control? |
| **Incident Response** | IR | Incident reporting requirements? RTO/RPO? |
| **Contingency Planning** | CP | Backup requirements? Recovery testing? |
| **Risk Assessment** | RA | Vulnerability scanning? Penetration testing? |
| **Supply Chain Risk Management** | SR | Third-party component vetting? Open-source dependency management? |

### Minimum Controls by Impact Level

**Low Baseline (NIST 800-53B)**
- AC-2 (Account Management), AC-3 (Access Enforcement), AC-17 (Remote Access)
- AU-2 (Event Logging), AU-3 (Content of Audit Records), AU-12 (Audit Record Generation)
- IA-2 (Identification and Authentication), IA-5 (Authenticator Management)
- SC-8 (Transmission Confidentiality — TLS), SC-28 (Protection of Information at Rest for sensitive data)
- SI-3 (Malware Protection — if applicable), SI-10 (Input Validation)

**Moderate Baseline (adds to Low)**
- AC-2 (enhanced: automated provisioning/deprovisioning)
- AU-6 (Audit Review and Reporting — regular review required)
- IA-2(1) (MFA for privileged accounts), IA-2(2) (MFA for non-privileged accounts)
- SC-28(1) (Cryptographic protection at rest)
- SI-7 (Software and Firmware Integrity Verification)
- RA-5 (Vulnerability Scanning — quarterly minimum)

**High Baseline (adds to Moderate)**
- AC-2(2) (Automated account removal/disabling), AC-6(1) (Least privilege — automated enforcement)
- AU-9 (Protection of Audit Information — restricted access to logs)
- IA-2(1) and IA-2(2) (MFA required for all users — not just privileged)
- SC-8(1) (TLS with FIPS-validated cryptography)
- IR-6 (Incident reporting to authority within timeframe)

---

## Inherited vs. System-Specific Controls

A key FISMA concept is control inheritance — many controls are provided by the cloud platform or enterprise infrastructure and the system does not need to re-implement them.

### Common Inherited Controls (Cloud Platform)

When the system runs on a FedRAMP-authorized cloud platform (AWS GovCloud, Azure Government, Google Cloud Government):

| Control Family | Often Inherited From Cloud |
|---------------|--------------------------|
| Physical protection (PE) | Fully inherited — data center security is the CSP's responsibility |
| Media protection (MP) | Partially inherited — storage encryption at rest |
| Personnel security (PS) | Partially inherited — background checks for CSP staff |
| Configuration management (CM) | Partially inherited — hypervisor and host OS patching |
| Incident response (IR) | Partially inherited — CSP reports infrastructure incidents; agency investigates application incidents |

### Always System-Specific Controls

These controls cannot be inherited — the application must implement them:

| Control | Why It Cannot Be Inherited |
|---------|--------------------------|
| AC-2 (Account Management) | The application manages its own user accounts and roles |
| AC-3 (Access Enforcement) | Application enforces its own authorization logic |
| AU-2/AU-3 (Audit Logging) | Application generates its own audit events |
| IA-2 (Authentication) | Application authenticates its own users |
| SI-10 (Input Validation) | Application validates its own inputs |
| SC-8 (Transmission Confidentiality) | Application configures its own TLS settings |

---

## ATO Process Considerations for PRD Review

If the PRD describes a system requiring ATO, the PRD should account for:

| ATO Activity | Timeline Impact | PRD Requirement |
|-------------|----------------|----------------|
| Security categorization | 1-2 weeks | State FIPS 199 category in PRD |
| System Security Plan (SSP) | 4-8 weeks | Document controls in SSP (not PRD, but PRD must be complete enough to write the SSP) |
| Security Assessment | 4-8 weeks | Vulnerability scanning, pen test, control assessment |
| POA&M creation | 1-2 weeks | Document any gaps and remediation plans |
| ATO decision | 2-4 weeks | Authorizing Official (AO) review |
| **Total (new system)** | **4-6 months minimum** | PRD timeline must account for this |

**Flag in PRD review** when:
- An ATO is required and the timeline doesn't include 4-6 months for the authorization process
- A Continuous ATO (cATO) is claimed without evidence the system qualifies
- No ISSO is identified (required for ATO process to begin)
- The PRD states the system will process High-impact data but no ATO plan is mentioned

---

## FISMA-Specific PRD Findings Templates

### Finding: Missing Impact Level

```
Finding: FISMA Impact Level Not Stated
Type: Concern
Severity: HIGH
Confidence: HIGH
Description: The PRD does not state a FIPS 199 security categorization. All federal systems must be categorized before an ATO can proceed, and the categorization drives which control baseline applies (Low/Moderate/High). Without this, it is impossible to assess whether the stated security requirements are sufficient.
Recommendation: Add to Section 8: "This system is categorized [Low/Moderate/High] under FIPS 199. Categorization rationale: [brief justification]."
```

### Finding: MFA Not Required for Moderate/High System

```
Finding: MFA Absent for [Moderate/High]-Impact System
Type: Concern
Severity: CRITICAL
Confidence: HIGH
Description: NIST 800-53 IA-2(1) requires MFA for privileged account access at Moderate baseline. IA-2(2) requires MFA for non-privileged accounts at Moderate baseline. The PRD does not include MFA as a requirement. For a system categorized [Moderate/High], this is a control gap that will prevent ATO.
Recommendation: Add to FR-[Authentication]: "All user accounts shall require multi-factor authentication. Acceptable second factors: authenticator app (TOTP), hardware security key (FIDO2), or agency-approved PIV/CAC card."
```

### Finding: Audit Retention Not Stated

```
Finding: Audit Log Retention Period Not Specified
Type: Concern
Severity: HIGH
Confidence: HIGH
Description: NIST 800-53 AU-11 requires audit log retention to be specified. At Moderate baseline, logs must be retained for a minimum of [3 years / per agency policy]. The PRD references audit logging but does not state a retention period.
Recommendation: Add to NFR-[Security]: "Audit logs shall be retained for [N] years in accordance with [agency records schedule / NIST 800-53 AU-11]. Logs shall be stored in a system separate from the application and protected against modification."
```
