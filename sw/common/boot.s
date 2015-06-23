################################################################################
# Boot Up Code                                                                 #
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
	.globl 	boot
	.ent 	   boot
boot:
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

   .set  noat   
   and   $at, $0, $0             # Clear all registers.
   .set  at
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
	.end 	boot

   
################################################################################
# Start Flash Application                                                      #
#------------------------------------------------------------------------------#	
   .globl   start
	.ent 	   start			
start:
	.set 	noreorder  
   
   lui   $k0, 0x2000
   jr    $k0
   nop
   
	.set 	reorder
	.end 	start
