`timescale 1ns / 1ns
module tdm_switch_top (
                       clk_in,
                       clk_out,
                       frame_sync,
                       rx_stream,
                       tx_stream,
                       reset,
                       mpi_clk,
                       mpi_cs,
                       mpi_rw,
                       mpi_addr,
                       mpi_data_in,
                       mpi_data_out
                      );

//=======================================================================================
//====================== IO PORT DESCRIPTION ============================================

input		clk_in;
output		clk_out;
output		frame_sync;

input		[7:0] rx_stream;
output		[7:0] tx_stream;

input		reset;

input		mpi_clk;
input		mpi_cs;
input		mpi_rw;
input		[8:0] mpi_addr;
input		[8:0] mpi_data_in;
output		[8:0] mpi_data_out;

//=======================================================================================
//====================== PARAMETER DESCRIPTION ==========================================

parameter pu = 1'b1;
parameter pd = 1'b0;

//=======================================================================================
//====================== REGISTER DESCRIPTION ===========================================

reg		[7:0] rx_shift_reg_0;
reg		[7:0] rx_shift_reg_1;
reg		[7:0] rx_shift_reg_2;
reg		[7:0] rx_shift_reg_3;
reg		[7:0] rx_shift_reg_4;
reg		[7:0] rx_shift_reg_5;
reg		[7:0] rx_shift_reg_6;
reg		[7:0] rx_shift_reg_7;

reg		[7:0] tx_shift_reg_0;
reg		[7:0] tx_shift_reg_1;
reg		[7:0] tx_shift_reg_2;
reg		[7:0] tx_shift_reg_3;
reg		[7:0] tx_shift_reg_4;
reg		[7:0] tx_shift_reg_5;
reg		[7:0] tx_shift_reg_6;
reg		[7:0] tx_shift_reg_7;

reg		[7:0] rx_buf_reg_0;
reg		[7:0] rx_buf_reg_1;
reg		[7:0] rx_buf_reg_2;
reg		[7:0] rx_buf_reg_3;
reg		[7:0] rx_buf_reg_4;
reg		[7:0] rx_buf_reg_5;
reg		[7:0] rx_buf_reg_6;
reg		[7:0] rx_buf_reg_7;

reg		[7:0] tx_buf_reg_0;
reg		[7:0] tx_buf_reg_1;
reg		[7:0] tx_buf_reg_2;
reg		[7:0] tx_buf_reg_3;
reg		[7:0] tx_buf_reg_4;
reg		[7:0] tx_buf_reg_5;
reg		[7:0] tx_buf_reg_6;
reg		[7:0] tx_buf_reg_7;

reg		[1:0] frame_delay_cnt_0;
reg		[1:0] frame_delay_cnt_1;
reg		[1:0] frame_delay_cnt_2;
reg		[1:0] frame_delay_cnt_3;
reg		[1:0] frame_delay_cnt_4;
reg		[1:0] frame_delay_cnt_5;
reg		[1:0] frame_delay_cnt_6;
reg		[1:0] frame_delay_cnt_7;

reg		[1:0] frame_delay_buf_0;
reg		[1:0] frame_delay_buf_1;
reg		[1:0] frame_delay_buf_2;
reg		[1:0] frame_delay_buf_3;
reg		[1:0] frame_delay_buf_4;
reg		[1:0] frame_delay_buf_5;
reg		[1:0] frame_delay_buf_6;
reg		[1:0] frame_delay_buf_7;

reg		div_reg;
reg		[8:0] frame_cnt;
reg		[4:0] c_mem_addr_cnt;
reg		[4:0] d_mem_addr_cnt;
reg		[15:0] data_in_bus;
reg		[1:0] ctrl_out_reg;
reg		mem_page_sel;

//=======================================================================================
//====================== WIRE DESCRIPTION ===============================================

wire		clk_4096k;
wire		clk_2048k;
wire		frame_8k;
wire		g_rst;

wire		tx_sr_load;
wire		rx_buf_load;

wire		load_rx_buf_0;
wire		load_rx_buf_1;
wire		load_rx_buf_2;
wire		load_rx_buf_3;
wire		load_rx_buf_4;
wire		load_rx_buf_5;
wire		load_rx_buf_6;
wire		load_rx_buf_7;

wire		tx_buf_wen;
wire		data_wen;
wire		cd_en;

wire		[7:0] d_mem_addr;
wire		[1:0] d_mem_low_addr;
wire		[4:0] d_mem_high_addr;

wire		[7:0] c_mem_addr;
wire		[2:0] c_mem_low_addr;
wire		[4:0] c_mem_high_addr;

wire		[7:0] data_out_bus;

wire		[2:0] tx_buf_addr;

wire		[8:0] cd_mem_addr;
wire		[15:0] cd_data;

wire		ram_en;

wire		[15:0] mpi_mem_bus_in;
wire		[15:0] mpi_mem_bus_out;

wire		[1:0] ctrl_in;
wire		[1:0] ctrl_out;

//=======================================================================================
//====================== IO AND CLK BUFFERS =============================================

assign g_rst = reset;
assign clk_4096k = clk_in;
assign clk_2048k = div_reg;
assign clk_out = clk_2048k;
assign frame_sync = frame_8k;

always @ (posedge clk_4096k or negedge g_rst)
    if (!g_rst)
       div_reg <= 0;
     else
       div_reg <= ~div_reg;

//=======================================================================================
//====================== FRAME SYNC GENERATION ==========================================

always @ (negedge clk_4096k or negedge g_rst)
    if (!g_rst)
       frame_cnt <= 0;
     else
       frame_cnt <= frame_cnt + 1;

assign frame_8k = (frame_cnt == 9'h00A) ? 1'b1 : 1'b0;

//=======================================================================================
//====================== SYNC SIGNALS FOR INPUT STREAMS =================================

assign rx_buf_load = (frame_cnt[3:0] == 4'hA) ? 1'b1 : 1'b0;

always @ (negedge clk_2048k or posedge rx_buf_load)
    if (rx_buf_load)
       begin
         frame_delay_cnt_0 <= frame_delay_buf_0 + 1;
         frame_delay_cnt_1 <= frame_delay_buf_1 + 1;
         frame_delay_cnt_2 <= frame_delay_buf_2 + 1;
         frame_delay_cnt_3 <= frame_delay_buf_3 + 1;
         frame_delay_cnt_4 <= frame_delay_buf_4 + 1;
         frame_delay_cnt_5 <= frame_delay_buf_5 + 1;
         frame_delay_cnt_6 <= frame_delay_buf_6 + 1;
         frame_delay_cnt_7 <= frame_delay_buf_7 + 1;
       end
     else
       begin
         if (frame_delay_cnt_0 == 0)
            frame_delay_cnt_0 <= frame_delay_cnt_0;
          else
            frame_delay_cnt_0 <= frame_delay_cnt_0 + 2'b11;
            
         if (frame_delay_cnt_1 == 0)
            frame_delay_cnt_1 <= frame_delay_cnt_1;
          else
            frame_delay_cnt_1 <= frame_delay_cnt_1 + 2'b11;
            
         if (frame_delay_cnt_2 == 0)
            frame_delay_cnt_2 <= frame_delay_cnt_2;
          else
            frame_delay_cnt_2 <= frame_delay_cnt_2 + 2'b11;
            
         if (frame_delay_cnt_3 == 0)
            frame_delay_cnt_3 <= frame_delay_cnt_3;
          else
            frame_delay_cnt_3 <= frame_delay_cnt_3 + 2'b11;
            
         if (frame_delay_cnt_4 == 0)
            frame_delay_cnt_4 <= frame_delay_cnt_4;
          else
            frame_delay_cnt_4 <= frame_delay_cnt_4 + 2'b11;
            
         if (frame_delay_cnt_5 == 0)
            frame_delay_cnt_5 <= frame_delay_cnt_5;
          else
            frame_delay_cnt_5 <= frame_delay_cnt_5 + 2'b11;
            
         if (frame_delay_cnt_6 == 0)
            frame_delay_cnt_6 <= frame_delay_cnt_6;
          else
            frame_delay_cnt_6 <= frame_delay_cnt_6 + 2'b11;
            
         if (frame_delay_cnt_7 == 0)
            frame_delay_cnt_7 <= frame_delay_cnt_7;
          else
            frame_delay_cnt_7 <= frame_delay_cnt_7 + 2'b11;
       end

assign load_rx_buf_0 = (frame_delay_cnt_0 == 2'b01) ? 1'b1 : 1'b0;
assign load_rx_buf_1 = (frame_delay_cnt_1 == 2'b01) ? 1'b1 : 1'b0;
assign load_rx_buf_2 = (frame_delay_cnt_2 == 2'b01) ? 1'b1 : 1'b0;
assign load_rx_buf_3 = (frame_delay_cnt_3 == 2'b01) ? 1'b1 : 1'b0;
assign load_rx_buf_4 = (frame_delay_cnt_4 == 2'b01) ? 1'b1 : 1'b0;
assign load_rx_buf_5 = (frame_delay_cnt_5 == 2'b01) ? 1'b1 : 1'b0;
assign load_rx_buf_6 = (frame_delay_cnt_6 == 2'b01) ? 1'b1 : 1'b0;
assign load_rx_buf_7 = (frame_delay_cnt_7 == 2'b01) ? 1'b1 : 1'b0;

//=======================================================================================
//====================== SERIAL INPUT TO PARALLEL CONVERTIONS ===========================

always @ (negedge clk_2048k)
    begin
      rx_shift_reg_0 <= {rx_stream[0], rx_shift_reg_0[7:1]};
      rx_shift_reg_1 <= {rx_stream[1], rx_shift_reg_1[7:1]};
      rx_shift_reg_2 <= {rx_stream[2], rx_shift_reg_2[7:1]};
      rx_shift_reg_3 <= {rx_stream[3], rx_shift_reg_3[7:1]};
      rx_shift_reg_4 <= {rx_stream[4], rx_shift_reg_4[7:1]};
      rx_shift_reg_5 <= {rx_stream[5], rx_shift_reg_5[7:1]};
      rx_shift_reg_6 <= {rx_stream[6], rx_shift_reg_6[7:1]};
      rx_shift_reg_7 <= {rx_stream[7], rx_shift_reg_7[7:1]};
    end

//=======================================================================================
//====================== Rx BUFFER LOAD =================================================

always @ (posedge clk_2048k)
    if (load_rx_buf_0)
       rx_buf_reg_0 <= rx_shift_reg_0;
     else
       rx_buf_reg_0 <= rx_buf_reg_0;

always @ (posedge clk_2048k)
    if (load_rx_buf_1)
       rx_buf_reg_1 <= rx_shift_reg_1;
     else
       rx_buf_reg_1 <= rx_buf_reg_1;

always @ (posedge clk_2048k)
    if (load_rx_buf_2)
       rx_buf_reg_2 <= rx_shift_reg_2;
     else
       rx_buf_reg_2 <= rx_buf_reg_2;

always @ (posedge clk_2048k)
    if (load_rx_buf_3)
       rx_buf_reg_3 <= rx_shift_reg_3;
     else
       rx_buf_reg_3 <= rx_buf_reg_3;

always @ (posedge clk_2048k)
    if (load_rx_buf_4)
       rx_buf_reg_4 <= rx_shift_reg_4;
     else
       rx_buf_reg_4 <= rx_buf_reg_4;

always @ (posedge clk_2048k)
    if (load_rx_buf_5)
       rx_buf_reg_5 <= rx_shift_reg_5;
     else
       rx_buf_reg_5 <= rx_buf_reg_5;

always @ (posedge clk_2048k)
    if (load_rx_buf_6)
       rx_buf_reg_6 <= rx_shift_reg_6;
     else
       rx_buf_reg_6 <= rx_buf_reg_6;

always @ (posedge clk_2048k)
    if (load_rx_buf_7)
       rx_buf_reg_7 <= rx_shift_reg_7;
     else
       rx_buf_reg_7 <= rx_buf_reg_7;

//=======================================================================================
//====================== PARALLEL TO SERIAL OUTPUT CONVERTIONS ==========================

assign tx_sr_load = (frame_cnt[3:0] == 4'hA) ? 1'b1 : 1'b0;

always @ (posedge clk_2048k)
    if (tx_sr_load)
       begin
         tx_shift_reg_0 <= tx_buf_reg_0;
         tx_shift_reg_1 <= tx_buf_reg_1;
         tx_shift_reg_2 <= tx_buf_reg_2;
         tx_shift_reg_3 <= tx_buf_reg_3;
         tx_shift_reg_4 <= tx_buf_reg_4;
         tx_shift_reg_5 <= tx_buf_reg_5;
         tx_shift_reg_6 <= tx_buf_reg_6;
         tx_shift_reg_7 <= tx_buf_reg_7;
       end
     else
       begin
         tx_shift_reg_0 <= {1'b0, tx_shift_reg_0[7:1]};
         tx_shift_reg_1 <= {1'b0, tx_shift_reg_1[7:1]};
         tx_shift_reg_2 <= {1'b0, tx_shift_reg_2[7:1]};
         tx_shift_reg_3 <= {1'b0, tx_shift_reg_3[7:1]};
         tx_shift_reg_4 <= {1'b0, tx_shift_reg_4[7:1]};
         tx_shift_reg_5 <= {1'b0, tx_shift_reg_5[7:1]};
         tx_shift_reg_6 <= {1'b0, tx_shift_reg_6[7:1]};
         tx_shift_reg_7 <= {1'b0, tx_shift_reg_7[7:1]};
       end

assign tx_stream[0] = tx_shift_reg_0[0];
assign tx_stream[1] = tx_shift_reg_1[0];
assign tx_stream[2] = tx_shift_reg_2[0];
assign tx_stream[3] = tx_shift_reg_3[0];
assign tx_stream[4] = tx_shift_reg_4[0];
assign tx_stream[5] = tx_shift_reg_5[0];
assign tx_stream[6] = tx_shift_reg_6[0];
assign tx_stream[7] = tx_shift_reg_7[0];

//=======================================================================================
//====================== Tx BUFFER LOAD =================================================

assign tx_buf_addr = frame_cnt[2:0] + 3'b110;
assign tx_buf_wen = ((frame_cnt[3:0] > 4'h1) & (frame_cnt[3:0] < 4'hA)) ? 1'b1 : 1'b0;

always @ (posedge clk_4096k)
    case ({tx_buf_wen, tx_buf_addr})
      4'h8 : tx_buf_reg_0 <= data_out_bus;
      4'h9 : tx_buf_reg_1 <= data_out_bus;
      4'hA : tx_buf_reg_2 <= data_out_bus;
      4'hB : tx_buf_reg_3 <= data_out_bus;
      4'hC : tx_buf_reg_4 <= data_out_bus;
      4'hD : tx_buf_reg_5 <= data_out_bus;
      4'hE : tx_buf_reg_6 <= data_out_bus;
      4'hF : tx_buf_reg_7 <= data_out_bus;
    endcase

//=======================================================================================
//====================== DATA MEMORY ADDRESS GENERATION =================================

assign d_mem_addr = {mem_page_sel, d_mem_high_addr, d_mem_low_addr};

assign d_mem_high_addr = d_mem_addr_cnt;

assign d_mem_low_addr = frame_cnt[2:1] + 2'b11;

always @ (posedge clk_2048k or negedge g_rst)
    if (!g_rst)
       mem_page_sel <= 0;
     else
       if (frame_8k)
          mem_page_sel <= ~mem_page_sel;
        else
          mem_page_sel <= mem_page_sel;
     

always @ (posedge clk_2048k)
    if (tx_sr_load & frame_8k)
       d_mem_addr_cnt <= 5'h1F;
     else
       if (tx_sr_load)
          d_mem_addr_cnt <= d_mem_addr_cnt + 1;
        else
          d_mem_addr_cnt <= d_mem_addr_cnt;

//=======================================================================================
//====================== CONNECTION MEMORY ADDRESS GENERATION ===========================

assign c_mem_addr = {c_mem_high_addr, c_mem_low_addr};

assign c_mem_high_addr = c_mem_addr_cnt;

assign c_mem_low_addr = frame_cnt[2:0];

always @ (posedge clk_2048k)
    if (rx_buf_load & frame_8k)
       c_mem_addr_cnt <= 5'h01;
     else
       if (rx_buf_load)
          c_mem_addr_cnt <= c_mem_addr_cnt + 1;
        else
          c_mem_addr_cnt <= c_mem_addr_cnt;

//=======================================================================================
//====================== DATA MEMORY MODULE =============================================

always @ (d_mem_addr[1:0], rx_buf_reg_7, rx_buf_reg_6, rx_buf_reg_5, rx_buf_reg_4, rx_buf_reg_3, rx_buf_reg_2, rx_buf_reg_1, rx_buf_reg_0)
    case (d_mem_addr[1:0])
       2'b00 : data_in_bus = {rx_buf_reg_1, rx_buf_reg_0};
       2'b01 : data_in_bus = {rx_buf_reg_3, rx_buf_reg_2};
       2'b10 : data_in_bus = {rx_buf_reg_5, rx_buf_reg_4};
     default : data_in_bus = {rx_buf_reg_7, rx_buf_reg_6};
    endcase

assign cd_mem_addr = {~mem_page_sel, cd_data[7:0]};
assign data_wen = ((frame_cnt[3:0] > 4'h1) & (frame_cnt[3:0] < 4'hA)) ? 1'b1 : 1'b0;
assign cd_en = (frame_cnt[3:0] < 4'h8) ? 1'b1 : 1'b0;

RAMB4_S8_S16 d_mem (
                    .DOA (data_out_bus),
                    .DOB (),
                    .ADDRA (cd_mem_addr),
                    .ADDRB (d_mem_addr),
                    .CLKA (clk_4096k),
                    .CLKB (clk_2048k),
                    .DIA ({8{pd}}),
                    .DIB (data_in_bus),
                    .ENA (pu),
                    .ENB (data_wen),
                    .RSTA (~g_rst),
                    .RSTB (~g_rst),
                    .WEA (pd),
                    .WEB (pu)
                   );

//=======================================================================================
//====================== CONNECTION MEMORY MODULE =======================================

assign mpi_data_out = (mpi_cs & ~mpi_addr[8]) ? mpi_mem_bus_out[8:0] :
                      (mpi_cs & mpi_addr[8]) ? {7'h00, ctrl_out} : 9'hzzz;
                      
assign mpi_mem_bus_in = {{7{pd}}, mpi_data_in};
assign ram_en = mpi_cs & ~mpi_addr[8];

RAMB4_S16_S16 c_mem (
                     .DOA (cd_data),
                     .DOB (mpi_mem_bus_out),
                     .ADDRA (c_mem_addr),
                     .ADDRB (mpi_addr[7:0]),
                     .CLKA (clk_4096k),
                     .CLKB (mpi_clk),
                     .DIA ({16{pd}}),
                     .DIB (mpi_mem_bus_in),
                     .ENA (cd_en),
                     .ENB (ram_en),
                     .RSTA (~g_rst),
                     .RSTB (~g_rst),
                     .WEA (pd),
                     .WEB (~mpi_rw)
                    );

//=======================================================================================
//====================== ================================================================

assign ctrl_in = mpi_data_in[1:0];

always @ (posedge mpi_clk)
   case ({mpi_rw, mpi_cs, mpi_addr[8], mpi_addr[3:0]})
	  7'b0110000 : frame_delay_buf_0 <= ctrl_in;
	  7'b0110001 : frame_delay_buf_1 <= ctrl_in;
	  7'b0110010 : frame_delay_buf_2 <= ctrl_in;
	  7'b0110011 : frame_delay_buf_3 <= ctrl_in;
	  7'b0110100 : frame_delay_buf_4 <= ctrl_in;
	  7'b0110101 : frame_delay_buf_5 <= ctrl_in;
	  7'b0110110 : frame_delay_buf_6 <= ctrl_in;
	  7'b0110111 : frame_delay_buf_7 <= ctrl_in;
	  //5'b01000 : clk_edge <= delay_in[0];
	  //5'b01001 : fs_edge	<= delay_in[0];
	endcase

always @ (posedge mpi_clk)
   case ({mpi_cs, mpi_addr[8], mpi_addr[3:0]})
	  6'b110000 : ctrl_out_reg <= frame_delay_buf_0;
	  6'b110001 : ctrl_out_reg <= frame_delay_buf_1;
	  6'b110010 : ctrl_out_reg <= frame_delay_buf_2;
	  6'b110011 : ctrl_out_reg <= frame_delay_buf_3;
	  6'b110100 : ctrl_out_reg <= frame_delay_buf_4;
	  6'b110101 : ctrl_out_reg <= frame_delay_buf_5;
	  6'b110110 : ctrl_out_reg <= frame_delay_buf_6;
	  6'b110111 : ctrl_out_reg <= frame_delay_buf_7;
	  //5'b11000 : delay_reg[0] <= clk_edge;
	  //5'b11001 : delay_reg[0] <= fs_edge;
	endcase

assign	ctrl_out = ctrl_out_reg;

//=======================================================================================
//====================== ================================================================
/*
initial
   begin
     frame_delay_buf_0 = 0;
     frame_delay_buf_1 = 0;
     frame_delay_buf_2 = 0;
     frame_delay_buf_3 = 0;
     frame_delay_buf_4 = 0;
     frame_delay_buf_5 = 0;
     frame_delay_buf_6 = 0;
     frame_delay_buf_7 = 0;
   end
*/
//=======================================================================================

endmodule