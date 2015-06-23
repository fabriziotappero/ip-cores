// B2X Command
// SDRAM Commands (CS_N, RAS_N, CAS_N, WE_N)
// 12 bit subtractor is not feasibile for FPGA, so changed to 6 bits
  //  Request Width 12 for ASIC and 6 for FPGA
/*********************************************************************
  SDRAM Controller top File                                  
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
  Description: SDRAM Controller Top Module.
    Support 81/6/32 Bit SDRAM.
    Column Address is Programmable
    Bank Bit are 2 Bit
    Row Bits are 12 Bits
    This block integrate following sub modules
    sdrc_core   
        SDRAM Controller file
    wb2sdrc    
        This module transalate the bus protocl from wishbone to custome
	sdram controller
  To Do:                                                      
    nothing                                                   
  Author(s): Dinesh Annayya, dinesha@opencores.org                 
  Version  : 0.0 - 8th Jan 2012
                Initial version with 16/32 Bit SDRAM Support
           : 0.1 - 24th Jan 2012
	         8 Bit SDRAM Support is added
	     0.2 - 31st Jan 2012
	         sdram_dq and sdram_pad_clk are internally generated
 Copyright (C) 2000 Authors and OPENCORES.ORG                
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
*******************************************************************/
module wb_sdr_ctrl_def 
           (
                    cfg_sdr_width       ,
                    cfg_colbits         ,
                // WB bus
                    wb_rst_i            ,
                    wb_clk_i            ,
                    wb_stb_i            ,
                    wb_ack_o            ,
                    wb_addr_i           ,
                    wb_we_i             ,
                    wb_dat_i            ,
                    wb_sel_i            ,
                    wb_dat_o            ,
                    wb_cyc_i            ,
		/* Interface to SDRAMs */
                    sdram_clk           ,
                    sdram_resetn        ,
                    sdr_cs_n            ,
                    sdr_cke             ,
                    sdr_ras_n           ,
                    sdr_cas_n           ,
                    sdr_we_n            ,
                    sdr_dqm             ,
                    sdr_ba              ,
                    sdr_addr            , 
                    sdr_dout            ,
                    sdr_din             ,
                    sdr_den             ,
                    sdr_dq              ,
		/* Parameters */
                    sdr_init_done       ,
                    cfg_req_depth       ,	        //how many req. buffer should hold
                    cfg_sdr_en          ,
                    cfg_sdr_mode_reg    ,
                    cfg_sdr_tras_d      ,
                    cfg_sdr_trp_d       ,
                    cfg_sdr_trcd_d      ,
                    cfg_sdr_cas         ,
                    cfg_sdr_trcar_d     ,
                    cfg_sdr_twr_d       ,
                    cfg_sdr_rfsh        ,
	            cfg_sdr_rfmax
	    );
parameter      APP_AW   = 25;  // Application Address Width
parameter      APP_DW   = 32;  // Application Data Width 
parameter      APP_BW   = 4;   // Application Byte Width
parameter      APP_RW   = 9;   // Application Request Width
parameter      SDR_DW   = 16;  // SDR Data Width 
parameter      SDR_BW   = 2;   // SDR Byte Width
parameter      SDR_RFSH_TIMER_W   = 12;
parameter      SDR_RFSH_ROW_CNT_W = 3;
parameter      dw       = 32;  // data width
parameter      tw       = 8;   // tag id width
parameter      bl       = 9;   // burst_lenght_width 
//-----------------------------------------------
// Global Variable
// ----------------------------------------------
input                   sdram_clk          ; // SDRAM Clock 
input                   sdram_resetn       ; // Reset Signal
input [1:0]             cfg_sdr_width      ; // 2'b00 - 32 Bit SDR, 2'b01 - 16 Bit SDR, 2'b1x - 8 Bit
input [1:0]             cfg_colbits        ; // 2'b00 - 8 Bit column address, 
                                             // 2'b01 - 9 Bit, 10 - 10 bit, 11 - 11Bits
//--------------------------------------
// Wish Bone Interface
// -------------------------------------      
input                   wb_rst_i           ;
input                   wb_clk_i           ;
input                   wb_stb_i           ;
output                  wb_ack_o           ;
input [24:0]            wb_addr_i          ;
input                   wb_we_i            ; // 1 - Write, 0 - Read
input [dw-1:0]          wb_dat_i           ;
input [dw/8-1:0]        wb_sel_i           ; // Byte enable
output [dw-1:0]         wb_dat_o           ;
input                   wb_cyc_i           ;
//------------------------------------------------
// Interface to SDRAMs
//------------------------------------------------
output                  sdr_cke             ; // SDRAM CKE
output 			sdr_cs_n            ; // SDRAM Chip Select
output                  sdr_ras_n           ; // SDRAM ras
output                  sdr_cas_n           ; // SDRAM cas
output			sdr_we_n            ; // SDRAM write enable
output [SDR_BW-1:0] 	sdr_dqm             ; // SDRAM Data Mask
output [1:0] 		sdr_ba              ; // SDRAM Bank Enable
output [11:0] 		sdr_addr            ; // SDRAM Address
inout [SDR_DW-1:0] 	sdr_dq              ; // SDRAM Data Input/output
input  [SDR_DW-1:0]     sdr_din             ; // SDRAM Data Output   
output  [SDR_DW-1:0]    sdr_dout            ; // SDRAM Data Output
output                  sdr_den             ; // SDRAM Data Output enable
//------------------------------------------------
// Configuration Parameter
//------------------------------------------------
output                  sdr_init_done       ; // Indicate SDRAM Initialisation Done
input [3:0] 		cfg_sdr_tras_d      ; // Active to precharge delay
input [3:0]             cfg_sdr_trp_d       ; // Precharge to active delay
input [3:0]             cfg_sdr_trcd_d      ; // Active to R/W delay
input 			cfg_sdr_en          ; // Enable SDRAM controller
input [1:0] 		cfg_req_depth       ; // Maximum Request accepted by SDRAM controller
input [11:0] 		cfg_sdr_mode_reg    ;
input [2:0] 		cfg_sdr_cas         ; // SDRAM CAS Latency
input [3:0] 		cfg_sdr_trcar_d     ; // Auto-refresh period
input [3:0]             cfg_sdr_twr_d       ; // Write recovery delay
input [SDR_RFSH_TIMER_W   -1 : 0] cfg_sdr_rfsh;
input [SDR_RFSH_ROW_CNT_W -1 : 0] cfg_sdr_rfmax;
//--------------------------------------------
// SDRAM controller Interface 
//--------------------------------------------
wire                  app_req            ; // SDRAM request
wire [24:0]           app_req_addr       ; // SDRAM Request Address
wire [bl-1:0]         app_req_len        ;
wire                  app_req_wr_n       ; // 0 - Write, 1 -> Read
wire                  app_req_ack        ; // SDRAM request Accepted
wire [dw/8-1:0]       app_wr_en_n        ; // Active low sdr byte-wise write data valid
wire                  app_wr_next_req    ; // Ready to accept the next write
wire                  app_rd_valid       ; // sdr read valid
wire                  app_last_rd        ; // Indicate last Read of Burst Transfer
wire                  app_last_wr        ; // Indicate last Write of Burst Transfer
wire [dw-1:0]         app_wr_data        ; // sdr write data
wire  [dw-1:0]        app_rd_data        ; // sdr read data
/****************************************
*  These logic has to be implemented using Pads
*  **************************************/
wire  [SDR_DW-1:0]    pad_sdr_din         ; // SDRA Data Input
wire  [SDR_BW-1:0]    sdr_den_n           ; // SDRAM Data Output enable
assign   sdr_den = (&sdr_den_n == 1'b0); 
assign   sdr_dq = (&sdr_den_n == 1'b0) ? sdr_dout :  {SDR_DW{1'bz}}; 
assign   pad_sdr_din = sdr_dq;
// sdram pad clock is routed back through pad
// SDRAM Clock from Pad, used for registering Read Data
wire  sdram_pad_clk = sdram_clk;
/************** Ends Here **************************/
wb2sdrc #(.dw(dw),.tw(tw),.bl(bl)) u_wb2sdrc (
      // WB bus
          .wb_rst_i           (wb_rst_i           ) ,
          .wb_clk_i           (wb_clk_i           ) ,
          .wb_stb_i           (wb_stb_i           ) ,
          .wb_ack_o           (wb_ack_o           ) ,
          .wb_addr_i          (wb_addr_i          ) ,
          .wb_we_i            (wb_we_i            ) ,
          .wb_dat_i           (wb_dat_i           ) ,
          .wb_sel_i           (wb_sel_i           ) ,
          .wb_dat_o           (wb_dat_o           ) ,
          .wb_cyc_i           (wb_cyc_i           ) ,
      //SDRAM Controller Hand-Shake Signal 
          .sdram_clk          (sdram_clk          ) ,
          .sdram_resetn       (sdram_resetn       ) ,
          .sdr_req            (app_req            ) ,
          .sdr_req_addr       (app_req_addr       ) ,
          .sdr_req_len        (app_req_len        ) ,
          .sdr_req_wr_n       (app_req_wr_n       ) ,
          .sdr_req_ack        (app_req_ack        ) ,
          .sdr_wr_en_n        (app_wr_en_n        ) ,
          .sdr_wr_next        (app_wr_next_req    ) ,
          .sdr_rd_valid       (app_rd_valid       ) ,
          .sdr_last_rd        (app_last_rd        ) ,
          .sdr_wr_data        (app_wr_data        ) ,
          .sdr_rd_data        (app_rd_data        ) 
      ); 
sdrc_core 
#(.SDR_DW                  ( SDR_DW            ) , 
  .SDR_BW                  ( SDR_BW            ) ,
  .SDR_RFSH_TIMER_W        ( SDR_RFSH_TIMER_W  ) , 
  .SDR_RFSH_ROW_CNT_W      ( SDR_RFSH_ROW_CNT_W) 
  ) u_sdrc_core (
          .clk                (sdram_clk          ) ,
          .pad_clk            (sdram_pad_clk      ) ,
          .reset_n            (sdram_resetn       ) ,
          .sdr_width          (cfg_sdr_width      ) ,
          .cfg_colbits        (cfg_colbits        ) ,
 		/* Request from app */
          .app_req            (app_req            ) ,// Transfer Request
          .app_req_addr       (app_req_addr       ) ,// SDRAM Address
          .app_req_len        (app_req_len        ) ,// Burst Length (in 16 bit words)
          .app_req_wrap       (1'b0               ) ,// Wrap mode request 
          .app_req_wr_n       (app_req_wr_n       ) ,// 0 => Write request, 1 => read req
          .app_req_ack        (app_req_ack        ) ,// Request has been accepted
          .cfg_req_depth      (cfg_req_depth      ) ,//how many req. buffer should hold
          .app_wr_data        (app_wr_data        ) ,
          .app_wr_en_n        (app_wr_en_n        ) ,
          .app_rd_data        (app_rd_data        ) ,
          .app_rd_valid       (app_rd_valid       ) ,
	  .app_last_rd        (app_last_rd        ) ,
          .app_last_wr        (app_last_wr        ) ,
          .app_wr_next_req    (app_wr_next_req    ) ,
          .sdr_init_done      (sdr_init_done      ) ,
          .app_req_dma_last   (app_req            ) ,
 		/* Interface to SDRAMs */
          .sdr_cs_n           (sdr_cs_n           ) ,
          .sdr_cke            (sdr_cke            ) ,
          .sdr_ras_n          (sdr_ras_n          ) ,
          .sdr_cas_n          (sdr_cas_n          ) ,
          .sdr_we_n           (sdr_we_n           ) ,
          .sdr_dqm            (sdr_dqm            ) ,
          .sdr_ba             (sdr_ba             ) ,
          .sdr_addr           (sdr_addr           ) , 
          .pad_sdr_din        (pad_sdr_din        ) ,
          .sdr_dout           (sdr_dout           ) ,
          .sdr_den_n          (sdr_den_n          ) ,
 		/* Parameters */
          .cfg_sdr_en         (cfg_sdr_en         ) ,
          .cfg_sdr_mode_reg   (cfg_sdr_mode_reg   ) ,
          .cfg_sdr_tras_d     (cfg_sdr_tras_d     ) ,
          .cfg_sdr_trp_d      (cfg_sdr_trp_d      ) ,
          .cfg_sdr_trcd_d     (cfg_sdr_trcd_d     ) ,
          .cfg_sdr_cas        (cfg_sdr_cas        ) ,
          .cfg_sdr_trcar_d    (cfg_sdr_trcar_d    ) ,
          .cfg_sdr_twr_d      (cfg_sdr_twr_d      ) ,
          .cfg_sdr_rfsh       (cfg_sdr_rfsh       ) ,
          .cfg_sdr_rfmax      (cfg_sdr_rfmax      ) 
	       );
endmodule // sdrc_core
/*********************************************************************
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
  Description: WISHBONE to SDRAM Controller Bus Transalator
     1. This module translate the WISHBONE protocol to custom sdram controller i/f 
     2. Also Handle the clock domain change from Application layer to Sdram layer
  To Do:                                                      
    nothing                                                   
  Author(s):  Dinesh Annayya, dinesha@opencores.org                 
  Version  : 0.0 - Initial Release
             0.1 - 2nd Feb 2012
	           Async Fifo towards the application layer is selected 
		   with Registered Full Generation
             0.2 - 2nd Feb 2012
	           Pending Read generation bug fix done to handle backto back write 
		   followed by read request
 Copyright (C) 2000 Authors and OPENCORES.ORG                
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
*******************************************************************/
module wb2sdrc (
      // WB bus
                    wb_rst_i            ,
                    wb_clk_i            ,
                    wb_stb_i            ,
                    wb_ack_o            ,
                    wb_addr_i           ,
                    wb_we_i             ,
                    wb_dat_i            ,
                    wb_sel_i            ,
                    wb_dat_o            ,
                    wb_cyc_i            ,
      //SDRAM Controller Hand-Shake Signal 
                    sdram_clk           ,
                    sdram_resetn        ,
                    sdr_req             ,
                    sdr_req_addr        ,
                    sdr_req_len         ,
                    sdr_req_wr_n        ,
                    sdr_req_ack         ,
                    sdr_wr_en_n         ,
                    sdr_wr_next         ,
                    sdr_rd_valid        ,
                    sdr_last_rd         ,
                    sdr_wr_data         ,
                    sdr_rd_data        
      ); 
parameter      dw              = 32;  // data width
parameter      tw              = 8;   // tag id width
parameter      bl              = 9;   // burst_lenght_width 
//--------------------------------------
// Wish Bone Interface
// -------------------------------------      
input                   wb_rst_i           ;
input                   wb_clk_i           ;
input                   wb_stb_i           ;
output                  wb_ack_o           ;
input [24:0]            wb_addr_i          ;
input                   wb_we_i            ; // 1 - Write , 0 - Read
input [dw-1:0]          wb_dat_i           ;
input [dw/8-1:0]        wb_sel_i           ; // Byte enable
output [dw-1:0]         wb_dat_o           ;
input                   wb_cyc_i           ;
//--------------------------------------------
// SDRAM controller Interface 
//--------------------------------------------
input                   sdram_clk          ; // sdram clock
input                   sdram_resetn       ; // sdram reset
output                  sdr_req            ; // SDRAM request
output [24:0]           sdr_req_addr       ; // SDRAM Request Address
output [bl-1:0]         sdr_req_len        ;
output                  sdr_req_wr_n       ; // 0 - Write, 1 -> Read
input                   sdr_req_ack        ; // SDRAM request Accepted
output [dw/8-1:0]       sdr_wr_en_n        ; // Active low sdr byte-wise write data valid
input                   sdr_wr_next        ; // Ready to accept the next write
input                   sdr_rd_valid       ; // sdr read valid
input                   sdr_last_rd        ; // Indicate last Read of Burst Transfer
output [dw-1:0]         sdr_wr_data        ; // sdr write data
input  [dw-1:0]         sdr_rd_data        ; // sdr read data
//----------------------------------------------------
// Wire Decleration
// ---------------------------------------------------
wire                    cmdfifo_full       ;
wire                    cmdfifo_empty      ;
wire                    wrdatafifo_full    ;
wire                    wrdatafifo_empty   ;
wire                    tagfifo_full       ;
wire                    tagfifo_empty      ;
wire                    rddatafifo_empty   ;
wire                    rddatafifo_full    ;
reg                     pending_read       ;
//-----------------------------------------------------------------------------
// Ack Generaltion Logic
//  If Write Request - Acknowledge if the command and write FIFO are not full
//  If Read Request  - Generate the Acknowledgment once read fifo has data
//                     available
//-----------------------------------------------------------------------------
assign wb_ack_o = (wb_stb_i && wb_cyc_i && wb_we_i) ?  // Write Phase
	                  ((!cmdfifo_full) && (!wrdatafifo_full)) :
		  (wb_stb_i && wb_cyc_i && !wb_we_i) ? // Read Phase 
		           !rddatafifo_empty : 1'b0;
//---------------------------------------------------------------------------
// Command FIFO Write Generation
//    If Write Request - Generate write, when Write fifo and command fifo is
//                       not full
//    If Read Request - Generate write, when command fifo not full and there
//                      is no pending read request.
//---------------------------------------------------------------------------
wire           cmdfifo_wr   = (wb_stb_i && wb_cyc_i && wb_we_i && (!cmdfifo_full) ) ? wb_ack_o :
	                      (wb_stb_i && wb_cyc_i && !wb_we_i && (!cmdfifo_full)) ? !pending_read: 1'b0 ; 
//---------------------------------------------------------------------------
// command fifo read generation
//    Command FIFo read will be generated, whenever SDRAM Controller
//    Acknowldge the Request
//----------------------------------------------------------------------------
wire           cmdfifo_rd   = sdr_req_ack;
//---------------------------------------------------------------------------
// Application layer request is generated towards the controller, whenever
// Command FIFO is not full
// --------------------------------------------------------------------------
assign         sdr_req      = !cmdfifo_empty;
//----------------------------------------------------------------------------
// Since Burst length is not known at the start of the Burst, It's assumed as
// Single Cycle Burst. We need to improvise this ...
// --------------------------------------------------------------------------
wire [bl-1:0]  burst_length  = 1;  // 0 Mean 1 Transfer
//-----------------------------------------------------------------------------
// In Wish Bone Spec, For Read Request has to be acked along with data.
// We need to identify the pending read request.
// Once we accept the read request, we should not accept one more read
// request, untill we have transmitted the read data.
//  Pending Read will 
//     set - with Read Request 
//     reset - with Read Request + Ack
// ----------------------------------------------------------------------------
always @(posedge wb_rst_i or posedge wb_clk_i) begin
   if(wb_rst_i) begin
       pending_read <= 1'b0;
   end else begin
      //pending_read <=  wb_stb_i & wb_cyc_i & !wb_we_i & !wb_ack_o;
      pending_read <=   (cmdfifo_wr && !wb_we_i) ? 1'b1:
	                (wb_stb_i & wb_cyc_i & !wb_we_i & wb_ack_o) ? 1'b0: pending_read;
   end
end
//---------------------------------------------------------------------
// Async Command FIFO. This block handle the clock domain change from
// Application layer to SDRAM Controller
// ------------------------------------------------------------------
   // Address + Burst Length + W/R Request 
    async_fifo #(.W(25+bl+1),.DP(4),.WR_FAST(1'b0), .RD_FAST(1'b0)) u_cmdfifo (
     // Write Path Sys CLock Domain
          .wr_clk             (wb_clk_i           ),
          .wr_reset_n         (!wb_rst_i          ),
          .wr_en              (cmdfifo_wr         ),
          .wr_data            ({burst_length, 
	                        !wb_we_i, 
				wb_addr_i}        ),
          .afull              (                   ),
          .full               (cmdfifo_full       ),
     // Read Path, SDRAM clock domain
          .rd_clk             (sdram_clk          ),
          .rd_reset_n         (sdram_resetn       ),
          .aempty             (                   ),
          .empty              (cmdfifo_empty      ),
          .rd_en              (cmdfifo_rd         ),
          .rd_data            ({sdr_req_len,
	                        sdr_req_wr_n,
		                sdr_req_addr}     )
     );
always @(posedge wb_clk_i) begin
  if (cmdfifo_full == 1'b1 && cmdfifo_wr == 1'b1)  begin
     $display("ERROR:%m COMMAND FIFO WRITE OVERFLOW");
  end 
end 
always @(posedge sdram_clk) begin
   if (cmdfifo_empty == 1'b1 && cmdfifo_rd == 1'b1) begin
      $display("ERROR:%m COMMAND FIFO READ OVERFLOW");
   end
end 
 //  `ifndef SYNTHESYS
//---------------------------------------------------------------------
// Write Data FIFO Write Generation, when ever Acked + Write Request
//   Note: Ack signal generation already taking account of FIFO full condition
// ---------------------------------------------------------------------
wire  wrdatafifo_wr  = wb_ack_o & wb_we_i ;
//------------------------------------------------------------------------
// Write Data FIFO Read Generation, When ever Next Write request generated
// from SDRAM Controller
// ------------------------------------------------------------------------
wire  wrdatafifo_rd  = sdr_wr_next;
//------------------------------------------------------------------------
// Async Write Data FIFO
//    This block handle the clock domain change over + Write Data + Byte mask 
//    From Application layer to SDRAM controller layer
//------------------------------------------------------------------------
   // Write DATA + Data Mask FIFO
    async_fifo #(.W(dw+(dw/8)), .DP(8), .WR_FAST(1'b0), .RD_FAST(1'b1)) u_wrdatafifo (
       // Write Path , System clock domain
          .wr_clk             (wb_clk_i           ),
          .wr_reset_n         (!wb_rst_i          ),
          .wr_en              (wrdatafifo_wr      ),
          .wr_data            ({~wb_sel_i, 
	                         wb_dat_i}        ),
          .afull              (                   ),
          .full               (wrdatafifo_full    ),
       // Read Path , SDRAM clock domain
          .rd_clk             (sdram_clk          ),
          .rd_reset_n         (sdram_resetn       ),
          .aempty             (                   ),
          .empty              (wrdatafifo_empty   ),
          .rd_en              (wrdatafifo_rd      ),
          .rd_data            ({sdr_wr_en_n,
                                sdr_wr_data}      )
     );
always @(posedge wb_clk_i) begin
  if (wrdatafifo_full == 1'b1 && wrdatafifo_wr == 1'b1)  begin
     $display("ERROR:%m WRITE DATA FIFO WRITE OVERFLOW");
  end 
end 
always @(posedge sdram_clk) begin
   if (wrdatafifo_empty == 1'b1 && wrdatafifo_rd == 1'b1) begin
      $display("ERROR:%m WRITE DATA FIFO READ OVERFLOW");
   end
end 
 //  `ifndef SYNTHESYS
// -------------------------------------------------------------------
//  READ DATA FIFO
//  ------------------------------------------------------------------
wire    rd_eop; // last read indication
// Read FIFO write generation, when ever SDRAM controller issues the read
// valid signal
wire    rddatafifo_wr = sdr_rd_valid;
// Read FIFO read generation, when ever ack is generated along with read
// request.
// Note: Ack generation is already accounted the write FIFO Not Empty
//       condition
wire    rddatafifo_rd = wb_ack_o & !wb_we_i;
//-------------------------------------------------------------------------
// Async Read FIFO
// This block handles the clock domain change over + Read data from SDRAM
// controller to Application layer.
//  Note: 
//    1. READ DATA FIFO depth is kept small, assuming that Sys-CLock > SDRAM Clock
//       READ DATA + EOP
//    2. EOP indicate, last transfer of Burst Read Access. use-full for future
//       Tag handling per burst
//
// ------------------------------------------------------------------------
    async_fifo #(.W(dw+1), .DP(4), .WR_FAST(1'b0), .RD_FAST(1'b1) ) u_rddatafifo (
       // Write Path , SDRAM clock domain
          .wr_clk             (sdram_clk          ),
          .wr_reset_n         (sdram_resetn       ),
          .wr_en              (rddatafifo_wr      ),
          .wr_data            ({sdr_last_rd,
	                        sdr_rd_data}      ),
          .afull              (                   ),
          .full               (rddatafifo_full    ),
       // Read Path , SYS clock domain
          .rd_clk             (wb_clk_i           ),
          .rd_reset_n         (!wb_rst_i          ),
          .empty              (rddatafifo_empty   ),
          .aempty             (                   ),
          .rd_en              (rddatafifo_rd      ),
          .rd_data            ({rd_eop,
                                wb_dat_o}         )
     );
always @(posedge sdram_clk) begin
  if (rddatafifo_full == 1'b1 && rddatafifo_wr == 1'b1)  begin
     $display("ERROR:%m READ DATA FIFO WRITE OVERFLOW");
  end 
end 
always @(posedge wb_clk_i) begin
   if (rddatafifo_empty == 1'b1 && rddatafifo_rd == 1'b1) begin
      $display("ERROR:%m READ DATA FIFO READ OVERFLOW");
   end
end 
 //  `ifndef SYNTHESYS
endmodule
/*********************************************************************
  ASYNC FIFO
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
  Description: ASYNC FIFO 
  To Do:                                                      
    nothing                                                   
  Author(s):  Dinesh Annayya, dinesha@opencores.org                 
 Copyright (C) 2000 Authors and OPENCORES.ORG                
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
*******************************************************************/
//-------------------------------------------
// async FIFO
//-----------------------------------------------
`timescale  1ns/1ps
module async_fifo (wr_clk,
                   wr_reset_n,
                   wr_en,
                   wr_data,
                   full,                 // sync'ed to wr_clk
                   afull,                 // sync'ed to wr_clk
                   rd_clk,
                   rd_reset_n,
                   rd_en,
                   empty,                // sync'ed to rd_clk
                   aempty,                // sync'ed to rd_clk
                   rd_data);
   parameter W = 4'd8;
   parameter DP = 3'd4;
   parameter WR_FAST = 1'b1;
   parameter RD_FAST = 1'b1;
   parameter FULL_DP = DP;
   parameter EMPTY_DP = 1'b0;
   parameter AW = (DP == 2)   ? 1 : 
		  (DP == 4)   ? 2 :
                  (DP == 8)   ? 3 :
                  (DP == 16)  ? 4 :
                  (DP == 32)  ? 5 :
                  (DP == 64)  ? 6 :
                  (DP == 128) ? 7 :
                  (DP == 256) ? 8 : 0;
   output [W-1 : 0]  rd_data;
   input [W-1 : 0]   wr_data;
   input             wr_clk, wr_reset_n, wr_en, rd_clk, rd_reset_n,
                     rd_en;
   output            full, empty;
   output            afull, aempty;       // about full and about to empty
   reg [W-1 : 0]    mem[DP-1 : 0];
   /*********************** write side ************************/
   reg [AW:0] sync_rd_ptr_0, sync_rd_ptr_1; 
   wire [AW:0] sync_rd_ptr;
   reg [AW:0] wr_ptr, grey_wr_ptr;
   reg [AW:0] grey_rd_ptr;
   reg full_q;
   wire full_c;
   wire afull_c;
   wire [AW:0] wr_ptr_inc = wr_ptr + 1'b1;
   wire [AW:0] wr_cnt = get_cnt(wr_ptr, sync_rd_ptr);
   assign full_c  = (wr_cnt == FULL_DP) ? 1'b1 : 1'b0;
   assign afull_c = (wr_cnt == FULL_DP-1) ? 1'b1 : 1'b0;
   always @(posedge wr_clk or negedge wr_reset_n) begin
	if (!wr_reset_n) begin
		wr_ptr <= 0;
		grey_wr_ptr <= 0;
		full_q <= 0;	
	end
	else if (wr_en) begin
		wr_ptr <= wr_ptr_inc;
		grey_wr_ptr <= bin2grey(wr_ptr_inc);
		if (wr_cnt == (FULL_DP-1)) begin
			full_q <= 1'b1;
		end
	end
	else begin
	    	if (full_q && (wr_cnt<FULL_DP)) begin
			full_q <= 1'b0;
	     	end
	end
    end
    assign full  = (WR_FAST == 1) ? full_c : full_q;
    assign afull = afull_c;
    always @(posedge wr_clk) begin
	if (wr_en) begin
		mem[wr_ptr[AW-1:0]] <= wr_data;
	end
    end
    wire [AW:0] grey_rd_ptr_dly ;
    assign #1 grey_rd_ptr_dly = grey_rd_ptr;
    // read pointer synchronizer
    always @(posedge wr_clk or negedge wr_reset_n) begin
	if (!wr_reset_n) begin
		sync_rd_ptr_0 <= 0;
		sync_rd_ptr_1 <= 0;
	end
	else begin
		sync_rd_ptr_0 <= grey_rd_ptr_dly;		
		sync_rd_ptr_1 <= sync_rd_ptr_0;
	end
    end
    assign sync_rd_ptr = grey2bin(sync_rd_ptr_1);
   /************************ read side *****************************/
   reg [AW:0] sync_wr_ptr_0, sync_wr_ptr_1; 
   wire [AW:0] sync_wr_ptr;
   reg [AW:0] rd_ptr;
   reg empty_q;
   wire empty_c;
   wire aempty_c;
   wire [AW:0] rd_ptr_inc = rd_ptr + 1'b1;
   wire [AW:0] sync_wr_ptr_dec = sync_wr_ptr - 1'b1;
   wire [AW:0] rd_cnt = get_cnt(sync_wr_ptr, rd_ptr);
   assign empty_c  = (rd_cnt == 0) ? 1'b1 : 1'b0;
   assign aempty_c = (rd_cnt == 1) ? 1'b1 : 1'b0;
   always @(posedge rd_clk or negedge rd_reset_n) begin
      if (!rd_reset_n) begin
         rd_ptr <= 0;
	 grey_rd_ptr <= 0;
	 empty_q <= 1'b1;
      end
      else begin
         if (rd_en) begin
            rd_ptr <= rd_ptr_inc;
            grey_rd_ptr <= bin2grey(rd_ptr_inc);
            if (rd_cnt==(EMPTY_DP+1)) begin
               empty_q <= 1'b1;
            end
         end
         else begin
            if (empty_q && (rd_cnt!=EMPTY_DP)) begin
	      empty_q <= 1'b0;
	    end
         end
       end
    end
    assign empty  = (RD_FAST == 1) ? empty_c : empty_q;
    assign aempty = aempty_c;
    reg [W-1 : 0]  rd_data_q;
   wire [W-1 : 0] rd_data_c = mem[rd_ptr[AW-1:0]];
   always @(posedge rd_clk) begin
	rd_data_q <= rd_data_c;
   end
   assign rd_data  = (RD_FAST == 1) ? rd_data_c : rd_data_q;
    wire [AW:0] grey_wr_ptr_dly ;
    assign #1 grey_wr_ptr_dly =  grey_wr_ptr;
    // write pointer synchronizer
    always @(posedge rd_clk or negedge rd_reset_n) begin
	if (!rd_reset_n) begin
	   sync_wr_ptr_0 <= 0;
	   sync_wr_ptr_1 <= 0;
	end
	else begin
	   sync_wr_ptr_0 <= grey_wr_ptr_dly;		
	   sync_wr_ptr_1 <= sync_wr_ptr_0;
	end
    end
    assign sync_wr_ptr = grey2bin(sync_wr_ptr_1);
/************************ functions ******************************/
function [AW:0] bin2grey;
input [AW:0] bin;
reg [8:0] bin_8;
reg [8:0] grey_8;
begin
	bin_8 = bin;
	grey_8[1:0] = do_grey(bin_8[2:0]);
	grey_8[3:2] = do_grey(bin_8[4:2]);
	grey_8[5:4] = do_grey(bin_8[6:4]);
	grey_8[7:6] = do_grey(bin_8[8:6]);
	grey_8[8] = bin_8[8];
	bin2grey = grey_8;
end
endfunction
function [AW:0] grey2bin;
input [AW:0] grey;
reg [8:0] grey_8;
reg [8:0] bin_8;
begin
	grey_8 = grey;
	bin_8[8] = grey_8[8];
	bin_8[7:6] = do_bin({bin_8[8], grey_8[7:6]});
	bin_8[5:4] = do_bin({bin_8[6], grey_8[5:4]});
	bin_8[3:2] = do_bin({bin_8[4], grey_8[3:2]});
	bin_8[1:0] = do_bin({bin_8[2], grey_8[1:0]});
	grey2bin = bin_8;
end
endfunction
function [1:0] do_grey;
input [2:0] bin;
begin
	if (bin[2]) begin  // do reverse grey
		case (bin[1:0]) 
			2'b00: do_grey = 2'b10;
			2'b01: do_grey = 2'b11;
			2'b10: do_grey = 2'b01;
			2'b11: do_grey = 2'b00;
		endcase
	end
	else begin
		case (bin[1:0]) 
			2'b00: do_grey = 2'b00;
			2'b01: do_grey = 2'b01;
			2'b10: do_grey = 2'b11;
			2'b11: do_grey = 2'b10;
		endcase
	end
end
endfunction
function [1:0] do_bin;
input [2:0] grey;
begin
	if (grey[2]) begin	// actually bin[2]
		case (grey[1:0])
			2'b10: do_bin = 2'b00;
			2'b11: do_bin = 2'b01;
			2'b01: do_bin = 2'b10;
			2'b00: do_bin = 2'b11;
		endcase
	end
	else begin
		case (grey[1:0])
			2'b00: do_bin = 2'b00;
			2'b01: do_bin = 2'b01;
			2'b11: do_bin = 2'b10;
			2'b10: do_bin = 2'b11;
		endcase
	end
end
endfunction
function [AW:0] get_cnt;
input [AW:0] wr_ptr, rd_ptr;
begin
	if (wr_ptr >= rd_ptr) begin
		get_cnt = (wr_ptr - rd_ptr);	
	end
	else begin
		get_cnt = DP*2 - (rd_ptr - wr_ptr);
	end
end
endfunction
always @(posedge wr_clk) begin
   if (wr_en && full) begin
      $display($time, "%m Error! afifo overflow!");
      $stop;
   end
end
always @(posedge rd_clk) begin
   if (rd_en && empty) begin
      $display($time, "%m error! afifo underflow!");
      $stop;
   end
end
endmodule
/*********************************************************************
  SDRAM Controller Core File                                  
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
  Description: SDRAM Controller Core Module
    2 types of SDRAMs are supported, 1Mx16 2 bank, or 4Mx16 4 bank.
    This block integrate following sub modules
    sdrc_bs_convert   
        convert the system side 32 bit into equvailent 8/16/32 SDR format
    sdrc_req_gen    
        This module takes requests from the app, chops them to burst booundaries
        if wrap=0, decodes the bank and passe the request to bank_ctl
   sdrc_xfr_ctl
      This module takes requests from sdr_bank_ctl, runs the transfer and
      controls data flow to/from the app. At the end of the transfer it issues a
      burst terminate if not at the end of a burst and another command to this
      bank is not available.
   sdrc_bank_ctl
      This module takes requests from sdr_req_gen, checks for page hit/miss and
      issues precharge/activate commands and then passes the request to
      sdr_xfr_ctl. 
  Assumption: SDRAM Pads should be placed near to this module. else
  user should add a FF near the pads
  To Do:                                                      
    nothing                                                   
  Author(s):                                                  
      - Dinesh Annayya, dinesha@opencores.org                 
  Version  : 0.0 - 8th Jan 2012
                Initial version with 16/32 Bit SDRAM Support
           : 0.1 - 24th Jan 2012
	         8 Bit SDRAM Support is added
             0.2 - 2nd Feb 2012
	           Improved the command pipe structure to accept up-to 
		   4 command of different bank.
	     0.3 - 7th Feb 2012
	           Bug fix for parameter defination for request length has changed from 9 to 12
 Copyright (C) 2000 Authors and OPENCORES.ORG                
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
*******************************************************************/
module sdrc_core 
           (
		clk,
                pad_clk,
		reset_n,
                sdr_width,
		cfg_colbits,
		/* Request from app */
		app_req,	        // Transfer Request
		app_req_addr,	        // SDRAM Address
		app_req_len,	        // Burst Length (in 16 bit words)
		app_req_wrap,	        // Wrap mode request (xfr_len = 4)
		app_req_wr_n,	        // 0 => Write request, 1 => read req
		app_req_ack,	        // Request has been accepted
		cfg_req_depth,	        //how many req. buffer should hold
		app_wr_data,
                app_wr_en_n,
		app_last_wr,
		app_rd_data,
		app_rd_valid,
		app_last_rd,
		app_wr_next_req,
		sdr_init_done,
		app_req_dma_last,
		/* Interface to SDRAMs */
		sdr_cs_n,
		sdr_cke,
		sdr_ras_n,
		sdr_cas_n,
		sdr_we_n,
		sdr_dqm,
		sdr_ba,
		sdr_addr, 
		pad_sdr_din,
		sdr_dout,
		sdr_den_n,
		/* Parameters */
		cfg_sdr_en,
		cfg_sdr_mode_reg,
		cfg_sdr_tras_d,
		cfg_sdr_trp_d,
		cfg_sdr_trcd_d,
		cfg_sdr_cas,
		cfg_sdr_trcar_d,
		cfg_sdr_twr_d,
		cfg_sdr_rfsh,
		cfg_sdr_rfmax);
parameter  APP_AW   = 25;  // Application Address Width
parameter  APP_DW   = 32;  // Application Data Width 
parameter  APP_BW   = 4;   // Application Byte Width
parameter  APP_RW   = 9;   // Application Request Width
parameter  SDR_DW   = 16;  // SDR Data Width 
parameter  SDR_BW   = 2;   // SDR Byte Width
parameter  SDR_RFSH_TIMER_W   = 12;
parameter  SDR_RFSH_ROW_CNT_W = 3;
//-----------------------------------------------
// Global Variable
// ----------------------------------------------
input                   clk                 ; // SDRAM Clock 
input                   pad_clk             ; // SDRAM Clock from Pad, used for registering Read Data
input                   reset_n             ; // Reset Signal
input [1:0]             sdr_width           ; // 2'b00 - 32 Bit SDR, 2'b01 - 16 Bit SDR, 2'b1x - 8 Bit
input [1:0]             cfg_colbits         ; // 2'b00 - 8 Bit column address, 2'b01 - 9 Bit, 10 - 10 bit, 11 - 11Bits
//------------------------------------------------
// Request from app
//------------------------------------------------
input 			app_req             ; // Application Request
input [APP_AW-1:0] 	app_req_addr        ; // Address 
input 			app_req_wr_n        ; // 0 - Write, 1 - Read
input                   app_req_wrap        ; // Address Wrap
output                  app_req_ack         ; // Application Request Ack
input [APP_DW-1:0] 	app_wr_data         ; // Write Data
output 		        app_wr_next_req     ; // Next Write Data Request
input [APP_BW-1:0] 	app_wr_en_n         ; // Byte wise Write Enable
output                  app_last_wr         ; // Last Write trannsfer of a given Burst
output [APP_DW-1:0] 	app_rd_data         ; // Read Data
output                  app_rd_valid        ; // Read Valid
output                  app_last_rd         ; // Last Read Transfer of a given Burst
//------------------------------------------------
// Interface to SDRAMs
//------------------------------------------------
output                  sdr_cke             ; // SDRAM CKE
output 			sdr_cs_n            ; // SDRAM Chip Select
output                  sdr_ras_n           ; // SDRAM ras
output                  sdr_cas_n           ; // SDRAM cas
output			sdr_we_n            ; // SDRAM write enable
output [SDR_BW-1:0] 	sdr_dqm             ; // SDRAM Data Mask
output [1:0] 		sdr_ba              ; // SDRAM Bank Enable
output [11:0] 		sdr_addr            ; // SDRAM Address
input [SDR_DW-1:0] 	pad_sdr_din         ; // SDRA Data Input
output [SDR_DW-1:0] 	sdr_dout            ; // SDRAM Data Output
output [SDR_BW-1:0] 	sdr_den_n           ; // SDRAM Data Output enable
//------------------------------------------------
// Configuration Parameter
//------------------------------------------------
output                  sdr_init_done       ; // Indicate SDRAM Initialisation Done
input [3:0] 		cfg_sdr_tras_d      ; // Active to precharge delay
input [3:0]             cfg_sdr_trp_d       ; // Precharge to active delay
input [3:0]             cfg_sdr_trcd_d      ; // Active to R/W delay
input 			cfg_sdr_en          ; // Enable SDRAM controller
input [1:0] 		cfg_req_depth       ; // Maximum Request accepted by SDRAM controller
input [APP_RW-1:0]	app_req_len         ; // Application Burst Request length in 32 bit 
input [11:0] 		cfg_sdr_mode_reg    ;
input [2:0] 		cfg_sdr_cas         ; // SDRAM CAS Latency
input [3:0] 		cfg_sdr_trcar_d     ; // Auto-refresh period
input [3:0]             cfg_sdr_twr_d       ; // Write recovery delay
input [SDR_RFSH_TIMER_W-1 : 0] cfg_sdr_rfsh;
input [SDR_RFSH_ROW_CNT_W -1 : 0] cfg_sdr_rfmax;
input                   app_req_dma_last;    // this signal should close the bank
/****************************************************************************/
// Internal Nets
// SDR_REQ_GEN
wire [4-1:0]r2b_req_id;
wire [1:0] 		r2b_ba;
wire [11:0] 		r2b_raddr;
wire [11:0] 		r2b_caddr;
wire [6-1:0] 	r2b_len;
// SDR BANK CTL
wire [4-1:0]b2x_id;
wire [1:0] 		b2x_ba;
wire [11:0] 		b2x_addr;
wire [6-1:0] 	b2x_len;
wire [1:0] 		b2x_cmd;
// SDR_XFR_CTL
wire [3:0] 		x2b_pre_ok;
wire [4-1:0]xfr_id;
wire [APP_DW-1:0] 	app_rd_data;
wire 			sdr_cs_n, sdr_cke, sdr_ras_n, sdr_cas_n, sdr_we_n; 
wire [SDR_BW-1:0] 	sdr_dqm;
wire [1:0] 		sdr_ba;
wire [11:0] 		sdr_addr;
wire [SDR_DW-1:0] 	sdr_dout;
wire [SDR_DW-1:0] 	sdr_dout_int;
wire [SDR_BW-1:0] 	sdr_den_n;
wire [SDR_BW-1:0] 	sdr_den_n_int;
wire [1:0] 		xfr_bank_sel;
wire [APP_AW-1:0]        app_req_addr;
wire [APP_RW-1:0]        app_req_len;
wire [APP_DW-1:0]        app_wr_data;
wire [SDR_DW-1:0]        a2x_wrdt       ;
wire [APP_BW-1:0]        app_wr_en_n;
wire [SDR_BW-1:0]        a2x_wren_n;
//wire [31:0] app_rd_data;
wire [SDR_DW-1:0]        x2a_rddt;
wire   r2x_idle;
wire   r2b_req;
wire   r2b_start;
wire   r2b_last;
wire   r2b_wrap;
wire   r2b_write;
wire   b2r_ack;
wire   b2r_arb_ok;
wire   b2x_idle;
wire   b2x_req;
wire   b2x_start;
wire   b2x_last;
wire   b2x_wrap;
wire   x2b_ack;
wire   b2x_tras_ok;
wire   x2b_refresh;
wire   x2b_act_ok;
wire   x2b_rdok;
wire   x2b_wrok;
wire   x2a_rdstart;
wire   x2a_wrstart;
wire   x2a_rdlast;
wire   x2a_wrlast;
wire   x2a_wrnext;
wire   x2a_rdok;
   wire [3:0]           sdr_cmd;
   assign sdr_cmd = {sdr_cs_n, sdr_ras_n, sdr_cas_n, sdr_we_n}; 
assign sdr_den_n = sdr_den_n_int ; 
assign sdr_dout  = sdr_dout_int ;
// To meet the timing at read path, read data is registered w.r.t pad_sdram_clock and register back to sdram_clk
// assumption, pad_sdram_clk is synhronous and delayed clock of sdram_clk.
// register w.r.t pad sdram clk
reg [SDR_DW-1:0] pad_sdr_din1;
reg [SDR_DW-1:0] pad_sdr_din2;
always@(posedge pad_clk) begin
   pad_sdr_din1 <= pad_sdr_din;
end
always@(posedge clk) begin
   pad_sdr_din2 <= pad_sdr_din1;
end
   /****************************************************************************/
   // Instantiate sdr_req_gen
   // This module takes requests from the app, chops them to burst booundaries
   // if wrap=0, decodes the bank and passe the request to bank_ctl
sdrc_req_gen #(.SDR_DW(SDR_DW) , .SDR_BW(SDR_BW)) u_req_gen (
          .clk                (clk          ),
          .reset_n            (reset_n            ),
	  .cfg_colbits        (cfg_colbits        ),
          .sdr_width          (sdr_width          ),
	/* Req to xfr_ctl */
          .r2x_idle           (r2x_idle           ),
	/* Request from app */
          .req                (app_req            ),
          .req_id             (4'b0               ),
          .req_addr           (app_req_addr       ),
          .req_len            (app_req_len        ),
          .req_wrap           (app_req_wrap       ),
          .req_wr_n           (app_req_wr_n       ),
          .req_ack            (app_req_ack        ),
       /* Req to bank_ctl */
          .r2b_req            (r2b_req            ),
          .r2b_req_id         (r2b_req_id         ),
          .r2b_start          (r2b_start          ),
          .r2b_last           (r2b_last           ),
          .r2b_wrap           (r2b_wrap           ),
          .r2b_ba             (r2b_ba             ),
          .r2b_raddr          (r2b_raddr          ),
          .r2b_caddr          (r2b_caddr          ),
          .r2b_len            (r2b_len            ),
          .r2b_write          (r2b_write          ),
          .b2r_ack            (b2r_ack            ),
          .b2r_arb_ok         (b2r_arb_ok         )
     );
   /****************************************************************************/
   // Instantiate sdr_bank_ctl
   // This module takes requests from sdr_req_gen, checks for page hit/miss and
   // issues precharge/activate commands and then passes the request to
   // sdr_xfr_ctl. 
sdrc_bank_ctl #(.SDR_DW(SDR_DW) ,  .SDR_BW(SDR_BW)) u_bank_ctl (
          .clk                (clk          ),
          .reset_n            (reset_n            ),
          .a2b_req_depth      (cfg_req_depth      ),
      /* Req from req_gen */
          .r2b_req            (r2b_req            ),
          .r2b_req_id         (r2b_req_id         ),
          .r2b_start          (r2b_start          ),
          .r2b_last           (r2b_last           ),
          .r2b_wrap           (r2b_wrap           ),
          .r2b_ba             (r2b_ba             ),
          .r2b_raddr          (r2b_raddr          ),
          .r2b_caddr          (r2b_caddr          ),
          .r2b_len            (r2b_len            ),
          .r2b_write          (r2b_write          ),
          .b2r_arb_ok         (b2r_arb_ok         ),
          .b2r_ack            (b2r_ack            ),
      /* Transfer request to xfr_ctl */
          .b2x_idle           (b2x_idle           ),
          .b2x_req            (b2x_req            ),
          .b2x_start          (b2x_start          ),
          .b2x_last           (b2x_last           ),
          .b2x_wrap           (b2x_wrap           ),
          .b2x_id             (b2x_id             ),
          .b2x_ba             (b2x_ba             ),
          .b2x_addr           (b2x_addr           ),
          .b2x_len            (b2x_len            ),
          .b2x_cmd            (b2x_cmd            ),
          .x2b_ack            (x2b_ack            ),
      /* Status from xfr_ctl */
          .b2x_tras_ok        (b2x_tras_ok        ),
          .x2b_refresh        (x2b_refresh        ),
          .x2b_pre_ok         (x2b_pre_ok         ),
          .x2b_act_ok         (x2b_act_ok         ),
          .x2b_rdok           (x2b_rdok           ),
          .x2b_wrok           (x2b_wrok           ),
      /* for generate cuurent xfr address msb */
          .sdr_req_norm_dma_last(app_req_dma_last),
          .xfr_bank_sel       (xfr_bank_sel       ),
       /* SDRAM Timing */
          .tras_delay         (cfg_sdr_tras_d     ),
          .trp_delay          (cfg_sdr_trp_d      ),
          .trcd_delay         (cfg_sdr_trcd_d     )
      );
   /****************************************************************************/
   // Instantiate sdr_xfr_ctl
   // This module takes requests from sdr_bank_ctl, runs the transfer and
   // controls data flow to/from the app. At the end of the transfer it issues a
   // burst terminate if not at the end of a burst and another command to this
   // bank is not available.
sdrc_xfr_ctl 
#(.SDR_DW              ( SDR_DW),  
  .SDR_BW              ( SDR_BW),
  .SDR_RFSH_TIMER_W    ( SDR_RFSH_TIMER_W),
  .SDR_RFSH_ROW_CNT_W  ( SDR_RFSH_ROW_CNT_W)
) u_xfr_ctl (
          .clk                (clk          ),
          .reset_n            (reset_n            ),
      /* Transfer request from bank_ctl */
          .r2x_idle           (r2x_idle           ),
          .b2x_idle           (b2x_idle           ),
          .b2x_req            (b2x_req            ),
          .b2x_start          (b2x_start          ),
          .b2x_last           (b2x_last           ),
          .b2x_wrap           (b2x_wrap           ),
          .b2x_id             (b2x_id             ),
          .b2x_ba             (b2x_ba             ),
          .b2x_addr           (b2x_addr           ),
          .b2x_len            (b2x_len            ),
          .b2x_cmd            (b2x_cmd            ),
          .x2b_ack            (x2b_ack            ),
       /* Status to bank_ctl, req_gen */
          .b2x_tras_ok        (b2x_tras_ok        ),
          .x2b_refresh        (x2b_refresh        ),
          .x2b_pre_ok         (x2b_pre_ok         ),
          .x2b_act_ok         (x2b_act_ok         ),
          .x2b_rdok           (x2b_rdok           ),
          .x2b_wrok           (x2b_wrok           ),
       /* SDRAM I/O */
          .sdr_cs_n           (sdr_cs_n           ),
          .sdr_cke            (sdr_cke            ),
          .sdr_ras_n          (sdr_ras_n          ),
          .sdr_cas_n          (sdr_cas_n          ),
          .sdr_we_n           (sdr_we_n           ),
          .sdr_dqm            (sdr_dqm            ),
          .sdr_ba             (sdr_ba             ),
          .sdr_addr           (sdr_addr           ),
          .sdr_din            (pad_sdr_din2       ),
          .sdr_dout           (sdr_dout_int       ),
          .sdr_den_n          (sdr_den_n_int      ),
      /* Data Flow to the app */
          .x2a_rdstart        (x2a_rdstart        ),
          .x2a_wrstart        (x2a_wrstart        ),
          .x2a_id             (xfr_id             ),
          .x2a_rdlast         (x2a_rdlast         ),
          .x2a_wrlast         (x2a_wrlast         ),
          .a2x_wrdt           (a2x_wrdt           ),
          .a2x_wren_n         (a2x_wren_n         ),
          .x2a_wrnext         (x2a_wrnext         ),
          .x2a_rddt           (x2a_rddt           ),
          .x2a_rdok           (x2a_rdok           ),
          .sdr_init_done      (sdr_init_done      ),
      /* SDRAM Parameters */
          .sdram_enable       (cfg_sdr_en         ),
          .sdram_mode_reg     (cfg_sdr_mode_reg   ),
      /* current xfr bank */
          .xfr_bank_sel       (xfr_bank_sel       ),
      /* SDRAM Timing */
          .cas_latency        (cfg_sdr_cas        ),
          .trp_delay          (cfg_sdr_trp_d      ),
          .trcar_delay        (cfg_sdr_trcar_d    ),
          .twr_delay          (cfg_sdr_twr_d      ),
          .rfsh_time          (cfg_sdr_rfsh       ),
          .rfsh_rmax          (cfg_sdr_rfmax      )
    );
   /****************************************************************************/
   // Instantiate sdr_bs_convert
   //    This model handle the bus with transaltion from application layer to
   //       8/16/32 SDRAM Memory format
   //     During Write Phase, this block split the data as per SDRAM Width
   //     During Read Phase, This block does the re-packing based on SDRAM
   //     Width
   //---------------------------------------------------------------------------
sdrc_bs_convert #(.SDR_DW(SDR_DW) ,  .SDR_BW(SDR_BW)) u_bs_convert (
          .clk                (clk          ),
          .reset_n            (reset_n            ),
          .sdr_width          (sdr_width          ),
   /* Control Signal from xfr ctrl */
          // Read Interface Inputs
          .x2a_rdstart        (x2a_rdstart        ),
          .x2a_rdlast         (x2a_rdlast         ),
          .x2a_rdok           (x2a_rdok           ),
	  // Read Interface outputs
          .x2a_rddt           (x2a_rddt           ),
          // Write Interface, Inputs
          .x2a_wrstart        (x2a_wrstart        ),
          .x2a_wrlast         (x2a_wrlast         ),
          .x2a_wrnext         (x2a_wrnext         ),
          // Write Interface, Outputs
          .a2x_wrdt           (a2x_wrdt           ),
          .a2x_wren_n         (a2x_wren_n         ),
   /* Control Signal from sdrc_bank_ctl  */
   /*  Control Signal from/to to application i/f  */
          .app_wr_data        (app_wr_data        ),
          .app_wr_en_n        (app_wr_en_n        ),
          .app_wr_next        (app_wr_next_req    ),
	  .app_last_wr        (app_last_wr        ),
          .app_rd_data        (app_rd_data        ),
          .app_rd_valid       (app_rd_valid       ),
	  .app_last_rd        (app_last_rd        )
       );   
endmodule // sdrc_core
/*********************************************************************
  SDRAM Controller Bank Controller
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
  Description: 
    This module takes requests from sdrc_req_gen, checks for page hit/miss and
    issues precharge/activate commands and then passes the request to sdrc_xfr_ctl. 
  To Do:                                                      
    nothing                                                   
  Author(s):                                                  
      - Dinesh Annayya, dinesha@opencores.org                 
  Version  :  1.0  - 8th Jan 2012
 Copyright (C) 2000 Authors and OPENCORES.ORG                
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
*******************************************************************/
module sdrc_bank_ctl (clk,
		     reset_n,
		     a2b_req_depth,  // Number of requests we can buffer
		     /* Req from req_gen */
		     r2b_req,	   // request
		     r2b_req_id,   // ID
		     r2b_start,	   // First chunk of burst
		     r2b_last,	   // Last chunk of burst
		     r2b_wrap,
		     r2b_ba,	   // bank address
		     r2b_raddr,	   // row address
		     r2b_caddr,	   // col address
		     r2b_len,	   // length
		     r2b_write,	   // write request
		     b2r_arb_ok,   // OK to arbitrate for next xfr
		     b2r_ack,
		     /* Transfer request to xfr_ctl */
		     b2x_idle,	   // All banks are idle
		     b2x_req,	   // Request to xfr_ctl
		     b2x_start,	   // first chunk of transfer
		     b2x_last,	   // last chunk of transfer
		     b2x_wrap,
		     b2x_id,	   // Transfer ID
		     b2x_ba,	   // bank address
		     b2x_addr,	   // row/col address
		     b2x_len,	   // transfer length
		     b2x_cmd,	   // transfer command
		     x2b_ack,	   // command accepted
		     /* Status to/from xfr_ctl */
		     b2x_tras_ok,  // TRAS OK for all banks
		     x2b_refresh,  // We did a refresh
		     x2b_pre_ok,   // OK to do a precharge (per bank)
		     x2b_act_ok,   // OK to do an activate
		     x2b_rdok,	   // OK to do a read
		     x2b_wrok,	   // OK to do a write
		     /* xfr msb address */
		     xfr_bank_sel,
                     sdr_req_norm_dma_last,
		     /* SDRAM Timing */
		     tras_delay,   // Active to precharge delay
		     trp_delay,	   // Precharge to active delay
		     trcd_delay);  // Active to R/W delay
parameter  SDR_DW   = 16;  // SDR Data Width 
parameter  SDR_BW   = 2;   // SDR Byte Width
   input                        clk, reset_n;
   input [1:0] 			a2b_req_depth;
   /* Req from bank_ctl */
   input 			r2b_req, r2b_start, r2b_last,
				r2b_write, r2b_wrap;
   input [4-1:0] 	r2b_req_id;
   input [1:0] 			r2b_ba;
   input [11:0] 		r2b_raddr;
   input [11:0] 		r2b_caddr;
   input [6-1:0] 	        r2b_len;
   output 			b2r_arb_ok, b2r_ack;
   input                        sdr_req_norm_dma_last;
   /* Req to xfr_ctl */
   output 			b2x_idle, b2x_req, b2x_start, b2x_last,
				b2x_tras_ok, b2x_wrap;
   output [4-1:0] 	b2x_id;
   output [1:0] 		b2x_ba;
   output [11:0] 		b2x_addr;
   output [6-1:0] 	b2x_len;
   output [1:0] 		b2x_cmd;
   input 			x2b_ack;
   /* Status from xfr_ctl */
   input [3:0] 			x2b_pre_ok;
   input 			x2b_refresh, x2b_act_ok, x2b_rdok,
				x2b_wrok;
   input [3:0] 			tras_delay, trp_delay, trcd_delay;
   input [1:0] xfr_bank_sel;
   /****************************************************************************/
   // Internal Nets
   wire [3:0] 			r2i_req, i2r_ack, i2x_req, 
				i2x_start, i2x_last, i2x_wrap, tras_ok;
   wire [11:0] 			i2x_addr0, i2x_addr1, i2x_addr2, i2x_addr3;
   wire [6-1:0] 	i2x_len0, i2x_len1, i2x_len2, i2x_len3;
   wire [1:0] 			i2x_cmd0, i2x_cmd1, i2x_cmd2, i2x_cmd3;
   wire [4-1:0] 	i2x_id0, i2x_id1, i2x_id2, i2x_id3;
   reg 				b2x_req;
   wire 			b2x_idle, b2x_start, b2x_last, b2x_wrap;
   wire [4-1:0] 	b2x_id;
   wire [11:0] 			b2x_addr;
   wire [6-1:0] 	b2x_len;
   wire [1:0] 			b2x_cmd;
   wire [3:0] 			x2i_ack;
   reg [1:0] 			b2x_ba;
   reg [4-1:0] 	curr_id;
   wire [1:0] 			xfr_ba;
   wire  			xfr_ba_last;
   wire [3:0] 			xfr_ok;
   // This 8 bit register stores the bank addresses for upto 4 requests.
   reg [7:0] 			rank_ba;
   reg [3:0] 			rank_ba_last;
   // This 3 bit counter counts the number of requests we have
   // buffered so far, legal values are 0, 1, 2, 3, or 4.
   reg [2:0] 			rank_cnt;
   wire [3:0] 			rank_req, rank_wr_sel;
   wire 			rank_fifo_wr, rank_fifo_rd;
   wire 			rank_fifo_full, rank_fifo_mt;
   wire [11:0] bank0_row, bank1_row, bank2_row, bank3_row;
   assign  b2x_tras_ok        = &tras_ok;
   // Distribute the request from req_gen
   assign r2i_req[0] = (r2b_ba == 2'b00) ? r2b_req & ~rank_fifo_full : 1'b0;
   assign r2i_req[1] = (r2b_ba == 2'b01) ? r2b_req & ~rank_fifo_full : 1'b0;
   assign r2i_req[2] = (r2b_ba == 2'b10) ? r2b_req & ~rank_fifo_full : 1'b0;
   assign r2i_req[3] = (r2b_ba == 2'b11) ? r2b_req & ~rank_fifo_full : 1'b0;
   /******************
   Modified the Better FPGA Timing Purpose
   assign b2r_ack = (r2b_ba == 2'b00) ? i2r_ack[0] :
		    (r2b_ba == 2'b01) ? i2r_ack[1] :
		    (r2b_ba == 2'b10) ? i2r_ack[2] :
		    (r2b_ba == 2'b11) ? i2r_ack[3] : 1'b0;
   ********************/
   // Assumption: Only one Ack Will be asserted at a time.
   assign b2r_ack  =|i2r_ack; 
   assign b2r_arb_ok = ~rank_fifo_full;
   // Put the requests from the 4 bank_fsms into a 4 deep shift
   // register file. The earliest request is prioritized over the
   // later requests. Also the number of requests we are allowed to
   // buffer is limited by a 2 bit external input
   // Mux the req/cmd to xfr_ctl. Allow RD/WR commands from the request in
   // rank0, allow only PR/ACT commands from the requests in other ranks
   // If the rank_fifo is empty, send the request from the bank addressed by
   // r2b_ba 
   // In FPGA Mode, to improve the timing, also send the rank_ba
   assign xfr_ba = (1'b0 == 1'b0) ? rank_ba[1:0]:
	           ((rank_fifo_mt) ? r2b_ba : rank_ba[1:0]);
   assign xfr_ba_last = (1'b0 == 1'b0) ? rank_ba_last[0]:
	                ((rank_fifo_mt) ? sdr_req_norm_dma_last : rank_ba_last[0]);
   assign rank_req[0] = i2x_req[xfr_ba];     // each rank generates requests
   assign rank_req[1] = (rank_cnt < 3'h2) ? 1'b0 :
			(rank_ba[3:2] == 2'b00) ? i2x_req[0] & ~i2x_cmd0[1] :
			(rank_ba[3:2] == 2'b01) ? i2x_req[1] & ~i2x_cmd1[1] :
			(rank_ba[3:2] == 2'b10) ? i2x_req[2] & ~i2x_cmd2[1] : 
			i2x_req[3] & ~i2x_cmd3[1];
   assign rank_req[2] = (rank_cnt < 3'h3) ? 1'b0 :
			(rank_ba[5:4] == 2'b00) ? i2x_req[0] & ~i2x_cmd0[1] :
			(rank_ba[5:4] == 2'b01) ? i2x_req[1] & ~i2x_cmd1[1] :
			(rank_ba[5:4] == 2'b10) ? i2x_req[2] & ~i2x_cmd2[1] : 
			i2x_req[3] & ~i2x_cmd3[1];
   assign rank_req[3] = (rank_cnt < 3'h4) ? 1'b0 :
			(rank_ba[7:6] == 2'b00) ? i2x_req[0] & ~i2x_cmd0[1] :
			(rank_ba[7:6] == 2'b01) ? i2x_req[1] & ~i2x_cmd1[1] :
			(rank_ba[7:6] == 2'b10) ? i2x_req[2] & ~i2x_cmd2[1] : 
			i2x_req[3] & ~i2x_cmd3[1];
   always @ (*) begin
      b2x_req = 1'b0;
      b2x_ba =   xfr_ba;
      if(1'b0 == 1'b1) begin // Support Multiple Rank request only on ASIC
         if (rank_req[0]) begin 
	    b2x_req = 1'b1;
	    b2x_ba = xfr_ba;
         end // if (rank_req[0])
	 else if (rank_req[1]) begin 
	   b2x_req = 1'b1;
	   b2x_ba = rank_ba[3:2];
        end // if (rank_req[1])
        else if (rank_req[2]) begin 
	  b2x_req = 1'b1;
	  b2x_ba = rank_ba[5:4];
        end // if (rank_req[2])
        else if (rank_req[3]) begin 
	  b2x_req = 1'b1;
	  b2x_ba = rank_ba[7:6];
        end // if (rank_req[3])
      end else begin // If FPGA
         if (rank_req[0]) begin 
	    b2x_req = 1'b1;
	 end
      end
  end // always @ (rank_req or rank_fifo_mt or r2b_ba or rank_ba)
   assign b2x_idle = rank_fifo_mt;
   assign b2x_start = i2x_start[b2x_ba];
   assign b2x_last = i2x_last[b2x_ba];
   assign b2x_wrap = i2x_wrap[b2x_ba];
   assign b2x_addr = (b2x_ba == 2'b11) ? i2x_addr3 :
		     (b2x_ba == 2'b10) ? i2x_addr2 :
		     (b2x_ba == 2'b01) ? i2x_addr1 : i2x_addr0;
   assign b2x_len = (b2x_ba == 2'b11) ? i2x_len3 :
		    (b2x_ba == 2'b10) ? i2x_len2 :
		    (b2x_ba == 2'b01) ? i2x_len1 : i2x_len0;
   assign b2x_cmd = (b2x_ba == 2'b11) ? i2x_cmd3 :
		    (b2x_ba == 2'b10) ? i2x_cmd2 :
		    (b2x_ba == 2'b01) ? i2x_cmd1 : i2x_cmd0;
   assign b2x_id = (b2x_ba == 2'b11) ? i2x_id3 :
		   (b2x_ba == 2'b10) ? i2x_id2 :
		   (b2x_ba == 2'b01) ? i2x_id1 : i2x_id0;
   assign x2i_ack[0] = (b2x_ba == 2'b00) ? x2b_ack : 1'b0;
   assign x2i_ack[1] = (b2x_ba == 2'b01) ? x2b_ack : 1'b0;
   assign x2i_ack[2] = (b2x_ba == 2'b10) ? x2b_ack : 1'b0;
   assign x2i_ack[3] = (b2x_ba == 2'b11) ? x2b_ack : 1'b0;
   // Rank Fifo
   // On a write write to selected rank and increment rank_cnt
   // On a read shift rank_ba right 2 bits and decrement rank_cnt
   assign rank_fifo_wr = b2r_ack;
   assign rank_fifo_rd = b2x_req & b2x_cmd[1] & x2b_ack;
   assign rank_wr_sel[0] = (rank_cnt == 3'h0) ? rank_fifo_wr : 
			   (rank_cnt == 3'h1) ? rank_fifo_wr & rank_fifo_rd : 
			   1'b0;
   assign rank_wr_sel[1] = (rank_cnt == 3'h1) ? rank_fifo_wr & ~rank_fifo_rd :
			   (rank_cnt == 3'h2) ? rank_fifo_wr & rank_fifo_rd :
			   1'b0; 
   assign rank_wr_sel[2] = (rank_cnt == 3'h2) ? rank_fifo_wr & ~rank_fifo_rd :
			   (rank_cnt == 3'h3) ? rank_fifo_wr & rank_fifo_rd :
			   1'b0; 
   assign rank_wr_sel[3] = (rank_cnt == 3'h3) ? rank_fifo_wr & ~rank_fifo_rd :
			   (rank_cnt == 3'h4) ? rank_fifo_wr & rank_fifo_rd :
			   1'b0; 
   assign rank_fifo_mt = (rank_cnt == 3'b0) ? 1'b1 : 1'b0;
   assign rank_fifo_full = (rank_cnt[2]) ? 1'b1 : 
			   (rank_cnt[1:0] == a2b_req_depth) ? 1'b1 : 1'b0; 
   // FIFO Check
   always @ (posedge clk) begin
      if (~rank_fifo_wr & rank_fifo_rd && rank_cnt == 3'h0) begin
	 $display ("%t: %m: ERROR!!! Read from empty Fifo", $time);
	 $stop;
      end // if (rank_fifo_rd && rank_cnt == 3'h0)
      if (rank_fifo_wr && ~rank_fifo_rd && rank_cnt == 3'h4) begin
	 $display ("%t: %m: ERROR!!! Write to full Fifo", $time);
	 $stop;
      end // if (rank_fifo_wr && ~rank_fifo_rd && rank_cnt == 3'h4)
   end // always @ (posedge clk)
   always @ (posedge clk)
      if (~reset_n) begin
	 rank_cnt <= 3'b0;
	 rank_ba <= 8'b0;
	 rank_ba_last <= 4'b0;
      end // if (~reset_n)
      else begin
	 rank_cnt <= (rank_fifo_wr & ~rank_fifo_rd) ? rank_cnt + 3'b1 :
		     (~rank_fifo_wr & rank_fifo_rd) ? rank_cnt - 3'b1 :
		     rank_cnt;
	 rank_ba[1:0] <= (rank_wr_sel[0]) ? r2b_ba :
			 (rank_fifo_rd) ? rank_ba[3:2] : rank_ba[1:0];
	 rank_ba[3:2] <= (rank_wr_sel[1]) ? r2b_ba :
			 (rank_fifo_rd) ? rank_ba[5:4] : rank_ba[3:2];
	 rank_ba[5:4] <= (rank_wr_sel[2]) ? r2b_ba :
			 (rank_fifo_rd) ? rank_ba[7:6] : rank_ba[5:4];
	 rank_ba[7:6] <= (rank_wr_sel[3]) ? r2b_ba :
			 (rank_fifo_rd) ? 2'b00 : rank_ba[7:6];
	 if(1'b0 == 1'b1) begin // This Logic is implemented for ASIC Only
	    // Note: Currenly top-level does not generate the
	    // sdr_req_norm_dma_last signal and can be tied zero at top-level
            rank_ba_last[0] <= (rank_wr_sel[0]) ? sdr_req_norm_dma_last :
                            (rank_fifo_rd) ?  rank_ba_last[1] : rank_ba_last[0];
            rank_ba_last[1] <= (rank_wr_sel[1]) ? sdr_req_norm_dma_last :
                               (rank_fifo_rd) ?  rank_ba_last[2] : rank_ba_last[1];
            rank_ba_last[2] <= (rank_wr_sel[2]) ? sdr_req_norm_dma_last :
                               (rank_fifo_rd) ?  rank_ba_last[3] : rank_ba_last[2];
            rank_ba_last[3] <= (rank_wr_sel[3]) ? sdr_req_norm_dma_last :
                               (rank_fifo_rd) ?  1'b0 : rank_ba_last[3];
         end
      end // else: !if(~reset_n)
   assign xfr_ok[0] = (xfr_ba == 2'b00) ? 1'b1 : 1'b0;
   assign xfr_ok[1] = (xfr_ba == 2'b01) ? 1'b1 : 1'b0;
   assign xfr_ok[2] = (xfr_ba == 2'b10) ? 1'b1 : 1'b0;
   assign xfr_ok[3] = (xfr_ba == 2'b11) ? 1'b1 : 1'b0;
   /****************************************************************************/
   // Instantiate Bank Ctl FSM 0
   sdrc_bank_fsm bank0_fsm (.clk (clk),
			   .reset_n (reset_n),
			   /* Req from req_gen */
			   .r2b_req (r2i_req[0]),
			   .r2b_req_id (r2b_req_id),
			   .r2b_start (r2b_start),
			   .r2b_last (r2b_last),
			   .r2b_wrap (r2b_wrap),
			   .r2b_raddr (r2b_raddr),
			   .r2b_caddr (r2b_caddr),
			   .r2b_len (r2b_len),
			   .r2b_write (r2b_write),
			   .b2r_ack (i2r_ack[0]),
                           .sdr_dma_last(rank_ba_last[0]),
			   /* Transfer request to xfr_ctl */
			   .b2x_req (i2x_req[0]),
			   .b2x_start (i2x_start[0]),
			   .b2x_last (i2x_last[0]),
			   .b2x_wrap (i2x_wrap[0]),
			   .b2x_id (i2x_id0),
			   .b2x_addr (i2x_addr0),
			   .b2x_len (i2x_len0),
			   .b2x_cmd (i2x_cmd0),
			   .x2b_ack (x2i_ack[0]),
			   /* Status to/from xfr_ctl */
			   .tras_ok (tras_ok[0]),
			   .xfr_ok (xfr_ok[0]),
			   .x2b_refresh (x2b_refresh),
			   .x2b_pre_ok (x2b_pre_ok[0]),
			   .x2b_act_ok (x2b_act_ok),
			   .x2b_rdok (x2b_rdok),
			   .x2b_wrok (x2b_wrok),
			   .bank_row(bank0_row),
			   /* SDRAM Timing */
			   .tras_delay (tras_delay),
			   .trp_delay (trp_delay),
			   .trcd_delay (trcd_delay));
   /****************************************************************************/
   // Instantiate Bank Ctl FSM 1
   sdrc_bank_fsm bank1_fsm (.clk (clk),
			   .reset_n (reset_n),
			   /* Req from req_gen */
			   .r2b_req (r2i_req[1]),
			   .r2b_req_id (r2b_req_id),
			   .r2b_start (r2b_start),
			   .r2b_last (r2b_last),
			   .r2b_wrap (r2b_wrap),
			   .r2b_raddr (r2b_raddr),
			   .r2b_caddr (r2b_caddr),
			   .r2b_len (r2b_len),
			   .r2b_write (r2b_write),
			   .b2r_ack (i2r_ack[1]),
                           .sdr_dma_last(rank_ba_last[1]),
			   /* Transfer request to xfr_ctl */
			   .b2x_req (i2x_req[1]),
			   .b2x_start (i2x_start[1]),
			   .b2x_last (i2x_last[1]),
			   .b2x_wrap (i2x_wrap[1]),
			   .b2x_id (i2x_id1),
			   .b2x_addr (i2x_addr1),
			   .b2x_len (i2x_len1),
			   .b2x_cmd (i2x_cmd1),
			   .x2b_ack (x2i_ack[1]),
			   /* Status to/from xfr_ctl */
			   .tras_ok (tras_ok[1]),           
			   .xfr_ok (xfr_ok[1]),
			   .x2b_refresh (x2b_refresh),
			   .x2b_pre_ok (x2b_pre_ok[1]),
			   .x2b_act_ok (x2b_act_ok),
			   .x2b_rdok (x2b_rdok),
			   .x2b_wrok (x2b_wrok),
			   .bank_row(bank1_row),
			   /* SDRAM Timing */
			   .tras_delay (tras_delay),
			   .trp_delay (trp_delay),
			   .trcd_delay (trcd_delay));
   /****************************************************************************/
   // Instantiate Bank Ctl FSM 2
   sdrc_bank_fsm bank2_fsm (.clk (clk),
			   .reset_n (reset_n),
			   /* Req from req_gen */
			   .r2b_req (r2i_req[2]),
			   .r2b_req_id (r2b_req_id),
			   .r2b_start (r2b_start),
			   .r2b_last (r2b_last),
			   .r2b_wrap (r2b_wrap),
			   .r2b_raddr (r2b_raddr),
			   .r2b_caddr (r2b_caddr),
			   .r2b_len (r2b_len),
			   .r2b_write (r2b_write),
			   .b2r_ack (i2r_ack[2]),
                           .sdr_dma_last(rank_ba_last[2]),
			   /* Transfer request to xfr_ctl */
			   .b2x_req (i2x_req[2]),
			   .b2x_start (i2x_start[2]),
			   .b2x_last (i2x_last[2]),
			   .b2x_wrap (i2x_wrap[2]),
			   .b2x_id (i2x_id2),
			   .b2x_addr (i2x_addr2),
			   .b2x_len (i2x_len2),
			   .b2x_cmd (i2x_cmd2),
			   .x2b_ack (x2i_ack[2]),
			   /* Status to/from xfr_ctl */
			   .tras_ok (tras_ok[2]),           
			   .xfr_ok (xfr_ok[2]),
			   .x2b_refresh (x2b_refresh),
			   .x2b_pre_ok (x2b_pre_ok[2]),
			   .x2b_act_ok (x2b_act_ok),
			   .x2b_rdok (x2b_rdok),
			   .x2b_wrok (x2b_wrok),
			   .bank_row(bank2_row),
			   /* SDRAM Timing */
			   .tras_delay (tras_delay),
			   .trp_delay (trp_delay),
			   .trcd_delay (trcd_delay));
   /****************************************************************************/
   // Instantiate Bank Ctl FSM 3
   sdrc_bank_fsm bank3_fsm (.clk (clk),
			   .reset_n (reset_n),
			   /* Req from req_gen */
			   .r2b_req (r2i_req[3]),
			   .r2b_req_id (r2b_req_id),
			   .r2b_start (r2b_start),
			   .r2b_last (r2b_last),
			   .r2b_wrap (r2b_wrap),
			   .r2b_raddr (r2b_raddr),
			   .r2b_caddr (r2b_caddr),
			   .r2b_len (r2b_len),
			   .r2b_write (r2b_write),
			   .b2r_ack (i2r_ack[3]),
                           .sdr_dma_last(rank_ba_last[3]),
			   /* Transfer request to xfr_ctl */
			   .b2x_req (i2x_req[3]),
			   .b2x_start (i2x_start[3]),
			   .b2x_last (i2x_last[3]),
			   .b2x_wrap (i2x_wrap[3]),
			   .b2x_id (i2x_id3),
			   .b2x_addr (i2x_addr3),
			   .b2x_len (i2x_len3),
			   .b2x_cmd (i2x_cmd3),
			   .x2b_ack (x2i_ack[3]),
			   /* Status to/from xfr_ctl */
			   .tras_ok (tras_ok[3]),           
			   .xfr_ok (xfr_ok[3]),
			   .x2b_refresh (x2b_refresh),
			   .x2b_pre_ok (x2b_pre_ok[3]),
			   .x2b_act_ok (x2b_act_ok),
			   .x2b_rdok (x2b_rdok),
			   .x2b_wrok (x2b_wrok),
			   .bank_row(bank3_row),
			   /* SDRAM Timing */
			   .tras_delay (tras_delay),
			   .trp_delay (trp_delay),
			   .trcd_delay (trcd_delay));
/* address for current xfr, debug only */
wire [11:0] cur_row = (xfr_bank_sel==3) ? bank3_row:
			(xfr_bank_sel==2) ? bank2_row: 
			(xfr_bank_sel==1) ? bank1_row: bank0_row; 
endmodule // sdr_bank_ctl
/*********************************************************************
  SDRAM Controller Bank Controller
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
  Description: 
    This module takes requests from sdrc_req_gen, checks for page hit/miss and
    issues precharge/activate commands and then passes the request to sdrc_xfr_ctl. 
  To Do:                                                      
    nothing                                                   
  Author(s):                                                  
      - Dinesh Annayya, dinesha@opencores.org                 
  Version  :  1.0  - 8th Jan 2012
 Copyright (C) 2000 Authors and OPENCORES.ORG                
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
*******************************************************************/
module sdrc_bank_fsm (clk,
		     reset_n,
		     /* Req from req_gen */
		     r2b_req,	   // request
		     r2b_req_id,   // ID
		     r2b_start,	   // First chunk of burst
		     r2b_last,	   // Last chunk of burst
		     r2b_wrap,
		     r2b_raddr,	   // row address
		     r2b_caddr,	   // col address
		     r2b_len,	   // length
		     r2b_write,	   // write request
		     b2r_ack,
                     sdr_dma_last,
		     /* Transfer request to xfr_ctl */
		     b2x_req,	   // Request to xfr_ctl
		     b2x_start,	   // first chunk of transfer
		     b2x_last,	   // last chunk of transfer
		     b2x_wrap,
		     b2x_id,	   // Transfer ID
		     b2x_addr,	   // row/col address
		     b2x_len,	   // transfer length
		     b2x_cmd,	   // transfer command
		     x2b_ack,	   // command accepted
		     /* Status to/from xfr_ctl */
		     tras_ok,      // TRAS OK for this bank
		     xfr_ok,
		     x2b_refresh,  // We did a refresh
		     x2b_pre_ok,   // OK to do a precharge (per bank)
		     x2b_act_ok,   // OK to do an activate
		     x2b_rdok,	   // OK to do a read
		     x2b_wrok,	   // OK to do a write
		     /* current xfr row address of the bank */
		     bank_row,
		     /* SDRAM Timing */
		     tras_delay,   // Active to precharge delay
		     trp_delay,	   // Precharge to active delay
		     trcd_delay);  // Active to R/W delay
parameter  SDR_DW   = 16;  // SDR Data Width 
parameter  SDR_BW   = 2;   // SDR Byte Width
   input                        clk, reset_n;
   /* Req from bank_ctl */
   input 			r2b_req, r2b_start, r2b_last,
				r2b_write, r2b_wrap;
   input [4-1:0] 	r2b_req_id;
   input [11:0] 		r2b_raddr;
   input [11:0] 		r2b_caddr;
   input [6-1:0] 	r2b_len;
   output 			b2r_ack;
   input                        sdr_dma_last;
   /* Req to xfr_ctl */
   output 			b2x_req, b2x_start, b2x_last,
				tras_ok, b2x_wrap;
   output [4-1:0] 	b2x_id;
   output [11:0] 		b2x_addr;
   output [6-1:0] 	b2x_len;
   output [1:0] 		b2x_cmd;
   input 			x2b_ack;
   /* Status from xfr_ctl */
   input 			x2b_refresh, x2b_act_ok, x2b_rdok,
				x2b_wrok, x2b_pre_ok, xfr_ok;
   input [3:0] 			tras_delay, trp_delay, trcd_delay;
   output [11:0] 			bank_row;
   /****************************************************************************/
   // Internal Nets
   reg [2:0] 			bank_st, next_bank_st;
   wire 			b2x_start, b2x_last;
   reg 				l_start, l_last;
   reg 				b2x_req, b2r_ack;
   wire [4-1:0] 	b2x_id;
   reg [4-1:0] 	l_id;
   reg [11:0] 			b2x_addr;
   reg [6-1:0] 	l_len;
   wire [6-1:0] 	b2x_len;
   reg [1:0] 			b2x_cmd_t;
   reg  			bank_valid;
   reg [11:0] 			bank_row;
   reg [3:0] 			tras_cntr, timer0;
   reg 				l_wrap, l_write;
   wire 			b2x_wrap;
   reg [11:0] 			l_raddr;
   reg [11:0] 			l_caddr;
   reg                          l_sdr_dma_last;
   reg                          bank_prech_page_closed;
   wire  			tras_ok_internal, tras_ok, activate_bank;
   wire 			page_hit, timer0_tc_t, ld_trp, ld_trcd;
   /*** Timing Break Logic Added for FPGA - Start ****/
   reg	x2b_wrok_r, xfr_ok_r , x2b_rdok_r;
   reg [1:0] b2x_cmd_r,timer0_tc_r,tras_ok_r,x2b_pre_ok_r,x2b_act_ok_r;
   always @ (posedge clk)
      if (~reset_n) begin
	 x2b_wrok_r <= 1'b0;
	 xfr_ok_r   <= 1'b0;
	 x2b_rdok_r <= 1'b0;
	 b2x_cmd_r  <= 2'b0;
	 timer0_tc_r  <= 1'b0;
	 tras_ok_r    <= 1'b0;
	 x2b_pre_ok_r <= 1'b0;
	 x2b_act_ok_r <= 1'b0;
      end
      else begin
	 x2b_wrok_r <= x2b_wrok;
	 xfr_ok_r   <= xfr_ok;
	 x2b_rdok_r <= x2b_rdok;
	 b2x_cmd_r  <= b2x_cmd_t;
	 timer0_tc_r <= (ld_trp | ld_trcd) ? 1'b0 : timer0_tc_t;
	 tras_ok_r   <= tras_ok_internal;
	 x2b_pre_ok_r  <= x2b_pre_ok;
	 x2b_act_ok_r  <= x2b_act_ok;
      end
 wire  x2b_wrok_t     = (1'b0 == 1'b0) ? x2b_wrok_r : x2b_wrok;
 wire  xfr_ok_t       = (1'b0 == 1'b0) ? xfr_ok_r : xfr_ok;
 wire  x2b_rdok_t     = (1'b0 == 1'b0) ? x2b_rdok_r : x2b_rdok;
 wire [1:0] b2x_cmd   = (1'b0 == 1'b0) ? b2x_cmd_r : b2x_cmd_t;
 wire  timer0_tc      = (1'b0 == 1'b0) ? timer0_tc_r : timer0_tc_t;
 assign  tras_ok      = (1'b0 == 1'b0) ? tras_ok_r : tras_ok_internal;
 wire  x2b_pre_ok_t   = (1'b0 == 1'b0) ? x2b_pre_ok_r : x2b_pre_ok;
 wire  x2b_act_ok_t   = (1'b0 == 1'b0) ? x2b_act_ok_r : x2b_act_ok;
   /*** Timing Break Logic Added for FPGA - End****/
   always @ (posedge clk)
      if (~reset_n) begin
	 bank_valid <= 1'b0;
	 tras_cntr <= 4'b0;
	 timer0 <= 4'b0;
	 bank_st <= 3'b000;
      end // if (~reset_n)
      else begin
	 bank_valid <= (x2b_refresh || bank_prech_page_closed) ? 1'b0 :  // force the bank status to be invalid
		       (activate_bank) ? 1'b1 : bank_valid;
	 tras_cntr <= (activate_bank) ? tras_delay :
		      (~tras_ok_internal) ? tras_cntr - 4'b1 : 4'b0;
	 timer0 <= (ld_trp) ? trp_delay :
		   (ld_trcd) ? trcd_delay :
		   (timer0 != 'h0) ? timer0 - 4'b1 : timer0;
	 bank_st <= next_bank_st;
      end // else: !if(~reset_n)
   always @ (posedge clk) begin 
      bank_row <= (bank_st == 3'b010) ? b2x_addr : bank_row;
      if (~reset_n) begin
	 l_start <= 1'b0;
	 l_last <= 1'b0;
	 l_id <= 1'b0;
	 l_len <= 1'b0;
	 l_wrap <= 1'b0;
	 l_write <= 1'b0;
	 l_raddr <= 1'b0;
	 l_caddr <= 1'b0;
         l_sdr_dma_last <= 1'b0;
      end
      else begin
        if (b2r_ack) begin
  	   l_start <= r2b_start;
  	   l_last <= r2b_last;
  	   l_id <= r2b_req_id;
  	   l_len <= r2b_len;
  	   l_wrap <= r2b_wrap;
  	   l_write <= r2b_write;
  	   l_raddr <= r2b_raddr;
  	   l_caddr <= r2b_caddr;
           l_sdr_dma_last <= sdr_dma_last;
        end // if (b2r_ack)
      end
   end // always @ (posedge clk)
   assign tras_ok_internal = ~|tras_cntr;
   assign activate_bank = (b2x_cmd == 2'b01) & x2b_ack;
   assign page_hit = (r2b_raddr == bank_row) ? bank_valid : 1'b0;    // its a hit only if bank is valid
   assign timer0_tc_t = ~|timer0;
   assign ld_trp = (b2x_cmd == 2'b00) ? x2b_ack : 1'b0;
   assign ld_trcd = (b2x_cmd == 2'b01) ? x2b_ack : 1'b0;
   always @ (*) begin
       bank_prech_page_closed = 1'b0;
       b2x_req = 1'b0;
       b2x_cmd_t = 2'bx;
       b2r_ack = 1'b0;
       b2x_addr = 12'bx;
       next_bank_st = bank_st;
      case (bank_st)
	3'b000 : begin
		if(1'b0 == 1'b0) begin // To break the timing, b2x request are generated delayed
	             if (~r2b_req) begin
	                next_bank_st = 3'b000;
	             end // if (~r2b_req)
	             else if (page_hit) begin 
	                b2r_ack = 1'b1;
	                b2x_cmd_t = (r2b_write) ? 2'b11 : 2'b10;
	                next_bank_st = 3'b011;  
	             end // if (page_hit)
	             else begin  // page_miss
	                b2r_ack = 1'b1;
	                b2x_cmd_t = 2'b00;
	                next_bank_st = 3'b001;  // bank was precharged on l_sdr_dma_last
	             end // else: !if(page_hit)
		end else begin // ASIC
	             if (~r2b_req) begin
                        bank_prech_page_closed = 1'b0;
	                b2x_req = 1'b0;
	                b2x_cmd_t = 2'bx;
	                b2r_ack = 1'b0;
	                b2x_addr = 12'bx;
	                next_bank_st = 3'b000;
	             end // if (~r2b_req)
	             else if (page_hit) begin 
	                b2x_req = (r2b_write) ? x2b_wrok_t & xfr_ok_t : 
			                       x2b_rdok_t & xfr_ok_t;
	                b2x_cmd_t = (r2b_write) ? 2'b11 : 2'b10;
	                b2r_ack = 1'b1;
	                b2x_addr = r2b_caddr;
	                next_bank_st = (x2b_ack) ? 3'b000 : 3'b011;  // in case of hit, stay here till xfr sm acks
	             end // if (page_hit)
	             else begin  // page_miss
	                b2x_req = tras_ok & x2b_pre_ok_t;
	                b2x_cmd_t = 2'b00;
	                b2r_ack = 1'b1;
	                b2x_addr = r2b_raddr & 12'hBFF;	   // Dont want to pre all banks!
	                next_bank_st = (l_sdr_dma_last) ? 3'b001 : (x2b_ack) ? 3'b010 : 3'b001;  // bank was precharged on l_sdr_dma_last
	             end // else: !if(page_hit)
	        end
	end // case: `BANK_IDLE
	3'b001 : begin
	   b2x_req = tras_ok & x2b_pre_ok_t;
	   b2x_cmd_t = 2'b00;
	   b2r_ack = 1'b0;
	   b2x_addr = l_raddr & 12'hBFF;	   // Dont want to pre all banks!
           bank_prech_page_closed = 1'b0;
	   next_bank_st = (x2b_ack) ? 3'b010 : 3'b001;
	end // case: `BANK_PRE
	3'b010 : begin
	   b2x_req = timer0_tc & x2b_act_ok_t;
	   b2x_cmd_t = 2'b01;
	   b2r_ack = 1'b0;
	   b2x_addr = l_raddr;
           bank_prech_page_closed = 1'b0;
	   next_bank_st = (x2b_ack) ? 3'b011 : 3'b010;
	end // case: `BANK_ACT
	3'b011 : begin
	   b2x_req = (l_write) ? timer0_tc & x2b_wrok_t & xfr_ok_t :
		     timer0_tc & x2b_rdok_t & xfr_ok_t; 
	   b2x_cmd_t = (l_write) ? 2'b11 : 2'b10;
	   b2r_ack = 1'b0;
	   b2x_addr = l_caddr;
           bank_prech_page_closed = 1'b0;
	   next_bank_st = (x2b_refresh) ? 3'b010 : 
                          (x2b_ack & l_sdr_dma_last) ? 3'b100 :
			  (x2b_ack) ? 3'b000 : 3'b011;
	end // case: `BANK_XFR
        3'b100 : begin
	   b2x_req = tras_ok & x2b_pre_ok_t;
	   b2x_cmd_t = 2'b00;
	   b2r_ack = 1'b0;
	   b2x_addr = l_raddr & 12'hBFF;	   // Dont want to pre all banks!
           bank_prech_page_closed = 1'b1;
	   next_bank_st = (x2b_ack) ? 3'b000 : 3'b100;
	end // case: `BANK_DMA_LAST_PRE
      endcase // case(bank_st)
   end // always @ (bank_st or ...)
   assign b2x_start = (bank_st == 3'b000) ? r2b_start : l_start;
   assign b2x_last = (bank_st == 3'b000) ? r2b_last : l_last;
   assign b2x_id = (bank_st == 3'b000) ? r2b_req_id : l_id;
   assign b2x_len = (bank_st == 3'b000) ? r2b_len : l_len;
   assign b2x_wrap = (bank_st == 3'b000) ? r2b_wrap : l_wrap;
endmodule // sdr_bank_fsm
/*********************************************************************
  SDRAM Controller buswidth converter                                  
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
  Description: SDRAM Controller Buswidth converter
  This module does write/read data transalation between
     application data to SDRAM bus width
  To Do:                                                      
    nothing                                                   
  Author(s):                                                  
      - Dinesh Annayya, dinesha@opencores.org                 
  Version  :  0.0  - 8th Jan 2012 - Initial structure
              0.2 - 2nd Feb 2012
	         Improved the command pipe structure to accept up-to 4 command of different bank.
	      0.3 - 6th Feb 2012
	         Bug fix on read valid generation
 Copyright (C) 2000 Authors and OPENCORES.ORG                
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
*******************************************************************/
module sdrc_bs_convert (
                    clk                 ,
                    reset_n             ,
                    sdr_width           ,
        /* Control Signal from xfr ctrl */
                    x2a_rdstart         ,
                    x2a_wrstart         ,
                    x2a_rdlast          ,
                    x2a_wrlast          ,
                    x2a_rddt            ,
                    x2a_rdok            ,
                    a2x_wrdt            ,
                    a2x_wren_n          ,
                    x2a_wrnext          ,
   /*  Control Signal from/to to application i/f  */
                    app_wr_data         ,
                    app_wr_en_n         ,
                    app_wr_next         ,
                    app_last_wr         ,
                    app_rd_data         ,
                    app_rd_valid        ,
		    app_last_rd
		);
parameter  APP_AW   = 30;  // Application Address Width
parameter  APP_DW   = 32;  // Application Data Width 
parameter  APP_BW   = 4;   // Application Byte Width
parameter  SDR_DW   = 16;  // SDR Data Width 
parameter  SDR_BW   = 2;   // SDR Byte Width
input                    clk              ;
input                    reset_n          ;
input [1:0]              sdr_width        ; // 2'b00 - 32 Bit SDR, 2'b01 - 16 Bit SDR, 2'b1x - 8 Bit
/* Control Signal from xfr ctrl Read Transaction*/
input                    x2a_rdstart      ; // read start indication
input                    x2a_rdlast       ; //  read last burst access
input [SDR_DW-1:0]       x2a_rddt         ;
input                    x2a_rdok         ;
/* Control Signal from xfr ctrl Write Transaction*/
input                    x2a_wrstart      ; // writ start indication
input                    x2a_wrlast       ; // write last transfer
input                    x2a_wrnext       ;
output [SDR_DW-1:0]      a2x_wrdt         ;
output [SDR_BW-1:0]      a2x_wren_n       ;
// Application Write Transaction
input  [APP_DW-1:0]      app_wr_data      ;
input  [APP_BW-1:0]      app_wr_en_n      ;
output                   app_wr_next      ;
output                   app_last_wr      ; // Indicate last Write Transfer for a given burst size
// Application Read Transaction
output [APP_DW-1:0]      app_rd_data      ;
output                   app_rd_valid     ;
output                   app_last_rd      ; // Indicate last Read Transfer for a given burst size
//----------------------------------------------
// Local Decleration
// ----------------------------------------
reg [APP_DW-1:0]         app_rd_data      ;
reg                      app_rd_valid     ;
reg [SDR_DW-1:0]         a2x_wrdt         ;
reg [SDR_BW-1:0]         a2x_wren_n       ;
reg                      app_wr_next      ;
reg [23:0]               saved_rd_data    ;
reg [1:0]                rd_xfr_count     ;
reg [1:0]                wr_xfr_count     ;
assign  app_last_wr = x2a_wrlast;
assign  app_last_rd = x2a_rdlast;
always @(*) begin
        if(sdr_width == 2'b00) // 32 Bit SDR Mode
          begin
            a2x_wrdt             = app_wr_data;
            a2x_wren_n           = app_wr_en_n;
            app_wr_next          = x2a_wrnext;
            app_rd_data          = x2a_rddt;
            app_rd_valid         = x2a_rdok;
          end
        else if(sdr_width == 2'b01) // 16 Bit SDR Mode
        begin
           // Changed the address and length to match the 16 bit SDR Mode
            app_wr_next          = (x2a_wrnext & wr_xfr_count[0]);
            app_rd_valid         = (x2a_rdok & rd_xfr_count[0]);
            if(wr_xfr_count[0] == 1'b1)
              begin
                a2x_wren_n      = app_wr_en_n[3:2];
                a2x_wrdt        = app_wr_data[31:16];
              end
            else
              begin
                a2x_wren_n      = app_wr_en_n[1:0];
                a2x_wrdt        = app_wr_data[15:0];
              end
            app_rd_data = {x2a_rddt,saved_rd_data[15:0]};
        end else  // 8 Bit SDR Mode
        begin
           // Changed the address and length to match the 16 bit SDR Mode
            app_wr_next         = (x2a_wrnext & (wr_xfr_count[1:0]== 2'b11));
            app_rd_valid        = (x2a_rdok &   (rd_xfr_count[1:0]== 2'b11));
            if(wr_xfr_count[1:0] == 2'b11)
            begin
                a2x_wren_n      = app_wr_en_n[3];
                a2x_wrdt        = app_wr_data[31:24];
            end
            else if(wr_xfr_count[1:0] == 2'b10)
            begin
                a2x_wren_n      = app_wr_en_n[2];
                a2x_wrdt        = app_wr_data[23:16];
            end
            else if(wr_xfr_count[1:0] == 2'b01)
            begin
                a2x_wren_n      = app_wr_en_n[1];
                a2x_wrdt        = app_wr_data[15:8];
            end
            else begin
                a2x_wren_n      = app_wr_en_n[0];
                a2x_wrdt        = app_wr_data[7:0];
            end
            app_rd_data         = {x2a_rddt,saved_rd_data[23:0]};
          end
     end
always @(posedge clk)
  begin
    if(!reset_n)
      begin
        rd_xfr_count    <= 8'b0;
        wr_xfr_count    <= 8'b0;
	saved_rd_data   <= 24'h0;
      end
    else begin
	// During Write Phase
        if(x2a_wrlast) begin
           wr_xfr_count    <= 0;
        end
        else if(x2a_wrnext) begin
           wr_xfr_count <= wr_xfr_count + 1'b1;
        end
	// During Read Phase
        if(x2a_rdlast) begin
           rd_xfr_count    <= 0;
        end
        else if(x2a_rdok) begin
           rd_xfr_count   <= rd_xfr_count + 1'b1;
	end
	// Save Previous Data
        if(x2a_rdok) begin
	   if(sdr_width == 2'b01) // 16 Bit SDR Mode
	      saved_rd_data[15:0]  <= x2a_rddt;
            else begin// 8 bit SDR Mode - 
	       if(rd_xfr_count[1:0] == 2'b00)      saved_rd_data[7:0]   <= x2a_rddt[7:0];
	       else if(rd_xfr_count[1:0] == 2'b01) saved_rd_data[15:8]  <= x2a_rddt[7:0];
	       else if(rd_xfr_count[1:0] == 2'b10) saved_rd_data[23:16] <= x2a_rddt[7:0];
	    end
        end
    end
end
endmodule // sdr_bs_convert
/*********************************************************************
  SDRAM Controller Request Generation                                  
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
  Description: SDRAM Controller Reguest Generation
  Address Generation Based on cfg_colbits
     cfg_colbits= 2'b00
            Address[7:0]    - Column Address
            Address[9:8]    - Bank Address
            Address[21:10]  - Row Address
     cfg_colbits= 2'b01
            Address[8:0]    - Column Address
            Address[10:9]   - Bank Address
            Address[22:11]  - Row Address
     cfg_colbits= 2'b10
            Address[9:0]    - Column Address
            Address[11:10]   - Bank Address
            Address[23:12]  - Row Address
     cfg_colbits= 2'b11
            Address[10:0]    - Column Address
            Address[12:11]   - Bank Address
            Address[24:13]  - Row Address
  The SDRAMs are operated in 4 beat burst mode.
  If Wrap = 0; 
      If the current burst cross the page boundary, then this block split the request 
      into two coressponding change in address and request length
  if the current burst cross the page boundar.
  This module takes requests from the memory controller, 
  chops them to page boundaries if wrap=0, 
  and passes the request to bank_ctl
  Note: With Wrap = 0, each request from Application layer will be splited into two request, 
	if the current burst cross the page boundary. 
  To Do:                                                      
    nothing                                                   
  Author(s):                                                  
      - Dinesh Annayya, dinesha@opencores.org                 
  Version  : 0.0 - 8th Jan 2012
             0.1 - 5th Feb 2012, column/row/bank address are register to improve the timing issue in FPGA synthesis
 Copyright (C) 2000 Authors and OPENCORES.ORG                
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
*******************************************************************/
module sdrc_req_gen (clk,
		    reset_n,
		    cfg_colbits,
		    sdr_width,
		    /* Request from app */
		    req,	        // Transfer Request
		    req_id,	        // ID for this transfer
		    req_addr,	        // SDRAM Address
		    req_len,	        // Burst Length (in 32 bit words)
		    req_wrap,	        // Wrap mode request (xfr_len = 4)
		    req_wr_n,	        // 0 => Write request, 1 => read req
		    req_ack,	        // Request has been accepted
		    /* Req to xfr_ctl */
		    r2x_idle,
		    /* Req to bank_ctl */
		    r2b_req,	        // request
		    r2b_req_id,	        // ID
		    r2b_start,	        // First chunk of burst
		    r2b_last,	        // Last chunk of burst
		    r2b_wrap,	        // Wrap Mode
		    r2b_ba,	        // bank address
		    r2b_raddr,	        // row address
		    r2b_caddr,	        // col address
		    r2b_len,	        // length
		    r2b_write,	        // write request
		    b2r_ack,
		    b2r_arb_ok
		    );
parameter  APP_AW   = 25;  // Application Address Width
parameter  APP_DW   = 32;  // Application Data Width 
parameter  APP_BW   = 4;   // Application Byte Width
parameter  APP_RW   = 9;   // Application Request Width
parameter  SDR_DW   = 16;  // SDR Data Width 
parameter  SDR_BW   = 2;   // SDR Byte Width
input                   clk           ;
input                   reset_n       ;
input [1:0]             cfg_colbits   ; // 2'b00 - 8 Bit column address, 2'b01 - 9 Bit, 10 - 10 bit, 11 - 11Bits
/* Request from app */
input 			req           ; // Request 
input [4-1:0] req_id      ; // Request ID
input [APP_AW-1:0] 	req_addr      ; // Request Address
input [APP_RW-1:0] 	req_len       ; // Request length
input 			req_wr_n      ; // 0 -Write, 1 - Read
input                   req_wrap      ; // 1 - Wrap the Address on page boundary
output 			req_ack       ; // Request Ack
/* Req to bank_ctl */
output 			r2x_idle      ; 
output                  r2b_req       ; // Request
output                  r2b_start     ; // First Junk of the Burst Access
output                  r2b_last      ; // Last Junk of the Burst Access
output                  r2b_write     ; // 1 - Write, 0 - Read
output                  r2b_wrap      ; // 1 - Wrap the Address at the page boundary.
output [4-1:0] 	r2b_req_id;
output [1:0] 		r2b_ba        ; // Bank Address
output [11:0] 		r2b_raddr     ; // Row Address
output [11:0] 		r2b_caddr     ; // Column Address
output [6-1:0] 	r2b_len       ; // Burst Length
input 			b2r_ack       ; // Request Ack
input                   b2r_arb_ok    ; // Bank controller fifo is not full and ready to accept the command
//
input [1:0] 	        sdr_width; // 2'b00 - 32 Bit, 2'b01 - 16 Bit, 2'b1x - 8Bit
   /****************************************************************************/
   // Internal Nets
   reg  [1:0]		req_st, next_req_st;
   reg 			r2x_idle, req_ack, r2b_req, r2b_start, 
			r2b_write, req_idle, req_ld, lcl_wrap;
   reg [4-1:0] 	r2b_req_id;
   reg [6-1:0] 	lcl_req_len;
   wire 		r2b_last, page_ovflw;
   reg page_ovflw_r;
   wire [6-1:0] 	r2b_len, next_req_len;
   wire [12:0] 	        max_r2b_len;
   reg  [12:0] 	        max_r2b_len_r;
   reg [1:0] 		r2b_ba;
   reg [11:0] 		r2b_raddr;
   reg [11:0] 		r2b_caddr;
   reg [APP_AW-1:0] 	curr_sdr_addr ;
   wire [APP_AW-1:0] 	next_sdr_addr ;
//--------------------------------------------------------------------
// Generate the internal Adress and Burst length Based on sdram width
//--------------------------------------------------------------------
reg [APP_AW:0]           req_addr_int;
reg [APP_RW-1:0]         req_len_int;
always @(*) begin
   if(sdr_width == 2'b00) begin // 32 Bit SDR Mode
      req_addr_int     = {1'b0,req_addr};
      req_len_int      = req_len;
   end else if(sdr_width == 2'b01) begin // 16 Bit SDR Mode
      // Changed the address and length to match the 16 bit SDR Mode
      req_addr_int     = {req_addr,1'b0};
      req_len_int      = {req_len,1'b0};
   end else  begin // 8 Bit SDR Mode
      // Changed the address and length to match the 16 bit SDR Mode
      req_addr_int    = {req_addr,2'b0};
      req_len_int     = {req_len,2'b0};
   end
end
   //
   // Identify the page over flow.
   // Find the Maximum Burst length allowed from the selected column
   // address, If the requested burst length is more than the allowed Maximum
   // burst length, then we need to handle the bank cross over case and we
   // need to split the reuest.
   //
   assign max_r2b_len = (cfg_colbits == 2'b00) ? (12'h100 - {4'b0, req_addr_int[7:0]}) :
	                (cfg_colbits == 2'b01) ? (12'h200 - {3'b0, req_addr_int[8:0]}) :
			(cfg_colbits == 2'b10) ? (12'h400 - {2'b0, req_addr_int[9:0]}) : (12'h800 - {1'b0, req_addr_int[10:0]});
     // If the wrap = 0 and current application burst length is crossing the page boundary, 
     // then request will be split into two with corresponding change in request address and request length.
     //
     // If the wrap = 0 and current burst length is not crossing the page boundary, 
     // then request from application layer will be transparently passed on the bank control block.
     //
     // if the wrap = 1, then this block will not modify the request address and length. 
     // The wrapping functionality will be handle by the bank control module and 
     // column address will rewind back as follows XX -> FF ? 00 ? 1
     //
     // Note: With Wrap = 0, each request from Application layer will be spilited into two request, 
     //	if the current burst cross the page boundary. 
   assign page_ovflw = ({1'b0, req_len_int} > max_r2b_len) ? ~r2b_wrap : 1'b0;
   assign r2b_len = r2b_start ? ((page_ovflw_r) ? max_r2b_len_r : lcl_req_len) :
                      lcl_req_len;
   assign next_req_len = lcl_req_len - r2b_len;
   assign next_sdr_addr = curr_sdr_addr + r2b_len;
   assign r2b_wrap = lcl_wrap;
   assign r2b_last = (r2b_start & !page_ovflw_r) | (req_st == 2'b10);
//
//
//
   always @ (posedge clk) begin
      page_ovflw_r   <= (req_ack) ? page_ovflw: 'h0;
      max_r2b_len_r  <= (req_ack) ? max_r2b_len: 'h0;
      r2b_start      <= (req_ack) ? 1'b1 :
		        (b2r_ack) ? 1'b0 : r2b_start;
      r2b_write      <= (req_ack) ? ~req_wr_n : r2b_write;
      r2b_req_id     <= (req_ack) ? req_id : r2b_req_id;
      lcl_wrap       <= (req_ack) ? req_wrap : lcl_wrap;
      lcl_req_len    <= (req_ack) ? req_len_int  :
		        (req_ld) ? next_req_len : lcl_req_len;
      curr_sdr_addr  <= (req_ack) ? req_addr_int :
		        (req_ld) ? next_sdr_addr : curr_sdr_addr;
   end // always @ (posedge clk)
   always @ (*) begin
      r2x_idle    = 1'b0;
      req_idle    = 1'b0;
      req_ack     = 1'b0;
      req_ld      = 1'b0;
      r2b_req     = 1'b0;
      next_req_st = 2'b00;
      case (req_st)      // synopsys full_case parallel_case
	2'b00 : begin
	   r2x_idle = ~req;
	   req_idle = 1'b1;
	   req_ack = req & b2r_arb_ok;
	   req_ld = 1'b0;
	   r2b_req = 1'b0;
	   next_req_st = (req & b2r_arb_ok) ? 2'b01 : 2'b00;
	end // case: `REQ_IDLE
	2'b01 : begin
	   r2x_idle = 1'b0;
	   req_idle = 1'b0;
	   req_ack = 1'b0;
	   req_ld = b2r_ack;
	   r2b_req = 1'b1;                       // req_gen to bank_req
	   next_req_st = (b2r_ack ) ? ((page_ovflw_r) ? 2'b10 :2'b00) : 2'b01;
	end // case: `REQ_ACTIVE
	2'b10 : begin
	   r2x_idle = 1'b0;
	   req_idle = 1'b0;
	   req_ack  = 1'b0;
	   req_ld = b2r_ack;
	   r2b_req = 1'b1;                       // req_gen to bank_req
	   next_req_st = (b2r_ack) ? 2'b00 : 2'b10;
	end // case: `REQ_ACTIVE
      endcase // case(req_st)
   end // always @ (req_st or ....)
   always @ (posedge clk)
      if (~reset_n) begin
	 req_st <= 2'b00;
      end // if (~reset_n)
      else begin
	 req_st <= next_req_st;
      end // else: !if(~reset_n)
//
// addrs bits for the bank, row and column
//
// Register row/column/bank to improve fpga timing issue
wire [APP_AW-1:0] 	map_address ;
assign      map_address  = (req_ack) ? req_addr_int :
		           (req_ld)  ? next_sdr_addr : curr_sdr_addr;
always @ (posedge clk) begin
// Bank Bits are always - 2 Bits
    r2b_ba <= (cfg_colbits == 2'b00) ? {map_address[9:8]}   :
	      (cfg_colbits == 2'b01) ? {map_address[10:9]}  :
	      (cfg_colbits == 2'b10) ? {map_address[11:10]} : map_address[12:11];
/********************
*  Colbits Mapping:
*           2'b00 - 8 Bit
*           2'b01 - 16 Bit
*           2'b10 - 10 Bit
*           2'b11 - 11 Bits
************************/
    r2b_caddr <= (cfg_colbits == 2'b00) ? {4'b0, map_address[7:0]} :
	         (cfg_colbits == 2'b01) ? {3'b0, map_address[8:0]} :
	         (cfg_colbits == 2'b10) ? {2'b0, map_address[9:0]} : {1'b0, map_address[10:0]};
    r2b_raddr <= (cfg_colbits == 2'b00)  ? map_address[21:10] :
	         (cfg_colbits == 2'b01)  ? map_address[22:11] :
	         (cfg_colbits == 2'b10)  ? map_address[23:12] : map_address[24:13];
end	   
endmodule // sdr_req_gen
/*********************************************************************
  SDRAM Controller Transfer control
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
  Description: SDRAM Controller Transfer control
  This module takes requests from sdrc_bank_ctl and runs the
  transfer. The input request is guaranteed to be in a bank that is
  precharged and activated. This block runs the transfer until a
  burst boundary is reached, then issues another read/write command
  to sequentially step thru memory if wrap=0, until the transfer is
  completed.
  if a read transfer finishes and the caddr is not at a burst boundary 
  a burst terminate command is issued unless another read/write or
  precharge to the same bank is pending.
  if a write transfer finishes and the caddr is not at a burst boundary 
  a burst terminate command is issued unless a read/write is pending.
   If a refresh request is made, the bank_ctl will be held off until
   the number of refreshes requested are completed.
   This block also handles SDRAM initialization.
  To Do:                                                      
    nothing                                                   
  Author(s):                                                  
      - Dinesh Annayya, dinesha@opencores.org                 
  Version  : 1.0 - 8th Jan 2012
 Copyright (C) 2000 Authors and OPENCORES.ORG                
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
*******************************************************************/
module sdrc_xfr_ctl (clk,
		    reset_n,
		    /* Transfer request from bank_ctl */
		    r2x_idle,	   // Req is idle
		    b2x_idle,      // All banks are idle
		    b2x_req,	   // Req from bank_ctl
		    b2x_start,	   // first chunk of transfer
		    b2x_last,	   // last chunk of transfer
		    b2x_id,	   // Transfer ID
		    b2x_ba,	   // bank address
		    b2x_addr,	   // row/col address
		    b2x_len,	   // transfer length
		    b2x_cmd,	   // transfer command
		    b2x_wrap,	   // Wrap mode transfer
		    x2b_ack,	   // command accepted
		    /* Status to bank_ctl, req_gen */
		    b2x_tras_ok,   // Tras for all banks expired
		    x2b_refresh,   // We did a refresh
		    x2b_pre_ok,	   // OK to do a precharge (per bank)
		    x2b_act_ok,	   // OK to do an activate
		    x2b_rdok,	   // OK to do a read
		    x2b_wrok,	   // OK to do a write
		    /* SDRAM I/O */
		    sdr_cs_n,
		    sdr_cke,
		    sdr_ras_n,
		    sdr_cas_n,
		    sdr_we_n,
		    sdr_dqm,
		    sdr_ba,
		    sdr_addr, 
		    sdr_din,
		    sdr_dout,
		    sdr_den_n,
		    /* Data Flow to the app */
		    x2a_rdstart,
		    x2a_wrstart,
		    x2a_rdlast,
		    x2a_wrlast,
		    x2a_id,
		    a2x_wrdt,
		    a2x_wren_n,
		    x2a_wrnext,
		    x2a_rddt,
		    x2a_rdok,
		    sdr_init_done,
		    /* SDRAM Parameters */
		    sdram_enable,
		    sdram_mode_reg,
		    /* output for generate row address of the transfer */
		    xfr_bank_sel,
		    /* SDRAM Timing */
		    cas_latency,
		    trp_delay,	   // Precharge to refresh delay
		    trcar_delay,   // Auto-refresh period
		    twr_delay,	   // Write recovery delay
		    rfsh_time,	   // time per row (31.25 or 15.6125 uS)
		    rfsh_rmax);	   // Number of rows to rfsh at a time (<120uS)
parameter  SDR_DW   = 16;  // SDR Data Width 
parameter  SDR_BW   = 2;   // SDR Byte Width
parameter  SDR_RFSH_TIMER_W   = 12;
parameter  SDR_RFSH_ROW_CNT_W = 3;
input            clk, reset_n; 
   /* Req from bank_ctl */
input 			b2x_req, b2x_start, b2x_last, b2x_tras_ok,
				b2x_wrap, r2x_idle, b2x_idle; 
input [4-1:0] 	b2x_id;
input [1:0] 			b2x_ba;
input [11:0] 		b2x_addr;
input [6-1:0] 	b2x_len;
input [1:0] 			b2x_cmd;
output 			x2b_ack;
/* Status to bank_ctl */
output [3:0] 		x2b_pre_ok;
output 			x2b_refresh, x2b_act_ok, x2b_rdok,
				x2b_wrok;
/* Data Flow to the app */
output 			x2a_rdstart, x2a_wrstart, x2a_rdlast, x2a_wrlast;
output [4-1:0] 	x2a_id;
input [SDR_DW-1:0] 	a2x_wrdt;
input [SDR_BW-1:0] 	a2x_wren_n;
output [SDR_DW-1:0] 	x2a_rddt;
output 			x2a_wrnext, x2a_rdok, sdr_init_done;
/* Interface to SDRAMs */
output 			sdr_cs_n, sdr_cke, sdr_ras_n, sdr_cas_n,
				sdr_we_n; 
output [SDR_BW-1:0] 	sdr_dqm;
output [1:0] 		sdr_ba;
output [11:0] 		sdr_addr;
input [SDR_DW-1:0] 	sdr_din;
output [SDR_DW-1:0] 	sdr_dout;
output [SDR_BW-1:0] 	sdr_den_n;
   output [1:0]			xfr_bank_sel;
   input 			sdram_enable;
   input [11:0] 		sdram_mode_reg;
   input [2:0] 			cas_latency;
   input [3:0] 			trp_delay, trcar_delay, twr_delay;
   input [SDR_RFSH_TIMER_W-1 : 0] rfsh_time;
   input [SDR_RFSH_ROW_CNT_W-1:0] rfsh_rmax;
   /************************************************************************/
   // Internal Nets
   reg [1:0] 			xfr_st, next_xfr_st;
   reg [11:0] 			xfr_caddr;
   wire 			last_burst;
   wire 			x2a_rdstart, x2a_wrstart, x2a_rdlast, x2a_wrlast;
   reg 				l_start, l_last, l_wrap;
   wire [4-1:0] 	x2a_id;
   reg [4-1:0] 	l_id;
   wire [1:0] 			xfr_ba;
   reg [1:0] 			l_ba;
   wire [11:0] 			xfr_addr;
   wire [6-1:0] 	xfr_len, next_xfr_len;
   reg [6-1:0] 	l_len;
   reg 				mgmt_idle, mgmt_req;
   reg [3:0] 			mgmt_cmd;
   reg [11:0] 			mgmt_addr;
   reg [1:0] 			mgmt_ba;
   reg 				sel_mgmt, sel_b2x;
   reg 				cb_pre_ok, rdok, wrok, wr_next,
				rd_next, sdr_init_done, act_cmd, d_act_cmd;
   wire [3:0] 			b2x_sdr_cmd, xfr_cmd;
   reg [3:0] 			i_xfr_cmd;
   wire 			mgmt_ack, x2b_ack, b2x_read, b2x_write, 
				b2x_prechg, d_rd_next, dt_next, xfr_end,
				rd_pipe_mt, ld_xfr, rd_last, d_rd_last, 
				wr_last, l_xfr_end, rd_start, d_rd_start,
				wr_start, page_hit, burst_bdry, xfr_wrap,
				b2x_prechg_hit;
   reg [6:0] 			l_rd_next, l_rd_start, l_rd_last;
   assign b2x_read = (b2x_cmd == 2'b10) ? 1'b1 : 1'b0;
   assign b2x_write = (b2x_cmd == 2'b11) ? 1'b1 : 1'b0;
   assign b2x_prechg = (b2x_cmd == 2'b00) ? 1'b1 : 1'b0;
   assign b2x_sdr_cmd = (b2x_cmd == 2'b00) ? 4'b0010 :
			(b2x_cmd == 2'b01) ? 4'b0011 :
			(b2x_cmd == 2'b10) ? 4'b0101 :
			(b2x_cmd == 2'b11) ? 4'b0100 : 4'b1111;
   assign page_hit = (b2x_ba == l_ba) ? 1'b1 : 1'b0;
   assign b2x_prechg_hit = b2x_prechg & page_hit;
   assign xfr_cmd = (sel_mgmt) ? mgmt_cmd :
		    (sel_b2x) ? b2x_sdr_cmd : i_xfr_cmd;
   assign xfr_addr = (sel_mgmt) ? mgmt_addr : 
		     (sel_b2x) ? b2x_addr : xfr_caddr+1;
   assign mgmt_ack = sel_mgmt;
   assign x2b_ack = sel_b2x;
   assign ld_xfr = sel_b2x & (b2x_read | b2x_write);
   assign xfr_len = (ld_xfr) ? b2x_len : l_len;
   //assign next_xfr_len = (l_xfr_end && !ld_xfr) ? l_len : xfr_len - 1;
   assign next_xfr_len = (ld_xfr) ? b2x_len : 
	                 (l_xfr_end) ? l_len:  l_len - 1;
   assign d_rd_next = (cas_latency == 3'b001) ? l_rd_next[2] :
		      (cas_latency == 3'b010) ? l_rd_next[3] :
		      (cas_latency == 3'b011) ? l_rd_next[4] :
		      (cas_latency == 3'b100) ? l_rd_next[5] :
		      l_rd_next[6];
   assign d_rd_last = (cas_latency == 3'b001) ? l_rd_last[2] :
		      (cas_latency == 3'b010) ? l_rd_last[3] :
		      (cas_latency == 3'b011) ? l_rd_last[4] :
		      (cas_latency == 3'b100) ? l_rd_last[5] :
		      l_rd_last[6];
   assign d_rd_start = (cas_latency == 3'b001) ? l_rd_start[2] :
		       (cas_latency == 3'b010) ? l_rd_start[3] :
		       (cas_latency == 3'b011) ? l_rd_start[4] :
		       (cas_latency == 3'b100) ? l_rd_start[5] :
		       l_rd_start[6];
   assign rd_pipe_mt = (cas_latency == 3'b001) ? ~|l_rd_next[1:0] :
		       (cas_latency == 3'b010) ? ~|l_rd_next[2:0] :
		       (cas_latency == 3'b011) ? ~|l_rd_next[3:0] :
		       (cas_latency == 3'b100) ? ~|l_rd_next[4:0] :
		       ~|l_rd_next[5:0];
   assign dt_next = wr_next | d_rd_next;
   assign xfr_end = ~|xfr_len;
   assign l_xfr_end = ~|(l_len-1);
   assign rd_start = ld_xfr & b2x_read & b2x_start;
   assign wr_start = ld_xfr & b2x_write & b2x_start;
   assign rd_last = rd_next & last_burst & ~|xfr_len[6-1:1];
   //assign wr_last = wr_next & last_burst & ~|xfr_len[APP_RW-1:1];
   assign wr_last = last_burst & ~|xfr_len[6-1:1];
   //assign xfr_ba = (ld_xfr) ? b2x_ba : l_ba;
   assign xfr_ba = (sel_mgmt) ? mgmt_ba : 
		   (sel_b2x) ? b2x_ba : l_ba;
   assign xfr_wrap = (ld_xfr) ? b2x_wrap : l_wrap;
//   assign burst_bdry = ~|xfr_caddr[2:0];
   wire [1:0] xfr_caddr_lsb = (xfr_caddr[1:0]+1);
   assign burst_bdry = ~|(xfr_caddr_lsb[1:0]);
   always @ (posedge clk) begin
      if (~reset_n) begin
	 xfr_caddr <= 12'b0;
	 l_start <= 1'b0;
	 l_last <= 1'b0;
	 l_wrap <= 1'b0;
	 l_id <= 0;
	 l_ba <= 0;
	 l_len <= 0;
	 l_rd_next <= 7'b0;
	 l_rd_start <= 7'b0;
	 l_rd_last <= 7'b0;
	 act_cmd <= 1'b0;
	 d_act_cmd <= 1'b0;
	 xfr_st <= 2'b00;
      end // if (~reset_n)
      else begin
	 xfr_caddr <= (ld_xfr) ? b2x_addr :
		      (rd_next | wr_next) ? xfr_caddr + 1 : xfr_caddr; 
	 l_start <= (dt_next) ? 1'b0 : 
		   (ld_xfr) ? b2x_start : l_start;
	 l_last <= (ld_xfr) ? b2x_last : l_last;
	 l_wrap <= (ld_xfr) ? b2x_wrap : l_wrap;
	 l_id <= (ld_xfr) ? b2x_id : l_id;
	 l_ba <= (ld_xfr) ? b2x_ba : l_ba;
	 l_len <= next_xfr_len;
	 l_rd_next <= {l_rd_next[5:0], rd_next};
	 l_rd_start <= {l_rd_start[5:0], rd_start};
	 l_rd_last <= {l_rd_last[5:0], rd_last};
	 act_cmd <= (xfr_cmd == 4'b0011) ? 1'b1 : 1'b0;
	 d_act_cmd <= act_cmd;
	 xfr_st <= next_xfr_st;
      end // else: !if(~reset_n)
   end // always @ (posedge clk)
   always @ (*) begin 
      case (xfr_st)
	2'b00 : begin
	   sel_mgmt = mgmt_req;
	   sel_b2x = ~mgmt_req & sdr_init_done & b2x_req;
	   i_xfr_cmd = 4'b1111;
	   rd_next = ~mgmt_req & sdr_init_done & b2x_req & b2x_read;
	   wr_next = ~mgmt_req & sdr_init_done & b2x_req & b2x_write;
	   rdok = ~mgmt_req;
	   cb_pre_ok = 1'b1;
	   wrok = ~mgmt_req;
	   next_xfr_st = (mgmt_req | ~sdr_init_done) ? 2'b00 :
			 (~b2x_req) ? 2'b00 :
			 (b2x_read) ? 2'b10 :
			 (b2x_write) ? 2'b01 : 2'b00;
	end // case: `XFR_IDLE
	2'b10 : begin
	   rd_next = ~l_xfr_end |
		     l_xfr_end & ~mgmt_req & b2x_req & b2x_read;
	   wr_next = 1'b0;
	   rdok = l_xfr_end & ~mgmt_req;
	   // Break the timing path for FPGA Based Design
	   cb_pre_ok = (1'b0 == 1'b0) ? 1'b0 : l_xfr_end;
	   wrok = 1'b0;
	   sel_mgmt = 1'b0;
	   if (l_xfr_end) begin		  // end of transfer
	      if (~l_wrap) begin
		 // Current transfer was not wrap mode, may need BT
		 // If next cmd is a R or W or PRE to same bank allow
		 // it else issue BT 
		 // This is a little pessimistic since BT is issued
		 // for non-wrap mode transfers even if the transfer
		 // ends on a burst boundary, but is felt to be of
		 // minimal performance impact.
		 i_xfr_cmd = 4'b0110;
		 sel_b2x = b2x_req & ~mgmt_req & (b2x_read | b2x_prechg_hit);
	      end // if (~l_wrap)
	      else begin
		 // Wrap mode transfer, by definition is end of burst
		 // boundary 
		 i_xfr_cmd = 4'b1111;
		 sel_b2x = b2x_req & ~mgmt_req & ~b2x_write;
	      end // else: !if(~l_wrap)
	      next_xfr_st = (sdr_init_done) ? ((b2x_req & ~mgmt_req & b2x_read) ? 2'b10 : 2'b11) : 2'b00;
	   end // if (l_xfr_end)
	   else begin
	      // Not end of transfer
	      // If current transfer was not wrap mode and we are at
	      // the start of a burst boundary issue another R cmd to
	      // step sequemtially thru memory, ELSE,
	      // issue precharge/activate commands from the bank control
	      i_xfr_cmd = (burst_bdry & ~l_wrap) ? 4'b0101 : 4'b1111;
	      sel_b2x = ~(burst_bdry & ~l_wrap) & b2x_req;
	      next_xfr_st = 2'b10;
	   end // else: !if(l_xfr_end)
	end // case: `XFR_READ
	2'b11 : begin 
	   rd_next = ~mgmt_req & b2x_req & b2x_read;
	   wr_next = rd_pipe_mt & ~mgmt_req & b2x_req & b2x_write;
	   rdok = ~mgmt_req;
	   cb_pre_ok = 1'b1;
	   wrok = rd_pipe_mt & ~mgmt_req;
	   sel_mgmt = mgmt_req;
	   sel_b2x = ~mgmt_req & b2x_req;
	   i_xfr_cmd = 4'b1111;
	   next_xfr_st = (~mgmt_req & b2x_req & b2x_read) ? 2'b10 : 
			 (~rd_pipe_mt) ? 2'b11 :
			 (~mgmt_req & b2x_req & b2x_write) ? 2'b01 : 
			 2'b00;
	end // case: `XFR_RDWT
	2'b01 : begin
	   rd_next = l_xfr_end & ~mgmt_req & b2x_req & b2x_read;
	   wr_next = ~l_xfr_end |
		     l_xfr_end & ~mgmt_req & b2x_req & b2x_write;
	   rdok = l_xfr_end & ~mgmt_req;
	   cb_pre_ok = 1'b0;
	   wrok = l_xfr_end & ~mgmt_req;
	   sel_mgmt = 1'b0;
	   if (l_xfr_end) begin		  // End of transfer
	      if (~l_wrap) begin
		 // Current transfer was not wrap mode, may need BT
		 // If next cmd is a R or W allow it else issue BT 
		 // This is a little pessimistic since BT is issued
		 // for non-wrap mode transfers even if the transfer
		 // ends on a burst boundary, but is felt to be of
		 // minimal performance impact.
		 sel_b2x = b2x_req & ~mgmt_req & (b2x_read | b2x_write);
		 i_xfr_cmd = 4'b0110;
	      end // if (~l_wrap)
	      else begin
		 // Wrap mode transfer, by definition is end of burst
		 // boundary 
		 sel_b2x = b2x_req & ~mgmt_req & ~b2x_prechg_hit;
		 i_xfr_cmd = 4'b1111;
	      end // else: !if(~l_wrap)
	      next_xfr_st = (~mgmt_req & b2x_req & b2x_read) ? 2'b10 : 
			    (~mgmt_req & b2x_req & b2x_write) ? 2'b01 : 
			    2'b00;
	   end // if (l_xfr_end)
	   else begin
	      // Not end of transfer
	      // If current transfer was not wrap mode and we are at
	      // the start of a burst boundary issue another R cmd to
	      // step sequemtially thru memory, ELSE,
	      // issue precharge/activate commands from the bank control
	      if (burst_bdry & ~l_wrap) begin
		 sel_b2x = 1'b0;
		 i_xfr_cmd = 4'b0100;
	      end // if (burst_bdry & ~l_wrap)
	      else begin
		 sel_b2x = b2x_req & ~mgmt_req;
		 i_xfr_cmd = 4'b1111;
	      end // else: !if(burst_bdry & ~l_wrap)
	      next_xfr_st = 2'b01;
	   end // else: !if(l_xfr_end)
	end // case: `XFR_WRITE
      endcase // case(xfr_st)
   end // always @ (xfr_st or ...)
   // signals to bank_ctl (x2b_refresh, x2b_act_ok, x2b_rdok, x2b_wrok,
   // x2b_pre_ok[3:0] 
   assign x2b_refresh = (xfr_cmd == 4'b0001) ? 1'b1 : 1'b0;
   assign x2b_act_ok = ~act_cmd & ~d_act_cmd;
   assign x2b_rdok = rdok;
   assign x2b_wrok = wrok;
   //assign x2b_pre_ok[0] = (l_ba == 2'b00) ? cb_pre_ok : 1'b1;
   //assign x2b_pre_ok[1] = (l_ba == 2'b01) ? cb_pre_ok : 1'b1;
   //assign x2b_pre_ok[2] = (l_ba == 2'b10) ? cb_pre_ok : 1'b1;
   //assign x2b_pre_ok[3] = (l_ba == 2'b11) ? cb_pre_ok : 1'b1;
   assign x2b_pre_ok[0] = cb_pre_ok;
   assign x2b_pre_ok[1] = cb_pre_ok;
   assign x2b_pre_ok[2] = cb_pre_ok;
   assign x2b_pre_ok[3] = cb_pre_ok;
   assign last_burst = (ld_xfr) ? b2x_last : l_last;
   /************************************************************************/
   // APP Data I/F
   wire [SDR_DW-1:0] 	x2a_rddt;
   //assign x2a_start = (ld_xfr) ? b2x_start : l_start;
   assign x2a_rdstart = d_rd_start;
   assign x2a_wrstart = wr_start;
   assign x2a_rdlast = d_rd_last;
   assign x2a_wrlast = wr_last;
   assign x2a_id = (ld_xfr) ? b2x_id : l_id;
   assign x2a_rddt = sdr_din;
   assign x2a_wrnext = wr_next;
   assign x2a_rdok = d_rd_next;
   /************************************************************************/
   // SDRAM I/F
   reg 				sdr_cs_n, sdr_cke, sdr_ras_n, sdr_cas_n,
				sdr_we_n; 
   reg [SDR_BW-1:0] 	sdr_dqm;
   reg [1:0] 			sdr_ba;
   reg [11:0] 			sdr_addr;
   reg [SDR_DW-1:0] 	sdr_dout;
   reg [SDR_BW-1:0] 	sdr_den_n;
   always @ (posedge clk)
      if (~reset_n) begin
	 sdr_cs_n <= 1'b1;
	 sdr_cke <= 1'b1;
	 sdr_ras_n <= 1'b1;
	 sdr_cas_n <= 1'b1;
	 sdr_we_n <= 1'b1;
	 sdr_dqm   <= {SDR_BW{1'b1}};
	 sdr_den_n <= {SDR_BW{1'b1}};
      end // if (~reset_n)
      else begin
	 sdr_cs_n <= xfr_cmd[3];
	 sdr_ras_n <= xfr_cmd[2];
	 sdr_cas_n <= xfr_cmd[1];
	 sdr_we_n <= xfr_cmd[0];
	 sdr_cke <= (xfr_st != 2'b00) ? 1'b1 : 
		    ~(mgmt_idle & b2x_idle & r2x_idle);
	 sdr_dqm <= (wr_next) ? a2x_wren_n : {SDR_BW{1'b0}};
         sdr_den_n <= (wr_next) ? {SDR_BW{1'b0}} : {SDR_BW{1'b1}};
      end // else: !if(~reset_n)
   always @ (posedge clk) begin 
      if (~xfr_cmd[3]) begin 
	 sdr_addr <= xfr_addr;
	 sdr_ba <= xfr_ba;
      end // if (~xfr_cmd[3])
      sdr_dout <= (wr_next) ? a2x_wrdt : sdr_dout;
   end // always @ (posedge clk)
   /************************************************************************/
   // Refresh and Initialization
   reg [2:0]       mgmt_st, next_mgmt_st;
   reg [3:0] 	   tmr0, tmr0_d;
   reg [3:0] 	   cntr1, cntr1_d;
   wire 	   tmr0_tc, cntr1_tc, rfsh_timer_tc, ref_req, precharge_ok;
   reg 		   ld_tmr0, ld_cntr1, dec_cntr1, set_sdr_init_done;
   reg [SDR_RFSH_TIMER_W-1 : 0]  rfsh_timer;
   reg [SDR_RFSH_ROW_CNT_W-1:0]  rfsh_row_cnt;
   always @ (posedge clk) 
      if (~reset_n) begin
	 mgmt_st <= 3'b000;
	 tmr0 <= 4'b0;
	 cntr1 <= 4'h7;
	 rfsh_timer <= 0;
	 rfsh_row_cnt <= 0;
	 sdr_init_done <= 1'b0;
      end // if (~reset_n)
      else begin
	 mgmt_st <= next_mgmt_st;
	 tmr0 <= (ld_tmr0) ? tmr0_d :
		  (~tmr0_tc) ? tmr0 - 1 : tmr0;
	 cntr1 <= (ld_cntr1) ? cntr1_d :
		  (dec_cntr1) ? cntr1 - 1 : cntr1;
	 sdr_init_done <= (set_sdr_init_done | sdr_init_done) & sdram_enable;
	 rfsh_timer <= (rfsh_timer_tc) ? 0 : rfsh_timer + 1;
	 rfsh_row_cnt <= (~set_sdr_init_done) ? 0 :
			 (rfsh_timer_tc) ? rfsh_row_cnt + 1 : rfsh_row_cnt;
      end // else: !if(~reset_n)
   assign tmr0_tc = ~|tmr0;
   assign cntr1_tc = ~|cntr1;
   assign rfsh_timer_tc = (rfsh_timer == rfsh_time) ? 1'b1 : 1'b0;
   assign ref_req = (rfsh_row_cnt >= rfsh_rmax) ? 1'b1 : 1'b0;
   assign precharge_ok = cb_pre_ok & b2x_tras_ok;
   assign xfr_bank_sel = l_ba;
   always @ (mgmt_st or sdram_enable or mgmt_ack or trp_delay or tmr0_tc or
	     cntr1_tc or trcar_delay or rfsh_row_cnt or ref_req or sdr_init_done
	     or precharge_ok or sdram_mode_reg) begin 
      case (mgmt_st)          // synopsys full_case parallel_case
	3'b000 : begin
	   mgmt_idle = 1'b0;
	   mgmt_req = 1'b0;
	   mgmt_cmd = 4'b1111;
	   mgmt_ba = 2'b0;
	   mgmt_addr = 12'h400;    // A10 = 1 => all banks
	   ld_tmr0 = 1'b0;
	   tmr0_d = 4'b0;
	   dec_cntr1 = 1'b0;
	   ld_cntr1 = 1'b1;
	   cntr1_d = 4'hf; // changed for sdrams with higher refresh cycles during initialization
	   set_sdr_init_done = 1'b0;
	   next_mgmt_st = (sdram_enable) ? 3'b001 : 3'b000; 
	end // case: `MGM_POWERUP
	3'b001 : begin	   // Precharge all banks
	   mgmt_idle = 1'b0;
	   mgmt_req = 1'b1;
	   mgmt_cmd = (precharge_ok) ? 4'b0010 : 4'b1111;
	   mgmt_ba = 2'b0;
	   mgmt_addr = 12'h400;	   // A10 = 1 => all banks
	   ld_tmr0 = mgmt_ack;
	   tmr0_d = trp_delay;
	   ld_cntr1 = 1'b0;
	   cntr1_d = 4'h7;
	   dec_cntr1 = 1'b0;
	   set_sdr_init_done = 1'b0;
	   next_mgmt_st = (precharge_ok & mgmt_ack) ? 3'b010 : 3'b001;
	end // case: `MGM_PRECHARGE
	3'b010 : begin	   // Wait for Trp
	   mgmt_idle = 1'b0;
	   mgmt_req = 1'b1;
	   mgmt_cmd = 4'b1111;
	   mgmt_ba = 2'b0;
	   mgmt_addr = 12'h400;	   // A10 = 1 => all banks
	   ld_tmr0 = 1'b0;
	   tmr0_d = trp_delay;
	   ld_cntr1 = 1'b0;
	   cntr1_d = 4'b0;
	   dec_cntr1 = 1'b0;
	   set_sdr_init_done = 1'b0;
	   next_mgmt_st = (tmr0_tc) ? 3'b011 : 3'b010;
	end // case: `MGM_PRECHARGE
	3'b011 : begin	   // Refresh
	   mgmt_idle = 1'b0;
	   mgmt_req = 1'b1;
	   mgmt_cmd = 4'b0001;
	   mgmt_ba = 2'b0;
	   mgmt_addr = 12'h400;	   // A10 = 1 => all banks
	   ld_tmr0 = mgmt_ack;
	   tmr0_d = trcar_delay;
	   dec_cntr1 = mgmt_ack;
	   ld_cntr1 = 1'b0;
	   cntr1_d = 4'h7;
	   set_sdr_init_done = 1'b0;
	   next_mgmt_st = (mgmt_ack) ? 3'b100 : 3'b011;
	end // case: `MGM_REFRESH
	3'b100 : begin	   // Wait for trcar
	   mgmt_idle = 1'b0;
	   mgmt_req = 1'b1;
	   mgmt_cmd = 4'b1111;
	   mgmt_ba = 2'b0;
	   mgmt_addr = 12'h400;	   // A10 = 1 => all banks
	   ld_tmr0 = 1'b0;
	   tmr0_d = trcar_delay;
	   dec_cntr1 = 1'b0;
	   ld_cntr1 = 1'b0;
	   cntr1_d = 4'h7;
	   set_sdr_init_done = 1'b0;
	   next_mgmt_st = (~tmr0_tc) ? 3'b100 : 
			  (~cntr1_tc) ? 3'b011 :
			  (sdr_init_done) ? 3'b111 : 3'b101;
	end // case: `MGM_REFWT
	3'b101 : begin	   // Program mode Register & wait for 
	   mgmt_idle = 1'b0;
	   mgmt_req = 1'b1;
	   mgmt_cmd = 4'b0000;
	   mgmt_ba = {1'b0, sdram_mode_reg[11]};
	   mgmt_addr = sdram_mode_reg;
	   ld_tmr0 = mgmt_ack;
	   tmr0_d = 4'h7;
	   dec_cntr1 = 1'b0;
	   ld_cntr1 = 1'b0;
	   cntr1_d = 4'h7;
	   set_sdr_init_done = 1'b0;
	   next_mgmt_st = (mgmt_ack) ? 3'b110 : 3'b101;
	end // case: `MGM_MODE_REG
	3'b110 : begin	   // Wait for tMRD
	   mgmt_idle = 1'b0;
	   mgmt_req = 1'b1;
	   mgmt_cmd = 4'b1111;
	   mgmt_ba = 2'bx;
	   mgmt_addr = 12'bx;
	   ld_tmr0 = 1'b0;
	   tmr0_d = 4'h7;
	   dec_cntr1 = 1'b0;
	   ld_cntr1 = 1'b0;
	   cntr1_d = 4'h7;
	   set_sdr_init_done = 1'b0;
	   next_mgmt_st = (~tmr0_tc) ? 3'b110 : 3'b111;
	end // case: `MGM_MODE_WT
	3'b111 : begin	   // Wait for ref_req
	   mgmt_idle = ~ref_req;
	   mgmt_req = 1'b0;
	   mgmt_cmd = 4'b1111;
	   mgmt_ba = 2'bx;
	   mgmt_addr = 12'bx;
	   ld_tmr0 = 1'b0;
	   tmr0_d = 4'h7;
	   dec_cntr1 = 1'b0;
	   ld_cntr1 = ref_req;
	   cntr1_d = rfsh_row_cnt;
	   set_sdr_init_done = 1'b1;
	   next_mgmt_st =  (~sdram_enable) ? 3'b000 :
                           (ref_req) ? 3'b001 : 3'b111;
	end // case: `MGM_MODE_WT
      endcase // case(mgmt_st)
   end // always @ (mgmt_st or ....)
endmodule // sdr_xfr_ctl
