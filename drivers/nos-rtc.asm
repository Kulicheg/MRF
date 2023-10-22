;clock driver nedoOS
	module Clock
readTime
	ld c,nos.CMD_GETTIME
    call nos.BDOS		;out: ix=date, hl=time
	di
	push ix
	pop bc
	ei
  	ret ;return bc=date, hl=time
    endmodule
