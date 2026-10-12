---
name: "Create Maven Build"
description: "Configure and verify pom.xml, Java compilation, JUnit 5, and Maven packaging."
argument-hint: "Provide the project root, Maven goal, Java version, and optional profile."
agent: "agent"
tools: [read, search, edit, execute]
---

Configure the Maven build for `${input:projectRoot}`.

## Inputs

- Java version: `${input:javaVersion}`
- Maven goal: `${input:mavenGoal}`
- Profile: `${input:mavenProfile}`
- Module: `${input:moduleName}`

## Procedure

1. Inspect parent/BOM, properties, dependencies, profiles, compiler configuration, Surefire/Failsafe, and Maven wrapper.
2. Make the smallest `pom.xml` changes needed for Java compilation and JUnit 5 discovery.
3. Preserve dependency versions and repository settings unless the requested build requires a documented change.
4. Run `${input:mavenGoal}` with batch/non-interactive flags through `.\mvnw.cmd` on Windows or `./mvnw` on Unix-like systems; do not require system Maven.
5. If the goal is successful, inspect test reports and generated artifacts under `target/`.
6. Run `.\mvnw.cmd verify` on Windows or `./mvnw verify` on Unix-like systems when the requested goal is only `test` and verification is relevant.

## Success criteria

- `pom.xml` is valid and the requested Java release is applied.
- JUnit 5 tests are discovered and executed.
- The requested Maven goal exits with code 0.
- Build/test reports identify the executed tests and no failure is hidden with `skipTests`.

## Failure handling

Stop on compilation, dependency resolution, test discovery, or test assertion failure. Report the first root-cause error, command, and affected file; do not weaken the build to force success.
