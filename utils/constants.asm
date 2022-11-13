TAB = 9
CR = 13
LF = 10
NULL = 0
SPACE = ' '
ESC = 27

    IFNDEF TIMEX80
MIME_DOWNLOAD = 1
MIME_LINK     = 2
MIME_TEXT     = 3 
MIME_IMAGE    = 6 
MIME_MUSIC    = 5 
MIME_INPUT    = 4
MIME_MOD      = 7

BORDER_TOP    = 9
BORDER_BOTTOM = 8
    ELSE
MIME_DOWNLOAD = #19
MIME_LINK = #1A
MIME_TEXT = #10
MIME_IMAGE = #01
MIME_MUSIC = #0e
MIME_INPUT = #b3
MIME_MOD = #0d

BORDER_TOP = #b2
BORDER_BOTTOM = #b1

    ENDIF

sepparators db CR, LF, TAB, NULL, SPACE
sepparators_len = $ - sepparators