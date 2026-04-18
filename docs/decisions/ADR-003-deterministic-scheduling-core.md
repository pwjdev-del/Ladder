# ADR-003 — Deterministic Scheduling Core (no OR-Tools for v1)

**Status:** Accepted
**Date:** 2026-04-18

## Decision
The scheduling engine (§11) uses a deterministic Swift + TypeScript constraint checker. Not OR-Tools, not MiniZinc, not FET, not an external constraint solver.

AI (Gemini via the AI gateway) proposes picks and explains resolutions. The deterministic core is authoritative for conflicts, prerequisites, capacity, and period clashes. AI output is input to the core, never bypasses it.

## Why
- K-8 pilot scale is trivial (~800 students × 7 periods × ~40 sections). A handwritten pass runs in milliseconds.
- Third-party solvers are an innovation token the team cannot afford for v1.
- Spec §11.4 explicitly calls for deterministic behavior; a handwritten checker satisfies that trivially.

## Trigger to revisit
If we add high-school-scale scheduling (≥2000 students, electives × pathways × prereq DAGs), migrate to OR-Tools via a dedicated microservice. Documented here so the migration decision is explicit.
