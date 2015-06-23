//Jun.30.2004 Mux sentibity list bug fix
//Jul.2.2004 Cleanup
//Jul.7.2004 int bug fix
//Jan.20.2005 apply @*
`include "define.h"
module Pipelined_RegFile(clock,sync_reset,
	dest_addrD2,source_addr,target_addr,	wren,memory_wdata,
      A_Right_SELD1,A_Left_SELD1,PCD1,IMMD1,ALU_FuncD2,Shift_FuncD2,
      Shift_amountD2,RRegSelD1,MOUT,RF_inputD2,alu_source,alu_target,
	MWriteD2,MWriteD1,mul_alu_selD2,mul_div_funcD2,pause_out,
	Shift_Amount_selD2,int_stateD1,PCCDD
	);
    parameter adder_type="GENERIC";
`ifdef RAM4K
	input	[11:0]  PCD1;
`else
	input	[25:0]  PCD1;
`endif
	input     [15:0] IMMD1;//Jul.6.2004
	input	[4:0]  dest_addrD2;
	input	[4:0]  source_addr;
	input	[4:0]  target_addr;
	input	wren;
	input	clock;
	input	A_Left_SELD1;
	input  [3:0] ALU_FuncD2;
	input  [4:0] Shift_amountD2;
	input  [1:0]  Shift_FuncD2;
	input [1:0] A_Right_SELD1;
	input sync_reset;
	input [1:0] RRegSelD1;
	output	[31:0]  alu_target,alu_source;
	output	[31:0]  memory_wdata;
	input [31:0] MOUT;
	input [1:0] RF_inputD2;
	input MWriteD2,MWriteD1;
	input	[1:0] mul_alu_selD2;
	input [3:0]  mul_div_funcD2;
	output pause_out;
	input Shift_Amount_selD2;	
	input int_stateD1;
	
	reg [31:0] AReg,NReg,RReg,DReg;
	reg [31:0] alu_left_latch,alu_right_latch;
	reg [31:0] memory_wdata;

`ifdef RAM4K
	input [11:0] PCCDD;
	reg [11:0] PCD2;
`else
	input [25:0] PCCDD;
	reg [25:0] PCD2;
`endif

	reg [15:0] IMMD2;//Jul.6.2004

	reg [4:0]  dadrD3,dadrD4,dadrD5,dadrD6;
	reg [4:0]  sadrD1,sadrD2;
	reg [4:0]  tadrD1,tadrD2;
	reg WD3,WD4,WD5,WD6;
	reg [1:0] A_Right_SELD2;
	reg [1:0] RRegSelD2,  RRegSelD3, RRegSelD4;
	reg [31:0] RRegin;
	reg test1D,test2D;		
	wire  [31:0] alu_right;
	reg [31:0] alu_left;
	
	wire [31:0] source_out,target_out;
	wire [31:0] alu_out,shift_out;
	wire [31:0] alu_source=alu_left;
	wire [31:0] alu_target=alu_right;
	wire [31:0] regfile_in;
	wire [31:0] test,test2;
	wire test1;

	reg  stest1D,stest2D;
	reg  stest1D_dup1,stest1D_dup2,stest1D_dup3,stest1D_dup4;
	reg [31:0] mul_alu_out;
	reg div_mode_ff;
	reg sign_ff;
	reg RRegSelD4_dup1,RRegSelD4_dup2,RRegSelD4_dup3;


	wire  mul_div_enable,mul_div_sign,mul_div_mode;
	
	wire  [31:0] mul_div_out;
	wire [31:0] c_mult;
	wire [4:0] Shift_Amount;

	localparam [4:0] zero_=0,
				     at_=1,
				     v0_=2,
				     v1_=3,
				     a0_=4,
				     a1_=5,
				     a2_=6,
				     a3_=7,
				     t0_=8, t1_=9,t2_=10,t3_=11,t4_=12,t5_=13,t6_=14,t7_=15,
				     s0_=16,s1_=17,s2_=18,s3_=19,s4_=20,s5_=21,s6_=22,s7_=23,t8_=24,t9_=25,
				     k0_=26,k1_=27,gp_=28,sp_=29,s8_=30,ra_=31;				     





	always @(posedge clock) begin
			
			dadrD3<=dest_addrD2;
			dadrD4<=dadrD3;
			dadrD5<=dadrD4;
			dadrD6<=dadrD5;

			tadrD1<=target_addr;
			tadrD2<=tadrD1;
		
			sadrD1<=source_addr;
			sadrD2<=sadrD1;


			if ( (mul_div_funcD2 ==4'b0000 ) || 
                             (mul_div_funcD2 ==4'b0001 ) ||
                             (mul_div_funcD2 ==4'b0010 ) ) WD3<=wren;//NOTHING,READLO/HI ˆÈŠO‚Å‚Íƒ‰ƒCƒg‚ðŽ~‚ß‚é
			else                    WD3<=1'b0;

			WD4<=WD3;
			WD5<=WD4;
			WD6<=WD5;			

			A_Right_SELD2<=A_Right_SELD1;
		   
			IMMD2<=IMMD1;
			if (int_stateD1) PCD2<=PCCDD;//Jul.7.2004
			else PCD2<=PCD1;


			RRegSelD2<=RRegSelD1;
			RRegSelD3<=RRegSelD2;
			RRegSelD4<=RRegSelD3;
			RRegSelD4_dup1<=RRegSelD3[0];
			RRegSelD4_dup2<=RRegSelD3[0];
			RRegSelD4_dup3<=RRegSelD3[0];

	
	end



//AReg
	always @(posedge clock) begin
	
			case (RF_inputD2) 
				`RF_ALU_sel :     AReg<=alu_out;
				`RF_Shifter_sel:  AReg<=shift_out;
				`SHIFT16_SEL:     AReg<= {IMMD2[15:0],16'h00};
				`RF_PC_SEL :      AReg<=mul_alu_out;
			endcase
	end
	
//ARegSel
	always @(*) begin//Mar.5.2005
			if (! mul_alu_selD2[1] ) mul_alu_out={6'b00_0000,PCD2};
			else  	mul_alu_out=c_mult;
	end
	



//NReg
	always @(posedge clock) 	NReg<=AReg;
	

//RReg
	always @(posedge clock) 	begin
		case (RRegSelD4_dup1) 
				`MOUT_SEL :     RReg<=MOUT;
				`NREG_SEL:      RReg<=NReg;
				default :       RReg<=MOUT;
			endcase
	end

//DReg
	always @(posedge clock) 	begin
					DReg<=RReg;
	end




	always @(*) begin 
			case (RRegSelD4_dup2) 
				`MOUT_SEL :     RRegin=MOUT;
				`NREG_SEL:      RRegin=NReg;
				 default :      RRegin=MOUT;
			endcase
	end
//target_reg
	always @(*) 	memory_wdata=alu_right;

mul_div MulDiv(.clock(clock),.sync_reset(sync_reset),.a(alu_left),.b(alu_right),
			  .mul_div_out(c_mult),.mul_div_sign(mul_div_funcD2[1]),
			  .mul_div_word(1'b1),.mul_div_mode(mul_div_funcD2[2]),
			  .stop_state(pause_out),.mul_div_enable(mul_div_funcD2[3]),.lohi(mul_div_funcD2[0]));

assign mul_div_enable= mul_div_funcD2;
	always @(posedge clock) begin 
		if (sync_reset) div_mode_ff<=1'b0;
		else if (mul_div_enable) div_mode_ff<=mul_div_mode;
	end

	always @(posedge clock) begin
		if (sync_reset) sign_ff<=1'b0; 
		else if (mul_div_enable) sign_ff<=mul_div_sign;
	end

assign mul_div_mode=!(IMMD2[1] ==`MUL_DIV_MUL_SEL);//div high / mul low
assign mul_div_sign=!IMMD2[0];



alu  alu1(.a(alu_left),.b(alu_right),.alu_func(ALU_FuncD2),.alu_out(alu_out));


	
shifter sh1(.a(alu_right),.shift_out(shift_out),.shift_func(Shift_FuncD2),
						.shift_amount(Shift_Amount));

	assign Shift_Amount=Shift_Amount_selD2==`SHIFT_AMOUNT_REG_SEL ?
						alu_left[4:0] : Shift_amountD2;


//alu left latch
	always @(posedge clock) begin
	begin
			if (sadrD1==dadrD4 && WD4) alu_left_latch<=RRegin;
//OK
			else if       (sadrD1==dadrD5 && WD5)   alu_left_latch<=RReg;//This must be priority encoder
			else if	   (sadrD1==dadrD6 && WD6)   alu_left_latch<=DReg;
			else  alu_left_latch<=source_out;
				end
	end


//alu right latch
	always @(posedge clock) begin
	begin
			case (A_Right_SELD1)
				`Imm_signed   :		alu_right_latch<={ {16{IMMD1[15]}},IMMD1[15:0]};
				`Imm_unsigned :		alu_right_latch<={ 16'h000,IMMD1[15:0]};
				`A_RIGHT_ERT  : begin
												
													if (tadrD1==dadrD4 && WD4 ) alu_right_latch<=RRegin;
													else   //OK
														if (tadrD1==dadrD5 && WD5 )  alu_right_latch<=RReg;
														else if (tadrD1==dadrD6 && WD6) alu_right_latch<=DReg;
														else alu_right_latch<=target_out;
					     						end
				`IMM_26_SEL		: begin
													alu_right_latch<={6'b00_0000,IMMD1};
												end
				default 			: alu_right_latch<={ {16{IMMD1[15]}},IMMD1[15:0]};
			endcase
		end
	end
`ifdef ALTERA	
ram_regfile32xx32 RFile(
	.data(regfile_in),
	.wraddress(dadrD5),
	.rdaddress_a(target_addr),
	.rdaddress_b(source_addr),
	.wren(WD5),
	.clock(clock),
	.qa(target_out),
	.qb(source_out));
`else

ram32x32_xilinx  RFile (
	.data(regfile_in),
	.wraddress(dadrD5),
	.rdaddress_a(target_addr),
	.rdaddress_b(source_addr),
	.wren(WD5),
	.clock(clock),
	.qa(target_out),
	.qb(source_out));
`endif
	assign regfile_in=dadrD5==5'b0_0000 ? 32'h0000_0000 :RReg;




	always @* begin //
		case (stest1D_dup1) 
			1'b1: alu_left[7:0]=AReg[7:0];
			1'b0: 
				case(stest2D)
					1'b1:
						case (RRegSelD4_dup3) 
							`MOUT_SEL :     alu_left[7:0]=MOUT[7:0];
							`NREG_SEL:      alu_left[7:0]=NReg[7:0];
						endcase
					1'b0:   alu_left[7:0]=alu_left_latch[7:0];
				endcase
		endcase
	end

      always @* begin //
		case (stest1D_dup2) 
			1'b1: alu_left[15:8]=AReg[15:8];
			1'b0: 
				case(stest2D)
					1'b1:
						case (RRegSelD4_dup3) 
							`MOUT_SEL :     alu_left[15:8]=MOUT[15:8];
							`NREG_SEL:      alu_left[15:8]=NReg[15:8];
						endcase
					1'b0:   alu_left[15:8]=alu_left_latch[15:8];
				endcase
		endcase
	end

always @* begin//
		case (stest1D_dup3) 
			1'b1: alu_left[23:16]=AReg[23:16];
			1'b0: 
				case(stest2D)
					1'b1:
						case (RRegSelD4_dup3) 
							`MOUT_SEL :     alu_left[23:16]=MOUT[23:16];
							`NREG_SEL:      alu_left[23:16]=NReg[23:16];
						endcase
					1'b0:   alu_left[23:16]=alu_left_latch[23:16];
				endcase
		endcase
	end

always @* begin //
		case (stest1D_dup4) 
			1'b1: alu_left[31:24]=AReg[31:24];
			1'b0: 
				case(stest2D)
					1'b1:
						case (RRegSelD4_dup3) 
							`MOUT_SEL :     alu_left[31:24]=MOUT[31:24];
							`NREG_SEL:      alu_left[31:24]=NReg[31:24];
						endcase
					1'b0:   alu_left[31:24]=alu_left_latch[31:24];
				endcase
		endcase
	end




	assign alu_right=test1D ? AReg :
		         test2D ?   RRegin : alu_right_latch;

	always @(posedge clock) begin
			stest1D<=(sadrD1==dest_addrD2) && wren;
			stest1D_dup1<=(sadrD1==dest_addrD2) && wren;
			stest1D_dup2<=(sadrD1==dest_addrD2) && wren;
			stest1D_dup3<=(sadrD1==dest_addrD2) && wren;
			stest1D_dup4<=(sadrD1==dest_addrD2) && wren;

	end
	always @(posedge clock) begin
		stest2D<=(sadrD1==dadrD3) && WD3  ;
	end




	always @(posedge clock) begin
			test1D<=tadrD1==dest_addrD2 && (wren )  && A_Right_SELD1==`A_RIGHT_ERT;
	end

	always @(posedge clock) begin
			test2D<=tadrD1==dadrD3 && (WD3 )  && A_Right_SELD1==`A_RIGHT_ERT;
	end


`ifdef Veritak
	reg [30*8:1] alu_function;
	reg [30*8:1] shift_function;
	reg [30*8:1] AReg_Input_Sel;

	always @*//Jan.20.2005 @(ALU_FuncD2,alu_left,alu_right)
		case (ALU_FuncD2)
			`ALU_NOTHING : $sprintf(alu_function,"non_operation");
			`ALU_ADD        : $sprintf(alu_function,"ADD %h,%h",alu_left,alu_right);
			`ALU_SUBTRACT :$sprintf(alu_function,"SUB %h,%h,alu_left,alu_right");
			`ALU_LESS_THAN_UNSIGNED :$sprintf(alu_function ,"LT_Unsigned %h,%h",alu_left,alu_right);
			`ALU_LESS_THAN_SIGNED   : $sprintf(alu_function,"LT_Signed %h,%h",alu_left,alu_right);
			`ALU_OR   : $sprintf(alu_function,"OR %h,%h",alu_left,alu_right);
			`ALU_AND : $sprintf(alu_function,"XOR %h,%h,alu_left,alu_right");
			`ALU_XOR : $sprintf(alu_function,"AND %h,%h",alu_left,alu_right);
			`ALU_NOR : $sprintf(alu_function,"NOR %h,%h",alu_left,alu_right);
			default: $sprintf(alu_function,"non_operation");
		endcase

	always @* begin //
		case (Shift_FuncD2)
			`SHIFT_LEFT : $sprintf(shift_function,"SLL %d",Shift_Amount);
			`SHIFT_RIGHT_UNSIGNED : $sprintf(shift_function,"SLR %d",Shift_Amount);
			`SHIFT_RIGHT_SIGNED : $sprintf(shift_function,"SAR %d",Shift_Amount);
			default: $sprintf(shift_function,"non_operation");
		endcase
	end	   


	always @* begin //
			case (RF_inputD2) 
				`RF_ALU_sel :     $sprintf(AReg_Input_Sel,"ALU");
				`RF_Shifter_sel:  $sprintf(AReg_Input_Sel,"Shifter");
				`SHIFT16_SEL:     $sprintf(AReg_Input_Sel,"IMM16<<16");
				`RF_PC_SEL :      $sprintf(AReg_Input_Sel,"PC/MulOutSEL");
			endcase
	end


`endif




endmodule