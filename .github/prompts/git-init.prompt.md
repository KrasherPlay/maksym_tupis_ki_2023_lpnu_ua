---
name: "Git Init"
description: "Initialize or verify Git for a Java/Maven project without overwriting existing work."
argument-hint: "Provide the project root and desired default branch name."
agent: "agent"
tools: [read, search, edit, execute]
---

Initialize version control for the Java/Maven project at `${input:projectRoot}`.

## Procedure

1. Inspect the project root and determine whether it is already a Git repository.
2. Inspect existing files and working-tree state before making changes.
3. If Git is absent, run `git init` and create or update `.gitignore` with Java/Maven entries (`target/`, IDE metadata, logs, and local environment files).
4. If a repository already exists, preserve it; do not reinitialize it or discard changes.
5. Create or verify the requested default branch `${input:branchName}` only when this can be done without rewriting history.
6. Never add secrets, credentials, private keys, generated artifacts, or local configuration containing sensitive values.
7. Do not commit unless the user explicitly requests a commit.

## Success criteria

- The project is a valid Git repository.
- Existing files and uncommitted changes are preserved.
- `.gitignore` excludes Maven build output and common local-only files.
- `git status --short` completes successfully.

## Failure handling

If any command fails, stop immediately, report the command and safe remediation, and do not continue to the next pipeline stage.

