# 📖 Полное руководство по настройке и модификации загрузчика

Данный документ содержит полное описание работы скриптов (`Downloader.cmd`), параметров реестра (`.reg`) и компонентов утилиты. Руководство поможет вам полностью кастомизировать проект под свои нужды: изменить качества, форматы, пути сохранения, добавить субтитры или переключить поведение контекстного меню.

---

## 📑 Оглавление

1. [Структура и расположение файлов](#files-structure)
2. [Как работает меню Shift (Разбор .reg файла)](#shift-menu)
3. [Разбор и модификация CMD-скрипта](#cmd-script)
   * [Переменные и пути](#vars-and-paths)
   * [Выбор качества (1080p / 2K / 4K)](#quality-selection)
   * [Настройка звука и кодеков](#audio-settings)
   * [Настройка скачивания плейлистов и папок](#playlists-settings)
   * [Добавление субтитров](#subtitles-settings)
   * [Настройка фото (gallery-dl)](#gallery-dl-settings)
4. [Включение многопоточной загрузки через aria2c](#aria2c-enable)
5. [Полезные ссылки](#useful-links)

---

<a id="files-structure"></a>

## 1. 📂 Структура и расположение файлов

Для корректной работы системы файлы должны размещаться в системной директории `C:\Windows\`:

* **`C:\Windows\Downloader.cmd`** — основной управляющий командный файл.
* **`C:\Windows\Downloader.ico`** — иконка контекстного меню.

---

<a id="shift-menu"></a>

## 2. ⌨️ Как работает меню Shift (Разбор `.reg` файла)

Проект поставляется в двух вариантах установки: обычный вывод меню по ПКМ и вывод **только при зажатой клавише Shift**.

### В чем разница?

В файлах реестра Windows за отображение пункта **только при зажатом Shift** отвечает строковый параметр `"Extended"=""`.

* В `_install_.cmd` в реестр записываются обычные ключи.
* В `_install_shift.cmd` в каждый раздел добавляется строковый параметр `"Extended"=""`.

#### Пример из REG-файла с поддержкой Shift

```registry
[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\background\shell\Downloader]
"icon"="C:\\Windows\\Downloader.ico"
"MUIVerb"="Скачать"
"Position"="Top"
"SubCommands"=""
"Extended"=""  <-- Благодаря этой строчке меню открывается ТОЛЬКО по Shift + ПКМ

```

### Как изменить название или порядок элементов в меню?

* **`MUIVerb`** — отвечает за текст, который вы видите в меню (например, `"MUIVerb"="Видео 1080"`).
* **`Position`** — выводит пункт в самый верх (`"top"`) или вниз меню.
* Разделы `1Video`, `1Video1440`, `3Audio` определяют порядок сортировки. Буквы или цифры перед именем раздела меняют итоговое расположение элементов.

---
<a id="cmd-script"></a>

## 3. ⚙️ Разбор и модификация CMD-скрипта

Все действия, аргументы и режимы вызова прописаны внутри `C:\Windows\Downloader.cmd`.
<a id="vars-and-paths"></a>

### Переменные и пути

В самом начале файла заданы основные параметры:

```bat
set "params=--force-overwrites --quiet --progress --ignore-errors --windows-filenames"
set "outpath=%cd%"

```

* `%cd%` — аргумент `outpath` берет текущую папку, в которой вы вызвали контекстное меню проводника.
* `--windows-filenames` — принудительно очищает названия файлов от спецсимволов (`:`, `?`, `*`, `|`), недопустимых в Windows.
* `--force-overwrites` — перезаписывает файл, если он уже существует в папке.

---
<a id="quality-selection"></a>

### Выбор качества (1080p / 2K / 4K)

За качество скачиваемого видео отвечает флаг `-f` (format).

#### Блок 1080p (Full HD)

```bat
-f "bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best"

```

#### Как изменить разрешение?

В скрипте уже предусмотрены метки `:video1440` и `:video2160`. Качество регулируется аргументом `height`:

* `[height<=720]` — HD 720p (для медленного интернета или экономии места).
* `[height<=1080]` — Full HD 1080p.
* `[height<=1440]` — 2K (QHD).
* `[height<=2160]` — 4K (UHD).

Если вы хотите скачать **абсолютно максимально возможное качество** без ограничений по контейнеру MP4, измените значение `-f` на:

```bat
-f "bestvideo+bestaudio/best"

```

---
<a id="audio-settings"></a>

### Настройка звука и кодеков

За загрузку только аудиодорожки отвечает метка `:audio`:

```bat
:audio
yt-dlp ^
--yes-playlist ^
--extract-audio ^
--audio-format m4a ^
--audio-quality 0 ^
--embed-metadata ^
--embed-thumbnail ^
-o "%outpath%\%%(playlist_title|.)s\%%(title)s.%%(ext)s" ^
%params% "%ClipboardData%"

```

* `--extract-audio` — извлекает только аудио без загрузки видеоряда.
* `--audio-format m4a` — формат аудиофайла. Можно заменить на `mp3`, `flac`, `wav`, `opus`, `aac`.
* `--audio-quality 0` — настраивает качество сжатия (значение `0` — лучшее качество).
* `--embed-thumbnail` — вшивает обложку видео (превью) прямо в теги аудиофайла.

---
<a id="playlists-settings"></a>

### Настройка скачивания плейлистов и папок

Шаблон имени и пути файла задается параметром `-o` (output):

```bat
-o "%outpath%\%%(playlist_title|.)s\%%(title)s.%%(ext)s"

```

* `%%(playlist_title|.)s` — если вы скачиваете плейлист, создастся отдельная папка с названием плейлиста. Если скачивается одиночное видео, точка `.` означает, что файл сохранится сразу в текущую папку без создания подпапок.
* `%%(title)s.%%(ext)s` — имя файла будет соответствовать названию ролика на сайте.

#### Альтернативные шаблоны именования

* Сохранение с указанием автора:

```bat
-o "%outpath%\%%(uploader)s - %%(title)s.%%(ext)s"

```

* Нумерация треков в плейлисте:

```bat
-o "%outpath%\%%(playlist_title|.)s\%%(playlist_index)s - %%(title)s.%%(ext)s"

```

---
<a id="subtitles-settings"></a>

### Добавление субтитров

Чтобы автоматизировать скачивание и вшивание субтитров, добавьте следующий блок параметров в секцию `yt-dlp`:

```bat
yt-dlp ^
--yes-playlist ^
--embed-metadata ^
--write-subs ^
--write-auto-subs ^
--sub-langs "ru.*,en.*" ^
--embed-subs ^
-o "%outpath%\%%(playlist_title|.)s\%%(title)s.%%(ext)s" ^
-f "bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best" ^
%params% ^
"%ClipboardData%"

```

**Расшифровка аргументов субтитров:**

* `--write-subs` — загружает авторские субтитры.
* `--write-auto-subs` — скачивает автоматические субтитры (например, с YouTube), если оригинальных нет.
* `--sub-langs "ru.*,en.*"` — скачивает только русский и английский языки. Для всех языков укажите `"all"`.
* `--embed-subs` — вшивает субтитры внутрь контейнера видеофайла (без создания отдельных файлов `.srt`).

---
<a id="gallery-dl-settings"></a>

### Настройка фото (gallery-dl)

Для загрузки изображений из соцсетей, арт-борд и форумов используется утилита `gallery-dl`:

```bat
:image
title Downloading images
echo Downloading images URL: %ClipboardData%

gallery-dl "%ClipboardData%" --dest "%outpath%"

```

* `--dest "%outpath%"` — указывает путь, куда `gallery-dl` сохранит файлы.
* Если нужно скачивать фото без создания подпапок по сайтам/авторам, можно дописать флаг `--directory ""`:

```bat
gallery-dl --directory "" --dest "%outpath%" "%ClipboardData%"

```

---
<a id="aria2c-enable"></a>

## 4. 🚀 Включение многопоточной загрузки через aria2c

В вашем `.reg` файле строки с вызовом `aria2c` закомментированы символом `;`.

Утилита `aria2c` ускоряет скачивание больших файлов благодаря разбивке потока.

### Как включить aria2c в меню

Раскомментируйте блоки в файле `.reg` (удалите `;` в начале строк):

```registry
[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\background\shell\Downloader\shell\2VideoDated]
"icon"="C:\\Windows\\Downloader.ico"
"MUIVerb"="Видео с помощью aria2c"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\background\shell\Downloader\shell\2VideoDated\command]
@="C:\\Windows\\Downloader.cmd video-aria2c"

```

После раскомментирования и повторного импорта `.reg` файла в реестр у вас появится пункт меню **«Видео с помощью aria2c»**, который будет вызывать метку `:video_aria` из файла `Downloader.cmd`.

---
<a id="useful-links"></a>

## 5. 🔗 Полезные ссылки

* [Документация yt-dlp (Раздел General Options)](https://www.google.com/search?q=https://github.com/yt-dlp/yt-dlp%23general-options)
* [Документация gallery-dl](https://www.google.com/search?q=https://github.com/mikf/gallery-dl%23usage)
* [Официальный репозиторий aria2](https://github.com/aria2/aria2)
