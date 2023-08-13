    module ScreenViewer
PGT EQU 0		; начало таблицы шаблонов screen2
CT EQU #2000
display:

	ld a,2			; screen2
	call CHGMOD
    ;ld hl,MSX1paletteData
	;call set_palette_registre

	ld hl,outputBuffer
	ld ix,outputBuffer + 0x2000

	ld a,3			; 3 сегмента экрана
loop3:
	ex af,af'
	push hl
	ld c,0			
loop256:
	ld b,8
	push hl
loop8:
	ld a,(hl)
	ld (ix+0),a
	ld de,#0100
	add hl,de
	inc ix
	djnz loop8
	pop hl
	inc hl
	dec c
	jr nz,loop256
	pop hl
	ld de,2048
	add hl,de
	ex af,af'
	dec a
	jr nz,loop3

	ld hl,outputBuffer + 0x2000
	ld de,PGT
	ld bc,6144
	call LDIRVM
	
	;jr keywait

	ld bc,768
	ld hl,outputBuffer+6144
	ld de,outputBuffer + 0x2000
colorloop2:
	push bc
	ld b,8
	ld a,(hl)
	call convertpalete
colorloop1:
	ld (de),a
	inc de
	djnz colorloop1
	inc hl
	pop bc
	dec bc
	ld a,b
	or c
	jr nz,colorloop2

	ld hl,outputBuffer + 0x2000
	ld de,CT
	ld bc,6144
	call LDIRVM

keywait:	
	RST #30			; Читает один символ из буфера клавиатуры. Если буфер пуст,
	db 0			; выводит курсор и ждет нажатия клавиши.
 	dw #009F 		; CHGET A = код символа	

	xor a			; screen0
	call CHGMOD
    call TextMode.loadFont
    call TextMode.init
    jp History.back
	ret
convertpalete:
	push hl
	push de
	push bc
	ld b,a
	and #07
	ld hl,colors0
	bit 6,b
	jr z,col0
	ld hl,colors1
col0:
	ld d,0
	ld e,a
	add hl,de
	ld a,(hl)
	and a
	rlca
	rlca
	rlca
	rlca
	ld c,a
	ld a,b
	rrca
	rrca
	rrca
	and #07
	ld hl,colors0
	bit 6,b
	jr z,col00
	ld hl,colors1
col00:
	ld d,0
	ld e,a
	add hl,de
	ld a,(hl)
	or c
	pop bc
	pop de
	pop hl
	ret

calcxy:
	ld a,e
	and #18
	or #40
	ld h,a
	ld a,e
	and #07
	rrca
	rrca
	rrca
	add a,d
	ld l,a
	ret
;-----------------------------------------------------------------------------------
; Routine to set colors palette MSX1 like
 
VDP_DW	equ	#00007
RG16SAV	equ	#FFEF
 
MSX1palette:
	ld	a,(VDP_DW)
	ld	c,a		; C= CPU port connected to the VDP writing port #1
 
	xor	a		; Set color 0 ...
	di
	out	(c),a
	ld	(RG16SAV),a
	ld	a,#80+16	; ...into register 16 (+80h)
	out	(c),a
	ei
 
	inc	c		; C= CPU port connected to the VDP writing port #2
	ld	b,31
	ld	hl,MSX1paletteData
	otir
	ret
 
set_palette_registre:
	xor a
	out (#99),a		; номер регистра цвета
	ld a,#90		; reg 16(#10) +7бит=1(запись)
	nop
	out (#99),a
	ld a,16			; сколько регистров
	ld c,#9A		; Color Palette Register
set_palette_loop:
	outi			; SET RED BLUE
	outi			; SET GREEN
	dec a
	jr nz, set_palette_loop
	ret

MSX1paletteData:
	db	00h,0	; Color 0
	db	00h,0	; Color 1
	db	11h,5	; Color 2
	db	33h,6	; Color 3
	db	26h,2	; Color 4
	db	37h,3	; Color 5
	db	52h,2	; Color 6
	db	27h,6	; Color 7
	db	62h,2	; Color 8
	db	63h,3	; Color 9
	db	52h,5	; Color A
	db	63h,6	; Color B
	db	11h,4	; Color C
	db	55h,2	; Color D
	db	55h,5	; Color E
	db	77h,7	; Color F
;----------------------------------------------------------------------------------

WRTVRM:	
	rst #30
	db 0		
	dw #004D		
	ret
LDIRVM:				; копирует блок данных из RAM в VRAM
	RST #30
	db 0
	dw #005C
	ret
CHGMOD:
	rst #30
	db 0
	dw #005F
	ret

colors0:
	db #01,#04,#08,13,#02,7,10,14
colors1:
	db #01,#05,#09,13,#03,7,11,15
    endmodule