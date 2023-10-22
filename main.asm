    DEFINE TCP_BUF_SIZE 1024
; Generate version string
    LUA ALLPASS
    v = tostring(sj.get_define("V"))
    maj = string.sub(v, 1,1)
    min = string.sub(v, 2,2)
    sj.insert_define("VERSION_STRING", "\"" .. maj .. "." .. min .. "\"")

    b = tostring(sj.get_define("BLD"))
    sj.insert_define("BUILD_STRING", "\"" .. b .. "\"")
    ENDLUA

    IFNDEF MSX
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
    IFNDEF NEDOOS
    include "player/vortex-processor.asm"
    include "player/mod-processor.asm"
    include "screen/screen.asm"
	ELSE
    include "screen/nedoscreen.asm"
    include "player/vortexnedoos.asm"
    include "player/mod-processor.asm"
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
        ld c,nos.CMD_SETSYSDRV
     	ex af,af'   
	    call nos.BDOS
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

    ELSE
;****************************** MSX ***********************************************
    output "moonr.com"
    org 100h
    jp start
    include "vdp/vdpdriver.asm"
    include "utils/index.asm"
    include "gopher/render/index.asm"
    include "dos/msxdos.asm"
    include "gopher/engine/history/index.asm"
    include "gopher/engine/urlencoder.asm"
    include "gopher/engine/fetcher.asm"
    include "gopher/engine/media-processor.asm"
    include "drivers/unapi/unapi.asm"
    include "drivers/unapi/tcp.asm"
    include "gopher/msxgopher.asm"
    include "screen/msxscreen.asm"
    include "player/vortex-processor.asm"
    include "player/mod-processor.asm"
    include "screen/rtc.asm"
fontName db "font.bin",0
start:
    ld hl,(0x0006)
    ld bc,outputBuffer
    sbc hl,bc 
    ld bc, 0x100
    sbc hl,bc 
    ld (ramtop),hl
  
    call TcpIP.init : jp nc, noTcpIP ; No TCP/IP - no browser! Anyway you can use "useless tcp/ip driver"
    ; Loading font
    ;ld de, fontName, a, FMODE_NO_WRITE : call Dos.fopen
    ;push bc
    ;ld de, font, hl, 2048 :call Dos.fread
    ;pop bc
    ;call Dos.fclose
    call TextMode.loadFont
    call TextMode.init
    call History.home
    jp exit
noTcpIP:
    ld hl, .err
    call Console.putStringZ
    rst 0
.err db 13,10,"No TCP/IP implementation found!",13,10,0
ramtop:
    db 0x00, 0xD0
outputBuffer:
font:
    display "ENDS: ", $
    ENDIF