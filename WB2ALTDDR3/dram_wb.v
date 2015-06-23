`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  (C) Athree, 2009
// Engineer: Dmitry Rozhdestvenskiy 
// Email dmitry.rozhdestvenskiy@srisc.com dmitryr@a3.spb.ru divx4log@narod.ru
// 
// Design Name:    Bridge from Wishbone to Altera DDR3 controller
// Module Name:    wb2altddr3 
// Project Name:   SPARC SoC single-core
//
// LICENSE:
// This is a Free Hardware Design; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// version 2 as published by the Free Software Foundation.
// The above named program is distributed in the hope that it will
// be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
//////////////////////////////////////////////////////////////////////////////////

module dram_wb(
   input             clk200,
   input             rup,
   input             rdn,

   input             wb_clk_i,
   input             wb_rst_i,
    
   input      [63:0] wb_dat_i, 
   output reg [63:0] wb_dat_o, 
   input      [63:0] wb_adr_i, 
   input      [ 7:0] wb_sel_i, 
   input             wb_we_i, 
   input             wb_cyc_i, 
   input             wb_stb_i, 
   output            wb_ack_o, 
   output            wb_err_o, 
   output            wb_rty_o, 
   input             wb_cab_i, 

   inout      [63:0] ddr3_dq,
   inout      [ 7:0] ddr3_dqs,
   inout      [ 7:0] ddr3_dqs_n,
   inout             ddr3_ck,
   inout             ddr3_ck_n,
   output            ddr3_reset,
   output     [12:0] ddr3_a,
   output     [ 2:0] ddr3_ba,
   output            ddr3_ras_n,
   output            ddr3_cas_n,
   output            ddr3_we_n,
   output            ddr3_cs_n,
   output            ddr3_odt,
   output            ddr3_ce,
   output     [ 7:0] ddr3_dm,

   output            phy_init_done,
   
   output     [ 7:0] fifo_used,
    
   input             dcm_locked,
   input             sysrst
);

wire [255:0] rd_data_fifo_out;
reg  [ 23:0] rd_addr_cache;
wire [ 71:0] wr_dout;
wire [ 31:0] cmd_out;
reg          wb_stb_i_d;
reg  [ 31:0] mask_data;

wire fifo_empty;

wire [13:0] parallelterminationcontrol;
wire [13:0] seriesterminationcontrol;

dram dram_ctrl(
    .pll_ref_clk(clk200),
    .global_reset_n(sysrst),  // Resets all
    .soft_reset_n(1),    // Resets all but PLL
    
    .reset_request_n(), // Active when not ready (PLL not locked)
    .reset_phy_clk_n(), // Reset input sync to phy_clk

    .phy_clk(ddr_clk),         // User clock
    .dll_reference_clk(), // For external DLL

    .dqs_delay_ctrl_export(),
    .aux_scan_clk(),
    .aux_scan_clk_reset_n(),
    .aux_full_rate_clk(),
    .aux_half_rate_clk(),
    
    .oct_ctl_rs_value(seriesterminationcontrol),
    .oct_ctl_rt_value(parallelterminationcontrol),

    .local_init_done(phy_init_done),

    .local_ready(dram_ready),
    .local_address(cmd_out[25:2]),
    .local_burstbegin(push_tran),
    .local_read_req(!cmd_out[31] && push_tran),
    .local_write_req(cmd_out[31] && push_tran),
    .local_wdata_req(),
    .local_wdata({wr_dout[63:0],wr_dout[63:0],wr_dout[63:0],wr_dout[63:0]}),
    .local_be(mask_data),
    .local_size(3'b001),
    .local_rdata_valid(rd_data_valid),
    .local_rdata(rd_data_fifo_out),
    .local_refresh_ack(),
    
    .mem_clk(ddr3_ck),
    .mem_clk_n(ddr3_ck_n),
    .mem_reset_n(ddr3_reset),
    .mem_dq(ddr3_dq),
    .mem_dqs(ddr3_dqs),
    .mem_dqsn(ddr3_dqs_n),
    .mem_odt(ddr3_odt),
    .mem_cs_n(ddr3_cs_n),
    .mem_cke(ddr3_ce),
    .mem_addr(ddr3_a),
    .mem_ba(ddr3_ba),
    .mem_ras_n(ddr3_ras_n),
    .mem_cas_n(ddr3_cas_n),
    .mem_we_n(ddr3_we_n),
    .mem_dm(ddr3_dm)
);

assign ddr_rst=!phy_init_done;

oct_alt_oct_power_f4c oct
( 
    .parallelterminationcontrol(parallelterminationcontrol),
    .seriesterminationcontrol(seriesterminationcontrol),
    .rdn(rdn),
    .rup(rup)
) ;

always @( * )
   case(cmd_out[1:0])
      2'b00:mask_data<={24'h000000,wr_dout[71:64]};
      2'b01:mask_data<={16'h0000,wr_dout[71:64],8'h00};
      2'b10:mask_data<={8'h00,wr_dout[71:64],16'h0000};
      2'b11:mask_data<={wr_dout[71:64],24'h000000};
   endcase

wire [254:0] trig0;

/*ila1 ila1_inst (
    .CONTROL(CONTROL),
    .CLK(ddr_clk),
    .TRIG0(trig0)
);*/

assign trig0[127:0]=rd_data_fifo_out;
assign trig0[199:128]=wr_dout;
assign trig0[231:200]=cmd_out;
assign trig0[232]=0;
assign trig0[233]=0;
assign trig0[234]=rd_data_valid;
assign trig0[235]=0;
assign trig0[236]=fifo_empty;
assign trig0[237]=0;
assign trig0[238]=0;
assign trig0[254:239]=0;

reg fifo_full_d;
reg written;

dram_fifo fifo(
    .aclr(ddr_rst),
    
    .wrclk(wb_clk_i),
    .rdclk(ddr_clk),

    .data({wb_sel_i,wb_dat_i,wb_we_i,wb_adr_i[33:3]}),
    .wrreq(wb_cyc_i && wb_stb_i && (!wb_stb_i_d || (fifo_full_d && !written)) && !fifo_full && !(rd_addr_cache==wb_adr_i[28:5] && !wb_we_i)),
    .wrfull(fifo_full),

    .rdreq(fifo_read),
    .q({wr_dout,cmd_out}),
    .wrusedw(fifo_used),
    .rdempty(fifo_empty)
);

`define DDR_IDLE    3'b000
`define DDR_WRITE_1 3'b001
`define DDR_WRITE_2 3'b010
`define DDR_READ_1  3'b011
`define DDR_READ_2  3'b100

reg [2:0] ddr_state;
reg       push_tran;
reg       fifo_read;

always @(posedge ddr_clk or posedge ddr_rst)
   if(ddr_rst)
      begin
         ddr_state<=`DDR_IDLE;
         fifo_read<=0;
         push_tran<=0;
         rd_data_valid_stb<=0;
      end
   else
      case(ddr_state)
         `DDR_IDLE:
            if(!fifo_empty && dram_ready)
               begin
                  push_tran<=1;
                  if(cmd_out[31])
                     begin
                        ddr_state<=`DDR_WRITE_1;
                        fifo_read<=1;
                     end
                  else
                     ddr_state<=`DDR_READ_1;
               end
         `DDR_WRITE_1:
            begin
               push_tran<=0;
               fifo_read<=0;
               ddr_state<=`DDR_WRITE_2; // Protect against FIFO empty signal latency
            end
         `DDR_WRITE_2:
            ddr_state<=`DDR_IDLE;
         `DDR_READ_1:
            begin
               push_tran<=0;
               if(rd_data_valid)
                  begin
                     rd_data_valid_stb<=1;
                     fifo_read<=1;
                     ddr_state<=`DDR_READ_2;
                  end
            end
         `DDR_READ_2:
            begin
               fifo_read<=0;
               if(wb_ack_d1) // Enought delay to protect against FIFO empty signal latency
                  begin
                     rd_data_valid_stb<=0;
                     ddr_state<=`DDR_IDLE;
                  end
            end
      endcase

reg rd_data_valid_stb;
reg rd_data_valid_stb_d1;
reg rd_data_valid_stb_d2;
reg rd_data_valid_stb_d3;
reg rd_data_valid_stb_d4;
reg [255:0] rd_data_fifo_out_d;
reg wb_ack_d;
reg wb_ack_d1;

always @( * )
   case(wb_adr_i[4:3])
      2'b00:wb_dat_o<=rd_data_fifo_out_d[63:0];
      2'b01:wb_dat_o<=rd_data_fifo_out_d[127:64];
      2'b10:wb_dat_o<=rd_data_fifo_out_d[191:128];
      2'b11:wb_dat_o<=rd_data_fifo_out_d[255:192];
   endcase

always @(posedge wb_clk_i or posedge wb_rst_i)
   if(wb_rst_i)
      rd_addr_cache<=24'hFFFFFF;
   else
   begin
      wb_stb_i_d<=wb_stb_i;
      if(wb_cyc_i && wb_stb_i)
         if(!wb_we_i)
            rd_addr_cache<=wb_ack_o ? wb_adr_i[28:5]:rd_addr_cache;
         else
            if(rd_addr_cache==wb_adr_i[28:5])
               rd_addr_cache<=24'hFFFFFF;
      rd_data_valid_stb_d1<=rd_data_valid_stb;
      rd_data_valid_stb_d2<=rd_data_valid_stb_d1;
      rd_data_valid_stb_d3<=rd_data_valid_stb_d2;
      rd_data_valid_stb_d4<=rd_data_valid_stb_d3;
      fifo_full_d<=fifo_full;
      if(wb_ack_o)
         written<=0;
      else
         if(!fifo_full && fifo_full_d)
            written<=1;
   end

assign wb_ack_o=wb_we_i ? (wb_cyc_i && wb_stb_i && !fifo_full):(rd_data_valid_stb_d2 && !rd_data_valid_stb_d3) || (rd_addr_cache==wb_adr_i[28:5]);

always @(posedge ddr_clk)
   begin
      wb_ack_d<=wb_ack_o;
      wb_ack_d1<=wb_ack_d;
      if(rd_data_valid)
         rd_data_fifo_out_d<=rd_data_fifo_out;
   end
    
endmodule
