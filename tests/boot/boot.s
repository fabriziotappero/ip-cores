/*
 * Simply RISC S1 Core - Boot code
 *
 * Cutdown version from the original OpenSPARC T1:
 *
 *   $T1_ROOT/verif/diag/assembly/include/hred_reset_handler.s
 *
 * Main changes:
 * - L1 and L2 cache handling are not enabled;
 * - Interrupt Queues handling currently commented out since causes troubles in S1 Core.
 *
 * Sun Microsystems' copyright notices follow:
 */

/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: hred_reset_handler.s
* Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
* DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
* 
* The above named program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License version 2 as published by the Free Software Foundation.
* 
* The above named program is distributed in the hope that it will be 
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
* 
* You should have received a copy of the GNU General Public
* License along with this work; if not, write to the Free Software
* Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
* 
* ========== Copyright Header End ============================================
*/

	/* Base address for Power-On Reser is 0xFFF0000020, adding 8 NOPs to artificially create the 0x20 offset */
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	/* Initialize windowed local, output and input GPRs */
	wrpr %g0, %g0, %cwp 		!! CWP = 0
	wrpr %g0, 0x6, %cansave 	!! CANSAVE = 6
	wrpr %g0, %g0, %canrestore 	!! CANRESTORE = 0
	wrpr %g0, %g0, %otherwin 	!! OTHERWIN = 0
	wrpr %g0, 0x7, %cleanwin 	!! CLEANWIN = 7
	wrpr %g0, 0x7, %wstate 		!! WSTATE = (b)000_111
	add %g0, 0x1, %l1 		!! l1 = 1
	add %g0, 0x1, %o1 		!! o1 = 1
	add %g0, 0x1, %i1 		!! i1 = 1
	add %l1, 0x1, %l2 		!! l1 = 2
	add %o1, 0x1, %o2 		!! o1 = 2
	add %i1, 0x1, %i2 		!! i1 = 2
	add %l2, 0x1, %l3 		!! l1 = 3
	add %o2, 0x1, %o3 		!! o1 = 3
	add %i2, 0x1, %i3 		!! i1 = 3
	nop; nop; nop; nop

	/* Set the LSU Diagnostic Register to enable all ways for L1-icache and L1-dcache and using the "random replacement" algorithm */
	clr %l1 			!! Clear l1
	mov 0x10, %g1
	stxa %l1, [%g1] (66) 		!! LSU_DIAG_REG = b00

	/* Set the LSU Control Register to enable L1-icache and L1-dcache */
!	mov 3, %l1
!	stxa %l1, [%g0] (69)

	/* Set hpstate.red = 0 and hpstate.enb = 1 */
	rdhpr %hpstate, %l1
	wrhpr %l1, 0x820, %hpstate

	/* Clear L1-icache and L1-dcache SFSR */
	mov 0x18, %g1
	stxa %g0, [%g0 + %g1] 0x50	!! IMMU Synchronous Fault Status (SFS) register=0
	stxa %g0, [%g0 + %g1] 0x58	!! DMMU Synchronous Fault Status (SFS) register=0

	/* SPARC Error Enable Reg. */
	!! in file defines.h constant cregs_sparc_error_en_reg_r64:=3
	!! so the effect should be "trap on correctable error" and "trap on uncorrectable error"
	or %g0, 0x3, %l1 		!! l1 = 3
	stxa %l1, [%g0] (75) 		!! SPARC_Error_Enable_reg = 3

	/* Set HTBA: HTBA[63:14] = 0x12 */
	mov 1, %g1 			!! g1 = 1
	sllx %g1, 18, %l1 		!! l1 = 40000
	sllx %g1, 15, %g1 		!! g1 = 8000
	or %l1, %g1, %l1 		!! l1 = 48000
	wrhpr %l1, %g0, %htba 		!! bits 63-14 select Hpriv trap vector

	/**************************************************/
	/* Instructions merged from file hboot_tlb_init.s */
	/**************************************************/

	/* Init all itlb entries */
	mov	0x30, %g1
	mov	%g0, %g2
itlb_init_loop:                  
        stxa	%g0, [%g1] 0x50  	!! IMMU TLB Tag Access register=0
        stxa	%g0, [%g2] 0x55  	!! IMMU TLB Data Access register=0, g2 values from 0x000 to 0x7f8
	add	%g2, 8, %g2    		!! increment the g2 register 8 bytes every time (64 bits)
	cmp	%g2, 0x200 		!! compare g2 with 512 (512*8=4096=0x1000), but max VA=0x7F8
	bne	itlb_init_loop  	!! if (g2!=512) then run another loop
	nop
 
	/* Init all dtlb entries */
        mov	0x30, %g1  
	mov	%g0, %g2
dtlb_init_loop:
        stxa	%g0, [%g1] 0x58  	!! DMMU TLB Tag Access register=0
        stxa	%g0, [%g2] 0x5d  	!! DMMU TLB Data Access register=0, g2 values from 0x000 to 0x7f8
	add	%g2, 8, %g2 		!! increment the g2 register 64 bits each time
	cmp	%g2, 0x200  		!! compare g2 with 512
	bne	dtlb_init_loop 		!! if (g2!=512) then run another loop
	nop
 
	/* Clear itlb/dtlb valid */
	stxa	%g0, [%g0] 0x60		!! ASI_ITLB_INVALIDATE_ALL(IMMU TLB Invalidate register)=0
	mov	0x8, %g1
	stxa	%g0, [%g0 + %g1] 0x60	!! ASI_DTLB_INVALIDATE_ALL(DMMU TLB Invalidate register)=0
 
	/********************************/
	/* End of inserted instructions */
	/********************************/

	/* Initialize primary context register = 0 */
	mov 0x8, %l1
	stxa %g0, [%l1] 0x21
	/* Initialize secondary context register = 0 */
	mov 0x10, %l1
	stxa %g0, [%l1] 0x21

	/* LSU_CTL_REG[3]=1 (DMMU enabled)
	   LSU_CTL_REG[2]=1 (IMMU enabled)
	   LSU_CTL_REG[1]=0 (L1-dcache disabled)
	   LSU_CTL_REG[0]=0 (L1-icache disabled) */
	mov 0xC, %l1 			!! all enabled
	stxa %l1, [%g0] (69)
	
	/* Jump to program in RAM */
	sethi %hi(0), %g1
	sethi %hi(0x40000), %g2 	!! Jump address in RAM
	mov %g1, %g1
	mov %g2, %g2
	sllx %g1, 0x20, %g1
	or %g2, %g1, %g2

	/* HTSTATE[TL=1] */
	rdhpr %hpstate, %g3
	wrpr 1, %tl 			!! current trap level = 1
	mov 0x0, %l1 			!! l1 = 0
	wrhpr %g3, %g0, %htstate 	!! reset HTSTATE reg that store hyperpriviliged state after a trap
	wrpr 0, %tl 			!! current trap level = 0 (No Trap)
	mov 0x0, %o0 			!! please don’t delete since used in customized IMMU miss trap

	/* Jump in RAM */
	jmp %g2 			!! jump to 0x40000
!!	wrhpr %g0, 0x804, %hpstate	!! ensure bit 11 of the HPSTATE register is set
	nop
	nop
