#include "stdio.h"
/*#include <stdio.h>*/
#include "xil_printf.c"
char str[] = "Hallo, Welt!\r\n";
/*[>char str[] = "1";<]*/
int fib(int n){
    switch (n) {
	case 0:
	    return 0;
	case 1:
	    return 1;
	default:
	    return fib(n-1) + fib(n-2);
    }
}
int main()
{
    char count = 0;
    int f = 0;
    volatile char *led = (char *) 0xffffffb0;
while(1) {
    *led = (char) count;
    count += 1;
    xil_printf2(
		/*"02"*/
	    "0:Hello, world!\r\n"
	    "1:Hello, world!\r\n"
    );
    xil_printf2(str);
    f = fib(15);
    if (f == 610)
	/*xil_printf2("Okey\r\n");*/
	xil_printf2("0x%x\r\n", f);
    else
	xil_printf2("Error\r\n");
    xil_printf2(str);
}
    return 0;
}
