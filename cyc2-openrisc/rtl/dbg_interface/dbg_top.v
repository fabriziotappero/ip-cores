//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_top.v                                                   ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC/OpenRISC Development Interface ////
////  http://www.opencores.org/cores/DebugInterface/              ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor                                             ////
////       igorm@opencores.org                                    ////
////                                                              ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000,2001 Authors                              ////
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
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.1  2006/12/21 16:46:58  vak
// Initial revision imported from
// http://www.opencores.org/cvsget.cgi/or1k/orp/orp_soc/rtl/verilog.
//
// Revision 1.1.1.1  2002/03/21 16:55:44  lampret
// First import of the "new" XESS XSV environment.
//
//
// Revision 1.20  2002/02/06 12:23:09  mohor
// LatchedJTAG_IR used when muxing TDO instead of JTAG_IR.
//
// Revision 1.19  2002/02/05 13:34:51  mohor
// Stupid bug that was entered by previous update fixed.
//
// Revision 1.18  2002/02/05 12:41:01  mohor
// trst synchronization is not needed and was removed.
//
// Revision 1.17  2002/01/25 07:58:35  mohor
// IDCODE bug fixed, chains reused to decreas size of core. Data is shifted-in
// not filled-in. Tested in hw.
//
// Revision 1.16  2001/12/20 11:17:26  mohor
// TDO and TDO Enable signal are separated into two signals.
//
// Revision 1.15  2001/12/05 13:28:21  mohor
// trst signal is synchronized to wb_clk_i.
//
// Revision 1.14  2001/11/28 09:36:15  mohor
// Register length fixed.
//
// Revision 1.13  2001/11/27 13:37:43  mohor
// CRC is returned when chain selection data is transmitted.
//
// Revision 1.12  2001/11/26 10:47:09  mohor
// Crc generation is different for read or write commands. Small synthesys fixes.
//
// Revision 1.11  2001/11/14 10:10:41  mohor
// Wishbone data latched on wb_clk_i instead of risc_clk.
//
// Revision 1.10  2001/11/12 01:11:27  mohor
// Reset signals are not combined any more.
//
// Revision 1.9  2001/10/19 11:40:01  mohor
// dbg_timescale.v changed to timescale.v This is done for the simulation of
// few different cores in a single project.
//
// Revision 1.8  2001/10/17 10:39:03  mohor
// bs_chain_o added.
//
// Revision 1.7  2001/10/16 10:09:56  mohor
// Signal names changed to lowercase.
//
//
// Revision 1.6  2001/10/15 09:55:47  mohor
// Wishbone interface added, few fixes for better performance,
// hooks for boundary scan testing added.
//
// Revision 1.5  2001/09/24 14:06:42  mohor
// Changes connected to the OpenRISC access (SPR read, SPR write).
//
// Revision 1.4  2001/09/20 10:11:25  mohor
// Working version. Few bugs fixed, comments added.
//
// Revision 1.3  2001/09/19 11:55:13  mohor
// Asynchronous set/reset not used in trace any more.
//
// Revision 1.2  2001/09/18 14:13:47  mohor
// Trace fixed. Some registers changed, trace simplified.
//
// Revision 1.1.1.1  2001/09/13 13:49:19  mohor
// Initial official release.
//
// Revision 1.3  2001/06/01 22:22:35  mohor
// This is a backup. It is not a fully working version. Not for use, yet.
//
// Revision 1.2  2001/05/18 13:10:00  mohor
// Headers changed. All additional information is now avaliable in the README.txt file.
//
// Revision 1.1.1.1  2001/05/18 06:35:02  mohor
// Initial release
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "dbg_defines.v"

// Top module
module dbg_top(
                // JTAG pins
                tms_pad_i, tck_pad_i, trst_pad_i, tdi_pad_i, tdo_pad_o, tdo_padoen_o,

                // Boundary Scan signals
                capture_dr_o, shift_dr_o, update_dr_o, extest_selected_o, bs_chain_i, bs_chain_o, 
                
                // RISC signals
                risc_clk_i, risc_addr_o, risc_data_i, risc_data_o, wp_i, 
                bp_i, opselect_o, lsstatus_i, istatus_i, risc_stall_o, reset_o, 
                
                // WISHBONE common signals
                wb_rst_i, wb_clk_i, 

                // WISHBONE master interface
                wb_adr_o, wb_dat_o, wb_dat_i, wb_cyc_o, wb_stb_o, wb_sel_o,
                wb_we_o, wb_ack_i, wb_cab_o, wb_err_i


              );

parameter Tp = 1;

// JTAG pins
input         tms_pad_i;                  // JTAG test mode select pad
input         tck_pad_i;                  // JTAG test clock pad
input         trst_pad_i;                 // JTAG test reset pad
input         tdi_pad_i;                  // JTAG test data input pad
output        tdo_pad_o;                  // JTAG test data output pad
output        tdo_padoen_o;               // Output enable for JTAG test data output pad 


// Boundary Scan signals
output capture_dr_o;
output shift_dr_o;
output update_dr_o;
output extest_selected_o;
input  bs_chain_i;
output bs_chain_o;

// RISC signals
input         risc_clk_i;                 // Master clock (RISC clock)
input  [31:0] risc_data_i;                // RISC data inputs (data that is written to the RISC registers)
input  [10:0] wp_i;                       // Watchpoint inputs
input         bp_i;                       // Breakpoint input
input  [3:0]  lsstatus_i;                 // Load/store status inputs
input  [1:0]  istatus_i;                  // Instruction status inputs
output [31:0] risc_addr_o;                // RISC address output (for adressing registers within RISC)
output [31:0] risc_data_o;                // RISC data output (data read from risc registers)
output [`OPSELECTWIDTH-1:0] opselect_o;   // Operation selection (selecting what kind of data is set to the risc_data_i)
output                      risc_stall_o; // Stalls the RISC
output                      reset_o;      // Resets the RISC


// WISHBONE common signals
input         wb_rst_i;                   // WISHBONE reset
input         wb_clk_i;                   // WISHBONE clock

// WISHBONE master interface
output [31:0] wb_adr_o;
output [31:0] wb_dat_o;
input  [31:0] wb_dat_i;
output        wb_cyc_o;
output        wb_stb_o;
output  [3:0] wb_sel_o;
output        wb_we_o;
input         wb_ack_i;
output        wb_cab_o;
input         wb_err_i;

reg           wb_cyc_o;

// TAP states
reg TestLogicReset;
reg RunTestIdle;
reg SelectDRScan;
reg CaptureDR;
reg ShiftDR;
reg Exit1DR;
reg PauseDR;
reg Exit2DR;
reg UpdateDR;

reg SelectIRScan;
reg CaptureIR;
reg ShiftIR;
reg Exit1IR;
reg PauseIR;
reg Exit2IR;
reg UpdateIR;


// Defining which instruction is selected
reg EXTESTSelected;
reg SAMPLE_PRELOADSelected;
reg IDCODESelected;
reg CHAIN_SELECTSelected;
reg INTESTSelected;
reg CLAMPSelected;
reg CLAMPZSelected;
reg HIGHZSelected;
reg DEBUGSelected;
reg BYPASSSelected;

reg [31:0]  ADDR;
reg [31:0]  DataOut;

reg [`OPSELECTWIDTH-1:0] opselect_o;      // Operation selection (selecting what kind of data is set to the risc_data_i)

reg [`CHAIN_ID_LENGTH-1:0] Chain;         // Selected chain
reg [31:0]  DataReadLatch;                // Data when reading register or RISC is latched one risc_clk_i clock after the data is read.
reg         RegAccessTck;                 // Indicates access to the registers (read or write)
reg         RISCAccessTck;                // Indicates access to the RISC (read or write)
reg [7:0]   BitCounter;                   // Counting bits in the ShiftDR and Exit1DR stages
reg         RW;                           // Read/Write bit
reg         CrcMatch;                     // The crc that is shifted in and the internaly calculated crc are equal

reg         RegAccess_q;                  // Delayed signals used for accessing the registers
reg         RegAccess_q2;                 // Delayed signals used for accessing the registers
reg         RISCAccess_q;                 // Delayed signals used for accessing the RISC
reg         RISCAccess_q2;                // Delayed signals used for accessing the RISC

reg         wb_AccessTck;                 // Indicates access to the WISHBONE
reg [31:0]  WBReadLatch;                  // Data latched during WISHBONE read
reg         WBErrorLatch;                 // Error latched during WISHBONE read
wire        trst;                         // trst is active high while trst_pad_i is active low

reg         BypassRegister;               // Bypass register


wire TCK = tck_pad_i;
wire TMS = tms_pad_i;
wire TDI = tdi_pad_i;

wire [31:0]             RegDataIn;        // Data from registers (read data)
wire [`CRC_LENGTH-1:0]  CalculatedCrcOut; // CRC calculated in this module. This CRC is apended at the end of the TDO.

wire RiscStall_reg;                       // RISC is stalled by setting the register bit
wire RiscReset_reg;                       // RISC is reset by setting the register bit
wire RiscStall_trace;                     // RISC is stalled by trace module
       
       
wire RegisterScanChain;                   // Register Scan chain selected
wire RiscDebugScanChain;                  // Risc Debug Scan chain selected
wire WishboneScanChain;                   // WISHBONE Scan chain selected

wire RiscStall_read_access;               // Stalling RISC because of the read access (SPR read)
wire RiscStall_write_access;              // Stalling RISC because of the write access (SPR write)
wire RiscStall_access;                    // Stalling RISC because of the read or write access

wire BitCounter_Lt4;
wire BitCounter_Eq5;
wire BitCounter_Eq32;
wire BitCounter_Lt38;
wire BitCounter_Lt65;

assign capture_dr_o       = CaptureDR;
assign shift_dr_o         = ShiftDR;
assign update_dr_o        = UpdateDR;
assign extest_selected_o  = EXTESTSelected;
wire   BS_CHAIN_I         = bs_chain_i;
assign bs_chain_o         = tdi_pad_i;


// This signals are used only when TRACE is used in the design
`ifdef TRACE_ENABLED
  wire [39:0] TraceChain;                 // Chain that comes from trace module
  reg  ReadBuffer_Tck;                    // Command for incrementing the trace read pointer (synchr with TCK)
  wire ReadTraceBuffer;                   // Command for incrementing the trace read pointer (synchr with MClk)
  reg  ReadTraceBuffer_q;                 // Delayed command for incrementing the trace read pointer (synchr with MClk)
  wire ReadTraceBufferPulse;              // Pulse for reading the trace buffer (valid for only one Mclk command)

  // Outputs from registers
  wire ContinMode;                        // Trace working in continous mode
  wire TraceEnable;                       // Trace enabled
  
  wire [10:0] WpTrigger;                  // Watchpoint starts trigger
  wire        BpTrigger;                  // Breakpoint starts trigger
  wire [3:0]  LSSTrigger;                 // Load/store status starts trigger
  wire [1:0]  ITrigger;                   // Instruction status starts trigger
  wire [1:0]  TriggerOper;                // Trigger operation
  
  wire        WpTriggerValid;             // Watchpoint trigger is valid
  wire        BpTriggerValid;             // Breakpoint trigger is valid
  wire        LSSTriggerValid;            // Load/store status trigger is valid
  wire        ITriggerValid;              // Instruction status trigger is valid
  
  wire [10:0] WpQualif;                   // Watchpoint starts qualifier
  wire        BpQualif;                   // Breakpoint starts qualifier
  wire [3:0]  LSSQualif;                  // Load/store status starts qualifier
  wire [1:0]  IQualif;                    // Instruction status starts qualifier
  wire [1:0]  QualifOper;                 // Qualifier operation
  
  wire        WpQualifValid;              // Watchpoint qualifier is valid
  wire        BpQualifValid;              // Breakpoint qualifier is valid
  wire        LSSQualifValid;             // Load/store status qualifier is valid
  wire        IQualifValid;               // Instruction status qualifier is valid
  
  wire [10:0] WpStop;                     // Watchpoint stops recording of the trace
  wire        BpStop;                     // Breakpoint stops recording of the trace
  wire [3:0]  LSSStop;                    // Load/store status stops recording of the trace
  wire [1:0]  IStop;                      // Instruction status stops recording of the trace
  wire [1:0]  StopOper;                   // Stop operation
  
  wire WpStopValid;                       // Watchpoint stop is valid
  wire BpStopValid;                       // Breakpoint stop is valid
  wire LSSStopValid;                      // Load/store status stop is valid
  wire IStopValid;                        // Instruction status stop is valid
  
  wire RecordPC;                          // Recording program counter
  wire RecordLSEA;                        // Recording load/store effective address
  wire RecordLDATA;                       // Recording load data
  wire RecordSDATA;                       // Recording store data
  wire RecordReadSPR;                     // Recording read SPR
  wire RecordWriteSPR;                    // Recording write SPR
  wire RecordINSTR;                       // Recording instruction
  
  // End: Outputs from registers

  wire TraceTestScanChain;                // Trace Test Scan chain selected
  wire [47:0] Trace_Data;                 // Trace data

  wire [`OPSELECTWIDTH-1:0]opselect_trace;// Operation selection (trace selecting what kind of
                                          // data is set to the risc_data_i)
  wire BitCounter_Lt40;

`endif


/**********************************************************************************
*                                                                                 *
*   Synchronizing TRST to clock signal                                            *
*                                                                                 *
**********************************************************************************/
assign trst = ~trst_pad_i;                // trst_pad_i is active low


/**********************************************************************************
*                                                                                 *
*   TAP State Machine: Fully JTAG compliant                                       *
*                                                                                 *
**********************************************************************************/

// TestLogicReset state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    TestLogicReset<=#Tp 1;
  else
    begin
      if(TMS & (TestLogicReset | SelectIRScan))
        TestLogicReset<=#Tp 1;
      else
        TestLogicReset<=#Tp 0;
    end
end

// RunTestIdle state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    RunTestIdle<=#Tp 0;
  else
    begin
      if(~TMS & (TestLogicReset | RunTestIdle | UpdateDR | UpdateIR))
        RunTestIdle<=#Tp 1;
      else
        RunTestIdle<=#Tp 0;
    end
end

// SelectDRScan state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    SelectDRScan<=#Tp 0;
  else
    begin
      if(TMS & (RunTestIdle | UpdateDR | UpdateIR))
        SelectDRScan<=#Tp 1;
      else
        SelectDRScan<=#Tp 0;
    end
end

// CaptureDR state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    CaptureDR<=#Tp 0;
  else
    begin
      if(~TMS & SelectDRScan)
        CaptureDR<=#Tp 1;
      else
        CaptureDR<=#Tp 0;
    end
end

// ShiftDR state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    ShiftDR<=#Tp 0;
  else
    begin
      if(~TMS & (CaptureDR | ShiftDR | Exit2DR))
        ShiftDR<=#Tp 1;
      else
        ShiftDR<=#Tp 0;
    end
end

// Exit1DR state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    Exit1DR<=#Tp 0;
  else
    begin
      if(TMS & (CaptureDR | ShiftDR))
        Exit1DR<=#Tp 1;
      else
        Exit1DR<=#Tp 0;
    end
end

// PauseDR state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    PauseDR<=#Tp 0;
  else
    begin
      if(~TMS & (Exit1DR | PauseDR))
        PauseDR<=#Tp 1;
      else
        PauseDR<=#Tp 0;
    end
end

// Exit2DR state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    Exit2DR<=#Tp 0;
  else
    begin
      if(TMS & PauseDR)
        Exit2DR<=#Tp 1;
      else
        Exit2DR<=#Tp 0;
    end
end

// UpdateDR state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    UpdateDR<=#Tp 0;
  else
    begin
      if(TMS & (Exit1DR | Exit2DR))
        UpdateDR<=#Tp 1;
      else
        UpdateDR<=#Tp 0;
    end
end

// Delayed UpdateDR state
reg UpdateDR_q;
always @ (posedge TCK)
begin
  UpdateDR_q<=#Tp UpdateDR;
end


// SelectIRScan state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    SelectIRScan<=#Tp 0;
  else
    begin
      if(TMS & SelectDRScan)
        SelectIRScan<=#Tp 1;
      else
        SelectIRScan<=#Tp 0;
    end
end

// CaptureIR state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    CaptureIR<=#Tp 0;
  else
    begin
      if(~TMS & SelectIRScan)
        CaptureIR<=#Tp 1;
      else
        CaptureIR<=#Tp 0;
    end
end

// ShiftIR state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    ShiftIR<=#Tp 0;
  else
    begin
      if(~TMS & (CaptureIR | ShiftIR | Exit2IR))
        ShiftIR<=#Tp 1;
      else
        ShiftIR<=#Tp 0;
    end
end

// Exit1IR state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    Exit1IR<=#Tp 0;
  else
    begin
      if(TMS & (CaptureIR | ShiftIR))
        Exit1IR<=#Tp 1;
      else
        Exit1IR<=#Tp 0;
    end
end

// PauseIR state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    PauseIR<=#Tp 0;
  else
    begin
      if(~TMS & (Exit1IR | PauseIR))
        PauseIR<=#Tp 1;
      else
        PauseIR<=#Tp 0;
    end
end

// Exit2IR state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    Exit2IR<=#Tp 0;
  else
    begin
      if(TMS & PauseIR)
        Exit2IR<=#Tp 1;
      else
        Exit2IR<=#Tp 0;
    end
end

// UpdateIR state
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    UpdateIR<=#Tp 0;
  else
    begin
      if(TMS & (Exit1IR | Exit2IR))
        UpdateIR<=#Tp 1;
      else
        UpdateIR<=#Tp 0;
    end
end

/**********************************************************************************
*                                                                                 *
*   End: TAP State Machine                                                        *
*                                                                                 *
**********************************************************************************/



/**********************************************************************************
*                                                                                 *
*   JTAG_IR:  JTAG Instruction Register                                           *
*                                                                                 *
**********************************************************************************/
wire [1:0]Status = 2'b10;     // Holds current chip status. Core should return this status. For now a constant is used.

reg [`IR_LENGTH-1:0]JTAG_IR;  // Instruction register
reg [`IR_LENGTH-1:0]LatchedJTAG_IR;

reg TDOInstruction;

always @ (posedge TCK or posedge trst)
begin
  if(trst)
    JTAG_IR[`IR_LENGTH-1:0] <= #Tp 0;
  else
    begin
      if(CaptureIR)
        begin
          JTAG_IR[1:0] <= #Tp 2'b01;       // This value is fixed for easier fault detection
          JTAG_IR[3:2] <= #Tp Status[1:0]; // Current status of chip
        end
      else
        begin
          if(ShiftIR)
            begin
              JTAG_IR[`IR_LENGTH-1:0] <= #Tp {TDI, JTAG_IR[`IR_LENGTH-1:1]};
            end
        end
    end
end


//TDO is changing on the falling edge of TCK
always @ (negedge TCK)
begin
  if(ShiftIR)
    TDOInstruction <= #Tp JTAG_IR[0];
end

/**********************************************************************************
*                                                                                 *
*   End: JTAG_IR                                                                  *
*                                                                                 *
**********************************************************************************/


/**********************************************************************************
*                                                                                 *
*   JTAG_DR:  JTAG Data Register                                                  *
*                                                                                 *
**********************************************************************************/
reg [`DR_LENGTH-1:0]JTAG_DR_IN;    // Data register
reg TDOData;


always @ (posedge TCK or posedge trst)
begin
  if(trst)
    JTAG_DR_IN[`DR_LENGTH-1:0]<=#Tp 0;
  else
  if(IDCODESelected)                          // To save space JTAG_DR_IN is also used for shifting out IDCODE
    begin
      if(ShiftDR)
        JTAG_DR_IN[31:0] <= #Tp {TDI, JTAG_DR_IN[31:1]};
      else
        JTAG_DR_IN[31:0] <= #Tp `IDCODE_VALUE;
    end
  else
  if(CHAIN_SELECTSelected & ShiftDR)
    JTAG_DR_IN[12:0] <= #Tp {TDI, JTAG_DR_IN[12:1]};
  else
  if(DEBUGSelected & ShiftDR)
    begin
      if(RiscDebugScanChain | WishboneScanChain)
        JTAG_DR_IN[73:0] <= #Tp {TDI, JTAG_DR_IN[73:1]};
      else
      if(RegisterScanChain)
        JTAG_DR_IN[46:0] <= #Tp {TDI, JTAG_DR_IN[46:1]};
    end
end
 
wire [73:0] RISC_Data;
wire [46:0] Register_Data;
wire [73:0] WISHBONE_Data;
wire [12:0] chain_sel_data;
wire wb_Access_wbClk;


reg select_crc_out;
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    select_crc_out <= 0;
  else
  if( RegisterScanChain  & BitCounter_Eq5  |
      RiscDebugScanChain & BitCounter_Eq32 |
      WishboneScanChain  & BitCounter_Eq32 )
    select_crc_out <=#Tp TDI;
  else
  if(CHAIN_SELECTSelected)
    select_crc_out <=#Tp 1;
  else
  if(UpdateDR)
    select_crc_out <=#Tp 0;
end

wire [8:0] send_crc;

assign send_crc = select_crc_out? {9{BypassRegister}}    :    // Calculated CRC is returned when read operation is
                                  {CalculatedCrcOut, 1'b0} ;  // performed, else received crc is returned (loopback).

assign RISC_Data      = {send_crc, DataReadLatch, 33'h0};
assign Register_Data  = {send_crc, DataReadLatch, 6'h0};
assign WISHBONE_Data  = {send_crc, WBReadLatch, 32'h0, WBErrorLatch};
assign chain_sel_data = {send_crc, 4'h0};
                                                  
                                                  
`ifdef TRACE_ENABLED                              
  assign Trace_Data     = {CalculatedCrcOut, TraceChain};
`endif

//TDO is changing on the falling edge of TCK
always @ (negedge TCK or posedge trst)
begin
  if(trst)
    begin
      TDOData <= #Tp 0;
      `ifdef TRACE_ENABLED
      ReadBuffer_Tck<=#Tp 0;
      `endif
    end
  else
  if(UpdateDR)
    begin
      TDOData <= #Tp CrcMatch;
      `ifdef TRACE_ENABLED
      if(DEBUGSelected & TraceTestScanChain & TraceChain[0])  // Sample in the trace buffer is valid
        ReadBuffer_Tck<=#Tp 1;                                // Increment read pointer
      `endif
    end
  else
    begin
      if(ShiftDR)
        begin
          if(IDCODESelected)
            TDOData <= #Tp JTAG_DR_IN[0]; // IDCODE is shifted out 32-bits, then TDI is bypassed
          else
          if(CHAIN_SELECTSelected)
            TDOData <= #Tp chain_sel_data[BitCounter];        // Received crc is sent back
          else
          if(DEBUGSelected)
            begin
              if(RiscDebugScanChain)
                TDOData <= #Tp RISC_Data[BitCounter];         // Data read from RISC in the previous cycle is shifted out
              else
              if(RegisterScanChain)
                TDOData <= #Tp Register_Data[BitCounter];     // Data read from register in the previous cycle is shifted out
              else
              if(WishboneScanChain)
                TDOData <= #Tp WISHBONE_Data[BitCounter];     // Data read from the WISHBONE slave
              `ifdef TRACE_ENABLED
              else
              if(TraceTestScanChain)
                TDOData <= #Tp Trace_Data[BitCounter];        // Data from the trace buffer is shifted out
              `endif
            end
        end
      else
        begin
          TDOData <= #Tp 0;
          `ifdef TRACE_ENABLED
          ReadBuffer_Tck<=#Tp 0;
          `endif
        end
    end
end

/**********************************************************************************
*                                                                                 *
*   End: JTAG_DR                                                                  *
*                                                                                 *
**********************************************************************************/



/**********************************************************************************
*                                                                                 *
*   CHAIN_SELECT logic                                                            *
*                                                                                 *
**********************************************************************************/
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    Chain[`CHAIN_ID_LENGTH-1:0]<=#Tp `GLOBAL_BS_CHAIN;  // Global BS chain is selected after reset
  else
  if(UpdateDR & CHAIN_SELECTSelected & CrcMatch)
    Chain[`CHAIN_ID_LENGTH-1:0]<=#Tp JTAG_DR_IN[3:0];   // New chain is selected
end



/**********************************************************************************
*                                                                                 *
*   Register read/write logic                                                     *
*   RISC registers read/write logic                                               *
*                                                                                 *
**********************************************************************************/
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    begin
      ADDR[31:0]        <=#Tp 32'h0;
      DataOut[31:0]     <=#Tp 32'h0;
      RW                <=#Tp 1'b0;
      RegAccessTck      <=#Tp 1'b0;
      RISCAccessTck     <=#Tp 1'b0;
      wb_AccessTck      <=#Tp 1'h0;
    end
  else
  if(UpdateDR & DEBUGSelected & CrcMatch)
    begin
      if(RegisterScanChain)
        begin
          ADDR[4:0]         <=#Tp JTAG_DR_IN[4:0];    // Latching address for register access
          RW                <=#Tp JTAG_DR_IN[5];      // latch R/W bit
          DataOut[31:0]     <=#Tp JTAG_DR_IN[37:6];   // latch data for write
          RegAccessTck      <=#Tp 1'b1;
        end
      else
      if(RiscDebugScanChain)
        begin
          ADDR[31:0]        <=#Tp JTAG_DR_IN[31:0];   // Latching address for RISC register access
          RW                <=#Tp JTAG_DR_IN[32];     // latch R/W bit
          DataOut[31:0]     <=#Tp JTAG_DR_IN[64:33];  // latch data for write
          RISCAccessTck     <=#Tp 1'b1;
        end
      else
      if(WishboneScanChain)
        begin
          ADDR              <=#Tp JTAG_DR_IN[31:0];   // Latching address for WISHBONE slave access
          RW                <=#Tp JTAG_DR_IN[32];     // latch R/W bit
          DataOut           <=#Tp JTAG_DR_IN[64:33];  // latch data for write
          wb_AccessTck      <=#Tp 1'b1;               // 
        end
    end
  else
    begin
      RegAccessTck      <=#Tp 1'b0;       // This signals are valid for one TCK clock period only
      RISCAccessTck     <=#Tp 1'b0;
      wb_AccessTck      <=#Tp 1'b0;
    end
end


assign wb_adr_o = ADDR;
assign wb_we_o  = RW;
assign wb_dat_o = DataOut;
assign wb_sel_o[3:0] = 4'hf;
assign wb_cab_o = 1'b0;
   
   
// Synchronizing the RegAccess signal to risc_clk_i clock
dbg_sync_clk1_clk2 syn1 (.clk1(risc_clk_i),   .clk2(TCK),           .reset1(wb_rst_i),  .reset2(trst), 
                         .set2(RegAccessTck), .sync_out(RegAccess)
                        );

// Synchronizing the RISCAccess signal to risc_clk_i clock
dbg_sync_clk1_clk2 syn2 (.clk1(risc_clk_i),    .clk2(TCK),          .reset1(wb_rst_i),  .reset2(trst), 
                         .set2(RISCAccessTck), .sync_out(RISCAccess)
                        );


// Synchronizing the wb_Access signal to wishbone clock
dbg_sync_clk1_clk2 syn3 (.clk1(wb_clk_i),     .clk2(TCK),           .reset1(wb_rst_i),  .reset2(trst), 
                         .set2(wb_AccessTck), .sync_out(wb_Access_wbClk)
                        );





// Delayed signals used for accessing registers and RISC
always @ (posedge risc_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    begin
      RegAccess_q   <=#Tp 1'b0;
      RegAccess_q2  <=#Tp 1'b0;
      RISCAccess_q  <=#Tp 1'b0;
      RISCAccess_q2 <=#Tp 1'b0;
    end
  else
    begin
      RegAccess_q   <=#Tp RegAccess;
      RegAccess_q2  <=#Tp RegAccess_q;
      RISCAccess_q  <=#Tp RISCAccess;
      RISCAccess_q2 <=#Tp RISCAccess_q;
    end
end

// Chip select and read/write signals for accessing RISC
assign RiscStall_write_access = RISCAccess & ~RISCAccess_q  &  RW;
assign RiscStall_read_access  = RISCAccess & ~RISCAccess_q2 & ~RW;
assign RiscStall_access = RiscStall_write_access | RiscStall_read_access;


reg wb_Access_wbClk_q;
// Delayed signals used for accessing WISHBONE
always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    wb_Access_wbClk_q <=#Tp 1'b0;
  else
    wb_Access_wbClk_q <=#Tp wb_Access_wbClk;
end

always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    wb_cyc_o <=#Tp 1'b0;
  else
  if(wb_Access_wbClk & ~wb_Access_wbClk_q & ~(wb_ack_i | wb_err_i))
    wb_cyc_o <=#Tp 1'b1;
  else
  if(wb_ack_i | wb_err_i)
    wb_cyc_o <=#Tp 1'b0;
end

assign wb_stb_o = wb_cyc_o;


// Latching data read from registers
always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    WBReadLatch[31:0]<=#Tp 32'h0;
  else
  if(wb_ack_i)
    WBReadLatch[31:0]<=#Tp wb_dat_i[31:0];
end

// Latching WISHBONE error cycle
always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    WBErrorLatch<=#Tp 1'b0;
  else
  if(wb_err_i)
    WBErrorLatch<=#Tp 1'b1;     // Latching wb_err_i while performing WISHBONE access
  else
  if(wb_ack_i)
    WBErrorLatch<=#Tp 1'b0;     // Clearing status
end


// Whan enabled, TRACE stalls RISC while saving data to the trace buffer.
`ifdef TRACE_ENABLED
  assign  risc_stall_o = RiscStall_access | RiscStall_reg | RiscStall_trace ;
`else
  assign  risc_stall_o = RiscStall_access | RiscStall_reg;
`endif

assign  reset_o = RiscReset_reg;


`ifdef TRACE_ENABLED
always @ (RiscStall_write_access or RiscStall_read_access or opselect_trace)
`else
always @ (RiscStall_write_access or RiscStall_read_access)
`endif
begin
  if(RiscStall_write_access)
    opselect_o = `DEBUG_WRITE_SPR;  // Write spr
  else
  if(RiscStall_read_access)
    opselect_o = `DEBUG_READ_SPR;   // Read spr
  else
`ifdef TRACE_ENABLED
    opselect_o = opselect_trace;
`else
    opselect_o = 3'h0;
`endif
end


// Latching data read from RISC or registers
always @ (posedge risc_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    DataReadLatch[31:0]<=#Tp 0;
  else
  if(RISCAccess_q & ~RISCAccess_q2)
    DataReadLatch[31:0]<=#Tp risc_data_i[31:0];
  else
  if(RegAccess_q & ~RegAccess_q2)
    DataReadLatch[31:0]<=#Tp RegDataIn[31:0];
end

assign risc_addr_o = ADDR;
assign risc_data_o = DataOut;



/**********************************************************************************
*                                                                                 *
*   Read Trace buffer logic                                                       *
*                                                                                 *
**********************************************************************************/
`ifdef TRACE_ENABLED
  

// Synchronizing the trace read buffer signal to risc_clk_i clock
dbg_sync_clk1_clk2 syn4 (.clk1(risc_clk_i),     .clk2(TCK),           .reset1(wb_rst_i),  .reset2(trst), 
                         .set2(ReadBuffer_Tck), .sync_out(ReadTraceBuffer)
                        );



  always @(posedge risc_clk_i or posedge wb_rst_i)
  begin
    if(wb_rst_i)
      ReadTraceBuffer_q <=#Tp 0;
    else
      ReadTraceBuffer_q <=#Tp ReadTraceBuffer;
  end

  assign ReadTraceBufferPulse = ReadTraceBuffer & ~ReadTraceBuffer_q;

`endif

/**********************************************************************************
*                                                                                 *
*   End: Read Trace buffer logic                                                  *
*                                                                                 *
**********************************************************************************/


/**********************************************************************************
*                                                                                 *
*   Bypass logic                                                                  *
*                                                                                 *
**********************************************************************************/
reg TDOBypassed;

always @ (posedge TCK)
begin
  if(ShiftDR)
    BypassRegister<=#Tp TDI;
end

always @ (negedge TCK)
begin
    TDOBypassed<=#Tp BypassRegister;
end
/**********************************************************************************
*                                                                                 *
*   End: Bypass logic                                                             *
*                                                                                 *
**********************************************************************************/





/**********************************************************************************
*                                                                                 *
*   Activating Instructions                                                       *
*                                                                                 *
**********************************************************************************/

// Updating JTAG_IR (Instruction Register)
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    LatchedJTAG_IR <=#Tp `IDCODE;   // IDCODE selected after reset
  else
  if(UpdateIR)
    LatchedJTAG_IR <=#Tp JTAG_IR;
end



// Updating JTAG_IR (Instruction Register)
always @ (LatchedJTAG_IR)
begin
  EXTESTSelected          = 0;
  SAMPLE_PRELOADSelected  = 0;
  IDCODESelected          = 0;
  CHAIN_SELECTSelected    = 0;
  INTESTSelected          = 0;
  CLAMPSelected           = 0;
  CLAMPZSelected          = 0;
  HIGHZSelected           = 0;
  DEBUGSelected           = 0;
  BYPASSSelected          = 0;

  case(LatchedJTAG_IR)
    `EXTEST:            EXTESTSelected          = 1;    // External test
    `SAMPLE_PRELOAD:    SAMPLE_PRELOADSelected  = 1;    // Sample preload
    `IDCODE:            IDCODESelected          = 1;    // ID Code
    `CHAIN_SELECT:      CHAIN_SELECTSelected    = 1;    // Chain select
    `INTEST:            INTESTSelected          = 1;    // Internal test
    `CLAMP:             CLAMPSelected           = 1;    // Clamp
    `CLAMPZ:            CLAMPZSelected          = 1;    // ClampZ
    `HIGHZ:             HIGHZSelected           = 1;    // High Z
    `DEBUG:             DEBUGSelected           = 1;    // Debug
    `BYPASS:            BYPASSSelected          = 1;    // BYPASS
    default:            BYPASSSelected          = 1;    // BYPASS
  endcase
end


/**********************************************************************************
*                                                                                 *
*   Multiplexing TDO and Tristate control                                         *
*                                                                                 *
**********************************************************************************/
wire TDOShifted;
assign TDOShifted = (ShiftIR | Exit1IR)? TDOInstruction : TDOData;
/**********************************************************************************
*                                                                                 *
*   End:  Multiplexing TDO and Tristate control                                   *
*                                                                                 *
**********************************************************************************/



// This multiplexer can be expanded with number of user registers
reg TDOMuxed;
//always @ (JTAG_IR or TDOShifted or TDOBypassed or BS_CHAIN_I)
always @ (LatchedJTAG_IR or TDOShifted or TDOBypassed or BS_CHAIN_I)
begin
  case(JTAG_IR)
    `IDCODE: // Reading ID code
      begin
        TDOMuxed<=#Tp TDOShifted;
      end
    `CHAIN_SELECT: // Selecting the chain
      begin
        TDOMuxed<=#Tp TDOShifted;
      end
    `DEBUG: // Debug
      begin
        TDOMuxed<=#Tp TDOShifted;
      end
    `SAMPLE_PRELOAD:  // Sampling/Preloading
      begin
        TDOMuxed<=#Tp BS_CHAIN_I;
      end
    `EXTEST:  // External test
      begin
        TDOMuxed<=#Tp BS_CHAIN_I;
      end
    default:  // BYPASS instruction
      begin
        TDOMuxed<=#Tp TDOBypassed;
      end
  endcase
end

// Tristate control for tdo_pad_o pin
//assign tdo_pad_o = (ShiftIR | ShiftDR | Exit1IR | Exit1DR | UpdateDR)? TDOMuxed : 1'bz;
assign tdo_pad_o = TDOMuxed;
assign tdo_padoen_o = ShiftIR | ShiftDR | Exit1IR | Exit1DR | UpdateDR;

/**********************************************************************************
*                                                                                 *
*   End: Activating Instructions                                                  *
*                                                                                 *
**********************************************************************************/

/**********************************************************************************
*                                                                                 *
*   Bit counter                                                                   *
*                                                                                 *
**********************************************************************************/


always @ (posedge TCK or posedge trst)
begin
  if(trst)
    BitCounter[7:0]<=#Tp 0;
  else
  if(ShiftDR)
    BitCounter[7:0]<=#Tp BitCounter[7:0]+1;
  else
  if(UpdateDR)
    BitCounter[7:0]<=#Tp 0;
end



/**********************************************************************************
*                                                                                 *
*   End: Bit counter                                                              *
*                                                                                 *
**********************************************************************************/



/**********************************************************************************
*                                                                                 *
*   Connecting Registers                                                          *
*                                                                                 *
**********************************************************************************/
dbg_registers dbgregs(.DataIn(DataOut[31:0]), .DataOut(RegDataIn[31:0]), 
                      .Address(ADDR[4:0]), .RW(RW), .Access(RegAccess & ~RegAccess_q), .Clk(risc_clk_i), 
                      .Bp(bp_i), .Reset(wb_rst_i), 
                      `ifdef TRACE_ENABLED
                      .ContinMode(ContinMode), .TraceEnable(TraceEnable), 
                      .WpTrigger(WpTrigger), .BpTrigger(BpTrigger), .LSSTrigger(LSSTrigger),
                      .ITrigger(ITrigger), .TriggerOper(TriggerOper), .WpQualif(WpQualif),
                      .BpQualif(BpQualif), .LSSQualif(LSSQualif), .IQualif(IQualif), 
                      .QualifOper(QualifOper), .RecordPC(RecordPC), 
                      .RecordLSEA(RecordLSEA), .RecordLDATA(RecordLDATA), 
                      .RecordSDATA(RecordSDATA), .RecordReadSPR(RecordReadSPR), 
                      .RecordWriteSPR(RecordWriteSPR), .RecordINSTR(RecordINSTR), 
                      .WpTriggerValid(WpTriggerValid), 
                      .BpTriggerValid(BpTriggerValid), .LSSTriggerValid(LSSTriggerValid), 
                      .ITriggerValid(ITriggerValid), .WpQualifValid(WpQualifValid), 
                      .BpQualifValid(BpQualifValid), .LSSQualifValid(LSSQualifValid), 
                      .IQualifValid(IQualifValid),
                      .WpStop(WpStop), .BpStop(BpStop), .LSSStop(LSSStop), .IStop(IStop), 
                      .StopOper(StopOper), .WpStopValid(WpStopValid), .BpStopValid(BpStopValid), 
                      .LSSStopValid(LSSStopValid), .IStopValid(IStopValid), 
                      `endif
                      .RiscStall(RiscStall_reg), .RiscReset(RiscReset_reg)

                     );

/**********************************************************************************
*                                                                                 *
*   End: Connecting Registers                                                     *
*                                                                                 *
**********************************************************************************/


/**********************************************************************************
*                                                                                 *
*   Connecting CRC module                                                         *
*                                                                                 *
**********************************************************************************/
wire AsyncResetCrc = trst;
wire SyncResetCrc = UpdateDR_q;
wire [7:0] CalculatedCrcIn;     // crc calculated from the input data (shifted in)

assign BitCounter_Lt4   = BitCounter<4;
assign BitCounter_Eq5   = BitCounter==5;
assign BitCounter_Eq32  = BitCounter==32;
assign BitCounter_Lt38  = BitCounter<38;
assign BitCounter_Lt65  = BitCounter<65;

`ifdef TRACE_ENABLED
  assign BitCounter_Lt40 = BitCounter<40;
`endif


wire EnableCrcIn = ShiftDR & 
                  ( (CHAIN_SELECTSelected                 & BitCounter_Lt4) |
                    ((DEBUGSelected & RegisterScanChain)  & BitCounter_Lt38)| 
                    ((DEBUGSelected & RiscDebugScanChain) & BitCounter_Lt65)|
                    ((DEBUGSelected & WishboneScanChain)  & BitCounter_Lt65)  
                  );

wire EnableCrcOut= ShiftDR & 
                   (
                    ((DEBUGSelected & RegisterScanChain)  & BitCounter_Lt38)| 
                    ((DEBUGSelected & RiscDebugScanChain) & BitCounter_Lt65)|
                    ((DEBUGSelected & WishboneScanChain)  & BitCounter_Lt65)  
                    `ifdef TRACE_ENABLED
                                                                            |
                    ((DEBUGSelected & TraceTestScanChain) & BitCounter_Lt40) 
                    `endif
                   );

// Calculating crc for input data
dbg_crc8_d1 crc1 (.Data(TDI), .EnableCrc(EnableCrcIn), .Reset(AsyncResetCrc), .SyncResetCrc(SyncResetCrc), 
                  .CrcOut(CalculatedCrcIn), .Clk(TCK));

// Calculating crc for output data
dbg_crc8_d1 crc2 (.Data(TDOData), .EnableCrc(EnableCrcOut), .Reset(AsyncResetCrc), .SyncResetCrc(SyncResetCrc), 
                  .CrcOut(CalculatedCrcOut), .Clk(TCK));


// Generating CrcMatch signal
always @ (posedge TCK or posedge trst)
begin
  if(trst)
    CrcMatch <=#Tp 1'b0;
  else
  if(Exit1DR)
    begin
      if(CHAIN_SELECTSelected)
        CrcMatch <=#Tp CalculatedCrcIn == JTAG_DR_IN[11:4];
      else
        begin
          if(RegisterScanChain)
            CrcMatch <=#Tp CalculatedCrcIn == JTAG_DR_IN[45:38];
          else
          if(RiscDebugScanChain)
            CrcMatch <=#Tp CalculatedCrcIn == JTAG_DR_IN[72:65];
          else
          if(WishboneScanChain)
            CrcMatch <=#Tp CalculatedCrcIn == JTAG_DR_IN[72:65];
        end
    end
end


// Active chain
assign RegisterScanChain   = Chain == `REGISTER_SCAN_CHAIN;
assign RiscDebugScanChain  = Chain == `RISC_DEBUG_CHAIN;
assign WishboneScanChain   = Chain == `WISHBONE_SCAN_CHAIN;

`ifdef TRACE_ENABLED
  assign TraceTestScanChain  = Chain == `TRACE_TEST_CHAIN;
`endif

/**********************************************************************************
*                                                                                 *
*   End: Connecting CRC module                                                    *
*                                                                                 *
**********************************************************************************/

/**********************************************************************************
*                                                                                 *
*   Connecting trace module                                                       *
*                                                                                 *
**********************************************************************************/
`ifdef TRACE_ENABLED
  dbg_trace dbgTrace1(.Wp(wp_i), .Bp(bp_i), .DataIn(risc_data_i), .OpSelect(opselect_trace), 
                      .LsStatus(lsstatus_i), .IStatus(istatus_i), .RiscStall_O(RiscStall_trace), 
                      .Mclk(risc_clk_i), .Reset(wb_rst_i), .TraceChain(TraceChain), 
                      .ContinMode(ContinMode), .TraceEnable_reg(TraceEnable), 
                      .WpTrigger(WpTrigger), 
                      .BpTrigger(BpTrigger), .LSSTrigger(LSSTrigger), .ITrigger(ITrigger), 
                      .TriggerOper(TriggerOper), .WpQualif(WpQualif), .BpQualif(BpQualif), 
                      .LSSQualif(LSSQualif), .IQualif(IQualif), .QualifOper(QualifOper), 
                      .RecordPC(RecordPC), .RecordLSEA(RecordLSEA), 
                      .RecordLDATA(RecordLDATA), .RecordSDATA(RecordSDATA), 
                      .RecordReadSPR(RecordReadSPR), .RecordWriteSPR(RecordWriteSPR), 
                      .RecordINSTR(RecordINSTR), 
                      .WpTriggerValid(WpTriggerValid), .BpTriggerValid(BpTriggerValid), 
                      .LSSTriggerValid(LSSTriggerValid), .ITriggerValid(ITriggerValid), 
                      .WpQualifValid(WpQualifValid), .BpQualifValid(BpQualifValid), 
                      .LSSQualifValid(LSSQualifValid), .IQualifValid(IQualifValid),
                      .ReadBuffer(ReadTraceBufferPulse),
                      .WpStop(WpStop), .BpStop(BpStop), .LSSStop(LSSStop), .IStop(IStop), 
                      .StopOper(StopOper), .WpStopValid(WpStopValid), .BpStopValid(BpStopValid), 
                      .LSSStopValid(LSSStopValid), .IStopValid(IStopValid) 
                     );
`endif
/**********************************************************************************
*                                                                                 *
*   End: Connecting trace module                                                  *
*                                                                                 *
**********************************************************************************/



endmodule
