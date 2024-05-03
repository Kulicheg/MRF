    IFDEF UNO
    	include "uart-uno.asm"
    ENDIF

    IFDEF UNOUART
    	include "uart-uno.asm"
    ENDIF

    IFDEF MB03
    	include "uart-mb03.asm"
    ENDIF

    IFDEF AY
    	include "uart-ay.asm"
    ENDIF

    IFDEF AY56
    	include "uart-ay.asm"
    ENDIF

    IFDEF ZW
    	include "uart-zxwifi.asm"
    ENDIF
	
	include "utils.asm"
   
	IFDEF UARTATM
		include "uart-atm.asm"
	ENDIF

	IFDEF UARTEVO
		include "uart-evo.asm"
    ENDIF
	
	IFDEF NEDONET
		include "nedowifi.asm"
	ELSE
	IFNDEF MSX
		include "wifi.asm"
	ENDIF		
	ENDIF

    IFDEF NEDOOS
    	include "rtc-nos.asm"
    ENDIF


    IFDEF SMUCRTC
    	include "rtc-smuc.asm"
    ENDIF
    
	IFDEF MSX
        include "drivers/unapi/unapi.asm"
    	include "drivers/unapi/tcp.asm"
		include "rtc-msx.asm"
    ELSE
		include "proxy.asm"
		include "memory.asm"
	ENDIF

	IFDEF GS
		include "general-sound.asm"	
	ENDIF		