`include "irda_defines.v"
module irda_crc32(clk, wb_rst_i, clrcrc, fir_tx4_enable, txdin, crcndata,txdout,bdcrc);
/* ************************************************************************* */
// compute 802.X CRC x32 x26 x23 x22 x16 x12 x11 x10 x8 x7 x5 x4 x2 x + 1
// on serial bit stream.
/* ************************************************************************* */
/* bdcrc is input signal used to send a bad crc for test purposes */

input clrcrc,clk,txdin,wb_rst_i,bdcrc, crcndata;
input fir_tx4_enable;

output txdout;
reg [31:0] nxtxcrc,txcrc;
/* ************************************************************************* */
// XOR data stream with output of CRC register and create input stream
// if crcndata is low, feed a 0 into input to create virtual shift reg
/* ************************************************************************* */
wire crcshin = (txcrc[31] ^ txdin)& ~crcndata;
/* ************************************************************************* */
// combinatorial logic to implement polynomial
/* ************************************************************************* */
always @ (txcrc or clrcrc or crcshin)
begin
	if (clrcrc)
		nxtxcrc			<= #1  32'hffffffff;
	else begin
		nxtxcrc[31:27] <= #1  txcrc[30:26];
		nxtxcrc[26]		<= #1  txcrc[25] ^ crcshin; // x26
		nxtxcrc[25:24] <= #1  txcrc[24:23];
		nxtxcrc[23]		<= #1  txcrc[22] ^ crcshin; // x23
		nxtxcrc[22]		<= #1  txcrc[21] ^ crcshin; // x22
		nxtxcrc[21:17] <= #1  txcrc[20:16];
		nxtxcrc[16]		<= #1  txcrc[15] ^ crcshin; // x16
		nxtxcrc[15:13] <= #1  txcrc[14:12];
		nxtxcrc[12]		<= #1  txcrc[11] ^ crcshin; // x12
		nxtxcrc[11]		<= #1  txcrc[10] ^ crcshin; // x11
		nxtxcrc[10]		<= #1  txcrc[9] ^ crcshin; // x10
		nxtxcrc[9]		<= #1  txcrc[8];
		nxtxcrc[8]		<= #1  txcrc[7] ^ crcshin; // x8
		nxtxcrc[7]		<= #1  txcrc[6] ^ crcshin; // x7
		nxtxcrc[6]		<= #1  txcrc[5];
		nxtxcrc[5]		<= #1  txcrc[4] ^ crcshin; // x5
		nxtxcrc[4]		<= #1  txcrc[3] ^ crcshin; // x4
		nxtxcrc[3]		<= #1  txcrc[2];
		nxtxcrc[2]		<= #1  txcrc[1] ^ crcshin; // x2
		nxtxcrc[1]		<= #1  txcrc[0] ^ crcshin; // x1
		nxtxcrc[0]		<= #1  crcshin; // +1
	end
end
/* ********************************************************************** */
// infer 32 flops for storage, include async reset asserted high
/* ********************************************************************** */
always @ (posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		txcrc <= #1  32'hffffffff;
	else if (fir_tx4_enable)
		txcrc <= #1  nxtxcrc; // load D input (nxtxcrc) into flops
end
/* ********************************************************************** */
// normally crc is inverted as it is sent out
// input signal badcrc is asserted to append bad CRC to packet for
// testing, this is an implied mux with control signal crcndata
// if crcndata = 0 , the data is passed by unchanged, if = 1 then
// the crc register is inverted and transmitted.
/* ********************************************************************** */
wire txdout = (crcndata) ? (~txcrc[31] ^ bdcrc) : txdin; // don't invert  if bdcrc is 1
endmodule
