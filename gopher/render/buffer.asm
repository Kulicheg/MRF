; BC - line count
findLine
    ld hl, outputBuffer
findLine2    
    ld a,b
    or c
    jp z, .checkEmpty
.loop
    ld a, (hl)
    and a
    jp z, .nope 
    inc hl
    cp 13
    jp z, .checkLF  ;13
    cp 10 : jp z, .nextCheck     ;10
    jp .loop
.nextCheck
    and a
    jp z, .nope
    dec bc
    ld d,a
    ld a,b
    or c
    ld a,d
    jp nz, .loop
    ret
.checkLF
    ld a, (hl)
    cp 10
    jp nz, .nextCheck    ;10
    inc hl
    jp  .nextCheck
.checkEmpty
    ld a, (hl) : and a : ret nz
.nope
    ld hl, 0 : ret
