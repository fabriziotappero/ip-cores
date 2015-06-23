// The Potato Processor Benchmark Applications
// (c) Kristian Klomsten Skordal 2015 <kristian.skordal@wafflemail.net>
// Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

// This file contains startup and initialization code for the Potato benchmark
// applications.

#include "platform.h"
#include "potato.h"

.section .init

.global _start
_start:

// Copies the .data section into the data memory section:
.hidden copy_data
copy_data:
	la x1, __text_end	// Copy source address
	la x2, __data_begin	// Copy destination address
	la x3, __data_end	// Copy destination end address

	beq x2, x3, 2f		// Skip if there is no data to copy

1:
	lw x4, (x1)
	sw x4, (x2)
	addi x1, x1, 4
	addi x2, x2, 4

	bne x2, x3, 1b		// Repeat as long as there is more data to copy
2:

.hidden clear_bss
clear_bss:
	la x1, __bss_begin
	la x2, __bss_end
	beq x1, x2, 2f		// Skip if there is no .bss section

1:
	sw x0, (x1)
	addi x1, x1, 4
	bne x1, x2, 1b

2:

.hidden set_evec
set_evec:
	// Set up an exception handler:
	la x1, exception_handler_wrapper
	csrw evec, x1

.hidden call_main
call_main:
	la sp, __stack_top
	jal main
	csrw tohost, a0
1:
	j 1b

.section .text

.global exception_handler_wrapper
exception_handler_wrapper:
	// Save all registers (even those that are saved by the IRQ handler
	// function, to aid in debugging):
	addi sp, sp, -124
	sw x1, 0(sp)
	sw x2, 4(sp)
	sw x3, 8(sp)
	sw x4, 12(sp)
	sw x5, 16(sp)
	sw x6, 20(sp)
	sw x7, 24(sp)
	sw x8, 28(sp)
	sw x9, 32(sp)
	sw x10, 36(sp)
	sw x11, 40(sp)
	sw x12, 44(sp)
	sw x13, 48(sp)
	sw x14, 52(sp)
	sw x15, 56(sp)
	sw x16, 60(sp)
	sw x17, 64(sp)
	sw x18, 68(sp)
	sw x19, 72(sp)
	sw x20, 76(sp)
	sw x21, 80(sp)
	sw x22, 84(sp)
	sw x23, 88(sp)
	sw x24, 92(sp)
	sw x25, 96(sp)
	sw x26, 100(sp)
	sw x27, 104(sp)
	sw x28, 108(sp)
	sw x29, 112(sp)
	sw x30, 116(sp)
	sw x31, 120(sp)

	csrr a0, cause
	csrr a1, epc
	mv a2, sp
	jal exception_handler

.hidden exception_return
exception_return:
	// Restore all registers:
	lw x1, 0(sp)
	lw x2, 4(sp)
	lw x3, 8(sp)
	lw x4, 12(sp)
	lw x5, 16(sp)
	lw x6, 20(sp)
	lw x7, 24(sp)
	lw x8, 28(sp)
	lw x9, 32(sp)
	lw x10, 36(sp)
	lw x11, 40(sp)
	lw x12, 44(sp)
	lw x13, 48(sp)
	lw x14, 52(sp)
	lw x15, 56(sp)
	lw x16, 60(sp)
	lw x17, 64(sp)
	lw x18, 68(sp)
	lw x19, 72(sp)
	lw x20, 76(sp)
	lw x21, 80(sp)
	lw x22, 84(sp)
	lw x23, 88(sp)
	lw x24, 92(sp)
	lw x25, 96(sp)
	lw x26, 100(sp)
	lw x27, 104(sp)
	lw x28, 108(sp)
	lw x29, 112(sp)
	lw x30, 116(sp)
	lw x31, 120(sp)
	addi sp, sp, 124

	sret

