`include "irda_defines.v"

module irda_reg (clk, wb_rst_i, wb_addr_i, wb_dat_i, f_wb_we_i,
		f_ifdlr, f_iir, rxfifo_dat_o, re_i,
		f_ier, f_fcr, f_lcr, f_ofdlr, f_cdr, txfifo_add, f_wb_dat_o, en_reload,
		f_iir_read, rxfifo_remove);

input 										clk;
input 										wb_rst_i;
input [3:0] 								wb_addr_i;
input [31:0] 								wb_dat_i;
input 										f_wb_we_i;
input [15:0] 								f_ifdlr;
input [7:0] 								f_iir;
input [`IRDA_FIFO_WIDTH-1:0] 			rxfifo_dat_o;
input 										re_i; /// read enable

output [6:0] 								f_ier;
output [7:0] 								f_fcr;
output [1:0] 								f_lcr;
output [15:0] 								f_ofdlr;
output [`IRDA_F_CDR_WIDTH-1:0] 		f_cdr;
output 										txfifo_add;
output [31:0] 								f_wb_dat_o;
output 										en_reload;
output 										f_iir_read; // true when iir was accessed for reading
output 										rxfifo_remove;

reg [6:0] 									f_ier;
wire [7:0] 									f_iir;
reg [7:0] 									f_fcr;
reg [1:0] 									f_lcr;
reg [15:0] 									f_ofdlr;
reg [`IRDA_F_CDR_WIDTH-1:0] 			f_cdr;
reg 											txfifo_add;
reg [31:0] 									f_wb_dat_o;
reg 											en_reload;
reg 											f_iir_read;
reg 											rxfifo_remove;

wire [3:0] 									wb_addr_i;
wire [31:0] 								wb_dat_i;
wire [15:0] 								f_ifdlr;		// incoming frame data length

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		f_wb_dat_o <= #1 31'b0;
	end else if (re_i) begin
		case	(wb_addr_i)
			`IRDA_RECEIVER:	f_wb_dat_o 			  <= #1 rxfifo_dat_o;
			`IRDA_F_IER:		f_wb_dat_o[7:0] 	  <= #1 {1'b0, f_ier};
			`IRDA_F_IIR:		f_wb_dat_o[7:0] 	  <= #1 f_iir;
			`IRDA_F_FCR:		f_wb_dat_o[7:0] 	  <= #1 f_fcr;
			`IRDA_F_LCR:		f_wb_dat_o[7:0] 	  <= #1 f_lcr;
			`IRDA_F_OFDLR:		f_wb_dat_o[15:0] 	  <= #1 f_ofdlr;
			`IRDA_F_IFDLR:		f_wb_dat_o[15:0] 	  <= #1 f_ifdlr;
			`IRDA_F_CDR:		f_wb_dat_o[31:0] 	  <= #1 f_cdr;
			default:				f_wb_dat_o			  <= #1 32'b0;
		endcase
	end
end

// rxfifo_remove logic
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		rxfifo_remove <= #1 0;
	end
	else
	begin
	  if (re_i && wb_addr_i && ~rxfifo_remove == `IRDA_RECEIVER)
		 rxfifo_remove <= #1 1;
	  else
		 rxfifo_remove <= #1 0;
	end
end


// f_iir_read signal logic
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		f_iir_read <= #1 0;
	end else begin
		f_iir_read <= #1 (~ f_wb_we_i && wb_addr_i == `IRDA_F_IIR);
	end
end

// en_reload controls the restart of fast enable signal generation logic
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		en_reload <= #1 0;
	else if (en_reload) // the signal is asserted for one clock only
		en_reload <= #1 0;
	else if (f_wb_we_i && wb_addr_i == `IRDA_F_CDR) // enabled at writing to the CDR register
		en_reload <= #1 1;
end

// TX fifo
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		txfifo_add <= #1 1'b0;
	end else begin
		if (~txfifo_add && f_wb_we_i && wb_addr_i == `IRDA_TRANSMITTER) // hold txfifo_add for one clock only
			txfifo_add <= #1 1'b1;
		else
			txfifo_add <= #1 1'b0;
	end
end

// Interrupt Enable Register
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		f_ier	<= #1 7'b0;
	end else 
	if (f_wb_we_i && wb_addr_i==`IRDA_F_IER) begin
		f_ier	<= #1 wb_dat_i[6:0];
	end
end

// fifo Control Register
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		f_fcr	<= #1 8'b00110011;
	end else 
	if (f_wb_we_i && wb_addr_i==`IRDA_F_FCR) begin
		f_fcr	<= #1 wb_dat_i[7:0];
	end else
		f_fcr <= #1 f_fcr & 8'b10110011; // mask reset bits, so they won't stick to '1'
end

// Line Control Register
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		f_lcr	<= #1 2'b0;
	end else
	if (f_wb_we_i && wb_addr_i==`IRDA_F_LCR) begin
		f_lcr	<= #1 wb_dat_i[1:0];
	end
end

// Outgoing Frame Data Length Register
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		f_ofdlr	<= #1 16'b0;
	end else
	if (f_wb_we_i && wb_addr_i==`IRDA_F_OFDLR) begin
		f_ofdlr	<= #1 wb_dat_i[15:0];
	end
end

// Clock Divisor Register
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		f_cdr	<= #1 0;  /// fix later
	end else 
	if (f_wb_we_i && wb_addr_i==`IRDA_F_CDR) begin
		f_cdr	<= #1 wb_dat_i;
	end
end

endmodule
