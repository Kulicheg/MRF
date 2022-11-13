total   equ 5
depth   db 0

historyBlock:  
.isFile    db  0
.mediaType db  0
.locator   ds  #1ff 
.host      ds  64
.port      ds  6
.search    ds  #ff
.position  dw  #0000    ;position
    
    db 0,0,0,0,0,0  ;cursor_position page_offset

historyBlockSize = $ - historyBlock

HistoryRecord EQU $ - historyBlock
    dup total 
    ds HistoryRecord
    edup
HistoryEnd equ $ - 1
