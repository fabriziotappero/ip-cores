`include "irda_defines.v"
module irda_crc_ccitt16(clk, wb_rst_i, clrcrc, txdin, crcndata,mir_txbit_enable, txdout, bdcrc);
/* ************************************************************************* */
// compute CRC-CCITT x16 x12 x5 + 1
// on serial bit stream.
/* ************************************************************************* */
/* bdcrc is input signal used to send a bad crc for test purposes */

input clrcrc,clk,txdin,wb_rst_i,bdcrc, crcndata;
input mir_txbit_enable;

output txdout;

reg [15:0] nxtxcrc,txcrc;
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
	else if (clrcrc) begin
		txcrc <= #1 16'hffff;
	end else if (mir_txbit_enable) begin
		txcrc <= #1  nxtxcrc; // load D input (nxtxcrc) into flops
	end
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
