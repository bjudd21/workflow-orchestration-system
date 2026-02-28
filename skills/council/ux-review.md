# Skill: UX Review

This document provides the User Advocate agent with user journey validation methodology, usability heuristics adapted for PRD review, accessibility baseline checks, and user value scoring frameworks.

---

## User Journey Validation

A PRD describes features and requirements. The User Advocate's job is to reconstruct the actual user journey from those requirements and find the gaps.

### Journey Mapping Process

For each primary user persona, trace:

1. **Entry** — How does the user discover and access the system? (Direct URL, email link, SSO, app store, referral)
2. **Onboarding** — What does a first-time user encounter? Is account creation, verification, and initial setup described?
3. **Core loop** — What does the user do on a typical session? Walk through the sequence of actions.
4. **Edge cases** — What happens when something goes wrong? (Error, empty state, permission denied, timeout)
5. **Exit** — How does the user leave? (Logout, inactivity timeout, browser close) What state is preserved?

**Gap detection**: Every step in the user journey must be addressed by a requirement. Unmarked steps are implementation decisions left to developers — which means inconsistent UX.

### Journey Coverage Checklist

| Stage | Questions |
|-------|-----------|
| **Discovery** | How do users find this? Is there a public landing page, internal link, or invitation? |
| **Registration/Access** | Is the sign-up or provisioning flow specified? What verification is required? |
| **First use** | What does the user see before they've created any data? Is an empty state specified? Is there a tutorial or onboarding guide? |
| **Primary task** | Can the user complete their primary goal with the features described? Are all steps supported? |
| **Error recovery** | What does the user see when something fails? Is the error message actionable? |
| **Help & support** | Is there in-app help? What's the support path? |
| **Account management** | Can the user update their profile, change their password, manage notifications? |
| **Offboarding** | Can the user delete their account or export their data? (Required for GDPR; good practice generally) |

---

## Usability Heuristics (Adapted for PRD Review)

These are Jakob Nielsen's 10 heuristics adapted to evaluate what a PRD describes, not a live interface.

| Heuristic | What to Check in the PRD |
|-----------|-------------------------|
| **1. Visibility of system status** | Does the PRD require feedback for long operations? Loading states? Progress indicators? Success/failure confirmations? |
| **2. Match system to real world** | Does the terminology in the PRD match how users think and talk? Or is it system/developer language? |
| **3. User control and freedom** | Can users undo actions? Cancel out of flows? Are destructive actions reversible (soft delete) or confirmed before execution? |
| **4. Consistency and standards** | Does the PRD reference a design system or existing UI patterns? Is there consistency in how similar actions work? |
| **5. Error prevention** | Does the PRD describe validation before submission? Confirmation for destructive actions? Are dangerous operations separated from common ones? |
| **6. Recognition over recall** | Does the PRD require users to remember information from a previous step to complete a current step? Can they refer back? |
| **7. Flexibility and efficiency** | Are there shortcuts for power users? Keyboard shortcuts? Bulk operations? Or does every user go through the same multi-step flow? |
| **8. Aesthetic and minimalist design** | Does the PRD add features "because we might need it" without a specific user need? Every extra UI element competes for attention. |
| **9. Error messages** | Does the PRD describe error messages? Are they specific (not "An error occurred")? Do they tell the user what happened and what to do? |
| **10. Help and documentation** | For complex operations, does the PRD require in-context help? Tooltips? Documentation? |

---

## State Coverage: The Missing States

PRDs almost always describe the "happy path" (user does X, system responds with Y). They frequently omit:

| Missing State | Questions |
|--------------|-----------|
| **Empty state** | What does the user see before any data exists? A blank table? An empty list? This is the first impression for new users — it should be welcoming and guide the next action. |
| **Loading state** | For operations > 1-2 seconds, what does the user see while waiting? A spinner? Progress bar? If there's no indication, users think the system is broken. |
| **Error state** | What does the user see when an operation fails? The error must state what failed, why (if known), and what the user can do next. Generic errors ("Something went wrong") are unacceptable. |
| **Partial state** | What does the user see when data is loading in stages? Are different sections of a page loaded independently? What happens if one section fails? |
| **Offline state** | If the application requires network access, what happens when the network is lost mid-session? |
| **Permission-denied state** | When a user tries to do something they're not authorized for, do they see a clear explanation (not a blank page or a generic 403)? |
| **Expired state** | Session expired, token expired, invitation link expired — what does the user see, and is recovery straightforward? |
| **Success state** | Is the user clearly told when an action succeeds? Not every action is obviously complete (form submission, background processing). |

---

## Persona Completeness Assessment

### Persona Quality Checklist

A good persona in a PRD includes:

| Element | Good | Poor |
|---------|------|------|
| **Role** | "State agency procurement officer, responsible for vendor selection" | "User" |
| **Technical skill** | "Uses Excel and SharePoint daily; comfortable with web apps; not a developer" | Not stated |
| **Goals** | "Needs to submit RFQs and track responses without calling vendors" | "Wants to use the system" |
| **Pain points** | "Currently emails vendors individually and manually tracks responses in a spreadsheet" | Not stated |
| **Constraints** | "Uses government-issued laptop with limited browser; may be on VPN with slow connection" | Not stated |
| **Environment** | "Desktop browser (Chrome/Edge); rarely on mobile for work tasks" | Not stated |

### Secondary Persona Coverage

Systems often have users who aren't the primary audience but must be supported:

| Secondary Role | Often Forgotten |
|---------------|----------------|
| **System administrator** | Manages user accounts, roles, configurations — needs admin UI or clear API |
| **Auditor / compliance officer** | Reads audit logs, exports reports — needs read-only access and export capability |
| **Support/help desk** | Handles user issues — needs visibility into user state without full admin rights |
| **Approver / reviewer** | Reviews submissions before they proceed — needs a review queue and approve/reject workflow |
| **Supervisor / manager** | Views team activity, reports — needs aggregate views without individual data visibility violations |

### Assumed Knowledge Detection

Flag requirements that assume user knowledge:

| Assumption | Impact |
|-----------|--------|
| User knows their department code / cost center | If this is required to complete a task, where do they find it? |
| User knows file format requirements before upload | Validation should happen at upload time with a clear error, not after |
| User understands what "roles" mean in context | Role names should be described in plain language, not system labels |
| User knows to check their spam folder for verification emails | Explicit instruction should be in the UI |
| User knows keyboard shortcuts | Discoverable UI is required; shortcuts are an enhancement |

---

## Accessibility Baseline

### Section 508 / WCAG 2.1 AA Minimum Requirements

For any system with a UI, verify the PRD addresses or doesn't conflict with:

| Requirement | Check |
|-------------|-------|
| **Keyboard navigation** | All interactive elements operable without a mouse |
| **Focus management** | Keyboard focus visible at all times; modals and drawers trap focus correctly |
| **Alt text** | All images have alt text; decorative images have empty alt="" |
| **Form labels** | All form fields have programmatic labels (not just placeholder text) |
| **Color contrast** | Text meets 4.5:1 contrast ratio minimum (3:1 for large text) |
| **Color as sole conveyor** | Color coding must be supplemented by text or icon |
| **Error identification** | Errors identify the field in error with text (not just red color) |
| **Page/view titles** | Each view has a unique, descriptive title |
| **Time limits** | Users warned before session expiry with ability to extend |
| **Moving content** | Auto-playing media must be pausable |
| **Captions** | Video content must have captions |
| **Responsive layout** | Content usable at 320px wide (mobile) and at 400% zoom |

### High-Risk Features for Accessibility

Flag these features for explicit accessibility requirements in the PRD:

| Feature | Accessibility Risk |
|---------|-------------------|
| **Drag-and-drop** | Must provide keyboard-accessible alternative (e.g., buttons to move items) |
| **Data visualizations** | Must have text alternative (data table, description) |
| **Real-time updates** | Screen readers must be notified of live region updates (ARIA live regions) |
| **Custom dropdowns/selects** | Native `<select>` is more accessible; custom implementations require ARIA |
| **Multi-step wizard/form** | Progress indicator must be accessible; returning to previous step must be supported |
| **File upload** | Must accept keyboard; file type/size errors must be accessible |
| **Infinite scroll** | Must have keyboard-accessible pagination alternative |
| **Toast/notification messages** | Must be announced to screen readers (ARIA role="alert") |

---

## User Value Scoring

Use this to assess whether the PRD's features deliver proportionate user value:

For each major feature, score:

| Dimension | 1 | 2 | 3 |
|----------|---|---|---|
| **Frequency** | Used once or rarely | Used weekly | Used daily |
| **Impact** | Saves a few minutes | Saves significant time or prevents frustration | Enables task that was previously impossible |
| **User effort** | High — requires learning or many steps | Medium — familiar pattern, few steps | Low — single action, obvious |

**Score 7-9**: High-value feature — strong MVP justification
**Score 4-6**: Medium-value feature — worth including, could be deferred
**Score 1-3**: Low-value feature — question whether it belongs in MVP

Features with scores of 1-3 appearing in MVP scope are candidates for the User Advocate's findings.

---

## PRD Review Checklist for User Advocate

Before writing findings:

- [ ] Are all primary user personas described with role, skill, constraints, and goals?
- [ ] Do secondary personas (admin, auditor, approver) have at least one user story?
- [ ] Can the primary user complete their main goal with the features described?
- [ ] Are empty states, error states, and loading states specified?
- [ ] Are error messages described as actionable (not "error occurred")?
- [ ] Is the onboarding/first-use experience described?
- [ ] Are destructive actions confirmed before execution or reversible?
- [ ] Is accessibility mentioned? Are any high-risk features present without accessibility requirements?
- [ ] Does the PRD require users to recall information from previous steps without support?
- [ ] Are there features that assume user knowledge not provided by the system?
