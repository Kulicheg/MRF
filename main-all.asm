    device	zxspectrum128
    IFDEF NEDOOS
	DEFINE CRLF "\r\n"
        MODULE nos
            include "../_sdk/sysdefs.asm"
        ENDMODULE
        org nos.PROGSTART
        ELSE
	DEFINE CRLF "\r"
        org 24576
    ENDIF
asmOrg:
    align 256
    jp start
    include "vdp/index.asm"
    include "utils/index.asm"
    include "gopher/render/index.asm"
    include "dos/index.asm"
    include "gopher/engine/history/index.asm"
    include "gopher/engine/urlencoder.asm"
    include "gopher/engine/fetcher.asm"
    include "gopher/engine/media-processor.asm"
    include "gopher/gopher.asm"
    include "drivers/index.asm"
    include "screen/rtc.asm"

    IFDEF NEDOOS
    ;Gap about 8kb, CMD_SETMUSIC 0x4000 mandatory
    ;Stack down from 0x4000
        include "screen/nedoscreen.asm"
        include "player/mod-processor.asm"
        include "player/vortexnedoos.asm"

start:
outputBuffer:
        ld sp, 0x4000
        ld c,nos.CMD_SETSYSDRV
     	ex af,af'   
	    call nos.BDOS
	ELSE
        include "player/mod-processor.asm"
        include "screen/screen.asm"
        include "player/vortex-processor.asm"

start:
outputBuffer:
        di
        xor a : ld (#5c6a), a  ; Thank you, Mario Prato, for feedback
        ld (#5c00),a
        ld sp, asmOrg
        call Memory.init
        xor a : out (#fe),a
        ei
    
        ld a, 7 : call Memory.setPage
        ;; Logo
        ld hl, logo, b, Dos.FMODE_READ : call Dos.fopen
        push af
        ld hl, #c000, bc, 6912 : call Dos.fread
        pop af
        call Dos.fclose

        ld b, 50 
1       halt 
        djnz 1b
    ENDIF
 
    call TextMode.init
	ld hl, initing : call TextMode.printZ
    
    IFNDEF NOINIT
  	    call Wifi.init
    ENDIF
    
    jp History.home

initing db "Initing Wifi...", CRLF, 0
logo    db "browser/logo.scr", 0
creds   db "browser/auth.pwd", 0
outputBuffer2:
    db  "ATE0", 0
    display "ENDS: ", $
    display "Buff size", #ffff - $

	IFDEF TRDOS
		SAVETRD "TRD/MRF.TRD",|BINNAME,asmOrg, $ - asmOrg
	        ELSE
			    savebin BINNAME, asmOrg, $ - asmOrg
   	ENDIF        

