    IFDEF UNO
    	include "uno-uart.asm"
    ENDIF

    IFDEF UNOUART
    	include "uno-uart.asm"
    ENDIF

    IFDEF MB03
    	include "mb03-uart.asm"
    ENDIF

    IFDEF AY
    	include "ay-uart.asm"
    ENDIF
	
    IFDEF ZW
    	include "zx-wifi.asm"
    ENDIF
	
	include "utils.asm"
   
	IFDEF NEDOOSATM
		include "atm-uart.asm"
	ENDIF

	IFDEF NEDOOSEVO
		include "evo-uart.asm"
       	ENDIF
	
	IFDEF NEDONET
		include "nedowifi.asm"
	ELSE
		include "wifi.asm"
	ENDIF

    IFDEF SMUCRTC
    include "smuc-rtc.asm"
    ENDIF

    IFDEF NOSRTC
    include "nos-rtc.asm"
    ENDIF

	
	include "proxy.asm"
	include "memory.asm"
	include "general-sound.asm"
    