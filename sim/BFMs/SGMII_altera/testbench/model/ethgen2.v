// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: ethgen2.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/verilog/ethernet_model/gen/ethgen2.v,v $
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
// MII Interface Ethernet Traffic Generator
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

module ethgenerator2 (reset,
   rx_clk,
   rxd,
   rx_dv,
   rx_er,
   sop,
   eop,
   ethernet_speed,
   mii_mode,
   rgmii_mode,
   mac_reverse,
   dst,
   src,
   prmble_len,
   pquant,
   vlan_ctl,
   len,
   frmtype,
   cntstart,
   cntstep,
   ipg_len,
   payload_err,
   prmbl_err,
   crc_err,
   vlan_en,
   stack_vlan,
   pause_gen,
   pad_en,
   phy_err,
   end_err,
   data_only,
   carrier_sense,
   false_carrier,
   carrier_extend,
   carrier_extend_error,
   start,
   done);
parameter thold = 1'b 1;
input   reset; //  active high
input   rx_clk; 
output   [7:0] rxd; 
output   rx_dv; 
output   rx_er; 
output   sop; //  pulse with first character
output   eop; //  pulse with last  character
input   ethernet_speed;
input   mii_mode; //  4-bit Nibbles (Fast Ethernet)
input   rgmii_mode; //  4-bit DDR (Reduced Gigabit)
input   mac_reverse; //  1: dst/src are sent MSB first
input   [47:0] dst; //  destination address
input   [47:0] src; //  source address
input   [4:0] prmble_len; //  length of preamble
input   [15:0] pquant; //  Pause Quanta value
input   [15:0] vlan_ctl; //  VLAN control info
input   [15:0] len; //  Length of payload
input   [15:0] frmtype; //  if non-null: type field instead length
input   [7:0] cntstart; //  payload data counter start (first byte of payload)
input   [7:0] cntstep; //  payload counter step (2nd byte in paylaod)
input   [15:0] ipg_len; //  inter packet gap (delay after CRC)  
input   payload_err; //  generate payload pattern error (last payload byte is wrong)
input   prmbl_err; 
input   crc_err; 
input   vlan_en; 
input   stack_vlan;
input   pause_gen; 
input   pad_en; 
input   phy_err; 
input   end_err; //  keep rx_dv high one cycle after end of frame
input   data_only; //  if set omits preamble, padding, CRC
input   carrier_sense;
input   false_carrier;
input   carrier_extend;
input   carrier_extend_error;
input   start; 
output   done; 
//  GMII receive interface: To be connected to MAC RX
wire    [7:0] rxd; 
wire    rx_dv; 
//  Additional FIFO controls for FIFO test scenarios
wire    rx_er; 
wire    sop; 
//  Mode of Operation
wire    eop; 
reg     done; 
reg    gmii_clk; 
wire    [7:0] gmii_d; 
wire    gmii_en; 
reg     gmii_en_d; 
reg     gmii_err_d;

reg     gmii_10_100_en_d;
reg     gmii_10_100_err_d;


wire    gmii_er; 
wire    sop_gen; //  pulse with first character
wire    eop_gen; //  pulse with last  character
wire    done_gen; 
reg     eop_int; //  pulse with last  character
reg     sop_m; 
reg     eop_m; 
reg     [1:0] start_gen; 
reg     clk_div2; 
wire    [3:0] nib1; 
reg     rgmii_en_er; 
reg     rgmii_10_100_en_er;
reg     rgmii_10_100_en_er_d;
reg     rgmii_10_100_en_er_d2;
reg     rgmii_en_er_f; 
reg     rgmii_10_100_en_er_f; 
reg     [3:0] rgmii_dat; 
reg     [3:0] rgmii_dat_f; //  save upper nibble for falling edge
reg     mii_en; 
reg     mii_er; 
wire    [3:0] mii_dat; 
//  divide clock for nibble transfers 8-bit pathes

initial
   begin
      clk_div2 <= 1'b 0;
      start_gen <= 2'b 00;
   end
   
always @(posedge reset or posedge rx_clk)
   begin : process_1
   if (reset == 1'b 1)
      begin
      clk_div2 <= 1'b 0;    
      start_gen <= 2'b 00;  
      end
   else
      begin
      clk_div2 <= ~clk_div2;    
      if (start == 1'b 1)
         begin
         start_gen <= {2{1'b 1}};   
         end
      else
         begin
         start_gen[1:0] <= {1'b 0, start_gen[1]};   //  make it longer for MII mode
         end
      end
   end
//  multiplex GMII into RGMII/MII
initial
   begin
      rgmii_en_er <= 1'b 0;
      rgmii_en_er_f <= 1'b 0;
      rgmii_dat <= {4{1'b 0}};
      rgmii_dat_f <= {4{1'b 0}};
      sop_m <= 1'b 0;
      eop_m <= 1'b 0;
      gmii_en_d <= 1'b 0;
      gmii_err_d <= 1'b 0;
      mii_en <= 1'b 0;
      mii_er <= 1'b 0;
   end

always @(posedge reset or gmii_clk)
   begin : process_2
   if (reset == 1'b 1)
      begin
      rgmii_en_er <= 1'b 0; 
      rgmii_en_er_f <= 1'b 0;
      rgmii_dat <= {4{1'b 0}};  
      rgmii_dat_f <= {4{1'b 0}};    
      sop_m <= 1'b 0;   
      eop_m <= 1'b 0;   
      gmii_en_d <= 1'b 0;   
      gmii_err_d<= 1'b 0;   
      end
   else 
      begin
//  DDR
      if (gmii_clk == 1'b 1)
         begin
         gmii_en_d <= gmii_en;  
         done <= done_gen & ~gmii_en;   
//  FIFO signaling in right clock edge
         sop_m <= sop_gen;  
         eop_int <= eop_gen;    
                 if (mii_mode == 1'b 1 | rgmii_mode == 1'b1 & ethernet_speed == 1'b0)
            begin
//  not in MII, then EOP is 1 clock cycle already
            eop_m <= 1'b 0; 
            end
         else
            begin
            eop_m <= eop_gen;   
            end
//  Data and Control
         rgmii_dat <= #(thold) gmii_d[3:0]; 
         rgmii_dat_f <= gmii_d[7:4];    
                 
                 rgmii_en_er <= #(thold) gmii_en;
                 rgmii_en_er_f <= #(thold) gmii_er;   
                     
         mii_en <= #(thold) gmii_en;    
         mii_er <= #(thold) gmii_er;    
         end
      else
         begin
                 rgmii_en_er <= #(thold) rgmii_en_er_f ^ gmii_en_d;   
         rgmii_dat <= #(thold) rgmii_dat_f; //  produce upper nibble 

         
                 if (mii_mode == 1'b 1 | rgmii_mode == 1'b1 & ethernet_speed == 1'b0)
            begin
            sop_m <= 1'b 0; 
            eop_m <= eop_int;   
            end
         end
      end
   end


//  multiplex GMII into RGMII/MII
initial
   begin
      rgmii_10_100_en_er <= 1'b 0; 
      rgmii_10_100_en_er_f <= 1'b 0;
      gmii_10_100_en_d <= 1'b 0;
      gmii_10_100_err_d<= 1'b 0;
      rgmii_10_100_en_er_d <= 1'b0;
      rgmii_10_100_en_er_d2 <= 1'b0;
   end

always @(posedge reset or rx_clk)
   begin 
   if (reset == 1'b 1)
      begin
      rgmii_10_100_en_er <= 1'b 0; 
      rgmii_10_100_en_er_f <= 1'b 0;
      gmii_10_100_en_d <= 1'b 0;
      gmii_10_100_err_d<= 1'b 0;
      rgmii_10_100_en_er_d <= 1'b0;
      rgmii_10_100_en_er_d2 <= 1'b0;

      end
   else 
      begin
        //  DDR
              if (rx_clk == 1'b 1)
                 begin
                 gmii_10_100_en_d <= gmii_en;
                 rgmii_10_100_en_er <= #(thold) gmii_en;
                 rgmii_10_100_en_er_f <= #(thold) gmii_er;   
                 rgmii_10_100_en_er_d <= rgmii_10_100_en_er;
                 rgmii_10_100_en_er_d2 <= rgmii_10_100_en_er_d;

                 end
              else
                 begin
                 rgmii_10_100_en_er <= #(thold) rgmii_10_100_en_er_f ^ gmii_10_100_en_d;
                 rgmii_10_100_en_er_d <= rgmii_10_100_en_er;
                 rgmii_10_100_en_er_d2 <= rgmii_10_100_en_er_d;
                 end   
       end
   end





//  connect clock


always @ (*)

 begin
   if (ethernet_speed == 1'b 0)
     begin
      if (rgmii_mode == 1'b1|mii_mode == 1'b1)
       gmii_clk <= clk_div2;
     end
   else
     begin
       gmii_clk <= rx_clk;
 end

 end


//  connect output ports
assign rxd[7:4] = rgmii_mode == 1'b 1 | mii_mode == 1'b 1 | 
    reset == 1'b 1 ? 4'b 0000 : 
    gmii_d[7:4]; 
assign rxd[3:0] = rgmii_mode == 1'b 1 | mii_mode == 1'b 1 | reset == 1'b 1 ? rgmii_dat : gmii_d[3:0]; 
assign rx_dv = reset == 1'b 1 ? 1'b 0 : 
    rgmii_mode == 1'b 1 ? (ethernet_speed == 1'b1) ? rgmii_en_er: rgmii_10_100_en_er_d2 : 
    mii_mode == 1'b 1 ? mii_en : 
    gmii_en; 
assign rx_er = reset == 1'b 1 ? 1'b 0 : 
    rgmii_mode == 1'b 1 ? 1'b 0 : 
    mii_mode == 1'b 1 ? mii_er : 
    gmii_er; 
assign #(thold) sop = rgmii_mode == 1'b 1 | mii_mode == 1'b 1 ? sop_m : 
    sop_gen; 
assign #(thold) eop = rgmii_mode == 1'b 1 | mii_mode == 1'b 1 ? eop_m : 
    eop_gen; 
    
ethgenerator #(2) gmii_gen (.reset(reset),
          //  active high
          .rx_clk(gmii_clk),
          .enable(1'b1),
          .rxd(gmii_d),
          .rx_dv(gmii_en),
          .rx_er(gmii_er),
          .sop(sop_gen),
          .eop(eop_gen),
          .mac_reverse(mac_reverse),
          .dst(dst),
          .src(src),
          .prmble_len(prmble_len),
          .pquant(pquant),
          .vlan_ctl(vlan_ctl),
          .len(len),
          .frmtype(frmtype),
          .cntstart(cntstart),
          .cntstep(cntstep),
          .ipg_len(ipg_len),
          .payload_err(payload_err),
          .prmbl_err(prmbl_err),
          .crc_err(crc_err),
          .vlan_en(vlan_en),
          .stack_vlan(stack_vlan),
          .pause_gen(pause_gen),
          .pad_en(pad_en),
          .phy_err(phy_err),
          .end_err(end_err),
          .data_only(data_only),
          .runt_gen(1'b0) ,
          .long_pause(1'b0) ,
          .carrier_sense(carrier_sense),
          .false_carrier(false_carrier),
          .carrier_extend(carrier_extend),
          .carrier_extend_error(carrier_extend_error),
          .start(start_gen[0]),
          .done(done_gen));
//  GMII Generator
//  --------------

endmodule // module ethgenerator2

