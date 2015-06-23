###############################################################################
# TITLE: Exception Vectors
# AUTHOR: Grant Ayers (ayers@cs.utah.edu)
# DATE: 23 May 2012
# FILENAME: exceptions.asm
# PROJECT: University of Utah XUM Single Core
# DESCRIPTION:
#   Provides the exception vectors which jump to
#   exception-handling routines.
#
###############################################################################


#  Current setup:
#    1. The exception vector begins at address 0x0.
#    2. The interrupt vector begins at address 0x8.
#    3. Each vector has room for 2 instructions (8 bytes) with which
#       it must jump to its demultiplexing routine. The demultiplexing
#       routine calls individual exception-specific handlers.
#    4. The linker script must ensure that this code is placed at the
#       correct address.    


	.text
	.balign	4
	.ent	exception_vector
	.set	noreorder
exception_vector:
	j	mips32_exception
	nop
	.end	exception_vector


	.ent	interrupt_vector
interrupt_vector:
	j	mips32_exception
	nop
	.end	interrupt_vector

