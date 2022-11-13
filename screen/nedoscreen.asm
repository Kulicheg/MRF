	
	module ScreenViewer
display:
    call Console.waitForKeyUp
	ld e,0x83
	ld c,nos.CMD_SETGFX
	call nos.BDOS
	ld a,(nos.user_scr0_high)
	rst 0x28
    ld hl, outputBuffer, de, #c000, bc, 6912 : ldir
    xor a : out (#fe), a
.wait
    call Console.getC
	ld e,0x86
	ld c,nos.CMD_SETGFX
	call nos.BDOS
	ld a,(TextMode.pgC)
	rst 0x28
    call TextMode.cls
    jp History.back
    endmodule