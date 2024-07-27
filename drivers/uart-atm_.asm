    MODULE Uart

init:
;���樠�����㥬 ����
		di
		ld	bc,#55FE	;55FEh
		in	a,(c)		;���室 � ०�� �������
		ld	b,#C3		;������� - ��⠭����� ᪮���� ����
		in	a,(c)
		ld	b,3			;��ࠬ��� - ��⠭����� ᪮���� ���� 19200(6) 38400(3) 115200(1) 57600(2) 9600(12) 14400(8)
		in	a,(c)
		ei
		ret
read:
		di
		ld	bc,#55FE	;55FEh
		in	a,(c)		;���室 � ०�� �������
		ld	b,0x42		;������� - �⥭�� ॣ���� ����� RS232
		in	a,(c)		;�஢�ਫ� ���ﭨ� �ਥ�����
		rra
		jp nc,read

		ld	bc,#55FE	;55FEh
		in	a,(c)		;���室 � ०�� �������
		ld	b,0xc2		;������� - �⥭�� ���稪� ���� �ਥ��
		in	a,(c)		;�஢�ਫ� ���ﭨ� �ਥ����� ;����稫� �᫮ ���� � ����
		or a
		jp nz,togetb	; � ���� ���� ����
		call startrts2	; � ���� ��� ����, �ਯ������� �� ᥪ㭤��� RTS
		jp read			; � ⥯��� ����?

togetb:		
		di
		ld	bc,#55FE	;55FEh
		in	a,(c)		;���室 � ०�� �������
		ld	b,0x42		;������� - �⥭�� ॣ���� ����� RS232
		in	a,(c)		;�஢�ਫ� ���ﭨ� �ਥ����� ;����稫� �᫮ ���� � ����
		rra
		jp nc,togetb

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
		di
		ld	bc,#55FE	;55FEh
		in	a,(c)		;���室 � ०�� �������
		ld	b,#43		;������� - ��⠭����� �����
		IN	a,(c)
		ld	b,#03		;��ࠬ���� - ���� RTS (START)
		in	a, (c)

		ld	bc,#55FE	;55FEh
		in	a,(c)		;���室 � ०�� �������
		ld	b,#43		;������� - ��⠭����� �����
		in	a,(c)
		ld	b,0			;��ࠬ���� - ��⠭����� RTS (STOP)
		in	a,(c)
		ret
dihalt:
	di
	halt
	ENDMODULE
