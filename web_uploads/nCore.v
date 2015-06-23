`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    nCore 
// Author: STEFAN, Istvan
// Published under GPL
//////////////////////////////////////////////////////////////////////////////////
module nCore(IP, DP, In, data_out, data_in, clkin);
	parameter inst_mvA=4'd0;
	parameter inst_mvB=4'd1;
	parameter inst_shl=4'd2;
	parameter inst_shr=4'd3;
	parameter inst_and=4'd4;
	parameter inst_orr=4'd5;
	parameter inst_xor=4'd6;
	parameter inst_add=4'd7;
	parameter inst_sub=4'd8;
	parameter inst_Fmv=4'd9;
	parameter inst_mvD=4'd10;
	parameter inst_coB=4'd11;
	parameter inst_mvP=4'd12;
	parameter inst_jmp=4'd13;
	parameter inst_coA=4'd14;
	parameter inst_Dmv=4'd15;

//buswidth constants	
parameter dw=15;
parameter maxaddrbits=10;
parameter Dmaxaddrbits=10;

	output [maxaddrbits:0] IP;
	output [Dmaxaddrbits:0] DP;
	input [7:0] In;
	output [dw:0] data_out;
	input [dw:0] data_in;
	input clkin;

//Instructions
	wire [7:0] In;
//Sign of the clock
	wire clk;
//Instruction pointer
	reg [maxaddrbits:0] IP=0;//init to 0
//Data pointer
	reg [Dmaxaddrbits:0] DP=0;//init to 0
	//Contact with the data memory
	wire [dw:0] data_in;
	wire [dw:0] data_out;

//Source registers
	reg [dw:0] a=0;
	reg [dw:0] b=0;
//General registers
	reg [dw:0] regs [15:0];
//Flag register
	reg [4:0] FLAG=0;//init to 0
	wire [4:0] FLAG_new;
	wire F_pre_add,F_pre_sub,F_pre_shl,F_pre_shr;
//Wire of results
	wire [dw:0] t;
//Temp reg of results
	reg [dw:0] c;
//The wires of part results
	wire [dw:0] w_add;
	wire [dw:0] w_sub;
	wire [dw:0] w_shl;//shift to left
	wire [dw:0] w_shr;//shift to right
	wire [dw:0] w_and;
	wire [dw:0] w_orr;
	wire [dw:0] w_xor;
	wire [dw:0] w_con;//load constant
//Begin of ALU
	wire F_zero;
assign F_zero=(t==16'h0000);
assign FLAG_new[0]=((In[7:4]==inst_and)||(In[7:4]==inst_orr)||
	(In[7:4]==inst_xor)||(In[7:4]==inst_and)||
	(In[7:4]==inst_sub)||(In[7:4]==inst_shl)||
	(In[7:4]==inst_shr))?F_zero:FLAG[0];

assign {F_pre_add,w_add}=a+b;
assign {F_pre_sub,w_sub}=a-b;
assign {F_pre_shl,w_shl}=a<<b[3:0];
assign {w_shr,F_pre_shr}=a>>b[3:0];

assign w_and=a&b;
assign w_orr=a|b;
assign w_xor=a^b;
assign w_con={12'h000,In[3:0]};
//End of ALU

//Instruction pointer
always @(negedge clk)
	if ((In[7:4]==inst_jmp)&&(a[0]))
		IP=regs[In[3:0]];
	else 
		IP=IP+1;

wire i_mvP;
assign i_mvP=((In[7:4]==inst_mvP)&&~clk);

//Data pointer
always @(posedge i_mvP)
	DP=t;

//Contact with the data memory
wire i_mvD;
assign i_mvD=(In[7:4]==inst_mvD)&&~clk;
	assign data_out=(i_mvD)?t:data_in;

//Evaluation of the instructions
	assign t=(In[7:4]==inst_mvA)?regs[In[3:0]]:16'hzzzz;
	assign t=(In[7:4]==inst_mvB)?regs[In[3:0]]:16'hzzzz;
	assign t=(In[7:4]==inst_shl)?w_shl:16'hzzzz;
		assign FLAG_new[3]=(In[7:4]==inst_shl)?F_pre_shl:FLAG[3];
	assign t=(In[7:4]==inst_shr)?w_shr:16'hzzzz;
		assign FLAG_new[4]=(In[7:4]==inst_shr)?F_pre_shr:FLAG[4];
	assign t=(In[7:4]==inst_and)?w_and:16'hzzzz;
	assign t=(In[7:4]==inst_orr)?w_orr:16'hzzzz;
	assign t=(In[7:4]==inst_xor)?w_xor:16'hzzzz;
	assign t=(In[7:4]==inst_add)?w_add:16'hzzzz;
		assign FLAG_new[1]=(In[7:4]==inst_add)?F_pre_add:FLAG[1];
	assign t=(In[7:4]==inst_sub)?w_sub:16'hzzzz;
		assign FLAG_new[2]=(In[7:4]==inst_sub)?F_pre_sub:FLAG[2];
	assign t=(In[7:4]==inst_Dmv)?data_in:16'hzzzz;
	assign t=(In[7:4]==inst_Fmv)?FLAG:16'hzzzz;
	assign t=(In[7:4]==inst_mvD)?regs[In[3:0]]:16'hzzzz;
	assign t=(In[7:4]==inst_coB)?w_con:16'hzzzz;
	assign t=(In[7:4]==inst_coA)?w_con:16'hzzzz;
	assign t=(In[7:4]==inst_mvP)?regs[In[3:0]]:16'hzzzz;

//Implementation of the registres
wire i_mvA;
wire i_mvB;
wire i_mvR;
assign i_mvA=((In[7:4]==inst_mvA)||(In[7:4]==inst_coA))&&clk;
assign i_mvB=((In[7:4]==inst_mvB)||(In[7:4]==inst_coB))&&clk;
assign i_mvR=((In[7:4]==inst_Dmv)
	||(In[7:4]==inst_and)||(In[7:4]==inst_orr)
	||(In[7:4]==inst_xor)||(In[7:4]==inst_add)
	||(In[7:4]==inst_shr)||(In[7:4]==inst_shl)
	||(In[7:4]==inst_sub)||(In[7:4]==inst_Fmv))&&clk;

//First source register
always @(negedge i_mvA)
	a=c;

//Second source register
always @(negedge i_mvB)
	b=c;

//Keep the result
always @(negedge clk)
	c=t;

always @(posedge clk)
	FLAG=FLAG_new;

always @(negedge i_mvR)
	regs[In[3:0]]=c;

BUFGP U1 (.I(clkin),.O(clk));


endmodule
