// ============================================================================
//        __
//   \\__/ o\    (C) 2012  Robert Finch
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//  
// Raptor64_opcodes.v
//  - 64 bit CPU
//
//
//  This source code is available for evaluation and validation purposes
//  only. This copyright statement and disclaimer must remain present in
//  the file.
//
//
//	NO WARRANTY.
//  THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
//  EXPRESS OR IMPLIED. The user must assume the entire risk of using the
//  Work.
//
//  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
//  INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
//  THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.
//
//  IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
//  IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
//  REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
//  LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
//  AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
//  LOSSES RELATING TO SUCH UNAUTHORIZED USE.
//
// ============================================================================

`define MISC	7'd0
`define		BRK		7'd0
`define		IRQ		7'd1
`define		ICACHE_ON	7'd10
`define		ICACHE_OFF	7'd11
`define		DCACHE_ON	7'd12
`define		DCACHE_OFF	7'd13
`define     PCCAP_OFF	7'd14
`define 	IEPP	7'd15
`define     FIP		7'd20
`define 	SYSCALL	7'd23
`define		IRET	7'd32
`define		ERET	7'd33
`define 	WAIT	7'd40
`define		TLBP	7'd49
`define     TLBR	7'd50
`define     TLBWI	7'd51
`define     TLBWR	7'd52
`define		CLI		7'd64
`define 	SEI		7'd65
`define		GRAN	7'd80
`define		GRAFD	7'd82
`define R		7'd1
`define 	COM		6'd4
`define		NOT		6'd5
`define		NEG		6'd6
`define		ABS		6'd7
`define		SGN		6'd8
`define		MOV		6'd9
`define		SWAP	6'd13
`define		RBO		6'd14
`define		CTLZ	6'd16
`define		CTLO	6'd17
`define		CTPOP	6'd18
`define		SEXT8	6'd19
`define		SEXT16	6'd20
`define		SEXT32	6'd21
`define		SQRT	6'd24
`define		REDOR	6'd30
`define		REDAND	6'd31
`define     MFSPR	6'd40
`define     MTSPR	6'd41
`define         SR				6'd00
`define         TLBIndex    	6'd01
`define         TLBRandom		6'd02
`define			VER				6'd03
`define         PageTableAddr	6'd04
`define			CORE			6'd05
`define         BadVAddr        6'd08
`define         TLBPhysPage0	6'd10
`define         TLBPhysPage1	6'd11
`define         TLBVirtPage		6'd12
`define			TLBPageMask		6'd13
`define			TLBASID			6'd14
`define         ASID			6'd15
`define			TLBWired		6'd16
`define         EP0             6'd17
`define         EP1             6'd18
`define         EP2             6'd19
`define         EP3             6'd20
`define         AXC             6'd21
`define			Tick			6'd22
`define 		EPC				6'd23
`define			ERRADR			6'd24
`define			TBA				6'd25
`define			NON_ICACHE_SEG	6'd26
`define			CS				6'd27
`define			DS				6'd28
`define			SS				6'd29
`define			ES				6'd30
`define			FPCR			6'd32
`define			IPC				6'd33
`define			RAND			6'd34
`define			SRAND1			6'd35
`define			SRAND2			6'd36
`define			INSNKEY			6'd37
`define			PCHI			6'd62
`define         PCHISTORIC		6'd63
`define 	MFSEG	6'd42
`define 	MTSEG	6'd43
`define 	MFSEGI	6'd44	
`define		OMG		6'd50
`define 	CMG		6'd51
`define		OMGI	6'd52
`define 	CMGI	6'd53
`define		EXEC	6'd58
`define RR	7'd2
`define 	ADD		6'd2
`define		ADDU	6'd3
`define 	SUB		6'd4
`define 	SUBU	6'd5
`define 	CMP		6'd6
`define 	CMPU	6'd7
`define 	AND		6'd8
`define 	OR		6'd9
`define 	XOR		6'd10
`define 	ANDC	6'd11
`define		NAND	6'd12
`define		NOR		6'd13
`define 	XNOR	6'd14
`define		ORC		6'd15
`define		AVG		6'd19
`define		MIN		6'd20
`define		MAX		6'd21
`define		MULU	6'd24
`define		MULS	6'd25
`define		DIVU	6'd26
`define 	DIVS	6'd27
`define		MODU	6'd28
`define		MODS	6'd29
`define		MOVZ	6'd30
`define		MOVNZ	6'd31
`define		MOVPL	6'd32
`define		MOVMI	6'd33

`define 	MTSEGI	6'd35

`define 	SHL		6'd40
`define 	SHRU	6'd41
`define		ROL		6'd42
`define		ROR		6'd43
`define		SHR		6'd44
`define		SHLU	6'd46

//`define		NOP		7'd60

`define 	SLT		6'd48
`define 	SLE		6'd49
`define 	SGT		6'd50
`define 	SGE		6'd51
`define 	SLTU	6'd52
`define 	SLEU	6'd53
`define 	SGTU	6'd54
`define 	SGEU	6'd55
`define 	SEQ		6'd56
`define 	SNE		6'd57

`define 	MTEP	6'd58
`define 	MFEP	6'd59

`define     BCD_MUL 6'd60
`define     BCD_ADD	6'd61
`define     BCD_SUB 6'd62

`define SHFTI	7'd3
`define		SHLI		4'd0
`define 	SHRUI		4'd1
`define 	ROLI		4'd2
`define 	SHRI		4'd3
`define 	RORI		4'd4
`define		SHLUI		4'd6
`define ADDI	7'd4
`define ADDUI	7'd5
`define SUBI	7'd6
`define SUBUI	7'd7
`define CMPI	7'd8
`define CMPUI	7'd9
`define ANDI	7'd10
`define ORI		7'd11
`define XORI	7'd12

`define MULUI	7'd13
`define MULSI	7'd14
`define DIVUI	7'd15
`define DIVSI	7'd16

`define TRAPcc	7'd17
`define		TEQ		5'd0
`define		TNE		5'd1
`define		TLT		5'd2
`define		TGE		5'd3
`define		TLE		5'd4
`define		TGT		5'd5
`define		TLTU	5'd6
`define		TGEU	5'd7
`define		TLEU	5'd8
`define		TGTU	5'd9
`define		TRAP	5'd10
`define		TRN		5'd11
`define TRAPcci	7'd18
`define		TEQI	5'd0
`define		TNEI	5'd1
`define		TLTI	5'd2
`define		TGEI	5'd3
`define		TLEI	5'd4
`define		TGTI	5'd5
`define		TLTUI	5'd6
`define		TGEUI	5'd7
`define		TLEUI	5'd8
`define		TGTUI	5'd9
`define		TRAI	5'd10
`define		TRNI	5'd11
`define	SIMD	7'd20
`define		SIMD_ADD	5'd0
`define		SIMD_SUB	5'd1
`define		SIMD_MUL	5'd2
`define		SIMD_DIV	5'd3
`define		SIMD_CMP	5'd4
`define		SIMD_AND	5'd8
`define		SIMD_OR		5'd9
`define		SIMD_XOR	5'd10
`define BITFIELD	7'd21
`define 	BFINS		3'd0
`define 	BFSET		3'd1
`define 	BFCLR		3'd2
`define 	BFCHG		3'd3
`define 	BFEXTU		3'd4
`define 	BFEXTS		3'd5
`define		SEXT		3'd6
`define	MUX		7'd22
`define	MYST	7'd23
`define CALL	7'd24
`define JMP		7'd25
`define JAL		7'd26
`define RET		7'd27
// SETLO=28 to 31
`define LB		7'd32
`define LC		7'd33
`define LH		7'd34
`define LW		7'd35
`define LP		7'd36
`define LBU		7'd37
`define LCU		7'd38
`define LHU		7'd39
`define LSH		7'd40
`define LSW		7'd41
`define LF		7'd42
`define LFD		7'd43
`define LFP		7'd44
`define LFDP	7'd45
`define LWR		7'd46
`define LDONE	7'd47

`define SB		7'd48
`define SC		7'd49
`define SH		7'd50
`define SW		7'd51
`define SP		7'd52
`define MEMNDX	7'd53
`define 	LBX		6'd0
`define 	LCX		6'd1
`define 	LHX		6'd2
`define 	LWX		6'd3
`define 	LPX		6'd4
`define 	LBUX	6'd5
`define 	LCUX	6'd6
`define 	LHUX	6'd7
`define 	LSHX	6'd8
`define 	LSWX	6'd9
`define	 	LFX		6'd10
`define 	LFDX	6'd11
`define 	LFPX	6'd12
`define 	LFDPX	6'd13
`define 	LWRX	6'd14

`define 	SBX		6'd16
`define 	SCX		6'd17
`define 	SHX		6'd18
`define 	SWX		6'd19
`define 	SPX		6'd20
`define 	SSHX	6'd24
`define 	SSWX	6'd25
`define 	SFX		6'd26
`define 	SFDX	6'd27
`define 	SFPX	6'd28
`define 	SFDPX	6'd29
`define 	SWCX	6'd30

`define 	INBX	6'd32
`define 	INCX	6'd33
`define 	INHX	6'd34
`define 	INWX	6'd35
`define 	INBUX	6'd36
`define 	INCUX	6'd37
`define 	INHUX	6'd38
`define 	OUTBX	6'd40
`define 	OUTCX	6'd41
`define 	OUTHX	6'd42
`define 	OUTWX	6'd43
`define 	CACHEX	6'd44
`define 	LEAX	6'd45
`define 	LMX		6'd46
`define 	SMX		6'd47

`define STBC	7'd54

`define SSH		7'd56
`define SSW		7'd57
`define SF		7'd58
`define SFD		7'd59
`define SFP		7'd60
`define SFDP	7'd61
`define SWC		7'd62

`define INB		7'd64
`define INCH	7'd65
`define INH		7'd66
`define INW		7'd67
`define INBU	7'd68
`define INCU	7'd69
`define INHU	7'd70
`define OUTBC	7'd71
`define OUTB	7'd72
`define OUTC	7'd73
`define OUTH	7'd74
`define OUTW	7'd75
`define CACHE	7'd76
`define		INVIL		5'd0
`define		INVIALL		5'd1
`define     ICACHEON	5'd14
`define		ICACHEOFF	5'd15
`define		DCACHEON	5'd30
`define		DCACHEOFF	5'd31
`define LEA		7'd77
`define LM		7'd78
`define SM		7'd79

`define BLTI	7'd80
`define BGEI	7'd81
`define BLEI	7'd82
`define BGTI	7'd83
`define BLTUI	7'd84
`define BGEUI	7'd85
`define BLEUI	7'd86
`define BGTUI	7'd87
`define BEQI	7'd88
`define BNEI	7'd89

`define BTRI	7'd94
`define 	BLTRI	5'd0
`define 	BGERI	5'd1
`define 	BLERI	5'd2
`define 	BGTRI	5'd3
`define 	BLTURI	5'd4
`define 	BGEURI	5'd5
`define 	BLEURI	5'd6
`define 	BGTURI	5'd7
`define 	BEQRI	5'd8
`define 	BNERI	5'd9
`define		BRARI	5'd10
`define		BRNRI	5'd11
`define		BANDRI	5'd12
`define		BORRI	5'd13
`define BTRR	7'd95
`define 	BLT		5'd0
`define 	BGE		5'd1
`define 	BLE		5'd2
`define 	BGT		5'd3
`define 	BLTU	5'd4
`define 	BGEU	5'd5
`define 	BLEU	5'd6
`define 	BGTU	5'd7
`define 	BEQ		5'd8
`define 	BNE		5'd9
`define		BRA		5'd10
`define		BRN		5'd11
`define		BAND	5'd12
`define		BOR		5'd13
`define		BNR		5'd14
`define		LOOP	5'd15
`define 	BLTR	5'd16
`define 	BGER	5'd17
`define 	BLER	5'd18
`define 	BGTR	5'd19
`define 	BLTUR	5'd20
`define 	BGEUR	5'd21
`define 	BLEUR	5'd22
`define 	BGTUR	5'd23
`define 	BEQR	5'd24
`define 	BNER	5'd25
`define		BRAR	5'd26
`define		BRNR	5'd27


`define SLTI	7'd96
`define SLEI	7'd97
`define SGTI	7'd98
`define SGEI	7'd99
`define SLTUI	7'd100
`define SLEUI	7'd101
`define SGTUI	7'd102
`define SGEUI	7'd103
`define SEQI	7'd104
`define SNEI	7'd105

`define FP		7'd108
`define FDADD		6'd0
`define FDSUB		6'd1
`define FDMUL		6'd2
`define FDDIV		6'd3
`define FDCUN		6'd4
`define FDI2F		6'd5
`define FDF2I		6'd6
`define FDF2D		6'd7
`define FDD2F		6'd8
`define FDCLT		6'b001100
`define FDCEQ		6'b010100
`define FDCLE		6'b011100
`define FDCGT		6'b100100
`define FDCNE		6'b101100
`define FDCGE		6'b110100
`define FPLOO	7'd109
`define FPZL	7'd110
`define NOPI	7'd111

`define SETLO	7'b11100xx
`define SETMID	7'b11101xx
`define SETHI	7'b11110xx
`define IMM1	7'd124
`define IMM2	7'd125
`define IMM3	7'd126

`define NOP_INSN	32'b1101111_0_00000000_00000000_00000000

