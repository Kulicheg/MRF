    module Uart
;AT+UART_CUR=115200,8,1,0,3
;AT+CWMODE_DEF=1
;AT+CWJAP_DEF="Kulich","password"
;

; Internal port constants
;RBR_THR equ 0xF8EE
;IER		equ	0xF9EE
;IIR_FCR	equ	0xFAEE
;LCR		equ	0xFBEE
;MCR		equ	0xFCEE
;LSR		equ	0xFDEE
;MSR		equ	0xFEEE
;SR		equ	0xFFEE


RBR_THR 	equ 	0xF8EF
IER		equ	0xF9EF
IIR_FCR		equ	0xFAEF
LCR		equ	0xFBEF
MCR		equ	0xFCEF
LSR		equ	0xFDEF
MSR		equ	0xFEEF
SR		equ	0xFFEF




init:
	push bc

	ld bc,MCR       // Assert RTS. In Evo only  bit #1 is used. For RTS control
    ld a, 0x0d
	out (c),a

	ld bc,IIR_FCR   // Enable fifo 8 level, and clear it
    ld a, 0x87
	out (c),a

	ld bc,LCR       // 8n1, DLAB=1
    ld a, 0x83
	out (c),a

	ld bc,RBR_THR   // 115200 (divider 1-115200, 3 - 38400)
    ld a, 0x01
	out (c),a

	ld bc,IER       // (divider 0). Divider is 16 bit, so we get (0x0002 divider)
    ld a, 0x00
	out (c),a

	ld bc,LCR       // 8n1, DLAB=0
    ld a, 0x03
	out (c),a

	ld bc,IER       // Disable int
    ld a, 0x00
	out (c),a

	ld bc,MCR       // Enable AFE. Not implemented in EVO
    ld a, 0x2f
	out (c),a
	pop bc
    ret
    
; Flag C <- Data available
isAvailable:
	ld bc, LSR
	in a, (c)
    rrca
    ret

; Blocking read
; A <- Byte
read:
	ld bc, LSR          // Test FIFO for data
	in a, (c)
    rrca
    jp nc,flashRTS    // No data in FIFO let's set RTS for awile 
    ld bc, RBR_THR      // Recieve data from FIFO
	in a, (c)
	ret

flashRTS:
	di
	ld bc,MCR           // Open the gate
    ld a, 2
	out (c),a
    ld bc, LSR          // Test FIFO for data
flashRTS2:
	in a, (c)
    rrca
    jp nc,flashRTS2      // No data? Once more.
    ld bc,MCR           // Close the gate
    xor a
	out (c),a
    ld bc, RBR_THR      // Recieve data from FIFO
	in a, (c)
    ei
	ret

; A -> byte to send
write:
	push af
.wait
    ld bc, LSR      //FIFO is free?
	in a, (c)
    and 0x20
    jr z, .wait     //No. Wait more.
    pop af
	ld bc,RBR_THR   //Write data to FIFO
	out (c),a	
    ret

    endmodule