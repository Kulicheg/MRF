;clock driver nedoOS
	module Clock
readTime
	ld c,nos.CMD_GETTIME
    call nos.BDOS		;out: ix=date, hl=time
	di
	push ix
	pop bc
	ei

	push hl
	pop de
	ld a,e
    add a,a
    and 63	;seconds
	ld (seconds),a
    	
	ld a,d
    rra
    rra
    rra
    and 31 		;hours
	ld (hours),a

    ex de,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ex de,hl
    ld a,d
    and 63       ;minutes
 	ld (minutes),a

;   ld a,h
;   srl a
;   ;sub 20
;   ld (year),a
;   ld a,l
;   and 31
;   ld (day),a
;   add hl,hl
;   add hl,hl
;   add hl,hl
;   ld a,h
;   and 15
;   ld (month),a


  	ret
    endmodule
