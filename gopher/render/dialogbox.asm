    module DialogBox

inputBox:
    xor a : ld (inputBuffer), a
.noclear
    call drawBox
.loop
    ld de, #0B05 : call TextMode.gotoXY
    ld hl, inputBuffer : call TextMode.printZ
    ld a, MIME_INPUT : call TextMode.putC : ld a, ' ' : call TextMode.putC
.checkkey
    call Console.peekC
    cp 00 :  jp z, .checkkey
    cp CR : ret z
    
    IFNDEF MSX
    dup 11
    halt
    edup
    ENDIF

    cp Console.BACKSPACE : jr z, .removeChar
    cp SPACE : jr c, .checkkey
.putC
    ld e, a
    xor a : ld hl, inputBuffer, bc, #ff : cpir
    ld (hl), a : dec hl : ld (hl), e 
    jr .loop
.removeChar
    xor a
    ld hl, inputBuffer, bc, #ff : cpir
    push hl
        ld de, inputBuffer + 1
        or a : sbc hl, de
        ld a, h : or l
    pop hl
    jr z, .loop
    xor a
    dec hl : dec hl : ld (hl), a 
    jr .loop


namedownload
    IFDEF NEDOOS
		db "..",92,"downloads",92
    ENDIF

inputBuffer ds 80

msgBox:
    call msgNoWait
    ld b, 150
.loop
    halt
    djnz .loop
    ret

msgNoWait:
    push hl
    call drawBox
    pop hl
    jp TextMode.printZ

drawBox:
    ld h, #0a, a, BORDER_TOP
    call TextMode.fillLine
    ld h, #0b, a, ' '
    call TextMode.fillLine
    ld h, #0c, a, BORDER_BOTTOM
    call TextMode.fillLine
    ld a, #0a
    call TextMode.highlightLine
    ld a, #0c
    call TextMode.highlightLine
    ld de,#0B03
    call TextMode.gotoXY 
    ret
    endmodule
