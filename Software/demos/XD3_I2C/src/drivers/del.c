#include <stdio.h>

int foo(int a, int b)
{
	return (a+b);
}

int foo(int a)
{
	return a*2;
}

int main()
{
	return foo(2);
}

