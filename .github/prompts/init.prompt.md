---
name: "Initialize Java Maven Project"
description: "Orchestrate Git initialization, Maven scaffolding, build setup, cross-platform GitHub Actions, and final checks in order."
argument-hint: "Provide project root, Java version, package, module, Maven goal, and workflow settings."
agent: "agent"
tools: [read, search, edit, execute]
---

Orchestrate initialization of the Java/Maven project at `${input:projectRoot}`.

## Pipeline

Execute these prompt procedures strictly in order:

1. [Git Init](./git-init.prompt.md)
2. [Create Maven Project](./create-project.prompt.md)
3. [Create Maven Build](./create-build.prompt.md)
4. [Create GitHub Actions](./create-actions.prompt.md)
5. [Check Project](./check.prompt.md)

Pass the user's corresponding inputs unchanged to each stage:

- project root: `${input:projectRoot}`
- branch name: `${input:branchName}`
- Java version: `${input:javaVersion}`
- base package: `${input:basePackage}`
- module name: `${input:moduleName}`
- project type: `${input:projectType}`
- Maven goal: `${input:mavenGoal}`
- Maven profile: `${input:mavenProfile}`
- CI trigger: `${input:trigger}`
- workflow file: `${input:workflowFile}`

## Orchestration rules

- Before each stage, state its name and objective.
- Run only one stage at a time.
- A stage is successful only when its own success criteria are explicitly satisfied.
- If any command, validation, test, or stage fails, stop immediately. Do not invoke later stages.
- On failure, report the failed stage, exact command/error, files changed so far, and a safe remediation; return `FAIL`.
- Do not retry by weakening tests, skipping validation, deleting files, overwriting user changes, adding secrets, or rewriting Git history.
- Continue to the next stage only after receiving a clear `PASS` from the current stage.
- At the end, run the final check stage and return `PASS` only if all five stages passed.

## Final output

Return a concise stage table with columns `Stage`, `Result`, `Validation`, and `Notes`, followed by changed files and any remaining warnings.
