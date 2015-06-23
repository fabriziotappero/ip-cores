// test of inserted asm code into C code
int i;

void ihandler() __interrupt (3) __using (7)
{
	_asm
		DISALBE INTERRUPT
	_endasm;
}

int main(int x, int y)
{
_asm
INPUT s0
_endasm;
i = 10;
return i;
}