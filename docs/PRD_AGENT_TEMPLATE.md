# PRD Template — AI-Agent Ready

```yaml
prd_version: 1.0
product: <product name>
doc_owner: <your name>
last_updated: <YYYY-MM-DD>
status: draft|approved
tech_stack:
  client:
    - <framework>
    - <language>
    - <key libs>
  backend:
    - <services>
repositories:
  - <repo url or name>
environments:
  - name: dev
    notes: <env notes>
  - name: prod
    notes: <env notes>
```

## 1) TL;DR

* **Problem:** <one sentence>
* **Solution:** <one sentence>
* **Success metrics (3–5):**

  * M1: <metric + target>
  * M2: <metric + target>
  * M3: <metric + target>
* **Out of scope (top 3):**

  * OOS1: …
  * OOS2: …
  * OOS3: …
* **Deliverables:** D0–Dn (see Section 10)

---

## 2) Goals and Non-Goals

### Goals (MUST)

* G1: …
* G2: …
* G3: …

### Non-Goals (NOT doing in v1)

* NG1: …
* NG2: …
* NG3: …

---

## 3) Users and Key Flows

### Personas

* P1: <who + needs>
* P2: <who + needs>

### Key journeys

* J1: <step-by-step flow>
* J2: <step-by-step flow>
* J3: <step-by-step flow>

---

## 4) Functional Requirements (FR)

Write as atomic requirements with IDs. Use MUST/SHOULD/MUST NOT.

**Format**

* **FR-###**: <requirement statement>

  * **Rationale:** <why it matters>
  * **Acceptance (BDD):**

    * Given …
    * When …
    * Then …

**FR list**

* **FR-001**: …
* **FR-002**: …
* **FR-003**: …

---

## 5) Non-Functional Requirements (NFR)

Include measurable targets where possible.

* **NFR-001 (Security):** …

  * **Metric/threshold:** …
  * **How we test:** …
* **NFR-002 (Performance):** …

  * **Metric/threshold:** …
  * **How we test:** …
* **NFR-003 (Reliability):** …
* **NFR-004 (Accessibility):** …

---

## 6) Data & Contracts (No Guessing)

This section removes ambiguity for an agent.

### 6.1 Data model

List tables/collections with fields and constraints.

**<table_name>**

* `id <type> <constraints>`
* `created_at <type> <default>`
* `<field> <type> <constraints>`
* Indexes: …
* Notes: …

### 6.2 API / RPC contracts

Define endpoints/functions with schema + errors.

**<endpoint or function name>**

* **Auth:** <none|user|service-role>
* **Request:**

```json
{ "example": true }
```

* **Response (200):**

```json
{ "ok": true }
```

* **Errors:**

  * `400 <code>` — <when>
  * `401 <code>` — <when>
  * `403 <code>` — <when>
  * `404 <code>` — <when>
  * `409 <code>` — <when>

### 6.3 Permissions / security rules

* Who can read/write what (by table/resource).
* Explicit “MUST NOT” statements.
* If using row-level security, specify required policies at a high level.

---

## 7) UX Spec (Enough to build)

### Screens

1. **<Screen name>**: <purpose>
2. **<Screen name>**: <purpose>
3. …

### Navigation map

* <route> → <route> → …

### Per-screen spec (repeat)

**<Screen name>**

* **States:** loading / empty / error / success
* **Primary actions:** …
* **Validation rules:** …
* **Permissions in UI:** …
* **Copy strings (if important):** …

### Deep links (if any)

* `myapp://<path>?<params>`

---

## 8) Telemetry & Ops (Optional but recommended)

Track key events:

* `<event_name>` → `{ prop1: <type>, prop2: <type> }`
* `<event_name>` → `{ ... }`

Operational notes:

* Error handling standard: <toasts/logging/error boundary>
* Feature flags: <if any>

---

## 9) Risks, Edge Cases, Open Questions

### Risks

* R1: <risk> → <mitigation>
* R2: <risk> → <mitigation>

### Edge cases

* E1: …
* E2: …
* E3: …

### Open questions

* OQ-001: …
* OQ-002: …
* OQ-003: …

---

# 10) Deliverables Plan (Agent Build Units)

## Deliverable template (repeat for D0…Dn)

**D# — <Deliverable name>**

* **Objective:** <one sentence outcome>
* **Scope includes:** FR-###, NFR-###, Sections …
* **Out of scope:** <explicit exclusions>
* **Dependencies:** D#… / external decisions
* **Artifacts to produce (MUST):**

  * Code: <files/modules/screens/functions>
  * Contracts: <schemas/migrations/openapi>
  * Tests: <unit/integration/e2e + what>
  * Docs: <README changes / runbook>
* **Implementation constraints (MUST follow):**

  * <coding standards, patterns, libraries, folder structure>
* **Acceptance criteria (BDD):**

  * Given …
  * When …
  * Then …
* **Verification steps (copy/paste commands):**

  * `<command>`
  * `<command>`
* **Done when checklist:**

  * [ ] All acceptance criteria pass
  * [ ] Tests pass
  * [ ] Lint/typecheck pass
  * [ ] No secrets committed
  * [ ] PR summary includes: files changed + how to test