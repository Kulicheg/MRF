    module Gopher
; HL - gopher row
extractRequest:
    ld hl, historyBlock.locator
    ld de, requestbuffer
.loop
    ld a, (hl)
    ld (de), a
    inc hl
    inc de
    cp 0 
    jr z, .search
    jr .loop
.search
    dec de
    ld a, (historyBlock.mediaType)
    cp MIME_INPUT
    jr nz, .exit
    ld hl, historyBlock.search
    ld a, TAB
    ld (de), a
    inc de
.searchCopy
    ld a, (hl) 
    and a : jr z, .exit
    ld (de), a
    inc hl : inc de
    jr .searchCopy
.exit
    xor a
    ld (de), a
    ret


makeRequest:
    call extractRequest

    ld hl, historyBlock.host
    ld de, historyBlock.port
    call Wifi.openTCP
    ret c

    ld hl, requestbuffer
    call Wifi.tcpSendZ
    xor a : ld (Wifi.closed), a
    ret


loadBuffer:
    ld hl, outputBuffer
    ld (Wifi.buffer_pointer), hl
.loop
    call Wifi.getPacket
    ld a, (Wifi.closed)
    and a
    ret nz
    ;call Wifi.continue
    jr .loop

    ifdef GS
loadMod:
    xor a : call GeneralSound.init
    ld hl, .progress : call DialogBox.msgNoWait
    call makeRequest : jp c, Fetcher.fetchFromNet.error
    call GeneralSound.loadModule
.loop
    ld hl, outputBuffer, (Wifi.buffer_pointer), hl
    call Wifi.getPacket
    ld a, (Wifi.closed) : and a : jr nz, .exit
    ld hl, outputBuffer, bc, (Wifi.bytes_avail)
.loadLoop
    ld a, b : or c : and a : jr z, .nextFrame
    ld a, (hl) : call GeneralSound.sendByte
    dec bc
    inc hl
    jr .loadLoop
.nextFrame
    call pulsing
    ;call Wifi.continue
    jr .loop
.exit
    call GeneralSound.finishLoadingModule
    ;jp History.back
	jp MediaProcessor.processResource
.progress db "MOD downloading directly to GS!", 0
    endif

download:
    ld de, historyBlock.locator
    ld hl, de
.findFileName
    ld a, (de) : inc de
    cp '/' : jr nz, .skip
    ld hl, de
.skip
    and a : jr nz, .findFileName
.copy
    ;; HL - filename pointer
    ld de, DialogBox.inputBuffer
.copyFileName
    ld a, (hl) : and a : jr z, .finishCopy

    ld (de), a : inc hl, de
    jr .copyFileName
.finishCopy
    ld (de), a
    call DialogBox.inputBox.noclear
    ld a, (DialogBox.namedownload) : and a : jp z, History.back
    
    call makeRequest : jp c, Fetcher.fetchFromNet.error

    ld b, Dos.FMODE_CREATE, hl, DialogBox.namedownload
    call Dos.fopen
    ld (.fp), a
    
    ld hl, .progress : call DialogBox.msgNoWait
.loop
    ld hl, outputBuffer, (Wifi.buffer_pointer), hl
    call Wifi.getPacket
    ld a, (Wifi.closed) : and a : jr nz, .exit
    
    ld a, (.fp), hl, outputBuffer, bc, (Wifi.bytes_avail)
    call Dos.fwrite
    call pulsing
    jr .loop
.exit
    ld a, (.fp)
    call Dos.fclose
    jp History.back
.error
    ld a, (.fp)
    call Dos.fclose
    ld hl, .err
    call DialogBox.msgBox
    jp History.back

.err db "Operation failed! Sorry! Check filename or disk space!",0
.progress db "Downloading in progress! Wait a bit!", 0
.fp db 0
socket db 0
pulsator db " "
pulsing
    ld de, #0B01 : call TextMode.gotoXY
    ld a, (pulsator)
    cp '*'
    jp z, printasterix
    call TextMode.putC
    ld a, '*'
    ld (pulsator),a
    ret 
printasterix
    call TextMode.putC
    ld a, ' '
    ld (pulsator),a
    ret 

requestbuffer ds #1ff
    endmodule
    