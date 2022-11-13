	IFDEF NEDOOS
	    include "nedoconsole.asm"
		include "nedoos.asm"
	ENDIF
	
	IFDEF TRDOS
    	include "console.asm"
		include "trdos.asm"
	ENDIF

	IFDEF ESXDOS
   		include "console.asm"
   		include "esxdos.asm"
	ENDIF

	IFDEF P3DOS
   		include "console.asm"
   		include "p3dos.asm"
	ENDIF
