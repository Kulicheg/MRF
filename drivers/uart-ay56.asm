; Copyright 2024 TIsland Crew
; SPDX-License-Identifier: Apache-2.0

	MODULE Uart

    ASSERT $ > 0x7fff || $ < 0x4000
    ; both "UART drivers" need MRF compat shim (this file)
    IFDEF ZXOS
        INCLUDE "uart-next.asm"
UART.dtr    equ UART.RS232_CFGDTR
    ELSE;!ZXOS
        DISPLAY "UART speed ",/D,_UART_SPEED
        IF _UART_SPEED == 57600
        INCLUDE "uart-ay-57600.asm"
UART.init   equ UART5.RS232_INIT
UART.dtr    equ UART5.RS232_CFGDTR
UART.RS232_RD_BT equ UART5.RS232_RD_BT
UART.RS232_WR_BT:
    push hl, de, bc
    call UART5.RS232_WR_BT
    pop bc, de, hl
    ret
        ELSE;_UART_SPEED!=57600
		INCLUDE "uart-ay-128k.asm"
        ENDIF
    ENDIF;ZXOS
init:
		call UART.init
    IFDEF ZXOS
        ld a, 0xff
    ELSE
		xor a
    ENDIF;ZXOS
		jp UART.dtr

write		equ	UART.RS232_WR_BT
uartRead	equ	UART.RS232_RD_BT

read:
    push bc, de, hl
    call uartRead
    pop hl, de, bc
    ret c
    jr read

	ENDMODULE

; EOF vim: et:ai:ts=4:sw=4:
