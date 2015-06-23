//Jun.2.2004
//Jun.27.2004
//Jun.28.2004
//Jun.30.2004 mulfunc output bug fix
//			   still 16x16 sign extension
//Jul.2.2004  mul 32x32=>64bit w/ w/o sign
//Jul.2.2004  address MUL_WIDTH==1
//Jul.4.2004  input critical path : => add carry_ff;
//Jul.5.2004  				 :=> less fanout 
//Jul.13.2004 signed mul bug fix
//Jul.15.2004 32/32 div 
//Jul.16.2004 diet
//Jul.17.2004 add `ifdef less path delay for interface port
//Apr.7.2005 ADDRESS to XILINX Specific problem 
//Apr.14.2005 Add Stratix2

// mul/div module

// a[31:0] /b[31:0]  =>  
//   mul_div_out[15:0]  <=a/b
//   mul_div_out[31:16] <=a%b
// No detection of overflow
// Algorithm
//  answer_reg = (answer_reg << 1);
// multout_reg<={sum,a_reg[31]};
//    if (multout_reg >= b_reg) {
//       answer_reg += 1;
//       multout_reg -= b_reg;
//    }
//    a_reg <= a_reg << 1;
`include "define.h"
module mul_div(clock,sync_reset,a,b,mul_div_out,mul_div_sign,mul_div_word,mul_div_mode,state,stop_state,mul_div_enable,lohi);
`ifdef RAM4K

	 `ifdef XILINX
		parameter MUL_WIDTH=16;//Must be 2,4,8,16 2=> less area less speed 16=> greater area but faster
		parameter MUL_STATE_MSB=2;//should be 32/MUL_WIDTH-1+1;
		// XILINX fails using ISE7.1 if MUL_WIDTH==1,2
		// if MULWIDTH==1 synthesis is possible but post synthesis simulation fails
            // if MULWIDTH==2 synthesis fails;
            // MUL_WIDTH==16 shows good.

	 `else
			parameter MUL_WIDTH=1;//Must be 2,4,8,16 2=> less area less speed 16=> greater area but faster
			parameter MUL_STATE_MSB=32;//should be 32/MUL_WIDTH-1+1;
	 `endif
`else
	`ifdef XILINX
		parameter MUL_WIDTH=16;//Must be 2,4,8,16 2=> less area less speed 16=> greater area but faster
		parameter MUL_STATE_MSB=2;//should be 32/MUL_WIDTH-1+1;
		// XILINX fails using ISE7.1 if MUL_WIDTH==1,2
		// if MULWIDTH==1 synthesis is possible but post synthesis simulation fails
   		 // if MULWIDTH==2 synthesis fails;
             // MUL_WIDTH==16 shows good.

	 `else
		`ifdef Stratix2
					parameter MUL_WIDTH=16;//Must be 2,4,8,16 2=> less area less speed 16=> greater area but faster
					parameter MUL_STATE_MSB=2;//should be 32/MUL_WIDTH-1+1;
			`else 
					parameter MUL_WIDTH=1;//Must be 2,4,8,16 2=> less area less speed 16=> greater area but faster
					parameter MUL_STATE_MSB=32;//should be 32/MUL_WIDTH-1+1;
			`endif
		`endif
`endif
	input clock,sync_reset;
	input [31:0] a,b;
	input [7:0] state;
	input lohi;
	input mul_div_enable,mul_div_sign,mul_div_word,mul_div_mode;
	output stop_state;
	output [31:0] mul_div_out;
	
	reg [31:0] a_reg;
	reg [31:0] b_reg;
	reg [31:0] answer_reg;
	
	reg stop_state_reg;// For state control
	reg [5:0] counter;
	reg mul_div_sign_ff,mul_div_mode_ff;
	reg a31_latch,b31_latch;
	reg breg31;
//mult64
	wire [63:0] ab62={1'b0,a_reg[31]*breg31,62'h0};//Jul.5.2004
	wire [63:0] shift_a31=mul_div_sign_ff  ? ~{2'b0,a_reg[30:0],31'h0}+1'b1: {2'b0,a_reg[30:0],31'h0} ;//Jul.13.2004 Jul.2.2004
	wire [63:0] shift_b31=mul_div_sign_ff  ? ~{2'b0,b_reg[30:0],31'h0}+1'b1: {2'b0,b_reg[30:0],31'h0};//Jul.13.2004 Jul.2.2004

	wire [30:0] init_lower  =breg31*shift_a31[30:0] +a_reg[31]*shift_b31[30:0]+ab62[30:0];//Jul.5.2004
	wire [63:31] init_upper=breg31*shift_a31[63:31]+a_reg[31]*shift_b31[63:31]+ab62[63:31];//+carry;Jul.5.2004
	wire [63:0] init_val={init_upper,init_lower};
	wire [MUL_WIDTH+30    :0] mult32x4out_temp=a_reg[30:0]*b_reg[MUL_WIDTH-1:0];//Jul.5.2004		
	wire [MUL_WIDTH+31 :0] mult32x4out={1'b0,mult32x4out_temp};
	reg [63:0] mult64_reg;
	reg [31:0] multout_reg;
	wire [63:0] mult64_out;
	wire  [63:0] mult64=a_reg* b_reg;
	reg  [MUL_WIDTH+31-1+1 :0] mult32x4out_reg;


	wire finish_operation;
	wire pre_stop;
	wire [32:0] sum;
	wire [31:0] answer_inc;
	wire [31:0] aminus=-a;
	wire [31:0] div_out,div_out_tmp;
	
	
	wire mul_div_mode_w;
	reg mul_state_reg;
	reg div_msb_ff;	

	assign mul_div_mode_w=pre_stop ? mul_div_mode: mul_div_mode_ff;

`ifdef RAM4K
//less area
		
	assign mul_div_out=!lohi ?  !mul_div_mode_ff ?  mult64_out[31:0] : div_out  : 
					  !mul_div_mode_ff ? mult64_out[63:32]  :	div_out;//Jul.16.2004	

	assign div_out_tmp=!lohi ? answer_reg: {div_msb_ff,multout_reg[31:1]};
	assign div_out= (!lohi && (a31_latch ^ b31_latch)  &&  mul_div_sign_ff) || 
					   (lohi && mul_div_sign_ff && a31_latch) ? ~div_out_tmp+1'b1 : div_out_tmp;

`else

// faster
	reg [31:0] div_out_multout_latch,answer_reg_latch;//

	assign mul_div_out=!lohi ?  !mul_div_mode_ff ? mult64_out[31:0]   : answer_reg_latch  : 
				    !mul_div_mode_ff ? mult64_out[63:32]  : div_out_multout_latch;//Jul.16.2004	
	 


	always @(posedge clock) begin
		if ( (a31_latch ^ b31_latch)  &&  mul_div_sign_ff) 
			answer_reg_latch<=~answer_reg+1'b1;
		else    answer_reg_latch<= answer_reg;

		if  ( mul_div_sign_ff && a31_latch) 
			div_out_multout_latch<=~{div_msb_ff,multout_reg[31:1]}+1'b1;
		else div_out_multout_latch<={div_msb_ff,multout_reg[31:1]};
		

	end
		

`endif

//mul64
	//mul_state 
	always @(posedge clock) begin
		 breg31<=b[31];
	end
	always @(posedge clock) begin
		mult32x4out_reg<=mult32x4out;
	end

//Jul.16.2004
	always @(posedge clock) begin
		if (sync_reset) mul_state_reg<=0;
		else if (pre_stop && mul_div_mode_w==`MUL_DIV_MUL_SEL )	mul_state_reg<=1;
		else if (finish_operation) mul_state_reg<=0; 
	end

	//mult64_reg multout_reg
	always @(posedge clock) begin
		if (mul_state_reg && counter==0 )begin
				mult64_reg<=init_val;//Jul.13.2004 Jul.5.2004 Jul.4.2004
		end
		else 
			if (mul_state_reg) begin  
						{mult64_reg,multout_reg[31:31-MUL_WIDTH+1]}<={{MUL_WIDTH {1'b0}},mult64_reg+mult32x4out_reg};
						multout_reg[31-MUL_WIDTH:0] <=multout_reg[31:MUL_WIDTH];
	
		//Division
		end  else if (pre_stop && counter==0 ) multout_reg<=0; //First
		else if (mul_div_mode_ff && stop_state_reg ) begin
				if (sum[32]==1'b0) begin //if (a_reg >=b_reg)
					if (finish_operation) div_msb_ff<=sum[31];
							multout_reg<={sum,a_reg[31]};
    				end else begin 
					if (finish_operation) div_msb_ff<=multout_reg[31];
					multout_reg[0]<=a_reg[31];
					multout_reg[31:1] <=multout_reg[30:0];
				end
		end
	end

	assign mult64_out={mult64_reg[31:0],multout_reg[31:0]};
//input FFs

	always @(posedge clock) begin
		if (sync_reset) begin
			mul_div_sign_ff<=0;
			mul_div_mode_ff<=0;


		end else if (pre_stop) begin
			mul_div_sign_ff<=mul_div_sign;
			a31_latch<=a[31];
			b31_latch<=b[31];			
			mul_div_mode_ff<=mul_div_mode;
		end
	end



//state_machine
	assign pre_stop=mul_div_enable ;
	assign finish_operation=(mul_div_mode_ff && counter==32) || (mul_state_reg && counter==MUL_STATE_MSB) ;//Jul.2.2004
			

	always @(posedge clock) begin
		if (sync_reset) stop_state_reg <=0;
		else if (pre_stop && !stop_state_reg )  stop_state_reg<=1;
		else if (stop_state_reg && finish_operation) stop_state_reg<=0;  
	end

	assign stop_state=stop_state_reg;

	always @(posedge clock) begin
		if (sync_reset) counter <=0;
		else if (!stop_state_reg) counter <=0;
		else if (stop_state_reg ) counter <=counter+1;
	end

//a_reg
	always @(posedge clock) begin
		if(mul_div_mode_w==`MUL_DIV_MUL_SEL && pre_stop)  a_reg <=a;//
			else if(mul_div_mode_w !=`MUL_DIV_MUL_SEL )begin//
			if (!stop_state_reg && !pre_stop) a_reg <=a_reg;//
 			else if (pre_stop && counter==0  ) begin //
				if (mul_div_sign) begin//
					if (a[31])       a_reg <=aminus;//
							else a_reg <=a;
				end else  a_reg <=a;//
			end else begin//div 
							a_reg <={a_reg[30:0],1'b0};// a_reg <<=1;
			end
			
		end
	end

//b_reg
	always @(posedge clock) begin
		if (pre_stop && mul_div_mode_w==`MUL_DIV_MUL_SEL )	b_reg<={1'b0,b[30:0]};
		else if ( mul_state_reg) b_reg<=b_reg[31:MUL_WIDTH];
				else if( mul_div_mode_w !=`MUL_DIV_MUL_SEL) begin//
			if (!stop_state_reg && !pre_stop ) b_reg <=b_reg;//
 			else if (pre_stop && counter==0 ) begin //
				if (mul_div_sign) begin//
					if ( b[31])  b_reg <=-b[31:0];//
							else  b_reg <=b[31:0];//
				end else begin
					b_reg <=b[31:0];//
				end
			end else begin//div 
					b_reg <=b_reg;//;
			end
		end
	 end

//answer_reg
	always @(posedge clock) begin

		if (mul_div_mode_w !=`MUL_DIV_MUL_SEL) begin//
			if (!stop_state_reg && !pre_stop) answer_reg <=answer_reg;//
			else if (pre_stop && counter==0  ) answer_reg<=0; //
			else  begin//div 
				if ( !sum[32] ) begin//
						if (finish_operation) answer_reg <=answer_inc;
						else answer_reg <={answer_inc[30:0],1'b0};   //Jun.7.2004  a_reg -= b_reg
				end else begin
						if  (finish_operation ) begin
							answer_reg <=answer_reg;
					 end else answer_reg <={answer_reg[30:0],1'b0};   // answer_reg <<=1;
				end
			end
		end
	 end


	assign sum={1'b0,multout_reg}+~{1'b0,b_reg}+1'b1;//
	assign answer_inc=answer_reg+1'b1;//Jun.7.2004

endmodule

