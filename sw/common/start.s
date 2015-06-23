################################################################################
# Start Up Code                                                                #
#------------------------------------------------------------------------------#
# REFERENCES                                                                   #
#                                                                              #
#    [1] The MIPS programmer's handbook                                        #
#        Erin Frquhar and Philip Bunce                                         #
#        San Francisco, CA, Morgan Kaufmann Publishers, 1994                   #
#        ISBN 1-55860-297-6                                                    #
#                                                                              #
#------------------------------------------------------------------------------#
# Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.com>            #
#                                                                              #
# This program is free software: you can redistribute it and/or modify         #
# it under the terms of the GNU General Public License as published by         #
# the Free Software Foundation, either version 3 of the License, or            #
# (at your option) any later version.                                          #
#                                                                              #
# This program is distributed in the hope that it will be useful,              #
# but WITHOUT ANY WARRANTY; without even the implied warranty of               #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                #
# GNU General Public License for more details.                                 #
#                                                                              #
# You should have received a copy of the GNU General Public License            #
# along with this program.  If not, see <http://www.gnu.org/licenses/>.        #
################################################################################

	.ifndef STACKSIZE             # Stack size in byte.
	.set 	STACKSIZE, 8192
	.endif
	
	.comm 	stack, STACKSIZE     # Global memory: stack.

	.text
	.align 	2  
################################################################################
# Execution Start                                                              #
#------------------------------------------------------------------------------#
	.globl 	start
	.ent 	   start
start:
	.set 	noreorder	
   
	la	   $gp, _gp                   # Set global pointer.
	la	   $sp, stack+STACKSIZE-24	   # Set stack pointer.		
   
	la 	$v0, _bss_start         # Global variable region start.
	la 	$v1, _bss_end           # Global variable region end.
      
clrbss:                          # Clear global variable region. 
	sw 	$0, ($v0)
	addiu $v0, 4
	blt	$v0, $v1, clrbss        # Continue execution when .bss region is clear.
	nop

   .set noat
   and   $at, $0, $0             # Clear all registers.
   .set at
   and   $v0, $0, $0
   and   $v1, $0, $0
   and   $a0, $0, $0
   and   $a1, $0, $0
   and   $a2, $0, $0
   and   $a3, $0, $0
   and   $t0, $0, $0
   and   $t1, $0, $0
   and   $t2, $0, $0
   and   $t3, $0, $0
   and   $t4, $0, $0
   and   $t5, $0, $0
   and   $t6, $0, $0
   and   $t7, $0, $0
   and   $s0, $0, $0
   and   $s1, $0, $0
   and   $s2, $0, $0
   and   $s3, $0, $0
   and   $s4, $0, $0
   and   $s5, $0, $0
   and   $s6, $0, $0
   and   $s7, $0, $0
   and   $t8, $0, $0
   and   $t9, $0, $0
   and   $k0, $0, $0
   and   $k1, $0, $0
   and   $fp, $0, $0
   and   $ra, $0, $0
   
	jal	main                    # Start execution of the C main procedure.
	nop   
   
loop:                            # Final loop. Afer returning from C main loop.
   nop
	j	loop                       # Real Infinity.
	nop
   nop
   
	.set 	reorder
	.end 	start
 
 
################################################################################
# Interrupt Start                                                              #
#------------------------------------------------------------------------------#	
	.ent 	intr_handler			
intr_handler:
	.set 	noreorder
	.set  noat

# If we do not include the Interrupt API, simply return to normal execution
# immediately.
.ifdef _INTERRUPT 
 
	addiu	$sp, $sp, -72	         # Allocate space for all relevant registers.				
	sw	   $at,  4($sp)            # Save all registers, that are used directily
	sw	   $v0,  8($sp)            # after a successful execution of the interrupt
	sw	   $v1, 12($sp)            # service routines.
	sw	   $a0, 16($sp)            # Registers $s0 - $s8 do not need to be saved,
	sw	   $a1, 20($sp)            # since the compiler stores them if they are
	sw	   $a2, 24($sp)            # used in a procedure.
	sw	   $a3, 28($sp)            # $gp is the same for the entire source code.
	sw	   $t0, 32($sp)            # Registers $k0 and $k1 are reserved for ASM
	sw	   $t1, 36($sp)            # routines. The C compiler does not use them.
	sw	   $t2, 40($sp)
	sw	   $t3, 44($sp)
	sw	   $t4, 48($sp)
	sw	   $t5, 52($sp)
	sw	   $t6, 56($sp)
	sw	   $t7, 60($sp)
	sw	   $t8, 64($sp)
	sw	   $t9, 68($sp)
	sw	   $ra, 72($sp)

	mfc0	$k0, $13		            # Retrieve CAUSE (Pending Interrupts).
	nop	
	mfc0  $k1, $12		            # Retrieve SR (Interrupt mask and global IE).
	nop
	and	$k0, $k0, $k1	         # Get legal pending interrupts.	

   addiu	$sp, $sp, -24           # Allocate minimal procedure context.
	jal	intr_dispatch           # Jump to C interrupt dispatch routine.  
   srl	$a0, $k0, 8	            # a0 <- legal pending interrupts.
   addiu	$sp, $sp, 24	         # Deallocate minimal procedure context. 
   
	lw	   $at,  4($sp)            # Restore saved registers.
	lw	   $v0,  8($sp)
	lw	   $v1, 12($sp)
	lw	   $a0, 16($sp)
	lw	   $a1, 20($sp)
	lw	   $a2, 24($sp)
	lw	   $a3, 28($sp)
	lw	   $t0, 32($sp)
	lw	   $t1, 36($sp)
	lw	   $t2, 40($sp)
	lw	   $t3, 44($sp)
	lw	   $t4, 48($sp)
	lw	   $t5, 52($sp)
	lw	   $t6, 56($sp)
	lw	   $t7, 60($sp)
	lw	   $t8, 64($sp)
	lw	   $t9, 68($sp)
	lw	   $ra, 72($sp)	   		
	addiu	$sp, $sp, 72   	      # Undo stack allocation.  
   
.endif
	
	mfc0	$k1, $14		            # Retrieve EPC.  
	nop	   	   	   	   	   	   	   	   	
	jr	   $k1                     # Return to normal execution.
	rfe  			                  # Restore from exception. Pop IE stack.
 
   .set  at
	.set 	reorder
	.end 	intr_handler

   
################################################################################
# Return to Bootloader                                                         #
#------------------------------------------------------------------------------#	
   .globl   boot
	.ent 	   boot			
boot:
	.set 	noreorder  
   
   jr    $0
   nop
   
	.set 	reorder
	.end 	boot
