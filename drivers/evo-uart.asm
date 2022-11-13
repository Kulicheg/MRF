    module Uart
; This driver works with 16c550 uart that's support AFE
;AT+UART_CUR=38400,8,1,0,0
;AT+CWMODE_DEF=1
;AT+CWJAP_DEF="Kulich","password"
;

; Internal port constants
RBR_THR equ #F8
IER		equ	#F9
IIR_FCR	equ	#FA
LCR		equ	#FB
MCR		equ	#FC
LSR		equ	#FD
MSR		equ	#FE
SR		equ	#FF

    macro outp port, value
	di
	ld b, port
	ld c, #EF
    ld a, value
	out (port), a
	ei
	endm



init:
	push bc
    outp MCR,     #0d	// Assert RTS
    outp IIR_FCR, #87	// Enable fifo 8 level, and clear it
    outp LCR,     #83	// 8n1, DLAB=1
    outp RBR_THR, #03	// 115200 (divider 1-115200, 3 - 38400)
    outp IER,     #00	// (divider 0). Divider is 16 bit, so we get (#0002 divider)
    outp LCR,     #03	// 8n1, DLAB=0
    outp IER,     #00	// Disable int
    outp MCR,     #2f	// Enable AFE
	pop bc
    ret
    
; Flag C <- Data available
isAvailable:
	ld bc, #FDEF
	in a, (c)
    rrca
    ret

; Blocking read
; A <- Byte
read:
	di
    ld bc, #FDEF
	in a, (c)
    rrca
    jr nc, read
    ld bc, #F8EF
	in a, (c)
	ei	
    ret

; A -> byte to send

write:
	di
    push af
.wait
    ld bc, #FDEF
	in a, (c)
    and #20
    jr z, .wait
    pop af

	ld bc,#F8EF
	out (c),a	
	ei
    ret

    endmodule