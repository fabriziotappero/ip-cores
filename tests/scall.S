# The Potato Processor - A simple RISC-V based processor for FPGAs
# (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
# Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

#include "riscv_test.h"
#include "test_macros.h"

.section .text
RVTEST_RV32U
RVTEST_CODE_BEGIN

test_1:
	la x1, handle_exception
	csrw evec, x1

	li TESTNUM, 1
	scall

	j fail
	j pass

TEST_PASSFAIL

RVTEST_CODE_END

test_failed:
	RVTEST_FAIL

# Exception handlers:
handle_exception:
	li x1, 6 # Cause value for syscall exceptions
	csrr x2, cause
	bne x1, x2, test_failed

	csrr x1, epc
	addi x1, x1, 8
	csrw epc, x1
	sret

