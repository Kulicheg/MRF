    IFDEF ZXSCR
    DEFINE LEFT_TAB "[D]omain:                                  "
    ENDIF

    IFDEF TIMEX     ;UNKNOWM fallback to 64
    DEFINE LEFT_TAB "[D]omain:                                  "
    ENDIF

    IFDEF TIMEX80
    DEFINE LEFT_TAB "[D]omain:                                                      "
    ENDIF

    IFDEF NEDOOS
    DEFINE LEFT_TAB "[D]omain:                                                  "
    ENDIF

    IFDEF MSX
    DEFINE LEFT_TAB "[D]omain:                                              "
    ENDIF
prepareScreen:
    call TextMode.cls
    ld hl, header : call TextMode.printZ
    ld de, #000A : call TextMode.gotoXY
    ld hl, hostName : call TextMode.printZ
    xor a : call TextMode.highlightLine
    ret

inputHost:
    	call Console.waitForKeyUp
.loop
    ld de, #000A : call TextMode.gotoXY : ld hl, hostName : call TextMode.printZ
    ld a, MIME_INPUT : call TextMode.putC
    ld a, ' ' : call TextMode.putC
.wait
    call Console.getC
    ld e, a
    cp Console.BACKSPACE : jr z, .removeChar
    cp CR : jp z, inputNavigate
    cp 32 : jr c, .wait
.putC
    xor a : ld hl, hostName, bc, 48 : cpir
    ld (hl), a : dec hl : ld (hl), e 
    jr .loop
.removeChar
    xor a
    ld hl, hostName, bc, 48 : cpir
    dec hl : dec hl : ld (hl), a 
    jr .loop

inputNavigate:
    ld hl, hostName, de, domain
    ld a,(hl)
    and a
    jp z, History.load
.loop
    ld a, (hl) : and a : jr z, .complete
    ld (de), a : inc hl, de
    jr .loop
.complete
    ld a, TAB : ld (de), a : inc de
    ld a, '7' : ld (de), a : inc de
    ld a, '0' : ld (de), a : inc de
    ld a, CR : ld (de), a : inc de
    ld a, LF : ld (de), a : inc de
    ld hl, navRow : jp History.navigate

navRow db "1 ", TAB, "/", TAB
domain db "nihirash.net" 
    ds 64 - ($ - domain)

	IFDEF MSX
header db LEFT_TAB, "    MRF"
       db VERSION_STRING
       db "."
       db BUILD_STRING
       db " [MSX UNAPI]",13, 0
	ENDIF      

    IFDEF MB03
header db LEFT_TAB, "    MRF"
       db VERSION_STRING
       db "."
       db BUILD_STRING
       db " [MB03+]",13, 0
       ENDIF
    
    IFDEF UNO
header db LEFT_TAB, "MRF"
       db VERSION_STRING
       db "."
       db BUILD_STRING
       db " [UNO UART]",13, 0
    ENDIF

    IFDEF AY
header db LEFT_TAB, "  MRF"
       db VERSION_STRING
       db "."
       db BUILD_STRING
       db " [AYWIFI]",13, 0
	ENDIF

    IFDEF ZW
header db LEFT_TAB, "  MRF"
       db VERSION_STRING
       db "."
       db BUILD_STRING
       db " [ZXWiFi]",13, 0
    ENDIF	
 
     IFDEF NEDOOSATM
header db LEFT_TAB, "MRF"
       db VERSION_STRING
       db "."
       db BUILD_STRING
       db " [ATM UART]",13, 0
    ENDIF
	
    IFDEF NEDOOSEVO
header db LEFT_TAB, "MRF"
       db VERSION_STRING
       db "."
       db BUILD_STRING
       db " [EVO UART]",13, 0
    ENDIF

    IFDEF UNOUART
header db LEFT_TAB, "MRF"
       db VERSION_STRING
       db "."
       db BUILD_STRING
       db " [UNO UART]",13, 0
    ENDIF

    IFDEF NEDOOS
	IFNDEF NEDOOSATM
	IFNDEF NEDOOSEVO
header db LEFT_TAB, " MRF"
       db VERSION_STRING
       db "."
       db BUILD_STRING
       db " [nedoNET]",13, 0
       
    ENDIF
	ENDIF
	ENDIF	

