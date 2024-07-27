    DEFINE TCP_BUFFER_SIZE 2048
; Generate version string
    LUA ALLPASS
    v = tostring(sj.get_define("V"))
    maj = string.sub(v, 1,1)
    min = string.sub(v, 2,2)
    sj.insert_define("VERSION_STRING", "\"" .. maj .. "." .. min .. "\"")

    b = tostring(sj.get_define("BLD"))
    sj.insert_define("BUILD_STRING", "\"" .. b .. "\"")
    ENDLUA

    IFDEF MSX
        include "main-msx.asm"
    ELSE
        include "main-all.asm"
    ENDIF