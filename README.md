# Варіант 5 — Java / Maven / JUnit 5

Цей проєкт містить набір Copilot customizations для поетапної підготовки Java/Maven-проєкту:

- custom agent [Build Engineer](./.github/agents/build-engineer.agent.md);
- skills для структури, Maven build/test і GitHub Actions;
- prompts для ініціалізації Git, створення Maven-проєкту, налаштування build, CI та фінальної перевірки;
- оркестратор [init.prompt.md](./.github/prompts/init.prompt.md), який запускає етапи послідовно.

## Передумови

- Visual Studio Code з GitHub Copilot та підтримкою workspace prompt/skill files;
- встановлені Java і Maven або Maven Wrapper (`mvnw` / `mvnw.cmd`);
- доступ до Maven repositories для завантаження залежностей;
- відкритий у VS Code корінь цього проєкту.

## Запуск агента

### Повний сценарій

1. Відкрийте папку проєкту у VS Code.
2. Відкрийте Copilot Chat.
3. Виберіть prompt `/init` — **Initialize Java Maven Project**.
4. Передайте параметри:
   - корінь проєкту;
   - назву гілки;
   - версію Java;
   - базовий package;
   - назву модуля і тип проєкту;
   - Maven goal, наприклад `verify`;
   - Maven profile, якщо потрібен;
   - trigger для CI;
   - назву workflow-файлу.
5. Підтвердьте виконання команд і перегляньте звіт кожного етапу.

Оркестратор виконує такий порядок:

```text
git-init
  -> create-project
  -> create-build
  -> create-actions
  -> check
```

Наступний етап запускається лише після успішного завершення попереднього. При першій помилці workflow зупиняється і повертає назву етапу, команду, помилку та безпечний наступний крок.

### Запуск окремого етапу

За потреби можна запускати prompts окремо:

| Prompt | Призначення |
|---|---|
| [`git-init`](./.github/prompts/git-init.prompt.md) | Ініціалізація або перевірка Git і `.gitignore` |
| [`create-project`](./.github/prompts/create-project.prompt.md) | Стандартна структура Java/Maven і JUnit 5 |
| [`create-build`](./.github/prompts/create-build.prompt.md) | `pom.xml`, компіляція, тести та packaging |
| [`create-actions`](./.github/prompts/create-actions.prompt.md) | CI matrix для Linux, Windows і macOS |
| [`check`](./.github/prompts/check.prompt.md) | Фінальна перевірка проєкту |

Для Maven-роботи можна вибрати агента [Build Engineer](./.github/agents/build-engineer.agent.md), який спеціалізується на `pom.xml`, залежностях, тестах і діагностиці build failures.

## Перевірка результату

Мінімальні локальні команди:

```powershell
mvn -B -ntp validate
mvn -B -ntp test
mvn -B -ntp verify
```

Якщо в проєкті є Maven Wrapper, використовуйте `.\mvnw.cmd` у Windows:

```powershell
.\mvnw.cmd -B -ntp validate
.\mvnw.cmd -B -ntp verify
```

Очікувані результати:

- Java-код компілюється;
- JUnit 5 тести знаходяться та виконуються;
- звіти тестів створюються в `target/surefire-reports/`;
- workflow містить runner-и `ubuntu-latest`, `windows-latest` і `macos-latest`;
- невдала перевірка завершується ненульовим кодом.

## Безпечні обмеження

Автоматизація не повинна:

- видаляти файли або перезаписувати непов’язані зміни;
- додавати credentials, токени, приватні ключі чи connection strings;
- пропускати тести через `-DskipTests` або `-Dmaven.test.skip=true`;
- використовувати `continue-on-error` для приховування CI failure;
- виконувати force push або переписувати Git-історію.

Детальна схема компонентів і передачі даних описана в [`docs/architecture.md`](./docs/architecture.md).

