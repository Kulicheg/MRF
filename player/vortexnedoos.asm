    MODULE VortexProcessor
play:
    ld a, 255
    ld (oldminutes), a

    call Console.waitForKeyUp

    ld hl, message : call DialogBox.msgNoWait

    ld hl, outputBuffer  : call VTPL.INIT
    
    
    ld a, 0, (Render.play_next), a
    ifdef GS
    call GeneralSound.stopModule
    endif
	ld a,(TextMode.pg4)
	ld hl,VTPL.PLAY
	ld c,nos.CMD_SETMUSIC
	ex af,af'
	call nos.BDOS
    call Console.getC
	ld a,(TextMode.pg4)
	ld hl,fakemod.fakeret
	ld c,nos.CMD_SETMUSIC
	ex af,af'
	call nos.BDOS
    call VTPL.MUTE
    call Console.waitForKeyUp
    ret
	
message db "    Press key to stop...", 0
    ENDMODULE
	org 0x4000
	
    include "player.asm"
	MODULE fakemod
fakeret
	ret
    ENDMODULE
    