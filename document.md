# Amazon Connect Instance Sync — Project Plan
**PROD → QA Instance Sync: Pipeline & Import Utility**

| | |
|---|---|
| **Instances** | `retail-prod-ue1` → `retail-qa-ue1` |
| **Deadline** | September |
| **Status** | Active |

---

## Objective

Two parallel workstreams will run concurrently to reach the September deadline. The CICD pipeline continues bringing instance and flow resources under source control. A new scripting initiative will handle one-way sync of remaining Connect resources from the PROD instance (`retail-prod-ue1`) into the new QA instance (`retail-qa-ue1`) — covering everything not yet managed by the pipeline.

---

## Workstreams

### Track 1 — CICD Pipeline *(Continuing)*

Instance and Flows remain under source control via the existing pipeline. No changes to scope or approach. Pipeline deployments cover the core infrastructure layer across East and West regions.

**Scope:** Instances · Flows

### Track 2 — Import Utility *(New Initiative)*

A scripting utility to import Connect instance objects from one instance into another. Targets resources not ready for pipeline management. Michael compiles requirements; DevOps engineers build and operate the utility.

**Scope:** All remaining Connect resources not in the pipeline

---

## Architecture Overview

```
              East                          West
         ┌─────────────┐               ┌─────────────┐
PROD     │  TCC IVR    │ ────────────▶ │  TCC IVR    │
         │  Instance   │  Pipeline     │  Instance   │
         │retail-prod  │  Deploy       │             │
         └─────────────┘               └─────────────┘

         ┌─────────────┐               ┌─────────────┐
QA       │  TCC IVR    │ - - - - - -▶  │  TCC IVR    │
         │  Instance   │  One-Way      │  Instance   │
         │retail-prod  │  Sync (Script)│retail-qa-ue1│
         └─────────────┘               └─────────────┘
```

**Legend**
- `────▶` Pipeline Deploy
- `- - ▶` Scripted One-Way Sync
- Solid border = Existing instance
- Dashed border = New QA instance

---

## Import Utility — Core Requirements

### 1. One-Way Sync
PROD is the source of truth. Changes flow from PROD to QA only. No reverse sync or bidirectional merge.

### 2. Idempotent
Running the utility multiple times produces the same result. Safe to re-run without creating duplicates or overwriting manual QA changes unexpectedly.

### 3. Drift Report
Detects and reports differences between PROD and QA. Surfaces what has drifted so teams can review before applying changes.

---

## Resources in Scope — PROD → QA

| # | Resource |
|---|---|
| 1 | Flows (Contact, Customer Queues, etc.) |
| 2 | Flow Modules |
| 3 | Queues |
| 4 | Routing Profiles |
| 5 | Hours of Operation |
| 6 | Quick Connects |
| 7 | Prompts |
| 8 | Hierarchies |
| 9 | Agent Status |
| 10 | Security Profiles |
| 11 | Rules (Word Collection) |
| 12 | Rules |
| 13 | Evaluation Forms |

---

## Out of Scope

| Resource | Reason |
|---|---|
| ~~Users~~ | Explicitly excluded — agent/supervisor accounts are not synced |
| ~~Reverse / Bidirectional Sync~~ | PROD → QA only |

---

## Responsibilities

| Owner | Track | Deliverable |
|---|---|---|
| Michael | Import Utility | Review all Connect instance components. Compile requirements defining what to sync (e.g., queues yes, users no). Provide final resource scope to DevOps. |
| DevOps Engineers | Import Utility | Design and build the import utility based on Michael's requirements. Implement one-way sync, idempotency guarantees, and drift reporting. |
| DevOps Engineers | Pipeline | Continue pipeline work bringing Instance and Flow resources under CICD source control. No change to existing scope. |

---

## Timeline

> **September deadline.** Both workstreams must deliver concurrently. The pipeline track is ongoing; the import utility is a new initiative that must be scoped, built, and validated before end of September. Prioritise requirement sign-off from Michael early so DevOps engineering time is not blocked.
