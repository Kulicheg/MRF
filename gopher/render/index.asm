    MODULE Render
PER_PAGE = 22
CURSOR_OFFSET = 2
    include "row.asm"
    include "buffer.asm"
    include "ui.asm"
    include "gopher-page.asm"
    include "plaintext.asm"

play_next       db  0
position        EQU historyBlock.position
cursor_position EQU position + 2
page_offset     EQU position + 4

    ENDMODULE

    include "dialogbox.asm"