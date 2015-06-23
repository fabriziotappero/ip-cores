// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: ethgen32.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/verilog/ethernet_model/gen/ethgen32.v,v $
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
// Ethernet Traffic Generator for 32 bit MAC Atlantic client interface
// Instantiated in top_ethgenerator32 (top_ethgen32.v)
//
// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------


`timescale 1 ns / 10 ps // timescale for following modules

module ethgenerator32 (reset,
   rx_clk,
   rxd,
   rx_dv,
   rx_er,
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
parameter thold = 1'b 1;
parameter ENABLE_SHIFT16 = 1'b 0;

input   reset; //  active high
input   rx_clk; 
output   [7:0] rxd; 
output   rx_dv; 
output   rx_er; 
output   sop; //  pulse with first character
output   eop; //  pulse with last  character
input   mac_reverse; //  1: dst/src are sent MSB first
input   [47:0] dst; //  destination address
input   [47:0] src; //  source address
input   [3:0] prmble_len; //  length of preamble
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
input   start; 
output   done; 
//  GMII receive interface: To be connected to MAC RX
reg     [7:0] rxd; 
reg     rx_dv; 
//  Additional FIFO controls for FIFO test scenarios
reg     rx_er; 
reg     sop; 
//  Frame Contents definitions
reg     eop; 
reg     done; 
reg     imac_reverse; //  1: dst/src are sent MSB first
reg     [47:0] idst; //  destination address
reg     [47:0] isrc; //  source address
reg     [3:0] iprmble_len; //  length of preamble
reg     [15:0] ipquant; //  Pause Quanta value
reg     [15:0] ivlan_ctl; //  VLAN control info
reg     [15:0] ilen; //  Length of payload
reg     [15:0] ifrmtype; //  if non-null: type field instead length
reg     [7:0] icntstart; //  payload data counter start (first byte of payload)
reg     [7:0] icntstep; //  payload counter step (2nd byte in paylaod)
reg     [15:0] iipg_len; //  inter packet gap
reg     ipayload_err; 
reg     iprmbl_err; 
reg     icrc_err; 
reg     ivlan_en;
reg     istack_vlan; 
reg     ipause_gen; 
reg     ipad_en; 
reg     iphy_err; 
reg     iend_err; 
reg     idata_only; 
//  internal

// TYPE state_typ:
parameter state_typ_s_idle = 0;
parameter state_typ_s_prmbl = 1;
parameter state_typ_s_sfd = 2;
parameter state_typ_s_dst = 3;
parameter state_typ_s_src = 4;
parameter state_typ_s_pause = 5;
parameter state_typ_s_tag = 6;
parameter state_typ_s_len = 7;
parameter state_typ_s_data = 8;
parameter state_typ_s_pad = 9;
parameter state_typ_s_crc = 10;
parameter state_typ_s_enderr = 11;
parameter state_typ_s_ipg = 12;
parameter state_typ_s_stack = 13;
parameter state_typ_s_Dword32Aligned = 14;


reg     [3:0] state; 
reg     [3:0] last_state; 
reg     [3:0] last_state_dly; //  delayed one again
reg     [31:0] crc32; 
reg     [31:0] count; 
reg     [31:0] poscnt; //  position in frame starts at first dst byte
reg     [7:0] datacnt; 
reg     [7:0] rxdata; //  next data to put on the line
reg     sop_int; 
//  -----------------------------------
//  capture command when start asserted
//  -----------------------------------
reg     [31:0]  process_2_crctmp; 
reg     [3:0]  V2V_process_2_i; 
integer  process_7_hi; 
integer  process_7_lo; 
reg     [31:0]  process_7_cnttmp; 
integer  V2V_process_7_i; 

always @(posedge rx_clk or posedge reset)
   begin : process_1
   if (reset == 1'b 1)
      begin
      imac_reverse <= 1'b 0;    //  1: dst/src are sent MSB first
      idst <= {48{1'b 0}};  //  destination address
      isrc <= {48{1'b 0}};  //  source address
      iprmble_len <= 0; //  length of preamble
      ipquant <= {16{1'b 0}};   //  Pause Quanta value
      ivlan_ctl <= {16{1'b 0}}; //  VLAN control info
      ilen <= {16{1'b 0}};  //  Length of payload
      ifrmtype <= {16{1'b 0}};  //  if non-null: type field instead length
      icntstart <= 0;   //  payload data counter start (first byte of payload)
      icntstep <= 0;    //  payload counter step (2nd byte in paylaod)
      iipg_len <= 0;    
      ipayload_err <= 1'b 0;    
      iprmbl_err <= 1'b 0;  
      icrc_err <= 1'b 0;    
      ivlan_en <= 1'b 0;
      istack_vlan <= 1'b 0; 
      ipause_gen <= 1'b 0;  
      ipad_en <= 1'b 0; 
      iphy_err <= 1'b 0;    
      iend_err <= 1'b 0;    
      idata_only <= 1'b 0;  
      end
   else
      begin
      if (start == 1'b 1 & state == state_typ_s_idle)
         begin
         imac_reverse <= mac_reverse;   //  1: dst/src are sent MSB first
         idst <= dst;   //  destination address
         isrc <= src;   //  source address
         iprmble_len <= prmble_len; //  length of preamble
         ipquant <= pquant; //  Pause Quanta value
         ivlan_ctl <= vlan_ctl; //  VLAN control info
         ilen <= len;   //  Length of payload
         ifrmtype <= frmtype;   //  if non-null: type field instead length
         icntstart <= cntstart; //  payload data counter start (first byte of payload)
         icntstep <= cntstep;   //  payload counter step (2nd byte in paylaod)
         iipg_len <= ipg_len;   
         ipayload_err <= payload_err;   
         iprmbl_err <= prmbl_err;   
         icrc_err <= crc_err;   
         ivlan_en <= vlan_en;
         istack_vlan <= stack_vlan; 
         ipause_gen <= pause_gen;   
         ipad_en <= pad_en; 
         iphy_err <= phy_err;   
         iend_err <= end_err;   
         idata_only <= data_only;   
         end
      end
   end
//  ----------------------------------------------
//  CRC calculation over all bytes except preamble
//  ----------------------------------------------
always @(negedge rx_clk or posedge reset)
   begin : process_2
   if (reset == 1'b 1)
      begin
      crc32 <= {32{1'b 1}}; 
      end
   else
      begin
//  need it ahead
      if (last_state == state_typ_s_sfd)
         begin
         crc32 <= {32{1'b 1}};  //  RESET CRC at start of DST
         end
      else if (state != state_typ_s_idle & state != state_typ_s_prmbl & 
    last_state != state_typ_s_crc )
         begin
         process_2_crctmp = crc32;  

         for (V2V_process_2_i = 0; V2V_process_2_i <= 7; V2V_process_2_i = V2V_process_2_i + 1)
            begin
            if ((rxdata[V2V_process_2_i] ^ process_2_crctmp[31]) == 1'b 1)
               begin
               process_2_crctmp = (process_2_crctmp << 1);  //  shift in a 0, will be xor'ed to 1 by the polynom
               process_2_crctmp = process_2_crctmp ^ 32'h 04C11DB7; 
               end
            else
               begin
               process_2_crctmp = (process_2_crctmp << 1);  //  shift in a 0
               end
            end
//  process all bits we have here
         crc32 <= process_2_crctmp; 
         end
      end
   end
//  ----------------------------------------------
//  Push RX Data on GMII and 
//  produce PHY error if requested during SRC address transmission
//  ----------------------------------------------
always @(posedge rx_clk or posedge reset)
   begin : process_3
   if (reset == 1'b 1)
      begin
      rxd <= {8{1'b 0}};    
      rx_dv <= 1'b 0;   
      rx_er <= 1'b 0;   
      end
   else
      begin
      if (last_state == state_typ_s_idle | last_state == state_typ_s_ipg)
         begin
         rxd <= #(thold) {8{1'b 0}};    
         rx_dv <= #(thold) 1'b 0;   
//  Data and DV 
         end
      else
         begin
         rxd <= #(thold) rxdata;    
         rx_dv <= #(thold) 1'b 1;   
//  PHY error in SRC field
         if (last_state == state_typ_s_src & count == 2 & 
    iphy_err == 1'b 1)
            begin
            rx_er <= #(thold) 1'b 1;    
            end
         else
            begin
            rx_er <= #(thold) 1'b 0;    
            end
         end
      end
   end
//  ----------------------------------------------
//  SOP and EOP generation (helper for FIFO testing)
//  ----------------------------------------------
always @(posedge rx_clk or posedge reset)
   begin : process_4
   if (reset == 1'b 1)
      begin
      sop <= 1'b 0; 
      sop_int <= 1'b 0; 
      eop <= 1'b 0; 
      end
   else
      begin
      if (last_state == state_typ_s_idle & state != state_typ_s_idle)
         begin
         sop_int <= 1'b 1;  
         end
      else
         begin
         sop_int <= 1'b 0;  
         end
      if (last_state != state_typ_s_idle & state == state_typ_s_idle | 
    last_state != state_typ_s_ipg & state == state_typ_s_ipg)
         begin
         if (~(last_state == state_typ_s_ipg & state == state_typ_s_idle))
            begin
//  if from ipg to idle, eop has been pulsed already
            eop <= #(thold) 1'b 1;  
            end
         end
      else
         begin
         eop <= #(thold) 1'b 0; 
         end
      sop <= #(thold) sop_int;  //  need 1 delay
      end
   end
//  ----------------------------------------------
//  Position Counter: Starts with first octet of destination address
//  ----------------------------------------------
always @(posedge rx_clk or posedge reset)
   begin : process_5
   if (reset == 1'b 1)
      begin
      poscnt <= 0;  
      end
   else
      begin
      if (state == state_typ_s_sfd | state == state_typ_s_idle & 
    start == 1'b 1)
         begin
//  in the data_only case necessary
         poscnt <= 0;   //  is 1 with the first byte sent (prmbl or DST)
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
//  Done indication
//  ----------------------------------------------
always @(posedge rx_clk or posedge reset)
   begin : process_6
   if (reset == 1'b 1)
      begin
      done <= 1'b 1;    
      end
   else
      begin
      if (state == state_typ_s_idle)
         begin
         done <= ~start;    
         end
      else
         begin
         done <= 1'b 0; 
         end
      end
   end
//  ----------------------------------------------
//  Generator State Machine
//  ----------------------------------------------
always @(posedge rx_clk or posedge reset)
   begin : process_7
   if (reset == 1'b 1)
      begin
      state <= state_typ_s_idle;    
      last_state <= state_typ_s_idle;   
      rxdata <= {8{1'b X}}; 
      count <= 0;   
      end
   else
      begin
//  remember last state and increment internal counter
      last_state <= state;  
      last_state_dly <= last_state; //  for viewing only
      if (count < 65535)
         begin
         process_7_cnttmp = count + 1'b 1;  
         end
      else
         begin
         process_7_cnttmp = count;  
         end
      case (state)
      state_typ_s_idle:
         begin
         if (start == 1'b 1)
            begin
            if (data_only == 1'b 1)
               begin
//  data only then skip preamble
               if (ENABLE_SHIFT16 == 1'b0)         
               state <= state_typ_s_dst;    
               else
                state <= state_typ_s_Dword32Aligned; 
	
               process_7_cnttmp = 1'b 0;    
               end
            else
               begin
               state <= state_typ_s_prmbl;  
               process_7_cnttmp = 1'b 1;    
               end
            end
         rxdata <= {8{1'b X}};  
         end
      state_typ_s_prmbl:
         begin
         if (iprmble_len <= process_7_cnttmp)
            begin
//  one earlier
            state <= state_typ_s_sfd;   
            end
         rxdata <= 8'h 55;  
         end
      state_typ_s_sfd:
         begin
         state <= state_typ_s_dst;  
         process_7_cnttmp = 1'b 0;  
         if (iprmbl_err == 1'b 1)
            begin
            rxdata <= 8'h F5;   //  preamble error
            end
         else
            begin
            rxdata <= 8'h D5;   
            end
         end

     state_typ_s_Dword32Aligned:
        begin
        if (count == 1)
           begin
           state <= state_typ_s_dst;    
           process_7_cnttmp = 1'b 0;    
           end
        case (count)
            1'b 0:
               begin
               rxdata[7:0] <= 8'h 00;    
               end
            1'b 1:
               begin
               rxdata[7:0] <= 8'h 00;   
               end
            default:
               ;
        endcase 
        end

      state_typ_s_dst:
         begin
         if (count == 5)
            begin
            state <= state_typ_s_src;   
            process_7_cnttmp = 1'b 0;   
            end
         case (count)
         1'b 0:
            begin
            rxdata[7:0] <= idst[7:0];   
            end
         1'b 1:
            begin
            rxdata[7:0] <= idst[15:8];  
            end
         2'b 10:
            begin
            rxdata[7:0] <= idst[23:16]; 
            end
         2'b 11:
            begin
            rxdata[7:0] <= idst[31:24]; 
            end
         3'b 100:
            begin
            rxdata[7:0] <= idst[39:32]; 
            end
         3'b 101:
            begin
            rxdata[7:0] <= idst[47:40]; 
            end
         default:
            ;
         endcase
         end
      state_typ_s_src:
         begin
         if (count == 5)
            begin
            if (ipause_gen == 1'b 1)
               begin
               state <= state_typ_s_pause;  // if( mac_reverse='1' ) then
// hi := 47-(count*8);
// lo := 40-(count*8);
// else 
// hi := (count*8)+7;
// lo := (count*8);
// end if;
// rxdata(7 downto 0) <= idst(hi downto lo);
               end
            else if (ivlan_en == 1'b 1 )
               begin
               state <= state_typ_s_tag;    //  VLAN follows
               end
            else
               begin
               state <= state_typ_s_len;    //  normal frame
               end
            process_7_cnttmp = 1'b 0;   
            end
// if( mac_reverse='1' ) then
         case (count)
         1'b 0:
            begin
            rxdata[7:0] <= isrc[7:0];   
            end
         1'b 1:
            begin
            rxdata[7:0] <= isrc[15:8];  
            end
         2'b 10:
            begin
            rxdata[7:0] <= isrc[23:16]; 
            end
         2'b 11:
            begin
            rxdata[7:0] <= isrc[31:24]; 
            end
         3'b 100:
            begin
            rxdata[7:0] <= isrc[39:32]; 
            end
         3'b 101:
            begin
            rxdata[7:0] <= isrc[47:40]; 
            end
         default:
            ;
         endcase
         end
      state_typ_s_pause:
         begin
         if (count == 0)
            begin
            rxdata <= 8'h 88;   // hi := 47-(count*8);
// lo := 40-(count*8);
// else 
// hi := (count*8)+7;
// lo := (count*8);
// end if;
// rxdata(7 downto 0) <= isrc(hi downto lo);
            end
         else if (count == 1 )
            begin
            rxdata <= 8'h 08;   
            end
         else if (count == 2 )
            begin
            rxdata <= 8'h 00;   
            end
         else if (count == 3 )
            begin
            rxdata <= 8'h 01;   
            end
         else if (count == 4 )
            begin
            rxdata <= pquant[15:8]; 
            end
         else if (count == 5 )
            begin
            rxdata <= pquant[7:0];  
            if (ipad_en == 1'b 1)
               begin
               state <= state_typ_s_pad;    
               end
            else
               begin
               state <= state_typ_s_crc;    //  error non-padded pause frame
               end
            process_7_cnttmp = 1'b 0;   
            end
         end
      state_typ_s_tag:
         begin
         if (count == 0)
            begin
            rxdata <= 8'h 81;   
            end
         else if (count == 1 )
            begin
            rxdata <= 8'h 00;   
            end
         else if (count == 2 )
            begin
            rxdata <= ivlan_ctl[15:8];  
            end
         else if (count == 3 )
            begin
                
                if (istack_vlan==1'b0)
                begin
            
                        rxdata <= ivlan_ctl[7:0];   
                        state  <= state_typ_s_len;  
                        process_7_cnttmp = 1'b 0;
                end
                else
                begin
            
                        rxdata <= ivlan_ctl[7:0];   
                        state  <= state_typ_s_stack;    
                        process_7_cnttmp = 1'b 0;
                        
                end 
            end
         end
      state_typ_s_stack:
         begin
         if (count == 0)
            begin
            rxdata <= 8'h 81;   
            end
         else if (count == 1 )
            begin
            rxdata <= 8'h 00;   
            end
         else if (count == 2 )
            begin
            rxdata <= ivlan_ctl[15:8];  
            end
         else if (count == 3 )
            begin
            
                rxdata <= ivlan_ctl[7:0];   
                state  <= state_typ_s_len;  
                process_7_cnttmp = 1'b 0;
                    
            end
         end
      state_typ_s_len:
         begin
         if (count == 0)
            begin
            if (ifrmtype != 0)
               begin
               rxdata <= ifrmtype[15:8];    
               end
            else
               begin
               rxdata <= ilen[15:8];    //  MSB
               end
            end
         else if (count == 1 )
            begin
            if (ifrmtype != 0)
               begin
               rxdata <= ifrmtype[7:0]; 
               end
            else
               begin
               rxdata <= ilen[7:0]; //  LSB
               end
//  if zero length frame go directly to pad
            if (ilen == 0)
               begin
               if (idata_only == 1'b 1 & iend_err == 1'b 1)
                  begin
                  state <= state_typ_s_enderr;  
                  end
               else if (idata_only == 1'b 1 )
                  begin
                  state <= state_typ_s_idle;    //  stop immediately
                  end
               else if (ipad_en == 1'b 1 )
                  begin
                  state <= state_typ_s_pad; 
                  end
               else
                  begin
                  state <= state_typ_s_crc; 
                  end
               end
            else
               begin
               state <= state_typ_s_data;   
               end
            process_7_cnttmp = 1'b 0;   
            end
         end
      state_typ_s_data:
         begin
         if (count == 0)
            begin
            rxdata <= icntstart;    //  first the init
            datacnt <= icntstart;   
            end
         else if (count == 1 )
            begin
            rxdata <= icntstep; //  then the step
            end
         else
            begin
            rxdata <= datacnt;  //  then data
            datacnt <= (datacnt + icntstep) % 256;  
            end
//  check end of payload
         if (count >= ilen - 1'b 1)
            begin
            if (idata_only == 1'b 1)
               begin
               if (iend_err == 1'b 1)
                  begin
                  state <= state_typ_s_enderr;  
                  end
               else if (iipg_len != 0 )
                  begin
                  state <= state_typ_s_ipg; 
                  process_7_cnttmp = 1'b 0; 
                  end
               else
                  begin
                  state <= state_typ_s_idle;    
                  end
               end
            else if (poscnt < 6'b 111100 - 1'b 1 & ipad_en == 
    1'b 1 )
               begin
//  need to pad ?
               state <= state_typ_s_pad;    
               end
            else
               begin
               state <= state_typ_s_crc;    
               process_7_cnttmp = 1'b 0;    
               end
//  modify last data byte if payload error was requested
            if (ipayload_err == 1'b 1)
               begin
               rxdata <= rxdata;    //  just keep the old value signals error
               end
            end
         end
      state_typ_s_pad:
         begin
         rxdata <= {8{1'b 0}};  //  PAD BYTE
         if (poscnt >= 6'b 111100 - 1'b 1)
            begin
            state <= state_typ_s_crc;   
            process_7_cnttmp = 1'b 0;   
            end
         end
      state_typ_s_crc:
         begin
         process_7_hi = 5'b 11111 - count * 8;  
//  send CRC inverted, MSB of most significant byte first

         for (V2V_process_7_i = 0; V2V_process_7_i <= 7; V2V_process_7_i = V2V_process_7_i + 1)
            begin
            rxdata[V2V_process_7_i] <= crc32[process_7_hi - V2V_process_7_i] ^ 1'b 1;   //  first LSB is CRC MSB
            end
         if (count == 2 & icrc_err == 1'b 1)
            begin
            rxdata <= rxdata ^ 8'h FF;  //  produce some wrong number
            end
         if (count == 3)
            begin
            if (iend_err == 1'b 1)
               begin
               state <= state_typ_s_enderr; 
               end
            else if (iipg_len > 0 )
               begin
               state <= state_typ_s_ipg;    
               process_7_cnttmp = 1'b 1;    
               end
            else
               begin
               state <= state_typ_s_idle;   
               end
            end
         end
      state_typ_s_enderr:
         begin
         if (iipg_len == 0)
            begin
//  delay dv going low by one cycle
            state <= state_typ_s_idle;  
            end
         else
            begin
            state <= state_typ_s_ipg;   
            process_7_cnttmp = 1'b 1;   
            end
         end
      state_typ_s_ipg:
         begin
         if (count >= iipg_len)
            begin
//  wait after last
            state <= state_typ_s_idle;  
            end
         end
      endcase
      count <= process_7_cnttmp;    //  load the counter with the new value                   
      end
   end

//  local copied (registered) commands 
//  ----------------------------------

endmodule // 

