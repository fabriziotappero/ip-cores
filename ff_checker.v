/////////////////////////////////////////////////////////////////////
////                                                             ////
////  JPEG Encoder Core - Verilog                                ////
////                                                             ////
////  Author: David Lundgren                                     ////
////          davidklun@gmail.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2009 David Lundgren                           ////
////                  davidklun@gmail.com                        ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

/*
This module takes the JPEG_bitstream as its input, and checks for any FF values in
the bitstream.  When it finds an FF in the bitstream, this module puts a 00 after the FF,
and then continues with the rest of the bitstream after the 00, per the JPEG standard.
*/

`timescale 1ns / 100ps

module ff_checker(clk, rst, end_of_file_signal, JPEG_in, data_ready_in, orc_reg_in,
JPEG_bitstream_1, data_ready_1, orc_reg, eof_data_partial_ready);
input		clk;
input		rst;
input		end_of_file_signal;
input  [31:0]  JPEG_in;
input		data_ready_in;
input	[4:0]	orc_reg_in;
output  [31:0]  JPEG_bitstream_1;
output		data_ready_1;
output	[4:0]	orc_reg;
output		eof_data_partial_ready;

		
reg	first_2bytes, second_2bytes, third_2bytes, fourth_2bytes;
reg first_2bytes_eof, second_2bytes_eof, third_2bytes_eof;
reg fourth_2bytes_eof, fifth_2bytes_eof, s2b, t2b; 
reg [79:0]	JPEG_eof_6, JPEG_eof_7;
reg [63:0]	JPEG_5, JPEG_eof_5_1, JPEG_6, JPEG_7;
reg [55:0]	JPEG_4, JPEG_eof_3, JPEG_eof_4, JPEG_eof_5;
reg [47:0]	JPEG_3, JPEG_eof_2; 
reg	[39:0]	JPEG_2, JPEG_eof_1;
reg	[31:0]	JPEG_1, JPEG_ro, JPEG_bitstream, JPEG_bitstream_1;
reg [31:0] 	JPEG_eof, JPEG_eof_ro;
reg [31:0]	JPEG_bitstream_eof;
reg [15:0] 	JPEG_eof_ro_ro;
reg	[87:0]	JPEG_out, JPEG_out_1, JPEG_pf;
reg [23:0]  JPEG_ro_ro;
reg	dr_in_1, dr_in_2, dr_in_3, dr_in_4, dr_in_5, dr_in_6;
reg	dr_in_7, dr_in_8;
reg rollover, rollover_1, rollover_2, rollover_3, rollover_4, rollover_5;
reg rollover_pf, rpf_1;
reg [1:0] FF_count, FF_count_1, FF_eof_shift;
reg [2:0] count_total, ct_1;
reg [1:0] ffc_1, ffc_2, ffc_3, ffc_4, ffc_5, ffc_6, ffc_7;
reg [1:0] ffc_postfifo, count_total_eof;
reg [4:0] orc_input;
reg [4:0] orc_reg;
reg [6:0] extra_bits_eof, extra_bits_eof_1;
wire [90:0] read_data;
wire [90:0] write_data = { JPEG_out_1, ffc_7, rollover_5 }; 
reg data_ready, data_ready_1, write_enable, read_req, rdv_1;
reg end_of_file_enable, eof_count_enable;
reg eof_data_partial_ready, eof_dpr_1, eof_dpr_2;
reg end_of_file_enable_hold, eof_data_ready;
reg eof_data_ready_1, eof_bits_1, eof_bits_2, eof_bits_3;
reg [8:0] eof_count;
wire fifo_empty, rdata_valid;

 sync_fifo_ff u18(.clk(clk), .rst(rst), .read_req(read_req), .write_data(write_data), 
		.write_enable(write_enable), .rollover_write(rollover_5),
		.read_data(read_data), .fifo_empty(fifo_empty), 
		.rdata_valid(rdata_valid));
	
	// sync_fifo is the FIFO for the bitstream.  A FIFO is needed because when a  
	// total of 4 FF's have been found, then there will be a rollover of the 
	// 32 bit set of JPEG bits.  The JPEG bitstream input will need to be stored 
	// for 1 clock cycle as the extra 00 put in after the FF will cause an
	// extra set of 32 bits to be put into the bitstream.

always @(posedge clk)
begin 
	if (rst) 
		eof_data_partial_ready <= 0; 
	else if (eof_bits_1)
		eof_data_partial_ready <= (extra_bits_eof_1 > 0) && (extra_bits_eof_1 < 32);
	else
		eof_data_partial_ready <= eof_dpr_1;
end

always @(posedge clk)
begin 
	if (rst) 
		eof_dpr_1 <= 0; 
	else if (eof_bits_1)
		eof_dpr_1 <= (extra_bits_eof_1 > 32) && (extra_bits_eof_1 < 64);
	else
		eof_dpr_1 <= eof_dpr_2;
end

always @(posedge clk)
begin 
	if (rst) 
		eof_dpr_2 <= 0; 
	else if (eof_bits_1)
		eof_dpr_2 <= extra_bits_eof_1 > 64;
	else
		eof_dpr_2 <= 0;
end

always @(posedge clk)
begin 
	if (rst) 
		eof_data_ready_1 <= 0;
	else if (end_of_file_enable)
		eof_data_ready_1 <= (extra_bits_eof_1 > 31);
	else if (eof_bits_1 || eof_bits_2)  
		eof_data_ready_1 <= eof_data_ready;
end

always @(posedge clk)
begin 
	if (rst) 
		eof_data_ready <= 0;
	else if (end_of_file_enable)
		eof_data_ready <= (extra_bits_eof_1 > 63);
	else if (eof_bits_1) 
		eof_data_ready <= 0;
end

always @(posedge clk)
begin 
	if (rst) begin
		eof_bits_1 <= 0; eof_bits_2 <= 0; eof_bits_3 <= 0;
	end
	else begin
		eof_bits_1 <= end_of_file_enable;
		eof_bits_2 <= eof_bits_1;
		eof_bits_3 <= eof_bits_2;
	end
end

always @(posedge clk)
begin 
	if (rst) begin
		JPEG_bitstream_eof <= 0; JPEG_eof_ro <= 0;
	end
	else if (end_of_file_enable) begin
		JPEG_bitstream_eof <= JPEG_eof_7[79:48];
		JPEG_eof_ro <= JPEG_eof_7[47:16];
	end
	else if (eof_bits_1 | eof_bits_2) begin
		JPEG_bitstream_eof <= JPEG_eof_ro;
		JPEG_eof_ro <= { JPEG_eof_ro_ro, {16{1'b0}} };
	end
end

always @(posedge clk)
begin 
	if (rst)
		JPEG_eof_ro_ro <= 0; 
	else if (end_of_file_enable)
		JPEG_eof_ro_ro <= JPEG_eof_7[15:0];
end

always @(posedge clk)
begin // These registers combine the previous leftover bits with
// the end of file bits
	if (rst) begin
		JPEG_eof_7 <= 0; JPEG_eof_6 <= 0; JPEG_eof_5_1 <= 0;
		FF_eof_shift <= 0; FF_count_1 <= 0;
	end
	else begin
		JPEG_eof_7[79:72] <= (FF_count_1 > 0) ? JPEG_ro[31:24] : JPEG_eof_6[79:72];
		JPEG_eof_7[71:64] <= (FF_count_1 > 1) ? JPEG_ro[23:16] : JPEG_eof_6[71:64];
		JPEG_eof_7[63:56] <= (FF_count_1 > 2) ? JPEG_ro[15:8] : JPEG_eof_6[63:56];
		JPEG_eof_7[55:0] <= JPEG_eof_6[55:0];
		JPEG_eof_6 <= JPEG_eof_5_1 << { FF_eof_shift[1], 4'b0000 };
		JPEG_eof_5_1 <= JPEG_eof_5 << { FF_eof_shift[0], 3'b000 };
		FF_eof_shift <= 2'b11 - FF_count;
		FF_count_1 <= FF_count;
	end
end


always @(posedge clk)
begin // These registers generate the end of file bits
	if (rst) begin
		orc_reg <= 0; extra_bits_eof <= 0; 
		extra_bits_eof_1 <= 0; count_total_eof <= 0;
		JPEG_eof_5 <= 0; fifth_2bytes_eof <= 0;
		JPEG_eof_4 <= 0; fourth_2bytes_eof <= 0;
		JPEG_eof_3 <= 0; third_2bytes_eof <= 0;
		JPEG_eof_2 <= 0;
		second_2bytes_eof <= 0; JPEG_eof_1 <= 0;
		first_2bytes_eof <= 0; s2b <= 0;  
		t2b <= 0; orc_input <= 0;
		end
	else begin
		orc_reg <= extra_bits_eof_1[4:0];
		extra_bits_eof <= { 2'b00, orc_input } + { 2'b00, FF_count, 3'b000 };
		extra_bits_eof_1 <= extra_bits_eof + { 2'b00, count_total_eof, 3'b000 }; 
		count_total_eof <= first_2bytes_eof + s2b + t2b;
		JPEG_eof_5[55:16] <= JPEG_eof_4[55:16]; 
		JPEG_eof_5[15:8] <= fifth_2bytes_eof ? 8'b00000000 : JPEG_eof_4[15:8];
		JPEG_eof_5[7:0] <= fifth_2bytes_eof ? JPEG_eof_4[15:8] : JPEG_eof_4[7:0];
		fifth_2bytes_eof <= (JPEG_eof_4[23:16] == 8'b11111111);
		JPEG_eof_4[55:24] <= JPEG_eof_3[55:24]; 
		JPEG_eof_4[23:16] <= fourth_2bytes_eof ? 8'b00000000 : JPEG_eof_3[23:16];
		JPEG_eof_4[15:8] <= fourth_2bytes_eof ? JPEG_eof_3[23:16] : JPEG_eof_3[15:8];
		JPEG_eof_4[7:0] <= fourth_2bytes_eof ? JPEG_eof_3[15:8] : JPEG_eof_3[7:0];
		fourth_2bytes_eof <= (JPEG_eof_3[31:24] == 8'b11111111);
		JPEG_eof_3[55:32] <= JPEG_eof_2[47:24]; 
		JPEG_eof_3[31:24] <= third_2bytes_eof ? 8'b00000000 : JPEG_eof_2[23:16];
		JPEG_eof_3[23:16] <= third_2bytes_eof ? JPEG_eof_2[23:16] : JPEG_eof_2[15:8];
		JPEG_eof_3[15:8] <= third_2bytes_eof ? JPEG_eof_2[15:8] : JPEG_eof_2[7:0];
		JPEG_eof_3[7:0] <= third_2bytes_eof ? JPEG_eof_2[7:0] : 8'b00000000; 
		third_2bytes_eof <= (JPEG_eof_2[31:24] == 8'b11111111);
		JPEG_eof_2[47:32] <= JPEG_eof_1[39:24]; 
		JPEG_eof_2[31:24] <= second_2bytes_eof ? 8'b00000000 : JPEG_eof_1[23:16];
		JPEG_eof_2[23:16] <= second_2bytes_eof ? JPEG_eof_1[23:16] : JPEG_eof_1[15:8];
		JPEG_eof_2[15:8] <= second_2bytes_eof ? JPEG_eof_1[15:8] : JPEG_eof_1[7:0];
		JPEG_eof_2[7:0] <= second_2bytes_eof ? JPEG_eof_1[7:0] : 8'b00000000; 
		second_2bytes_eof <= (JPEG_eof_1[31:24] == 8'b11111111);					
		JPEG_eof_1[39:32] <= JPEG_eof[31:24]; 
		JPEG_eof_1[31:24] <= first_2bytes_eof ? 8'b00000000 : JPEG_eof[23:16];
		JPEG_eof_1[23:16] <= first_2bytes_eof ? JPEG_eof[23:16] : JPEG_eof[15:8];
		JPEG_eof_1[15:8] <= first_2bytes_eof ? JPEG_eof[15:8] : JPEG_eof[7:0];
		JPEG_eof_1[7:0] <= first_2bytes_eof ? JPEG_eof[7:0] : 8'b00000000;
		first_2bytes_eof <= (JPEG_eof[31:24] == 8'b11111111);
		s2b <= (JPEG_eof[23:16] == 8'b11111111);
		t2b <= (JPEG_eof[15:8] == 8'b11111111);
		orc_input <= orc_reg_in;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		JPEG_eof <= 0; 
		end
	else begin
		JPEG_eof[31] <= (orc_reg_in > 5'b00000) ? JPEG_in[31] : 1'b0;
		JPEG_eof[30] <= (orc_reg_in > 5'b00001) ? JPEG_in[30] : 1'b0;
		JPEG_eof[29] <= (orc_reg_in > 5'b00010) ? JPEG_in[29] : 1'b0;
		JPEG_eof[28] <= (orc_reg_in > 5'b00011) ? JPEG_in[28] : 1'b0;
		JPEG_eof[27] <= (orc_reg_in > 5'b00100) ? JPEG_in[27] : 1'b0;
		JPEG_eof[26] <= (orc_reg_in > 5'b00101) ? JPEG_in[26] : 1'b0;
		JPEG_eof[25] <= (orc_reg_in > 5'b00110) ? JPEG_in[25] : 1'b0;
		JPEG_eof[24] <= (orc_reg_in > 5'b00111) ? JPEG_in[24] : 1'b0;
		JPEG_eof[23] <= (orc_reg_in > 5'b01000) ? JPEG_in[23] : 1'b0;
		JPEG_eof[22] <= (orc_reg_in > 5'b01001) ? JPEG_in[22] : 1'b0;
		JPEG_eof[21] <= (orc_reg_in > 5'b01010) ? JPEG_in[21] : 1'b0;
		JPEG_eof[20] <= (orc_reg_in > 5'b01011) ? JPEG_in[20] : 1'b0;
		JPEG_eof[19] <= (orc_reg_in > 5'b01100) ? JPEG_in[19] : 1'b0;
		JPEG_eof[18] <= (orc_reg_in > 5'b01101) ? JPEG_in[18] : 1'b0;
		JPEG_eof[17] <= (orc_reg_in > 5'b01110) ? JPEG_in[17] : 1'b0;
		JPEG_eof[16] <= (orc_reg_in > 5'b01111) ? JPEG_in[16] : 1'b0;
		JPEG_eof[15] <= (orc_reg_in > 5'b10000) ? JPEG_in[15] : 1'b0;
		JPEG_eof[14] <= (orc_reg_in > 5'b10001) ? JPEG_in[14] : 1'b0;
		JPEG_eof[13] <= (orc_reg_in > 5'b10010) ? JPEG_in[13] : 1'b0;
		JPEG_eof[12] <= (orc_reg_in > 5'b10011) ? JPEG_in[12] : 1'b0;
		JPEG_eof[11] <= (orc_reg_in > 5'b10100) ? JPEG_in[11] : 1'b0;
		JPEG_eof[10] <= (orc_reg_in > 5'b10101) ? JPEG_in[10] : 1'b0;
		JPEG_eof[9] <= (orc_reg_in > 5'b10110) ? JPEG_in[9] : 1'b0;
		JPEG_eof[8] <= (orc_reg_in > 5'b10111) ? JPEG_in[8] : 1'b0;
		JPEG_eof[7] <= (orc_reg_in > 5'b11000) ? JPEG_in[7] : 1'b0;
		JPEG_eof[6] <= (orc_reg_in > 5'b11001) ? JPEG_in[6] : 1'b0;
		JPEG_eof[5] <= (orc_reg_in > 5'b11010) ? JPEG_in[5] : 1'b0;
		JPEG_eof[4] <= (orc_reg_in > 5'b11011) ? JPEG_in[4] : 1'b0;
		JPEG_eof[3] <= (orc_reg_in > 5'b11100) ? JPEG_in[3] : 1'b0;
		JPEG_eof[2] <= (orc_reg_in > 5'b11101) ? JPEG_in[2] : 1'b0;
		JPEG_eof[1] <= (orc_reg_in > 5'b11110) ? JPEG_in[1] : 1'b0;
		JPEG_eof[0] <= 1'b0;
		end
end	

always @(posedge clk)
begin
	if (rst) 
		eof_count_enable <= 0; 
	else if (end_of_file_enable_hold) 
		eof_count_enable <= 0;
	else if (end_of_file_signal) 
		eof_count_enable <= 1;
end	 

always @(posedge clk)
begin
	if (rst) 
		eof_count <= 0; 
	else if (!eof_count_enable) 
		eof_count <= 0;
	else if (eof_count_enable) 
		eof_count <= eof_count + 1;
end

always @(posedge clk)
begin
	if (rst) 
		end_of_file_enable <= 0;
	else if (eof_count != 9'b011110000) 
		end_of_file_enable <= 0; 
	else if (eof_count == 9'b011110000) 
		end_of_file_enable <= 1;
end

always @(posedge clk)
begin
	if (rst) 
		end_of_file_enable_hold <= 0;
	else if (end_of_file_enable) 
		end_of_file_enable_hold <= 1; 
end

// This ends the section dealing with the end of file.

always @(posedge clk)
begin
	if (rst) begin
		data_ready_1 <= 0; JPEG_bitstream_1 <= 0;
		end
	else begin
		data_ready_1 <= data_ready || eof_data_ready_1;
		JPEG_bitstream_1 <= (eof_bits_1 || eof_bits_2 || eof_bits_3) ?
							JPEG_bitstream_eof : JPEG_bitstream;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		data_ready <= 0; rdv_1 <= 0; rpf_1 <= 0;
		end
	else begin
		data_ready <= rdv_1 || rpf_1;
		rdv_1 <= rdata_valid;
		rpf_1 <= rollover_pf & !rpf_1; // there can't be 2 rollover's in a row
		// because after the first rollover, the next fifo entry is dummy data
		end
end	

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[31:24] <= 0; 
	else if (rdv_1 && ffc_postfifo == 0 && !rpf_1) 
		JPEG_bitstream[31:24] <= JPEG_pf[87:80];
	else if (rpf_1 || (rdv_1 &&  ffc_postfifo > 0))
		JPEG_bitstream[31:24] <= JPEG_ro[31:24];
end	 

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[23:16] <= 0; 
	else if (rdv_1 && ffc_postfifo < 2 && !rpf_1) 
		JPEG_bitstream[23:16] <= JPEG_pf[79:72];
	else if (rpf_1 || (rdv_1 && ffc_postfifo > 1))
		JPEG_bitstream[23:16] <= JPEG_ro[23:16];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[15:8] <= 0; 
	else if (rdv_1 && ffc_postfifo < 3 && !rpf_1) 
		JPEG_bitstream[15:8] <= JPEG_pf[71:64];
	else if (rpf_1 || (rdv_1 && ffc_postfifo == 3))
		JPEG_bitstream[15:8] <= JPEG_ro[15:8];
end

always @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[7:0] <= 0; 
	else if (rdv_1 && !rpf_1) 
		JPEG_bitstream[7:0] <= JPEG_pf[63:56];
	else if (rpf_1)
		JPEG_bitstream[7:0] <= JPEG_ro[7:0];
end

always @(posedge clk)
begin
	if (rst)
		JPEG_ro <= 0; 
	else if (rdv_1 && !rpf_1)
		JPEG_ro <= JPEG_pf[55:24];
	else if (rpf_1)
		JPEG_ro[31:8] <= JPEG_ro_ro;
end	 

always @(posedge clk)
begin
	if (rst) begin
		JPEG_ro_ro <= 0;
		end
	else if (rdv_1) begin
		JPEG_ro_ro <= JPEG_pf[23:0];
		end
end	


always @(posedge clk)
begin
	if (fifo_empty)
		read_req <= 0; 
	else if (!fifo_empty)
		read_req <= 1;
end	 

always @(posedge clk)
begin
	if (rst)
		rollover_pf <= 0;
	else if (!rdata_valid)
		rollover_pf <= 0;
	else if (rdata_valid) 
		rollover_pf <= read_data[0];
end	

always @(posedge clk)
begin
	if (rst) begin 
		JPEG_pf <= 0; ffc_postfifo <= 0;
		end
	else if (rdata_valid) begin
		JPEG_pf <= read_data[90:3];
		ffc_postfifo <= read_data[2:1];
		// ffc_postfifo is the current count of how many FF's there have
		// been in the bitstream.  This determines how the bitstream from the
		// FIFO is adjusted as it is put into the output bitstream.
		end
end	 

always @(posedge clk)
begin
	if (!dr_in_8)
		write_enable <= 0; 
	else if (dr_in_8) 
		write_enable <= 1;
		// write_enable is the write enable to the FIFO
end	  

always @(posedge clk)
begin
	if (rst) begin
		JPEG_out_1 <= 0; ffc_7 <= 0; 
		end 
	else if (dr_in_8) begin 
		JPEG_out_1 <= ffc_6[0] ? JPEG_out : JPEG_out << 8; 
		ffc_7 <= ffc_6;
		end
end	 

always @(posedge clk)
begin
	if (rst) begin
		JPEG_out <= 0; ffc_6 <= 0;
		end 
	else if (dr_in_7) begin 
		JPEG_out <= ffc_5[1] ? JPEG_7 : JPEG_7 << 16; 
		ffc_6 <= ffc_5;
		end
end	 

always @(posedge clk)
begin
	if (rst) begin
		JPEG_7 <= 0; ffc_5 <= 0;
		end 
	else if (dr_in_6) begin 
		JPEG_7[63:16] <= JPEG_6[63:16]; 
		JPEG_7[15:8] <= (JPEG_6[23:16] == 8'b11111111) ? 8'b00000000 : JPEG_6[15:8];
		JPEG_7[7:0] <= (JPEG_6[23:16] == 8'b11111111) ? JPEG_6[15:8] : JPEG_6[7:0];
		ffc_5 <= ffc_4;
		end
end	 

always @(posedge clk)
begin
	if (rst) begin
		JPEG_6 <= 0; ffc_4 <= 0;
		end 
	else if (dr_in_5) begin 
		JPEG_6[63:24] <= JPEG_5[63:24]; 
		JPEG_6[23:16] <= (JPEG_5[31:24] == 8'b11111111) ? 8'b00000000 : JPEG_5[23:16];
		JPEG_6[15:8] <= (JPEG_5[31:24] == 8'b11111111) ? JPEG_5[23:16] : JPEG_5[15:8];
		JPEG_6[7:0] <= (JPEG_5[31:24] == 8'b11111111) ? JPEG_5[15:8] : JPEG_5[7:0]; 
		ffc_4 <= ffc_3;
		end
end	 

always @(posedge clk)
begin
	if (rst) begin
		JPEG_5 <= 0; ffc_3 <= 0;
		end 
	else if (dr_in_4) begin 
		JPEG_5[63:32] <= JPEG_4[55:24]; 
		JPEG_5[31:24] <= (JPEG_4[31:24] == 8'b11111111) ? 8'b00000000 : JPEG_4[23:16];
		JPEG_5[23:16] <= (JPEG_4[31:24] == 8'b11111111) ? JPEG_4[23:16] : JPEG_4[15:8];
		JPEG_5[15:8] <= (JPEG_4[31:24] == 8'b11111111) ? JPEG_4[15:8] : JPEG_4[7:0];
		JPEG_5[7:0] <= (JPEG_4[31:24] == 8'b11111111) ? JPEG_4[7:0] : 8'b00000000; 
		ffc_3 <= ffc_2;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		JPEG_4 <= 0; ffc_2 <= 0; 
		end 
	else if (dr_in_3) begin 
		JPEG_4[55:32] <= JPEG_3[47:24]; 
		JPEG_4[31:24] <= (JPEG_3[31:24] == 8'b11111111) ? 8'b00000000 : JPEG_3[23:16];
		JPEG_4[23:16] <= (JPEG_3[31:24] == 8'b11111111) ? JPEG_3[23:16] : JPEG_3[15:8];
		JPEG_4[15:8] <= (JPEG_3[31:24] == 8'b11111111) ? JPEG_3[15:8] : JPEG_3[7:0];
		JPEG_4[7:0] <= (JPEG_3[31:24] == 8'b11111111) ? JPEG_3[7:0] : 8'b00000000; 
		ffc_2 <= ffc_1;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		JPEG_3 <= 0; ct_1 <= 0; FF_count <= 0;
		ffc_1 <= 0; 
		end  
	else if (dr_in_2) begin 
		JPEG_3[47:32] <= JPEG_2[39:24]; 
		JPEG_3[31:24] <= (JPEG_2[31:24] == 8'b11111111) ? 8'b00000000 : JPEG_2[23:16];
		JPEG_3[23:16] <= (JPEG_2[31:24] == 8'b11111111) ? JPEG_2[23:16] : JPEG_2[15:8];
		JPEG_3[15:8] <= (JPEG_2[31:24] == 8'b11111111) ? JPEG_2[15:8] : JPEG_2[7:0];
		JPEG_3[7:0] <= (JPEG_2[31:24] == 8'b11111111) ? JPEG_2[7:0] : 8'b00000000; 
		ct_1 <= count_total;
		FF_count <= FF_count + count_total;
		ffc_1 <= FF_count;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		JPEG_2 <= 0; count_total <= 0; 
		end 
	else if (dr_in_1) begin 
		JPEG_2[39:32] <= JPEG_1[31:24]; 
		JPEG_2[31:24] <= first_2bytes ? 8'b00000000 : JPEG_1[23:16];
		JPEG_2[23:16] <= first_2bytes ? JPEG_1[23:16] : JPEG_1[15:8];
		JPEG_2[15:8] <= first_2bytes ? JPEG_1[15:8] : JPEG_1[7:0];
		JPEG_2[7:0] <= first_2bytes ? JPEG_1[7:0] : 8'b00000000; 
		count_total <= first_2bytes + second_2bytes + third_2bytes + fourth_2bytes;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		first_2bytes <= 0; second_2bytes <= 0; 
		third_2bytes <= 0; fourth_2bytes <= 0;
		JPEG_1 <= 0; 
		end
	else if (data_ready_in) begin 
		first_2bytes <= JPEG_in[31:24] == 8'b11111111;
		second_2bytes <= JPEG_in[23:16] == 8'b11111111;
		third_2bytes <= JPEG_in[15:8] == 8'b11111111;
		fourth_2bytes <= JPEG_in[7:0] == 8'b11111111;
		JPEG_1 <= JPEG_in;
		end
end	

always @(posedge clk)
begin
	if (rst) begin
		rollover_1 <= 0; rollover_2 <= 0; rollover_3 <= 0;
		rollover_4 <= 0; rollover_5 <= 0; 
		end 
	else begin 
		rollover_1 <= rollover; rollover_2 <= rollover_1;
		rollover_3 <= rollover_2; rollover_4 <= rollover_3;
		rollover_5 <= rollover_4; 
		end
end	

always @(posedge clk)
begin
	if (rst) 
		rollover <= 0;
	else if (!dr_in_3) 
		rollover <= 0;
	else if (dr_in_3) 
		rollover <= (FF_count < ffc_1) | (ct_1 == 3'b100);
	// A rollover occurs whenever the next count is less than the current count.
	// FF_count is the next count of how many FF's have been found in the bitstream
	// The count rolls over at 4.  A rollover could also occur if all 32 bits of the
	// are FF's, which would be 4 FF's in the bitstream.  This is the condition where
	// ct_1 == 3'b100.  This is highly unlikely, almost impossible, but it could 
	// theoretically happen.
	// In that case, the next count would equal the current count, and by 
	// comparing the two, you wouldn't get a rollover condition, so you need the extra
	// check of the condition ct_1 == 3'b100.
end	

always @(posedge clk)
begin
	if (rst) begin
		dr_in_1 <= 0; dr_in_2 <= 0; dr_in_3 <= 0; dr_in_4 <= 0;
		dr_in_5 <= 0; dr_in_6 <= 0; dr_in_7 <= 0; dr_in_8 <= 0;
		end
	else begin 
		dr_in_1 <= data_ready_in;
		dr_in_2 <= dr_in_1;
		dr_in_3 <= dr_in_2;
		dr_in_4 <= dr_in_3;
		dr_in_5 <= dr_in_4;
		dr_in_6 <= dr_in_5;
		dr_in_7 <= dr_in_6;
		dr_in_8 <= dr_in_7;
		end
end		   

endmodule