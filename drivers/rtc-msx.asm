;clock driver MSX2
	module Clock
    define RTCreg 0xb4
    define RTCdat 0xb5
    define MODEreg 0x0d
    
readTime:
;I/O Ports
;Port 00B4h allows you to specify the RTC register (0-15) to access, and 
;port 00B5h allows you to read or write data in the specified register. Bits 4 to 7 of these ports are not used.
;
;Block 0
;Register	Bit 3	Bit 2	Bit 1	Bit 0
;0	        Units counter for seconds
;1	        0	    Tens counter for seconds
;2	        Units counter for minutes
;3	        0	    Tens counter for minutes
;4	        Units counter for hours
;5	        0	    0	    Tens counter for hours
;

	ld bc, RTCreg
	ld a,MODEreg 
    out (c),a           ; Selecting MODE register

	ld bc, RTCdat
    in a, (c)           ; Reading MODE register
    and 12
    out (c),a           ;Selecting BLOCK0

; Seconds-----------------------------------------------------------------
	ld bc, RTCreg
    ld a,0
    out (c),a           ;Selecting 0 register (Units counter for seconds)

    ld bc, RTCdat
    in  a, (c)          ; Reading 0 register
    and 15
    ld e,a

	ld bc, RTCreg
    ld a, 1
    out (c),a           ;Selecting 1 register (Tens counter for seconds)

    ld bc, RTCdat
    in  a, (c)          ; Reading 1 register
    and 7
    cp 0
    jp z,zerosecs
    ld d,a
    xor a
secCounter:
    add 10
    dec d
    jp nz,secCounter
zerosecs:
    add e
	ld (seconds),a
; Minites-----------------------------------------------------------------
	ld bc, RTCreg
    ld a,2
    out (c),a           ;Selecting 2 register

    ld bc, RTCdat
    in  a, (c)          ; Reading 2 register
    and 15
    ld e,a

	ld bc, RTCreg
    ld a, 3
    out (c),a           ;Selecting 3 register

    ld bc, RTCdat
    in  a, (c)          ; Reading 3 register
    and 7
    cp 0
    jp z,zerominutes
    ld d,a
    xor a
minCounter:
    add 10
    dec d
    jp nz,minCounter
zerominutes:
    add e
    ld (minutes),a
; Hours-----------------------------------------------------------------

	ld bc, RTCreg
    ld a,4
    out (c),a          ;Selecting 4 register

    ld bc, RTCdat
    in  a, (c)         ; Reading 4 register
    and 7
    ld e,a

	ld bc, RTCreg
    ld a, 5
    out (c),a          ;Selecting 5 register

    ld bc, RTCdat
    in  a, (c)         ; Reading 5 register
    and 3
    cp 0
    jp z,zerohour
    ld d,a
    xor a
hourCounter:
    add 10
    dec d
    jp nz,hourCounter
zerohour:
    add e
    ld (hours),a
  	ret
    endmodule
