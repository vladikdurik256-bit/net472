# Mono Full Offline NET472 — генератор комплекта

Это генератор, а не готовый расширенный архив DLL. В исходной песочнице DNS недоступен; загрузка Debian .deb и NuGet невозможна. В CURRENT_SANDBOX.log записаны реальные результаты: Hello World PASS, отсутствуют восемь сборок и профиль 4.7.2, MCS не поддерживает C# 7.3.

## Windows (Docker Desktop, Linux containers)
Распаковать архив. В PowerShell в этой папке:

    powershell -ExecutionPolicy Bypass -File .\build_bundle.ps1

## Linux с Docker

    bash build_bundle.sh

## GitHub Actions без установки Docker на ПК
В пустой репозиторий добавить все файлы и папки из архива (включая скрытую `.github`). Actions -> Build offline Mono NET472 kit -> Run workflow. Скачать artifact Mono-Full-Offline-NET472, распаковать его и взять внутренний Mono_Full_Offline_NET472.zip. Workflow не запускается автоматически при push.

## Что делает сборщик
- На чистом Debian 13 amd64 APT скачивает mono-devel, mono-xbuild, зависимости, libgdiplus, Xvfb, Xauth, шрифты и сборки из csproj Python_Interpreter_UI.
- Из NuGet скачивает Roslyn 4.8.0 (tasks/net472/csc.exe).
- Генерирует SHA256SUMS для проверки целостности полученных файлов.
- Запускает независимый чистый Debian 13 контейнер с отключённой сетью, устанавливает локальные пакеты и проверяет Hello, MCS, графику, числовые типы, XML, DataSet, HTTP без сети, ZIP и Roslyn C# 7.3.
- Архив формируется только при успешном завершении всех тестов. VALIDATION.log содержит результат.

## Установка полученного архива в песочнице ChatGPT
Распаковать Mono_Full_Offline_NET472.zip на Debian 13 amd64 с root:

    bash setup.sh
    bash test.sh

Для MCS: `mcs -sdk:4.7.2 -langversion:7.2 ...`.
Для Roslyn: `mono /path/to/roslyn/tasks/net472/csc.exe -noconfig -nostdlib+ -langversion:7.3 -r:/usr/lib/mono/4.7.2-api/mscorlib.dll -r:/usr/lib/mono/4.7.2-api/System.dll ...` (добавить все ссылки проекта).

Ограничения: сценарии сборки проверены синтаксически, но скачивание и полноценная установка не выполнялись в исходной песочнице. Сборщик использует текущие согласованные версии пакетов Debian 13, не фиксирует снимок репозитория. Docker требует сетевой доступ на этапе загрузки. Не заменяет Windows/MSBuild и не гарантирует выполнение Windows P/Invoke, OpenGL/WGL, COM, ClickOnce и других платформенных API. Проект Python_Interpreter_UI целиком не компилировался в рамках этой проверки.
