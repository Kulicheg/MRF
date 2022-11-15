    MODULE Dos
; API methods
ESX_GETSETDRV = #89
ESX_FOPEN = #9A
ESX_FCLOSE = #9B
ESX_FSYNC = #9C
ESX_FREAD = #9D
ESX_FWRITE = #9E

; File modes
FMODE_READ = #01
FMODE_WRITE = #06
FMODE_CREATE = #0E

    ; MACRO esxCall func
    ; rst #8 : db func
    ; ENDM
	
;id = 0 файл не открыт
;id = 1 файл для чтения
;id = 2 файл для записи
;id = 3 файл для записи тип TRD
;id = 4 файл для записи тип SCL

; HL - filename in ASCIIZ
loadBuffer:
    ld b, Dos.FMODE_READ: call Dos.fopen
    push af
        ld hl, outputBuffer, bc, #ffff - outputBuffer : call Dos.fread
        ld hl, outputBuffer : add hl, bc : xor a : ld (hl), a : inc hl : ld (hl), a
    pop af
    call Dos.fclose
    ret


; Returns: 
;  A - current drive
; getDefaultDrive: ;нигде не используется
    ; ld a, 0 : esxCall ESX_GETSETDRV
    ; ret



; Opens file on default drive
; B - File mode
; HL - File name
; Returns:
;  A - file stream id
fopen:
    ; push bc : push hl 
    ; call getDefaultDrive
    ; pop ix : pop bc
    ; esxCall ESX_FOPEN
    ; ret
	ld a,b
	cp FMODE_READ ;если режим открытие файла
	jr z,fopen_r
	cp FMODE_CREATE
	jr z,fopen_c ;если режим создание файла
	jr fopen_err ;иначе выход
	
fopen_r	;открытие существующего файла на чтение (id=1)
			call format_name ;
			ld      c,#13 ;move file info to syst var
            call    #3d13
            ld      c,#0a ;find file
            call    #3d13
            ld      a,c
			cp 		#ff
			jr 		z,fopen_err ;если не нашли файла
            ld      c,#08 ;read file title
            call    #3d13
            ;ld      hl,loadadr ;куда
            ld      de,(#5ceb) ;начало файла сектор дорожка
            ld      (f_r_cur_trk),de

            ld      a,(#5cea)
            ld      (f_r_len_sec),a ;длина в секторах
            ;or      a
            ;ret     z    ;выход если пустой

            ; ld      de,(fcurtrk) ;текущие сектор дорожка
            ; ld      (#5cf4),de ;восстановим
			xor a
			ld 		a,1
			ld (f_r_flag),a ;флаг что файл для чтения открыт
			;id канала будет 1
	ret
	
fopen_err
	xor a ;если никакой файл не открыли, то id = 0
	scf ;флаг ошибки
	ret


fopen_c	;создание нового файла (id=2-4)
	call format_name ;
	;выясним, не образ ли это для разворачивания
    ld hl, trdExt1 : call CompareBuff.search : and a : jr nz, fopen_c_trd
    ld hl, trdExt2 : call CompareBuff.search : and a : jr nz, fopen_c_trd
	ld hl, sclExt1 : call CompareBuff.search : and a : jr nz, fopen_c_scl
    ld hl, sclExt2 : call CompareBuff.search : and a : jr nz, fopen_c_scl

	
fopen_c_2	;создание произвольного файла
	jr 		fopen_err ;пока отключено

	; ld      c,#13 ;move file info to syst var
    ; call    #3d13
	; ld de,256 ;запишем пока 1 сектор
	; ld hl,#4000 ;возьмём случайные данные из экрана
    ; ld      c,#0b ;запись файла CODE
    ; call    #3d13
    ; ld      a,c
	; cp 		#ff
	; jr 		z,fopen_err ;если ошибка
		
    ; ld      de,(#5ceb) ;начало файла сектор дорожка
    ; ld      (f_w_cur_trk),de
    ; ld      a,(#5cea)
    ; ld      (f_w_len_sec),a ;длина в секторах
	; xor a ;id канала будет 2
	; ld a,2
	; ld (f_w_flag),a ;флаг что файл для записи открыт
	; ret		
	




fopen_c_trd	;открытие файла для разворачивания образа trd (id=3)
	ld a,(#5D19) ;номер дисковода по умолчанию
	add a,"A"
	ld (write_ima_d),a ;подставим букву в запросе
    ld hl, write_ima
    call DialogBox.msgBox ;предуреждение
WAITKEY_trd	
	ld 		a,(23556)
	cp 255
	JR Z,WAITKEY_trd	;ждём любую клавишу
	
	ld      de,0 ;начало сектор дорожка
    ld      (#5cf4),de
	xor a 
	ld (sec_shift),a ;переменная
	ld hl,0
	ld (f_w_len+0),hl
	ld (f_w_len+2),hl
	ld a,3 ;id канала
	ld (f_w_flag),a ;флаг что trd для записи открыт
	ret




fopen_c_scl	;открытие файла для разворачивания образа scl (id=4)
	ld a,(#5D19) ;номер дисковода по умолчанию
	add a,"A"
	ld (write_ima_d),a ;подставим букву в запросе
    ld hl, write_ima
    call DialogBox.msgBox ;предуреждение
WAITKEY_scl	
	ld 		a,(23556)
	cp 255
	JR Z,WAITKEY_scl	;ждём любую клавишу
	
	ld      de,0 ;начало сектор дорожка
    ld      (#5cf4),de
	
	ld hl,cat_buf ;очистить место для каталога дискеты
	ld de,cat_buf+1
	ld (hl),0
	ld bc,9*256-1
	ldir
	
	call scl_parse ;запуск цикла сборки образа
	
	xor a 
	ld (sec_shift),a ;переменная
	;ld (scl_que),a
	ld hl,0
	ld (f_w_len+0),hl
	ld (f_w_len+2),hl
	ld a,4 ;id канала
	ld (f_w_flag),a ;флаг что scl для записи открыт
	ret	



; A - file stream id
fclose:
    ;esxCall ESX_FCLOSE
	; push af
; WAITKEY2	XOR A:IN A,(#FE):CPL:AND #1F:JR Z,WAITKEY2
	; pop af
	cp 4 ;если scl
	jr nz,fclose2
	ld hl,sec_buf ;
	ld b,1
	call scl_write_buf ;допишем остаток scl, если есть
	
fclose2	
	xor a ;как бы закрываем все файлы
	ld (f_r_flag),a
	ld (f_w_flag),a
    ret




; A - file stream id
; BC - length
; HL - buffer
; Returns
;  BC - length(how much was actually read) 
fread: ;(id=1)
    ; push hl : pop ix
    ; esxCall ESX_FREAD
	; push af
	; ld a,4
	; out (254),a
; WAITKEY	XOR A:IN A,(#FE):CPL:AND #1F:JR Z,WAITKEY
	; xor a
	; out (254),a
	; pop af

	cp 1 ;id = 1?
	jr nz,fread_no_chek ;выход если номер потока не = 1
	ld a,(f_r_flag)
	or a
	jr nz,fread_chek ;файл уже открыт?
fread_no_chek ;выход с ошибкой
	xor a
	scf ;флаг ошибки
	ld bc,0 ;ничего мы не считали
	ret
	
fread_chek
	push bc
	ld bc,(f_r_len_sec-1) ;загружаем файл целиком, не смотря на то, сколько байт было запрошено
    ld      c,5 ;read читаем целыми секторами
	ld de,(f_r_cur_trk)
    call    #3d13	
	pop bc ;возвратим, что сколько запрашивали, столько и считали байт
	xor a ;флаги сбросим
    ret

; A - file stream id
; BC - length
; HL - buffer
; Returns:
;   BC - actually written bytes
fwrite: ;
    ; push hl : pop ix
    ; esxCall ESX_FWRITE
	
	; push af
	; ld a,2
	; out (254),a
; WAITKEY1	XOR A:IN A,(#FE):CPL:AND #1F:JR Z,WAITKEY1
	; xor a
	; out (254),a
	; pop af

	cp 2 ;id = 2?
	jr z,fwrite_chek ;проверка id потока
	cp 3 ;id = 3?
	jr z,fwrite_chek_trd ;проверка id потока
	cp 4 ;id = 4?
	jp z,fwrite_chek_scl ;проверка id потока

	
fwrite_no_chek ;выход с ошибкой
	xor a
	scf ;флаг ошибки
	ld bc,0 ;ничего мы не записали
	ret
	
fwrite_chek ;запись произвольного типа файла
	jr fwrite_no_chek ;пока отключено
	; ld a,(f_w_flag)
	; or a
	; jr z,fwrite_no_chek ;файл уже открыт?
	; ld (temp_bc),bc
	; ;ld bc,(f_r_len_sec-1) ;
    ; ld      c,6 ;пишем целыми секторами
	; ld de,(f_w_cur_trk)
    ; call    #3d13	
	; ld bc,(temp_bc) ;возвратим, что сколько запрашивали, столько и считали байт
	; xor a ;флаги сбросим
    ; ret





fwrite_chek_trd ;запись trd файла (разворачивание образа)
	; ld a,2
	; out (254),a
; WAITKEY_t	XOR A:IN A,(#FE):CPL:AND #1F:JR Z,WAITKEY_t
	; xor a
	; out (254),a
	ld a,(f_w_flag)
	or a
	jr z,fwrite_no_chek ;файл уже открыт?
	ld (temp_bc),bc ;длина
	ld (temp_hl),hl ;адрес данных
	ld a,b
	or c
	jr z,fwrite_no_chek ; если длина 0, то выход
	
	; ld a,b
	; or a
	; jr nz,testt1
	; nop
	
; testt1
	
	xor a
	ld (sec_part),a ;обнулить переменные
	ld (sec_shift2),a
	ld (sec_shift2+1),a
	ld (sec_shift_flag),a
	ld (write_end_flag),a ;
	

	ld a,(sec_shift)
	or a
	jr z,fwrite_trd3 ;если смещения нет, то первую часть пропустим
	

	ld c,a
	ld b,0
	ld hl,(temp_bc) ;проверка заполнится ли целый сектор
	add hl,bc
	
	ld a,1
	ld (write_end_flag),a ;флаг что не нужно дописывать остаток
	
	ld a,h
	or a
	jr nz,fwrite_trd4
	ld a,1
	ld (sec_shift_flag),a ;флаг что не заполнен сектор
	
fwrite_trd4	
	ld hl,sec_buf ;буфер последнего сектора	
	add hl,bc ;на этой точке остановились
	ex de,hl
	ld hl,(temp_hl) ;присоединим начало данных в конец предыдущих
	; ld a,c
	; or a
	; jr nz,fwrite_trd2
	; inc b ;коррекция
; fwrite_trd2		
	; ld c,a
	xor a
	sub c
	ld c,a ;сколько осталось перенести до заполнения сектора
	ld (sec_shift2),bc ;сохраним сколько добавили байт
	ldir

	ld a,(sec_shift_flag)
	or a
	jr nz,fwrite_trd3 ;если сектор ещё не заполнен писать не будем

	ld hl,sec_buf
	ld de,(#5cf4)
	;ld (f_w_cur_trk),de	;запомним позицию
    ld      bc,#0106 ;пишем 1 сектор из буфера
    call    #3d13	
	ld a,c
	cp 255
	jp z,fwrite_no_chek ;выход если ошибка	

	xor a
	ld (write_end_flag),a ;флаг что нужно дописывать остаток	
	; ld de,(f_w_cur_trk) ;если сектор ещё не заполнен, останемся на старой позиции
	; ld (#5cf4),de
	; ld b,1 ;на сектор вперёд
	; ld de,(f_w_cur_trk)
	; call calc_next_pos
	; ld (f_w_cur_trk),de	

fwrite_trd3	
	ld hl,(temp_hl) ;запишем остаток данных
	;ld a,(sec_shift)
	;ld c,a
	;ld b,0
	ld bc,(sec_shift2)
	add hl,bc ;с этой точки пишем
	ld (temp_hl2),hl ;сохраним начало записи второго сектора
	
	ld hl,(temp_bc) ;вычисление на чём остановимся в этот раз
	and a
	sbc hl,bc ;вычтем то, что добавили к первому сектору
	ld c,l
	ld b,h
	jr nc,fwrite_trd5
	ld b,0 ;коррекция если вышел минус
fwrite_trd5
	ld hl,(temp_hl)
	add hl,bc 
	
	ld de,outputBuffer
	and a
	sbc hl,de
	
	ld a,l
	ld (sec_shift),a ;смещение на следующий раз
	;ld hl,(temp_hl)	
	

	; or a
	; jr z,fwrite_trd1
	; inc b  ;коррекция количества секторов
	
	ld a,b ;нужна проверка на количество секторов!!!
	ld (sec_part),a ;запомним сколько секторов во второй части
	
	;ld a,b	
	or a
	jr z,fwrite_trd1 ;если размер данных меньше сектора, то пропустим запись
	
	ld hl,(temp_hl2)
	;push bc
	ld de,(#5cf4)
    ld      c,6 ;пишем целыми секторами
    call    #3d13	
	ld a,c
	;pop bc
	cp 255
	jp z,fwrite_no_chek ;выход если ошибка
	; ld de,(f_w_cur_trk)
	; call calc_next_pos
	; ld (f_w_cur_trk),de
	
	xor a
	ld (write_end_flag),a ;флаг что нужно дописывать остаток	
	
fwrite_trd1	
	ld a,(write_end_flag) ;нужно записывать остаток?
	or a
	jr nz,fwrite_trd_ex ;не нужно

	ld hl,(temp_hl2) ;сохраним незаписанный остаток
	ld a,(sec_part)
	ld b,a
	ld c,0
	add hl,bc
	ld de,sec_buf
	ld bc,256
	ldir
;fwrite_trd2	

	
fwrite_trd_ex	
	ld bc,(temp_bc) ;возвратим, что сколько запрашивали, столько и записали байт
	;посчитаем общую длину записанного
	ld hl,(f_w_len)
	add hl,bc
	ld (f_w_len),hl
	jr nc,fwrite_trd_ex1
	ld hl,(f_w_len+2)
	inc hl
	ld (f_w_len+2),hl
	
fwrite_trd_ex1
	xor a ;флаги сбросим
    ret





;------------------scl----------------------
fwrite_chek_scl ;запись scl файла (разворачивание образа)
	; ld a,2
	; out (254),a
; WAITKEY_t	XOR A:IN A,(#FE):CPL:AND #1F:JR Z,WAITKEY_t
	; xor a
	; out (254),a
	ld a,(f_w_flag)
	or a
	jp z,fwrite_no_chek ;файл уже открыт?
	ld (temp_bc),bc ;длина
	ld (temp_hl),hl ;адрес данных
	ld a,b
	or c
	jp z,fwrite_no_chek ; если длина 0, то выход
	
	; ld a,b
	; or a
	; jr nz,testt1
	; nop
	
; testt1
	
	xor a
	ld (sec_part),a ;обнулить переменные
	ld (sec_shift2),a
	ld (sec_shift2+1),a
	ld (sec_shift_flag),a
	ld (write_end_flag),a ;
	

	ld a,(sec_shift)
	or a
	jr z,fwrite_scl3 ;если смещения нет, то первую часть пропустим
	

	ld c,a
	ld b,0
	ld hl,(temp_bc) ;проверка заполнится ли целый сектор
	add hl,bc
	
	ld a,1
	ld (write_end_flag),a ;флаг что не нужно дописывать остаток
	
	ld a,h
	or a
	jr nz,fwrite_scl4
	ld a,1
	ld (sec_shift_flag),a ;флаг что не заполнен сектор
	
fwrite_scl4	
	ld hl,sec_buf ;буфер последнего сектора	
	add hl,bc ;на этой точке остановились
	ex de,hl
	ld hl,(temp_hl) ;присоединим начало данных в конец предыдущих
	; ld a,c
	; or a
	; jr nz,fwrite_scl2
	; inc b ;коррекция
; fwrite_scl2		
	; ld c,a
	xor a
	sub c
	ld c,a ;сколько осталось перенести до заполнения сектора
	ld (sec_shift2),bc ;сохраним сколько добавили байт
	ldir

	ld a,(sec_shift_flag)
	or a
	jr nz,fwrite_scl3 ;если сектор ещё не заполнен писать не будем

	ld hl,sec_buf
	;ld de,(#5cf4)
	;ld (f_w_cur_trk),de	;запомним позицию
    ld      b,#01 ;пишем 1 сектор из буфера
    call    scl_write_buf	
	; ld a,c
	; cp 255
	; jp z,fwrite_no_chek ;выход если ошибка	

	xor a
	ld (write_end_flag),a ;флаг что нужно дописывать остаток	
	; ld de,(f_w_cur_trk) ;если сектор ещё не заполнен, останемся на старой позиции
	; ld (#5cf4),de
	; ld b,1 ;на сектор вперёд
	; ld de,(f_w_cur_trk)
	; call calc_next_pos
	; ld (f_w_cur_trk),de	

fwrite_scl3	
	ld hl,(temp_hl) ;запишем остаток данных
	;ld a,(sec_shift)
	;ld c,a
	;ld b,0
	ld bc,(sec_shift2)
	add hl,bc ;с этой точки пишем
	ld (temp_hl2),hl ;сохраним начало записи второго сектора
	
	ld hl,(temp_bc) ;вычисление на чём остановимся в этот раз
	and a
	sbc hl,bc ;вычтем то, что добавили к первому сектору
	ld c,l
	ld b,h
	jr nc,fwrite_scl5
	ld b,0 ;коррекция если вышел минус
fwrite_scl5
	ld hl,(temp_hl)
	add hl,bc 
	
	ld de,outputBuffer
	and a
	sbc hl,de
	
	ld a,l
	ld (sec_shift),a ;смещение на следующий раз
	;ld hl,(temp_hl)	
	

	; or a
	; jr z,fwrite_scl1
	; inc b  ;коррекция количества секторов
	
	ld a,b ;нужна проверка на количество секторов!!!
	ld (sec_part),a ;запомним сколько секторов во второй части
	
	;ld a,b	
	or a
	jr z,fwrite_scl1 ;если размер данных меньше сектора, то пропустим запись
	
	ld hl,(temp_hl2)
	;push bc
	;ld de,(#5cf4)
    ;ld      c,6 ;пишем целыми секторами
    call    scl_write_buf	
	;ld a,c
	;pop bc
	; cp 255
	; jp z,fwrite_no_chek ;выход если ошибка
	; ld de,(f_w_cur_trk)
	; call calc_next_pos
	; ld (f_w_cur_trk),de
	
	xor a
	ld (write_end_flag),a ;флаг что нужно дописывать остаток	
	
fwrite_scl1	
	ld a,(write_end_flag) ;нужно записывать остаток?
	or a
	jr nz,fwrite_scl_ex ;не нужно

	ld hl,(temp_hl2) ;сохраним незаписанный остаток
	ld a,(sec_part)
	ld b,a
	ld c,0
	add hl,bc
	ld de,sec_buf
	ld bc,256
	ldir
;fwrite_scl2	

	
fwrite_scl_ex	
	ld bc,(temp_bc) ;возвратим, что сколько запрашивали, столько и записали байт
	;посчитаем общую длину записанного
	ld hl,(f_w_len)
	add hl,bc
	ld (f_w_len),hl
	jr nc,fwrite_scl_ex1
	ld hl,(f_w_len+2)
	inc hl
	ld (f_w_len+2),hl
	
fwrite_scl_ex1
	xor a ;флаги сбросим
    ret






scl_write_buf ;заполнение промежуточного буфера
	push bc ;сколько пакетов указано в b
	ld de,scl_buf ;перенесём сектор во временный буфер
	ld bc,256
	ldir
	ld (scl_temp_hl2),hl ;сохраним адрес данных
	ld a,(scl_que) ;проверим флаг что нужны данные
	or a
	jr z,scl_write_buf_ret ;не будем вызывать парсер если не нужны
	ld hl,scl_write_buf_ret ;адрес возврата
	push hl
	ld hl,(scl_parse_ret_adr) ;адрес для продолжения основного цикла сборки
	jp (hl) ;отдадим пакет 256 байт парсеру
scl_write_buf_ret
	ld hl,(scl_temp_hl2)
	pop bc
	djnz scl_write_buf

	ret
	
	
	
scl_parse ;разбор образа scl в trd, основной цикл
	;получить первый сектор
;запрос порции данных по 256 байт
	ld (scl_temp_hl),hl
	ld (scl_temp_de),de
	ld (scl_temp_bc),bc
	ld a,1
	ld (scl_que),a ;включим флаг что нужны данные
	ld hl,scl_parse_ret ;сохраним адрес возврата
	ld (scl_parse_ret_adr),hl
	ret ;вернёмся для ожидания данных
scl_parse_ret	
	xor a
	ld (scl_que),a
	ld hl,(scl_temp_hl)
	ld de,(scl_temp_de)
	ld bc,(scl_temp_bc)
	
	ld de,scl_buf ;проверка метки образа
	ld hl,scl_sign
	ld b,8
scl_parse_chk
	ld a,(de)
	cp (hl)
	jr nz,scl_parse_chk_no
	inc hl
	inc de
	djnz scl_parse_chk
	jr scl_parse_chk_ok
scl_parse_chk_no ;если не совпало, значит плохой образ
    ld hl, scl_err
    call DialogBox.msgBox ;предуреждение
	xor a
	ld (scl_que),a ;выключим флаг что нужны данные
	ld a,4 ;закроем файл
	call fclose
	ret
scl_parse_chk_ok ;сигнатура правильная

;формирование каталога
	ld a,(scl_buf+8)
	ld (scl_files),a ;всего файлов
	ld (scl_cat_cycl),a ;цикл
	ld hl,scl_buf+9 ;адрес первого заголовка
	ld de,cat_buf ;адрес формируемого каталога trd
scl_parse_cat2	
	ld b,14 ;14 байт одна запись
scl_parse_cat	
	ld a,(hl)
	ld (de),a
	inc de
	inc l ;адрес увеличиваем только в пределах младшего регистра
	jr nz,scl_parse_cat1
	;тут пора запросить следующий сектор
;запрос порции данных по 256 байт
	ld (scl_temp_hl),hl
	ld (scl_temp_de),de
	ld (scl_temp_bc),bc
	ld a,1
	ld (scl_que),a ;включим флаг что нужны данные
	ld hl,scl_parse_ret1 ;сохраним адрес возврата
	ld (scl_parse_ret_adr),hl
	ret ;вернёмся для ожидания данных
scl_parse_ret1
	xor a
	ld (scl_que),a
	ld hl,(scl_temp_hl)
	ld de,(scl_temp_de)
	ld bc,(scl_temp_bc)
	
scl_parse_cat1
	djnz scl_parse_cat
	inc de
	inc de
	ld a,(scl_cat_cycl)
	dec a
	ld (scl_cat_cycl),a
	jr nz,scl_parse_cat2
	
	ld (scl_temp_hl),hl ;запомнить где остановились
	
;подсчёт секторов и дорожек
	push ix
	ld a,(scl_files)
	ld de,#0100 ;данные с первой дорожки
	ld ix,cat_buf
	ld (ix+14),e
	ld (ix+15),d
	ld hl,0 ;общее количество секторов
scl_cacl
	ld (scl_cat_cycl),a ;цикл
	ld a,(ix+13) ;длина файла в секторах
	ld c,a
	ld b,0
	add hl,bc ;секторов
	
	ld bc,16
	add ix,bc
	ld b,a
	call calc_next_pos
	ld a,(scl_cat_cycl)
	cp 1
	jr z,scl_cacl2 ;в последний раз пропусим
	ld (ix+14),e 
	ld (ix+15),d
scl_cacl2
	dec a
	jr nz,scl_cacl
	;теперь узнаем первый свободный сектор
	ld a,(ix+13) ;длина файла в секторах
	ld c,a
	ld b,0
	add hl,bc
	; ld b,a
	; call calc_next_pos
	ld (cat_buf+8*256+#e1),de ;Первый свободный сектор и дорожка на дискете
	ld de,16*159
	ex de,hl
	and a
	sbc hl,de
	ld (cat_buf+8*256+#e5),hl ;Число свободных секторов на диске
	pop ix


	
;запись содержимого файлов
	ld a,(scl_files) ;всего файлов
	ld (scl_cat_cycl),a ;цикл
	ld hl,cat_buf+13 ;адрес размер секторов файла
	ld (cat_cur_adr),hl

	ld hl,#0100 ;начиная с первой дорожки
	ld (#5cf4),hl
scl_parse_file2	
	ld hl,(scl_temp_hl) ;адрес данных
	ld de,(cat_cur_adr) ;адрес сектор дорожка файла
	;dec de
	ld a,(de) ;количество секторов, цикл
	ld c,a
scl_parse_file3
	ld de,scl_buf2 ;адрес ещё одного буфера
	ld b,0 ;256 байт один сектор, цикл
scl_parse_file	
	ld a,(hl)
	ld (de),a
	inc de
	inc l ;адрес увеличиваем только в пределах младшего регистра
	jr nz,scl_parse_file1
	;тут пора запросить следующий сектор
;запрос порции данных по 256 байт
	ld (scl_temp_hl),hl
	ld (scl_temp_de),de
	ld (scl_temp_bc),bc
	ld a,1
	ld (scl_que),a ;включим флаг что нужны данные
	ld hl,scl_parse_ret2 ;сохраним адрес возврата
	ld (scl_parse_ret_adr),hl
	ret ;вернёмся для ожидания данных
scl_parse_ret2
	xor a
	ld (scl_que),a
	ld hl,(scl_temp_hl)
	ld de,(scl_temp_de)
	ld bc,(scl_temp_bc)
	
scl_parse_file1
	djnz scl_parse_file
	ld (scl_temp_hl),hl	
	ld (scl_temp_bc),bc
	
	ld hl,scl_buf2 ;;запишем один сектор
	ld  de,(#5cf4)
    ld      bc,#0106 ;
    call    #3d13	
	; ld a,c
	; cp 255
	; jp z,fwrite_no_chek ;выход если ошибка	
	ld hl,(scl_temp_hl)
	ld bc,(scl_temp_bc)
	
	dec c
	jr nz,scl_parse_file3
	
	ld hl,(cat_cur_adr) ;адрес сектор дорожка файла
	; ld e,(hl)
	; inc hl
	; ld d,(hl)
	ld bc,16
	add hl,bc ;на следующий файл
	ld (cat_cur_adr),hl	
	
	
	ld a,(scl_cat_cycl)
	dec a
	ld (scl_cat_cycl),a
	jr nz,scl_parse_file2	;на следующий файл
	
	

;формирование системного сектора №9 (8)
	;
	;ld (cat_buf+8*256+#e1),a ;// #E1 Первый свободный сектор на дискете
	;
	;ld (cat_buf+8*256+#e2),a ;// #E2 Первый свободный трек
	ld a,#16
	ld (cat_buf+8*256+#e3),a ;// #E3 16 80 дорожек, 2 стороны
	ld a,(scl_files)
	ld (cat_buf+8*256+#e4),a ;// #E4 Общее количество файлов записанных на диск
	;
	;ld (cat_buf+8*256+#e5),a ;// #Е5,Е6 Число свободных секторов на диске
	;ld (cat_buf+8*256+#e6),a
	ld a,#10
	ld (cat_buf+8*256+#e7),a ;// #E7 Код  #10,определяющий принадлежность к TR-DOS	

	ld hl,f_name ;запишем имя диска, взяв для этого имя файла
	ld de,cat_buf+8*256+#f5 ;// #F5-#FC Имя диска в ASCII формате
	ld bc,8
	ldir
	
	ld hl,cat_buf ;запишем каталог на диск
	ld de,0
    ld      bc,#0906 ;
    call    #3d13	
	; ld a,c
	; cp 255
	; jp z,fwrite_no_chek ;выход если ошибка	
	ret


;-----------scl end --------------------









    
; A - file stream id
; fsync:
;     esxCall ESX_FSYNC
    ; ret


; HL - name (name.ext)
; Returns:
; HL - name (name    e)	
format_name ;подгоняет имя файла под стандарт trdos (8+1)

	;сначала попробуем убрать из пути подпапку, если она есть
	ld (temp_hl),hl ;сохраним адрес исходного имени
	ld b,#00 ;не больше 255 символов	
format_name5	
	ld a,(hl)
	cp "/" ;если есть подпапка
	jr z,format_name_path_yep
	ld a,(hl)
	cp "." ;если ещё не дошли до расширения
	jr nz,format_name6
	ld hl,(temp_hl) ;если дошли до расширения, то путей нет, вернёмся на начало имени
	jr format_name_7 ;на выход
format_name6
	inc hl
	djnz format_name5
	
format_name_path_yep ;нашли
	inc hl ;пропустим знак "/"
	
format_name_7	


	push hl ;очистим место для нового имени
	ld hl,f_name
	ld de,f_name+1
	ld (hl)," "
	ld bc,8
	ldir
	pop hl

	ld bc,#09ff ;длина имени 9 символов
	ld de,f_name ;куда
format_name2	
	ld a,(hl)
	cp "."
	jr nz,format_name1
	inc hl
	ld a,(hl)
	ld (f_name+8),a ; и в конце первую букву расширения
	ex de,hl ;сохраним адрес исходного расширения
	jr format_name_e
format_name1
	ldi
	djnz format_name2
	
	;если имя длинное, пропустим лишнее до расширения
	ld b,#00 ;не больше 255 символов	
format_name3	
	ld a,(hl)
	cp "."
	jr nz,format_name4
	inc hl
	ld a,(hl)
	ld (f_name+8),a ; и в конце первую букву расширения
	ex de,hl ;сохраним адрес исходного расширения
	jr format_name_e
format_name4
	inc hl
	djnz format_name3
	
format_name_e ;выход
	ld hl,f_name ;вернём результат
	ret

; DE - trk/sec
; B - sectors step
; Returns:
; DE - trk/sec	
calc_next_pos		;вперёд на N секторов	
			;ld b,4 
			;ld  de,(#5ceb) 
calc_next_pos2		
			inc e
			ld a,e
			cp 16
			jr c,calc_next_pos1
			inc d
			ld e,0
calc_next_pos1
			;ld (#5ceb),de
			djnz calc_next_pos2
			ret
			

;testt db "123.trd"
write_ima db "Insert disk to drive "
write_ima_d db "A. "
		db "All data will be lost!",0
		
trdExt1 db ".trd", 0
trdExt2 db ".TRD", 0

sclExt1 db ".scl", 0
sclExt2 db ".SCL", 0

f_name ds 9 ;имя файла
f_r_cur_trk dw 	 0 ;текущие сектор-дорожка файла на чтение
f_r_len_sec db 0 ;длина файла на чтение в секторах
f_r_flag db 0 ;флаг что открыт файл на чтение

f_w_cur_trk dw 	 0 ;текущие сектор-дорожка файла на запись
f_w_len_sec db 0 ;длина файла на запись в секторах
f_w_flag db 0 ;флаг что открыт файл на запись
f_w_len ds 4 ;длина записанных данных
write_end_flag db 0 ;флаг что нужно записать остаток

temp_bc dw 0 ;хранение регистра 
temp_hl dw 0 ;хранение регистра 
temp_hl2 dw 0 ;хранение регистра 

sec_shift db 0 ;указатель на каком байте остановлена запись
sec_shift2 db 0 ;указатель на каком байте остановлена запись (остаток)
sec_part db 0 ;сколько секторов во второй порции для записи
sec_shift_flag db 0 ;флаг что буфер сектора не заполнен

;секция scl
scl_sign db "SINCLAIR" ;метка
scl_que db 0 ;флаг запроса порции данных
scl_err db "SCL image error!",0
scl_parse_ret_adr dw 0; адрес возврата в цикл
scl_cat_cycl db 0 ;переменная цикла
scl_files db 0 ;всего файлов
scl_temp_hl dw 0;;хранение регистра
scl_temp_hl2 dw 0;
scl_temp_de dw 0;
scl_temp_bc dw 0;
cat_cur_adr dw 0;
;scl end
	align 256 ;временно
	;по адресу #4000 шрифт
cat_buf equ #4800 ;буфер для кататога диска 9*256
sec_buf equ cat_buf + 9*256 ;буфер сектора для записи 256
scl_buf equ sec_buf + 512 ;промежуточный буфер 256
scl_buf2 equ scl_buf + 512 ;промежуточный буфер 256

    ENDMODULE