//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores common library Module                       ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

/**********************************************
      Web-bone cross bar M-Master By S-Slave
**********************************************/

module wb_crossbar (

              rst_n               , 
              clk                 ,


    // Master Interface Signal
              wbd_taddr_master    ,
              wbd_din_master      ,
              wbd_dout_master     ,
              wbd_adr_master      , 
              wbd_be_master       , 
              wbd_we_master       , 
              wbd_ack_master      ,
              wbd_stb_master      , 
              wbd_cyc_master      , 
              wbd_err_master      ,
              wbd_rty_master      ,
 
    // Slave Interface Signal
              wbd_din_slave       , 
              wbd_dout_slave      ,
              wbd_adr_slave       , 
              wbd_be_slave        , 
              wbd_we_slave        , 
              wbd_ack_slave       ,
              wbd_stb_slave       , 
              wbd_cyc_slave       , 
              wbd_err_slave       ,
              wbd_rty_slave
         );

parameter WB_SLAVE   = 4 ;
parameter WB_MASTER  = 4 ;

parameter D_WD    = 16; // Data Width
parameter BE_WD   = 2;  // Byte Enable
parameter ADR_WD  = 28; // Address Width
parameter TAR_WD  = 4;  // Target Width

input                  clk; // CLK_I The clock input [CLK_I] coordinates all activities 
                            // for the internal logic within the WISHBONE interconnect. 
                            // All WISHBONE output signals are registered at the 
                            // rising edge of [CLK_I]. 
                            // All WISHBONE input signals must be stable before the 
                            // rising edge of [CLK_I]. 
input                  rst_n; // RST_I The reset input [RST_I] forces the WISHBONE interface 
                            // to restart. Furthermore, all internal self-starting state 
                            // machines will be forced into an initial state. 

input [(WB_MASTER *TAR_WD)-1:0] wbd_taddr_master; // target address from master 
input [WB_MASTER-1:0]  wbd_stb_master;  
                    // STB_O The strobe output [STB_O] indicates a valid data 
                    // transfer cycle. It is used to qualify various other signals 
                    // on the interface such as [SEL_O(7..0)]. The SLAVE must 
                    // assert either the [ACK_I], [ERR_I] or [RTY_I] signals in 
                    // response to every assertion of the [STB_O] signal. 
output [WB_SLAVE-1:0]  wbd_stb_slave;  
                    // STB_O The strobe output [STB_O] indicates a valid data 
                    // transfer cycle. It is used to qualify various other signals 
                    // on the interface such as [SEL_O(7..0)]. The SLAVE must 
                    // assert either the [ACK_I], [ERR_I] or [RTY_I] signals in 
                    // response to every assertion of the [STB_O] signal. 

input [WB_MASTER-1:0]   wbd_we_master;    
                    // WE_O The write enable output [WE_O] indicates whether the 
                    // current local bus cycle is a READ or WRITE cycle. The 
                    // signal is negated during READ cycles, and is asserted 
                    // during WRITE cycles. 
output [WB_SLAVE-1:0]   wbd_we_slave;    
                    // WE_O The write enable output [WE_O] indicates whether the 
                    // current local bus cycle is a READ or WRITE cycle. The 
                    // signal is negated during READ cycles, and is asserted 
                    // during WRITE cycles. 

output [WB_MASTER-1:0]  wbd_ack_master; 
                    // The acknowledge input [ACK_I], when asserted, 
                    // indicates the termination of a normal bus cycle. 
                    // Also see the [ERR_I] and [RTY_I] signal descriptions. 
input [WB_SLAVE-1:0]  wbd_ack_slave; 
                    // The acknowledge input [ACK_I], when asserted, 
                    // indicates the termination of a normal bus cycle. 
                    // Also see the [ERR_I] and [RTY_I] signal descriptions. 

input [(WB_MASTER *ADR_WD)-1:0] wbd_adr_master; 
                    // The address output array [ADR_O(63..0)] is used 
                    // to pass a binary address, with the most significant 
                    // address bit at the higher numbered end of the signal array. 
                    // The lower array boundary is specific to the data port size. 
                    // The higher array boundary is core-specific. 
                    // In some cases (such as FIFO interfaces) 
                    // the array may not be present on the interface. 

output [(WB_SLAVE *ADR_WD)-1:0] wbd_adr_slave; 
                    // The address output array [ADR_O(63..0)] is used 
                    // to pass a binary address, with the most significant 
                    // address bit at the higher numbered end of the signal array. 
                    // The lower array boundary is specific to the data port size. 
                    // The higher array boundary is core-specific. 
                    // In some cases (such as FIFO interfaces) 
                    // the array may not be present on the interface. 

input [(WB_MASTER * BE_WD)-1:0] wbd_be_master; // Byte Enable 
                    // SEL_O(7..0) The select output array [SEL_O(7..0)] indicates 
                    // where valid data is expected on the [DAT_I(63..0)] signal 
                    // array during READ cycles, and where it is placed on the 
                    // [DAT_O(63..0)] signal array during WRITE cycles. 
                    // Also see the [DAT_I(63..0)], [DAT_O(63..0)] and [STB_O] 
                    // signal descriptions.
output [(WB_SLAVE * BE_WD)-1:0] wbd_be_slave; // Byte Enable  
                    // SEL_O(7..0) The select output array [SEL_O(7..0)] indicates 
                    // where valid data is expected on the [DAT_I(63..0)] signal 
                    // array during READ cycles, and where it is placed on the 
                    // [DAT_O(63..0)] signal array during WRITE cycles. 
                    // Also see the [DAT_I(63..0)], [DAT_O(63..0)] and [STB_O] 
                    // signal descriptions.

input [WB_SLAVE -1:0] wbd_cyc_master; 
                    // CYC_O The cycle output [CYC_O], when asserted, 
                    // indicates that a valid bus cycle is in progress. 
                    // The signal is asserted for the duration of all bus cycles. 
                    // For example, during a BLOCK transfer cycle there can be 
                    // multiple data transfers. The [CYC_O] signal is asserted 
                    // during the first data transfer, and remains asserted 
                    // until the last data transfer. The [CYC_O] signal is useful 
                    // for interfaces with multi-port interfaces 
                    // (such as dual port memories). In these cases, 
                    // the [CYC_O] signal requests use of a common bus from an 
                    // arbiter. Once the arbiter grants the bus to the MASTER, 
                    // it is held until [CYC_O] is negated. 
output [WB_SLAVE -1:0] wbd_cyc_slave; 
                    // CYC_O The cycle output [CYC_O], when asserted, 
                    // indicates that a valid bus cycle is in progress. 
                    // The signal is asserted for the duration of all bus cycles. 
                    // For example, during a BLOCK transfer cycle there can be 
                    // multiple data transfers. The [CYC_O] signal is asserted 
                    // during the first data transfer, and remains asserted 
                    // until the last data transfer. The [CYC_O] signal is useful 
                    // for interfaces with multi-port interfaces 
                    // (such as dual port memories). In these cases, 
                    // the [CYC_O] signal requests use of a common bus from an 
                    // arbiter. Once the arbiter grants the bus to the MASTER, 
                    // it is held until [CYC_O] is negated. 

input [(WB_MASTER * D_WD)-1:0] wbd_din_master;  
                    // DAT_I(63..0) The data input array [DAT_I(63..0)] is 
                    // used to pass binary data. The array boundaries are 
                    // determined by the port size. Also see the [DAT_O(63..0)] 
                    // and [SEL_O(7..0)] signal descriptions. 

output [(WB_SLAVE * D_WD)-1:0] wbd_din_slave;  
                    // DAT_I(63..0) The data input array [DAT_I(63..0)] is 
                    // used to pass binary data. The array boundaries are 
                    // determined by the port size. Also see the [DAT_O(63..0)] 
                    // and [SEL_O(7..0)] signal descriptions. 

output [(WB_MASTER * D_WD)-1:0] wbd_dout_master; 
                    // DAT_O(63..0) The data output array [DAT_O(63..0)] is 
                    // used to pass binary data. The array boundaries are 
                    // determined by the port size. Also see the [DAT_I(63..0)] 
                         // and [SEL_O(7..0)] signal descriptions. 
input [(WB_SLAVE * D_WD)-1:0] wbd_dout_slave; 
                    // DAT_O(63..0) The data output array [DAT_O(63..0)] is 
                    // used to pass binary data. The array boundaries are 
                    // determined by the port size. Also see the [DAT_I(63..0)] 
                    // and [SEL_O(7..0)] signal descriptions. 

output [WB_MASTER -1:0]  wbd_err_master; 
                    // ERR_I The error input [ERR_I] indicates an abnormal 
                    // cycle termination. The source of the error, and the 
                    // response generated by the MASTER is defined by the IP core 
                    // supplier in the WISHBONE DATASHEET. Also see the [ACK_I] 
                    // and [RTY_I] signal descriptions. 
input [WB_SLAVE -1:0]  wbd_err_slave; 
                    // ERR_I The error input [ERR_I] indicates an abnormal 
                    // cycle termination. The source of the error, and the 
                    // response generated by the MASTER is defined by the IP core 
                    // supplier in the WISHBONE DATASHEET. Also see the [ACK_I] 
                    // and [RTY_I] signal descriptions. 

output [WB_MASTER -1:0]   wbd_rty_master; 
                    // RTY_I The retry input [RTY_I] indicates that the indicates 
                    // that the interface is not ready to accept or send data, and 
                    // that the cycle should be retried. When and how the cycle is 
                    // retried is defined by the IP core supplier in the WISHBONE 
                    // DATASHEET. Also see the [ERR_I] and [RTY_I] signal 
                    // descriptions. 
input [WB_SLAVE -1:0]   wbd_rty_slave; 
                    // RTY_I The retry input [RTY_I] indicates that the indicates 
                    // that the interface is not ready to accept or send data, and 
                    // that the cycle should be retried. When and how the cycle is 
                    // retried is defined by the IP core supplier in the WISHBONE 
                    // DATASHEET. Also see the [ERR_I] and [RTY_I] signal 
                    // descriptions. 


reg  [WB_MASTER-1:0]  wbd_ack_master; 
reg  [WB_MASTER-1:0]  wbd_err_master; 
reg  [WB_MASTER-1:0]  wbd_rty_master; 


reg  [WB_MASTER-1:0]  master_busy; // master busy flag
reg  [WB_SLAVE-1:0]   slave_busy;  // slave busy flag
reg  [TAR_WD -1:0]     master_mx_id[WB_MASTER-1:0];
reg  [TAR_WD -1:0]     slave_mx_id [WB_SLAVE-1:0];

reg  [TAR_WD-1 :0]     cur_target_id;
wire  [TAR_WD-1:0]     wbd_taddr_master_t[WB_MASTER:0]; // target address from master 
wire  [D_WD-1:0]       wbd_din_master_t[WB_MASTER-1:0]; // target address from master 
reg   [D_WD-1:0]       wbd_dout_master_t[WB_MASTER-1:0]; // target address from master 
wire  [ADR_WD-1:0]     wbd_adr_master_t[WB_MASTER-1:0]; // target address from master 
wire  [BE_WD-1:0]      wbd_be_master_t[WB_MASTER-1:0]; // target address from master 


reg  [WB_SLAVE-1:0]  wbd_stb_slave; 
reg  [WB_SLAVE-1:0]  wbd_we_slave; 
reg  [WB_SLAVE-1:0]  wbd_cyc_slave; 
wire [D_WD-1:0]      wbd_dout_slave_t[WB_SLAVE-1:0]; // target data towards master 


reg   [D_WD-1:0]     wbd_din_slave_t[WB_SLAVE-1:0]; // target address from master 
reg   [ADR_WD-1:0]    wbd_adr_slave_t[WB_SLAVE-1:0]; // target address from master 
reg   [BE_WD-1:0]     wbd_be_slave_t[WB_SLAVE-1:0]; // target address from master 

integer i,k,l;

  
/**********************************************************
   Re-Arraging the array in seperate two dimensional information
***********************************************************/

genvar j,m; 
generate        

  // Connect the Master Mux
  for(j=0; j < WB_MASTER ; j = j + 1) begin : master_expand
     assign wbd_taddr_master_t[j] = wbd_taddr_master[((j+1)*TAR_WD)-1:j * TAR_WD];
     assign wbd_din_master_t[j]  = wbd_din_master[((j+1)*D_WD)-1:j * D_WD];
     assign wbd_adr_master_t[j]  = wbd_adr_master[((j+1)*ADR_WD)-1:j * ADR_WD];
     assign wbd_be_master_t[j]   = wbd_be_master[((j+1)*BE_WD)-1:j * BE_WD];

     assign wbd_dout_master[((j+1)*D_WD)-1:j * D_WD] = wbd_dout_master_t[j];
  end

  // Connect the Slave Mux
  for(m=0; m < WB_SLAVE ; m = m + 1) begin : slave_expand
     assign wbd_din_slave[((m+1)*D_WD)-1:m * D_WD]        = wbd_din_slave_t[m];
     assign wbd_adr_slave[((m+1)*ADR_WD)-1:m * ADR_WD]   = wbd_adr_slave_t[m];
     assign wbd_be_slave[((m+1)*BE_WD)-1:m * BE_WD]      = wbd_be_slave_t[m];

     assign wbd_dout_slave_t[m]   = wbd_dout_slave[((m+1)*D_WD)-1:m * D_WD];

  end
endgenerate

always @*   begin
   for(k = 0; k < WB_MASTER; k = k + 1) begin
      if(master_busy[k] == 1) begin
         wbd_dout_master_t[k] = wbd_dout_slave_t[master_mx_id[k]];
         wbd_ack_master[k]    = wbd_ack_slave[master_mx_id[k]];
         wbd_err_master[k]    = wbd_err_slave[master_mx_id[k]];
         wbd_rty_master[k]    = wbd_rty_slave[master_mx_id[k]];
      end else begin
         wbd_dout_master_t[k] = 0;
         wbd_ack_master[k]    = 0;
         wbd_err_master[k]    = 0;
         wbd_rty_master[k]    = 0;
      end
   end
   for(l = 0; l < WB_SLAVE; l = l + 1) begin
      if(slave_busy[l] == 1) begin
         wbd_din_slave_t[l]  = wbd_din_master_t[slave_mx_id[l]];
         wbd_adr_slave_t[l]  = wbd_adr_master_t[slave_mx_id[l]];
         wbd_be_slave_t[l]   = wbd_be_master_t[slave_mx_id[l]];
         wbd_stb_slave[l]    = wbd_stb_master[slave_mx_id[l]];
         wbd_we_slave[l]     = wbd_we_master[slave_mx_id[l]];
         wbd_cyc_slave[l]    = wbd_cyc_master[slave_mx_id[l]];
      end else begin
         wbd_din_slave_t[l]  = 0;
         wbd_adr_slave_t[l]  = 0;
         wbd_be_slave_t[l]   = 0;
         wbd_stb_slave[l]    = 0;
         wbd_we_slave[l]     = 0;
         wbd_cyc_slave[l]    = 0;
      end
   end
end

/*******************************************************
   Parsing through the master and deciding on mux connectio
   Step-1: analysis the master from 0 to total master
   Step-2: If the previously master is not busy, 
           Then check for any new request from the master and
           check corresponding slave is free or not. If there is 
           master request and requesting slave is free. 
           Then set the master max id to slave id &
           requesting slave to master number & set the master
           and slave busy flag
   Step-3: If the previous state of master is busy and bus-cycle
           is de-asserted, then reset the master and corresponding
           slave busy flag

*********************************************************/ 

always @(negedge rst_n or posedge clk) begin
   if(rst_n == 0) begin
      master_busy   = 0;
      slave_busy    = 0;
      cur_target_id = 0;
      
   end
   else begin
      for(i = 0; i < WB_MASTER; i = i + 1) begin
         cur_target_id                     = wbd_taddr_master_t[i];
         if(master_busy[i] == 0) begin
            if(wbd_stb_master[i] & slave_busy[cur_target_id] == 0) begin
               master_mx_id[i] <= cur_target_id;
               slave_mx_id [cur_target_id] = i;
               slave_busy[cur_target_id]   = 1;
               master_busy[i]              = 1;
               // synopsys translate_off
               // $display("%m:%t: Locking Master : %d with Slave : %d",$time,i,cur_target_id);
               // synopsys translate_on
            end
         end else if(wbd_cyc_master[i] == 0) begin
            master_busy[i]            = 0;
            slave_busy[cur_target_id] = 0;
         end
      end
   end
end



endmodule
