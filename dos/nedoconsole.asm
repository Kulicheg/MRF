    
	    module Console
KEY_UP = nos.key_up
KEY_DN = nos.key_down
KEY_LT = nos.key_left
KEY_RT = nos.key_right
BACKSPACE = nos.key_backspace
getC:
    call inkey
.loop
    push af
    call inkey
    pop bc
    cp b 
    jr z, .loop
.exit
    ret

peekC:
inkey
	ld c,nos.CMD_YIELD
	call nos.BDOS
	rst 0x08
	ld a,c
	cp nos.key_esc
	jp z,0x0000
	ret
waitForKeyUp
	call inkey
	or a
	ret z
	jr waitForKeyUp


getCint:
    call inkey2
.loop2
    push af
    call inkey2
    pop bc
    cp b 
    jr z, .loop2
.exit2
    ret

peekCint:
inkey2
	ld c,nos.CMD_YIELD
	call nos.BDOS
	rst 0x08
	cp nos.key_esc
	jp z,0x0000
	ret
waitForKeyUp2
	call inkey2
	or a
	ret z
	jr waitForKeyUp2

    ENDMODULE
