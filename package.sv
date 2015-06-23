//////////////////////////////////////////////////////////////////////////////////////////////
//    Project Qrisc32 is risc cpu implementation, purpose is studying
//    Digital System Design course at Kyoung Hee University during my PhD earning
//    Copyright (C) 2010  Vinogradov Viacheslav
// 
//    This library is free software; you can redistribute it and/or
//   modify it under the terms of the GNU Lesser General Public
//    License as published by the Free Software Foundation; either
//    version 2.1 of the License, or (at your option) any later version.
//
//    This library is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//    Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public
//    License along with this library; if not, write to the Free Software
//    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//
//////////////////////////////////////////////////////////////////////////////////////////////


`ifdef RISC_PACK_DEF
`else
`define RISC_PACK_DEF

interface 	avalon_port;
logic[31:0] address_r;//address
logic[31:0] data_r;//data is read
logic[31:0] data_w;//data to write
logic		rd,wr,wait_req;//read, write and wait request signals
endinterface

package risc_pack;
	typedef struct packed{
		bit[31:0]		val_r1;//value of register src1
		bit[31:0]		val_r2;//value of register src2
		bit[31:0]		val_dst;//value of register dst
		
		bit[4:0]		src_r2;//indicate number of src2 register
		bit[4:0]		src_r1;//indicate number of src1 register
		bit[4:0]		dst_r;//indicate number of dest register
		
		//add to src2
		bit[3:0]		incr_r2;//0 +1 or -1, +2,-2, +4, -4
		bit				incr_r2_enable;//
		
		//
		bit				write_reg;//indicate write to RF(addres in dst_r, value in dst_v)
		//load store operations, if both bit is zero then bypass MEM stage
		bit				read_mem;//indicate read from memory(addres in src1+src2)
		bit				write_mem;//indicate write to memory(addres in src1+src2, value in dst)
		//
		
		//if alu and shift operations are  zeros then bypass EX stage
		//alu operations
		bit				and_op;//AND
		bit				or_op;// OR
		bit				xor_op;//XOR
		bit				add_op;//+
		bit				mul_op;//
		bit				cmp_op;//compare operation
	
		bit				ldrf_op;//conditional load
		//shifter operations
		bit				shl_op;//shift left
		bit				shr_op;//shift  right
		//jmp operations
		//old pc in  value in	val_r1
		//offset to  pc  value in	val_r2
		//new pc value in	val_dst
		//types of jump
		//indicate to calc new address of PC
		bit				jmpunc;
		bit				jmpz;
		bit				jmpnz;
		bit				jmpc;
		bit				jmpnc;
	
	}pipe_struct;

//typedef enum logic[3:0]{
	//operations 
parameter[3:0]	LDR=4'd0;//,//LDR Rdst,[Rsrc1],-+Rsrc2
		//[31:28]LDR_op
	//[27:26] type of LDR op
	//0- Rdst= Rsrc1
	//1-Rdst[31:16] = code[20:5]  LDRH Rx,0x1234
	//2-Rdst[15:0] = code[20:5]    LDRL Rx,0x5678
	//3- Rdst=[Rsrc1+offset]
	//[25]
	//0 - offset = code[24:10](signed)
	//1 - offset = Rsrc2(signed)
	//[24:22]
	//000  Rsrc2=Rsrc2
	//001  Rsrc2=Rsrc2+1
	//010  Rsrc2=Rsrc2+2
	//011  Rsrc2=Rsrc2+4
	//100  Rsrc2=Rsrc2
	//101  Rsrc2=Rsrc2-1
	//110  Rsrc2=Rsrc2-2
	//111  Rsrc2=Rsrc2-4
	//[14:10] src2
	//[9:5]src1
	//[4:0]dst
parameter[3:0]	
	STR=4'd1;//,//STR Rdst,[Rsrc1],-+Rsrc2
		//[31:28]STR_op
	//[27:26] type of STORE op
	//3- [Rsrc1+offset]=Rdst
	//[25]
	//0 - offset = code[24:10](signed)
	//1 - offset = Rsrc2(signed)
	//[24:23]
	//000  Rsrc2=Rsrc2
	//001  Rsrc2=Rsrc2+1
	//010  Rsrc2=Rsrc2+2
	//011  Rsrc2=Rsrc2+4
	//100  Rsrc2=Rsrc2
	//101  Rsrc2=Rsrc2-1
	//110  Rsrc2=Rsrc2-2
	//111  Rsrc2=Rsrc2-4
	//[14:10] src2
	//[9:5]src1
	//[4:0]dst
parameter[3:0]		
	JMPUNC=4'd2;//,//unconditional jump
	//[31:28]  jump
	//[27:26] type of jumps
	//0 - jmp	pc[25:0]=code[25:0] 
	//1 - jmp	pc=pc+offset(relaitive jump)	jmpr	R2(jmpr R2+4)
	//2 - call	pc=pc+offset, Rdst=pc 		callr	R0,0xXXXXXXX,R1+4  or callr R0,R1+4
	//3 - ret	pc=Rdst				ret	Rx or ret Rx,Ry+-0,1,2,4
	//[25]
	//0 - offset = code[24:10](signed)
	//1 - offset = Rsrc2(signed)
	//[24:23]
	//000  Rsrc2=Rsrc2
	//001  Rsrc2=Rsrc2+1
	//010  Rsrc2=Rsrc2+2
	//011  Rsrc2=Rsrc2+4
	//100  Rsrc2=Rsrc2
	//101  Rsrc2=Rsrc2-1
	//110  Rsrc2=Rsrc2-2
	//111  Rsrc2=Rsrc2-4
	//[14:10] src2
	//[9:5]src1
	//[4:0]dst
parameter[3:0]		
	JMPF=4'd3;//,//conditional jumps
	//[31:28]  jump
	//[27:26] type of jumps
	//0 - jmpz	pc=pc+offset
	//1 - jmpnz	pc=pc+offset
	//2 - jmpc	pc=pc+offset
	//3 - jmpnc	pc=pc+offset
	//[25]
	//0 - offset = code[24:10](signed)
	//1 - offset = Rsrc2(signed)
	//[24:22]
	//000  Rsrc2=Rsrc2
	//001  Rsrc2=Rsrc2+1
	//010  Rsrc2=Rsrc2+2
	//011  Rsrc2=Rsrc2+4
	//100  Rsrc2=Rsrc2
	//101  Rsrc2=Rsrc2-1
	//110  Rsrc2=Rsrc2-2
	//111  Rsrc2=Rsrc2-4
	//[14:10] src2
	//[9:5]src1
	//[4:0]dst
	
parameter[3:0]		
	ALU=4'd4;// AND, OR, XOR, 
		// ADD,  MUL,
		// SHR, SHL
	//[31:28]ALU_op
	//[27:25] type of op
	//0- AND
	//1- OR
	//2- XOR
	//3- ADD
	//4- MUL
	//5-shift Rsrc1 left by Rscr2 ...0 MSB->C flag
	//6-shift Rsrc1 right by Rscr2 ...0 LSB ->C flag
	//7-CMP compare, 
	//[24:23]
	//000  Rsrc2=Rsrc2
	//001  Rsrc2=Rsrc2+1
	//010  Rsrc2=Rsrc2+2
	//011  Rsrc2=Rsrc2+4
	//100  Rsrc2=Rsrc2
	//101  Rsrc2=Rsrc2-1
	//110  Rsrc2=Rsrc2-2
	//111  Rsrc2=Rsrc2-4
	//[14:10] src2
	//[9:5]src1
	//[4:0]dst
//} OPCODE;
parameter[3:0]
	LDRF=4'd5;//,//LDRF Rdst,Rsrc1,-+Rsrc2
	//[31:28]LDRF_op
	//[27:26] type of LDRF op
	//0-LDRZ Rdst=Rsrc1 if z=1, otherwise Rdst=Rsrc2
	//1-LDRNZ Rdst=Rsrc1 if z=0, otherwise Rdst=Rsrc2
	//2-LDRC Rdst=Rsrc1 if c=1, otherwise Rdst=Rsrc2
	//3-LDRNC Rdst=Rsrc1 if c=0, otherwise Rdst=Rsrc2
	//[24:22]
	//000  Rsrc2=Rsrc2
	//001  Rsrc2=Rsrc2+1
	//010  Rsrc2=Rsrc2+2
	//011  Rsrc2=Rsrc2+4
	//100  Rsrc2=Rsrc2
	//101  Rsrc2=Rsrc2-1
	//110  Rsrc2=Rsrc2-2
	//111  Rsrc2=Rsrc2-4
	//[14:10] src2
	//[9:5]src1
	//[4:0]dst


parameter[4+1:0]	NOP 	=	{32'h0};
//ldr
parameter[4+1:0]	LDRR 	=	{LDR,2'b00};
parameter[4+6:0] 	LDRH	=	{LDR,7'b01_0_000_0};
parameter[4+6:0] 	LDRL	=	{LDR,7'b10_0_000_0};
parameter[4+1:0] 	LDRP	=	{LDR,2'b11};

//str
parameter[4+1:0] 	STRP	={STR,2'b11};

//alu
parameter[4+2:0] 	AND		={ALU,3'd0};
parameter[4+2:0] 	OR		={ALU,3'd1};
parameter[4+2:0] 	XOR		={ALU,3'd2};
parameter[4+2:0] 	ADD		={ALU,3'd3};
parameter[4+2:0] 	MUL		={ALU,3'd4};
parameter[4+2:0] 	SHL		={ALU,3'd5};
parameter[4+2:0] 	SHR		={ALU,3'd6};
parameter[4+2:0] 	CMP		={ALU,3'd7};

//jmp
parameter[4+1:0] 	JMP		={JMPUNC,2'd0};
parameter[4+1:0] 	JMPR	={JMPUNC,2'd1};
parameter[4+1:0] 	CALL	={JMPUNC,2'd2};
parameter[4+1:0] 	RET		={JMPUNC,2'd3};

parameter[4+1:0] 	JMPZ	={JMPF,2'd0};
parameter[4+1:0] 	JMPNZ	={JMPF,2'd1};
parameter[4+1:0] 	JMPC	={JMPF,2'd2};
parameter[4+1:0] 	JMPNC	={JMPF,2'd3};


parameter[4+2:0] 	LDRZ	={LDRF,2'd0,1'b0};
parameter[4+2:0] 	LDRNZ	={LDRF,2'd1,1'b0};
parameter[4+2:0] 	LDRC	={LDRF,2'd2,1'b0};
parameter[4+2:0] 	LDRNC	={LDRF,2'd3,1'b0};

//common
parameter[0:0] 	OFFSET_CODE	=1'b0;
parameter[0:0] 	OFFSET_R	=1'b1;

parameter[2:0] 	INCR_0		=3'b000;
parameter[2:0] 	DECR_0		=3'b000;
parameter[2:0] 	INCR_1		=3'b001;
parameter[2:0] 	INCR_2		=3'b010;
parameter[2:0] 	INCR_4		=3'b011;
parameter[2:0] 	DECR_1		=3'b101;
parameter[2:0] 	DECR_2		=3'b110;
parameter[2:0] 	DECR_4		=3'b111;

parameter[4:0] 	R0			=5'd0;
parameter[4:0] 	R1			=5'd1;
parameter[4:0] 	R2			=5'd2;
parameter[4:0] 	R3			=5'd3;
parameter[4:0] 	R4			=5'd4;
parameter[4:0] 	R5			=5'd5;
parameter[4:0] 	R6			=5'd6;
parameter[4:0] 	R7			=5'd7;
parameter[4:0] 	R8			=5'd8;
parameter[4:0] 	R9			=5'd9;
parameter[4:0] 	R10			=5'd10;
parameter[4:0] 	R11			=5'd11;
parameter[4:0] 	R12			=5'd12;
parameter[4:0] 	R13			=5'd13;
parameter[4:0] 	R14			=5'd14;
parameter[4:0] 	R15			=5'd15;
parameter[4:0] 	R16			=5'd16;
parameter[4:0] 	R17			=5'd17;
parameter[4:0] 	R18			=5'd18;
parameter[4:0] 	R19			=5'd19;
parameter[4:0] 	R20			=5'd20;
parameter[4:0] 	R21			=5'd21;
parameter[4:0] 	R22			=5'd22;
parameter[4:0] 	R23			=5'd23;
parameter[4:0] 	R24			=5'd24;
parameter[4:0] 	R25			=5'd25;
parameter[4:0] 	R26			=5'd26;
parameter[4:0] 	R27			=5'd27;
parameter[4:0] 	R28			=5'd28;
parameter[4:0] 	R29			=5'd29;
parameter[4:0] 	R30			=5'd30;
parameter[4:0] 	R31			=5'd31;

endpackage

`endif
