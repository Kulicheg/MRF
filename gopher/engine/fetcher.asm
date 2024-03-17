    MODULE Fetcher

fetchFromNet:
	
	IFDEF MSX
    	call Gopher.makeRequest : jr nz, .error
    ELSE
    	call Gopher.makeRequest : jr c, .error
    ENDIF
        
    call Gopher.loadBuffer
    jp MediaProcessor.processResource
.error
    ld hl, .err : call DialogBox.msgBox 
    jp History.back
    
.err db "Document fetch error! Check your connection or hostname!", 0


fetchFromFS:
    call UrlEncoder.extractPath
loadFile
	IFDEF MSX
    ld de, Gopher.requestbuffer, a, FMODE_NO_WRITE
    call Dos.fopen
    ld a, b, (.fp), a
    ld de, outputBuffer, hl, (ramtop)
    call Dos.fread
    ld a, (.fp), b, a
    call Dos.fclose
    jp MediaProcessor.processResource
.fp db 0
	ELSE
    ld hl, Gopher.requestbuffer
    call Dos.loadBuffer
    jp MediaProcessor.processResource
	ENDIF
    ENDMODULE