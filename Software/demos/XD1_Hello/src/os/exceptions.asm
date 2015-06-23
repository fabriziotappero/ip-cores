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

	.text
	.balign	4
	.set	noreorder
	.global	mips32_exception
	.ent	mips32_exception
mips32_exception:
	j	mips32_exception	# Loop forever
	nop
	.end	mips32_exception


