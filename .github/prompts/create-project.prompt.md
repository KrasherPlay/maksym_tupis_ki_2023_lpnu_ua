---
name: "Create Maven Project"
description: "Create or complete a standard Java Maven project structure with JUnit 5."
argument-hint: "Provide the project root, Java version, base package, and optional module name."
agent: "agent"
tools: [read, search, edit, execute]
---

Create or complete the Java/Maven project at `${input:projectRoot}` using the `project-scaffold` skill.

## Inputs

- Java version: `${input:javaVersion}`
- Base package: `${input:basePackage}`
- Module name: `${input:moduleName}`
- Project type: `${input:projectType}`

## Procedure

1. Inspect existing `pom.xml`, Maven wrapper, source files, tests, README, and `.gitignore`.
2. Preserve existing code and user changes; create only missing standard Maven directories and files.
3. Establish `src/main/java`, `src/main/resources`, `src/test/java`, and `src/test/resources` for the selected module.
4. Ensure package paths match `${input:basePackage}` and add only the requested minimal entry point or smoke test.
5. Configure the requested Java version and JUnit 5 without unrelated dependency upgrades.
6. Run `mvn validate` or the project Maven wrapper equivalent, then run a focused test check if a test exists.

## Success criteria

- The requested Maven structure exists and package paths are consistent.
- Existing files were not deleted or overwritten.
- Maven validation succeeds.
- Any generated test is discoverable by JUnit 5.

## Failure handling

On an invalid `pom.xml`, package/version conflict, or validation failure, stop and report the first actionable error. Do not proceed to build configuration.

