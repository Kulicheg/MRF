
    MODULE TextMode
pg4	defb 0
pg0	defb 0
pgC	defb 0
pg8	defb 0
init
	ld c,nos.CMD_HIDEFROMPARENT
	call nos.BDOS
	ld e,0x86
	ld c,nos.CMD_SETGFX
	call nos.BDOS
	ld c,nos.CMD_YIELD
	call nos.BDOS
	ld c,nos.CMD_GETMAINPAGES
	call nos.BDOS
	ld (pg4),de
	ld (pgC),hl
	jp cls
	
printZ
	ld a,(hl)
	or a
	ret z
	inc hl
	push hl
	rst 0x10
	pop hl
	jr printZ
	
cls	
	ld e,7
	ld c,nos.CMD_CLS
	jp nos.BDOS
	
putC
	jp 0x0010
	
gotoXY
	push hl
	ld c,nos.CMD_SETXY
	call nos.BDOS
	pop hl
	ret
	
fillLine:
    ld d, h, e, 0 : call gotoXY
    ld b, 80
.loop
    push af, bc
    rst 0x10
    pop bc, af
    djnz .loop
    ret
	
usualLine
	ld d,a
	ld e,0
.mloop
	push de
	ld c,nos.CMD_SETXY
	call nos.BDOS
	ld e,7
	ld c,nos.CMD_PRATTR
	call nos.BDOS
	pop de
	inc e
	ld a,e
	cp 80
	jr nz,.mloop
	ret

highlightLine	
	ld d,a
	ld e,0
.mloop
	push de
	ld c,nos.CMD_SETXY
	call nos.BDOS
	ld e,79
	ld c,nos.CMD_PRATTR
	call nos.BDOS
	pop de
	inc e
	ld a,e
	cp 80
	jr nz,.mloop
	ret
    ENDMODULE
