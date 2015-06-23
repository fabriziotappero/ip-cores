`include "../define.v"

/*********************************************************************
							
	File: arbiter.v 
	
	Copyright (C) 2013  Alireza Monemi

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
	
	Purpose:
	round robin bcd out arbiter 
	round robin one hot out arbiter
	fixed priority bcd out arbiter
	fixed priority one hot out arbiter
	
	Info: monemi@fkegraduate.utm.my

	*******************************************************/
	
	
	
	/**************************************************
	round robin BCD out arbiter

	****************************************************/
module bcd_arbiter #(
	parameter ARBITER_WIDTH	=4,
	parameter ARBITER_BCD_WIDTH= log2(ARBITER_WIDTH)
)
(
	input		[ARBITER_WIDTH-1 			:	0]	request,
	output	[ARBITER_BCD_WIDTH-1		:	0]	grant,
	output											any_grant,
	input												clk,
	input												reset
	
);
`LOG2

	generate 
	if(ARBITER_WIDTH<= 4) begin
		my_bcd_arbiter #(
			.ARBITER_WIDTH	(ARBITER_WIDTH)
		)
		my_bcd_arbiter
		(
		.request		(request),
		.grant		(grant),
		.any_grant	(any_grant),
		.clk			(clk),
		.reset		(reset)
		);
	end else begin 
		two_level_bcd_arbiter #(
			.ARBITER_WIDTH	(ARBITER_WIDTH)
		)
		my_two_level_bcd_arbiter
			(
			.request		(request),
			.grant		(grant),
			.any_grant	(any_grant),
			.clk			(clk),
			.reset		(reset)
			
		);
	end
	endgenerate
endmodule



module my_bcd_arbiter #(
	parameter ARBITER_WIDTH	=8,
	parameter ARBITER_BCD_WIDTH= log2(ARBITER_WIDTH)
)
(
	input		[ARBITER_WIDTH-1 			:	0]	request,
	output	[ARBITER_BCD_WIDTH-1		:	0]	grant,
	output											any_grant,
	input												clk,
	input												reset
);
	`LOG2
	reg 	[ARBITER_BCD_WIDTH-1		:	0] 	low_pr;
	
	always@(posedge clk or posedge reset) begin
		if(reset) begin
			low_pr	<=	{ARBITER_BCD_WIDTH{1'b0}};
		end else begin
			if(any_grant) low_pr <= grant;
		end
	end
	

	assign any_grant = | request;

	generate 
		if(ARBITER_WIDTH	==2) 		arbiter_2_bcd arb( .in(request) , .out(grant), .low_pr(low_pr));
		if(ARBITER_WIDTH	==3) 		arbiter_3_bcd arb( .in(request) , .out(grant), .low_pr(low_pr));
		if(ARBITER_WIDTH	==4) 		arbiter_4_bcd arb( .in(request) , .out(grant), .low_pr(low_pr));
	endgenerate

endmodule

 
 
 /*******************************************
 
 round-robin bcd-out arbiter using two fixed priority bcd arbiter 
 
 ********************************************/
 
 module two_level_bcd_arbiter #(
	parameter ARBITER_WIDTH	=4,
	parameter ARBITER_BCD_WIDTH= log2(ARBITER_WIDTH)
)
(
	input		[ARBITER_WIDTH-1 			:	0]	request,
	output	[ARBITER_BCD_WIDTH-1		:	0]	grant,
	output											any_grant,
	input												clk,
	input												reset
	
);
 `LOG2
 wire	[ARBITER_BCD_WIDTH-1		:	0]	grant1,grant2;
 wire [ARBITER_WIDTH-1 			:	0]	request2;
 wire sel;
 reg	[ARBITER_WIDTH-1 			:	0]	mask,mask_next;
 
 
 assign request2 = request& mask;
 assign grant = (sel)? grant2 : grant1;
 
 
 always@(posedge clk or posedge reset) begin
			if(reset)				mask <= {ARBITER_WIDTH{1'b1}};
			else if(any_grant) 	mask	<= mask_next;
end //always
		
		
		
 genvar i;
 generate 
	for(i=0;i<ARBITER_WIDTH;i=i+1) begin : loop
		always@(*) begin
			mask_next[i] <=  (grant < i)? 1'b1: 1'b0;
		end //always
	end //for
 endgenerate
 
 
 
 
 
fixed_priority_bcd_arbiter #(
	.IN_WIDTH		(ARBITER_WIDTH)
	)
	first_arbiter
	(
	 .request	(request), 
    .grant	(grant1),
	 .any_grant	(any_grant)
	);
 
 
 fixed_priority_bcd_arbiter #(
	.IN_WIDTH		(ARBITER_WIDTH)
	)
	second_arbiter
	(
	 .request	(request2), 
    .grant	(grant2),
	 .any_grant	(sel)
	);
 
 
 
 endmodule
 
 
 
 
 module arbiter_2_bcd(
	 input      [1 			:	0]	in,
	 output	reg[0				:	0]	out,
	 input 	   [0				:	0]	low_pr
);
always @(*) begin
  out=1'd0;
 	 case(low_pr)
		 1'd0:
			 if(in[1]) 			out=1'd1;
			 else if(in[0]) 		out=1'd0;
		 1'd1:
			 if(in[0]) 			out=1'd0;
			 else if(in[1]) 		out=1'd1;
		 default: out=1'd0;
	 endcase 
  end
 endmodule 


 module arbiter_3_bcd(
	 input      [2 			:	0]	in,
	 output	reg[1				:	0]	out,
	 input 	   [1				:	0]	low_pr
);
always @(*) begin
  out=2'd0;
 	 case(low_pr)
		 2'd0:
			 if(in[1]) 			out=2'd1;
			 else if(in[2]) 		out=2'd2;
			 else if(in[0]) 		out=2'd0;
		 2'd1:
			 if(in[2]) 			out=2'd2;
			 else if(in[0]) 		out=2'd0;
			 else if(in[1]) 		out=2'd1;
		 2'd2:
			 if(in[0]) 			out=2'd0;
			 else if(in[1]) 		out=2'd1;
			 else if(in[2]) 		out=2'd2;
		 default: out=2'd0;
	 endcase 
  end
 endmodule 


 module arbiter_4_bcd(
	 input      [3 			:	0]	in,
	 output	reg[1				:	0]	out,
	 input 	   [1				:	0]	low_pr
);
always @(*) begin
  out=2'd0;
 	 case(low_pr)
		 2'd0:
			 if(in[1]) 			out=2'd1;
			 else if(in[2]) 		out=2'd2;
			 else if(in[3]) 		out=2'd3;
			 else if(in[0]) 		out=2'd0;
		 2'd1:
			 if(in[2]) 			out=2'd2;
			 else if(in[3]) 		out=2'd3;
			 else if(in[0]) 		out=2'd0;
			 else if(in[1]) 		out=2'd1;
		 2'd2:
			 if(in[3]) 			out=2'd3;
			 else if(in[0]) 		out=2'd0;
			 else if(in[1]) 		out=2'd1;
			 else if(in[2]) 		out=2'd2;
		 2'd3:
			 if(in[0]) 			out=2'd0;
			 else if(in[1]) 		out=2'd1;
			 else if(in[2]) 		out=2'd2;
			 else if(in[3]) 		out=2'd3;
		 default: out=2'd0;
	 endcase 
  end
 endmodule 
 
  
 
 module fixed_priority_bcd_arbiter #(
	parameter IN_WIDTH	=	4,
	parameter OUT_WIDT	=	log2(IN_WIDTH)
)
(
	 input      [IN_WIDTH-1 			:	0]	request,
	 output	reg[OUT_WIDT-1				:	0]	grant,
	 output 											any_grant
);
	`LOG2
	reg[OUT_WIDT-1	:0] i;
	assign  any_grant= | request;
	always @(*) begin
		grant={OUT_WIDT{1'b0}};
		for(i=IN_WIDTH-1'b1;i>{OUT_WIDT{1'b0}};i=i-1'b1) begin 
			if(request[i]) 			grant=i;
		end
		if(request[0]) 			grant={OUT_WIDT{1'b0}};
 	end
endmodule
 
 
 
 /*****************************************
		
		round robin One-Hot arbiter
 

******************************************/

module one_hot_arbiter #(
	parameter ARBITER_WIDTH	=8
	
)
(
	input		[ARBITER_WIDTH-1 			:	0]	request,
	output	[ARBITER_WIDTH-1			:	0]	grant,
	output											any_grant,
	input												clk,
	input												reset
);

	generate 
	if(ARBITER_WIDTH<=4) begin
		//my own arbiter 
		my_one_hot_arbiter #(
			.ARBITER_WIDTH	(ARBITER_WIDTH)
		)
		one_hot_arb
		(	
			.clk			(clk), 
			.reset 		(reset), 
			.request		(request), 
			.grant		(grant),
			.any_grant	(any_grant)
		);
	
	end else begin
		// Dimitrakopoulos arbiter
		arbiter #(
			.ARBITER_WIDTH	(ARBITER_WIDTH)
		)
		one_hot_arb
		(	
			.clk			(clk), 
			.reset 		(reset), 
			.request		(request), 
			.grant		(grant),
			.anyGrant	(any_grant)
		);
	end
	endgenerate
endmodule


module my_one_hot_arbiter #(
	parameter ARBITER_WIDTH	=4
	
)
(
	input		[ARBITER_WIDTH-1 			:	0]	request,
	output	[ARBITER_WIDTH-1			:	0]	grant,
	output											any_grant,
	input												clk,
	input												reset
);
	`LOG2
	localparam ARBITER_BCD_WIDTH= log2(ARBITER_WIDTH);
	reg 	[ARBITER_BCD_WIDTH-1		:	0] 	low_pr;
	wire 	[ARBITER_BCD_WIDTH-1		:	0] 	grant_bcd;
	
	one_hot_to_bcd #(
		.ONE_HOT_WIDTH	(ARBITER_WIDTH)
	)conv 
	(
		.one_hot_code(grant),
		.bcd_code(grant_bcd)
	);
	
	always@(posedge clk or posedge reset) begin
		if(reset) begin
			low_pr	<=	{ARBITER_BCD_WIDTH{1'b0}};
		end else begin
			if(any_grant) low_pr <= grant_bcd;
		end
	end
	

	assign any_grant = | request;

	generate 
		if(ARBITER_WIDTH	==2) 		arbiter_2_one_hot arb( .in(request) , .out(grant), .low_pr(low_pr));
		if(ARBITER_WIDTH	==3) 		arbiter_3_one_hot arb( .in(request) , .out(grant), .low_pr(low_pr));
		if(ARBITER_WIDTH	==4) 		arbiter_4_one_hot arb( .in(request) , .out(grant), .low_pr(low_pr));
	endgenerate

endmodule


module arbiter_2_one_hot(
	 input      [1 			:	0]	in,
	 output	reg[1				:	0]	out,
	 input 	   						low_pr
);
always @(*) begin
	 out=2'b00;
 	 case(low_pr)
		 1'd0:
			 if(in[1]) 				out=2'b10;
			 else if(in[0]) 		out=2'b01;
		 1'd1:
			 if(in[0]) 				out=2'b01;
			 else if(in[1]) 		out=2'b10;
		  default: out=2'b00;
	 endcase 
  end
 endmodule 




module arbiter_3_one_hot(
	 input      [2 			:	0]	in,
	 output	reg[2				:	0]	out,
	 input 	   [1				:	0]	low_pr
);
always @(*) begin
  out=3'b000;
 	 case(low_pr)
		 2'd0:
			 if(in[1]) 				out=3'b010;
			 else if(in[2]) 		out=3'b100;
			 else if(in[0]) 		out=3'b001;
		 2'd1:
			 if(in[2]) 				out=3'b100;
			 else if(in[0]) 		out=3'b001;
			 else if(in[1]) 		out=3'b010;
		 2'd2:
			 if(in[0]) 				out=3'b001;
			 else if(in[1]) 		out=3'b010;
			 else if(in[2]) 		out=3'b100;
		 default: out=3'b000;
	 endcase 
  end
 endmodule 


 module arbiter_4_one_hot(
	 input      [3 			:	0]	in,
	 output	reg[3				:	0]	out,
	 input 	   [1				:	0]	low_pr
);
always @(*) begin
  out=4'b0000;
 	 case(low_pr)
		 2'd0:
			 if(in[1]) 				out=4'b0010;
			 else if(in[2]) 		out=4'b0100;
			 else if(in[3]) 		out=4'b1000;
			 else if(in[0]) 		out=4'b0001;
		 2'd1:
			 if(in[2]) 				out=4'b0100;
			 else if(in[3]) 		out=4'b1000;
			 else if(in[0]) 		out=4'b0001;
			 else if(in[1]) 		out=4'b0010;
		 2'd2:
			 if(in[3]) 				out=4'b1000;
			 else if(in[0]) 		out=4'b0001;
			 else if(in[1]) 		out=4'b0010;
			 else if(in[2]) 		out=4'b0100;
		 2'd3:
			 if(in[0]) 				out=4'b0001;
			 else if(in[1]) 		out=4'b0010;
			 else if(in[2]) 		out=4'b0100;
			 else if(in[3]) 		out=4'b1000;
		 default: out=4'b0000;
	 endcase 
  end
 endmodule 

 
 
 
 
 
 
 
 
 
 
 
 
 

//
//module one_hot_to_bcd_arbiter #(
//	parameter ARBITER_WIDTH	=8,
//	parameter ARBITER_BCD_WIDTH= log2(ARBITER_WIDTH)
//)
//(
//	input		[ARBITER_WIDTH-1 			:	0]	request,
//	output	[ARBITER_BCD_WIDTH-1		:	0]	grant,
//	output											any_grant,
//	input												clk,
//	input												reset
//);
//
//`LOG2
//wire [ARBITER_WIDTH-1		:	0]grant_one_hot;
//arbiter #(
//	.ARBITER_WIDTH	(ARBITER_WIDTH),
//	.CHOISE(1)  // 0 blind round-robin and 1 true round robin
//) old_arb
//(	
//	.clk		(clk), 
//   .reset 	(reset), 
//   .request	(request), 
//   .grant	(grant_one_hot),
//   .anyGrant (any_grant)
//);
//
//	one_hot_to_bcd #(
//		.ONE_HOT_WIDTH	(ARBITER_WIDTH)
//	)conv 
//	(
//		.one_hot_code(grant_one_hot),
//		.bcd_code(grant)
//	);
//
//
//endmodule
//










/*
test timing
module test #(
	parameter ARBITER_WIDTH	=5,
	parameter ARBITER_BCD_WIDTH= log2(ARBITER_WIDTH)
)
(
	input		[ARBITER_WIDTH-1 			:	0]	request,
	output	reg [ARBITER_BCD_WIDTH-1		:	0]	grant,
	output	reg										any_grant,
	input												clk,
	input												reset
	
);
`LOG2
reg 		[ARBITER_WIDTH-1 			:	0]	request_reg;
wire		[ARBITER_BCD_WIDTH-1		:	0]	grant_out;
wire												any_grant_out;
always@(posedge clk or posedge reset) begin 
	if(reset) begin
		request_reg <= 0;
		grant			<= 0;
		any_grant   <= 0;
		
	end else begin 
		request_reg <= request;
		grant			<= grant_out;
		any_grant   <= any_grant_out;
	end
end


//my_arbiter #(
//one_hot_to_bcd_arbiter #(
 two_level_arbiter #(

	.ARBITER_WIDTH	(ARBITER_WIDTH)
	)
	arbb
	(
	.request		(request_reg),
	.grant		(grant_out),
	.any_grant	(any_grant_out),
	.clk			(clk),
	.reset		(reset)
	//.mask			(mask_reg)
);



endmodule



*/
