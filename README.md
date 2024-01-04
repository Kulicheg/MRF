Релиз 04.01.2023 версия 1.7.16:
- Отцентрован текст о проигрывании MOD файлов

Релиз 05.11.2023 версия 1.7.15:
- Рефакторинг структуры файлов.
- Добавление часов в MSX версию.

Релиз 02.11.2023 версия 1.7.14:
- Исправлена ошибка не сохранения файлов.

Релиз 01.11.2023 версия 1.7.13:
- Рефакторинг кода для обеспечения совместимости разных часов.

Релиз 31.10.2023 версия 1.7.12:
- Рефакторинг кода. Мелкие исправления.

Релиз 29.10.2023 версия 1.7.11:
- Оптимизации процедур работы с UARTом и отображения "*"
Скачивание файла теперь на 2% быстрее (115200)

Релиз 22.10.2023 версия 1.7.10:
- Драматически ускорен рендер страниц. Теперь страницы отображаются одинаково быстро вне зависимости от их объема. (izzx)
- исправлено определение конца буфера для nedoOS версии.

Релиз 22.10.2023 версия 1.7.9:
- Добавлена поддержка отображения времени для версии под NedoOS, добавлена возможность  собрать с поддержкой SMUC RTC, не проверялось.

Релиз 21.10.2023 версия 1.7.8:
- Воспроизведение MOD файлов теперь происходит подряд. Будут воспроизводиться все треки подряд которые на странице. [Space] следующий трек [Backspace] выход из воспроизведения. Спасибо izzx за код плеера.
Релиз 17.09.2023 версия 1.7.7:
- Для Gopher страниц также снято ограничение на 256 строк. Теперь страница может занимать всю свободную память.

Релиз 13.08.2023 версия 1.7.6:
- Добавлена поддержка просмотра SCR-картинок в версию для MSX. Палитра пока не настроена и картинки похожи на C64 версии себя

Релиз 10.08.2023 версия 1.7.6:
- Перенесена версия для MSX с Bad Cat WiFi в репозиторий. Код приведен к единой базе где было возможно. Отсутствует  поддержка SCR и строки инициализации, NiFi не поддерживает настройку через AT команды.

Релиз 19.06.2023 версия 1.7.6:
- Обновлен драйвер evo-uart.asm, включена поддержка RTS и установлена скорость обмена в 115200. Эффективная скорость скачивания на SD составила 36157 кбит/с (4,52 кб/с)

Релиз 17.06.2023 версия 1.7.5:
- Для сборки с General Sound добавлена возможеность выбора сохранять  MOD на диск или играть сразу (кнопка 'G')
- Сборка без поддержки General Sound теперь сохраняет файлы сразу на диск
- Добавлен русский шрифт для 80 колоночной TR-DOS версии.

Релиз 16.02.2023 версия 1.7.4:
- nedoNET: Увеличен еще немного буфер nedoNET (эффект должен быть только на эмуляторе, в реальности карта отдает за раз не больше чем MTU)
- nedoNET: Между попытками отправки DNS запросов делаем небоьшие паузы.

Релиз 12.02.2023 версия 1.7.3:
- nedoOS: Откуда бы мы не запускали mrf, всегда откроется его домашняя страница. Все скачивания теперь происходят в папку downloads, которая должна быть в корне системного диска. Внимание! Если папки нет, то и файлы будут скачиваться в пустоту.

Релиз 04.02.2023 версия 1.7.2:
- Для скачивания файлов и для загрузки mod в GS добавлено отображение пульсирующей "*" для  обозначения "живости" процесса
- Для драйвера NEDONET увеличен буфер приема, чуть возросла скорость.

Релиз 28.01.2023 версия 1.7.1:
 - При сборке присваиваем новую версию билда программы, отображаем ее в заголовке. Теперь отсчет ведем с 1.7.1

Релиз 14.01.2023:
 - Обновлен trdos.asm до версии 14.01.2023
 - Добавлены halt при опросе клавиатуры, должно улучшить работу на Скорпионе если это не было уже исправвлено.


Релиз 15.11.2022:
 - Обновлен trdos.asm до версии 14.11.2022
 - Увеличен буфер для nedoNET версии

Релиз 14.11.2022:
 - Обновлен trdos.asm

Релиз 13.11.2022:
 - Обновлен драйвер trdos.asm, теперь  сохраняем TRD и SCL на дискеты
 - Для UART версий передвинут вверх конец буфера с 0xC000 на 0хFE00
 - Полностью переделана работа со строками на 16 бит указатель, алгоритм работы MR такой, чем больше номер строки - тем дольше она рисуется

Релиз 12.11.2022:
 - добавлена очистка буфера клавиатуры перед новым чтением(стандартная консоль).
 - Переписаны вызовы поиска строки под 16 битный номер. findLine все еще 8 битная
 - Убрана задержка  при вводе данных, бесполезная

Релиз 09.11.2022:
 - Исправлена ошибка в nedoWiFi приводившая к зависанию при попытке загрузить страницу  большую чем есть памяти, теперь аварийно завершаем процесс если память кончилась.
 - Изменена раскладка навигации в plain-text
 - Уменьшенна задержка отображения лого
 - Исправлена ошибка в новой навигации по plain-text
 - Обновлен trdos.asm

Релиз 05.11.2022:
 - Добавлена задержка опроса кнопок в  диалоговых окнах, должно помочь предотвращать двойные нажатия.
 - Продублирована навигация на Синклер джойстик
 - Переработан интерфейс, теперь в него влезают 22 строки. Пришлось отказаться от копирайтов  и полного названия в заголовке
 - Инверсия цветов  по кнопке 'T' для TIMEX80
 - Для страницы с простым текстом добавлена возможность вводить адрес страницы как и для гофер.
 - Авторизация/инициализация включается ключом -DAUTH при сборке *
 - Добавлена возможность добавления пользовательской строки инициализации для драйвера ESP. Можно добавить подключение к АP, нужно добавить в файл auth.p строку  подключения (AT+CWJAP="SSID","drowssap")
 - Для режима 64 колонки  добавлена возможность использовать  все 64 колонки, для TIMEX80 все 85 колонок
 - Для не ZX-UNO машин используем порт 0xEFF7 для управления Timex Hi-Res режимом
 - Добавлен новый таргет TR-UN-64 (например,Карабас-Про)

Поддержка OS:
 - TR-DOS
 - nedoOS

Поддержка экранов:
 - 6912     64 колонки
 - TIMEX80  85 колонок
 - nedoOS   80 колонок

Поддержка сети:
 - ESP на ATM ком-порт
 - ESP на EVO ком-порт
 - ESP на UNO ком-порт
 - ESP на  AY ком-порт
 - ZXNETUSB (nedoOS)
 - карта ZX-Wifi от izzx
*По умолчанию строка подключения к AP  установлена как "AT". При необходимости заменить ее на актуальную. По идее AT+CWJAP нужно устаноыить только 1 раз, после ESP запомнит точку.

Для АТМ:     38400,8N2  FC (AT+UART=38400,8,2,0,3)

Для EVO:     115200,8N1 FC (AT+UART=115200,8,1,0,3)

Для ZX-WIFI: 115200,8N1

Для AY:       9600

Для UNO:      Н/Д

Credits:
- Оригинальная версия:    Nihirash
- nedoOS порт:            DimkaM
- TR-DOS драйвер:         izzx
- Просмотр SCR:           KoD/SDM