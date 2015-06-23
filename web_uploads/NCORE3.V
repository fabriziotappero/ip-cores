`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    nCore 
// Author: STEFAN, Istvan
// Published under GPL
// With exceptions and address masking for multitasking
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
	reg [dw:0] DP=0;//init to 0
	//Contact with the data memory
	wire [dw:0] data_in;
	wire [dw:0] data_out;

//WDT of 1^20 tick defined at IP counting
//	reg [19:0] wdt=0;//what kind of size? Could/should we change at runtime?
//Source registers
	reg [dw:0] a=0;
	reg [dw:0] b=0;
//General registers
	reg [dw:0] regs [12:0];
	reg [dw:0] mask;//Register for masking addresses
	wire [dw:0] Dmask;//Mask for data address masking
	wire [dw:0] Imask;//Mask for instruction address masking
//Flag register
	reg [9:0] FLAG=0;//init to 0
	wire [9:0] FLAG_new;
	wire F_zero,F_pre_add,F_pre_sub,F_pre_shl,F_pre_shr;
//Interrupt
	reg int=1;//We start in interrupt state to allow setting the environement
//Temp reg of results
	reg [dw:0] c;
//The wires of part results
	wire inst_ALU;//We have an alu-instruction in In[7:4]
	wire [dw:0] w_add;
	wire [dw:0] w_sub;
	wire [dw:0] w_shl;//shift to left
	wire [dw:0] w_shr;//shift to right
	wire [dw:0] w_and;
	wire [dw:0] w_orr;
	wire [dw:0] w_xor;
	wire [3:0] w_con;//load constant
//Begin of ALU

assign {F_pre_add,w_add}=a+b;
assign {F_pre_sub,w_sub}=a-b;
assign {F_pre_shl,w_shl}=a<<b[3:0];
assign {w_shr,F_pre_shr}=a>>b[3:0];

assign w_and=a&b;
assign w_orr=a|b;
assign w_xor=a^b;
assign w_con=In[3:0];

assign inst_ALU=((In[7:4]==inst_and)||(In[7:4]==inst_orr)
	||(In[7:4]==inst_xor)||(In[7:4]==inst_add)
	||(In[7:4]==inst_shr)||(In[7:4]==inst_shl)
	||(In[7:4]==inst_sub));

//End of ALU

//WDT
	reg [19:0] wdt=0;//what kind of size? Could/should we change at runtime?

//Instruction pointer
always @(negedge clk)
	if ((In[7:4]==inst_jmp)&&(a[0]))
		begin
			if(int)//Using the whole address space is allowed only in interrupt
				IP=c;
			else
				IP=Imask&c;//Masking IP address
		end
	else if((In[7:4]==inst_int)||(wdt==20'hFFFFF))//if wdt runned over, 
		//we can decide what to do:switch to the next task or kill the current task
		//																		(was not cooperativ)
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
		IP=IP+1;//Adder!


always @(posedge clk)
begin
	if(In[7:4]==inst_int)//Every int call is a possible task-switch
		wdt=0;
	else
		wdt=wdt+1;
end

//Contact with the data memory
assign data_out=(inst_ALU||(In[7:4]==inst_Imv))&(In[3:0]==14)&~clk?c:data_in;

//Setting the flags
	assign F_zero=(c==16'h0000);

	assign FLAG_new[0]=inst_ALU?F_zero:FLAG[0];
	assign FLAG_new[3]=(In[7:4]==inst_shl)?F_pre_shl:FLAG[3];
	assign FLAG_new[4]=(In[7:4]==inst_shr)?F_pre_shr:FLAG[4];
	assign FLAG_new[1]=(In[7:4]==inst_add)?F_pre_add:FLAG[1];
	assign FLAG_new[2]=(In[7:4]==inst_sub)?F_pre_sub:FLAG[2];
	assign FLAG_new[5]=(wdt==20'hFFFFF);//WDT overflow
	assign FLAG_new[6]=((~clk)&&(~int)&&((inst_ALU)||(In[7:4]==inst_Imv))
				&&(mask[1]))?//IP page mismatch//We aren't in int
			((Imask&IP)!=(Imask&c))
			:FLAG[6];
	assign FLAG_new[7]=((~clk)&&(~int)&&((inst_ALU)||(In[7:4]==inst_Imv))
				&&(mask[2]))?//DP page mismatch
			((Dmask&DP)!=(Dmask&c))
			:FLAG[7];
	assign FLAG_new[8]=((~clk)&&(~int)&&(mask[0])&&//Restricted reg utilisation
			(inst_ALU||(In[7:4]==inst_Imv)//Restricted reg write
			||(In[7:4]==inst_mvA)||(In[7:4]==inst_mvB)
			||(In[7:4]==inst_jmp)))?//Restricted reg read
			((In[3:0]>8)&&(In[3:0]<13)):FLAG[8];//If this is restricted reg, and we are in preemptiv mode

	assign FLAG_new[9]=(In[7:4]==inst_int);//Interrupt call
	

//Implementation of the registres
wire i_mvA;
wire i_mvB;
wire i_mvR;
assign i_mvA=((In[7:4]==inst_mvA)||(In[7:4]==inst_coA))&&clk;
assign i_mvB=((In[7:4]==inst_mvB)||(In[7:4]==inst_coB)||(In[7:4]==inst_csB))&&clk;
assign i_mvR=(inst_ALU||(In[7:4]==inst_Imv)||(In[7:4]==inst_int))&&clk;

//First source register
always @(negedge i_mvA)
		a=c;

//Second source register
always @(negedge i_mvB)
		b=c;

//Keep the result
always @(negedge clk)
		case (In[7:4])
			//inst_mvA
			inst_coA: c=w_con;
			//inst_mvB
			inst_coB: c=w_con;
			inst_csB: c=w_con;
			inst_shl: c=w_shl;
			inst_shr: c=w_shr;
			inst_and: c=w_and;
			inst_orr: c=w_orr;
			inst_xor: c=w_xor;
			inst_add: c=w_add;
			inst_sub: c=w_sub;
			//inst_int
			//inst_ire
			inst_Imv: c=IP;
			//inst_jmp
			default:
				case (In[3:0])
					15: c=FLAG;
					14: c=data_in;
					13: c=DP;
					default:
						c=regs[In[3:0]];
				endcase
		endcase
		
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
	if(In[3:0]==13)
		DP=c;
	else
		regs[In[3:0]]=c;
	end
else
	begin
//Handle the exceptions
		if((In[7:4]==inst_int)||(wdt==20'hFFFFF))
		begin
			regs[12]=IP;
			regs[11]=FLAG_new;
			regs[10]=a;
			regs[9]=b;
		end	
		else begin
			if(In[3:0]<13)//Comparator!
				regs[In[3:0]]=c;
			else
				if(In[3:0]==13)
						DP=Dmask&c;//Masking DP address
			end
	end
end

//Setting the masks
assign Dmask=32'hFFFF0000>>mask[11:8];
assign Imask=32'hFFFF0000>>mask[7:4];
//regs[15] mask on write in interrupt/ FLAG on read
//data:regs[14]
//DP:regs[13]
//retA:regs[12]:address of the return from interrupt
//Exceptions:
//		mask[0]:1->preemptive, 0->cooperative task
//		mask[1]:page fault, code section (IP)
//		mask[2]:page fault, data section (DP)
//		mask[3]:
BUFGP U1 (.I(clkin),.O(clk));

endmodule
