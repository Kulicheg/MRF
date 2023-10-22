    MODULE Wifi
bytes_avail dw 0
buffer_pointer dw 0
closed db 1
; Initialize Wifi chip to work
init:
   
    ld hl, .uartIniting : call TextMode.printZ
    call Uart.init
    ld hl, .chipIniting : call TextMode.printZ
    
    EspCmdOkErr "ATE0"
    jp c, .initError

    IFDEF AUTH  
    ld hl, creds, b, Dos.FMODE_READ : call Dos.fopen
    push af
    ld hl,outputBuffer2, bc, 255 : call Dos.fread
    pop af
    call Dos.fclose
   
    ld hl, .doneInit1 : call TextMode.printZ
    ;ld hl, outputBuffer2 : call TextMode.printZ
    
    ld hl,outputBuffer2
    call espSendT
    ld a, 13 : call Uart.write
    ld a, 10 : call Uart.write
    call checkOkErr
    jp c, .initError    
    ENDIF
    
   	EspCmdOkErr "AT+CIPSERVER=0" 
    EspCmdOkErr "AT+CIPCLOSE" ; Close if there some connection was. Don't care about result
    EspCmdOkErr "AT+CIPMUX=0" ; Single connection mode
    jp c, .initError
    
    EspCmdOkErr "AT+CIPDINFO=0" ; Disable additional info
    jp c, .initError

    ld hl, .doneInit : call TextMode.printZ
    
    or a
    ret
.initError
    ld hl, .errMsg : call DialogBox.msgBox
    scf
    ret
.errMsg      db "WiFi chip init failed!", CRLF, 0
.uartIniting db "Uart initing...", CRLF, 0
.chipIniting db "Chip initing...", CRLF, 0
.doneInit    db "Done!",CRLF, 0
.doneInit1   db "Connecting to AP",CRLF, 0
    IFNDEF PROXY   
; HL - host pointer in gopher row
; DE - port pointer in gopher row
openTCP:
    push de
    push hl
    EspCmdOkErr "AT+CIPCLOSE" ; Don't care about result. Just close if it didn't happens before
    EspSend 'AT+CIPSTART="TCP","'
    pop hl
    call espSendT
    EspSend '",'
    pop hl
    call espSendT
    ld a, 13 : call Uart.write
    ld a, 10 : call Uart.write
    xor a : ld (closed), a
    jp checkOkErr

continue:
    ret
    ENDIF



checkOkErr:
    call Uart.read
    cp 'O' : jp z, .okStart ; OK
    cp 'E' : jp z, .errStart ; ERROR
    cp 'F' : jp z, .failStart ; FAIL
    jp checkOkErr
.okStart
    call Uart.read : cp 'K' : jp nz, checkOkErr
    call Uart.read : cp 13  : jp nz, checkOkErr
    call .flushToLF
    or a
    ret
.errStart
    call Uart.read : cp 'R' : jp nz, checkOkErr
    call Uart.read : cp 'R' : jp nz, checkOkErr
    call Uart.read : cp 'O' : jp nz, checkOkErr
    call Uart.read : cp 'R' : jp nz, checkOkErr
    call .flushToLF
    scf 
    ret 
.failStart
    call Uart.read : cp 'A' : jp nz, checkOkErr
    call Uart.read : cp 'I' : jp nz, checkOkErr
    call Uart.read : cp 'L' : jp nz, checkOkErr
    call .flushToLF
    scf
    ret
.flushToLF
    call Uart.read
    cp 10 : jp nz, .flushToLF
    ret

; Send buffer to UART
; HL - buff
; E - count
espSend:
    ld a, (hl) : call Uart.write
    inc hl 
    dec e
    jp nz, espSend
    ret

; HL - string that ends with one of the terminator(CR/LF/TAB/NULL)
espSendT:
    ld a, (hl) 

    and a : ret z
    cp 9 : ret z 
    cp 13 : ret z
    cp 10 : ret z
    
    call Uart.write
    inc hl 
    jp espSendT

; HL - stringZ to send
; Adds CR LF
tcpSendZ:
    push hl
    EspSend "AT+CIPSEND="
    pop de : push de
    call strLen
    inc hl : inc hl ; +CRLF
    call hlToNumEsp
    ld a, 13 : call Uart.write
    ld a, 10 : call Uart.write
    call checkOkErr : ret c
.wait
    call Uart.read : cp '>' : jp nz, .wait
    pop hl
.loop
    ld a, (hl) : and a : jp z, .exit
    call Uart.write
    inc hl
    jp .loop
.exit
    ld a, 13 : call Uart.write
    ld a, 10 : call Uart.write
    jp checkOkErr

getPacket:
    call Uart.read
    cp '+' : jp z, .ipdBegun    ; "+IPD," packet 
    cp 'O' : jp z, .closedBegun ; It enough to check "OSED\n" :-)
    jp getPacket
.closedBegun
    call Uart.read : cp 'S' : jp nz, getPacket
    call Uart.read : cp 'E' : jp nz, getPacket
    call Uart.read : cp 'D' : jp nz, getPacket
    call Uart.read : cp 13 : jp nz, getPacket
    ld a, 1, (closed), a
    ret
.ipdBegun
    call Uart.read : cp 'I' : jp nz, getPacket
    call Uart.read : cp 'P' : jp nz, getPacket
    call Uart.read : cp 'D' : jp nz, getPacket
    call Uart.read ; Comma
    call .count_ipd_lenght : ld (bytes_avail), hl 
    ld bc, hl
    ld hl, (buffer_pointer)
.readp
    ld a, h : cp #ff : jp nc, .skipbuff
    push bc, hl
    call Uart.read
    pop hl, bc
    ld (hl), a
    dec bc : inc hl
    ld a, b : or c : jp nz, .readp
    ld (buffer_pointer), hl
    ret
.skipbuff 
    push bc
    call Uart.read
    pop bc
    dec bc : ld a, b : or c : jp nz, .skipbuff
    ret
.count_ipd_lenght
		ld hl,0			; count lenght
.cil1	push  hl
        call Uart.read
        pop hl 
		cp ':' : ret z
		sub 0x30 : ld c,l : ld b,h : add hl,hl : add hl,hl : add hl,bc : add hl,hl : ld c,a : ld b,0 : add hl,bc
		jp .cil1

; Based on: https://wikiti.brandonw.net/index.php?title=Z80_Routines:Other:DispHL
; HL - number
; It will be written to UART
hlToNumEsp:
	ld	bc,-10000
	call	.n1
	ld	bc,-1000
	call	.n1
	ld	bc,-100
	call	.n1
	ld	c,-10
	call	.n1
	ld	c,-1
.n1	ld	a,'0'-1
.n2	inc	a
	add	hl,bc
	jp	c, .n2
	sbc	hl,bc
    push bc
	call Uart.write
    pop bc
    ret
flushToLF1
    call Uart.read
    cp 10 : jp nz, flushToLF1
    ret
    ENDMODULE