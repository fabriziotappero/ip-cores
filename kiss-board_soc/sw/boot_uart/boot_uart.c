
#include "../boot_flash/syscall.h"

//static int test_int;									// .bss
//static int test_data = 10;								// .data
//static const int test_int_const = 1234;						// .rodata

unsigned long int boot_uart ( long int *syscall(unsigned long int command,...) ){	// .text

	syscall(SYS_SCREEN_PUT_CHAR,'a');
	
	return 0;
}
