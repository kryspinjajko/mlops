# Project standards (Feb 2026)

**For the AI and anyone contributing:** Follow these so we don’t introduce outdated patterns or versions.

---

## Versions and recency

- **Use the most recent stable versions** of every tool, library, and provider as of **February 2026**. When adding or updating dependencies (Terraform, providers, Python packages, Helm charts, Docker bases, etc.), look up and pin the **current latest** stable release, not old defaults.
- **Prefer 2026-era docs and examples.** When you look up how to do something (Terraform, Kubernetes, ArgoCD, MLflow, AWS, etc.), use the **latest official docs and examples from 2026**. Do not copy patterns from old tutorials, deprecated APIs, or pre-2025 examples unless there is no current alternative.
- **Avoid deprecated options.** If the official docs or tool output say something is deprecated (e.g. a Terraform backend parameter, a Helm chart value, an API flag), use the recommended replacement. Do not add or leave deprecated usage in the repo.

---

## How to apply this

- **Before adding a dependency:** Check the official registry/site for the latest stable version and compatibility (e.g. Terraform 1.14+, provider major versions, Python 3.11+).
- **When writing or updating code:** Prefer current syntax and APIs; search for “[tool] 2026” or “[tool] latest” when unsure.
- **When documenting:** Link to the current official docs; don’t reference removed or archived pages.

This file is the single source of truth for “we stay current; no outdated shit.”
