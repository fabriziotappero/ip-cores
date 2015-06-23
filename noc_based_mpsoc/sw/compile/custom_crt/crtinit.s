###################################-*-asm*- 
# 
# Copyright (c) 2001 Xilinx, Inc.  All rights reserved. 
# 
# Xilinx, Inc.  
#
# XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A 
# COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
# ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR 
# STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
# IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE 
# FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.  
# XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO 
# THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO 
# ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE 
# FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY 
# AND FITNESS FOR A PARTICULAR PURPOSE.
# 
# crtinit.s 
#
# Default second stage of C run-time initialization
#    
# $Id: crtinit.s,v 1.5.2.7 2006/07/05 18:53:54 vasanth Exp $
# 
#######################################

	.globl _crtinit
	.align 2
	.ent _crtinit

_crtinit:
	addi	r1, r1, -20               	/* Save Link register	 */
	swi	r15, r1, 0

    	addi	r6, r0, __sbss_start          	/* clear SBSS */
	addi	r7, r0, __sbss_end	
	rsub	r18, r6, r7		
	blei	r18, .Lendsbss

.Lloopsbss:	
	swi	r0, r6, 0
	addi	r6, r6, 4
	rsub	r18, r6, r7
	bgti	r18, .Lloopsbss
.Lendsbss:

	addi	r6, r0, __bss_start             /* clear BSS */
	addi	r7, r0, __bss_end		
    	rsub	r18, r6, r7		
	blei	r18, .Lendbss
.Lloopbss:	
	swi	r0, r6, 0
	addi	r6, r6, 4
	rsub	r18, r6, r7
	bgti	r18, .Lloopbss
.Lendbss:

	brlid	r15, _program_init              /* Initialize the program  */
	nop

#        brlid   r15, __init                     /* Invoke language initialization functions */
#        nop
    
	addi	r6, r0, 0                       /* Initialize argc = 1 and argv = NULL and envp = NULL  */
	addi	r7, r0, 0			
      	brlid	r15, main                       /* Execute the program */
    	addi	r5, r0, 0

        addik   r19, r3, 0                      /* Save return value */
    
#        brlid   r15, __fini                     /* Invoke language cleanup functions */
#        nop
    
	brlid	r15, _program_clean             /* Cleanup the program  */
	nop

	lw	r15, r1, r0                     /* Return back to CRT   */

        addik   r3, r19, 0                      /* Restore return value */
	rtsd	r15, 8
    	addi	r1, r1, 20
	.end _crtinit

