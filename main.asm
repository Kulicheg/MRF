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
    align 256 ;временно
    jp start
; Generate version string
    LUA ALLPASS
    v = tostring(sj.get_define("V"))
    maj = string.sub(v, 1,1)
    min = string.sub(v, 2,2)
    sj.insert_define("VERSION_STRING", "\"" .. maj .. "." .. min .. "\"")
    ENDLUA

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
    IFNDEF NEDOOS
    include "player/vortex-processor.asm"
    include "screen/screen.asm"
	ELSE
    include "screen/nedoscreen.asm"
    include "player/vortexnedoos.asm"
    ENDIF
start:
	IFNDEF NEDOOS
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
1   halt 
    djnz 1b
    ;; End of logo :-)

    ELSE
        ld sp, 0x4000
    ENDIF
 
    call TextMode.init
	ld hl, initing : call TextMode.printZ
  	call Wifi.init

   jp History.home

    IFDEF NEDOOS
outputBuffer:	
	ENDIF

initing db "Initing Wifi...", CRLF, 0
logo    db "browser/logo.scr", 0
creds   db "browser/auth.pwd", 0

    display "ENDS: ", $
    display "Buff size", #ffff - $
    IFDEF NEDOOS
        savebin "moon.com", asmOrg, $ - asmOrg
    ELSE
		IFDEF TRDOS
			SAVETRD "MOONR.TRD",|"moon.C",asmOrg, $ - asmOrg
		ELSE
			savebin "moon.bin", asmOrg, $ - asmOrg
	    	ENDIF        
    ENDIF
outputBuffer2:
    db  "ATE0", 0  