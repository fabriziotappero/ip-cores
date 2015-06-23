`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    nCore 
// Author: STEFAN, Istvan
// Published under GPL
//////////////////////////////////////////////////////////////////////////////////
module nCore(IP, DP, In, data_out, data_in, clkin);
	parameter inst_mvA=4'd0;//Move reg to a
	parameter inst_coA=4'd1;//Move constant to a[3:0]
	parameter inst_mvB=4'd2;//Move reg to b
	parameter inst_coB=4'd3;//Move constant to b[3:0]
	parameter inst_csB=4'd4;//b[7:4]<-b[3:0];b[3:0]<-constant
	parameter inst_shl=4'd5;//Shift to left, a<<b->reg,carry->flag,if zero->flag
	parameter inst_shr=4'd6;//Shift to right a>>b->reg,carry->flag,if zero->flag
	parameter inst_and=4'd7;//Aritmetical and a&b->reg,if zero->flag
	parameter inst_orr=4'd8;//Aritmetical or  a|b->reg,if zero->flag
	parameter inst_xor=4'd9;//Aritmetical xor a^b->reg,if zero->flag
	parameter inst_add=4'd10;//Unsigned add    a+b->reg,carry->flag,if zero->flag
	parameter inst_sub=4'd11;//Unsigned sub    a-b->reg,carry->flag,if zero->flag
	parameter inst_int=4'd12;
	parameter inst_ire=4'd13;
	parameter inst_Imv=4'd14;//Move IP to reg
	parameter inst_jmp=4'd15;//Move reg to IP if a[0]

//buswidth constants	
parameter dw=15;
//parameter maxaddrbits=10;
//parameter Dmaxaddrbits=10;

	output [dw:0] IP;
	output [dw:0] DP;
	input [7:0] In;
	output [dw:0] data_out;
	input [dw:0] data_in;
	input clkin;

//Instructions
	wire [7:0] In;
//Sign of the clock
	wire clk;
//Instruction pointer
	reg [dw:0] IP=0;//init to 0
//Data pointer
	wire [dw:0] DP;//init to 0
	//Contact with the data memory
	wire [dw:0] data_in;
	wire [dw:0] data_out;

//Source registers
	reg [dw:0] a=0;
	reg [dw:0] b=0;
//General registers
	reg [dw:0] regs [14:0];
	reg [dw:0] mask;//Register for masking addresses
//Flag register
//	reg [15:0] FLAG=0;//init to 0
	wire [4:0] FLAG_new;
	wire F_pre_add,F_pre_sub,F_pre_shl,F_pre_shr;
//Interrupt
	reg int=1;//We start in interrupt state to allow setting the environement
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
	wire [3:0] w_con;//load constant
//Begin of ALU
	wire F_zero;
assign F_zero=(t==16'h0000);
//assign FLAG_new[0]=((In[7:4]==inst_and)||(In[7:4]==inst_orr)||
//	(In[7:4]==inst_xor)||(In[7:4]==inst_and)||
//	(In[7:4]==inst_sub)||(In[7:4]==inst_shl)||
//	(In[7:4]==inst_shr))?F_zero:regs[13][0];////:FLAG[0];
	assign FLAG_new[0]=((In[7:4]==inst_and)||(In[7:4]==inst_orr)||
	(In[7:4]==inst_xor)||(In[7:4]==inst_and)||
	(In[7:4]==inst_sub)||(In[7:4]==inst_shl)||
	(In[7:4]==inst_shr))?F_zero:regs[13][0];//:FLAG[0];

assign {F_pre_add,w_add}=a+b;
assign {F_pre_sub,w_sub}=a-b;
assign {F_pre_shl,w_shl}=a<<b[3:0];
assign {w_shr,F_pre_shr}=a>>b[3:0];

assign w_and=a&b;
assign w_orr=a|b;
assign w_xor=a^b;
assign w_con=In[3:0];
//End of ALU

//Instruction pointer
always @(negedge clk)
	if ((In[7:4]==inst_jmp)&&(a[0]))
		begin
			if(int)//Using the whole address space is allowed only in interrupt
				IP=c;
			else
				IP={regs[13][15:5],5'b11111}&c;//Masking address DP
//		IP=regs[In[3:0]];
		end
	else if((In[7:4]==inst_int))
		begin
			IP=16;//begin of the code of the interrupt
			int=1;
		end
	else if((In[7:4]==inst_ire))
		begin
			IP=regs[12];
			int=0;
		end
	else
		IP=IP+1;

//Data pointer
assign DP=regs[15];

//Contact with the data memory
assign data_out=regs[14];

//Evaluation of the instructions
/*0-2*/assign t=((In[7:4]==inst_mvA)||(In[7:4]==inst_mvB))&&(In[3:0]==14)?data_in:16'hzzzz;
/*0*/	assign t=(In[7:4]==inst_mvA)?regs[In[3:0]]:16'hzzzz;
/*1*/	assign t=(In[7:4]==inst_coA)?w_con:16'hzzzz;
/*2*/	assign t=(In[7:4]==inst_mvB)?regs[In[3:0]]:16'hzzzz;
/*3*/	assign t=(In[7:4]==inst_coB)?w_con:16'hzzzz;
/*4*/	assign t=(In[7:4]==inst_csB)?{b[11:4],w_con}:16'hzzzz;
/*5*/	assign t=(In[7:4]==inst_shl)?w_shl:16'hzzzz;
   		assign FLAG_new[3]=(In[7:4]==inst_shl)?F_pre_shl:regs[13][3];//FLAG[3];
/*6*/	assign t=(In[7:4]==inst_shr)?w_shr:16'hzzzz;
    		assign FLAG_new[4]=(In[7:4]==inst_shr)?F_pre_shr:regs[13][4];//FLAG[4];
/*7*/	assign t=(In[7:4]==inst_and)?w_and:16'hzzzz;
/*8*/	assign t=(In[7:4]==inst_orr)?w_orr:16'hzzzz;
/*9*/	assign t=(In[7:4]==inst_xor)?w_xor:16'hzzzz;
/*10*/assign t=(In[7:4]==inst_add)?w_add:16'hzzzz;
   		assign FLAG_new[1]=(In[7:4]==inst_add)?F_pre_add:regs[13][1];//FLAG[1];
/*11*/assign t=(In[7:4]==inst_sub)?w_sub:16'hzzzz;
			assign FLAG_new[2]=(In[7:4]==inst_sub)?F_pre_sub:regs[13][2];//FLAG[2];
/*14*/	assign t=(In[7:4]==inst_Imv)?IP:16'hzzzz;

//Implementation of the registres
wire i_mvA;
wire i_mvB;
wire i_mvR;
assign i_mvA=((In[7:4]==inst_mvA)||(In[7:4]==inst_coA))&&clk;
assign i_mvB=((In[7:4]==inst_mvB)||(In[7:4]==inst_coB)||(In[7:4]==inst_csB))&&clk;
assign i_mvR=(
	  (In[7:4]==inst_and)||(In[7:4]==inst_orr)
	||(In[7:4]==inst_xor)||(In[7:4]==inst_add)
	||(In[7:4]==inst_shr)||(In[7:4]==inst_shl)
	||(In[7:4]==inst_sub)||(In[7:4]==inst_Imv)||(In[7:4]==inst_int)
	)&&clk;

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
begin
	FLAG=FLAG_new;
end

always @(negedge i_mvR)//TODO!!!
begin
if(int)
	begin
	if(In[3:0]==15)
		mask=c;
	else
		regs[In[3:0]]=c;
	end
else
	begin
		if(In[7:4]==inst_int)
			regs[12]=IP;
		else begin
			if(In[3:0]<13)
				regs[In[3:0]]=c;
			else
				if(In[3:0]==14)
						regs[14]=mask&c;//Masking address DP
			end
	end
end
//mask:regs[15]
//DP:regs[14]
//data:regs[13]
//retA:regs[12]:address of the return from interrupt
BUFGP U1 (.I(clkin),.O(clk));

endmodule
