`include "define.h"





module	uart_read( sync_reset, clk, rxd,buffer_reg, int_req);
	input sync_reset;
	input	clk, rxd;
	output	[7:0] buffer_reg;
	output	int_req;
	

//________|-|______int_req (This module,, posedge interrupt)
//
//Spec. Upper module must service within 115.2Kbpsx8bit time. Maybe enough time...
//
//No error handling (overrun ) is supported.
	
	reg	        rxq1;
	reg		[8:0] clk_ctr;
	reg		[2:0] bit_ctr;
	reg		[2:0] ua_state;
	reg		[7:0] rx_sr;             //.,tx_sr;
	reg		int_req;
	reg		[7:0] buffer_reg;	

	wire	 clk_ctr_equ15, clk_ctr_equ31, bit_ctr_equ7, 
			   clk_ctr_enable_state, bit_ctr_enable_state  ;
	wire 	clk_ctr_equ0;
	    

	
	 
//sync_reset

//synchronization
	always @(posedge clk ) begin
		rxq1 <=rxd ;
	end
	
// 7bit counter
	always @(posedge clk ) begin
		if (sync_reset)
			clk_ctr <= 0;
		else if (clk_ctr_enable_state && clk_ctr_equ31)  clk_ctr<=0;	
		else if (clk_ctr_enable_state)	                 clk_ctr <= clk_ctr + 1;
		else	clk_ctr <= 0;
	end
	assign	clk_ctr_equ15 =  (clk_ctr==`COUNTER_VALUE1)  ;//
	assign	clk_ctr_equ31 =  (clk_ctr==`COUNTER_VALUE2) ;//
	assign  clk_ctr_equ0=    (clk_ctr==`COUNTER_VALUE3);	//


	// 3bit counter
	always @(posedge clk) begin
		if (sync_reset)
			bit_ctr <= 0;
		else if (bit_ctr_enable_state) begin
			if (clk_ctr_equ15)
				bit_ctr <= bit_ctr + 1;
		end
		else
			bit_ctr <= 0;
	end

	assign	bit_ctr_equ7 = (bit_ctr==7);

	
	assign	clk_ctr_enable_state =  ua_state !=3'b000  && ua_state<=3'b011;
	assign	bit_ctr_enable_state = ua_state==3'h2;

//	
	always @(posedge clk ) begin
		if (sync_reset) ua_state <= 3'h0;
		else begin
			case (ua_state)
				3'h0:	if (rxq1==0) ua_state <= 3'h1;  // if rxd==0 then goto next state and enable clock						// start bit search
				3'h1:	if (clk_ctr_equ15) ua_state <= 3'h2;					// start bit receive
				3'h2:	if (bit_ctr_equ7 & clk_ctr_equ15) ua_state <= 3'h3;	
				3'h3:	if (clk_ctr_equ15)     ua_state <=3'h4; 								// stop bit receive
				3'h4:   ua_state <= 3'b000;
				default: ua_state <= 3'b000;			
			endcase
		end
	end


//reg_we
	always @(posedge clk ) begin
		if (sync_reset) 			   buffer_reg<=8'h00;
		else if (ua_state==3'h3 && clk_ctr_equ0)  buffer_reg<=rx_sr;
	end

//int_req
	always @(posedge clk ) begin
		if (sync_reset) 			    int_req<=1'b0;
		else if (ua_state==3'h4	)   int_req<=1'b1;	//
		else 					    int_req<=1'b0;
	end


// rx shift reg.
	always @(posedge clk ) begin
		if (sync_reset) rx_sr <= 0;
		else if (clk_ctr_equ15) rx_sr <= {rxq1, rx_sr[7:1]};
	end
	
endmodule