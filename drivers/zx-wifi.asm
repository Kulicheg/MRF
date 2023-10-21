; This driver works with 16c550 uart that's support AFE
    module Uart
; Make init shorter and readable:-)
    macro outp port, value
	ld b, port
	ld c, #EF
    ld a, value
    out (c), a
    endm

; Internal port constants
RBR_THR = #F8
IER     = RBR_THR + 1
IIR_FCR = RBR_THR + 2
LCR     = RBR_THR + 3
MCR     = RBR_THR + 4
LSR     = RBR_THR + 5
MSR     = RBR_THR + 6
SR      = RBR_THR + 7


init:
    IFDEF GZ
    outp MCR,     #0d  // Assert RTS
    outp IIR_FCR, #87  // Enable fifo 8 level, and clear it
    outp LCR,     #83  // 8n1, DLAB=1
    outp RBR_THR, 12  //(divider 12)
    outp IER,     #00  // (divider 0). Divider is 16 bit, so we get (#0002 divider)

    outp LCR,     #03 // 8n1, DLAB=0
    outp IER,     #00 // Disable int
    outp MCR,     #2f // Enable AFE
    ret
    ELSE
    outp MCR,     #0d  // Assert RTS
    outp IIR_FCR, #87  // Enable fifo 8 level, and clear it
    outp LCR,     #83  // 8n1, DLAB=1
    outp RBR_THR, 1  // 115200 (divider 1)
    outp IER,     #00  // (divider 0). Divider is 16 bit, so we get (#0002 divider)

    outp LCR,     #03 // 8n1, DLAB=0
    outp IER,     #00 // Disable int
    outp MCR,     #2f // Enable AFE
    ret
    ENDIF
retry_rec_count_max equ 50 ;ждать 1 байт максимум столько прерываний
    
; Flag C <- Data available
; isAvailable:
    ; ld a, LSR
    ; in a, (#EF)
    ; rrca
    ; ret

; Non-blocking read
; Flag C <- is byte was readen
; A <- byte
; read1:
    ; ld a, LSR
    ; in a, (#EF)
    ; rrca
    ; ret nc
    ; ld a, RBR_THR	
    ; in a, (#EF)
    ; scf 
    ; ret

; Tries read byte with timeout
; Flag C <- is byte read
; A <- byte
read:
	xor a ;4
	ld (#5C78),a ;обнулить счётчик ожидания ;13
.wait
    ld a, LSR
    in a, (#EF)
    rrca
	jr nc, .readW
    ld a, RBR_THR	
    in a, (#EF)
	ret	
.readW	
	ld a,(#5C78)
	cp retry_rec_count_max
	jr c, .wait ;ещё попытка
	xor a ;выключим флаг переноса если время вышло
	ret
	
	
	

; Blocking read
; A <- Byte
; readB:
    ; ld a, LSR
    ; in a, (#EF)
    ; rrca
    ; jr nc, readB
	; ld a, RBR_THR
    ; in a, (#EF)
    ; ret

; A -> byte to send
write:
    push af
.wait
	ld a, LSR
    in a, (#EF)
    and #20
    jr z, .wait
    pop af
	ld b, RBR_THR
	ld c, #EF	
    out (c), a
    ret

    endmodule