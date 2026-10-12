# Архітектура агента — Варіант 5

## 1. Призначення

Набір customizations автоматизує підготовку Java/Maven/JUnit 5 проєкту та його CI. Архітектура розділяє:

1. рольового агента для build-операцій;
2. skills із повторюваними правилами;
3. атомарні prompts для окремих етапів;
4. prompt-оркестратор, який координує порядок і зупинку при помилці.

## 2. Структура каталогів

```text
.github/
├── agents/
│   └── build-engineer.agent.md
├── prompts/
│   ├── git-init.prompt.md
│   ├── create-project.prompt.md
│   ├── create-build.prompt.md
│   ├── create-actions.prompt.md
│   ├── check.prompt.md
│   └── init.prompt.md
└── skills/
    ├── project-scaffold/SKILL.md
    ├── build-and-test/SKILL.md
    └── github-actions/SKILL.md
```

### Build Engineer

[build-engineer.agent.md](../.github/agents/build-engineer.agent.md) — спеціалізована роль для:

- `pom.xml`, dependency management і Maven plugins;
- Java compilation, JUnit 5, packaging і CI failures;
- відтворюваної діагностики;
- перевірки результатів і звітування.

Агент має інструменти читання, пошуку, редагування і виконання команд. Його обмеження забороняють видалення файлів, розкриття секретів і force push.

### Skills

Skills підвантажуються за потреби:

- [project-scaffold](../.github/skills/project-scaffold/SKILL.md) описує Maven directory layout, packages і JUnit 5 scaffold;
- [build-and-test](../.github/skills/build-and-test/SKILL.md) описує `pom.xml`, compiler/test plugins, Maven goals і діагностику;
- [github-actions](../.github/skills/github-actions/SKILL.md) описує CI matrix для Windows, Linux і macOS.

Skill не є окремим runtime-процесом: він надає агенту процедурні правила для конкретного етапу.

## 3. Потік виконання

Точка входу — [`init.prompt.md`](../.github/prompts/init.prompt.md). Оркестратор запускає етапи в такому DAG, який фактично є послідовним pipeline:

```text
START
  |
  v
git-init
  |
  v
create-project
  |
  v
create-build
  |
  v
create-actions
  |
  v
check
  |
  v
PASS
```

Кожен prompt має власні `description`, `argument-hint`, інструменти, процедуру, критерії успіху та обробку помилок. Окремий етап можна запускати вручну, але повний сценарій рекомендується запускати через `/init`.

## 4. Передача даних

Параметри вводяться один раз при запуску `/init` і передаються до відповідних prompts через `${input:...}`:

| Дані | Використання |
|---|---|
| `projectRoot` | корінь Git/Maven-проєкту та робоча директорія команд |
| `branchName` | перевірка або створення назви Git-гілки без переписування історії |
| `javaVersion` | compiler release, `setup-java` і сумісність Maven |
| `basePackage` | package declaration і шлях Java-класів |
| `moduleName` | single-module або конкретний Maven-модуль |
| `projectType` | вибір структури single-module/multi-module |
| `mavenGoal` | команда `test`, `verify` або `package` |
| `mavenProfile` | необов’язковий Maven profile |
| `trigger` | `push`, `pull_request` або інший CI trigger |
| `workflowFile` | назва `.github/workflows` YAML-файлу |

Передача відбувається логічно через prompt context: оркестратор не копіює секретні значення у файли, а кожен етап використовує тільки потрібні параметри. Результатом етапу є `PASS` або `FAIL`, список змінених файлів, команди перевірки та діагностика.

## 5. Контракти етапів

### Git Init

Вхід: `projectRoot`, `branchName`.

Результат: валідний Git repository, безпечний `.gitignore`, збережені existing changes і успішний `git status`.

### Create Project

Вхід: `projectRoot`, `javaVersion`, `basePackage`, `moduleName`, `projectType`.

Результат: Maven directories, узгоджені package paths, JUnit 5 scaffold і успішний `validate`.

### Create Build

Вхід: `projectRoot`, `javaVersion`, `mavenGoal`, `mavenProfile`, `moduleName`.

Результат: валідний `pom.xml`, успішна компіляція, JUnit 5 discovery і заданий Maven goal.

### Create Actions

Вхід: `projectRoot`, `javaVersion`, `mavenGoal`, `trigger`, `workflowFile`.

Результат: CI workflow із `ubuntu-latest`, `windows-latest`, `macos-latest`, Java setup, cache і non-skipping Maven tests.

### Check

Вхід: `projectRoot`, `mavenGoal`.

Результат: фінальний `PASS` лише після структурної, Maven, test і CI перевірки.

## 6. Обробка помилок

Використовується fail-fast стратегія:

1. етап запускається тільки після успішного завершення попереднього;
2. перша помилка зупиняє pipeline;
3. наступні prompts не викликаються;
4. повертаються stage name, команда, перша релевантна помилка, змінені файли й remediation;
5. відновлення виконується новим запуском після виправлення, а не приховуванням проблеми.

Критичні категорії помилок:

- невалідний `pom.xml` або YAML;
- невірна Java/Maven version;
- dependency/plugin resolution failure;
- compilation або JUnit assertion/discovery failure;
- різна поведінка wrapper на Windows, Linux і macOS;
- відсутність required runner або CI configuration;
- спроба використати секрет у відкритому файлі.

Заборонені способи “виправлення”:

- `-DskipTests` і `-Dmaven.test.skip=true`;
- `continue-on-error` для приховування failure;
- broad exclusions або silent fallbacks;
- видалення файлів чи непов’язаних змін;
- force push і переписування історії;
- додавання credentials, tokens, private keys або connection strings.

## 7. Критерій завершення

Архітектурний pipeline вважається успішним, коли:

- усі п’ять етапів завершилися `PASS`;
- Maven build і JUnit 5 тести реально виконалися;
- CI workflow містить три цільові операційні системи;
- Git status і список змін перевірені;
- фінальний звіт містить результати кожного етапу, змінені файли та warnings.

