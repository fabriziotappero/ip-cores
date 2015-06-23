// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: top_ethgen32.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/verilog/ethernet_model/gen/top_ethgen8.v,v $
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
// Ethernet Traffic Generator for 8 bit fifoless MAC Atlantic client interface
// Instantiates VERILOG module: ethgenerator (ethgen.v)
// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

`timescale 1 ns / 10 ps  // timescale for following modules

module top_ethgenerator_8 (

   reset,
   clk,
   enable,
   dout,
   dval,
   derror,
   sop,
   eop,
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
   start,
   done);

parameter thold = 1.0 ;   
parameter ZERO_LATENCY = 0;
parameter ENABLE_SHIFT16 = 1'b 0;


input   reset; //  active high
input   clk; 
input   enable;
output   [7:0] dout; 
output   dval; 
output   derror; 
output   sop; //  pulse with first word
output   eop; //  pulse with last word (tmod valid)
input   mac_reverse; //  1: dst/src are sent MSB first (non-standard)
input   [47:0] dst; //  destination address
input   [47:0] src; //  source address
input   [3:0] prmble_len; //  length of preamble
input   [15:0] pquant; //  Pause Quanta value
input   [15:0] vlan_ctl; //  VLAN control info
input   [15:0] len; //  Length of payload
input   [15:0] frmtype; //  if non-null: type field instead length
input   [7:0] cntstart; //  payload data counter start (first byte of payload)
input   [7:0] cntstep; //  payload counter step (2nd byte in paylaod)
input   [15:0] ipg_len; 
input   payload_err; //  generate payload pattern error (last payload byte is wrong)
input   prmbl_err; //  Send corrupt SFD in otherwise correct preamble
input   crc_err; 
input   vlan_en; 
input   stack_vlan;
input   pause_gen; 
input   pad_en; 
input   phy_err; //  Generate the well known ERROR control character
input   end_err; //  Send corrupt TERMINATE character (wrong code)
input   data_only; //  if set omits preamble, padding, CRC
input   start; 
output   done; 
wire     [7:0] dout; 
reg     [7:0] dout_reg; 
wire     dval; 
reg     dval_reg; 
wire     derror; 
reg     derror_reg; 
wire    sop; 
wire    eop; 
//  Frame Contents definitions
wire     done; 
reg     done_reg; 
//  internal GMII from generator
wire    [7:0] rxd; 
wire    rx_dv; 
wire    rx_er; 
wire    sop_gen; 
wire    eop_gen; 
reg     start_gen; 
wire    done_gen; 
//  captured signals from generator (lasting 1 word clock cycle)
wire     enable_int; 
reg     enable_reg; 
reg     sop_int; //  captured sop_gen
wire    sop_int_d; //  captured sop_gen
reg     eop_int; //  captured eop_gen
wire    eop_i; //  captured eop_gen
reg     rx_er_int; //  captured rx_er
//  external signals
reg     sop_ex; 
reg     eop_ex; 
//  captured command signals 
reg     [15:0] ipg_len_i; 
//  internal
reg     [7:0] data8; 
wire    [2:0] clkcnt; 
reg     [1:0] bytecnt_eop; //  captured count for last word
integer count; 

//assign output
reg     [7:0] dout_temp; 
reg     dval_temp; 
reg     derror_temp; 
reg     sop_temp; 
reg     eop_temp; 
reg     done_temp;    

reg     [7:0] dout_before_delay; 
reg     dval_before_delay; 
reg     derror_before_delay; 
reg     sop_before_delay; 
reg     eop_before_delay; 
reg     done_before_delay;    


// TYPE stm_typ:
parameter stm_typ_s_idle = 0;
parameter stm_typ_s_data = 1;
parameter stm_typ_s_ipg = 2;
parameter stm_typ_s_ipg0 = 3;
parameter stm_typ_s_wait = 4;

reg     [2:0] state; 
reg     clk_d; 
reg     fast_clk; 
reg     fast_clk_gate; 
reg     [1:0] bytecnt; 
reg     tx_clk; 


//  ---------------------------------------
//  Generate internal fast clock synchronized to external input clock
//  ---------------------------------------

always 
   begin : process_1
   fast_clk <= #(0.1) 1'b 0;    
   #( 0.4 ); 
   fast_clk <= #(0.1) 1'b 1;    
   #( 0.4 ); 
   end

always @(negedge fast_clk or posedge reset)
   begin : process_2
   if (reset == 1'b 1)
      begin
      fast_clk_gate <= 1'b 0;   
      clk_d <= 1'b 0;   
      end
   else
      begin
//  work on neg edge
      clk_d <= clk; 
      if ((rx_dv == 1'b 0 | done_gen == 1'b 1) & 
    (enable_int == 1'b 1 | start_gen == 1'b 1))
         begin
//  generator not running, enable it permanently
         fast_clk_gate <= 1'b 1;    
         end
      else if (clk_d == 1'b 0 & clk == 1'b 1 & 
    state != stm_typ_s_wait & (enable_int == 1'b 1 | 
    state == stm_typ_s_ipg0) )
         begin
//  wait for rising edge
         fast_clk_gate <= 1'b 1;    
         end
      else
         begin
         fast_clk_gate <= 1'b 0;    
         end
      end
   end
//  DDR process to generate gated clock
always @(fast_clk or reset)
   begin : process_3
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



// tx_clk <= fast_clk and fast_clk_gate;        
//  capture generator signals with word clock domain handshake
//  ----------------------------------------------------------
always @(posedge tx_clk or posedge reset)
   begin : process_4
   if (reset == 1'b 1)
      begin
      eop_int <= 1'b 0; 
      sop_int <= 1'b 0; 
      rx_er_int <= 1'b 0;   
      end
   else
      begin
      if (sop_gen == 1'b 1)
         begin
         sop_int <= 1'b 1;  
         end
      else if (sop_ex == 1'b 1 )
         begin
         sop_int <= 1'b 0;  
         end
      if (eop_gen == 1'b 1)
         begin
         eop_int <= 1'b 1;  
         end
      else if (eop_ex == 1'b 1 )
         begin
         eop_int <= 1'b 0;  
         end
      if (rx_er == 1'b 1)
         begin
         rx_er_int <= 1'b 1;    
         end
      else if (eop_ex == 1'b 1 )
         begin
         rx_er_int <= 1'b 0;    
         end
      end
   end
//  word clock, external signal generation
//  --------------------------------------
//assign #(thold) sop = sop_ex; 
//assign #(thold) eop = eop_ex; 
always @(posedge clk or posedge reset)
   begin : process_5
   if (reset == 1'b 1)
      begin
//      enable_int <= 1'b 0;  
      eop_ex <= 1'b 0;  
      sop_ex <= 1'b 0;  
      dval_reg <= 1'b 0;    
      dout_reg <= {8{1'b 0}};  
      derror_reg <= 1'b 0;  
      start_gen <= 1'b 0;   
      ipg_len_i <= 0;   
      done_reg <= 1'b 0;    
      end
   else
      begin
      eop_ex <= eop_int;    
      sop_ex <= sop_int;    
      dout_reg <= #(thold) data8;  
      derror_reg <= #(thold) rx_er_int; 
//      enable_int <= enable; 
      if (done_gen == 1'b 1 & enable_int == 1'b 1 & 
    (state == stm_typ_s_idle | state == stm_typ_s_ipg0 | 
    state == stm_typ_s_data & eop_int == 1'b 1 & 
    ipg_len_i < 4 & start == 1'b 1))
         begin
//  nextstate=S_IPG0
         start_gen <= start;    
         end
      else
         begin
         start_gen <= 1'b 0;    
         end
      if ((state == stm_typ_s_data | state == stm_typ_s_ipg0) & 
    enable_int == 1'b 1 )//| start_gen == 1'b 1)
         begin
         dval_reg <= #(thold) 1'b 1;    
         end
      else
         begin
         dval_reg <= #(thold) 1'b 0;    
         end
//  store input variables that could change until end of frame
      if (sop_int == 1'b 1)
         begin
         ipg_len_i <= ipg_len;  
         end
//  output last word modulo during eop
//      if (eop_int == 1'b 1)
//         begin
//         tmod_reg <= #(thold) bytecnt_eop;  
//         end
//      else if (eop_ex == 1'b 0 )
//         begin
//         tmod_reg <= #(thold) {2{1'b 0}};   
//         end
      done_reg <= done_gen; 
      end
   end
//  ------------------------
//  capture GMII data bytes
//  ------------------------
always @(posedge tx_clk or posedge reset)
   begin : process_6
   if (reset == 1'b 1)
      begin
      data8 <= {8{1'b 0}};    
      end
   else
      begin
      if (sop_gen == 1'b 1 & rx_dv == 1'b 1)
         begin
//  first byte
         data8 <= {rxd[7:0]}; 
         end
      else if (rx_dv == 1'b 1 )
         begin
//  during frame
         data8 <= {rxd[7:0]};  
         end
      end   
    end

//  ------------------------
//  state machine
//  ------------------------
always @(posedge clk or posedge reset)
   begin : process_7
   if (reset == 1'b 1)
      begin
      state <= stm_typ_s_idle;  
      count <= 8;   
      end
   else
      begin
      if (state == stm_typ_s_ipg)
         begin
         count <= count + 3'b 100;  
         end
      else
         begin
         count <= 8;    
         end
      case (state)
      stm_typ_s_idle:
         begin
         if (done_gen == 1'b 0) //  has the generator been triggered ?
            begin
            state <= stm_typ_s_data;    
            end
         else
            begin
            state <= stm_typ_s_idle;    
            end
         end
      stm_typ_s_data:
         begin
         if (eop_int == 1'b 0 & enable_int == 1'b 1)
            begin
            state <= stm_typ_s_data;    
            end
         else if (eop_int == 1'b 0 & enable_int == 1'b 0 )
            begin
            state <= stm_typ_s_wait;    
            end
         else if (eop_int == 1'b 1 )
            begin
            if (ipg_len_i < 4 & start == 1'b 1)
               begin
               state <= stm_typ_s_ipg0; //  no IPG
               end
            else if (ipg_len_i < 8 )
               begin
               state <= stm_typ_s_idle; 
               end
            else
               begin
               state <= stm_typ_s_ipg;  
               end
            end
         else
            begin
            state <= stm_typ_s_data;    
            end
         end
      stm_typ_s_ipg:
         begin
         if (count < ipg_len_i)
            begin
            state <= stm_typ_s_ipg; 
            end
         else
            begin
            state <= stm_typ_s_idle;    
            end
         end
      stm_typ_s_ipg0:
         begin
         state <= stm_typ_s_data;   
         end
      stm_typ_s_wait:
         begin
         if (enable_int == 1'b 1)
            begin
            state <= stm_typ_s_data;    
            end
         else
            begin
            state <= stm_typ_s_wait;    
            end
         end
      default:
         begin
         state <= stm_typ_s_idle;   
         end
      endcase
      end
   end



always @(posedge clk or posedge reset)
 begin 
   if (reset == 1'b 1)
      begin
          dout_temp  <= {8{1'b 0}}; 
          dval_temp  <= {{1'b 0}}; 
          derror_temp<= {{1'b 0}}; 
          sop_temp   <= {{1'b 0}}; 
          eop_temp   <= {{1'b 0}}; 
          done_temp  <= 1'b 0;    


      end
   else
    begin
             dout_temp     <= #(thold) dout_reg; 
             dval_temp     <= #(thold) dval_reg; 
             derror_temp   <= #(thold) derror_reg; 
             sop_temp      <= #(thold) sop_ex; 
             eop_temp      <= #(thold) eop_ex; 
             done_temp     <= #(thold) done_reg;    
    end
 end

generate if (ZERO_LATENCY == 1)
    begin
    timing_adapter_8 tb_adapter (

          // Interface: clk
          .clk(clk),                             //input
          .reset(reset),                            //input
          // Interface: in 
          .in_ready(enable_int),                    //output
          .in_valid(dval_temp),                     //input
          .in_data(dout_temp),                      //input
          .in_startofpacket(sop_temp),              //input
          .in_endofpacket(eop_temp),                //input
          .in_error({derror_temp}),                 //input
          // Interface: out
          .out_ready(enable),                       //input
          .out_valid(dval),                        //output
          .out_data(dout),                           //output
          .out_startofpacket(sop),                  //output
          .out_endofpacket(eop),                    //output
          .out_error({derror})                       //output

    );
  
    assign done = done_temp;   
    end
else
    begin
     always @(posedge clk or posedge reset)
       begin
         if (reset == 1'b 1)
           enable_reg <= 1'b 0;  
         else
           enable_reg <= enable;
        end
  	 assign enable_int = enable_reg;
     assign dout     =  dout_temp; 
     assign dval     =  dval_temp; 
     assign derror   =  derror_temp; 
     assign sop      =  sop_temp; 
     assign eop      =  eop_temp; 
     assign done     =  done_temp;    
    end
endgenerate


//  Generator
//  ---------
ethgenerator  gen1g (
          .reset(reset),
          .rx_clk(tx_clk),
          .enable(1'b1),
          .rxd(rxd),
          .rx_dv(rx_dv),
          .rx_er(rx_er),
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
          .ipg_len(16'h 4),
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
          .long_pause(1'b0),
          .carrier_sense(1'b0),
          .false_carrier(1'b0),
          .carrier_extend(1'b0),
          .carrier_extend_error(1'b0),
          .start(start_gen),
          .done(done_gen));

defparam gen1g.ENABLE_SHIFT16 = ENABLE_SHIFT16;
defparam gen1g.thold         = 0.1;


endmodule // module top_ethgenerator_8

