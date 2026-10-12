---
name: project-scaffold
description: "Use when creating or reviewing the structure of a Java Maven project with JUnit 5, including source folders, test folders, packages, resources, and the initial build configuration."
argument-hint: "Describe the Java Maven project name, package, Java version, and required modules."
user-invocable: true
---

# Java Project Scaffold

## Призначення

Створювати або перевіряти передбачувану структуру Java/Maven-проєкту з окремими production- і test-вихідними файлами та підтримкою JUnit 5. Skill не реалізує бізнес-логіку, якщо це не зазначено у вхідних даних.

## Вхідні дані

- Коренева директорія проєкту.
- Назва проєкту та базовий Java package.
- Цільова версія Java.
- Тип проєкту: single-module або multi-module.
- Потрібні модулі, ресурси, entry point і спосіб пакування, якщо вони відомі.
- Наявні файли, які потрібно зберегти.

Якщо критична інформація відсутня, використовуй наявні conventions у проєкті або запроси уточнення до створення несумісної структури.

## Очікуваний результат

- Maven-структура `src/main/java`, `src/main/resources`, `src/test/java` і `src/test/resources` для кожного відповідного модуля.
- Узгоджені package-директорії та відсутність дублювання класів.
- Коректний `pom.xml` або модульні `pom.xml` із Java compiler settings і JUnit 5 test dependencies/plugins.
- Мінімальні smoke/unit tests, якщо вони передбачені вхідними даними.
- Короткий звіт про створені/змінені файли, припущення та перевірки.

## Кроки виконання і перевірки

1. Перевірити кореневу директорію, існуючий `pom.xml`, Maven wrapper, `.gitignore`, README та поточні source/test-пакети.
2. Не перезаписувати користувацькі зміни; узгодити назву package з уже наявним кодом.
3. Створити лише відсутні директорії та файли у стандартних Maven-шляхах.
4. Налаштувати Java version через наявний підхід проєкту: `maven.compiler.release` або узгоджені `source`/`target`.
5. Додати JUnit Jupiter API/Engine через `org.junit.jupiter:junit-jupiter` або наявну dependency-management схему.
6. Налаштувати Surefire сумісно з JUnit 5, якщо поточна версія Maven/Surefire цього потребує.
7. Перевірити, що package declaration відповідає шляху файлу, а test package відповідає production package.
8. Запустити `mvn test` або `mvnw.cmd test` на Windows; для multi-module проєкту використати reactor-команду з кореня.
9. Перевірити `mvn validate`/`mvnw.cmd validate` і за потреби `mvn package` без пропуску тестів.
10. Зафіксувати результат, включно з відомими pre-existing failures.

## Обробка помилок

- Якщо `pom.xml` невалідний, виправляй першопричину XML/структури, а не обходь її параметрами Maven.
- Якщо package або Java version конфліктує з наявним кодом, зупини зміни, опиши конфлікт і запроси рішення.
- Якщо залежності недоступні через мережу/репозиторій, не підміняй їх випадковими версіями; повідом точну координату та команду, що впала.
- Якщо структура вже частково створена, доповнюй її і не видаляй файли чи тести.
- Не додавай секрети, приватні URL або credentials до `pom.xml`, resources чи прикладів.