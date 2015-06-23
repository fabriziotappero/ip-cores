struct s {
 int a;
 char b;
} struktura;

int sum(char nnn1, short n2, int n3)
{
	return (int)nnn1 + n2 + n3;
}

void main()
{
	char c = 29;
	short d = 57;
	int e = 113;


	if (sum(1, 2, 3) > 5)
	{
		sum(2, 3, c + d);
		return;
	}
	else
	{
		struktura.a = 99;
	}
	struktura.a = 2*e;
	struktura.b = c;
	sum (struktura.b, d, e);
	
}