; BC - line count

findLine:
    ld hl, outputBuffer
    ld a,b
    or c
    jp z, .checkEmpty
.preloop
    ld d,13
.loop
    ld a, (hl) : and a : jp z, .nope 
    cp d : inc hl : jp z, .checkLF  ;13
    cp 10 : jp z, .nextCheck     ;10
    jp .loop
.nextCheck
    and a : jp z, .nope
    dec bc
    ld e,a
    ld a,b
    or c
    ld a,e
    jp nz, .loop
    ret
.checkLF
    ld a, (hl)
    cp 10 : jp nz, .nextCheck    ;10
    inc hl
    jp  .nextCheck
.checkEmpty
    ld a, (hl) : and a : ret nz
.nope
    ld hl, 0 : ret


    /*
findLine:
    ld de,bc

    ld hl, outputBuffer
    xor a : or b : jr z, .checkEmpty


    ld b,e
    dec de
    inc d


.loop
    ld a, (hl) : and a : jr z, .nope 
    cp 13 : inc hl : jr z, .checkLF
    cp 10 : jr z, .nextCheck
    jr .loop
.nextCheck
    and a : jr z, .nope
    djnz .loop
    dec d
    jp nz, .loop
    ret
.checkLF
    ld a, (hl)
    cp 10 : jr nz, .nextCheck
    inc hl
    jr  .nextCheck
.checkEmpty
    ld a, (hl) : and a : ret nz
.nope
    ld hl, 0 : ret
    */