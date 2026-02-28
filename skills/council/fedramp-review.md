# Skill: FedRAMP Review

This document provides the Security Reviewer agent with FedRAMP-specific review guidance: baseline requirements, shared responsibility model, continuous monitoring requirements, and P-ATO considerations.

---

## When This Skill Applies

Include FedRAMP review content when the PRD or interview mentions:
- Cloud service being provided to federal agencies
- FedRAMP Authorization (P-ATO or Agency ATO)
- Hosting on AWS GovCloud, Azure Government, Google Cloud Government, or similar
- "FedRAMP authorized" infrastructure as a dependency
- The system is a SaaS, PaaS, or IaaS offering to federal customers

FedRAMP applies to the **cloud service provider** offering the system to federal agencies. FISMA applies to the **agency** operating or using the system. Both may apply when a contractor builds a cloud system for agency use.

---

## FedRAMP Baseline Overview

| Baseline | Impact Level | Approximate Controls | Typical Use |
|---------|-------------|---------------------|-------------|
| FedRAMP Low | FIPS 199 Low | ~125 controls | Low-risk systems, no PII |
| FedRAMP Moderate | FIPS 199 Moderate | ~325 controls | Most federal cloud systems; PII permitted |
| FedRAMP High | FIPS 199 High | ~420 controls | Law enforcement, financial, emergency response |
| FedRAMP Li-SaaS | Low; streamlined | ~51 controls | Low-risk SaaS with simplified review |

---

## Shared Responsibility Model

FedRAMP explicitly divides control responsibility between the Cloud Service Provider (CSP) and the federal agency (or agency contractor). A PRD must account for which controls the platform handles and which the application must implement.

### Responsibility Categories

| Category | Definition | Example |
|---------|-----------|---------|
| **CSP Inherited** | Platform fully handles; agency cannot change it | Physical security, hypervisor patching, data center access |
| **Shared** | Platform provides mechanism; application must configure or use it correctly | Encryption (platform provides key management; application must enable encryption) |
| **Agency / Customer Configured** | Platform provides the tool; agency must configure and operate it | IAM (platform provides IAM; application must define roles correctly) |
| **Agency / Customer Implemented** | Platform provides no relevant control; application must build it | Application-level audit logging, authentication, input validation |

### PRD Review: Checking Responsibility Clarity

The PRD should not claim controls are handled that actually require application implementation. Common misunderstandings:

| Incorrect Claim in PRD | Reality |
|----------------------|---------|
| "AWS handles encryption" | AWS provides encryption at rest for storage services (if enabled), but the application must enable it and manage its own data encryption for application-level data |
| "Our cloud platform handles authentication" | Cloud IAM manages console/API access for infrastructure; application user authentication must be implemented by the application |
| "Our FedRAMP platform handles compliance" | A FedRAMP-authorized platform reduces the CSP's control burden but does not transfer agency-owned controls to the platform |
| "We inherit all security controls" | Only CSP-inherited controls are inherited; shared and customer-implemented controls remain the agency's responsibility |

---

## Key FedRAMP Technical Requirements by Control Family

### IA — Identification and Authentication

| Control | Moderate Requirement |
|---------|---------------------|
| IA-2 | Authentication required for all system access |
| IA-2(1) | MFA for privileged (admin) access to all accounts |
| IA-2(2) | MFA for non-privileged user accounts |
| IA-2(12) | PIV/CAC card acceptance (for federal employee users) |
| IA-5 | Authenticator management — password complexity, rotation, storage |
| IA-8 | Non-organizational user identification — external users must also be authenticated |

**PRD Flag**: If the system serves federal employee users and does not mention PIV/CAC card support, flag it. PIV/CAC is required for federal employee access to federal systems.

### AC — Access Control

| Control | Moderate Requirement |
|---------|---------------------|
| AC-2 | Account management — provisioning, review, disabling, removal |
| AC-3 | Access enforcement — authorization at the service/API layer |
| AC-6 | Least privilege — users get only required access |
| AC-17 | Remote access controlled and monitored |
| AC-20 | Use of external systems — authorized connection agreements |

### AU — Audit and Accountability

| Control | Moderate Requirement |
|---------|---------------------|
| AU-2 | Event logging — what events are logged |
| AU-3 | Audit record content — user ID, timestamp, type, source, outcome |
| AU-6 | Audit review and analysis — regular log review required |
| AU-9 | Protection of audit logs — restricted access, integrity protection |
| AU-11 | Audit retention — [per agency/FedRAMP: minimum 1 year online, 3 years archived] |
| AU-12 | Audit generation — system must be capable of generating required records |

### SC — System and Communications Protection

| Control | Moderate Requirement |
|---------|---------------------|
| SC-7 | Boundary protection — system perimeter defined and protected |
| SC-8 | Transmission confidentiality — TLS required for all data in transit |
| SC-8(1) | Cryptographic protection — FIPS-validated modules for TLS |
| SC-28 | Protection at rest — encryption required for sensitive information |
| SC-28(1) | Cryptographic protection at rest — FIPS-validated encryption modules |

**Important**: FedRAMP Moderate and High require **FIPS 140-2 validated cryptographic modules**. Standard TLS libraries may not be FIPS-validated by default. The PRD should acknowledge this requirement if it applies.

### SI — System and Information Integrity

| Control | Moderate Requirement |
|---------|---------------------|
| SI-2 | Flaw remediation — patch management process |
| SI-3 | Malware protection — for systems with file upload or external content |
| SI-10 | Input validation — all inputs validated |
| SI-12 | Information management — proper handling and retention |

---

## FedRAMP Authorization Path

If the PRD describes a system seeking FedRAMP authorization, the authorization path must be included:

### Path 1: Agency ATO

1. Agency selects a cloud service
2. Agency conducts its own security assessment against FedRAMP controls
3. Agency Authorizing Official (AO) grants an ATO
4. Agency may reuse this ATO for their own use only

**Timeline**: 6-18 months depending on agency processes

### Path 2: JAB P-ATO (Joint Authorization Board)

1. CSP applies to FedRAMP PMO
2. 3PO (Third-Party Assessment Organization) conducts independent assessment
3. JAB (consisting of DOD, DHS, GSA CIOs) reviews and grants P-ATO
4. P-ATO is reusable by any federal agency

**Timeline**: 12-24 months; very rigorous; requires dedicated compliance program

### Path 3: FedRAMP Ready (Preliminary)

1. CSP demonstrates baseline security posture
2. FedRAMP PMO designates system as "FedRAMP Ready"
3. Agency or JAB authorization still required for actual use

---

## Continuous Monitoring Requirements

FedRAMP authorization is not a one-time assessment. The PRD must account for ongoing obligations:

| Activity | Frequency | PRD Implication |
|---------|-----------|----------------|
| Vulnerability scanning | Monthly (network); monthly (web app) | Scanning infrastructure or third-party service required |
| Penetration testing | Annual | Budget and schedule must include pen test |
| Audit log review | Continuous or weekly | Log aggregation and review tooling required |
| Patch management | Critical: 30 days; High: 30 days; Moderate: 90 days; Low: 180 days | Patch cadence must be documented |
| Configuration management | Continuous | Deviation from baseline triggers change management |
| Incident reporting | Within 1 hour of detection to FedRAMP PMO and agency | Incident response capability required |
| Annual assessment | Annual | Subset of controls re-assessed by 3PAO |
| Monthly reporting | Monthly | Operational visibility reports to agency AO |

---

## FedRAMP-Specific PRD Findings Templates

### Finding: FIPS Cryptography Not Addressed

```
Finding: FIPS 140-2 Cryptographic Module Requirement Not Addressed
Type: Concern
Severity: HIGH
Confidence: HIGH
Description: FedRAMP Moderate/High (SC-8(1), SC-28(1)) requires FIPS 140-2 validated cryptographic modules for data in transit and at rest. Standard TLS implementations (OpenSSL, BoringSSL) may not be FIPS-validated in their default configuration. The PRD specifies TLS but does not address FIPS validation.
Recommendation: Add to NFR-[Security]: "All cryptographic operations shall use FIPS 140-2 validated modules. The selected cloud platform's FIPS-validated endpoints shall be used (e.g., AWS FIPS endpoints). Document FIPS compliance in the SSP."
```

### Finding: PIV/CAC Not Mentioned for Federal User System

```
Finding: PIV/CAC Authentication Not Addressed
Type: Concern
Severity: HIGH
Confidence: HIGH
Description: Per FedRAMP control IA-2(12) and HSPD-12, federal employee users of federal systems must be able to authenticate using PIV/CAC smart cards. The PRD describes federal agency employees as users but does not address PIV/CAC authentication.
Recommendation: Add to FR-[Authentication]: "The system shall support PIV/CAC card authentication for federal employee users via SAML 2.0 or OIDC integration with the agency's identity provider."
```

### Finding: Continuous Monitoring Not Addressed

```
Finding: FedRAMP Continuous Monitoring Requirements Not Reflected in PRD
Type: Concern
Severity: MEDIUM
Confidence: HIGH
Description: FedRAMP authorization requires ongoing monthly vulnerability scanning, annual penetration testing, and monthly operational reporting. These are operational requirements that affect the system's architecture (logging infrastructure, scanning hooks) and the project's ongoing cost. The PRD does not acknowledge these requirements.
Recommendation: Add to Section 8 (Compliance): "FedRAMP continuous monitoring requirements include [list]. The architecture shall include [logging aggregation platform, scanning integration]. Budget and operational planning shall account for annual 3PAO assessment costs."
```
