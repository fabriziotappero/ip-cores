`include "irda_defines.v"
module irda_mir_st_det (clk, wb_rst_i, rx_i, std_restart, mir_rxbit_enable,
	std_is_good_bit, std_st_detected, std_o);

input 		clk;
input 		wb_rst_i;
input 		rx_i;	// input to the module
input 		std_restart; // to restart the module logic
input 		mir_rxbit_enable;

output 		std_is_good_bit; // tells if the bit at output is a good stream bit
output 		std_o;			// module output
output 		std_st_detected; // STA/STO signal detected

reg [7:0] 	st_int_reg; // internal buffer register
reg [2:0] 	front;  // position of front output element
reg 			std_is_good_bit;
// module ouptut , only valid when std_is_good_bit is asserted
assign 		std_o = st_int_reg[0];

// the internal shift register logic
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		st_int_reg <= #1 0;
	end else 
	if (std_restart) begin
		st_int_reg <= #1 0;
	end else if (mir_rxbit_enable) begin
		// shift the register right
		st_int_reg[6:0] <= #1 st_int_reg[7:1];
		st_int_reg[7] <= #1 rx_i;
	end
end // always @ (posedge clk or posedge wb_rst_i)

// std_st_detected : next clock the internal register will hold STA/STO signal
assign std_st_detected = ( {rx_i, st_int_reg[7:1]} == 8'b01111110 );

// Front register control
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		front <= #1 7;
	else if (std_restart)
		front <= #1 7;
	else if (mir_rxbit_enable) begin
		if (std_st_detected) // on detection of STx signal the good bit front is reset
			front <= #1 7;
		else if (front != 0)  // the front stays on 0 while all is good
			front <= #1 front - 1;
	end
end  // front

// std_is_good_bit signal logic
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
	  std_is_good_bit <= #1 0;
	else
	  std_is_good_bit <= #1 ( front == 0);
end

endmodule
