//---------------------------------------------------------------------------------------
// 
//	AES core top module 
// 
//	Description: 
//		AES core top module with direct interface to key and data buses. 
// 
//	To Do: 
//		- done 
//
//	Author(s):
//		- Luo Dongjun,   dongjun_luo@hotmail.com 
//
//---------------------------------------------------------------------------------------

// uncomment the following define to enable use of distributed RAM implementation 
// for XILINX FPGAs instead of block memory.
// NOTE: when commenting the following define, core size is slightly smaller but maximum 
// achievable clock frequency is also slightly lower. 
`define XILINX		1 

module aes (
	clk, reset,
	i_start, i_enable,
	i_ende, i_key,
	i_key_mode, i_data,
	i_data_valid, o_ready, 
	o_data, o_data_valid, 
	o_key_ready
);
 
//---------------------------------------------------------------------------------------
// module interfaces 
input			clk;		// core global clock 
input			reset;		// core global async reset control 
input			i_start;	// key expansion start pulse 
input			i_enable;	// enable encryption / decryption core operation 
input	[1:0]	i_key_mode; // key length: 0 => 128; 1 => 192; 2 => 256
input	[255:0]	i_key; 		// if key size is 128/192, upper bits are the inputs 
input	[127:0]	i_data;		// plain/cipher text data input 
input			i_data_valid;	// data input valid 
input			i_ende;		// core mode of operation: 0 => encryption; 1 => decryption
output			o_ready;	// indicates core is ready for new input data at the next clock cycle 
output	[127:0]	o_data;		// data output 
output			o_data_valid;	// data output valid 
output			o_key_ready;	// key expansion procedure done 

//---------------------------------------------------------------------------------------
// module registers and signals 
genvar i;
wire           final_round;
reg   [3:0]    max_round;
wire  [127:0]  en_sb_data,de_sb_data,sr_data,mc_data,imc_data,ark_data;
reg   [127:0]  sb_data,o_data,i_data_L;
reg            i_data_valid_L;
reg            round_valid;
reg   [2:0]    sb_valid;
reg            o_data_valid;
reg   [3:0]    round_cnt,sb_round_cnt1,sb_round_cnt2,sb_round_cnt3;
wire  [127:0]  round_key;
wire  [63:0]   rd_data0,rd_data1;
wire           wr;
wire  [4:0]    wr_addr;
wire  [63:0]   wr_data;
wire  [127:0]  imc_round_key,en_ark_data,de_ark_data,ark_data_final,ark_data_init;

//---------------------------------------------------------------------------------------
// module implementation 
assign final_round = sb_round_cnt3[3:0] == max_round[3:0];
//assign o_ready = ~sb_valid[1]; // if ready is asserted, user can input data for the same cycle
assign o_ready = ~sb_valid[0]; // if ready is asserted, user can input data for the next cycle
 
// round count is Nr - 1
always @ (*)
begin
   case (i_key_mode)
      2'b00: max_round[3:0] = 4'd10;
      2'b01: max_round[3:0] = 4'd12;
      default: max_round[3:0] = 4'd14;
   endcase
end
 
//---------------------------------------------------------------------------------------
// Sub Bytes
//
//
generate
for (i=0;i<16;i=i+1)
begin : sbox_block
   sbox u_sbox (
      .clk(clk),
      .reset(reset),
      .enable(i_enable),
      .ende(i_ende),
      .din(o_data[i*8+7:i*8]),
      .en_dout(en_sb_data[i*8+7:i*8]),
      .de_dout(de_sb_data[i*8+7:i*8])
   );
end
endgenerate
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
      sb_data[127:0] <= 128'b0;
   else if (i_enable)
      sb_data[127:0] <= i_ende ? de_sb_data[127:0] : en_sb_data[127:0];
end
 
//---------------------------------------------------------------------------------------
// Shift Rows
//
//
wire [127:0] shrows, ishrows;

shift_rows u_shrows (.si(sb_data[127:0]), .so(shrows));
inv_shift_rows u_ishrows (.si(sb_data[127:0]), .so(ishrows));

assign sr_data[127:0] = i_ende ? ishrows : shrows;
 
//---------------------------------------------------------------------------------------
// Mix Columns
//
//
mix_columns mxc_u (.in(sr_data), .out(mc_data));
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
   begin
      i_data_valid_L  <= 1'b0;
      i_data_L[127:0] <= 128'b0;
   end
   else
   begin
      i_data_valid_L  <= i_data_valid;
      i_data_L[127:0] <=i_data[127:0];
   end
end
 
//---------------------------------------------------------------------------------------
// Inverse Mix Columns
//
//
inv_mix_columns imxc_u (.in(sr_data), .out(imc_data));

//---------------------------------------------------------------------------------------
// add round key for decryption
//
inv_mix_columns imxk_u (.in(round_key), .out(imc_round_key));

assign ark_data_final[127:0] = sr_data[127:0] ^ round_key[127:0];
assign ark_data_init[127:0] = i_data_L[127:0] ^ round_key[127:0];
assign en_ark_data[127:0] = mc_data[127:0] ^ round_key[127:0];
assign de_ark_data[127:0] = imc_data[127:0] ^ imc_round_key[127:0];
assign ark_data[127:0] = i_data_valid_L ? ark_data_init[127:0] : 
                           (final_round ? ark_data_final[127:0] : 
                                (i_ende ? de_ark_data[127:0] : en_ark_data[127:0]));
 
//---------------------------------------------------------------------------------------
// Data outputs after each round
//
always @ (posedge clk or posedge reset)
begin
   if (reset)
      o_data[127:0] <= 128'b0;
   else if (i_enable && (i_data_valid_L || sb_valid[2]))
      o_data[127:0] <= ark_data[127:0];
end
 
//---------------------------------------------------------------------------------------
// in sbox, we have 3 stages (sb_valid),
// before the end of each round, we have another stage (round_valid)
//
always @ (posedge clk or posedge reset)
begin
   if (reset)
   begin
      round_valid  <= 1'b0;
      sb_valid[2:0] <= 3'b0;
      o_data_valid  <= 1'b0;
   end
   else if (i_enable)
   begin
      o_data_valid  <= sb_valid[2] && final_round;
      round_valid   <= (sb_valid[2] && !final_round) || i_data_valid_L;
      sb_valid[2:0] <= {sb_valid[1:0],round_valid};
   end
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)                      round_cnt[3:0] <= 4'd0;
   else if (i_data_valid_L) round_cnt[3:0] <= 4'd1;
   else if (i_enable && sb_valid[2])  round_cnt[3:0] <= sb_round_cnt3[3:0] + 1'b1;
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
   begin
      sb_round_cnt1[3:0] <= 4'd0;
      sb_round_cnt2[3:0] <= 4'd0;
      sb_round_cnt3[3:0] <= 4'd0;
   end
   else if (i_enable)
   begin
      if (round_valid) sb_round_cnt1[3:0] <= round_cnt[3:0];
      if (sb_valid[0]) sb_round_cnt2[3:0] <= sb_round_cnt1[3:0];
      if (sb_valid[1]) sb_round_cnt3[3:0] <= sb_round_cnt2[3:0];
   end
end
 
//---------------------------------------------------------------------------------------
// round key generation: the expansion keys are stored in 4 16*32 rams or 
// 2 16*64 rams or 1 16*128 rams
//
//assign rd_addr[3:0] = i_ende ? (max_round[3:0] - sb_round_cnt2[3:0]) : sb_round_cnt2[3:0];

assign round_key[127:0] = {rd_data0[63:0],rd_data1[63:0]};

`ifdef XILINX 
reg [3:0] rd_addr;

always @ (posedge clk or posedge reset)
begin 
	if (reset)
		rd_addr <= 4'b0;
	else if (sb_valid[1] | i_data_valid) 
	begin 
		if (i_ende) 
		begin 
			if (i_data_valid)
				rd_addr <= max_round[3:0];
			else 
				rd_addr <= max_round[3:0] - sb_round_cnt2[3:0];
		end 
		else 
		begin 
			if (i_data_valid) 
				rd_addr <= 4'b0;
			else 
				rd_addr <= sb_round_cnt2[3:0];
		end 
	end 
end 

xram_16x64 u_ram_0 
(
	.clk(clk),
	.wr(wr & ~wr_addr[0]),
	.wr_addr(wr_addr[4:1]),
	.wr_data(wr_data[63:0]),
	.rd_addr(rd_addr[3:0]),
	.rd_data(rd_data0[63:0])
);
xram_16x64 u_ram_1 
(
	.clk(clk),
	.wr(wr & wr_addr[0]),
	.wr_addr(wr_addr[4:1]),
	.wr_data(wr_data[63:0]),
	.rd_addr(rd_addr[3:0]),
	.rd_data(rd_data1[63:0])
);
`else 
wire [3:0] rd_addr;

assign rd_addr[3:0] = i_ende ? (i_data_valid ? max_round[3:0] : (max_round[3:0] - sb_round_cnt2[3:0])) : 
                               (i_data_valid ? 4'b0 : sb_round_cnt2[3:0]);

ram_16x64 u_ram_0 
(
	.clk(clk),
	.wr(wr & ~wr_addr[0]),
	.wr_addr(wr_addr[4:1]),
	.wr_data(wr_data[63:0]),
	.rd_addr(rd_addr[3:0]),
	.rd_data(rd_data0[63:0]),
	.rd(sb_valid[1] | i_data_valid)
);
ram_16x64 u_ram_1 
(
	.clk(clk),
	.wr(wr & wr_addr[0]),
	.wr_addr(wr_addr[4:1]),
	.wr_data(wr_data[63:0]),
	.rd_addr(rd_addr[3:0]),
	.rd_data(rd_data1[63:0]),
	.rd(sb_valid[1] | i_data_valid)
);
`endif 
//---------------------------------------------------------------------------------------
// Key Expansion module
//
//
key_exp u_key_exp (
   .clk(clk),
   .reset(reset),
   .key_in(i_key[255:0]),
   .key_mode(i_key_mode[1:0]),
   .key_start(i_start),
   .wr(wr),
   .wr_addr(wr_addr[4:0]),
   .wr_data(wr_data[63:0]),
   .key_ready(o_key_ready)
);
 
endmodule
//---------------------------------------------------------------------------------------
