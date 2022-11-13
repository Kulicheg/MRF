	MODULE Dos
	
FMODE_READ = #01
FMODE_CREATE = #0E

; HL - filename in ASCIIZ
loadBuffer:
    ld b, Dos.FMODE_READ: call Dos.fopen
    push af
        ld hl, outputBuffer, bc, #ffff - outputBuffer : call Dos.fread
        ld hl, outputBuffer : add hl, bc : xor a : ld (hl), a : inc hl : ld (hl), a
    pop af
    call Dos.fclose
    ret
	ret

; Opens file on default drive
; B - File mode
; HL - File name
; Returns:
;  A - file stream id
fopen
	ex de,hl
	ld c,nos.CMD_OPENHANDLE
	ld a,b
	cp FMODE_CREATE
	jr nz,.noncreate
	ld c,nos.CMD_CREATEHANDLE	
.noncreate
	call nos.BDOS
	ld a,b
	ret

; A - file stream id
; BC - length
; HL - buffer
; Returns:
;   BC - actually written bytes
fwrite
	ex de,hl
	ld h,b
	ld l,c
	ld b,a
	ld c,nos.CMD_WRITEHANDLE
	call nos.BDOS
	ld b,h
	ld c,l
	ret
	
; A - file stream id
fclose
	ld b,a
	ld c,nos.CMD_CLOSEHANDLE
	call nos.BDOS
	ret
	
; A - file stream id
; BC - length
; HL - buffer
; Returns
;  BC - length(how much was actually read) 
fread:
	ex de,hl
	ld h,b
	ld l,c
	ld b,a
	ld c,nos.CMD_READHANDLE
	call nos.BDOS
	ld b,h
	ld c,l
	ret
    ENDMODULE
	