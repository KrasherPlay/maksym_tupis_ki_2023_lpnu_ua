---
name: build-and-test
description: "Use when configuring or diagnosing a Java Maven pom.xml, compiling the project, running JUnit 5 tests, packaging artifacts, or investigating build and test failures."
argument-hint: "Provide the Maven module, failing command or test, Java version, and relevant error output."
user-invocable: true
---

# Java Build and Test

## Призначення

Налаштовувати відтворювану Maven-збірку Java-проєкту та перевіряти її через JUnit 5. Основний фокус — `pom.xml`, compiler/test plugins, dependency resolution, unit tests, packaging і діагностика помилок.

## Вхідні дані

- Корінь проєкту та конкретний Maven-модуль, якщо це multi-module repository.
- `pom.xml`, Maven wrapper і профілі, якщо вони наявні.
- Цільова Java version та бажана команда (`test`, `verify`, `package` тощо).
- Опис очікуваної поведінки тестів або текст помилки.
- Обмеження CI, registry/proxy або профілі, які потрібно зберегти.

## Очікуваний результат

- Валідний `pom.xml` із сумісними Java compiler, Surefire/Failsafe та JUnit 5 налаштуваннями.
- Залежності мають визначені scopes і не дублюють dependency management.
- JUnit 5 тести запускаються стандартною Maven-командою.
- Збірка повертає ненульовий код лише при реальній помилці.
- Звіт містить команди, результати, змінені файли та невирішені проблеми.

## Кроки виконання і перевірки

1. Прочитати `pom.xml`, parent/BOM, profiles, wrapper і пов'язаний test code до редагування.
2. Перевірити Java/Maven версії та існуючі plugin management settings.
3. Внести мінімальну зміну: dependency, version, plugin configuration або test fixture; не приховувати помилку через `skipTests`.
4. Переконатися, що JUnit 5 використовує `org.junit.jupiter` imports і test engine доступний у test runtime.
5. Запустити швидку перевірку через wrapper: `.\mvnw.cmd -B -ntp test` у Windows або `./mvnw -B -ntp test` у Unix-like середовищі.
6. Для конкретного тесту використати `-Dtest=ClassName#methodName`; для integration tests не підміняти `verify` командою `test`.
7. Якщо unit tests проходять, запустити `.\mvnw.cmd -B -ntp verify` у Windows або `./mvnw -B -ntp verify` у Unix-like середовищі, і за потреби аналогічний `package`.
8. Перевірити, що артефакт зібраний у `target/`, а звіт тестів доступний у `target/surefire-reports/`.
9. Для multi-module build перевірити і модуль, і кореневий reactor build.
10. Повторно виконати найменшу команду, яка відтворювала помилку, та описати різницю до/після.

## Обробка помилок

- Compilation failure: локалізуй перший релевантний source error, перевір Java release і classpath, не маскуй його compiler exclusions.
- Dependency/plugin resolution failure: зафіксуй groupId/artifactId/version, repository/profile і мережеву помилку; не додавай неперевірені repositories.
- JUnit test failure: відокремлюй assertion failure, test discovery failure і environment failure; не змінюй тест лише для отримання green build.
- Flaky test: повтори контрольовано, зафіксуй умови відтворення і запропонуй детермінований fix.
- Не використовуй `-DskipTests`, `-Dmaven.test.skip=true` або аналогічний обхід як критерій успіху.
- Якщо проблема pre-existing або потребує credentials/зовнішнього сервісу, явно познач її та наведи безпечний наступний крок.