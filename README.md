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
Поддержка экранов:'ktvtynfhyj -

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
Для АТМ:     38400,8N2 AFC
Для EVO:     38400,8N1
Для ZX-WIFI: 115200,8N1
Для AY:       9600
Для UNO:      Н/Д

