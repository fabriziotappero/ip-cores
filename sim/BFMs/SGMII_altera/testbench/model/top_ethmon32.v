// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: top_ethmon32.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/verilog/ethernet_model/mon/top_ethmon32.v,v $
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
// Ethernet Traffic Monitor/Decoder for 32 bit MAC Atlantic client interface
// Instantiates ethmonitor_32 (ethmon_32.v)
// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

`timescale 1 ns / 10 ps  // timescale for following modules


module top_ethmonitor32 (

   reset,
   clk,
   din,
   dval,
   derror,
   sop,
   eop,
   tmod,
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
   
parameter ENABLE_SHIFT16 = 1'b 0;
parameter BIG_ENDIAN = 1'b1;



input   reset; //  active high
input   clk; 
input   [31:0] din; 
input   dval; 
input   derror; 
input   sop; //  pulse with first word
input   eop; //  pulse with last word (tmod valid)
input   [1:0] tmod; //  last word modulo
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
reg     [47:0] dst; 
reg     [47:0] src; 
reg     [13:0] prmble_len; 
reg     [15:0] pquant; 
reg     [15:0] vlan_ctl; 
reg     [15:0] len; 
reg     [15:0] frmtype; 
wire    [7:0] payload; 
//  Indicators
wire    payload_vld; 
reg     is_vlan;
reg     is_stack_vlan;  
reg     is_pause; 
reg     crc_err; 
reg     prmbl_err; 
reg     len_err; 
reg     payload_err; 
reg     frame_err; 
reg     pause_op_err; 
reg     pause_dst_err; 
reg     mac_err; 
//  Control
reg     end_err; 
wire    frm_rcvd; 
wire    frm_rcvd_i; //  from gen
reg     frm_rcvd_d; //  delayed for handshake
reg     frm_rcvd_ex; //  external
//  GMII Monitor signals
reg     tx_clk; //  8 times the XGMII
wire    [7:0] txd; 
wire    tx_dv; 
wire    tx_er; 
//  internal
reg     fast_clk; 
integer fast_clk_cnt; 
reg     fast_clk_gate; 
reg     clk_d; 
//  captured word data 
reg     [31:0] din_int; 
reg     dval_int; 
reg     derror_int; 
reg     sop_int; //  pulse with first word             
reg     eop_int; //  pulse with last word (tmod valid) 
reg     [1:0] tmod_int; //  last word modulo
//  shift registers to feed GMII Monitor
reg     eop_int_d; 
reg     eop_done; 
reg     [31:0] txd_shift; 
reg     [3:0] txdv_shift; 
//  internal 
wire    [47:0] l_dst; //  destination address
wire    [47:0] l_src; //  source address
wire    [13:0] l_prmble_len; //  length of preamble
wire    [15:0] l_pquant; //  Pause Quanta value
wire    [15:0] l_vlan_ctl; //  VLAN control info
wire    [15:0] l_len; //  Length of payload
wire    [15:0] l_frmtype; //  if non-null: type field instead length
wire    l_is_vlan; 
wire    l_is_stack_vlan; 
wire    l_is_pause; 
wire    l_crc_err; 
wire    l_prmbl_err; 
wire    l_len_err; 
wire    l_payload_err; 
wire    l_frame_err; 
wire    l_pause_op_err; 
wire    l_pause_dst_err; 
wire    l_mac_err; 
wire    l_end_err;


reg   [31:0] din_reg; 
reg   dval_reg; 
reg   derror_reg; 
reg   sop_reg; //  pulse with first word
reg   eop_reg; //  pulse with last word (tmod valid)
reg   [1:0] tmod_reg; //  last word modulo
 
//  Capture word data input
//  ----------------------------------

always @(posedge clk or posedge reset)
   begin : process_1
   if (reset == 1'b 1)
      begin
      din_int <= {32{1'b 0}};   
      dval_int <= 1'b 0;    
      derror_int <= 1'b 0;  
      sop_int <= 1'b 0; 
      eop_int <= 1'b 0; 
      tmod_int <= {2{1'b 0}};   
      frm_rcvd_ex <= 1'b 0; 
      eop_int_d <= 1'b 0;   
      end
   else
      begin
      din_int <= din_reg;   
      dval_int <= dval_reg; 
      derror_int <= derror_reg; 
      sop_int <= sop_reg;   
      eop_int <= eop_reg;   
      tmod_int <= tmod_reg; 
      frm_rcvd_ex <= frm_rcvd_d;    
      eop_int_d <= eop_int & dval_int;  

      end
   end
//  Results in word clock domain
//  ----------------------------------
assign frm_rcvd = frm_rcvd_ex; 
always @(posedge clk or posedge reset)
   begin : process_2
   if (reset == 1'b 1)
      begin
      dst <= {48{1'b 0}};   
      src <= {48{1'b 0}};   
      prmble_len <= 0;  
      pquant <= {16{1'b 0}};    
      vlan_ctl <= {16{1'b 0}};  
      len <= {16{1'b 0}};   
      frmtype <= {16{1'b 0}};   
      is_vlan <= 1'b 0; 
      is_stack_vlan <= 1'b 0;
      is_pause <= 1'b 0;    
      crc_err <= 1'b 0; 
      prmbl_err <= 1'b 0;   
      len_err <= 1'b 0; 
      payload_err <= 1'b 0; 
      frame_err <= 1'b 0;   
      pause_op_err <= 1'b 0;    
      pause_dst_err <= 1'b 0;   
      mac_err <= 1'b 0; 
      end_err <= 1'b 0; 
      end
   else
      begin
        
        if(dval_int == 1'b 1) begin
                dst <= l_dst;   
                src <= l_src;   
                prmble_len <= l_prmble_len; 
                is_vlan <= l_is_vlan;
                is_stack_vlan <= l_is_stack_vlan;   
                is_pause <= l_is_pause; 
                pause_op_err <= l_pause_op_err; 
                pause_dst_err <= l_pause_dst_err;   
                pquant <= l_pquant; 
                vlan_ctl <= l_vlan_ctl; 
                prmbl_err <= l_prmbl_err;   
                frame_err <= l_frame_err;   
                mac_err <= l_mac_err;   
                end_err <= l_end_err;   
        end
        
      len <= l_len; 
      frmtype <= l_frmtype; 
      crc_err <= l_crc_err; 
      len_err <= l_len_err; 
      payload_err <= l_payload_err; 
      end
   end
//  create fast clock synchronized to clk rising edge
//  -------------------------------------------------
always 
   begin : process_3
   fast_clk <= 1'b 0;   
   #( 0.4 ); 
   fast_clk <= 1'b 1;   
   #( 0.4 ); 
   end

always @(negedge fast_clk or posedge reset)
   begin : process_4
   if (reset == 1'b 1)
      begin
      fast_clk_gate <= 1'b 0;   
      fast_clk_cnt <= 3;    
      clk_d <= 1'b 0;   
      frm_rcvd_d <= 1'b 0;  
      txd_shift <= {32{1'b 0}}; 
      txdv_shift <= {4{1'b 0}}; 
      eop_done <= 1'b 0;    //  remember when we added 2 extra cycles after EOP
      end
   else
      begin
//  work on neg edge
      clk_d <= clk; 
      if (clk_d == 1'b 1 & clk == 1'b 0 & 
    fast_clk_cnt > 2 & dval_int == 1'b 1)
         begin
//  wait for neg edge
         fast_clk_cnt <= 0; 
         fast_clk_gate <= 1'b 1;    
//  load shift registers
         txd_shift <= din_int;  
         if (eop_int == 1'b 1 & dval_int == 1'b 1)
            begin
            case (tmod_int)
            2'b 00:
               begin
               txdv_shift <= 4'b 1111;  
               end
            2'b 01:
               begin
               txdv_shift <= 4'b 0001;  
               end
            2'b 10:
               begin
               txdv_shift <= 4'b 0011;  
               end
            2'b 11:
               begin
               txdv_shift <= 4'b 0111;  
               end
            default:
               begin
               txdv_shift <= 4'b 0000;  
               end
            endcase
            end
         else if (dval_int == 1'b 1 )
            begin
            txdv_shift <= 4'b 1111; 
            end
         end
      else if (fast_clk_cnt < 3 )
         begin
         fast_clk_cnt <= fast_clk_cnt + 1'b 1;  
         txd_shift <= {8'h 00, txd_shift[31:8]};    //  LSByte first
         txdv_shift <= {1'b 0, txdv_shift[3:1]};    
         fast_clk_gate <= 1'b 1;    
         end
      else if (fast_clk_cnt < 7 & eop_int_d == 1'b 1 & eop_done == 1'b 0 )
         begin
//  give 2 more at end of frame to generate the frm_rcvd
         txdv_shift <= 4'b 0000;    
         fast_clk_cnt <= fast_clk_cnt + 1'b 1;  
         fast_clk_gate <= 1'b 1;    
         end
      else
         begin
         fast_clk_gate <= 1'b 0;    
         end
//  indicate when we finished the old frame (giving extra cycles after last bytes) 
//  to block eop_int_d indication in case b2b frames are received
      if (fast_clk_cnt == 7 & eop_int_d == 1'b 1)
         begin
         eop_done <= 1'b 1; 
         end
      else if (eop_int_d == 1'b 0 )
         begin
         eop_done <= 1'b 0; 
         end
//  capture frame received indication and sync it to word clock (handshake)
      if (frm_rcvd_i == 1'b 1)
         begin
         frm_rcvd_d <= 1'b 1;   
         end
      else if (frm_rcvd_ex == 1'b 1 )
         begin
         frm_rcvd_d <= 1'b 0;   
         end
      end
   end

//  DDR process to generate gated clock
always @(fast_clk or reset)
   begin : process_5
   if (reset == 1'b 1)
      begin
      tx_clk <= 1'b 0;  
      end
   else if ( fast_clk == 1'b 1 )
      begin
      if (fast_clk_gate == 1'b 1)
         begin
         tx_clk <= 1'b 1;   
         end
      end
   else if ( fast_clk == 1'b 0 )
      begin
      tx_clk <= 1'b 0;  
      end
   end

//  Use shifted word data to generate GMII signals
//  ----------------------------------------------------------
assign txd = txd_shift[7:0]; 
assign tx_dv = txdv_shift[0]; 
assign tx_er = derror_int; 



// endian adapter from Little endian to Big endian

// input   [31:0] din; 
// input   dval; 
// input   derror; 
// input   sop; //  pulse with first word
// input   eop; //  pulse with last word (tmod valid)
// input   [1:0] tmod; //  last word modulo

always @(posedge clk or posedge reset)
 begin 
   if (reset == 1'b 1)
      begin
          din_reg   <= {32{1'b 0}}; 
          dval_reg  <= {{1'b 0}}; 
          derror_reg<= {{1'b 0}}; 
          sop_reg   <= {{1'b 0}}; //  pulse with first word
          eop_reg   <= {{1'b 0}}; //  pulse with last word (tmod valid)
          tmod_reg  <= {2{1'b 0}}; //  last word modulo
      end
   else
    begin
        if (BIG_ENDIAN ==1'b1)
         begin
             din_reg   <= {din[7:0],din[15:8],din[23:16],din[31:24]}; 
             dval_reg  <= dval; 
             derror_reg<= derror; 
             sop_reg   <= sop; //  pulse with first word
             eop_reg   <= eop; //  pulse with last word (tmod valid)

             case (tmod)
               2'b00:  tmod_reg <= 2'b00;
               2'b01:  tmod_reg <= 2'b11;
               2'b10:  tmod_reg <= 2'b10;
               2'b11:  tmod_reg <= 2'b01;
               default:tmod_reg <= {{1'b 0}};     
             endcase          

         end      
        else
         begin
             din_reg           <= din; 
             dval_reg          <= dval; 
             derror_reg        <= derror; 
             sop_reg           <= sop; 
             eop_reg           <= eop; 
             tmod_reg          <= tmod; 
         end      
    end
 end



//  Monitor
//  ---------
ethmonitor_32 mon1g (.reset(reset),
          .tx_clk(tx_clk),
          .txd(txd),
          .tx_dv(tx_dv),
          .tx_er(tx_er),
          .dst(l_dst),
          .src(l_src),
          .prmble_len(l_prmble_len),
          .pquant(l_pquant),
          .vlan_ctl(l_vlan_ctl),
          .len(l_len),
          .frmtype(l_frmtype),
          .payload(payload),
          .payload_vld(payload_vld),
          .is_vlan(l_is_vlan),
          .is_stack_vlan(l_is_stack_vlan),
          .is_pause(l_is_pause),
          .crc_err(l_crc_err),
          .prmbl_err(l_prmbl_err),
          .len_err(l_len_err),
          .payload_err(l_payload_err),
          .frame_err(l_frame_err),
          .pause_op_err(l_pause_op_err),
          .pause_dst_err(l_pause_dst_err),
          .mac_err(l_mac_err),
          .end_err(l_end_err),
          .jumbo_en(jumbo_en),
          .data_only(data_only),
          .frm_rcvd(frm_rcvd_i));

defparam mon1g.ENABLE_SHIFT16 = ENABLE_SHIFT16;

endmodule // module ethmonitor32

