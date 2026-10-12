---
name: "Check Project"
description: "Run final structural, Maven, test, and CI configuration checks for a Java project."
argument-hint: "Provide the project root and Maven verification goal."
agent: "agent"
tools: [read, search, execute]
---

Perform final verification for `${input:projectRoot}`.

## Procedure

1. Inspect `git status --short` and list the files changed by this workflow.
2. Verify expected Maven paths, `pom.xml`, JUnit 5 test sources, Maven wrapper, and `.github/workflows`.
3. Run `.\mvnw.cmd validate` and `.\mvnw.cmd ${input:mavenGoal}` on Windows, or the equivalent `./mvnw` commands on Unix-like systems. The wrapper is required.
4. Confirm test reports exist and tests were not skipped.
5. Review GitHub Actions YAML for Windows, Linux, and macOS matrix entries, correct wrapper commands, minimal permissions, and absence of secrets.
6. Report a PASS only if every check succeeds.

## Success criteria

- Structure, Maven validation, tests, packaging/verification, and CI configuration are all valid.
- No files were deleted and no unrelated changes were introduced.
- The final report lists commands, results, changed files, and any warnings.

## Failure handling

On the first failed check, stop the verification sequence, report the exact failure and remediation, and return `FAIL`. Do not claim success based on partial checks.
