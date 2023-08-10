LINE_LIMIT = 63

    IFDEF NEDOOS
LINE_LIMIT = 79
    ENDIF

    IFDEF TIMEX80
LINE_LIMIT = 84
    ENDIF

    IFDEF MSX
LINE_LIMIT = 79
    ENDIF
; HL - string pointer
print70Text:
    ld b, LINE_LIMIT
.loop
    ld a, (hl)
    and a : ret z
    cp 13 : ret z
    cp 10 : ret z
    push bc
    push hl
    call TextMode.putC
    pop hl
    inc hl
    pop bc
    dec b
    ld a, b : and a: ret z
    jp .loop

; HL - string pointer
print70Goph:
    ld b, LINE_LIMIT
.loop
    ld a, (hl) : cp 09 : ret z
    and a : ret z
    push bc
    push hl
    call TextMode.putC
    pop hl
    inc hl
    pop bc
    dec b
    ld a, b : and a: ret z
    jp .loop