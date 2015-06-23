//Jun.30.2004 NOP_DISABLE BUG FIX
`include "define.h"
module pc_module(clock,sync_reset,pc_commandD1,PCC,imm,ea_reg_source,takenD2,
	takenD3 ,branchQQ,jumpQ,NOP_Signal,control_state,IMMD1, PCCDD);
	input clock;
	input sync_reset;
	input [31:0] ea_reg_source;
	input [2:0] pc_commandD1;
	input takenD2;
	input [25:0] imm;
	input [25:0] IMMD1;
`ifdef RAM4K
	output [11:0] PCC;
`else
	output [25:0] PCC;
`endif


	input takenD3;
	input  branchQQ,jumpQ;
	input NOP_Signal;
	input [7:0] control_state;
	
	reg [2:0] pc_commandD2,pc_commandD3;

`ifdef RAM4K
	reg [11:0] PC;
	reg [11:0] pcimm1D1,pcimm2D1;
	reg [15:0] immD1;//
	reg [11:0] pcimm1D2,pcimm2D2,pcimm2D3;
	reg [11:0] save_pc;
	wire [11:0] PCC;
	output [11:0] PCCDD;
	reg [11:0] PCCD,PCCDD;
`else
	reg [25:0] PC;
	reg [25:0] pcimm1D1,pcimm2D1;
	reg [15:0] immD1;// 
	reg [25:0] pcimm1D2,pcimm2D2,pcimm2D3;
	reg [25:0] save_pc;
	wire [25:0] PCC;
	output [25:0] PCCDD;
	reg [25:0] PCCD,PCCDD;
	
`endif

	reg takenD4;
	reg branchQQQtakenD4;



//combination
	
	always@(posedge clock) PCCD<=PCC;
	always@(posedge clock) PCCDD<=PCCD;


	always @(posedge clock) begin
			pc_commandD2 <=pc_commandD1;

	end
//
	always @(posedge clock) begin
		if (NOP_Signal) pc_commandD3<=3'b000;//Jun.30.2004
		else 	pc_commandD3 <=pc_commandD2;

	end

	always @(IMMD1 ) begin
		pcimm1D1={IMMD1,2'b00};//Jul.7.2004 {imm[23:0],2'b00};//+{PC[25:2],2'b00};
		
	end
	

`ifdef RAM4K
	always @(posedge clock) begin
		pcimm2D1<={PC[11:2],2'b00};
	end
`else

	always @(posedge clock) begin
		pcimm2D1<={PC[25:2],2'b00};
	end

`endif

	always @(posedge clock) begin
		 pcimm1D2<=pcimm1D1;
		
	end

	always @(posedge clock) begin

			pcimm2D2<={{8 {immD1[15]}},immD1[15:0],2'b00}+pcimm2D1;//Jul.14.2004
	end
	always @(posedge clock) begin
		 pcimm2D3<=pcimm2D2;
	end


	always @(posedge clock) begin
		 immD1<=imm[15:0];//Jul.14.2004
	end


	always @(posedge clock) begin
		if (control_state==8'b00_000_010) save_pc<=PCCDD;
	end





	always @(posedge clock) begin
		if (sync_reset) PC<=26'h0_00_0000_0000;

		else if (branchQQQtakenD4) PC<=pcimm2D3+4;//NOP
		else if (jumpQ && !NOP_Signal) PC<=pcimm1D1+4;

		else if (pc_commandD3==`PC_REG) PC<=ea_reg_source[25:0]+4;
		else if (control_state[2:0]==3'b110) PC<=save_pc+4;//mul/div	
		else  case(pc_commandD1) 
						`PC_INC:        PC<=PC+4;
						default:        PC<=PC+4;
			     endcase
		
			

	end
	always @(posedge clock) begin
		if (sync_reset) takenD4<=1'b0;
		else	takenD4<=takenD3;

	end

	always @(posedge clock) begin
		if (sync_reset) branchQQQtakenD4<=1'b0;
		else		branchQQQtakenD4<=branchQQ && takenD3;
	end

	assign PCC=  branchQQQtakenD4  ? pcimm2D3 :
				jumpQ  && !NOP_Signal ? pcimm1D1 :
				pc_commandD3==`PC_REG ?   ea_reg_source[25:0] :
				control_state[2:0] ==3'b110 ? save_pc:PC;//Jun.27.2004

endmodule