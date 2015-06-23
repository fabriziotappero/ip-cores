// interrupt handler test for pBlazeIDE

char  __xdata val = 0;
char  __xdata c;

void interruptHandler() __interrupt
{
	val++;		
}

void main()
{
	c = 0;
	__asm
		EINT
	__endasm;

	for (;;) {

		c += 4;
	}
}
