# Example: Passing Vault Validation Report

This is what a clean validation report looks like when a vault passes all checks.
The vault used in this example is the Sleep Tracker project.

```
═══════════════════════════════════════════════════
  VAULT VALIDATION REPORT
═══════════════════════════════════════════════════

  Vault:    sleep-tracker
  Path:     /Users/john/vaults/sleep-tracker
  Date:     2026-02-20 09:15

───────────────────────────────────────────────────
  STRUCTURE
───────────────────────────────────────────────────

  Folders:  6/6 required folders present
  Files:    9/9 required files present

  No structural issues found.

───────────────────────────────────────────────────
  METADATA
───────────────────────────────────────────────────

  Files checked:    12
  Files with valid metadata: 12
  Files with issues: 0

  No metadata issues found.

───────────────────────────────────────────────────
  QUALITY
───────────────────────────────────────────────────

  Empty files:      0
  Naming issues:    0
  Stale drafts:     1

  WARNING: 03_build/feature_slice_notifications.md has been in 'draft' status for 10 days (last updated 2026-02-10)

───────────────────────────────────────────────────
  RESULT
───────────────────────────────────────────────────

  Errors:    0
  Warnings:  1

  PASS — Vault is valid

═══════════════════════════════════════════════════
```

## Notes on this example

- The vault has 12 `.md` files total: 9 required plus 3 optional files in `03_build/`.
- All metadata is present and valid across every file.
- One optional file has a stale draft warning, which is informational only.
- The vault passes because there are zero errors. Warnings do not block a pass.
- `05_output/` is empty, which is perfectly acceptable.
