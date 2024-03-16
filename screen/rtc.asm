printRTC
	IFDEF RTC
	call Clock.readTime	

	ld a, (oldminutes)
	ld d,a
	ld a, (minutes)
	cp d					; Update only if minutes changed
	ret z
	ld (oldminutes), a

	ld d,1 ;Є??а¤Ё? вл Y,X
	ld e,SCREEN_WIDTH - 7
	call TextMode.gotoXY
	ld a,'['
	call TextMode.putC
	ld h,0
	ld a,(hours) ;часы
	ld l,a
	call toDecimal
	ld hl,decimalS+3
	call TextMode.printZ
	ld a,':'
	call TextMode.putC
	ld h,0
	ld a,(minutes) ;минуты
	ld l,a
	call toDecimal
	ld hl,decimalS+3
	call TextMode.printZ
	;ld a,':'
	;call TextMode.putC
	;ld h,0
	;ld a,(seconds) ;секунды
	;ld l,a
	;call toDecimal
	;ld hl,decimalS+3
	;call TextMode.printZ
	ld a,']'
	call TextMode.putC
	ret

toDecimal		;конвертирует 2 байта в 5 десятичных цифр
				;на входе в HL число
	ld de,10000 ;десятки тысяч
	ld a,255
toDecimal10k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal10k
	add hl,de
	add a,48
	ld (decimalS),a
	ld de,1000 ;тысячи
	ld a,255
toDecimal1k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal1k
	add hl,de
	add a,48
	ld (decimalS+1),a
	ld de,100 ;сотни
	ld a,255
toDecimal01k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal01k
	add hl,de
	add a,48
	ld (decimalS+2),a
	ld de,10 ;десятки
	ld a,255
toDecimal001k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal001k
	add hl,de
	add a,48
	ld (decimalS+3),a
	ld de,1 ;единицы
	ld a,255
toDecimal0001k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal0001k
	add hl,de
	add a,48
	ld (decimalS+4),a		
	ret
hours
	db 0
minutes
	db 0
seconds
	db 0
decimalS	ds 7 ;десятичные цифры
	ENDIF	
	ret
oldminutes		; не убирать под услоаие
	db 255



	