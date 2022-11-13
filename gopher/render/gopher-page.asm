renderGopherScreen:
    call Render.prepareScreen
    ld b, PER_PAGE
.loop
    push bc
    ld a, PER_PAGE : sub b
    
    ld b, a
    ld e, a
    ld a, (page_offset)
    add b
    ld c, a
    ld b,0
    push de
    call findLine
    pop de
    
    
    ld a, h : or l : jr z, .exit
    ld a, e : call renderRow
.exit
    pop bc 
    djnz .loop
    call showCursor
    ret

checkBorder:
    ld a, (cursor_position) : cp #ff : jp z, pageUp
    ld a, (cursor_position) : cp PER_PAGE : jp z, pageDn
    call showCursor
    jp workLoop

workLoop:
    ld a, (play_next) : and a : jp nz, navigate

    dup 5
    halt
    edup
.nothing
    call Console.peekC
    and a : jp z, .nothing

    cp '1' : jp z, History.back
    cp '2' : jp z, navigate
    cp '3' : jp z, cursorDown
    cp '4' : jp z, cursorUp
    cp '5' : jp z, pageUp
    cp '8' : jp z, pageDn
    cp '6' : jp z, cursorDown
    cp '7' : jp z, cursorUp

    cp Console.KEY_DN : jp z, cursorDown
    cp 'a' : jp z, cursorDown
    cp Console.KEY_UP : jp z, cursorUp
    cp 'q' : jp z, cursorUp
    cp Console.KEY_LT : jp z, pageUp
    cp 'o' : jp z, pageUp
    cp Console.KEY_RT : jp z, pageDn
    cp 'p' : jp z, pageDn

    cp 'h' : jp z, History.home
    cp 'H' : jp z, History.home

    cp 'b' : jp z, History.back
    cp 'B' : jp z, History.back
    cp Console.BACKSPACE : jp z, History.back

    cp 'd' : jp z, inputHost
    cp 'D' : jp z, inputHost

    cp CR : jp z, navigate

    IFDEF GS
    cp 'M' : call z, GeneralSound.toggleModule
    cp 'm' : call z, GeneralSound.toggleModule
    ENDIF
    
    IFDEF TIMEX80
    cp 'T' : call z, TextMode.toggleColor
    cp 't' : call z, TextMode.toggleColor
    ENDIF

    jp workLoop

navigate:
    call Console.waitForKeyUp
    xor a : ld (play_next), a
    
    call hideCursor
test001:
;    ld a, (page_offset), b, a, a, (cursor_position) : add b : ld b, a : call Render.findLine
    ld bc, (page_offset)
    ld hl, (cursor_position)
    add hl,bc
    ld b, h ;HHHHH
    ld c, l ;LLLLL
    push de
    call Render.findLine
    pop de
    ld a, (hl)
    cp '1' : jp z, .load
    cp '0' : jp z, .load
    cp '9' : jp z, .load
    cp '7' : jp z, .input
    call showCursor
    jp workLoop
.load
    push hl
    call getIcon 
    pop hl
    jp History.navigate
.input
    push hl
    call DialogBox.inputBox
    pop hl
    ld a, (DialogBox.inputBuffer) : and a : jp z, History.load
    jp .load

showCursor:
    ld a, (cursor_position) : add CURSOR_OFFSET
    jp TextMode.highlightLine

hideCursor:
    ld a, (cursor_position) : add CURSOR_OFFSET
    jp TextMode.usualLine

cursorDown:
    call hideCursor
    ld hl, cursor_position
    inc (hl)
    jp checkBorder

cursorUp:
    call hideCursor
    ld hl, cursor_position
    dec (hl)
    jp checkBorder

pageUp:
    ld a, (page_offset) : cp 0 : jp nz, .pageUp2
    ld a, (page_offset + 1) : cp 0 : jp nz, .pageUp2
    jp .skip
.pageUp2:    
    ld a, PER_PAGE - 1 : ld (cursor_position), a
    ld hl, (page_offset)
    ld de,PER_PAGE
    sbc hl,de
    ld (page_offset), hl
.exit
    call renderGopherScreen
    jp workLoop
.skip
    xor a : ld (cursor_position), a : call renderGopherScreen : jp workLoop

pageDn:
     xor a : ld (cursor_position), a
    ld hl,(page_offset)
    ld de,PER_PAGE
    add hl,de
    ld (page_offset), hl
    jp pageUp.exit



