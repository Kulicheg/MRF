    MODULE Wifi
	macro OS_NETSOCKET ;D=address family (2=inet, 23=inet6), E=socket type (0x01 tcp/ip, 0x02 icmp, 0x03 udp/ip) ;out: L=SOCKET (if L < 0 then A=error)
		ld l,0x01
		ld c,nos.CMD_WIZNETOPEN
		call nos.BDOS
	endm
	macro OS_NETCONNECT;A=SOCKET, DE=sockaddr ptr {unsigned char sin_family /*net type*/; unsigned short sin_port; struct in_addr sin_addr /*4 bytes IP*/; char sin_zero[8];}; out: if HL < 0 then A=error
		ld l,0x03
		ld c,nos.CMD_WIZNETOPEN
		ex af,af'
		call nos.BDOS
	endm	
	macro OS_WIZNETWRITE;A=SOCKET, de=buffer_ptr, HL=sizeof(buffer) ; out: HL=count if HL < 0 then A=error
		ld c,nos.CMD_WIZNETWRITE
		ex af,af'
		call nos.BDOS
	endm
	macro OS_WIZNETREAD;A=SOCKET, de=buffer_ptr, HL=sizeof(buffer) ; out: HL=count if HL < 0 then A=error
		ld c,nos.CMD_WIZNETREAD
		ex af,af'
		call nos.BDOS
	endm
	macro OS_NETSHUTDOWN;A=SOCKET ; out: if HL < 0 then A=error
		ld l,0x02
		ld c,nos.CMD_WIZNETOPEN
		ex af,af'
		call nos.BDOS
	endm
	
	macro OS_GETDNS;DE= ptr to DNS buffer(4 bytes)
		ld l, 0x08
		ld c, nos.CMD_WIZNETOPEN
		ex af,af' ;'
		call nos.BDOS ;c=CMD
	endm	

	macro OS_YIELD
		push bc
    	ld c,nos.CMD_YIELD
        call nos.BDOS
        pop bc
	endm	

init:
; Nothing to init there
	ret

host_ia:
.curport=$+1
	defb 0,0,80,8,8,8,8
	
tcpSendZ
	push hl
	pop de
	push de
	call strLen
	pop de
	ld a,(sock_fd)
	OS_WIZNETWRITE
	ld hl,2
	ld de,.rn
	ld a,(sock_fd)
	OS_WIZNETWRITE
	ret
.rn defb "\r\n"	
	
getPacket
;if A = op8 then the C flag is reset, and Z is set.
;If A < op8, C is set and Z is reset. 
;If A > op8 then both C and Z are reset
    ld de,(buffer_pointer)
	ld a,0xfb
	cp d
	jp nc, letsgo
	ld hl, .errMem : call DialogBox.msgBox
	ld a,1
	ld (closed),a
	xor a
	ld (bytes_avail),a
	ret
.errMem:
	db "Out of memory. Page loading error.",0
letsgo:
    ld de,(buffer_pointer)
    ld hl,TCP_BUFFER_SIZE
    ld a,(sock_fd)
	OS_WIZNETREAD
    BIT 7,H
    JR Z,RECEIVED	;ошибок нет
	CP 35   ;ERR_EAGAIN
    jp z, letsgo
    ;обработка ошибки
    ld a,1
    ld (closed), a
    LD	a,(sock_fd)
    LD	E,0
	OS_NETSHUTDOWN
	ld hl,(buffer_pointer)
	ld de,outputBuffer
	or a
	sbc hl,de
    ld (bytes_avail),HL	
    ret
RECEIVED
	ex hl,de
    ld hl,(buffer_pointer)
	add hl,de
	ld (buffer_pointer),hl
	ld de,outputBuffer
	or a
	sbc hl,de
    ld (bytes_avail),HL
    ret
	
	
openTCP ;DE - port_str, HL - domain name
	push hl
	call atohl
	ld a,h,h,l,l,a
	ld (host_ia.curport),hl      
	pop de
	call dns_resolver
	ld a,h : or l : jp z,reqErr
	ld de,host_ia+3
	ld bc,4
	ldir
	ld de,1+(2<<8)
	OS_NETSOCKET
	ld a,l : or a : jp m,reqErr
	ld (sock_fd),a
	ld de,host_ia
	OS_NETCONNECT
    ld a,l : or a : jp m,reqErr
    xor a : ld (closed), a
	ret
	
closed
    defb 1
bytes_avail
    defw 0
buffer_pointer
    defw 0
	
reqErr
    ld hl, .errMsg : call DialogBox.msgBox
    scf
    ret
.errMsg db "Socket failed!",0
	
dns_resolver:		;DE-domain name
    ld (.httphostname),de
    ld a,254
    ld (.dns_err_count),a
.dns_err_loop
	;push de
	ld hl,.dns_head
	ld de,outputBuffer
	ld bc,6
	ldir
	ex de,hl
	ld de,outputBuffer+7
	ld (hl),b;0
	ld  c,256-7
	ldir
	ld de,outputBuffer+12
	ld h,d
	ld l,e
	ld bc,.httphostname ;pop bc
.httphostname=$-2
.name_loop:
	inc hl
	ld a,(bc)
	ld (hl),a
	inc bc
	cp '.'
	jr z,.is_dot
	or a
	jr nz,.name_loop
.is_dot:
	sbc hl,de
	ex de,hl
	dec e
	ld (hl),e
	inc e
	add hl,de
	ld d,h
	ld e,l
	or a
	jr nz,.name_loop
	inc a
	inc hl
	inc hl
	ld (hl),a
	inc hl
	inc hl
	ld (hl),a
	inc hl
	push hl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld a, (.dns_ia2)
	cp 0
	jp nz, .skipgetdns
	ld de, .dns_ia2;DE= ptr to DNS buffer(4 bytes)
	OS_GETDNS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.skipgetdns:
	ld de,0x0203
    OS_NETSOCKET
	ld a,l
	ld (sock_fd),a
	or a
	jp m,.dns_exiterr
	pop hl
	push hl
	ld de,0xffff&(-outputBuffer)
	add hl,de
	LD	a,(sock_fd)
	LD	IX,outputBuffer
	LD	DE,.dns_ia
	OS_WIZNETWRITE
	bit 7,h
	jr nz,.dns_exitcode
.dns_err_count=$+1
	ld b,32
	jr .recv_wait1
.recv_wait:
        push bc
        ld c,nos.CMD_YIELD
        call nos.BDOS
        pop bc
.recv_wait1:
	push bc
	ld hl,256
	LD	a,(sock_fd)
	LD	DE,outputBuffer
	LD	IX,outputBuffer
	OS_WIZNETREAD
	pop bc
	bit 7,h
	jr z,.recv_wait_end
	djnz .recv_wait
	jr .dns_exiterr
.recv_wait_end:
	ld a,(outputBuffer+3)
	and 0x0f	
	jr nz,.dns_exiterr
.dns_exitcode:
	LD	a,(sock_fd)
	LD	E,0
	OS_NETSHUTDOWN
	pop hl
.reqpars_l
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	ld de,7
	add hl,de
	ld b,(hl)
	inc hl
	ld c,(hl)
	inc hl
	dec a
	ret z
	cp 4
	jr nz,.exiterr1
	add hl,bc
	jr .reqpars_l
.dns_exiterr:
	pop af
	LD	a,(sock_fd)
	LD	E,0
	OS_NETSHUTDOWN
    ld a,(.dns_err_count)
    add a,a
    ld (.dns_err_count),a
	OS_YIELD
    jp nc,.dns_err_loop
.exiterr1:
    ld hl,0
	ret
.dns_head
	defb 0x11,0x22,0x01,0x00,0x00,0x01

;struct sockaddr_in {unsigned char sin_family;unsigned short sin_port;
;	struct in_addr sin_addr;char sin_zero[8];};
.dns_ia:
	defb 0
        db 0,53 ;port (big endian)
.dns_ia2:
        db 0,0,0,0 ;ip (big endian)

sock_fd     defb 0
    ENDMODULE	