/*#include <stdio.h>*/

#define LIMIT 1500000 /*size of integers array*/
#define PRIMES 100000 /*size of primes array*/

nocall my_org() {
	asm {
		org	0x100800200
		db	"BOOT"
		jmp	crt_start
		.align 8
sp_save:
		dw	0
	}
}

int main(){
    int i,j,numbers[LIMIT];
    int primes[PRIMES];
	int limit;
	int start_tick,end_tick;

	asm {
		lw		r1,#0xAB
		outb	r1,0xdc0600
	}
	start_tick = get_tick();
	asm {
		lw		r1,#0xAC
		outb	r1,0xdc0600
	}
	printf("Start tick %d\r\n", start_tick);
	asm {
		lw		r1,#0xAD
		outb	r1,0xdc0600
	}

	limit=LIMIT;

    /*fill the array with natural numbers*/
	for (i=0;i<limit;i++){
		numbers[i]=i+2;
	}

    /*sieve the non-primes*/
    for (i=0;i<limit;i++){
        if (numbers[i]!=-1){
            for (j=2*numbers[i]-2;j<limit;j+=numbers[i])
                numbers[j]=-1;
        }
    }

    /*transfer the primes to their own array*/
    j = 0;
    for (i=0;i<limit&&j<PRIMES;i++)
        if (numbers[i]!=-1)
            primes[j++] = numbers[i];

	end_tick = get_tick();
	printf("Clock ticks %d\r\n", end_tick-start_tick);

    /*print*/
    for (i=0;i<PRIMES;i++)
        printf("%d\n",primes[i]);

return 0;
}

int printf(char *p)
{
	int *q;
	asm {
		lw		r1,#0xAE
		outb	r1,0xdc0600
	}
	q = &p;

	for (; *p; p++) {
		if (*p=='%') {
			p++;
			switch(*p) {
			case '%':
				putch('%');
				break;
			case 'c':
				q++;
				putch(*q);
				break;
			case 'd':
				q++;
				putnum(*q);
				break;
			case 's':
				q++;
				putstr(*q);
				break;
			}
		}
		else
			putch(*p);
	}
}

void putch(char ch)
{
	asm {
		lw		r1,#0xAF
		outb	r1,0xdc0600
	}
	asm {
		lw		r1,#0x0a
		lw		r2,24[bp]
		lw		r3,#1
		syscall	#410
	}
	asm {
		lw		r1,#0xB0
		outb	r1,0xdc0600
	}
}

void putnum(int num)
{
	asm {
		lw		r1,#0xB1
		outb	r1,0xdc0600
	}
	asm {
		lw		r1,#0x15
		lw		r2,24[bp]
		lw		r3,#5
		syscall	#410
	}
	asm {
		lw		r1,#0xB2
		outb	r1,0xdc0600
	}
}

void putstr(char *p)
{
	asm {
		lw		r1,#0x14
		lw		r2,24[bp]
		syscall	#410
	}
}

int get_tick()
{
	asm {
		lw		r1,#0
		syscall	#416
	}
}

void crt_start()
{
	asm {
		lw		r1,#0xAA
		outb	r1,0xdc0600
		sw		sp,sp_save
		lw		sp,#0x1_07FFFFF8
		lea		xlr,prog_abort
		call	main
		lw		sp,sp_save
		bra		retcode
prog_abort:
	}
	putstr("Program aborted abnormally.");
	asm {
		lw	sp,sp_save
retcode:
	}
}
