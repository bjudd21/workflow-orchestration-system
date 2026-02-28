# Skill: Government PRD Requirements

This document provides conditional guidance for projects subject to government compliance frameworks. It is injected into the PRD Writer and PRD Interviewer when the interview identifies applicable frameworks (FISMA, FedRAMP, NIST 800-171, Section 508, or similar).

---

## When This Skill Applies

Include compliance-specific PRD content when the interview identifies **any** of the following:

| Signal | Framework | Key Concern |
|--------|-----------|-------------|
| Federal agency system | FISMA | Security categorization, ATO, NIST 800-53 controls |
| Cloud service to federal agencies | FedRAMP | Authorized cloud, shared responsibility, continuous monitoring |
| Controlled Unclassified Information | NIST 800-171 | 110 security requirements, CUI handling |
| Federal accessibility requirement | Section 508 / WCAG 2.1 AA | All user interfaces, documents, and electronic content |
| DOD systems | RMF / DISA STIGs | Configuration baselines, vulnerability management |
| State/local government (varies) | Varies by state | Often mirrors FISMA at reduced scope |

---

## FISMA: Federal Information Security Modernization Act

### Security Categorization (FIPS 199)

Every federal system must be categorized before ATO can proceed. The PRD must include or reference the system's categorization:

| Impact Level | When to Use | Example |
|-------------|-------------|---------|
| **Low** | Loss of CIA would have limited adverse effect | Internal HR portal |
| **Moderate** | Loss of CIA would have serious adverse effect | Benefits payment system |
| **High** | Loss of CIA would have severe or catastrophic effect | Emergency response, law enforcement |

PRD must state: `This system is categorized [Low/Moderate/High] under FIPS 199 for Confidentiality, [Low/Moderate/High] for Integrity, [Low/Moderate/High] for Availability.`

The overall categorization is the **high watermark** (highest value across C, I, A).

### ATO Pathway

The PRD should document the path to Authority to Operate:

```markdown
## Compliance Requirements — FISMA

### Security Categorization
System FIPS 199 Category: [Low | Moderate | High]
- Confidentiality: [Low | Moderate | High] — [rationale]
- Integrity: [Low | Moderate | High] — [rationale]
- Availability: [Low | Moderate | High] — [rationale]

### ATO Status
- [ ] New ATO required
- [ ] Operating under existing ATO (expires: [date])
- [ ] ATO inherited from [parent system / platform]
- [ ] P-ATO (FedRAMP) — cloud platform: [platform name]

### Key Control Families to Implement
Based on [Low/Moderate/High] baseline (NIST 800-53):
- **AC**: Access Control — [specific requirements for this system]
- **AU**: Audit and Accountability — [logging requirements]
- **IA**: Identification and Authentication — [auth requirements]
- **SC**: System and Communications Protection — [encryption, boundary protection]
- [Additional families as applicable]

### Inherited Controls
Controls inherited from [cloud platform / enterprise services]:
- [List controls the platform provides so engineering doesn't duplicate]

### System-Specific Controls
Controls this system must implement:
- [List controls not inherited — these drive functional and technical requirements]
```

### FISMA-Driven Requirements

When FISMA applies, the PRD must explicitly require:

| Requirement | FR or NFR |
|-------------|-----------|
| Multi-factor authentication for privileged users | FR — Authentication |
| Session timeout after [N] minutes of inactivity | FR — Session Management |
| Audit logging of all user actions and admin events | FR — Audit Logging |
| Tamper-evident audit logs | NFR — Security |
| Encryption at rest for all sensitive data | NFR — Security |
| Encryption in transit (TLS 1.2+) for all communications | NFR — Security |
| Vulnerability scanning per [schedule] | NFR — Security Operations |
| Incident response capability | FR — Operations |

---

## FedRAMP: Federal Risk and Authorization Management Program

FedRAMP applies when a cloud service provider (CSP) provides cloud services to federal agencies.

### FedRAMP Baselines

| Baseline | Applies When | Approximate Control Count |
|---------|-------------|--------------------------|
| FedRAMP Low | Low impact federal systems | ~125 controls |
| FedRAMP Moderate | Moderate impact (most federal cloud) | ~325 controls |
| FedRAMP High | High impact (financial, law enforcement, classified-adjacent) | ~420 controls |

### Shared Responsibility Model

The PRD must document the shared responsibility split between the CSP and the agency:

```markdown
### Shared Responsibility Matrix (Summary)
| Control Area | CSP Responsibility | Agency Responsibility |
|-------------|-------------------|----------------------|
| Physical security | Full | None |
| Network perimeter | Shared | Application-level controls |
| OS patching | CSP-managed (PaaS/SaaS) | Agency-managed (IaaS) |
| Application code security | None | Full |
| Data classification and handling | None | Full |
| User access management | None | Full |
| Incident response | CSP notifies, provides logs | Agency investigates, reports |
```

### FedRAMP P-ATO

If the CSP has an existing FedRAMP P-ATO (Provisional Authorization), document:
- CSP name and P-ATO date
- Baseline level (Low/Moderate/High)
- Inherited controls that reduce agency implementation burden
- Any agency-responsible controls not covered by the P-ATO

---

## NIST 800-171: Protecting Controlled Unclassified Information

Applies to non-federal systems that process, store, or transmit CUI (Controlled Unclassified Information) — typically contractors, research institutions, and state/local systems handling federal data.

### CUI Categories Relevant to the Project

The PRD should identify which CUI categories the system handles:
- Privacy CUI (PII under Privacy Act)
- Law enforcement sensitive
- Controlled technical information
- Legal (attorney-client privileged)
- Financial (non-public financial information)

### 800-171 Requirement Families (14 families, 110 requirements)

PRD-relevant control families:
- **3.1 Access Control**: Limit system access to authorized users, limit access to types of transactions
- **3.3 Audit & Accountability**: Create and retain audit logs
- **3.5 Identification & Authentication**: Identify all users and authenticate before granting access; use MFA for privileged access and non-local access
- **3.13 System & Communications Protection**: Encrypt CUI in transit and at rest

The PRD must explicitly require compliance with the applicable 800-171 control families or inherit them from the organization's System Security Plan (SSP).

---

## Section 508 / WCAG 2.1 AA: Accessibility

Applies to all electronic and information technology developed, procured, maintained, or used by federal agencies, and to public-facing systems with broad public use.

### What Must Be Accessible

Per Section 508 and WCAG 2.1 AA, all user-facing interfaces must be accessible:
- Web interfaces (all pages, forms, error messages)
- Documents (PDFs must be tagged; Excel must have alt text)
- Reports and exports
- Email notifications
- Chatbots or conversational interfaces

### PRD Accessibility Requirements

The PRD must include explicit accessibility FRs, not just a note that accessibility is required:

```markdown
**FR-[N]: Accessibility Compliance**

All user-facing interfaces shall conform to WCAG 2.1 Level AA and Section 508 standards.

Acceptance Criteria:
- [ ] All images and non-text content have appropriate alt text
- [ ] All form fields have programmatic labels
- [ ] All interactive elements are keyboard-navigable without a mouse
- [ ] Color is not the sole means of conveying information (text labels or icons accompany color coding)
- [ ] Page/view titles are unique and descriptive
- [ ] Error messages identify the field in error and describe how to correct it
- [ ] VPAT (Voluntary Product Accessibility Template) is completed before launch
```

### Common 508 Failure Modes to Flag in PRD

| Feature | Accessibility Risk |
|---------|-------------------|
| Data visualizations / charts | Must have text alternatives or data tables |
| Drag-and-drop interfaces | Must have keyboard-accessible alternative |
| Modal dialogs | Must trap focus while open, return focus on close |
| Color-coded status indicators | Must include icon or text alongside color |
| Auto-playing media | Must be pausable; captions required |
| Timed sessions / timeouts | User must be warned and able to extend |
| PDFs | Must be tagged; not image-based scans |

---

## Privacy Act & PII Handling

Applies when the system stores records about individuals that are retrieved by a personal identifier (name, SSN, employee ID).

### Privacy Act Requirements in the PRD

```markdown
**FR-[N]: Privacy Act Compliance**

Systems of Records under the Privacy Act require:
- System of Records Notice (SORN) — must be published before PII is collected
- Privacy Impact Assessment (PIA) — must be completed before launch
- Data minimization — collect only PII necessary for the stated purpose
- Individual rights — users can request access to and correction of their records
```

### PII Categories and Required Controls

| PII Category | Required Controls |
|-------------|------------------|
| SSN, biometrics, financial | Encrypt at rest and in transit; mask in displays; restrict access |
| Name, address, contact | Encrypt in transit; access control |
| IP addresses, cookies | Document collection in Privacy Policy; consent where required |

---

## Compliance Section Template for PRD

When compliance applies, Section 8 of the PRD follows this structure:

```markdown
## 8. Compliance Requirements

### 8.1 Applicable Frameworks
| Framework | Applicability | Lead |
|-----------|--------------|------|
| FISMA Moderate | Federal agency system | ISSO: [name/TBD] |
| Section 508 | Federal agency + public-facing | [team] |

### 8.2 Security Categorization (FISMA)
[See FISMA section above]

### 8.3 ATO Pathway
[Timeline, inherited controls, system-specific controls]

### 8.4 Compliance-Driven Requirements
[Requirements that exist specifically to satisfy compliance, cross-referenced to FRs]

### 8.5 Open Compliance Questions
[Decisions that must be made before development: impact level confirmation, SORN status, PIA status]
```

---

## Government Contract Planning Notes

When the project is for a government contract or grant:

- **Period of Performance** should be stated in Section 7 (MVP vs. Future Phases), not just "Q3"
- **Deliverable-based milestones** may be contractually required — PRD milestones should align with contract deliverables
- **CDRLs (Contract Data Requirements Lists)** — if applicable, list what documentation must be delivered and when
- **Government-furnished equipment (GFE)** or **government-furnished information (GFI)** — document dependencies on government-provided assets that could delay the project
- **508 compliance testing** is frequently a contract deliverable, not just a best practice
