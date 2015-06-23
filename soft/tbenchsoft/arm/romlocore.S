#include "arm.h"	
 			 		
	/*
	 * Memctrl Initialization
	 */
	nop

	mov r0,   #0x00810000
	orr r0,r0,#0x0000000f		 
	mov r1,   #0x80000014		 
	str r0,[r1]
	        
	mov r0,   #0x04000000		 
	orr r0,r0,#0x00080000		 
	orr r0,r0,#0x00000300		 
	mov r1,   #0x80000000		 
	str r0,[r1]
	mov r0,   #0xd5000000		 
	orr r0,r0,#0x00380000		 
	orr r0,r0,#0x00004800		 
	orr r0,r0,#0x00000030		 
	mov r1,   #0x80000000		 
	orr r1,r1,#0x00000004
	str r0,[r1]
	mov r0,   #0x000f0000		 
	mov r1,   #0x80000000		 
	orr r1,r1,#0x00000008
	str r0,[r1]

	
	mov	ip,#0x40000000
	orr     ip,ip, #0x1000
	mov     sp,#0x40000000
	orr     sp,sp, #0x1000

	.globl	func1

	bl func1
	

	
		
	
	/* coprocessor */
	mrc 15,1,r0,cr1,cr0
	orr r0,r0,#0x00000001		 
	mcr 15,0,r0,cr1,cr0
	mrc 15,1,r0,cr1,cr0


	
	
		
        /*
	 * msr
	 * -- msr CPSR_[cxsf],#<imm>
	 * -- msr CPSR_[cxsf],<rm>
	 * -- msr SPSR_[cxsf],#<imm>
	 * -- msr SPSR_[cxsf],<rm>  
         */
	mov r13,#0x13 /* svc */
	mov r8,#0xaa
	
	msr CPSR_c,#0x17 /* abort */
 	mov r13,#0x17 
	mov r8,#0xaa
	
	msr CPSR_c,#0x1b /* undefined */
	mov r13,#0x1b 
	mov r8,#0xaa
	
	msr CPSR_c,#0x12 /* irq */
	mov r13,#0x12
	mov r8,#0xaa
	
	msr CPSR_c,#0x11 /* fiq */
	mov r13,#0x11 
	mov r8,#0x11  
	mov r12,#0x11 

	
	msr CPSR_c,#0x1f /* sys */
	mov r13,#0x1f 

	
	/* read in sys */
	msr CPSR_c,#0x1f 
	mov r1,r13   
	mov r1,r8   
	
	/* read in abort */
	msr CPSR_c,#0x17
	mov r1,r13
	mov r1,r8   
	
	/* read in svc */
	msr CPSR_c,#0x13
	mov r1,r13
	mov r1,r8   
	
	/* read in irq */
	msr CPSR_c,#0x12
	mov r1,r13
	mov r1,r8   

	/* read in fiq */
	msr CPSR_c,#0x11
	mov r1,r13
	mov r1,r8   

	/* read in undef */
	msr CPSR_c,#0x1b
	mov r1,r13
	mov r1,r8   

	
	

	
	
	
	
			
	
	mov r0,   #0x40000000
	mov r1,   #0x1
	ldr r1,[r0] 
	mov r1,   #0x2
 
	mov r0,   #0x40000000
	orr r0,r0,#0x00001000
	ldr r1,[r0]

	mov r0,   #0x40000000
	orr r0,r0,#0x00002000
	ldr r1,[r0]
	
	mov r0,   #0x40000000
	swp r1,r1,[r0]
	swp r1,r1,[r0]
	swp r1,r2,[r0]
	

	/* armcmd_lm.vhd
	-- LRM/STM: Increment after  (regorder [0-15],start:+0,end(onwb):+4) :ldmia|stmia <rn>,{<reglist>}
	-- LRM/STM: Increment before (regorder [0-15],start:+4,end(onwb):+0) :ldmib|stmib <rn>,{<reglist>}
        -- LRM/STM: Decrement after  (regorder [15-0],start:-0,end(onwb):-4) :ldmda|stmda <rn>,{<reglist>}
        -- LRM/STM: Decrement before (regorder [15-0],start:-4,end(onwb):-0) :ldmdb|stmdb <rn>,{<reglist>}
        */

	mov r0,   #0x40000000
	ldr r1,[r0] 
	orr r0,r0,#0x00000010		 
	ldmia r0,{r1,r2,r3}
	ldmib r0,{r1,r2,r3}
	ldmda r0,{r1,r2,r3}
	ldmdb r0,{r1,r2,r3}

	stmia r0,{r1,r2,r3}
	stmib r0,{r1,r2,r3}
	stmda r0,{r1,r2,r3}
	stmdb r0,{r1,r2,r3}

	/* locking */
	mov r0,   #0x40000000		 
	orr r0,r0,#0x00000010		 
	str r0,[r0]
	ldr r0,[r0]
	ldmia r0,{r1,r2,r3}
	

	
		
	/*
	armcmd_ld.vhd.am.LDSTAM_typ:	
	  adm_LDSTAM_simm
	    -- adm_atyp_LSV4AM.adm_LSV4AM_reg:
	    -- - L/S MISC: Register offset            : [<rn>, #+/-<rm>]
            -- - L/S MISC: Register offset pre-index  : [<rn>, #+/-<rm>] !
            -- - L/S MISC: Register offset post-index : [<rn>], #+/-<rm>
	*/
	mov r1,   #0x40000004		 
	mov r2,   #0x00000004
	orr r2,r2,#0x05000000		 
	mov r0,   #0x01000000		 
	orr r0,r0,#0x00020000		 
	orr r0,r0,#0x00000300		 
	orr r0,r0,#0x00000004		 
	str r0,[r1]
	strb r2,[r1]
	ldr r0,[r1]
	
	mov r2,   #0x4
	ldrb r0,[r1,#0]
	ldrb r0,[r1,#1]
	ldrb r0,[r1,#2]
	ldrb r0,[r1,#3]
	
	
	--ldr r0,[r1,r2]
	--ldr r0,[r1,-r2]
	ldrb r0,[r1,r2]
	
	/*
	    -- adm_atyp_LSV4AM.adm_LSV4AM_reg: 
	    -- - L/S MISC: Immediate offset            : [<rn>, #+/-<off>]
            -- - L/S MISC: Immediate offset pre-index  : [<rn>, #+/-<off>] !
            -- - L/S MISC: Immediate offset post-index : [<rn>], #+/-<off>
	*/
	mov r1,   #0x40000004		 
	mov r2,   #0x4		 
	ldrsb r0,[r1,-r2]
	ldrsb r0,[r1,r2]
	ldrsh r0,[r1,-r2]
	ldrsh r0,[r1,r2]!
	strh r0,[r1,r2]
	strh r0,[r1,-r2]!
	
		
	/*
	armcmd_ld.vhd.am.LDSTAM_typ:	
	  adm_LDSTAM_simm
	-- L/S W/UB: Register Offset                     : [<rn>, +/-<rm>]
        -- L/S W/UB: Register Offset pre-indexed         : [<rn>, +/-<rm>]!
        -- L/S W/UB: Register Offset post-indexed        : [<rn>], +/-<rm>
        -- L/S W/UB: Scaled Register Offset              : [<rn>, +/-<rm>, <LSAMscale>]
        -- L/S W/UB: Scaled Register Offset pre-indexed  : [<rn>, +/-<rm>, <LSAMscale>]!
        -- L/S W/UB: Scaled Register Offset post-indexed : [<rn>], +/-<rm>, <LSAMscale>
        -- <LSAMscale>: {LSL #<imm>}|{LSR #<imm>}|{ASR #<imm>}|{ROR #<imm>}|{RRX}
	*/
	mov r1,   #0x40000004		 
	mov r2,   #0x4		 
	ldr r0,[r1,r2]
	ldr r0,[r1,-r2]
	ldrb r0,[r1,r2]
	
	ldr r0,[r1,r2]!
	ldr r0,[r1],r2
	
	mov r1,   #0x40000004		 
	mov r2,   #0x4		 
	ldr r0,[r1,r2, lsl #1]
	ldr r0,[r1,r2, lsl #1]
	ldr r0,[r1,r2, lsr #1]
	ldr r0,[r1,r2, asr #1]
	ldr r0,[r1,r2, ror #1]
	ldr r0,[r1,r2, rrx]
	ldr r0,[r1,r2, lsl #1]!
	ldr r0,[r1,r2, lsr #1]!
	ldr r0,[r1,r2, asr #1]!
	ldr r0,[r1,r2, ror #1]!
	ldr r0,[r1,r2, rrx]!
	ldr r0,[r1],r2, lsl #1
	ldr r0,[r1],r2, lsr #1
	ldr r0,[r1],r2, asr #1
	ldr r0,[r1],r2, ror #1
	ldr r0,[r1],r2, rrx

	mov r1,   #0x40000004		 
	mov r2,   #0x4		 
	str r0,[r1,r2]
	str r0,[r1,-r2]
	strb r0,[r1,r2]
	
	str r0,[r1,r2]!
	str r0,[r1],r2
	
	mov r1,   #0x40000004		 
	mov r2,   #0x4		 
	str r0,[r1,r2, lsl #1]
	str r0,[r1,r2, lsr #1]
	str r0,[r1,r2, asr #1]
	str r0,[r1,r2, ror #1]
	str r0,[r1,r2, rrx]
	str r0,[r1,r2, lsl #1]!
	str r0,[r1,r2, lsr #1]!
	str r0,[r1,r2, asr #1]!
	str r0,[r1,r2, ror #1]!
	str r0,[r1,r2, rrx]!
	str r0,[r1],r2, lsl #1
	str r0,[r1],r2, lsr #1
	str r0,[r1],r2, asr #1
	str r0,[r1],r2, ror #1
	str r0,[r1],r2, rrx
	
	/*
	armcmd_l1.vhd.am.LDSTAM_typ:	
	  adm_LDSTAM_off =>
        -- L/S W/UB: Immediate Offset              : [<rn>, #+/-<offset12>]
        -- L/S W/UB: Immediate Offset pre-indexed  : [<rn>, #+/-<offset12>]!
        -- L/S W/UB: Immediate Offset post-indexed : [<rn>], #+/-<offset12>
	*/

	mov r1,   #0x40000004		 
	mov r2,   #0x4		 
	ldr r0,[r1,#4]
	ldr r0,[r1,#4]!
	ldr r0,[r1],#4
	
	str r0,[r1,#4]
	str r0,[r1,#4]!
	str r0,[r1],#4

	/* locking */
	ldr r0,[r1,#4]
	ldr r0,[r1,#4]!
	add r0,r0,r1


	/* armcmd_lm.vhd
	-- LRM/STM: Increment after  (regorder [0-15],start:+0,end(onwb):+4) :ldmia|stmia <rn>,{<reglist>}
	-- LRM/STM: Increment before (regorder [0-15],start:+4,end(onwb):+0) :ldmib|stmib <rn>,{<reglist>}
        -- LRM/STM: Decrement after  (regorder [15-0],start:-0,end(onwb):-4) :ldmda|stmda <rn>,{<reglist>}
        -- LRM/STM: Decrement before (regorder [15-0],start:-4,end(onwb):-0) :ldmdb|stmdb <rn>,{<reglist>}
        */
	
	ldmia r0,{r1,r2,r3}
	ldmib r0,{r1,r2,r3}
	ldmda r0,{r1,r2,r3}
	ldmdb r0,{r1,r2,r3}

	stmia r0,{r1,r2,r3}
	stmib r0,{r1,r2,r3}
	stmda r0,{r1,r2,r3}
	stmdb r0,{r1,r2,r3}

	/* locking */
	ldr r0,[r1]
	ldmia r0,{r1,r2,r3}
	
	
	
	

	
	

	
	
	
	
	
	
	
	
	
	
		mov r1,pc
	sub r1,r1,#8
	mov r0,#0x40000000
	str r1,[r0]
loop2:	ldr pc,[r0]
	nop
	nop
	nop
	nop
	nop
	nop	
	nop
	nop	
	nop
	nop	
	nop

	/* armcmd_lm.vhd
	-- LRM/STM: Increment after  (regorder [0-15],start:+0,end(onwb):+4) :ldmia|stmia <rn>,{<reglist>}
	-- LRM/STM: Increment before (regorder [0-15],start:+4,end(onwb):+0) :ldmib|stmib <rn>,{<reglist>}
        -- LRM/STM: Decrement after  (regorder [15-0],start:-0,end(onwb):-4) :ldmda|stmda <rn>,{<reglist>}
        -- LRM/STM: Decrement before (regorder [15-0],start:-4,end(onwb):-0) :ldmdb|stmdb <rn>,{<reglist>}
        */

	mov r0   ,#0x40000000
	orr r0,r0,#0x00000100
	mov r1,#1
	mov r2,#2
	mov r3,#3
	stmia r0,{r1,r2,r3}
	
	ldmia r0,{r1,r2,r3}
	ldmib r0,{r1,r2,r3}
	ldmda r0,{r1,r2,r3}
	ldmdb r0,{r1,r2,r3}

	stmia r0,{r1,r2,r3}
	stmib r0,{r1,r2,r3}
	stmda r0,{r1,r2,r3}
	stmdb r0,{r1,r2,r3}


	
	/* armcmd_sw.vhd
	-- sw <rd>,<rm>,[<rn>]
	*/
	mov r0   ,#0x40000000
	mov r1,#0
	str r1,[r0]
	mov r1,#1
	mov r2,#2
	
	swp r1,r1,[r0]
	swp r1,r1,[r0]
	swp r1,r2,[r0]
	
	
	/*
	armcmd_al.vhd.am.DAPRAM_typ:	
	  adm_DAPRAM_simm
        -- DP op2: Register                     : <rm>
        -- DP op2: Register <SDIR> by Immediate : <rm>, <SDIR> #<imm>
        -- DP op2: Register RRX                 : <rm>, RRX
        -- <SDIR>: {LSL}|{LSR}|{ASR}|{ROR}
	*/
	mov r0,   #0x0		 
	mov r1,   #0x1		 
	mov r2,   #0x2		 
	mov r3,   #0x3		 
	add r0,r1,r2
	add r0,r1,r2, lsl #1 
	add r0,r1,r2, lsr #1 
	add r0,r1,r2, asr #1 
	add r0,r1,r2, ror #1 
	add r0,r1,r2, rrx 
	
	/*
	armcmd_al.vhd.am.DAPRAM_typ:	
	  adm_DAPRAM_sreg 
        -- DP op2: Register <SDIR> by Register  : <rm>, <SDIR> <rs>
        -- <SDIR>: {LSL}|{LSR}|{ASR}|{ROR}
	*/
	add r0,r1,r2,lsl r3
	add r0,r1,r2,lsr r3
	add r0,r1,r2,asr r3
	add r0,r1,r2,ror r3
	
	/*
	armcmd_al.vhd.am.DAPRAM_typ:	
	  adm_DAPRAM_immrot =>
        -- DP op2: Immediate #<imm>
	*/
	add r0,r1,#1
	
	/* locking */
	add r0,r1,r2                 
	add r0,r0,r1             
	add r0,r1,r0             
	add r0,r1,r0,lsl #1      
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
		

	/* adm_DAPRAMxLDSTAM_DAPRAM_sreg shiefter */
	/* adm_slsl:	
          --if Rs[7:0] == 0 then
          --  shifter_operand = Rm
          --  shifter_carry_out = C Flag
          --else if Rs[7:0] < 32 then
          --  shifter_operand = Rm Logical_Shift_Left Rs[7:0]
          --  shifter_carry_out = Rm[32 - Rs[7:0]]
          --else if Rs[7:0] == 32 then
          --  shifter_operand = 0
          --  shifter_carry_out = Rm[0]
          --else  Rs[7:0] > 32 
          --  shifter_operand = 0
          --  shifter_carry_out = 0
	*/
	movs r1,#0x1
	movs r2,#0xc0000001
	movs r3,#0
	adds r0,r1,r2,lsl r3      
	
	movs r1,#0x1
	movs r2,#0xc0000001
	mov  r3,#0
	adds r0,r1,r2,lsl r3      
	
	
	movs r3,#1
	adds r0,r1,r2,lsl r3      
	movcss r3,#32
	addcss r0,r1,r2,lsl r3      
	movcss r3,#33
	addcss r0,r1,r2,lsl r3

	movs r2,#0x40000001
	movs r3,#1
	adds r0,r1,r2,lsl r3  /* carry 0 */    
	movs r2,#0xc0000000   
	movs r3,#32
	adds r0,r1,r2,lsl r3  /* carry 0 */

	/* adm_DAPRAMxLDSTAM_DAPRAM_sreg shiefter */
	/* adm_slsr:	
          --if Rs[7:0] == 0 then
          --  shifter_operand = Rm
          --  shifter_carry_out = C Flag
          --else if Rs[7:0] < 32 then
          --  shifter_operand = Rm Logical_Shift_Right Rs[7:0]
          --  shifter_carry_out = Rm[Rs[7:0] - 1]
          --else if Rs[7:0] == 32 then
          --  shifter_operand = 0
          --  shifter_carry_out = Rm[31]
          --else   Rs[7:0] > 32 
          --  shifter_operand = 0
          --  shifter_carry_out = 0
	*/
	mov r2,#0xc0000001
	mov r3,#0
	add r0,r1,r2,lsr r3      
	mov r3,#1
	add r0,r1,r2,lsr r3      
	mov r3,#32
	add r0,r1,r2,lsr r3      
	mov r3,#33
	add r0,r1,r2,lsr r3
	
	mov r2,#0x40000001
	mov r3,#1
	add r0,r1,r2,lsr r3  /* carry 0 */    
	mov r2,#0x40000001
	mov r3,#32
	add r0,r1,r2,lsr r3  /* carry 0 */

	/* adm_DAPRAMxLDSTAM_DAPRAM_sreg shiefter */
	/* adm_sasr:	
          --if Rs[7:0] == 0 then
          --  shifter_operand = Rm
          --  shifter_carry_out = C Flag
          --else if Rs[7:0] < 32 then
          --  shifter_operand = Rm Arithmetic_Shift_Right Rs[7:0]
          --  shifter_carry_out = Rm[Rs[7:0] - 1]
          --else  Rs[7:0] >= 32 
          --  if Rm[31] == 0 then
          --    shifter_operand = 0
          --    shifter_carry_out = Rm[31]
          --  else  Rm[31] == 1 
          --    shifter_operand = 0xFFFFFFFF
          --    shifter_carry_out = Rm[31]
	*/
	mov r2,#0xc0000001
	mov r3,#0
	add r0,r1,r2,asr r3      
	mov r3,#1
	add r0,r1,r2,asr r3      
	mov r2,#0xc0000001
	mov r3,#32
	add r0,r1,r2,asr r3      
	mov r2,#0x40000001
	mov r3,#32
	add r0,r1,r2,asr r3
	
	mov r2,#0x40000001
	mov r3,#1
	add r0,r1,r2,asr r3  /* carry 0 */    
	mov r2,#0x40000000   
	mov r3,#32
	add r0,r1,r2,asr r3  /* carry 0 */

	/* adm_DAPRAMxLDSTAM_DAPRAM_sreg shiefter */
	/* adm_sror:	
	  --if Rs[7:0] == 0 then
          --  shifter_operand = Rm
          --  shifter_carry_out = C Flag
          --else if Rs[4:0] == 0 then
          --  shifter_operand = Rm 
          --  shifter_carry_out = Rm[31]
          --else  Rs[4:0] > 0
          --  shifter_operand = Rm Rotate_Right Rs[4:0]
          --  shifter_carry_out = Rm[Rs[4:0] - 1]
	*/
	
	mov r2,#0x40000001
	mov r3,#0
	add r0,r1,r2,ror r3      
	mov r2,#0xc0000001
	mov r3,#0
	add r0,r1,r2,ror r3      
	mov r3,#1
	add r0,r1,r2,ror r3      
	mov r3,#32
	add r0,r1,r2,ror r3      
	mov r2,#0x40000001
	mov r3,#32
	add r0,r1,r2,ror r3      
	
	mov r3,#33
	add r0,r1,r2,ror r3
	
	/* adm_DAPRAMxLDSTAM_DAPRAM_sreg shiefter */
	/* adm_srrx:	
          --shifter_operand = (C Flag Logical_Shift_Left 31) OR (Rm Logical_Shift_Right 1)
          --shifter_carry_out = Rm[0]
	*/
	mov r2,#0xc0000001
	mov r3,#0
	add r0,r1,r2,rrx      

	/* adm_DAPRAMxLDSTAM_DAPRAMxLDSTAM_simm */
	/* adm_slsl
          --if shift_imm == 0 then 
          --  shifter_operand = Rm
          --  shifter_carry_out = C Flag
          --else  shift_imm > 0 
          --  shifter_operand = Rm Logical_Shift_Left shift_imm
          --  shifter_carry_out = Rm[32 - shift_imm]
	*/
	mov r2,#0xc0000001
	add r0,r1,r2,lsl #0      
	add r0,r1,r2,lsl #1      
	add r0,r1,r2,lsl #3      
	add r0,r1,r2,lsl #31      

	/* adm_DAPRAMxLDSTAM_DAPRAMxLDSTAM_simm */
	/* adm_slsr
          --if shift_imm == 0 then
          --  shifter_operand = 0
          --  shifter_carry_out = Rm[31]
          --else shift_imm > 0 
          --  shifter_operand = Rm Logical_Shift_Right shift_imm
          --  shifter_carry_out = Rm[shift_imm - 1]
	*/
	mov r2,#0xc0000001
	add r0,r1,r2,lsr #0      
	add r0,r1,r2,lsr #1      
	add r0,r1,r2,lsr #2      
	add r0,r1,r2,lsr #31      

	/* adm_DAPRAMxLDSTAM_DAPRAMxLDSTAM_simm */
	/* adm_sasr
          --if shift_imm == 0 then
          --  if Rm[31] == 0 then
          --    shifter_operand = 0
          --    shifter_carry_out = Rm[31]
          --  else  Rm[31] == 1 
          --    shifter_operand = 0xFFFFFFFF
          --    shifter_carry_out = Rm[31]
          --else  shift_imm > 0 
          --  shifter_operand = Rm Arithmetic_Shift_Right <shift_imm>
          --  shifter_carry_out = Rm[shift_imm - 1]
	*/        
	mov r2,#0xc0000001
	add r0,r1,r2,asr #1      
	add r0,r1,r2,asr #2      
	add r0,r1,r2,asr #31      
	mov r2,#0xc0000001
	add r0,r1,r2,asr #0      
	mov r2,#0x40000001
	add r0,r1,r2,asr #0      

	/* adm_DAPRAMxLDSTAM_DAPRAMxLDSTAM_simm */
	/* adm_sror
          --if shift_imm == 0 then
          --  adm_srrx case
          --else shift_imm > 0 
          --  shifter_operand = Rm Rotate_Right shift_imm
          --  shifter_carry_out = Rm[shift_imm - 1]
	*/
	mov r2,#0xc0000001
	add r0,r1,r2,ror #0      
	add r0,r1,r2,ror #1      
	add r0,r1,r2,ror #3      
	add r0,r1,r2,ror #31      
	
	/* adm_DAPRAMxLDSTAM_DAPRAMxLDSTAM_simm */
	/* adm_srrx
	  --shifter_operand = (C Flag Logical_Shift_Left 31) OR (Rm Logical_Shift_Right 1)
          --shifter_carry_out = Rm[0]
        */
	mov r2,#0xc0000001
	add r0,r1,r2,rrx	
	add r0,r1,r2,rrx	

	
	
	
	
	
	
	/* coprocessor */
	mrc 15,1,r0,cr1,cr0
	orr r0,r0,#0x00000001		 
	mcr 15,0,r0,cr1,cr0
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
		
	
	        nop

	mov r0,   #0x00810000
	orr r0,r0,#0x0000000f		 
	mov r1,   #0x80000014		 
	str r0,[r1]
	        
	mov r0,   #0x04000000		 
	orr r0,r0,#0x00080000		 
	orr r0,r0,#0x00000300		 
	mov r1,   #0x80000000		 
	str r0,[r1]
	mov r0,   #0xd5000000		 
	orr r0,r0,#0x00380000		 
	orr r0,r0,#0x00004800		 
	orr r0,r0,#0x00000030		 
	mov r1,   #0x80000000		 
	orr r1,r1,#0x00000004
	str r0,[r1]
	mov r0,   #0x000f0000		 
	mov r1,   #0x80000000		 
	orr r1,r1,#0x00000008
	str r0,[r1]

	
	mov r0,#0x40000000		 
	mov r7,#0x12		 
	mov r1,#0x11		 
	mov r2,#0x12		 
	/*str r2,[r1,r2]
	nop*/
	nop
	str r7,[r0]
	nop
	ldr r7,[r0]
Label:	
	nop
	stmia r0,{r1,r2}
	nop
	ldmia r0,{r3,r4}
	b Label
		
	/* # add, lock r0 */ 
	adds r0,r0,r1  ; /* reg */
	/* r0 = 3 */
	/*adds r0,r1,r2,lsl #3*/  ; /* lsl imm */
	/* r0 = 1 + (2 * 2^3) = 5 */
	
        mov r0,#3		 
	adds r0,r1,r2,lsl r0  ; /* lsl reg */
	/* r0 = 1 + (2 * 2^3) = 5 */
	adds r0,r1,r4,lsr #1  ; /* lsr imm */
	/* r0 = 1 + (4 / 2) = 3 */
	adds r0,r1,r4,lsr r1  ; /* lsr reg */
	/* r0 = 1 + (4 / 2) = 3 */
	adds r0,r1,r7,asr #1  ; /* asr imm */
	/* r0 = 0 */
	adds r0,r1,r7,asr r1  ; /* asr reg */
	/* r0 = 0 */
	adds  r0,r1,r8,ror r2  ; /* ror reg */
	/* r0 = 0x3c3c3c3c + 1 */
	adds  r0,r1,r8,rrx     ; /* ror reg */
	/* r0 = 0x78787878 + 1 */

		
	/* # addc */
	addcs r0,r1,r2  ; /* reg */
	
	/* # and */
	ands r0,r1,r2  ; ; /* reg */
	
	/* # bic */
	bic r0,r1,r2  
	
	/* # cmn */

	; /* # cmp */

	; /* # eor */

	; /* # mov */

	; /* # mvn */

	; /* # orr */
	orr r0,r1,r2  
	
	; /* # rsb */

	; /* # rsc */

	; /* # sbc */
	sbc r0,r1,r2  
	
	; /* # sub */
	sub r0,r1,r2  
	
	; /* # teq */

	; /* # tst */

	
	
	mul  r0,r1,r2

	mul  r0,r3,r4

	
	
	; /* # load store */
	ldrb r0,[r1], #4          ; /* addr word :	 r1, r1 = r1 + 4 */ 
	
	
	ldr r0,[r0]              ; /* addr word : r0 */
	ldr r0,[r1,#4]		 ; /* addr word : r3 + 4 */
	ldr r0,[r1,#-4]          ; /* addr word : r3 + -4 */
	str r0,[r1,#0x100]       ; /* addr word : r1 + 0x100 */
	
	ldrb r0,[r1]		 ; /* addr byte :	 r1 */
	ldrb r0,[r1,#3]          ; /* addr byte :	 r1 + 3 */
	strb r4,[r1,#0x200]      ; /* addr byte :	 r1 + 0x200 */
	
	ldr r0,[r1,r2]           ; /* addr word :	 r1 + r2 */
	strb r0,[r1,-r2]         ; /* addr byte :	 r1 - r2 */
	
	ldr r0,[r1,r2,lsl #2]    ; /* addr word :	 r1 + (r2 * 4) */
	ldr r0,[r1,#4]!          ; /* addr word :	 r1 + 4, write back */
	strb r0,[r1,#-1]!        ; /* addr byte :	 r1 - 1, write back */
	
        
	ldr r0,[r1], #4          ; /* addr word :	 r1, r1 = r1 + 4 */ 
	str r0,[r1], #8          ; /* addr word :	 r1, r1 = r1 + 8 */

	ldr r0,[pc,#40]          ; /* addr word :	 pc + 0x40 = . + 8 + 0x40 */
	
	ldr r0,[r1], r2          ; /* addr word :	 r1, r1 = r1 + r2  */

	/* miscelanous */	
	ldrh r1,[r0]             ; /* addr hword :	 r0 */
	ldrh r0,[r1,#2]          ; /* addr hword :	 r1 + 2 */
	ldrh r0,[r1,#-16]        ; /* addr hword :	 r1 - 16 */
	strh r0,[r1,#0x80]       ; /* addr hword :	 r1 + 0x80 */

	ldrsh r0,[r1]            ; /* addr hword :	 r1 (signed extend) */
	ldrsb r0,[r1,#3]         ; /* addr byte :	r1 + 3 (signed extend) */ 
	ldrsb r0,[r1,#0xc1]       ; /* addr byte :	r1 + 0xc1 (signed extend) */

	ldrh r0,[r1,r2]          ; /* addr hword :	 r1 + r2
	strh r0,[r1,-r2]         ; /* addr hword :	 r1 - r2

	ldrsh r0,[r1,#2]         ; /* addr hword : r1 + 2 (signed extend */ 
	
	
	

	
	
	
	
	
	
	
	
		/*
	 * msr
	 * -- msr CPSR_[cxsf],#<imm>
	 * -- msr CPSR_[cxsf],<rm>
	 * -- msr SPSR_[cxsf],#<imm>
	 * -- msr SPSR_[cxsf],<rm>  
         */
	mov r13,#0x13 /* svc */
	mov r8,#0xaa
	
	msr CPSR_c,#0x17 /* abort */
 	mov r13,#0x17 
	mov r8,#0xaa
	
	msr CPSR_c,#0x1b /* undefined */
	mov r13,#0x1b 
	mov r8,#0xaa
	
	msr CPSR_c,#0x12 /* irq */
	mov r13,#0x12
	mov r8,#0xaa
	
	msr CPSR_c,#0x11 /* fiq */
	mov r13,#0x11 
	mov r8,#0x11  
	mov r12,#0x11 

	
	msr CPSR_c,#0x1f /* sys */
	mov r13,#0x1f 

	
	/* read in sys */
	msr CPSR_c,#0x1f 
	mov r1,r13   
	mov r1,r8   
	
	/* read in abort */
	msr CPSR_c,#0x17
	mov r1,r13
	mov r1,r8   
	
	/* read in svc */
	msr CPSR_c,#0x13
	mov r1,r13
	mov r1,r8   
	
	/* read in irq */
	msr CPSR_c,#0x12
	mov r1,r13
	mov r1,r8   

	/* read in fiq */
	msr CPSR_c,#0x11
	mov r1,r13
	mov r1,r8   

	/* read in undef */
	msr CPSR_c,#0x1b
	mov r1,r13
	mov r1,r8   

	
	
		




	/*
	 * msr
	 * -- msr CPSR_[cxsf],#<imm>
	 * -- msr CPSR_[cxsf],<rm>
	 * -- msr SPSR_[cxsf],#<imm>
	 * -- msr SPSR_[cxsf],<rm>  
         */
	mov r13,#0x13 /* svc */
	msr SPSR_c,#0x1 /* svc */
	
	msr CPSR_c,#0x17 /* abort */
	msr SPSR_c,#0x2 /* abort */
	
	msr CPSR_c,#0x1b /* undefined */
	msr SPSR_c,#0x3 /* undefined */
		
	msr CPSR_c,#0x12 /* irq */
	msr SPSR_c,#0x4 /* irq*/
	
	msr CPSR_c,#0x11 /* fiq */
	msr SPSR_c,#0x5 /* fiq */

	msr CPSR_c,#0x1f /* sys */
	msr SPSR_c,#0x6 /* sys */
	
	mrs r0,SPSR /* sys */
	
	msr CPSR_c,#0x11 /* fiq */
	mrs r0,SPSR /* fiq : 0x5 */
	
	msr CPSR_c,#0x12 /* irq */
	mrs r0,SPSR /* irq : 0x4 */
	
	msr CPSR_c,#0x1b /* undefined */
	mrs r0,SPSR /* undefined : 0x3 */

	msr CPSR_c,#0x17 /* abort */
	mrs r0,SPSR /* abort : 0x2 */

	msr CPSR_c,#0x13 /* svc */
	mrs r0,SPSR /* svc : 0x1 */























		mov r0,   #0x40000000
	mov r1,   #0x1
	ldr r1,[r0] 
	mov r1,   #0x2


	mov r1,#8
	sub r1,r1,r1
	bne loop5
	beq loop4
	
		
	swi 10
	
loop4:	mov r1,#10
loop5:	mov r1,#10
	
			mov r1,pc
	sub r1,r1,#8
	mov r0,#0x40000000
	str r1,[r0]
loop3:	ldr pc,[r0]
	nop
	nop
	nop
	nop
	nop
	nop	
	nop
	nop	
	nop
	nop	

