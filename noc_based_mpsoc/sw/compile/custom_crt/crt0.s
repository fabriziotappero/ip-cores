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
# crt0.s 
# 
# Default C run-time initialization for MicroBlaze standalone 
# executables (compiled with -xl-mode-executable or no switches)
#    
# $Id: crt0.s,v 1.7.2.6 2005/11/15 23:32:53 salindac Exp $
# 
#######################################

/*
        
        MicroBlaze Vector Map for standalone executables

         Address                Vector type                 Label
         -------                -----------                 ------    

    	# 0x00 #		(-- IMM --)
	# 0x04 #                Reset                       _start1
    
	# 0x08 #		(-- IMM --)
	# 0x0c #		Software Exception          _exception_handler
    
	# 0x10 #		(-- IMM --)
	# 0x14 #		Hardware Interrupt          _interrupt_handler
    
        # 0x18 #                (-- IMM --)
        # 0x1C #                Breakpoint Exception        (-- Don't Care --)
    
        # 0x20 #                (-- IMM --) 
        # 0x24 #                Hardware Exception          _hw_exception_handler

*/      
    

	.globl _start
        .section .vectors.reset, "ax"
	.align 2
_start:
        brai    _start1

        .section .vectors.sw_exception, "ax"
        .align 2
_vector_sw_exception:       
        brai    _exception_handler

        .section .vectors.interrupt, "ax"
        .align 2
_vector_interrupt:      
        brai    _interrupt_handler

        .section .vectors.hw_exception, "ax"
        .align 2
_vector_hw_exception:       
        brai    _hw_exception_handler

        .section .text
        .globl _start1
        .align 2
_start1:
	la	r13, r0, _SDA_BASE_         /* Set the Small Data Anchors and the stack pointer */
	la	r2, r0, _SDA2_BASE_
	la	r1, r0, _stack-16           /* 16 bytes (4 words are needed by crtinit for args and link reg */

	brlid	r15, _crtinit               /* Initialize BSS and run program */
	nop

        brlid   r15, exit                   /* Call exit with the return value of main */
        addik   r5, r3, 0                   

        /* Control does not reach here */

/* 
        _exit 
        Our simple _exit      
*/    
        .globl _exit
        .align 2
        .ent _exit
_exit:
        bri     0
	.end _exit     
   
