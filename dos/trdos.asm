;trdos driver (izzx)
    MODULE Dos
; API methods
ESX_GETSETDRV = #89
ESX_FOPEN = #9A
ESX_FCLOSE = #9B
ESX_FSYNC = #9C
ESX_FREAD = #9D
ESX_FWRITE = #9E

; File modes
FMODE_READ = #01
FMODE_WRITE = #06
FMODE_CREATE = #0E

    ; MACRO esxCall func
    ; rst #8 : db func
    ; ENDM
	
;id = 0 䠩� �� �����
;id = 1 䠩� ��� �⥭��
;id = 2 䠩� ��� �����
;id = 3 䠩� ��� ����� ⨯ TRD
;id = 4 䠩� ��� ����� ⨯ SCL

; HL - filename in ASCIIZ
loadBuffer:
    ld b, Dos.FMODE_READ: call Dos.fopen
    push af
        ld hl, outputBuffer, bc, #ffff - outputBuffer : call Dos.fread
        ld hl, outputBuffer : add hl, bc : xor a : ld (hl), a : inc hl : ld (hl), a
    pop af
    call Dos.fclose
    ret


; Returns: 
;  A - current drive
; getDefaultDrive: ;����� �� �ᯮ������
    ; ld a, 0 : esxCall ESX_GETSETDRV
    ; ret



; Opens file on default drive
; B - File mode
; HL - File name
; Returns:
;  A - file stream id
fopen:
    ; push bc : push hl 
    ; call getDefaultDrive
    ; pop ix : pop bc
    ; esxCall ESX_FOPEN
    ; ret
	ld a,b
	cp FMODE_READ ;�᫨ ०�� ����⨥ 䠩��
	jr z,fopen_r
	cp FMODE_CREATE
	jr z,fopen_c ;�᫨ ०�� ᮧ����� 䠩��
	jr fopen_err ;���� ��室
	
fopen_r	;����⨥ �������饣� 䠩�� �� �⥭�� (id=1)
	; ld a,(#5D19) ;����� ��᪮���� �� 㬮�砭��
	; ld 	(prev_drive),a ;��������
			call format_name ;
			ld      c,#13 ;move file info to syst var
            call    call3d13
            ld      c,#0a ;find file
            call    call3d13
            ld      a,c
			cp 		#ff
			jr 		z,fopen_err ;�᫨ �� ��諨 䠩��
            ld      c,#08 ;read file title
            call    call3d13
            ;ld      hl,loadadr ;�㤠
            ld      de,(#5ceb) ;��砫� 䠩�� ᥪ�� ��஦��
            ld      (f_r_cur_trk),de

            ld      a,(#5cea)
            ld      (f_r_len_sec),a ;����� � ᥪ���
            ;or      a
            ;ret     z    ;��室 �᫨ ���⮩
			
			ld de,(#5CE8) ; ����� 䠩�� ��� �ணࠬ���� ��� ��� BASIC
			ld      (f_r_len),de

            ; ld      de,(fcurtrk) ;⥪�騥 ᥪ�� ��஦��
            ; ld      (#5cf4),de ;����⠭����
			xor a
			ld 		a,1
			ld (f_r_flag),a ;䫠� �� 䠩� ��� �⥭�� �����
			;id ������ �㤥� 1
	ret
	
fopen_err
	xor a ;�᫨ ������� 䠩� �� ���뫨, � id = 0
	scf ;䫠� �訡��
	ret


fopen_c	;ᮧ����� ������ 䠩�� (id=2-4)
	; ld a,(#5D19) ;����� ��᪮���� �� 㬮�砭��
	; ld 	(prev_drive),a ;��������
	call format_name ;
	;���᭨�, �� ��ࠧ �� �� ��� ࠧ���稢����
    ld hl, trdExt1 : call CompareBuff.search : and a : jr nz, fopen_c_trd
    ld hl, trdExt2 : call CompareBuff.search : and a : jr nz, fopen_c_trd
	ld hl, sclExt1 : call CompareBuff.search : and a : jp nz, fopen_c_scl
    ld hl, sclExt2 : call CompareBuff.search : and a : jp nz, fopen_c_scl

	
	;ᮧ����� �ந����쭮�� 䠩�� (id=2)
	call select_drive
	cp "y"
	jr nz,fopen_err

	call cat_buf_cls

	ld hl,cat_buf ;��⠥� ��⠫�� ��᪠
	ld de,0
    ld      bc,#0905 ;
    call    call3d13
	
	ld a,(cat_buf+8*256+#e4) ; ��饥 ������⢮ 䠩���
	cp 128
	jp c,fopen_c2 ;�᫨ 㦥 ���ᨬ�
    ld hl, file_err
    call DialogBox.msgBox ;�।�०�����			
	jr fopen_err	
	
fopen_c2	
	ld hl,(cat_buf+8*256+#e5) ; ������⢮ ᢮������ ᥪ�஢ �� ��᪥
	ld a,h
	or l
	jr nz,fopen_c3 ;�᫨ ��� ���� ����
    ld hl, file_err
    call DialogBox.msgBox ;�।�०�����			
	jr fopen_err

fopen_c3	
	ld de,(cat_buf+8*256+#e1) ;���� ᢮����� ᥪ��-��஦�� 
    ld   (#5cf4),de ;��� �㤥� ����� 䠩�	
	
	xor a 
	ld (sec_shift),a ;��६�����
	ld hl,0
	ld (f_w_len+0),hl
	ld (f_w_len+2),hl
	ld a,2 ;id ������
	ld (f_w_flag),a ;䫠� �� 䠩� ��� ����� �����	
	ret
	
	
cat_buf_cls ;���⪠ ���� ��⠫���
	ld hl,cat_buf ;������ ���� ��� ��⠫��� ��᪥��
	ld de,cat_buf+1
	ld (hl),0
	ld bc,9*256-1
	ldir
	ret



fopen_c_trd	;����⨥ 䠩�� ��� ࠧ���稢���� ��ࠧ� trd (id=3)
	call select_drive
	cp "y"
	jp nz,fopen_err
	
	ld      de,0 ;��砫� ᥪ�� ��஦��
    ld      (#5cf4),de
	
	xor a 
	ld (sec_shift),a ;��६�����
	ld hl,0
	ld (f_w_len+0),hl
	ld (f_w_len+2),hl
	ld a,3 ;id ������
	ld (f_w_flag),a ;䫠� �� trd ��� ����� �����
	ret
	


fopen_c_scl	;����⨥ 䠩�� ��� ࠧ���稢���� ��ࠧ� scl (id=4)
	call select_drive
	cp "y"
	jp nz,fopen_err
	
	ld      de,0 ;��砫� ᥪ�� ��஦��
    ld      (#5cf4),de
	
	call cat_buf_cls ;������� ����
	
	call scl_parse ;����� 横�� ᡮન ��ࠧ�
	
	xor a 
	ld (sec_shift),a ;��६�����
	;ld (scl_que),a
	ld hl,0
	ld (f_w_len+0),hl
	ld (f_w_len+2),hl
	ld a,4 ;id ������
	ld (f_w_flag),a ;䫠� �� scl ��� ����� �����
	ret	





select_drive	;����� ����� ��᪮����
	ld a,(#5D19) ;����� ��᪮���� �� 㬮�砭��
	add a,"A"
	ld (write_ima_d),a ;����⠢�� �㪢� � �����
    ld hl, write_ima
    call DialogBox.msgNoWait ;�।�०�����
WAITKEY_trd	
	;halt
	call Console.getC
	cp 255
	JR Z,WAITKEY_trd	;��� ���� �������
	cp "y"
	ret z
	cp "n"
	ret z
	cp "a"
	jr c,WAITKEY_trd
	cp "e"
	jr nc,WAITKEY_trd
	sub "a"
    ld      (#5d19) ,a
    ld      c,1
    call    call3d13
    ld      c,#18
    call    call3d13
	jr select_drive


; restore_drive ;����⠭����� ��᪮��� �� 㬮�砭��
	; ld 	a,(prev_drive)
    ; ld      (#5d19) ,a
    ; ld      c,1
    ; call    call3d13
    ; ld      c,#18
    ; call    call3d13
	; ret


call3d13 ;䨪� ��� GMX
	ifndef ZSGMX
    jp    #3d13
	endif
	
	ifdef ZSGMX
    call    #3d13
	exx
	call TextMode.gmxscron
	exx
	endif
	ret
	
	

; A - file stream id
fclose:
    ;esxCall ESX_FCLOSE
	; push af
; WAITKEY2	XOR A:IN A,(#FE):CPL:AND #1F:JR Z,WAITKEY2
	; pop af
	cp 2 ;�᫨ ����� 䠩� 
	jp nz,fclose_scl

	;������� ���⮪ 䠩��
	ld a,(write_end_flag) ;�㦭� �����뢠�� ���⮪?
	or a
	jr nz,fclose_f ;�� �㦭�

	ld hl,sec_buf
	ld bc,#0106
	ld de,(#5cf4)
	call call3d13
	
	ld a,"0" ;����� ��� 䠩��
	ld (file_num),a
	
fclose_f ;���ࠢ��� ��⠫��
	ld a,(f_w_len+2) ;ᠬ� ���訩 ���� ����� 䠩��
	ld hl,(f_w_len+0)
	or h
	or l
	jp z,fclose_ex ;��室 �᫨ ����� 0 
	
	;�஢�ન �� ����������
	ld a,(cat_buf+8*256+#e4) ; ��饥 ������⢮ 䠩���
	cp 128
	jp nc,fclose_ex ;�᫨ 㦥 ���ᨬ�
	ld hl,(cat_buf+8*256+#e5) ; ������⢮ ᢮������ ᥪ�஢ �� ��᪥
	ld a,h
	or l
	jp z,fclose_ex ;�᫨ ���� ���	
	
	ld a,(f_w_len+2) ;ᠬ� ���訩 ���� ����� 䠩��
	or a
	jr nz,fclose_f_multi ;�᫨ 䠩� ����� 255 ᥪ�஢ (65280)
	ld a,(f_w_len+1)
	cp 255
	jr nz,fclose_f1
	ld a,(f_w_len+0)
	jr nz,fclose_f_multi ;�᫨ 䠩� ����� 255 ᥪ�஢ (65280)
fclose_f1
	;䠩� �� �ॢ�蠥� ���ᨬ���� ࠧ��� ��� trdos 
	ld de,(f_w_len+0)	
	ld hl,f_name+11 ;����� 䠩��
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	ld a,(f_w_len+1) ;����� ᥪ�஢
	ld (hl),a
	ld a,(f_w_len+0) ;����� ����訩
	or a
	jr z,fclose_f2
	inc (hl) ;���४�� ᥪ�஢
fclose_f2
	call fclose_f_one ;������� ���ଠ��
	jp fclose_ex ;��⮢�
	
fclose_f_multi ;䠩� ����让, �㤥� ��᪮�쪮 ����ᥩ � ��⠫���	
	ld a,(file_num)
	ld (f_name+7),a ;� ���� ����� �����
	
	ld hl,f_name+11 ;����� 䠩��
	ld (hl),0
	inc hl
	ld (hl),#ff ;65280
	inc hl
	;����� ᥪ�஢
	ld (hl),#ff
	call fclose_f_one ;������� ���ଠ��
	
	;������ ����� ����ᠭ����
	ld hl,(f_w_len+1) ;���訩 � �।��� ����	
	ld bc,255
	and a
	sbc hl,bc ;������ 255 ᥪ�஢
	ld (f_w_len+1),hl
	
	ld a,(file_num)
	inc a
	ld (file_num),a
	ld (f_name+7),a ;� ���� ����� �����

	jr fclose_f ;᭠砫�

	
fclose_f_one ;������ �� ����� 䠩��
			ld a,(cat_buf+8*256+#e4) ; ��饥 ������⢮ 䠩���
			ld l,a ;㧭��� � ����� ᥪ�� �㤥� ������ � 䠩��
			ld h,0
			add hl,hl ;*2
			add hl,hl ;*4
			add hl,hl ;*8
			add hl,hl ;*16
			ld a,h ;��������� ����� ��� � ��⠫���
			ld (sec_cat),a
			ld bc,cat_buf
			add hl,bc ;����� �㤥� ������ � ����� 䠩��
			ex de,hl
			
			ld hl,f_name ;������ � 䠩��
			ld bc,16
			ldir ;᪮��஢���
			ex de,hl
			dec hl
			ld de,(cat_buf+8*256+#e1) ;���� ᢮����� ᥪ��-��஦�� �����祭��
			ld (hl),d ;��஦��
			dec hl
			ld (hl),e ;ᥪ��
			
			ld l,0 ;������� ᥪ�� 楫���� �� ஢���� �����
			ld d,0
			ld a,(sec_cat)
			ld e,a ;����� ᥪ��
			ld bc,#0106 ;1 ᥪ�� �������
			call call3d13			
			
			;�㦥��� ᥪ��
			ld de,(cat_buf+8*256+#e1) ;���� ᢮����� ᥪ��-��஦�� 
			ld a,(f_name+13) ;ࠧ��� 䠩�� � ᥪ���
			ld b,a
			call calc_next_pos2
			ld (cat_buf+8*256+#e1),de

			ld hl,(cat_buf+8*256+#e5) ; ������⢮ ᢮������ ᥪ�஢ �� ��᪥
			ld a,(f_name+13) ;ࠧ��� 䠩�� � ᥪ���
			ld c,a
			ld b,0
			and a
			sbc hl,bc
			jr nc,fclose_f_one2
			ld hl,0 ;�᫨ �뫮 ����⥫쭮�
fclose_f_one2
			ld (cat_buf+8*256+#e5),hl
			
			ld hl,cat_buf+8*256+#e4 ; ��饥 ������⢮ 䠩���			
			inc (hl)
			
			ld hl,cat_buf+8*256
			ld de,#0008
			ld bc,#0106 ;1 ᥪ�� �������
			call call3d13
			ret
	
	
fclose_scl	
	cp 4 ;�᫨ scl
	jr nz,fclose_ex
	ld hl,sec_buf ;
	ld b,1
	call scl_write_buf ;����襬 ���⮪ scl, �᫨ ����
	
fclose_ex	
	xor a ;��� �� ����뢠�� �� 䠩��
	ld (f_r_flag),a
	ld (f_w_flag),a
	;call restore_drive ;������ ���, ����� ��
    ret




; A - file stream id
; BC - length
; HL - buffer
; Returns
;  BC - length(how much was actually read) 
fread: ;(id=1)
    ; push hl : pop ix
    ; esxCall ESX_FREAD
	; push af
	; ld a,4
	; out (254),a
; WAITKEY	XOR A:IN A,(#FE):CPL:AND #1F:JR Z,WAITKEY
	; xor a
	; out (254),a
	; pop af

	cp 1 ;id = 1?
	jr nz,fread_no_chek ;��室 �᫨ ����� ��⮪� �� = 1
	ld a,(f_r_flag)
	or a
	jr nz,fread_chek ;䠩� 㦥 �����?
fread_no_chek ;��室 � �訡���
	xor a
	scf ;䫠� �訡��
	ld bc,0 ;��祣� �� �� ��⠫�
	ret
	
fread_chek
	ld bc,(f_r_len_sec-1) ;����㦠�� 䠩� 楫����, �� ᬮ��� �� �, ᪮�쪮 ���� �뫮 ����襭�
    ld      c,5 ;read �⠥� 楫묨 ᥪ�ࠬ�
	ld de,(f_r_cur_trk)
    call    call3d13	
	ld bc,(f_r_len) ;�����⨬ ᪮�쪮 ��⠫� ���� (����� 䠩��)
	xor a ;䫠�� ��ᨬ
    ret

; A - file stream id
; BC - length
; HL - buffer
; Returns:
;   BC - actually written bytes
fwrite: ;
    ; push hl : pop ix
    ; esxCall ESX_FWRITE
	
	; push af
	; ld a,2
	; out (254),a
; WAITKEY1	XOR A:IN A,(#FE):CPL:AND #1F:JR Z,WAITKEY1
	; xor a
	; out (254),a
	; pop af

	cp 2 ;id = 2?
	jr z,fwrite_chek ;�஢�ઠ id ��⮪�
	cp 3 ;id = 3?
	jr z,fwrite_chek_trd ;�஢�ઠ id ��⮪�
	cp 4 ;id = 4?
	jp z,fwrite_chek_scl ;�஢�ઠ id ��⮪�

	
fwrite_no_chek ;��室 � �訡���
	xor a
	scf ;䫠� �訡��
	ld bc,0 ;��祣� �� �� ����ᠫ�
	ret
	
fwrite_chek ;������ �ந����쭮�� ⨯� 䠩�� (id=2)

	;�� �⫨砥��� �� ����� trd, ������ �室�騩 ��⮪ �� ���, �⫨�� �� ����⨨ � �����⨨ 䠩��





fwrite_chek_trd ;������ trd 䠩�� (ࠧ���稢���� ��ࠧ�, id=3)
	; ld a,2
	; out (254),a
; WAITKEY_t	XOR A:IN A,(#FE):CPL:AND #1F:JR Z,WAITKEY_t
	; xor a
	; out (254),a
	ld a,(f_w_flag)
	or a
	jr z,fwrite_no_chek ;䠩� 㦥 �����?
	ld (temp_bc),bc ;�����
	ld (temp_hl),hl ;���� ������
	ld a,b
	or c
	jr z,fwrite_no_chek ; �᫨ ����� 0, � ��室
	
	;���� �� ��९������� ��᪠
	ld de,(#5cf4)
	ld a,d
	cp #a0 ;��᫥���� ��஦�� 160
	jr nc,fwrite_no_chek
	
	xor a
	ld (sec_part),a ;���㫨�� ��६����
	ld (sec_shift2),a
	ld (sec_shift2+1),a
	ld (sec_shift_flag),a
	ld (write_end_flag),a ;
	

	ld a,(sec_shift)
	or a
	jr z,fwrite_trd3 ;�᫨ ᬥ饭�� ���, � ����� ���� �ய��⨬
	

	ld c,a
	ld b,0
	ld hl,(temp_bc) ;�஢�ઠ ���������� �� 楫� ᥪ��
	add hl,bc
	
	ld a,1
	ld (write_end_flag),a ;䫠� �� �� �㦭� �����뢠�� ���⮪
	
	ld a,h
	or a
	jr nz,fwrite_trd4
	ld a,1
	ld (sec_shift_flag),a ;䫠� �� �� �������� ᥪ��
	
fwrite_trd4	
	ld hl,sec_buf ;���� ��᫥����� ᥪ��	
	add hl,bc ;�� �⮩ �窥 ��⠭�������
	ex de,hl
	ld hl,(temp_hl) ;��ᮥ����� ��砫� ������ � ����� �।����
	; ld a,c
	; or a
	; jr nz,fwrite_trd2
	; inc b ;���४��
; fwrite_trd2		
	; ld c,a
	xor a
	sub c
	ld c,a ;᪮�쪮 ��⠫��� ��७��� �� ���������� ᥪ��
	ld (sec_shift2),bc ;��࠭�� ᪮�쪮 �������� ����
	ldir

	ld a,(sec_shift_flag)
	or a
	jr nz,fwrite_trd3 ;�᫨ ᥪ�� ��� �� �������� ����� �� �㤥�

	ld hl,sec_buf
	ld de,(#5cf4)
	;ld (f_w_cur_trk),de	;�������� ������
    ld      bc,#0106 ;��襬 1 ᥪ�� �� ����
    call    call3d13	
	ld a,c
	cp 255
	jp z,fwrite_no_chek ;��室 �᫨ �訡��	

	xor a
	ld (write_end_flag),a ;䫠� �� �㦭� �����뢠�� ���⮪	
	; ld de,(f_w_cur_trk) ;�᫨ ᥪ�� ��� �� ��������, ��⠭���� �� ��ன ����樨
	; ld (#5cf4),de
	; ld b,1 ;�� ᥪ�� �����
	; ld de,(f_w_cur_trk)
	; call calc_next_pos
	; ld (f_w_cur_trk),de	

fwrite_trd3	
	ld hl,(temp_hl) ;����襬 ���⮪ ������
	;ld a,(sec_shift)
	;ld c,a
	;ld b,0
	ld bc,(sec_shift2)
	add hl,bc ;� �⮩ �窨 ��襬
	ld (temp_hl2),hl ;��࠭�� ��砫� ����� ��ண� ᥪ��
	
	ld hl,(temp_bc) ;���᫥��� �� �� ��⠭������ � ��� ࠧ
	and a
	sbc hl,bc ;���⥬ �, �� �������� � ��ࢮ�� ᥪ���
	ld c,l
	ld b,h
	jr nc,fwrite_trd5
	ld b,0 ;���४�� �᫨ ��襫 �����
fwrite_trd5
	ld hl,(temp_hl)
	add hl,bc 
	
	ld de,outputBuffer
	and a
	sbc hl,de
	
	ld a,l
	ld (sec_shift),a ;ᬥ饭�� �� ᫥���騩 ࠧ
	;ld hl,(temp_hl)	
	

	; or a
	; jr z,fwrite_trd1
	; inc b  ;���४�� ������⢠ ᥪ�஢
	
	ld a,b ;�㦭� �஢�ઠ �� ������⢮ ᥪ�஢!!!
	ld (sec_part),a ;�������� ᪮�쪮 ᥪ�஢ �� ��ன ���
	
	;ld a,b	
	or a
	jr z,fwrite_trd1 ;�᫨ ࠧ��� ������ ����� ᥪ��, � �ய��⨬ ������
	
	ld hl,(temp_hl2)
	;push bc
	ld de,(#5cf4)
    ld      c,6 ;��襬 楫묨 ᥪ�ࠬ�
    call    call3d13	
	ld a,c
	;pop bc
	cp 255
	jp z,fwrite_no_chek ;��室 �᫨ �訡��
	; ld de,(f_w_cur_trk)
	; call calc_next_pos
	; ld (f_w_cur_trk),de
	
	xor a
	ld (write_end_flag),a ;䫠� �� �㦭� �����뢠�� ���⮪	
	
fwrite_trd1	
	ld a,(write_end_flag) ;�㦭� �����뢠�� ���⮪?
	or a
	jr nz,fwrite_trd_ex ;�� �㦭�

	ld hl,(temp_hl2) ;��࠭�� ������ᠭ�� ���⮪
	ld a,(sec_part)
	ld b,a
	ld c,0
	add hl,bc
	ld de,sec_buf
	ld bc,256
	ldir
;fwrite_trd2	

	
fwrite_trd_ex	
	ld bc,(temp_bc) ;�����⨬, �� ᪮�쪮 ����訢���, �⮫쪮 � ����ᠫ� ����
	;����⠥� ����� ����� ����ᠭ����
	ld hl,(f_w_len)
	add hl,bc
	ld (f_w_len),hl
	jr nc,fwrite_trd_ex1
	ld hl,(f_w_len+2)
	inc hl
	ld (f_w_len+2),hl
	
fwrite_trd_ex1
	xor a ;䫠�� ��ᨬ
    ret





;------------------scl----------------------
fwrite_chek_scl ;������ scl 䠩�� (ࠧ���稢���� ��ࠧ�, id=4)
	; ld a,2
	; out (254),a
; WAITKEY_t	XOR A:IN A,(#FE):CPL:AND #1F:JR Z,WAITKEY_t
	; xor a
	; out (254),a
	ld a,(f_w_flag)
	or a
	jp z,fwrite_no_chek ;䠩� 㦥 �����?
	ld (temp_bc),bc ;�����
	ld (temp_hl),hl ;���� ������
	ld a,b
	or c
	jp z,fwrite_no_chek ; �᫨ ����� 0, � ��室
	
	; ld a,b
	; or a
	; jr nz,testt1
	; nop
	
; testt1
	
	xor a
	ld (sec_part),a ;���㫨�� ��६����
	ld (sec_shift2),a
	ld (sec_shift2+1),a
	ld (sec_shift_flag),a
	ld (write_end_flag),a ;
	

	ld a,(sec_shift)
	or a
	jr z,fwrite_scl3 ;�᫨ ᬥ饭�� ���, � ����� ���� �ய��⨬
	

	ld c,a
	ld b,0
	ld hl,(temp_bc) ;�஢�ઠ ���������� �� 楫� ᥪ��
	add hl,bc
	
	ld a,1
	ld (write_end_flag),a ;䫠� �� �� �㦭� �����뢠�� ���⮪
	
	ld a,h
	or a
	jr nz,fwrite_scl4
	ld a,1
	ld (sec_shift_flag),a ;䫠� �� �� �������� ᥪ��
	
fwrite_scl4	
	ld hl,sec_buf ;���� ��᫥����� ᥪ��	
	add hl,bc ;�� �⮩ �窥 ��⠭�������
	ex de,hl
	ld hl,(temp_hl) ;��ᮥ����� ��砫� ������ � ����� �।����
	; ld a,c
	; or a
	; jr nz,fwrite_scl2
	; inc b ;���४��
; fwrite_scl2		
	; ld c,a
	xor a
	sub c
	ld c,a ;᪮�쪮 ��⠫��� ��७��� �� ���������� ᥪ��
	ld (sec_shift2),bc ;��࠭�� ᪮�쪮 �������� ����
	ldir

	ld a,(sec_shift_flag)
	or a
	jr nz,fwrite_scl3 ;�᫨ ᥪ�� ��� �� �������� ����� �� �㤥�

	ld hl,sec_buf
	;ld de,(#5cf4)
	;ld (f_w_cur_trk),de	;�������� ������
    ld      b,#01 ;��襬 1 ᥪ�� �� ����
    call    scl_write_buf	
	; ld a,c
	; cp 255
	; jp z,fwrite_no_chek ;��室 �᫨ �訡��	

	xor a
	ld (write_end_flag),a ;䫠� �� �㦭� �����뢠�� ���⮪	
	; ld de,(f_w_cur_trk) ;�᫨ ᥪ�� ��� �� ��������, ��⠭���� �� ��ன ����樨
	; ld (#5cf4),de
	; ld b,1 ;�� ᥪ�� �����
	; ld de,(f_w_cur_trk)
	; call calc_next_pos
	; ld (f_w_cur_trk),de	

fwrite_scl3	
	ld hl,(temp_hl) ;����襬 ���⮪ ������
	;ld a,(sec_shift)
	;ld c,a
	;ld b,0
	ld bc,(sec_shift2)
	add hl,bc ;� �⮩ �窨 ��襬
	ld (temp_hl2),hl ;��࠭�� ��砫� ����� ��ண� ᥪ��
	
	ld hl,(temp_bc) ;���᫥��� �� �� ��⠭������ � ��� ࠧ
	and a
	sbc hl,bc ;���⥬ �, �� �������� � ��ࢮ�� ᥪ���
	ld c,l
	ld b,h
	jr nc,fwrite_scl5
	ld b,0 ;���४�� �᫨ ��襫 �����
fwrite_scl5
	ld hl,(temp_hl)
	add hl,bc 
	
	ld de,outputBuffer
	and a
	sbc hl,de
	
	ld a,l
	ld (sec_shift),a ;ᬥ饭�� �� ᫥���騩 ࠧ
	;ld hl,(temp_hl)	
	

	; or a
	; jr z,fwrite_scl1
	; inc b  ;���४�� ������⢠ ᥪ�஢
	
	ld a,b ;�㦭� �஢�ઠ �� ������⢮ ᥪ�஢!!!
	ld (sec_part),a ;�������� ᪮�쪮 ᥪ�஢ �� ��ன ���
	
	;ld a,b	
	or a
	jr z,fwrite_scl1 ;�᫨ ࠧ��� ������ ����� ᥪ��, � �ய��⨬ ������
	
	ld hl,(temp_hl2)
	;push bc
	;ld de,(#5cf4)
    ;ld      c,6 ;��襬 楫묨 ᥪ�ࠬ�
    call    scl_write_buf	
	;ld a,c
	;pop bc
	; cp 255
	; jp z,fwrite_no_chek ;��室 �᫨ �訡��
	; ld de,(f_w_cur_trk)
	; call calc_next_pos
	; ld (f_w_cur_trk),de
	
	xor a
	ld (write_end_flag),a ;䫠� �� �㦭� �����뢠�� ���⮪	
	
fwrite_scl1	
	ld a,(write_end_flag) ;�㦭� �����뢠�� ���⮪?
	or a
	jr nz,fwrite_scl_ex ;�� �㦭�

	ld hl,(temp_hl2) ;��࠭�� ������ᠭ�� ���⮪
	ld a,(sec_part)
	ld b,a
	ld c,0
	add hl,bc
	ld de,sec_buf
	ld bc,256
	ldir
;fwrite_scl2	

	
fwrite_scl_ex	
	ld bc,(temp_bc) ;�����⨬, �� ᪮�쪮 ����訢���, �⮫쪮 � ����ᠫ� ����
	;����⠥� ����� ����� ����ᠭ����
	ld hl,(f_w_len)
	add hl,bc
	ld (f_w_len),hl
	jr nc,fwrite_scl_ex1
	ld hl,(f_w_len+2)
	inc hl
	ld (f_w_len+2),hl
	
fwrite_scl_ex1
	xor a ;䫠�� ��ᨬ
    ret






scl_write_buf ;���������� �஬����筮�� ����
	push bc ;᪮�쪮 ����⮢ 㪠���� � b
	ld de,scl_buf ;��७��� ᥪ�� �� �६���� ����
	ld bc,256
	ldir
	ld (scl_temp_hl2),hl ;��࠭�� ���� ������
	ld a,(scl_que) ;�஢�ਬ 䫠� �� �㦭� �����
	or a
	jr z,scl_write_buf_ret ;�� �㤥� ��뢠�� ����� �᫨ �� �㦭�
	ld hl,scl_write_buf_ret ;���� ������
	push hl
	ld hl,(scl_parse_ret_adr) ;���� ��� �த������� �᭮����� 横�� ᡮન
	jp (hl) ;�⤠��� ����� 256 ���� ������
scl_write_buf_ret
	ld hl,(scl_temp_hl2)
	pop bc
	djnz scl_write_buf

	ret
	
	
	
scl_parse ;ࠧ��� ��ࠧ� scl � trd, �᭮���� 横�
	;������� ���� ᥪ��
;����� ���樨 ������ �� 256 ����
	ld (scl_temp_hl),hl
	ld (scl_temp_de),de
	ld (scl_temp_bc),bc
	ld a,1
	ld (scl_que),a ;����稬 䫠� �� �㦭� �����
	ld hl,scl_parse_ret ;��࠭�� ���� ������
	ld (scl_parse_ret_adr),hl
	ret ;������ ��� �������� ������
scl_parse_ret	
	xor a
	ld (scl_que),a
	ld hl,(scl_temp_hl)
	ld de,(scl_temp_de)
	ld bc,(scl_temp_bc)
	
	ld de,scl_buf ;�஢�ઠ ��⪨ ��ࠧ�
	ld hl,scl_sign
	ld b,8
scl_parse_chk
	ld a,(de)
	cp (hl)
	jr nz,scl_parse_chk_no
	inc hl
	inc de
	djnz scl_parse_chk
	jr scl_parse_chk_ok
scl_parse_chk_no ;�᫨ �� ᮢ����, ����� ���宩 ��ࠧ
    ld hl, scl_err
    call DialogBox.msgBox ;�।�०�����
	xor a
	ld (scl_que),a ;�몫�稬 䫠� �� �㦭� �����
	ld a,4 ;���஥� 䠩�
	call fclose
	ret
scl_parse_chk_ok ;ᨣ����� �ࠢ��쭠�

;�ନ஢���� ��⠫���
	ld a,(scl_buf+8)
	ld (scl_files),a ;�ᥣ� 䠩���
	ld (scl_cat_cycl),a ;横�
	ld hl,scl_buf+9 ;���� ��ࢮ�� ���������
	ld de,cat_buf ;���� �ନ�㥬��� ��⠫��� trd
scl_parse_cat2	
	ld b,14 ;14 ���� ���� ������
scl_parse_cat	
	ld a,(hl)
	ld (de),a
	inc de
	inc l ;���� 㢥��稢��� ⮫쪮 � �।���� ����襣� ॣ����
	jr nz,scl_parse_cat1
	;��� ��� ������� ᫥���騩 ᥪ��
;����� ���樨 ������ �� 256 ����
	ld (scl_temp_hl),hl
	ld (scl_temp_de),de
	ld (scl_temp_bc),bc
	ld a,1
	ld (scl_que),a ;����稬 䫠� �� �㦭� �����
	ld hl,scl_parse_ret1 ;��࠭�� ���� ������
	ld (scl_parse_ret_adr),hl
	ret ;������ ��� �������� ������
scl_parse_ret1
	xor a
	ld (scl_que),a
	ld hl,(scl_temp_hl)
	ld de,(scl_temp_de)
	ld bc,(scl_temp_bc)
	
scl_parse_cat1
	djnz scl_parse_cat
	inc de
	inc de
	ld a,(scl_cat_cycl)
	dec a
	ld (scl_cat_cycl),a
	jr nz,scl_parse_cat2
	
	ld (scl_temp_hl),hl ;��������� ��� ��⠭�������
	
;������� ᥪ�஢ � ��஦��
	push ix
	ld a,(scl_files)
	ld de,#0100 ;����� � ��ࢮ� ��஦��
	ld ix,cat_buf
	ld (ix+14),e
	ld (ix+15),d
	ld hl,0 ;��饥 ������⢮ ᥪ�஢
scl_cacl
	ld (scl_cat_cycl),a ;横�
	ld a,(ix+13) ;����� 䠩�� � ᥪ���
	ld c,a
	ld b,0
	add hl,bc ;ᥪ�஢
	
	ld bc,16
	add ix,bc
	ld b,a
	call calc_next_pos
	ld a,(scl_cat_cycl)
	cp 1
	jr z,scl_cacl2 ;� ��᫥���� ࠧ �ய�ᨬ
	ld (ix+14),e 
	ld (ix+15),d
scl_cacl2
	dec a
	jr nz,scl_cacl
	;⥯��� 㧭��� ���� ᢮����� ᥪ��
	ld a,(ix+13) ;����� 䠩�� � ᥪ���
	ld c,a
	ld b,0
	add hl,bc
	; ld b,a
	; call calc_next_pos
	ld (cat_buf+8*256+#e1),de ;���� ᢮����� ᥪ�� � ��஦�� �� ��᪥�
	ld de,16*159
	ex de,hl
	and a
	sbc hl,de
	ld (cat_buf+8*256+#e5),hl ;��᫮ ᢮������ ᥪ�஢ �� ��᪥
	pop ix


	
;������ ᮤ�ন���� 䠩���
	ld a,(scl_files) ;�ᥣ� 䠩���
	ld (scl_cat_cycl),a ;横�
	ld hl,cat_buf+13 ;���� ࠧ��� ᥪ�஢ 䠩��
	ld (cat_cur_adr),hl

	ld hl,#0100 ;��稭�� � ��ࢮ� ��஦��
	ld (#5cf4),hl
scl_parse_file2	
	ld hl,(scl_temp_hl) ;���� ������
	ld de,(cat_cur_adr) ;���� ᥪ�� ��஦�� 䠩��
	;dec de
	ld a,(de) ;������⢮ ᥪ�஢, 横�
	ld c,a
scl_parse_file3
	ld de,scl_buf2 ;���� ��� ������ ����
	ld b,0 ;256 ���� ���� ᥪ��, 横�
scl_parse_file	
	ld a,(hl)
	ld (de),a
	inc de
	inc l ;���� 㢥��稢��� ⮫쪮 � �।���� ����襣� ॣ����
	jr nz,scl_parse_file1
	;��� ��� ������� ᫥���騩 ᥪ��
;����� ���樨 ������ �� 256 ����
	ld (scl_temp_hl),hl
	ld (scl_temp_de),de
	ld (scl_temp_bc),bc
	ld a,1
	ld (scl_que),a ;����稬 䫠� �� �㦭� �����
	ld hl,scl_parse_ret2 ;��࠭�� ���� ������
	ld (scl_parse_ret_adr),hl
	ret ;������ ��� �������� ������
scl_parse_ret2
	xor a
	ld (scl_que),a
	ld hl,(scl_temp_hl)
	ld de,(scl_temp_de)
	ld bc,(scl_temp_bc)
	
scl_parse_file1
	djnz scl_parse_file
	ld (scl_temp_hl),hl	
	ld (scl_temp_bc),bc
	
	ld hl,scl_buf2 ;;����襬 ���� ᥪ��
	ld  de,(#5cf4)
    ld      bc,#0106 ;
    call    call3d13	
	; ld a,c
	; cp 255
	; jp z,fwrite_no_chek ;��室 �᫨ �訡��	
	ld hl,(scl_temp_hl)
	ld bc,(scl_temp_bc)
	
	dec c
	jr nz,scl_parse_file3
	
	ld hl,(cat_cur_adr) ;���� ᥪ�� ��஦�� 䠩��
	; ld e,(hl)
	; inc hl
	; ld d,(hl)
	ld bc,16
	add hl,bc ;�� ᫥���騩 䠩�
	ld (cat_cur_adr),hl	
	
	
	ld a,(scl_cat_cycl)
	dec a
	ld (scl_cat_cycl),a
	jr nz,scl_parse_file2	;�� ᫥���騩 䠩�
	
	

;�ନ஢���� ��⥬���� ᥪ�� �9 (8)
	;
	;ld (cat_buf+8*256+#e1),a ;// #E1 ���� ᢮����� ᥪ�� �� ��᪥�
	;
	;ld (cat_buf+8*256+#e2),a ;// #E2 ���� ᢮����� �४
	ld a,#16
	ld (cat_buf+8*256+#e3),a ;// #E3 16 80 ��஦��, 2 ��஭�
	ld a,(scl_files)
	ld (cat_buf+8*256+#e4),a ;// #E4 ��饥 ������⢮ 䠩��� ����ᠭ��� �� ���
	;
	;ld (cat_buf+8*256+#e5),a ;// #�5,�6 ��᫮ ᢮������ ᥪ�஢ �� ��᪥
	;ld (cat_buf+8*256+#e6),a
	ld a,#10
	ld (cat_buf+8*256+#e7),a ;// #E7 ���  #10,��।����騩 �ਭ���������� � TR-DOS	

	ld hl,f_name ;����襬 ��� ��᪠, ��� ��� �⮣� ��� 䠩��
	ld de,cat_buf+8*256+#f5 ;// #F5-#FC ��� ��᪠ � ASCII �ଠ�
	ld bc,8
	ldir
	
	ld hl,cat_buf ;����襬 ��⠫�� �� ���
	ld de,0
    ld      bc,#0906 ;
    call    call3d13	
	; ld a,c
	; cp 255
	; jp z,fwrite_no_chek ;��室 �᫨ �訡��	
	ret


;-----------scl end --------------------









    
; A - file stream id
; fsync:
;     esxCall ESX_FSYNC
    ; ret


; HL - name (name.ext)
; Returns:
; HL - name (name    e)	
format_name ;�������� ��� 䠩�� ��� �⠭���� trdos (8+1)

	;᭠砫� ���஡㥬 ���� �� ��� ��������, �᫨ ��� ����
	ld (temp_hl),hl ;��࠭�� ���� ��室���� �����
	ld b,#00 ;�� ����� 255 ᨬ�����	
format_name5	
	ld a,(hl)
	cp "/" ;�᫨ ���� ��������
	jr z,format_name_path_yep
	ld a,(hl)
	cp "." ;�᫨ ��� �� ��諨 �� ���७��
	jr nz,format_name6
	ld hl,(temp_hl) ;�᫨ ��諨 �� ���७��, � ��⥩ ���, ������ �� ��砫� �����
	jr format_name_7 ;�� ��室
format_name6
	inc hl
	djnz format_name5
	
format_name_path_yep ;��諨
	inc hl ;�ய��⨬ ���� "/"
	
format_name_7	

	push hl ;���⨬ ���� ��� ������ �����
	ld hl,f_name
	ld de,f_name+1
	ld (hl)," "
	ld bc,8+1
	ldir
	ld (hl),0
	ld bc,16-8-1-1
	ldir
	pop hl

	ld bc,#09ff ;����� ����� 9 ᨬ�����
	ld de,f_name ;�㤠
format_name2	
	ld a,(hl)
	cp "."
	jr nz,format_name1
	ld de,f_name+8
	inc hl
	ldi ; � � ���� ���७�� 3 �㪢�
	ldi
	ldi
	;ex de,hl ;��࠭�� ���� ��室���� ���७��
	jr format_name_e
format_name1
	ldi
	djnz format_name2
	
	;�᫨ ��� �������, �ய��⨬ ��譥� �� ���७��
	ld b,#00 ;�� ����� 255 ᨬ�����	
format_name3	
	ld a,(hl)
	cp "."
	jr nz,format_name4
	ld de,f_name+8
	inc hl
	ldi ; � � ���� ���७�� 3 �㪢�
	ldi
	ldi
	;ex de,hl ;��࠭�� ���� ��室���� ���७��
	jr format_name_e
format_name4
	inc hl
	djnz format_name3
	
format_name_e ;��室
	ld hl,f_name ;���� १����
	ret

; DE - trk/sec
; B - sectors step
; Returns:
; DE - trk/sec	
calc_next_pos		;����� �� N ᥪ�஢	
			;ld b,4 
			;ld  de,(#5ceb) 
calc_next_pos2		
			inc e
			ld a,e
			cp 16
			jr c,calc_next_pos1
			inc d
			ld e,0
calc_next_pos1
			;ld (#5ceb),de
			djnz calc_next_pos2
			ret
			

;testt db "123.trd"
write_ima db "Select disk "
write_ima_d db "A: (A-D). "
		db "All data may be lost! Press Y or N.",0
;prev_drive db 0 ;�।��騩 ����� ��᪮����
		
trdExt1 db ".trd", 0
trdExt2 db ".TRD", 0

sclExt1 db ".scl", 0
sclExt2 db ".SCL", 0

f_name ds 16 ;��� 䠩��
f_r_cur_trk dw 	 0 ;⥪�騥 ᥪ��-��஦�� 䠩�� �� �⥭��
f_r_len_sec db 0 ;����� 䠩�� �� �⥭�� � ᥪ���
f_r_len dw 0;����� 䠩�� � �����
f_r_flag db 0 ;䫠� �� ����� 䠩� �� �⥭��

f_w_cur_trk dw 	 0 ;⥪�騥 ᥪ��-��஦�� 䠩�� �� ������
f_w_len_sec db 0 ;����� 䠩�� �� ������ � ᥪ���
f_w_flag db 0 ;䫠� �� ����� 䠩� �� ������
f_w_len ds 4 ;����� ����ᠭ��� ������
write_end_flag db 0 ;䫠� �� �㦭� ������� ���⮪

temp_bc dw 0 ;�࠭���� ॣ���� 
temp_hl dw 0 ;�࠭���� ॣ���� 
temp_hl2 dw 0 ;�࠭���� ॣ���� 

sec_shift db 0 ;㪠��⥫� �� ����� ���� ��⠭������ ������
sec_shift2 db 0 ;㪠��⥫� �� ����� ���� ��⠭������ ������ (���⮪)
sec_part db 0 ;᪮�쪮 ᥪ�஢ �� ��ன ���樨 ��� �����
sec_shift_flag db 0 ;䫠� �� ���� ᥪ�� �� ��������

;ᥪ�� scl
scl_sign db "SINCLAIR" ;��⪠
scl_que db 0 ;䫠� ����� ���樨 ������
scl_err db "SCL image error!",0
scl_parse_ret_adr dw 0; ���� ������ � 横�
scl_cat_cycl db 0 ;��६����� 横��
scl_files db 0 ;�ᥣ� 䠩���
scl_temp_hl dw 0;;�࠭���� ॣ����
scl_temp_hl2 dw 0;
scl_temp_de dw 0;
scl_temp_bc dw 0;
cat_cur_adr dw 0;
;scl end

;ᥪ�� ��࠭���� ��� 䠩��
file_err db "Not enough space!",0
sec_cat db 0 ;ᥪ�� ��⠫���
file_num db "0" ;����� ��� ��� ������ 䠩���

	;�� ����� #4000 ����
cat_buf equ #4800 ;���� ��� ���⮣� ��᪠ 9*256
sec_buf equ cat_buf + 9*256 ;���� ᥪ�� ��� ����� 256
scl_buf equ sec_buf + 512 ;�஬������ ���� 256
scl_buf2 equ scl_buf + 512 ;�஬������ ���� 256

    ENDMODULE