    MODULE Uart
init:
;���樠�����㥬 ����
		di
		ld	bc,#55FE	;55FEh
		in	a,(c)		;���室 � ०�� �������
		ld	b,0xc3		;������� - ��⠭����� ᪮���� ����
		in	a,(c)
		ld	b,3			;��ࠬ��� - ��⠭����� ᪮���� ���� 19200(6) 38400(3) 115200(1) 57600(2) 9600(12) 14400(8)
		in	a,(c)
		ei
		ret
read:
		di
read2:
		ld	bc,#55FE	;55FEh
		in	a,(c)		;���室 � ०�� �������
		ld	b,0xc2		;������� - �⥭�� ���稪� ���� �ਥ��
		in	a,(c)		;����稫� �᫮ ���� � ����
		or a
		jp nz,togetb	; � ���� ���� ����
		call startrts2	; � ���� ��� ����, �ਯ������� �� ᥪ㭤��� RTS
		jp read2		; � ⥯��� ����?

togetb:		
		ld	bc,#55FE	;������ ������� ����஫���� ����������
		in	a,(c)		;���室 � ०�� �������
		ld	b,#02		;������� - �⥭�� 
		in	a,(c)		;����砥� ���� � �
		ei
		ret	

write: 
		di
		push bc
		push de		

		ld  d, a		;� � ����砥� ����, �࠭塞 ��� � D
readytx:
		ld	bc,#55FE	;55FEh
		in	a,(c)		;���室 � ०�� �������
		ld	b,#42		;������� - ������ �����
		in	a,(c)
		bit	 6,a		;��ࠬ���� - TX 
		jp z,readytx	; �������� �᫨ ���� ���

		ld	bc,#55FE	;55FEh
		in	a,(c)		;���室 � ०�� �������
		ld	b,#03		;������
		in	a,(c)
		ld	b,d			;���� ��� ����뫪�
		in	a,(c)		; ->
		pop de
		pop bc
		ei		
		ret

startrts2
		ld	bc,#55FE	;55FEh
		in	a,(c)		;���室 � ०�� �������
		ld	b,#43		;������� - ��⠭����� �����
		IN	a,(c)
		ld	b,#03		;��ࠬ���� - ���� RTS (START)
		in	a,(c)
		ld  b,10
loop
		djnz loop
		ld	bc,#55FE	;55FEh
		in	a,(c)		;���室 � ०�� �������
		ld	b,#43		;������� - ��⠭����� �����
		in	a,(c)
		ld	b,0			;��ࠬ���� - ��⠭����� RTS (STOP)
		in	a,(c)
		ret

    ENDMODULE
