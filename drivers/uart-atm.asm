    MODULE Uart
init:
;инициализируем порт
		di
		ld	bc,#55FE	;55FEh
		in	a,(c)		;Переход в режим команды
		ld	b,0xc3		;команда - установить скорость порта
		in	a,(c)
		ld	b,3			;параметр - установить скорость порта 19200(6) 38400(3) 115200(1) 57600(2) 9600(12) 14400(8)
		in	a,(c)
		ei
		ret
read:
		di
read2:
		ld	bc,#55FE	;55FEh
		in	a,(c)		;Переход в режим команды
		ld	b,0xc2		;команда - чтение счетчика буфера приема
		in	a,(c)		;Получили число байт в буфере
		or a
		jp nz,togetb	; В буфере есть байт
		call startrts2	; в буфере нет байта, приподнимем на секундочку RTS
		jp read2		; А теперь есть?

togetb:		
		ld	bc,#55FE	;подать комнаду контроллеру клавиатуры
		in	a,(c)		;Переход в режим команды
		ld	b,#02		;команда - чтение 
		in	a,(c)		;Получаем байт в А
		ei
		ret	

write: 
		di
		push bc
		push de		

		ld  d, a		;В А получаем байт, сораняем его в D
readytx:
		ld	bc,#55FE	;55FEh
		in	a,(c)		;Переход в режим команды
		ld	b,#42		;команда - прочесть статус
		in	a,(c)
		bit	 6,a		;Параметры - TX 
		jp z,readytx	; вернуться если байта нет

		ld	bc,#55FE	;55FEh
		in	a,(c)		;Переход в режим команды
		ld	b,#03		;запись
		in	a,(c)
		ld	b,d			;БАЙТ для пересылки
		in	a,(c)		; ->
		pop de
		pop bc
		ei		
		ret

startrts2
		ld	bc,#55FE	;55FEh
		in	a,(c)		;Переход в режим команды
		ld	b,#43		;команда - установить статус
		IN	a,(c)
		ld	b,#03		;Параметры - убрать RTS (START)
		in	a,(c)
		ld  b,10
loop
		djnz loop
		ld	bc,#55FE	;55FEh
		in	a,(c)		;Переход в режим команды
		ld	b,#43		;команда - установить статус
		in	a,(c)
		ld	b,0			;Параметры - установить RTS (STOP)
		in	a,(c)
		ret

    ENDMODULE
