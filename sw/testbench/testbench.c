/* THIS IS THE OFFICIAL MB-LITE TESTBENCH */

/* This file should be modified with care. It is designed
   against the design in the directory mblite/design/core. */

/* Code coverage was measure by using modelsim coverage tools.
   All statements have been executed at least once. The
   correct console output is listed in the file
   result.txt. */

#include "stdio.h"
#include <stdio.h>
#include <malloc.h>
#include <math.h>

#include "dhry.h"

int interrupt = 1;

void test_passed()
{
    xil_printf("OK!\n\n");
}

void test_failed()
{
    xil_printf("FAILED!\n\n");
}

void __attribute__ ((interrupt_handler)) interruptHandler()
{
    xil_printf("Handling interrupt routine\n");
    interrupt = 0;
}

int fib1(int n)
{
    /* WARNING! Using n > 10 requires huge stack and might cause problems! */

    switch (n) {
        case 0:
            return 0;
        case 1:
            return 1;
        default:
            return fib1(n-1) + fib1(n-2);
    }
}

int fib2(int n)
{
    int a[3];
    int *p=a;
    int i;

    for(i=0; i<=n; ++i)
    {
        if(i<2)
            *p=i;
        else
        {
            if(p==a)
                *p=*(a+1)+*(a+2);
            else if(p==a+1)
                *p=*a+*(a+2);
            else
                *p=*a+*(a+1);
        }
        if(++p>a+2)
            p=a;
    }

    return p==a?*(p+2):*(p-1);
}

int gcd(int a, int b)
{
    if (b > a)
        goto b_larger;
    while (1)
    {
        a = a % b;
        if (a == 0) return b;
    b_larger:
        b = b % a;
        if (b == 0) return a;
    }
}

int memoryTest(int size)
{
    volatile void *alloc;
    int magic;

    alloc = malloc(size * sizeof(int)); /* allocate 32 byte */
    if (alloc == NULL)
        return 0;

    *(int *)alloc = 577; /* write to memory */
    magic = *(int *)alloc; /* read from memory */

    return magic;
}

int uncommonInstructions()
{
    int mtb = 1234567;
    int a = 1;
    int b = 4;

    /* jump to PC + mtb if a == 1; */
    __asm__ volatile ("beq %0, %1;"::"r"(a),"r"(mtb));

    mtb = 241;

    __asm__ volatile ("bsra %0, %1, %2":"=r"(mtb):"r"(mtb), "r"(b));
    if(mtb != 15)
    {
        return 1;
    }
    __asm__ volatile ("andn %0, %1, %2":"=r"(mtb):"r"(mtb), "r"(a));
    if(mtb != 14)
    {
        return 2;
    }
    mtb = 241;
    __asm__ volatile ("andni %0, %1, 192":"=r"(mtb):"r"(mtb));
    if(mtb != 49)
    {
        return 3;
    }
    mtb = 241;
    __asm__ volatile ("muli %0, %1, 241":"=r"(mtb):"r"(mtb));
    if(mtb != 58081)
    {
        return 4;
    }
    __asm__ volatile ("src %0, %1;":"=r"(mtb):"r"(mtb));
    if(mtb != 29040)
    {
        return 5;
    }
    return 0;
}

int main()
{

    int a, b;
    float f;

    xil_printf("Welcome to the MB-Lite Testbench\n\n");
    xil_printf("1. Testing Interrupt...\n");
    while(interrupt){}
    test_passed();

    xil_printf("2. Testing Integer Arithmetic\n");
    a = fib1(8);
    b = fib2(8);
    if(a == b && gcd(1365180540, 1540383426) == 6)
    {
         test_passed();
    }
    else
    {
         test_failed();
         return 0;
    }

    xil_printf("3. Testing memory allocation\n");
    if(memoryTest(1) == 577)
    {
         test_passed();
    }
    else
    {
         test_failed();
         return 0;
    }
    
    xil_printf("4. Testing Floating Point Arithmetic\n");
    f = sqrt(2.0);
    if(f < 1.41421354 && f > 1.41421353)
    {
         test_passed();
    }
    else
    {
         test_failed();
         return 0;
    }

    xil_printf("5. Testing uncommon instructions\n");
    a = uncommonInstructions();
    if(a == 0)
    {
         test_passed();
    }
    else
    {
        xil_printf("%d\n", a);
        test_failed();
        return 0;
    }

    xil_printf("6. Executing dhrystone benchmark\n");
    a = dhry();
    if(a == 0)
    {
         test_passed();
    }
    else
    {
         test_failed();
         return 0;
    }

    xil_printf("The testbench is now finished.\n");
    return 0;
}
