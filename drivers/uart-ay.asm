; Copyright 2024 TIsland Crew
; SPDX-License-Identifier: Apache-2.0

    IFDEF AY56
        INCLUDE "uart-ay-57600.asm"
        MODULE      Uart
init:
        call UART5.RS232_INIT
        xor a
        jp UART5.RS232_CFGDTR

write       equ UART5.RS232_WR_BT
uartRead    equ UART5.RS232_RD_BT

read:
        push bc, de, hl
        call uartRead
        pop hl, de, bc
        ret c
        jr read

        ENDMODULE ; Uart
    ELSE
        INCLUDE "uart-ay-128k.asm"
    ENDIF;UART_128K

; EOF vim: et:ai:ts=4:sw=4: