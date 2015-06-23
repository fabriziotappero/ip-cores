`include "define.h"
//Apr.5.2005 Tak.Sugawara
//Jul.14.2004


module	uart_write( sync_reset, clk, txd, data_in , write_request,write_done,write_busy);
	input sync_reset,clk;
	input [7:0] data_in;
	input write_request;
	output txd,write_done;
	output write_busy;

	
 
	wire		queue_full;
	wire	queing, read_request;
        wire [7:0] queue_data;
	reg read_request_ff;
	

//________|--|___write_request (upper  module :     its period should be 1clock time.)
//__________________________|-|______write_done    (Responds by this module posedge interrupt)
//With 512Bytes FIFO.
//No error handling is supported.

	reg		[8:0] clk_ctr;
	reg		[2:0] bit_ctr;
	reg		[2:0] ua_state;
	reg		[7:0] tx_sr;
	reg		write_done_n;
	reg		txd;

	wire	 clk_ctr_equ15, clk_ctr_equ31,  bit_ctr_equ7,
			   clk_ctr_enable_state, bit_ctr_enable_state  ;
	wire    tx_state;
	wire empty;
	assign write_busy=queue_full;//Apr.2.2005

	always @ (posedge clk) begin
		if (sync_reset)	read_request_ff<=1'b0;
		else			read_request_ff<=read_request;
	end

	assign queing=	!empty;
	assign read_request	 = queing && ua_state==3'b000;//Jul.14.2004 

	assign write_done=ua_state==3'b101;

`ifdef ALTERA
 fifo512_cyclone  fifo(
	.data(data_in),
	.wrreq(write_request),
	.rdreq(read_request),
	.clock(clk),
	.q(queue_data),
	.full(queue_full),
	.empty(empty));
`else//XILINX coregen

 fifo	 fifo(
	.clk(clk),
	.sinit(sync_reset),
	.din(data_in),
	.wr_en(write_request),
	.rd_en(read_request),
	.dout(queue_data),
	.full(queue_full),
	.empty(empty));


`endif



// 7bit counter
	always @(posedge clk ) begin
		if (sync_reset)
			clk_ctr <= 0;
		else if (clk_ctr_enable_state && clk_ctr_equ31)  clk_ctr<=0;	
		else if (clk_ctr_enable_state)	                 clk_ctr <= clk_ctr + 1;
		else	clk_ctr <= 0;
	end


	assign	clk_ctr_equ15 = clk_ctr==`COUNTER_VALUE1;  
	assign	clk_ctr_equ31 = clk_ctr==`COUNTER_VALUE2;

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



	assign	clk_ctr_enable_state = bit_ctr_enable_state ||  ua_state==3'b001 ||  ua_state==3'b100 ;
	assign	bit_ctr_enable_state =  ua_state==3'b010 || ua_state==3'b011;


	always @(posedge clk ) begin
		if (sync_reset) ua_state <= 3'b000;
		else begin
			case (ua_state)
				3'b000:	if (queing)  ua_state <= 3'b001;	//wait write_request
				3'b001:	if ( clk_ctr_equ15) ua_state <= 3'b010;	// write start bit
				3'b010:	if (bit_ctr_equ7 & clk_ctr_equ15) ua_state <= 3'b011;		// start bit, bit0-7 data  send
				3'b011:	if (clk_ctr_equ15) ua_state <= 3'b100;					// bit7 data send
				3'b100:	if (clk_ctr_equ15) ua_state <= 3'b101;	// stop bit				// stop bit send
				3'b101:	 ua_state <= 3'h0;	// TAK					// byte read cycle end
				default: ua_state <= 3'h0;
			endcase
		end
	end












// tx shift reg.
	always @(posedge clk ) begin
		if (sync_reset) tx_sr<=0;
		else if (read_request_ff) tx_sr <= queue_data[7:0]; //data_in[7:0]; // load
		else if (tx_state ) tx_sr <= {1'b0, tx_sr[7:1]};
	end
	
	assign  tx_state=(  ua_state==3'h2 || ua_state==3'h3)		&&	clk_ctr_equ15;


// tx
	always @(posedge clk ) begin
		if (sync_reset) txd <=1'b1;
		else if (sync_reset)			  txd<=1'b1;
		else if (ua_state==3'h0)		  txd<=1'b1;
		else if (ua_state==3'h1 && clk_ctr_equ15) txd<=1'b0;	// start bit
		else if (ua_state==3'h2 && clk_ctr_equ15) txd<=tx_sr[0];
		else if (ua_state==3'h3 && clk_ctr_equ15) txd<=1'b1;     // stop bit
	end
endmodule
