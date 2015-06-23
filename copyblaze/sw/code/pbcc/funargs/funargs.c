char f(char arg, char arg2)
{
	return arg+arg2;
}


void main()
{
	char i = 0;
	for(; i < 10; i++)
	{ 
		i++;
		f(i, 17);
	}
}
