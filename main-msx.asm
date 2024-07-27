;******************************** MSX *********************************************
TCP_BUF_SIZE=1024
    output "mrfmsx.com"
    org 100h
asmOrg:
    jp start
    include "vdp/vdpdriver.asm"
    include "utils/index.asm"
    include "gopher/render/index.asm"
    include "dos/msxdos.asm"
    include "gopher/engine/history/index.asm"
    include "gopher/engine/urlencoder.asm"
    include "gopher/engine/fetcher.asm"
    include "gopher/engine/media-processor.asm"
    include "drivers/index.asm"
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
    display "Buff size: ", #D000 - $  ;ramtop  