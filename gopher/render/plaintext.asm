renderPlainTextScreen:
    call prepareScreen
    ld b, PER_PAGE
.loop
    push bc
    ld a, PER_PAGE
    sub b
    ld b,a
    ld e,a
    ld c,b
    ld b,0
    ld hl, (page_offset)
    add hl,bc
    ld bc,hl
    push de
    call Render.findLine
    pop de
    ld a, h : or l : jp z, .exit
    ld a, e
    add CURSOR_OFFSET : ld d, a, e, 1 : call TextMode.gotoXY
    call print70Text
    pop bc 
    djnz .loop
    ret
.exit
    pop bc
    ret

plainTextLoop:
    call Console.getC

    cp '1' : jp z, History.back
    cp '2' : jp z, navigate
    cp '5' : jp z, textUp
    cp '8' : jp z, textDown
    cp Console.KEY_LT : jp z, textUp
    cp Console.KEY_RT : jp z, textDown

    cp Console.KEY_DN : jp z, textDown
    cp 'a' : jp z, textDown

    cp Console.KEY_UP : jp z, textUp
    cp 'q' : jp z, textUp
    
    cp 'h' : jp z, History.home
    cp 'H' : jp z, History.home

    cp 'b' : jp z, History.back
    cp 'B' : jp z, History.back
    
    cp 'd' : jp z, inputHost
    cp 'D' : jp z, inputHost

    cp Console.BACKSPACE : jp z, History.back
    
    IFDEF MSX
    	cp ESC : jp z, exit
    ENDIF
     
    IFDEF GS
    cp 'M' : call z, GeneralSound.toggleModule
    cp 'm' : call z, GeneralSound.toggleModule
    ENDIF

    IFDEF TIMEX80
    cp 'T' : call z, TextMode.toggleColor
    cp 't' : call z, TextMode.toggleColor
    ENDIF

    jp plainTextLoop


textDown:
    ld hl,(page_offset)
    ld de,PER_PAGE
    add hl,de
    ld (page_offset), hl
    call renderPlainTextScreen
    jp plainTextLoop

textUp:
    ld a, (page_offset) : cp 0 : jr nz, .textUp2
    ld a, (page_offset + 1) : cp 0 : jr nz, .textUp2
    jp plainTextLoop

.textUp2:
    ld hl,(page_offset)
    ld de,PER_PAGE
    sbc hl,de
    ld (page_offset), hl
    call renderPlainTextScreen
    jp plainTextLoop    
