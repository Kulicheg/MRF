;

    MODULE UART5

; https://cygnus.speccy.cz/download/zx128k_rs232/rs232_paul_farrow_57600_data_sequence_with_cts_flow_control.html
;   via https://cygnus.speccy.cz/popis_zx-spectrum_dg192k_rs232.php

;==============================================================================
; RS232 - transmitting through AY-3-8912 without data flow control
;
; 57600bps (17.3611μs) 61.57813T on ZX128k, 61T will take 17.19811μs, error -0.9% (58146bps)
;                      60.76389T on ZX48k,  61T will take 17.42857μs, error +0.4% (57377bps)
;==============================================================================
; original author Paul Farrow - this is code disassembled from his RS232 ROM,
; but only RS232 part

RS232_CFGDTR:    ; enable/disable DTR check when sending
; NOTE: this is actually RTS line, IIRC it was a mistake carried on
; from the original Interface 1 docs
; A - flag, A=0 -- DTR disabled, A=0xff -- DTR enabled
    and %01000000   ; Bit 6: RS232  DTR (in)  - 0=Device ready for data,     1=Busy
    ld (DTRFL), a   ; patch the code
    ret

RS232_INIT:
        di
        call SET_AY_PORTS
        ei
        ret

SET_AY_PORTS:
        ld  bc,$fffd        ; 10T   BC = FFFD, register port
        ld  a,7             ; 7T    select AY register 7
        out (c),a           ; 12T
        ld  a,b             ; 4T    A = 255 / set IO port as output (1 on bit 6) and disable all sound channels
        ld  b,$BF           ; 7T    BC = BFFD, data port
        out (c),a           ; 12T
        ld  b,a             ; 4T    BC = FFFD / AY register port
        ld  a,14            ; 7T    select AY register 14 (I/O port)
        out (c),a           ; 12T
        ld  a,b             ; 4T    A = FF
        ld  b,$BF           ; 7T    BC = BFFD / data port
        out (c),a           ; 12T   write data byte 255, all bits high (like pullups?)
        ret                 ; 10T

; total 10+7+12+4+7+12+4+7+12+7+4+12+10 = 108T

RS232_RD_BT:
        di
        call SLOAD_AY_R
        ei
        ret

SLOAD_AY_R:
        ld  de,$80FB        ; 10T   D = 1000 0000, E = 1111 1011    (ZX 128k RS232 - *A2, A3, A6, *A7)
        jr  SLOAD_AY        ; 12T   jump to common part
        
SLOAD_AY_K:
        ld  de,$20FE        ; 10T   D = 0010 0000, E = 1111 1110    (ZX 128k Keypad - *A0, A1, A4, *A5)
SLOAD_AY:
        ld  a,e             ; 4T
        ld  e,0             ; 7T
        ld  hl,$BFFF        ; 10T   H = 1011 1111 (191 * 256 + 253 = 49149), L = 1111 1111 (255 * 256 + 253 = 65535)
        ld  bc,$BFFD        ; 10T   AY data port
        out (c),a           ; 12T   set CTS (ZX Spectrum is ready recieve data)
        ld  b,l             ; 4T    B = FF -> BC = FFFD
SLOAD_AY_WAIT:
        in  a,(c)           ; 12T   read control port = IO port - repeat 3 times
        and d               ; 4T    check TxD (data from PC)
        jr  z,SLOAD_AY_RD_1 ; 7/12T Z = start bit
        in  a,(c)           ; 12T
        and d               ; 4T
        jr  z,SLOAD_AY_RD_1 ; 7/12T
        in  a,(c)           ; 12T
        and d               ; 4T
        jr  z,SLOAD_AY_RD_1 ; 7/12T
        dec e               ; 4T    decrement counter
        jr  nz,SLOAD_AY_WAIT; 7/12T wait for start bit again if NZ
        in  a,(c)           ; 12T
        and d               ; 4T
        jr  z,SLOAD_AY_RD_1 ; 7/12T
        ld  a,l             ; 4T    A = FF
        ld  b,h             ; 4T    B = BF -> BC = BFFD (what port is it selecting now?)
        out (c),a           ; 12T
        ld  b,l             ; 4T    B = FF -> BC = FFFD
SLOAD_AY_WAI2:
        in  a,(c)           ; 12T   what port was read here?
        and d               ; 4T
        jr  z,SLOAD_AY_RD_2 ; 7/12T
        in  a,(c)           ; 12T
        and d               ; 4T
        jr  z,SLOAD_AY_RD_2 ; 7/12T
        in  a,(c)           ; 12T
        and d               ; 4T
        jr  z,SLOAD_AY_RD_2 ; 7/12T
        dec e               ; 4T
        jp  nz,SLOAD_AY_WAI2; 10T
        xor a               ; 4T    CF=0
        ret                 ; 10T

; start bit detected, read other bits (this is critical for precize timing)

SLOAD_AY_RD_1:  nop         ; 4T    only delay?
SLOAD_AY_RD_2:
        ld  a,l             ; 4T    A = FF
        ld  b,h             ; 4T    B = BF -> BC = BFFD
        out (c),a           ; 12T   write FF to what register? 14?
        ld  e,10000000b     ; 7T    this will be counter to 8
        ld  b,l             ; 4T    B = FF -> BC = FFFD
SLOAD_AY_BITL:
        in  a,(c)           ; 12T   read AY I/O port
        cp  (ix+0)          ; 19T   delay?
        and d               ; 4T    zero irrelevant bits, leave only one (bit 7 for RS232/MIDI connector)
        add a,255           ; 7T    activate carry flag if bit from serial port was H
        rr  e               ; 8T    8x rotate E to right and carry flag copy in bit 7
        jr  nc,SLOAD_AY_BITL; 12/7T carry = last bit was read
        xor a               ; 4T    set Z flag, A = 0, only delay?
        ld  a,e             ; 4T    A = E
        scf                 ; 4T    set carry flag
        ret                 ; 10T

; ZX Spectrum 128k Keypad is using bits
;   A0  ?   output
;   A1  ?   output
;   A4  ?   input
;   A5  ?   input
;
; ZX Spectrum 128k RS232 is using bits
;   A2  CTS output      RTS
;   A3  RxD output      TxD
;   A6  DTR input       CTS
;   A7  TxD input       RxD

RS232_WR_BT:
        di
        push hl, de, bc
        call SSAVE_AY_R
        pop bc, de, hl
        ei
        ret

SSAVE_AY_R:
DTRFL    equ $ + 2
        ld  hl,$40F6        ; 10T       H = 0100 0000, L = 1111 0110    mask/bits for RS232/MIDI
        jr  SSAVE_AY        ; 12T

SSAVE_AY_K:
        ld  hl,$10FC        ; 10T       H = 0001 0000, L = 1111 1100    mask/bits for KEYPAD
SSAVE_AY:
        ld  d,10            ; 7T        bit counter (start bit + 8 bits + stop bit)
        ld  bc,$FFFD        ; 10T       BC = FFFD / register port AY-3-8912 
        cpl                 ; 4T        invert A
        ld  e,a             ; 4T        copy inverted data into E
; wait for CTS or BREAK
SSAVE_AY_WFSB:  ; THE 'BREAK-KEY' SUBROUTINE https://skoolkid.github.io/rom/asm/1F54.html
        call 0x1F54      ; 17T+(33|53T)  test BREAK / nc = BREAK was pressed
        ret nc              ; 11/5T
        in  a,(c)           ; 12T       read AY I/O port
        and h               ; 4T
        jr   nz,SSAVE_AY_WFSB    ; 12/7T     Z = CTS in low detected
        ld  b,$BF           ; 7T        BC = BFFD / data port AY-3-8912 
        scf                 ; 4T        set carry
SSAVE_AY_LOOP:
        jr  c,SSAVE_AY_OVER ; 12/7T
        ld  a,$FE           ; 7T        TxD = 1 (A3/A1)
        jr  SSAVE_AY_OUT    ; 12T
        
SSAVE_AY_OVER:
        ld  a,l             ; 4T        TxD = 0 (A3/A1)
        jp  SSAVE_AY_OUT    ; 10T

; CTS detected from in  12+4+7+7+4+12+4+10 = 60T (still not transmitting anything)
; start bit from out    12+8+4+12+12+4+10 = 62T
; bit 1         12+8+4+12+7+7+12 = 62T
; stop bit (nc)     12+8+4+12+7+7+12 = 62T

SSAVE_AY_OUT:
        out (c),a       ; 12T       write to AY I/O port
        srl e           ; 8T        shift right logical - shift data byte, 0 to bit 7, bit 0 to carry
        dec d           ; 4T        decrement bit counter
        jr  nz,SSAVE_AY_LOOP    ; 12/7T     jump if any bit left
        scf             ; 4T
        ret             ; 10T

; after stop bit 12+8+4+7+4+10 = 45T (and more)

    ENDMODULE; UART5

; EOF vim: et:ai:ts=4:sw=4:
