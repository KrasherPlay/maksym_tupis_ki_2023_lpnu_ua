---
name: "Create GitHub Actions"
description: "Create a cross-platform GitHub Actions CI workflow for Java Maven and JUnit 5."
argument-hint: "Provide the project root, Java version, Maven goal, and workflow trigger."
agent: "agent"
tools: [read, search, edit, execute]
---

Create or update the GitHub Actions workflow for `${input:projectRoot}`.

## Inputs

- Java version: `${input:javaVersion}`
- Maven goal: `${input:mavenGoal}`
- Trigger: `${input:trigger}`
- Workflow file: `${input:workflowFile}`

## Procedure

1. Inspect existing workflows, `pom.xml`, Maven wrapper scripts, Java version, and module layout.
2. Create `.github/workflows/${input:workflowFile}` with the requested trigger and a matrix for `ubuntu-latest`, `windows-latest`, and `macos-latest`.
3. Use pinned major action versions for checkout and setup-java, `contents: read`, Maven dependency caching, and the project wrapper where available.
4. Use platform-correct wrapper commands: `./mvnw` on Unix-like runners and `.\mvnw.cmd` on Windows.
5. Run the same non-skipping Maven goal on every runner and preserve failure status.
6. Validate YAML structure and locally run the equivalent Maven command.

## Success criteria

- Workflow YAML parses and contains all three requested OS runners.
- Java setup, Maven cache, wrapper invocation, and JUnit 5 execution are configured.
- No credentials, tokens, private keys, or hard-coded secrets are present.
- CI failures cannot be converted into success with `continue-on-error`.

## Failure handling

If YAML, wrapper invocation, matrix configuration, or local Maven validation fails, stop and report the failing step. Do not continue to final verification or modify unrelated workflows.

