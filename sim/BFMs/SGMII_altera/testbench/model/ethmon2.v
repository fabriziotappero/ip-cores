// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: ethmon2.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/verilog/ethernet_model/mon/ethmon2.v,v $
//
// $Revision: #1 $
// $Date: 2012/06/21 $
// Check in by : $Author: swbranch $
// Author      : SKNg/TTChong
//
// Project     : Triple Speed Ethernet - 10/100/1000 MAC
//
// Description : (Simulation only)
//
// MII Interface Ethernet Traffic Monitor/Decoder
//
// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

`timescale 1 ns / 10 ps
//`include "common_header.verilog" 

module ethmonitor2 (reset,
   tx_clk,
   txd,
   tx_dv,
   tx_er,
   tx_sop,
   tx_eop,
   ethernet_speed,
   mii_mode,
   rgmii_mode,
   dst,
   src,
   prmble_len,
   pquant,
   vlan_ctl,
   len,
   frmtype,
   payload,
   payload_vld,
   is_vlan,
   is_stack_vlan,
   is_pause,
   crc_err,
   prmbl_err,
   len_err,
   payload_err,
   frame_err,
   pause_op_err,
   pause_dst_err,
   mac_err,
   end_err,
   jumbo_en,
   data_only,
   frm_rcvd);

input   reset; //  active high
input   tx_clk; 
input   [7:0] txd; 
input   tx_dv; 
input   tx_er; 
input   tx_sop; 
input   tx_eop; 
input   ethernet_speed; 
input   mii_mode; //  4-bit Nibbles (Fast Ethernet)
input   rgmii_mode; //  4-bit DDR (Reduced Gigabit)
output   [47:0] dst; //  destination address
output   [47:0] src; //  source address
output   [13:0] prmble_len; //  length of preamble
output   [15:0] pquant; //  Pause Quanta value
output   [15:0] vlan_ctl; //  VLAN control info
output   [15:0] len; //  Length of payload
output   [15:0] frmtype; //  if non-null: type field instead length
output   [7:0] payload; 
output   payload_vld; 
output   is_vlan; 
output   is_stack_vlan;
output   is_pause; 
output   crc_err; 
output   prmbl_err; 
output   len_err; 
output   payload_err; 
output   frame_err; 
output   pause_op_err; 
output   pause_dst_err; 
output   mac_err; 
output   end_err; 
input   jumbo_en; 
input   data_only; 
output   frm_rcvd; 
//  GMII transmit interface: To be connected to MAC TX
wire    [47:0] dst; 
wire    [47:0] src; 
wire    [13:0] prmble_len; 
wire    [15:0] pquant; 
wire    [15:0] vlan_ctl; 
wire    [15:0] len; 
wire    [15:0] frmtype; 
wire    [7:0] payload; 
//  Indicators
wire    payload_vld; 
wire    is_vlan;
wire    is_stack_vlan; 
wire    is_pause; 
wire    crc_err; 
wire    prmbl_err; 
wire    len_err; 
wire    payload_err; 
wire    frame_err; 
wire    pause_op_err; 
wire    pause_dst_err; 
wire    mac_err; 
//  Control
wire    end_err; 
wire    frm_rcvd; 
reg     clk_div2; 
//  Signals for GMII Monitor
reg    gmii_clk; 
wire    [7:0] gmii_d; 
wire    gmii_en; 
wire    gmii_er; 
//  RGMII demultiplexed

reg     [7:0] ddr_rgmii_d;    
reg     ddr_rgmii_en;    
reg     ddr_rgmii_er;    

reg     [7:0] ddr_rgmii_d_dly1;    
reg     ddr_rgmii_en_dly1;    
reg     ddr_rgmii_er_dly1;    

reg     [7:0]  sdr_rgmii_d;    
reg     sdr_rgmii_en;    
reg     sdr_rgmii_er;    

reg     PartOfFrameData_1000;    
reg     FrameError_1000;    

wire     [7:0] rgmii_d; 
wire     rgmii_en; 
wire     rgmii_er; 
//  MII demultiplexed
reg     [3:0] mii_d_lo; //  low nibble
reg     [7:0] mii_d; 
reg     mii_en; 
reg     mii_er; 
reg     mii_hi; //  hi nibble is on bus
wire    frm_rcvd_mon; 
reg     frm_rcvd_i; 
//  demultiplex RGMII 
reg     [7:0] rgmii_10_100_d;  
reg     [3:0] rgmii_10_100_d_lo;
reg     rgmii_hi;

 

//SDR rising edge 
always @(reset or posedge tx_clk)
   begin  
   if (reset == 1'b 1)
      begin
      sdr_rgmii_d [3:0] <= {4{1'b 0}};    //  rising edge
      sdr_rgmii_en      <= 1'b 0;    
      end
   else 
      begin
      sdr_rgmii_d[3:0]  <= #2 txd[3:0];   //  low nibble 
      sdr_rgmii_en      <= #2 tx_dv; //  dv in 1st half of clock
      end        
   end

//SDR falling edge 
always @(reset or negedge tx_clk)
   begin  
   if (reset == 1'b 1)
      begin
      sdr_rgmii_d[7:4] <= {4{1'b 0}};    //  falling edge
      sdr_rgmii_er     <= 1'b 0;    
      end
   else 
      begin
      sdr_rgmii_d[7:4] <= #2 txd[3:0];   //  high nibble on rising edge
      sdr_rgmii_er     <= #2 tx_dv;   
      end
   end

//DDR edges 
always @(reset or posedge tx_clk)
   begin  
   if (reset == 1'b 1)
      begin
      ddr_rgmii_d       <= {8{1'b 0}};    
      ddr_rgmii_en      <= 1'b 0;    
      ddr_rgmii_er      <= 1'b 0;    

      ddr_rgmii_d_dly1  <= {8{1'b 0}};    
      ddr_rgmii_en_dly1 <= 1'b 0;    
      ddr_rgmii_er_dly1 <= 1'b 0;    

      end
   else 
      begin
      ddr_rgmii_d  <= sdr_rgmii_d;    
      ddr_rgmii_en <= sdr_rgmii_en;    
      ddr_rgmii_er <= sdr_rgmii_er;    

      ddr_rgmii_d_dly1  <= ddr_rgmii_d;    
      ddr_rgmii_en_dly1 <= ddr_rgmii_en;    
      ddr_rgmii_er_dly1 <= ddr_rgmii_er;    

      end        
   end

//demultiplex rgmii 10/100  
always @(posedge reset or posedge tx_clk)
   begin 
   if (reset == 1'b 1)
      begin
      rgmii_10_100_d <= {8{1'b 0}};  
      rgmii_10_100_d_lo <= {4{1'b 0}};   //  low nibble
      end
   else
      begin
//  prepare that we can have a start at any clock cycle.
      if (tx_dv == 1'b 0 & sdr_rgmii_en == 1'b 0)
         begin
         rgmii_hi <= 1'b 0;   
         end
      else
         begin
         rgmii_hi <= ~rgmii_hi; 
         end
//  read two nibbles
      if (rgmii_hi == 1'b 0)
         begin
         rgmii_10_100_d_lo <= txd[3:0];  //  low nibble first
         end
      else
         begin
         rgmii_10_100_d[7:0] <= #(5.000000e-01) {txd[3:0], rgmii_10_100_d_lo};    //  hi nibble and all internal dv
         end
	  end
   end

//Frame markers
always @(posedge reset or posedge tx_clk)
      begin
   if (reset == 1'b 1)
         begin
      PartOfFrameData_1000  <= 1'b 0;    
      FrameError_1000       <= 1'b 0;    
         end
      else
         begin

          if (ddr_rgmii_en_dly1 == 1'b1 && ddr_rgmii_en == 1'b0)
           begin
              PartOfFrameData_1000  <= 1'b 0;    
              FrameError_1000       <= 1'b 0;    
           end
          else if (ddr_rgmii_en_dly1 == 1'b0) 
           begin
              PartOfFrameData_1000  <= 1'b 0;    
              FrameError_1000       <= 1'b 0;    
         end
          else if (ddr_rgmii_d !== 8'hD5) 
           begin   
              PartOfFrameData_1000  <= 1'b 1;
           end

           // Generate Frame Error
           if (ddr_rgmii_en == 1'b1 && ddr_rgmii_er == 1'b0)
              FrameError_1000      <= 1'b1;
           else if ( (ddr_rgmii_en_dly1 == 1'b1 && ddr_rgmii_en == 1'b0) | ddr_rgmii_d_dly1 == 1'b0)
              FrameError_1000      <= 1'b0;
      end
   end


assign rgmii_d  = ethernet_speed == 1'b1 ? ddr_rgmii_d_dly1 : rgmii_10_100_d ;    
assign rgmii_en = PartOfFrameData_1000;    
assign rgmii_er = FrameError_1000;    
  
//always @ (posedge reset or posedge gmii_clk)
//
// begin
//   if (reset == 1'b 1)
//     begin
//      rgmii_10_100_d  <= 8{1'b0};    
//      rgmii_10_100_en <= 1'b0;    
//      rgmii_10_100_er <= 1'b0;    
//     end
//   else
//     begin
//      rgmii_10_100_d  <= 8{1'b0};    
//      rgmii_10_100_en <= 1'b0;    
//      rgmii_10_100_er <= 1'b0;    
//     end
//
// end
  


//  demultiplex MII 
always @(posedge reset or posedge tx_clk)
   begin : process_2
   if (reset == 1'b 1)
      begin
      mii_d <= {8{1'b 0}};  
      mii_d_lo <= {4{1'b 0}};   //  low nibble
      mii_en <= 1'b 0;  
      mii_er <= 1'b 0;  
      mii_hi <= 1'b 0;  
      frm_rcvd_i <= 1'b 0;  
      clk_div2 <= 1'b 0;    
      end
   else
      begin
      clk_div2 <= ~clk_div2;    
//  prepare that we can have a start at any clock cycle.
      if (tx_dv == 1'b 0 & mii_en == 1'b 0)
         begin
         mii_hi <= 1'b 0;   
         end
      else
         begin
         mii_hi <= ~mii_hi; 
         end
//  read two nibbles
      if (mii_hi == 1'b 0)
         begin
         mii_d_lo <= txd[3:0];  //  low nibble first
         end
      else
         begin
         mii_d[7:0] <= #(5.000000e-01) {txd[3:0], mii_d_lo};    //  hi nibble and all internal dv
         mii_en <= #(5.000000e-01) tx_dv;   
         mii_er <= #(5.000000e-01) tx_er;   
         end
//  frame received indication only for 1 clock cycle
      if (frm_rcvd_mon == 1'b 1 & frm_rcvd_i == 1'b 0)
         begin
         frm_rcvd_i <= 1'b 1;   
         end
      else
         begin
         frm_rcvd_i <= 1'b 0;   
         end
      end
   end



//  connect Model Signals


//assign gmii_clk = mii_mode == 1'b 0 ? tx_clk : 
//    clk_div2;
    


always @ (*)

 begin
   if (ethernet_speed == 1'b 0)
     begin
      if (rgmii_mode == 1'b1|mii_mode == 1'b1)
       gmii_clk <= clk_div2;
     end
   else
     begin
      if (rgmii_mode == 1'b1 & mii_mode == 1'b0)
       gmii_clk <= tx_clk;
     end

 end
    
     
assign gmii_d = rgmii_mode == 1'b 1 ? rgmii_d : 
    mii_mode == 1'b 1 ? mii_d : 
    txd; 
assign gmii_en = (rgmii_mode == 1'b 1 & ethernet_speed == 1'b1) ? rgmii_en : 
    (mii_mode == 1'b 1|ethernet_speed == 1'b0) ? mii_en : 
    tx_dv; 
assign gmii_er = rgmii_mode == 1'b 1 ? rgmii_er : 
    mii_mode == 1'b 1 ? mii_er : 
    tx_er; 
assign frm_rcvd = (mii_mode == 1'b 1|ethernet_speed == 1'b0) ? frm_rcvd_i : 
    frm_rcvd_mon; 
//  connect GMII Monitor
//  --------------------
ethmonitor gmii_mon (.reset(reset),
          //  active high
          .tx_clk(gmii_clk),
          .txd(gmii_d),
          .tx_dv(gmii_en),
          .tx_er(gmii_er),
          .tx_sop(tx_sop),
          .tx_eop(tx_eop),
          .dst(dst),
          .src(src),
          .prmble_len(prmble_len),
          .pquant(pquant),
          .vlan_ctl(vlan_ctl),
          .len(len),
          .frmtype(frmtype),
          .payload(payload),
          .payload_vld(payload_vld),
          .is_vlan(is_vlan),
          .is_stack_vlan(is_stack_vlan),
          .is_pause(is_pause),
          .crc_err(crc_err),
          .prmbl_err(prmbl_err),
          .len_err(len_err),
          .payload_err(payload_err),
          .frame_err(frame_err),
          .pause_op_err(pause_op_err),
          .pause_dst_err(pause_dst_err),
          .mac_err(mac_err),
          .end_err(end_err),
          .jumbo_en(jumbo_en),
          .data_only(data_only),
          .frm_rcvd(frm_rcvd_mon));
//  GMII Monitor

endmodule // module ethmonitor2

