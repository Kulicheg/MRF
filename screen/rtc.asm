printRTC
	ifdef SMUCRTC
	;печать текущего времени
	call Clock.readTime
	jr nc,read_time_ok
	; ld hl,mes_no_RTC
	; call print_mes
	; scf
	ret ;выход	
read_time_ok
	push bc
	ld l,e ;часы
	ld h,0
	call toDecimal
	ld de,00 ;координаты
	call TextMode.gotoXY
	ld hl,decimalS+3
	call TextMode.printZ
	ld a,":"
	call TextMode.putC
	pop bc
	ld l,b ;минуты
	ld h,0
	call toDecimal
	ld hl,decimalS+3
	call TextMode.printZ
	; ld a,":"
	; call TextMode.putC
	; ld l,c ;секунды
	; ld h,0
	; call toDecimal
	; ld hl,decimalS+3
	; call TextMode.printZ
	; or a ;нет ошибки
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
	
	ENDIF

	IFDEF NOSRTC
	call Clock.readTime	;bc=date, hl=time

	push hl
	pop de
	ld a,e
    add a,a
    and 63	;seconds
	ld (seconds),a
    	
	ld a,d
    rra
    rra
    rra
    and 31 		;hours
	ld (hours),a

    ex de,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ex de,hl
    ld a,d
    and 63       ;minutes
 	ld (minutes),a

;        ld a,h
;        srl a
;        ;sub 20
;        ld b,0x93		;year
;        call send2ve
;
;        ld a,l
;        and 31
;        ld b,0x13		;day
;        call send2ve
;    
;        add hl,hl
;        add hl,hl
;        add hl,hl
;        ld a,h
;        and 15
;        ld b,0x53	        ;month
;        call send2ve
	ld a, (oldminutes)
	ld d,a
	ld a, (minutes)
	cp d
	ret z
	ld (oldminutes), a

	ld d,1 ;координаты
	ld e,73
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
	ENDIF	

	IFDEF MSX
	ENDIF

	ret
decimalS	ds 6 ;десятичные цифры

oldminutes
	db 255


	