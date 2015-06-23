`include "irda_defines.v"
module irda_crc_rx_ccitt16(clk, wb_rst_i, clrcrc, txdin, crcndata,
							 bds_is_data_bit, mir_rxbit_enable, txdout, bdcrc, crc16_par_o);
/* ************************************************************************* */
// compute CRC-CCITT x16 x12 x5 + 1
// on serial bit stream.
/* ************************************************************************* */
/* bdcrc is input signal used to send a bad crc for test purposes */

input clrcrc,clk,txdin,wb_rst_i,bdcrc, crcndata;
input mir_rxbit_enable;
input bds_is_data_bit;

output txdout;
output [15:0] crc16_par_o; // parallel output

reg [15:0] nxtxcrc,txcrc;

wire [15:0] crc16_par_o = txcrc;

/* ************************************************************************* */
// XOR data stream with output of CRC register and create input stream
// if crcndata is low, feed a 0 into input to create virtual shift reg
/* ************************************************************************* */
wire crcshin = (txcrc[15] ^ txdin)& ~crcndata;
/* ************************************************************************* */
// combinatorial logic to implement polynomial
/* ************************************************************************* */
always @ (txcrc or clrcrc or crcshin)
begin
	if (clrcrc)
		nxtxcrc			<= #1  16'hffff;
	else begin
		nxtxcrc[15:13] <= #1  txcrc[14:12];
		nxtxcrc[12]		<= #1  txcrc[11] ^ crcshin; // x12
		nxtxcrc[11:6]	<= #1  txcrc[10:5];
		nxtxcrc[5]		<= #1  txcrc[4] ^ crcshin; // x5
		nxtxcrc[4:1]	<= #1  txcrc[3:0];
		nxtxcrc[0]		<= #1  crcshin; // +1
	end
end
/* ********************************************************************** */
// infer 16 flops for strorage, include async reset asserted high
/* ********************************************************************** */
always @ (posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		txcrc <= #1  16'hffff;
	else if (mir_rxbit_enable && bds_is_data_bit)
		txcrc <= #1  nxtxcrc; // load D input (nxtxcrc) into flops
end
/* ********************************************************************** */
// normally crc is inverted as it is sent out
// input signal badcrc is asserted to append bad CRC to packet for
// testing, this is an implied mux with control signal crcndata
// if crcndata = 0 , the data is passed by unchanged, if = 1 then
// the crc register is inverted and transmitted.
/* ********************************************************************** */
wire txdout = (crcndata) ? (~txcrc[15] ^ bdcrc) : txdin; // don't invert
// if bdcrc is 1
endmodule
