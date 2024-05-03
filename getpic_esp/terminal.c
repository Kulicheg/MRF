void putdec(int c)
{
  int div;
  int hassent = 0;
  for (div = 100; div > 0; div /= 10) {
    int disp = c / div;
    c %= div;
    if ((disp != 0) || (hassent) || (div == 1)) {
      hassent = 1;
      putchar('0' + disp);
    }
  }
}



void AT(int X, int Y)
{
  putchar(27);
  putchar('[');
  putdec(Y);
  putchar(';');
  putdec(X);
  putchar('H');
}

void ATRIB( int color)
{
  putchar(27);
  putchar('[');
  putdec(color);
  putchar('m');
}



void BOX(unsigned char Xbox, unsigned char Ybox, unsigned char Wbox, unsigned char Hbox, unsigned char Cbox)
{
unsigned char x,y;
  ATRIB(Cbox);
  for (y = 0; y < Hbox;y++)
  {
	  AT (Xbox,Ybox + y);
	  for (x = 0; x < Wbox;x++)
	  {
		putchar(' ');  
	  }
  }
}
