// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: ethmon_32.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/verilog/ethernet_model/mon/ethmon_32.v,v $
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
// Instantiated in top_ethmonitor32 (top_ethmon32.v)
//
// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

`timescale 1 ns / 10 ps  // timescale for following modules


module ethmonitor_32 (

   reset,
   tx_clk,
   txd,
   tx_dv,
   tx_er,
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
   
input   reset; //  active high
input   tx_clk; 
input   [7:0] txd; 
input   tx_dv; 
input   tx_er; 
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
reg     [47:0] src; 
wire    [13:0] prmble_len; 
reg     [15:0] pquant; 
reg     [15:0] vlan_ctl; 
wire    [15:0] len; 
wire    [15:0] frmtype; 
reg     [7:0] payload; 
//  Indicators
reg     payload_vld; 
wire    is_vlan;
wire    is_stack_vlan;  
wire    is_pause; 
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
reg     frm_rcvd; 
reg     [13:0] iprmble_len; //  length of preamble
reg     [15:0] ifrmtype; 
reg     [15:0] ilen; 
reg     [47:0] idst; 
reg     iis_vlan; 
reg     iis_stack_vlan;
reg     iis_pause; 
//  internal

// TYPE state_typ:
parameter state_typ_s_idle = 0;
parameter state_typ_s_prmbl = 1;
parameter state_typ_s_dst = 2;
parameter state_typ_s_src = 3;
parameter state_typ_s_typelen = 4;
parameter state_typ_s_pause = 5;
parameter state_typ_s_tag = 6;
parameter state_typ_s_len = 7;
parameter state_typ_s_data = 8;
parameter state_typ_s_pad = 9;
parameter state_typ_s_crc = 10;
parameter state_typ_s_abort = 11;
parameter state_typ_s_utype = 12;
parameter state_typ_s_Dword32Aligned = 13;


reg     [3:0] state; 
reg     [3:0] last_state; 
reg     last_tx_dv; //  follows tx_dv with one cycle delay
reg     [31:0] crc32; 
reg     [31:0] count; 
reg     [31:0] poscnt; //  position in frame starts at first dst byte
reg     [7:0] datacnt; //  counter to verify payload
reg     [7:0] datainc; //  counter increment
wire    tx_sof; //  start of frame indicator for 1 clk cycle with 1st byte
reg     tx_dst; //  start of frame indicator for 1 clk cycle with 1st byte
//  connect permanent port signals
//  ------------------------------
reg     [31:0]  process_3_crctmp; 
reg     [3:0]  V2V_process_3_i; 
integer  process_8_ix; 
integer  process_9_ix; 
reg      process_9_ln; 
integer  process_12_ix; 
integer  process_10_ix; 
integer  process_11_hi; 
integer  process_11_lo; 
reg     [31:0]  process_11_cnttmp; 
integer  process_11_i; 
integer  process_11_flen; 

assign prmble_len = iprmble_len; 
assign frmtype = ifrmtype; 
assign len = ilen; 
assign dst = idst; 
assign is_vlan = iis_vlan;
assign is_stack_vlan = iis_stack_vlan;  
assign is_pause = iis_pause; 
//  generate tx start pulse
//  ----------------------
assign tx_sof = ~last_tx_dv & tx_dv; //  pulse with first byte 0 to 1 change
//  generate pulse start of destination address
//  --------------------
always @(last_state or state)
   begin : process_1
   if (last_state != state_typ_s_dst & state == state_typ_s_dst)
      begin
      tx_dst <= 1'b 1;  
      end
   else
      begin
      tx_dst <= 1'b 0;  
      end
   end
//  ------------------------------------------
//  capture tx_er indicator
//  ------------------------------------------
always @(posedge tx_clk or posedge reset)
   begin : process_2
   if (reset == 1'b 1)
      begin
      mac_err <= 1'b 0; 
      last_tx_dv <= 1'b 0;  
      end
   else
      begin
      if (tx_sof == 1'b 1)
         begin
         mac_err <= 1'b 0;  //  reset indicator at start of new receive
         end
      else if (tx_er == 1'b 1 )
         begin
         mac_err <= 1'b 1;  //  capture one or many
         end
      last_tx_dv <= tx_dv;  
      end
   end
//  ----------------------------------------------
//  CRC calculation over all bytes except preamble
//  ----------------------------------------------
always @(posedge tx_clk or posedge reset)
   begin : process_3
   if (reset == 1'b 1)
      begin
      crc32 <= {32{1'b 1}}; 
      crc_err <= 1'b 0; 
      end
   else
      begin
//  need it ahead
      if (tx_dst == 1'b 1 | state != state_typ_s_idle & 
    state != state_typ_s_prmbl & state != state_typ_s_utype | 
    state == state_typ_s_utype & tx_dv == 1'b 1)
         begin
//  push all inclusive CRC bytes
//  preset CRC or load current value
         if (tx_dst == 1'b 1)
            begin
//  first data, preset CRC
            process_3_crctmp = {32{1'b 1}}; 
            end
         else
            begin
            process_3_crctmp = crc32;   
            end
//  calculate next step

         for (V2V_process_3_i = 0; V2V_process_3_i <= 7; V2V_process_3_i = V2V_process_3_i + 1)
            begin
            if ((txd[V2V_process_3_i] ^ process_3_crctmp[31]) == 1'b 1)
               begin
               process_3_crctmp = (process_3_crctmp << 1);  //  shift in a 0, will be xor'ed to 1 by the polynom
               process_3_crctmp = process_3_crctmp ^ 32'h 04C11DB7; 
               end
            else
               begin
               process_3_crctmp = (process_3_crctmp << 1);  //  shift in a 0
               end
            end
//  process all bits we have here
         crc32 <= process_3_crctmp; //  remember current value
//  check if CRC is valid
         if (process_3_crctmp == 32'h C704DD7B)
            begin
            crc_err <= 1'b 0;   
            end
         else
            begin
            crc_err <= 1'b 1;   
            end
         end
      end
   end
//  ----------------------------------------------
//  Extract RX Payload on payload bus and check payload errors:
//  * first byte is counter initialization
//  * second byte is counter increment
//  * data begins from 3rd byte on 
//  ----------------------------------------------
always @(posedge tx_clk or posedge reset)
   begin : process_4
   if (reset == 1'b 1)
      begin
      payload <= {8{1'b 0}};    
      payload_vld <= 1'b 0; 
      payload_err <= 1'b 0; 
      datacnt <= 0; 
      end
   else
      begin
      if (state == state_typ_s_typelen)
         begin
         payload_err <= 1'b 0;  //  reset as a frame of length 0 will not get into S_DATA.
         end
      if (state == state_typ_s_data)
         begin
         payload <= txd;    
         payload_vld <= 1'b 1;  
         if (count == 0)
            begin
            datacnt <= ({1'b 0, txd});  //  load counter
            payload_err <= 1'b 0;   
            end
         else if (count == 1 )
            begin
            datainc <= ({1'b 0, txd});  //  load increment
//  verify payload contents
            end
         else
            begin
            datacnt <= (datacnt + datainc) % 256;   
            if (datacnt != ({1'b 0, txd}))
               begin
               payload_err <= 1'b 1;    
               end
            end
         end
      else
         begin
         payload <= {8{1'b 0}}; 
         payload_vld <= 1'b 0;  
         end
      end
   end
//  ----------------------------------------------
//  Position Counter: Starts with first octet of destination address
//  ----------------------------------------------
always @(posedge tx_clk or posedge reset)
   begin : process_5
   if (reset == 1'b 1)
      begin
      poscnt <= 0;  
      end
   else
      begin
      if (tx_dst == 1'b 1)
         begin
//  reset at start of DST 
         poscnt <= 1;   
         end
      else
         begin
         if (poscnt < 65535)
            begin
            poscnt <= poscnt + 1'b 1;   
            end
         end
      end
   end
//  ----------------------------------------------
//  End of Frame:
//  change from non-idle to idle indicates something was received
//  if dv is still asserted this is an end error
//  ----------------------------------------------
always @(posedge tx_clk or posedge reset)
   begin : process_6
   if (reset == 1'b 1)
      begin
      frm_rcvd <= 1'b 0;    
      end_err <= 1'b 0; 
      end
   else
      begin
      if (last_state != state_typ_s_idle & state == state_typ_s_idle)
         begin
         frm_rcvd <= 1'b 1; 
         end
      else
         begin
         frm_rcvd <= 1'b 0; 
         end
      if (tx_sof == 1'b 1)
         begin
         end_err <= 1'b 0;  
         end
      else if (last_state != state_typ_s_idle & state == state_typ_s_idle & 
    tx_dv == 1'b 1 )
         begin
         end_err <= 1'b 1;  //  dv still asserted even after nothing more expected
         end
      end
   end
//  ----------------------------------------------
//  Preamble check
//  ----------------------------------------------
always @(posedge tx_clk or posedge reset)
   begin : process_7
   if (reset == 1'b 1)
      begin
      prmbl_err <= 1'b 0;   
      iprmble_len <= 0; 
      end
   else
      begin
      if (tx_sof == 1'b 1)
         begin
         if (txd != 8'h 55)
            begin
            prmbl_err <= 1'b 1; 
            end
         else
            begin
            prmbl_err <= 1'b 0; //  reset usually
            end
         if (data_only == 1'b 1)
            begin
            iprmble_len <= 0;   
            end
         else
            begin
            iprmble_len <= 1;   
            end
         end
      else if (state == state_typ_s_prmbl )
         begin
         if (txd != 8'h 55 & txd != 8'h D5)
            begin
            prmbl_err <= 1'b 1; 
            end
         iprmble_len <= iprmble_len + 1'b 1;    
         end
      end
   end
//  ----------------------------------------------
//  Extract Source and Destination addresses
//  ----------------------------------------------
always @(posedge tx_clk or posedge reset)
   begin : process_8
   if (reset == 1'b 1)
      begin
      idst <= {48{1'b 0}};  
      src <= {48{1'b 0}};   
      end
   else
      begin
      process_8_ix = count * 8; 

      if (tx_sof == 1'b 1 & data_only == 1'b 1 & state == state_typ_s_Dword32Aligned & ENABLE_SHIFT16 == 1'b1)
         begin
             case (count)
             1'b 0 : ;
             1'b 1 : ;
             default:;
             endcase         
          end
      if (tx_sof == 1'b 0 & data_only == 1'b 1 & ENABLE_SHIFT16 == 1'b1 & state == state_typ_s_dst)
         begin
         case (count)
         1'b 0:
            begin
            idst[7:0] <= txd[7:0];  
            end
         1'b 1:
            begin
            idst[15:8] <= txd[7:0]; 
            end
         2'b 10:
            begin
            idst[23:16] <= txd[7:0];    
            end
         2'b 11:
            begin
            idst[31:24] <= txd[7:0];    
            end
         3'b 100:
            begin
            idst[39:32] <= txd[7:0];    
            end
         3'b 101:
            begin
            idst[47:40] <= txd[7:0];    
            end
         default:
            ;
         endcase         end
 
 
      if (tx_sof == 1'b 1 & data_only == 1'b 1 & ENABLE_SHIFT16 == 1'b0 | state == state_typ_s_dst)
         begin
         case (count)
         1'b 0:
            begin
            idst[7:0] <= txd[7:0];  
            end
         1'b 1:
            begin
            idst[15:8] <= txd[7:0]; 
            end
         2'b 10:
            begin
            idst[23:16] <= txd[7:0];    
            end
         2'b 11:
            begin
            idst[31:24] <= txd[7:0];    
            end
         3'b 100:
            begin
            idst[39:32] <= txd[7:0];    
            end
         3'b 101:
            begin
            idst[47:40] <= txd[7:0];    
            end
         default:
            ;
         endcase         end
      if (state == state_typ_s_src)
         begin
        case (count)
         1'b 0:
            begin
            src[7:0] <= txd[7:0];   
            end
         1'b 1:
            begin
            src[15:8] <= txd[7:0];  
            end
         2'b 10:
            begin
            src[23:16] <= txd[7:0]; 
            end
         2'b 11:
            begin
            src[31:24] <= txd[7:0]; 
            end
         3'b 100:
            begin
            src[39:32] <= txd[7:0]; 
            end
         3'b 101:
            begin
            src[47:40] <= txd[7:0]; 
            end
         default:
         ;
         endcase         
       end      
      end
   end

//  ----------------------------------------------
//  Extract Length/Type field and VLAN Tag identifier
//  ----------------------------------------------

always @(posedge tx_clk or posedge reset)
   begin : process_12
   if (reset == 1'b 1)
      begin
      ilen <= {16{1'b 0}};  
      ifrmtype <= {16{1'b 0}};  
      vlan_ctl <= {16{1'b 0}};  
      iis_vlan <= 1'b 0;    
      len_err <= 1'b 0; 
      iis_stack_vlan <= 1'b0;
      end
   else
      begin
      process_12_ix = 4'b 1000 - count * 8; 
// if( tx_sof_d = '1' ) then              -- clear all on start of every frame
// 
//     ilen     <= (others => '0');
//     ifrmtype <= (others => '0');
//     vlan_ctl <= (others => '0');
//     iis_vlan  <= '0';
//     
// end if;
      if (state == state_typ_s_typelen)
         begin
//  if in type/len set both
        case (count)
         1'b 0:
            begin
            ifrmtype[15:8] <= txd;  
            ilen[15:8] <= txd;  
            end
         1'b 1:
            begin
            ifrmtype[7:0] <= txd;   
            ilen[7:0] <= txd;   
            end
         default:
            ;
         endcase                
         vlan_ctl <= {16{1'b 0}};   //  clear at start of new frame (at SOF it is too early)
         iis_vlan <= 1'b 0; 
         len_err <= 1'b 0;  
         end
         
         if(state==state_typ_s_typelen)
         begin
            
                iis_stack_vlan <= 1'b0 ;
         
         end 
         else if (last_state == state_typ_s_len & state == state_typ_s_tag)
         begin
            
                iis_stack_vlan <= 1'b1 ;
                
         end
         
      else if (state == state_typ_s_len )
         begin
//  in len again, set len independently
         case (count)
         1'b 0:
            begin
            ifrmtype[15:8] <= txd;  
            ilen[15:8] <= txd;  
            end
         1'b 1:
            begin
            ifrmtype[7:0] <= txd;   
            ilen[7:0] <= txd;   
            end
         default:
            ;
         endcase    
         end
      else if (state == state_typ_s_tag )
         begin
         iis_vlan <= 1'b 1; 
        case (count)
         1'b 0:
            begin
            vlan_ctl[15:8] <= txd;  // ilen(ix+7 downto ix)     <= txd;
            end
         1'b 1:
            begin
            vlan_ctl[7:0] <= txd;   
            end
         default:
            ;
         endcase         end
//  verify length at end of frame for normal frames (length 46... max and not a type)
      if (last_state == state_typ_s_crc & state == state_typ_s_idle & 
    iis_pause == 1'b 0 & (iis_vlan == 1'b 0 & 
    ilen > 45 | iis_vlan == 1'b 1 & 
    ilen > 41))
         begin
//  verify integrity of length field 
         if (tx_dv == 1'b 1 | 
             iis_stack_vlan == 1'b 1 & ilen != poscnt - 5'b 11010 |
             (iis_vlan == 1'b 1 & iis_stack_vlan == 1'b 0) & ilen != poscnt - 5'b 10110 | 
             iis_vlan == 1'b 0 & ilen != poscnt - 5'b 10010)
            begin
            len_err <= 1'b 1;   
            end
         else
            begin
            len_err <= 1'b 0;   
            end
         end
      end
   end
//  ----------------------------------------------
//  Extract Pause frame indication,
//                opcode error,
//                destination address error,
//                and Pause Quanta
//  ----------------------------------------------
always @(posedge tx_clk or posedge reset)
   begin : process_13
   if (reset == 1'b 1)
      begin
      pquant <= {16{1'b 0}};    
      iis_pause <= 1'b 0;   
      pause_op_err <= 1'b 0;    
      pause_dst_err <= 1'b 0;   
      end
   else
      begin
      if (tx_sof == 1'b 1)
         begin
         iis_pause <= 1'b 0;    //  clear at start of frame
         pause_op_err <= 1'b 0; 
         pause_dst_err <= 1'b 0;    
         end
      if (state == state_typ_s_pause)
         begin
         iis_pause <= 1'b 1;    
         //if (count >= 2)
            //begin
//  pick octets after opcode
        case (count)
            2'b 11:
               begin
               pquant[15:8] <= txd; 
               end
            1'b 0:
               begin
               pquant[7:0] <= txd;  
               end
            default:
               ;
            endcase            
            //end
        if (count == 0 & txd != 8'h 00 | 
    count == 1 & txd != 8'h 01 )
            begin
            pause_op_err <= 1'b 1;  
            end
         if (idst != 48'h 010000c28001)
            begin
//  01-80-c2-00-00-01 is standard !
            pause_dst_err <= 1'b 1; 
            end
         end
      end
   end
//  ----------------------------------------------
//  Monitor State Machine
//  ----------------------------------------------
always @(posedge tx_clk or posedge reset)
   begin : process_11
   if (reset == 1'b 1)
      begin
      state <= state_typ_s_idle;    
      last_state <= state_typ_s_idle;   
      count <= 0;   
      frame_err <= 1'b 0;   //  state machine abort indicator
      end
   else
      begin
//  remember last state and increment internal counter
      last_state <= state;  
      if (count < 65535)
         begin
         process_11_cnttmp = count + 1'b 1; 
         end
      else
         begin
         process_11_cnttmp = count; 
         end
//  Abort detection: If enable goes low in middle of frame
      if (state != state_typ_s_idle & state != state_typ_s_abort & 
    state != state_typ_s_utype & tx_dv == 1'b 0)
         begin
         state <= state_typ_s_abort;    
         end
      else
         begin
         case (state)
         state_typ_s_abort:
            begin
            if (tx_dv == 1'b 1)
               begin
               if (last_tx_dv == 1'b 0 & data_only == 1'b 1)
                  begin
//  only 1 clock cycle inbetween
                  if (ENABLE_SHIFT16 == 1'b0)
                  state <= state_typ_s_dst; 
                  else
                    state <= state_typ_s_Dword32Aligned;    

                  process_11_cnttmp = 1'b 1;    
                  frame_err <= 1'b 0;   
                  end
               else
                  begin
                  state <= state_typ_s_abort;   //  wait til tx stops transmission
                  end
               end
            else
               begin
               state <= state_typ_s_idle;   
               end
            frame_err <= 1'b 1; 
            end
         state_typ_s_idle:
            begin
            if (tx_sof == 1'b 1)
               begin
//  we miss the very first !
               process_11_cnttmp = 1'b 1;   //  therefore need to count to 1 immediately
               frame_err <= 1'b 0;  
               if (data_only == 1'b 1)
                  begin
//  no preamble checking ?
                  if (ENABLE_SHIFT16 == 1'b0)
                  state <= state_typ_s_dst; 
                  else
                    state <= state_typ_s_Dword32Aligned;    
                  end
               else
                  begin
                  state <= state_typ_s_prmbl;   
                  end
               end
            else
               begin
               process_11_cnttmp = 1'b 0;   //  keep it to zero always 
               end
            end
         state_typ_s_prmbl:
            begin
            if (txd == 8'h D5)
               begin
               state <= state_typ_s_dst;    
               process_11_cnttmp = 1'b 0;   
               end
            end

         state_typ_s_Dword32Aligned:
           begin
           if (count == 1)
              begin
              state <= state_typ_s_dst;   
              process_11_cnttmp = 1'b 0;  
              end
           end

         state_typ_s_dst:
            begin
            if (count == 5)
               begin
               state <= state_typ_s_src;    
               process_11_cnttmp = 1'b 0;   
               end
            end
         state_typ_s_src:
            begin
            if (count == 5)
               begin
               state <= state_typ_s_typelen;    
               process_11_cnttmp = 1'b 0;   
               end
            end
         state_typ_s_typelen:
            begin
            if (count != 0)
               begin
//  second half of 2-octet field
               process_11_cnttmp = 1'b 0;   
               process_11_flen = ({1'b 0, ilen[15:8], txd});    //  need it NOW
               if (jumbo_en == 1'b 1 & process_11_flen <= 9000 | 
    process_11_flen <= 1500)
                  begin
//  ok normal user frame. check if data or 0 length
                  if (process_11_flen != 0)
                     begin
                     state <= state_typ_s_data; 
//  no data, PAD or finished
                     end
                  else
                     begin
                     if (data_only == 1'b 1)
                        begin
                        state <= state_typ_s_idle;  //  Ok, we are done dont expect anything more
                        end
                     else
                        begin
                        state <= state_typ_s_pad;   //  zero-length frame needs padding
                        end
                     end
//  not normal frame
                  end
               else
                  begin
                  if (process_11_flen == 16'h 8808)
                     begin
                     state <= state_typ_s_pause;    
                     end
                  else if (process_11_flen == 16'h 8100 )
                     begin
                     state <= state_typ_s_tag;  
                     end
                  else
                     begin
                     state <= state_typ_s_utype;    //  S_ABORT;    -- unknown type
                     end
                  end
               end
            end
         state_typ_s_pause:
            begin
            if (count >= 3)
               begin
//  need to overread opcode
               state <= state_typ_s_pad;    
               process_11_cnttmp = 1'b 0;   
               end
            end
         state_typ_s_tag:
            begin
            if (count >= 1)
               begin
               state <= state_typ_s_len;    
               process_11_cnttmp = 1'b 0;   
               end
            end
         state_typ_s_len:
            begin
            if (count >= 1)
               begin
//  Length after VLAN TAG
               process_11_cnttmp = 1'b 0;   
               process_11_flen = ({1'b 0, ilen[15:8], txd});    //  need it NOW
               
               if ( process_11_flen == 16'h8100)
               begin
                                    
                state <= state_typ_s_tag;
               
               end               
               else if (process_11_flen != 0 & (jumbo_en == 1'b 1 & 
    process_11_flen > 9000 | jumbo_en == 1'b 0 & 
    process_11_flen > 1500))
                  begin
                  state <= state_typ_s_utype;   
                  end
               else if (process_11_flen != 0 )
                  begin
                  state <= state_typ_s_data;    
//  no data, PAD or finished
                  end
               else
                  begin
                  if (data_only == 1'b 1)
                     begin
                     state <= state_typ_s_idle; //  Ok, we are done dont expect CRC
                     end
                  else
                     begin
                     state <= state_typ_s_pad;  
                     end
                  end
               end
            end
         state_typ_s_data:
            begin
            if (count >= ilen - 1'b 1)
               begin
               process_11_cnttmp = 1'b 0;   
               if (data_only == 1'b 1)
                  begin
//  no PAD and no CRC ?
                  state <= state_typ_s_idle;    
                  end
               else if (poscnt < 6'b 111100 - 1'b 1 )
                  begin
//  expect padding ?
                  state <= state_typ_s_pad; 
                  end
               else
                  begin
                  state <= state_typ_s_crc; 
                  end
               end
            end
         state_typ_s_pad:
            begin
            if (poscnt >= 6'b 111100 - 1'b 1)
               begin
               state <= state_typ_s_crc;    
               process_11_cnttmp = 1'b 0;   
               end
            end
         state_typ_s_crc:
            begin
            if (count >= 3)
               begin
               state <= state_typ_s_idle;   
               process_11_cnttmp = 1'b 0;   
               end
            end
         state_typ_s_utype:
            begin
            if (tx_dv == 1'b 0)
               begin
//  unknown type... wait for end of frame
               state <= state_typ_s_idle;   
               process_11_cnttmp = 1'b 0;   
               end
            end
         endcase
         end
//  abort                    
//  load the counter with the new value                   
      count <= process_11_cnttmp;   
      end
   end

//  port signals internally reused

endmodule // module ethmonitor_32

