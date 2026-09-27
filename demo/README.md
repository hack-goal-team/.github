# Локальный запуск «Москоллектор»

Один архив содержит исходный код бэкенда, фронтенда и сервиса инференса из
веток `main`, а также конфигурацию Docker Compose. Версии записаны в
`SOURCES.txt`. Для запуска архива доступ к GitHub не нужен.

## Поддерживаемые системы и требования

| Система | Docker |
| --- | --- |
| Windows 10/11 x64 | [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/) с WSL 2 и режимом Linux containers |
| macOS, Intel или Apple Silicon | [Docker Desktop](https://docs.docker.com/desktop/setup/install/mac-install/) |
| Linux x86_64 или arm64 | [Docker Engine и Compose plugin](https://docs.docker.com/compose/install/linux/) либо Docker Desktop |

Нужны не менее 8 ГиБ памяти для Docker, 15 ГиБ свободного места, интернет для
первой сборки и свободный порт 8088. Docker должен быть запущен; команда
`docker compose version` должна работать. На Windows выбирайте **Linux
containers**. Установка Windows containers для этого пакета не подходит.

## Запуск на Windows

1. Распакуйте `moscollector-demo.zip` штатным Проводником. Откройте каталог
   `moscollector-demo`, содержащий `compose.yaml`.
2. Запустите `start.cmd` двойным щелчком. Если Windows ограничивает запуск
   скачанного файла, откройте PowerShell в этом каталоге и выполните:

   ```powershell
   docker compose up --build -d
   docker compose ps
   ```

## Запуск на macOS и Linux

Распакуйте архив, откройте терминал в каталоге `moscollector-demo` и выполните:

```sh
sh ./start.sh
```

Равнозначные команды: `docker compose up --build -d` и `docker compose ps`.
Первый запуск включает загрузку образов, компиляцию Java, сборку Vue и
установку зависимостей Python; он может занять несколько минут.

## Проверка

Откройте `http://localhost:8088/health` и дождитесь `"status":"UP"`.
Затем откройте `http://localhost:8088/` и войдите под именем `dispatcher`
с паролем `demo1234`. Эта учётная запись предназначена для локального пакета.

При ошибке посмотрите состояние и журналы из каталога `moscollector-demo`:

```text
docker compose ps
docker compose logs --tail=100 backend inference inference-setup
```

Если сборка сообщает об отсутствии Docker daemon, запустите Docker Desktop
или Docker Engine. Если занят порт 8088, освободите его и повторите запуск.

Работают API, интерфейс, PostgreSQL, Kafka, имитаторы реестра и ОДС и
отдельный процесс инференса. Реестр содержит четыре канала и загружается
через API после старта. Исторического журнала в архиве нет: прогнозы появятся
после подачи событий. Обучение модели в этот пакет не входит.

## Остановка

Из каталога `moscollector-demo` выполните `docker compose down`. Данные в
именованных томах сохранятся. Для полного удаления локальных данных:
`docker compose down -v`.

Опубликован только `127.0.0.1:8088`; порты PostgreSQL, Kafka и Java-сервиса
доступны контейнерам внутри сети Compose. Пароли в архиве демонстрационные.
