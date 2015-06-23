// test ruzne typy ukazatelu

int pole[] = {100,200,300,400};
char text[] = "Pepa";
int nepole = 6;
volatile int *vgptr;
int *gptr;


char fun( volatile char *a, int b, char c, char *d)
{
	volatile char val = 0;
	char t1 = *d;
	
	val = val * c;
	b = pole[3] & pole[1];
	text[2] = 'R';
	*d = text[3];
	return t1 + b + nepole;
}

void main()
{
	volatile char a = 10;
	volatile char b = 20;
	char c = 30;
	gptr = &nepole;
	vgptr = &nepole;
	pole[1] = 150;
	pole[0] = *gptr;
	*vgptr = 18;
	fun(&a,555,c, &c);
	nepole = c;

}
