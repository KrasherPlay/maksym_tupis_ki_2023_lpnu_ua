---
name: github-actions
description: "Use when creating or reviewing GitHub Actions CI for a Java Maven project with JUnit 5 across Windows, Linux, and macOS runners."
argument-hint: "Provide the Java version, Maven command, project modules, and required CI triggers or matrix."
user-invocable: true
---

# GitHub Actions for Java/Maven

## Призначення

Створювати кросплатформений GitHub Actions workflow для Java/Maven-проєкту, який запускає збірку та JUnit 5 тести на Windows, Linux і macOS без розкриття секретів і без платформозалежних припущень.

## Вхідні дані

- Java version(s), які потрібно підтримувати.
- Maven wrapper або вимога використовувати system Maven.
- Команда CI (`test`, `verify`, `package`) і назва профілю/модулів.
- Події запуску: `push`, `pull_request`, manual dispatch або їх комбінація.
- OS matrix: `windows-latest`, `ubuntu-latest`, `macos-latest`, якщо користувач не задав інше.
- Потрібні permissions, cache policy та безпечні repository variables/secrets.

## Очікуваний результат

- Workflow у `.github/workflows/*.yml` або `.yaml` з валідним YAML.
- Matrix job запускається на Windows, Linux і macOS та використовує однакову Java/Maven перевірку.
- Maven dependencies кешуються без кешування секретів або runtime artifacts, що можуть приховати помилки.
- JUnit 5 результати та build artifacts публікуються лише за визначеною політикою.
- Workflow має зрозумілі назви кроків, коректні failure semantics і не містить секретів.

## Кроки створення і перевірки

1. Перевірити наявні workflows, `pom.xml`, wrapper scripts (`mvnw`, `mvnw.cmd`) і supported Java versions.
2. Визначити trigger-и та мінімальні permissions; для CI за замовчуванням використовувати `contents: read`.
3. Створити job з matrix `os: [ubuntu-latest, windows-latest, macos-latest]` і заданою Java version.
4. Використати `actions/checkout` та `actions/setup-java@v5` з однаковою distribution/version на всіх OS.
5. Налаштувати Maven cache через `setup-java` або узгоджений repository pattern.
6. Перед запуском на Linux/macOS виконати `chmod +x mvnw`, потім запускати `./mvnw -B -ntp verify`; на Windows використовувати `.\mvnw.cmd -B -ntp verify`. Не покладатися на shell-specific синтаксис в одному кроці.
7. Не використовувати `-DskipTests`; переконатися, що JUnit 5 discovery і Surefire працюють у всіх трьох OS.
8. Додати upload test reports/artifacts лише за потреби та з `if: always()` так, щоб failure не став success.
9. Перевірити YAML syntax, action versions, matrix expression і runner-specific shell paths.
10. Перевірити локально відповідні Maven-команди та, після push/PR, переглянути всі matrix jobs і зберегти перший релевантний failure.

## Обробка помилок

- Якщо workflow не парситься, спочатку виправ YAML indentation, quoting, expressions і mapping types.
- Якщо Linux/macOS не можуть виконати wrapper, перевір крок `chmod +x mvnw`; якщо Windows не знаходить wrapper, перевір використання `.\mvnw.cmd`; не видаляй wrapper.
- Якщо macOS/Linux/Windows дають різні failures, порівняй Java version, shell, path separator, line endings і file permissions.
- Якщо cache corrupt або спричиняє помилку, очисть/зміни cache key, але не приховуй build failure через `continue-on-error`.
- Якщо GitHub Actions quota, network або external service недоступні, познач failure як infrastructure-related і повтори лише контрольовано.
- Не вставляй tokens, passwords, private keys чи connection strings у workflow, logs, commit або приклади. Використовуй `${{ secrets.NAME }}` лише коли секрет справді потрібен.
- Не використовуй force push, не переписуй історію та не змінюй unrelated workflows без явної потреби.