//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Key expansion module                                        ////
////                                                              ////
////  Description:                                                ////
////  Used to expand the key based on key expansion procudure     ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Luo Dongjun,   dongjun_luo@hotmail.com                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
module key_exp (
   clk,
   reset,
   key_in,
   key_mode,
   key_start,
   wr,
   wr_addr,
   wr_data,
   key_ready
);
 
input             clk;
input             reset;
input   [255:0]   key_in;   // initial key value
input   [1:0]     key_mode; // 0:128, 1:192, 2:256
input             key_start;// start key expansion
output            wr;       // key expansion ram interface
output  [4:0]     wr_addr;
output  [63:0]    wr_data;
output            key_ready;
 
reg [31:0]  rcon;
reg         rcon_is_1b;
reg [1:0]   state,nstate,pstate;
reg [3:0]   round;
reg         sbox_in_valid;
reg [31:0]  sbox_in;
reg [4:0]   valid;
wire        sbox_out_valid;
wire [31:0] sbox_out;
wire [31:0] w0_next,w1_next,w2_next,w3_next,w4_next1,w5_next1,w6_next,w7_next;
wire [31:0] w4_next2,w5_next2;
reg [31:0]  w0,w1,w2,w3,w4,w5,w6,w7;
wire        wr1,wr2,wr3,init_wr1,init_wr2,init_wr3,init_wr4;
reg         wr;
wire [63:0] wr_data1,wr_data2,wr_data3;
reg         key_start_L,key_start_L2,key_start_L3;
reg         wr_256;
reg [4:0]   wr_addr;
reg [63:0]  wr_data;
reg         key_ready;
wire   [3:0] max_round_p1;
 
parameter   IDLE       = 2'b00,
            START      = 2'b01,
            GENKEY1    = 2'b10,
            GENKEY_256 = 2'b11;
 
assign max_round_p1[3:0] = (key_mode == 2'b00) ? 4'd11 : (key_mode == 2'b01 ? 4'd13 : 4'd15);
 
// rcon generation
always @ (posedge clk or posedge reset)
begin
   if (reset)
   begin
      rcon[31:0] <= 32'h01000000;
      rcon_is_1b <= 1'b0;
   end
   else if (key_start)
   begin
      rcon[31:0] <= 32'h01000000;
      rcon_is_1b <= 1'b0;
   end
   else if (sbox_out_valid && (state[1:0] == GENKEY1))
   begin
      if (rcon[31])
      begin
         rcon[31:0] <= 32'h1b000000;
         rcon_is_1b <= 1'b1;
      end
      else if (rcon_is_1b)
      begin
         rcon[31:0] <= 32'h36000000;
         rcon_is_1b <= 1'b1;
      end
      else
         rcon[31:0] <= {rcon[30:0],1'b0};
   end
end
 
/*****************************************************************************/
// State machine for Key expansion
//
//
always @ (posedge clk or posedge reset)
begin
   if (reset)   
   begin
      state[1:0]  <= IDLE;
      pstate[1:0] <= IDLE;
   end
   else
   begin
      state[1:0]  <= nstate[1:0];
      pstate[1:0] <= state[1:0];
   end
end
 
always @ (*)
begin
   nstate[1:0] = state[1:0];
   case (state[1:0])
      IDLE: 
         if (key_start) nstate[1:0] = START;
      START:
      begin
         nstate[1:0] = GENKEY1;
      end
      GENKEY1:
      begin
         if (sbox_out_valid)
         begin
            if (key_mode == 2'b00) //128 bit mode 4 x 10 + 4
               if (round[3:0] == 4'd10)   nstate[1:0] = IDLE;
               else                       nstate[1:0] = START;
            else if (key_mode == 2'b01) // 192 bit mode 6 + 6 x 8 = 54 > 52
               if (round[3:0] == 4'd8) nstate[1:0] = IDLE;
               else                    nstate[1:0] = START;
            else if (round[3:0] == 4'd7)// 256 bit mode 8 + 8 x 7 = 64 > 60
               nstate[1:0] = IDLE;
            else
               nstate[1:0] = GENKEY_256;
         end
      end
      GENKEY_256:
      begin
         if (sbox_out_valid)
            nstate[1:0] = START;
      end
   endcase
end
 
// round counter: 10/12/14
always @ (posedge clk or posedge reset)
begin
   if (reset)
      round[3:0] <= 1'b0;
   else if (nstate[1:0] == IDLE)
      round[3:0] <= 4'b0;
   else if (state[1:0] == START)
      round[3:0] <= round[3:0] + 1'b1;
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
   begin
      sbox_in_valid <= 1'b0;
      sbox_in[31:0] <= 32'b0;
   end
   else if (state[1:0] == START) // rotword
   begin
      sbox_in_valid <= 1'b1;
      if (key_mode == 2'b00) //128
         sbox_in[31:0] <= {w3[23:0],w3[31:24]};
      else if (key_mode == 2'b01) //192
         sbox_in[31:0] <= {w5[23:0],w5[31:24]};
      else //256
         sbox_in[31:0] <= {w7[23:0],w7[31:24]};
   end
   else if ((state[1:0] == GENKEY_256) && (pstate[1:0] ==GENKEY1))
   begin
      sbox_in_valid <= 1'b1;
      sbox_in[31:0] <= w3[31:0];
   end
   else
      sbox_in_valid <= 1'b0;
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
      valid[4:0] <= 5'b0;
   else
      valid[4:0] <= {valid[3:0],sbox_in_valid};
end
assign sbox_out_valid = valid[1];
 
sbox u_0(.clk(clk),.reset(reset),.enable(1'b1),.din(sbox_in[7:0]),.ende(1'b0),.en_dout(sbox_out[7:0]),.de_dout());
sbox u_1(.clk(clk),.reset(reset),.enable(1'b1),.din(sbox_in[15:8]),.ende(1'b0),.en_dout(sbox_out[15:8]),.de_dout());
sbox u_2(.clk(clk),.reset(reset),.enable(1'b1),.din(sbox_in[23:16]),.ende(1'b0),.en_dout(sbox_out[23:16]),.de_dout());
sbox u_3(.clk(clk),.reset(reset),.enable(1'b1),.din(sbox_in[31:24]),.ende(1'b0),.en_dout(sbox_out[31:24]),.de_dout());
 
/*****************************************************************************/
// key expansion calculation
//
//
assign w0_next[31:0]  = sbox_out[31:0] ^ rcon[31:0]^w0[31:0];
assign w1_next[31:0]  = w0_next[31:0]  ^ w1[31:0];
assign w2_next[31:0]  = w1_next[31:0]  ^ w2[31:0];
assign w3_next[31:0]  = w2_next[31:0]  ^ w3[31:0];
assign w4_next1[31:0] = w3_next[31:0]  ^ w4[31:0];
assign w5_next1[31:0] = w4_next1[31:0] ^ w5[31:0];
assign w4_next2[31:0] = sbox_out[31:0] ^ w4[31:0];
assign w5_next2[31:0] = w4_next2[31:0] ^ w5[31:0];
assign w6_next[31:0]  = w5_next2[31:0] ^ w6[31:0];
assign w7_next[31:0]  = w6_next[31:0]  ^ w7[31:0];
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
   begin
      {w0[31:0],w1[31:0],w2[31:0],w3[31:0],w4[31:0],w5[31:0],w6[31:0],w7[31:0]} <= 256'b0;
   end
   else if (key_start)
   begin
      {w0[31:0],w1[31:0],w2[31:0],w3[31:0],w4[31:0],w5[31:0],w6[31:0],w7[31:0]} <= key_in[255:0];
   end
   else if ((key_mode[1:0] == 2'b10) && sbox_out_valid)
   begin
      if (state[1:0] == GENKEY1)
      begin
         w0[31:0] <= w0_next[31:0];
         w1[31:0] <= w1_next[31:0];
         w2[31:0] <= w2_next[31:0];
         w3[31:0] <= w3_next[31:0];
      end
      else
      begin
         w4[31:0] <= w4_next2[31:0];
         w5[31:0] <= w5_next2[31:0];
         w6[31:0] <= w6_next[31:0];
         w7[31:0] <= w7_next[31:0];
      end
   end
   else if (sbox_out_valid)
   begin
      w0[31:0] <= w0_next[31:0];
      w1[31:0] <= w1_next[31:0];
      w2[31:0] <= w2_next[31:0];
      w3[31:0] <= w3_next[31:0];
      if (key_mode[1:0] == 2'b01)
      begin
         w4[31:0] <= w4_next1[31:0];
         w5[31:0] <= w5_next1[31:0];
      end
   end
end
 
// write to external ram
assign init_wr1 = key_start;
assign init_wr2 = key_start_L;
assign init_wr3 = key_start_L2 && (key_mode[1:0] != 2'b00);
assign init_wr4 = key_start_L3 && (key_mode[1:0] == 2'b10);
assign wr1 = valid[2];
assign wr2 = valid[3];
assign wr3 = valid[4] && (key_mode[1:0] == 2'b01) && (state[1:0] != IDLE); // remove the last write 
 
assign wr_data1[63:0] = wr_256 ?{w4[31:0],w5[31:0]} : {w0[31:0],w1[31:0]};
assign wr_data2[63:0] = wr_256 ?{w6[31:0],w7[31:0]} : {w2[31:0],w3[31:0]};
assign wr_data3[63:0] = {w4[31:0],w5[31:0]};
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
      wr_256 <= 1'b0;
   else if (key_start)
      wr_256 <= 1'b0;
   else if (sbox_out_valid && (state[1:0] == GENKEY_256))
      wr_256 <= 1'b1;
   else if (sbox_out_valid)
      wr_256 <= 1'b0;
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
      {key_start_L3,key_start_L2,key_start_L} <= 3'b0;
   else
      {key_start_L3,key_start_L2,key_start_L} <= {key_start_L2,key_start_L,key_start};
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
      wr <= 1'b0;
   else 
      wr <= wr1 || wr2 || wr3 || init_wr1 || init_wr2 || init_wr3 || init_wr4;
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
   begin
      wr_data[63:0] <= 64'b0;
   end
   else
   begin
      if (init_wr1)
         wr_data[63:0] <= key_in[255:192];
      else if (init_wr2)
         wr_data[63:0] <= key_in[191:128];
      else if (init_wr3)
         wr_data[63:0] <= key_in[127:64];
      else if (init_wr4)
         wr_data[63:0] <= key_in[63:0];
      else if (wr1)
         wr_data[63:0] <= wr_data1[63:0];
      else if (wr2)
         wr_data[63:0] <= wr_data2[63:0];
      else if (wr3)
         wr_data[63:0] <= wr_data3[63:0];
   end
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
      wr_addr[4:0] <= 5'b0;
   else if (key_start)
      wr_addr[4:0] <= 5'd0;
   else if (wr)
      wr_addr[4:0] <= wr_addr[4:0] + 1'b1;
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
      key_ready <= 1'b0;
   else if (key_start)
      key_ready <= 1'b0;
   else if (wr_addr[4:1] == max_round_p1[3:0])
      key_ready <= 1'b1;
end
endmodule
