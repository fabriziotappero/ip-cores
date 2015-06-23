//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_trace.v                                                 ////
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
// Revision 1.6  2001/11/26 10:47:09  mohor
// Crc generation is different for read or write commands. Small synthesys fixes.
//
// Revision 1.5  2001/10/19 11:40:01  mohor
// dbg_timescale.v changed to timescale.v This is done for the simulation of
// few different cores in a single project.
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
// Revision 1.1.1.1  2001/05/18 06:35:06  mohor
// Initial release
//
//


// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "dbg_defines.v"

// module Trace
module dbg_trace (Wp, Bp, DataIn, OpSelect, LsStatus, IStatus, RiscStall_O, 
                  Mclk, Reset, TraceChain, ContinMode, TraceEnable_reg, 
                  WpTrigger, BpTrigger, LSSTrigger, ITrigger, TriggerOper, WpQualif, 
                  BpQualif, LSSQualif, IQualif, QualifOper, RecordPC, RecordLSEA, 
                  RecordLDATA, RecordSDATA, RecordReadSPR, RecordWriteSPR, 
                  RecordINSTR, 
                  WpTriggerValid, BpTriggerValid, LSSTriggerValid, ITriggerValid, 
                  WpQualifValid, BpQualifValid, LSSQualifValid, IQualifValid, ReadBuffer,
                  WpStop, BpStop, LSSStop, IStop, StopOper, WpStopValid, BpStopValid, 
                  LSSStopValid, IStopValid 
                 );

parameter Tp = 1;


input [10:0] Wp;              // Watchpoints
input        Bp;              // Breakpoint
input [31:0] DataIn;          // Data from the RISC
input [3:0]  LsStatus;        // Load/Store status
input [1:0]  IStatus;         // Instruction status

input        Mclk;            // Master clock (RISC clock)
input        Reset;           // Reset
input        ReadBuffer;      // Instruction for reading a sample from the Buffer

// from registers
input ContinMode;             // Continous mode of the trace
input TraceEnable_reg;        // Trace is enabled (enabled by writing a bit in the register)

input [10:0] WpTrigger;       // Signals that come from registers to set the trigger
input        BpTrigger;       // Signals that come from registers to set the trigger
input [3:0]  LSSTrigger;      // Signals that come from registers to set the trigger
input [1:0]  ITrigger;        // Signals that come from registers to set the trigger
input [1:0]  TriggerOper;     // Signals that come from registers to set the trigger

input [10:0] WpQualif;        // Signals that come from registers to set the qualifier
input        BpQualif;        // Signals that come from registers to set the qualifier
input [3:0]  LSSQualif;       // Signals that come from registers to set the qualifier
input [1:0]  IQualif;         // Signals that come from registers to set the qualifier
input [1:0]  QualifOper;      // Signals that come from registers to set the qualifier

input [10:0] WpStop;          // Signals that come from registers to set the stop condition
input        BpStop;          // Signals that come from registers to set the stop condition
input [3:0]  LSSStop;         // Signals that come from registers to set the stop condition
input [1:0]  IStop;           // Signals that come from registers to set the stop condition
input [1:0]  StopOper;        // Signals that come from registers to set the stop condition

input RecordPC;               // Signals that come from registers for defining the sample for recording
input RecordLSEA;             // Signals that come from registers for defining the sample for recording
input RecordLDATA;            // Signals that come from registers for defining the sample for recording
input RecordSDATA;            // Signals that come from registers for defining the sample for recording
input RecordReadSPR;          // Signals that come from registers for defining the sample for recording
input RecordWriteSPR;         // Signals that come from registers for defining the sample for recording
input RecordINSTR;            // Signals that come from registers for defining the sample for recording

input WpTriggerValid;         // Signals that come from registers and indicate which trigger conditions are valid
input BpTriggerValid;         // Signals that come from registers and indicate which trigger conditions are valid
input LSSTriggerValid;        // Signals that come from registers and indicate which trigger conditions are valid
input ITriggerValid;          // Signals that come from registers and indicate which trigger conditions are valid

input WpQualifValid;          // Signals that come from registers and indicate which qualifier conditions are valid
input BpQualifValid;          // Signals that come from registers and indicate which qualifier conditions are valid
input LSSQualifValid;         // Signals that come from registers and indicate which qualifier conditions are valid
input IQualifValid;           // Signals that come from registers and indicate which qualifier conditions are valid

input WpStopValid;            // Signals that come from registers and indicate which stop conditions are valid
input BpStopValid;            // Signals that come from registers and indicate which stop conditions are valid
input LSSStopValid;           // Signals that come from registers and indicate which stop conditions are valid
input IStopValid;             // Signals that come from registers and indicate which stop conditions are valid
// end: from registers


output [`OPSELECTWIDTH-1:0]  OpSelect;  // Operation select (what kind of information is avaliable on the DataIn)
output        RiscStall_O;              // CPU stall (stalls the RISC)
output [39:0] TraceChain;               // Scan shain from the trace module

reg TraceEnable_d;
reg TraceEnable;



reg [`TRACECOUNTERWIDTH:0] Counter;
reg [`TRACECOUNTERWIDTH-1:0] WritePointer;
reg [`TRACECOUNTERWIDTH-1:0] ReadPointer;
reg RiscStall;
reg RiscStall_q;
reg [`OPSELECTWIDTH-1:0] StallCounter;

reg [`TRACESAMPLEWIDTH-1:0] Buffer[0:`TRACEBUFFERLENGTH-1];

reg TriggerLatch;


/**********************************************************************************
*                                                                                 *
*   Generation of the trigger                                                     *
*                                                                                 *
**********************************************************************************/
wire TempWpTrigger = |(Wp[10:0] & WpTrigger[10:0]);
wire TempBpTrigger = Bp & BpTrigger;
wire TempLSSTrigger = LsStatus[3:0] == LSSTrigger[3:0];
wire TempITrigger = IStatus[1:0] == ITrigger[1:0];

wire TempTriggerAND =  (  (TempWpTrigger  | ~WpTriggerValid)
                        & (TempBpTrigger  | ~BpTriggerValid) 
                        & (TempLSSTrigger | ~LSSTriggerValid) 
                        & (TempITrigger   | ~ITriggerValid)
                       ) 
                       & (WpTriggerValid | BpTriggerValid | LSSTriggerValid | ITriggerValid);

wire TempTriggerOR =   (  (TempWpTrigger  &  WpTriggerValid)
                        | (TempBpTrigger  &  BpTriggerValid) 
                        | (TempLSSTrigger &  LSSTriggerValid) 
                        | (TempITrigger   &  ITriggerValid)
                       );

wire Trigger = TraceEnable & (~TriggerOper[1]?  1 :                               // any
                               TriggerOper[0]?  TempTriggerAND : TempTriggerOR    // AND : OR
                             );

/**********************************************************************************
*                                                                                 *
*   Generation of the qualifier                                                   *
*                                                                                 *
**********************************************************************************/
wire TempWpQualifier = |(Wp[10:0] & WpQualif[10:0]);
wire TempBpQualifier = Bp & BpQualif;
wire TempLSSQualifier = LsStatus[3:0] == LSSQualif[3:0];
wire TempIQualifier = IStatus[1:0] == IQualif[1:0];

wire TempQualifierAND =  (  (TempWpQualifier  | ~WpQualifValid)
                          & (TempBpQualifier  | ~BpQualifValid) 
                          & (TempLSSQualifier | ~LSSQualifValid) 
                          & (TempIQualifier   | ~IQualifValid)
                         ) 
                         & (WpQualifValid | BpQualifValid | LSSQualifValid | IQualifValid);

wire TempQualifierOR =   (  (TempWpQualifier  &  WpQualifValid)
                          | (TempBpQualifier  &  BpQualifValid) 
                          | (TempLSSQualifier &  LSSQualifValid) 
                          | (TempIQualifier   &  IQualifValid)
                         );


wire Stop;
wire Qualifier = TraceEnable & ~Stop & (~QualifOper[1]? 1 :                                   // any
                                         QualifOper[0]? TempQualifierAND  :  TempQualifierOR  // AND : OR
                                       );

/**********************************************************************************
*                                                                                 *
*   Generation of the stop signal                                                 *
*                                                                                 *
**********************************************************************************/
wire TempWpStop = |(Wp[10:0] & WpStop[10:0]);
wire TempBpStop = Bp & BpStop;
wire TempLSSStop = LsStatus[3:0] == LSSStop[3:0];
wire TempIStop = IStatus[1:0] == IStop[1:0];

wire TempStopAND =       (  (TempWpStop  | ~WpStopValid)
                          & (TempBpStop  | ~BpStopValid) 
                          & (TempLSSStop | ~LSSStopValid) 
                          & (TempIStop   | ~IStopValid)
                         ) 
                         & (WpStopValid | BpStopValid | LSSStopValid | IStopValid);

wire TempStopOR =        (  (TempWpStop  &  WpStopValid)
                          | (TempBpStop  &  BpStopValid) 
                          | (TempLSSStop &  LSSStopValid) 
                          | (TempIStop   &  IStopValid)
                         );


assign Stop = TraceEnable & (~StopOper[1]? 0 :                         // nothing
                              StopOper[0]? TempStopAND  :  TempStopOR  // AND : OR
                            );



/**********************************************************************************
*                                                                                 *
*   Generation of the TriggerLatch                                                *
*                                                                                 *
**********************************************************************************/
always @(posedge Mclk or posedge Reset)
begin
  if(Reset)
    TriggerLatch<=#Tp 0;
  else
  if(TriggerLatch & ~TraceEnable)
    TriggerLatch<=#Tp 0;
  else
  if(Trigger)
    TriggerLatch<=#Tp 1;
end




/**********************************************************************************
*                                                                                 *
*   TraceEnable Synchronization                                                   *
*                                                                                 *
**********************************************************************************/
always @(posedge Mclk or posedge Reset)
begin
  if(Reset)
    begin
      TraceEnable_d<=#Tp 0;
      TraceEnable<=#Tp 0;
    end
  else
    begin
      TraceEnable_d<=#Tp TraceEnable_reg;
      TraceEnable<=#Tp TraceEnable_d;
    end
end




/**********************************************************************************
*                                                                                 *
*   RiscStall, counter and pointers generation                                     *
*                                                                                 *
**********************************************************************************/
reg BufferFullDetected;
wire [`OPSELECTIONCOUNTER-1:0] RecEnable;

wire BufferFull = Counter[`TRACECOUNTERWIDTH:0]==`TRACEBUFFERLENGTH;
wire BufferEmpty = Counter[`TRACECOUNTERWIDTH:0]==0;
wire IncrementCounter = RiscStall_q & ~(BufferFull | BufferFullDetected) & Qualifier & RecEnable[StallCounter];
wire IncrementPointer = RiscStall_q & (~BufferFull | ContinMode) & Qualifier & RecEnable[StallCounter];

wire WriteSample = IncrementPointer;

wire Decrement = ReadBuffer & ~BufferEmpty & (~ContinMode | ContinMode & ~TraceEnable);
wire CounterEn = IncrementCounter ^ Decrement;

wire SyncResetCpuStall;
wire ResetStallCounter;
reg BufferFull_q;
reg BufferFull_2q;

reg Qualifier_mclk;

always @(posedge Mclk)
begin
  Qualifier_mclk<=#Tp Qualifier;
  BufferFull_q<=#Tp BufferFull;
  BufferFull_2q<=#Tp BufferFull_q;
  RiscStall_q <=#Tp RiscStall_O;
end


wire FirstCpuStall =    Qualifier & ~Qualifier_mclk & TriggerLatch              | 
                        Qualifier_mclk & Trigger & ~TriggerLatch                | 
                        Qualifier & Trigger & ~Qualifier_mclk & ~TriggerLatch   ;


//wire SyncSetCpuStall = Qualifier_mclk & TriggerLatch &

wire SyncSetCpuStall = RiscStall_O & ~RiscStall_q |
                        Qualifier_mclk & TriggerLatch &
                       ( 
                        (~ContinMode & ~BufferFull & ~BufferFull_q & StallCounter==`OPSELECTIONCOUNTER-1) |
                        (~ContinMode & ~BufferFull_q & BufferFull_2q & StallCounter==0)                   |
                        ( ContinMode & StallCounter==`OPSELECTIONCOUNTER-1)
                       );

assign SyncResetCpuStall = ( 
                            (~ContinMode & ~BufferFull & ~BufferFull_q & StallCounter==`OPSELECTIONCOUNTER-2) |
                            (~ContinMode &  ~BufferFull & BufferFull_q & StallCounter==`OPSELECTIONCOUNTER-1) |
                            ( ContinMode & StallCounter==`OPSELECTIONCOUNTER-2)
                           );

assign RiscStall_O = FirstCpuStall | RiscStall;


always @(posedge Mclk or posedge Reset)
begin
  if(Reset)
    Counter<=#Tp 0;
  else
  if(CounterEn)
    if(IncrementCounter)
      Counter[`TRACECOUNTERWIDTH:0]<=#Tp Counter[`TRACECOUNTERWIDTH:0] + 1;
    else
      Counter[`TRACECOUNTERWIDTH:0]<=#Tp Counter[`TRACECOUNTERWIDTH:0] - 1;      
end


always @(posedge Mclk or posedge Reset)
begin
  if(Reset)
    WritePointer<=#Tp 0;
  else
  if(IncrementPointer)
    WritePointer[`TRACECOUNTERWIDTH-1:0]<=#Tp WritePointer[`TRACECOUNTERWIDTH-1:0] + 1;
end

always @(posedge Mclk or posedge Reset)
begin
  if(Reset)
    ReadPointer<=#Tp 0;
  else
  if(Decrement & ~ContinMode | Decrement & ContinMode & ~TraceEnable)
    ReadPointer[`TRACECOUNTERWIDTH-1:0]<=#Tp ReadPointer[`TRACECOUNTERWIDTH-1:0] + 1;
  else
  if(ContinMode & IncrementPointer & (BufferFull | BufferFullDetected))
    ReadPointer[`TRACECOUNTERWIDTH-1:0]<=#Tp WritePointer[`TRACECOUNTERWIDTH-1:0] + 1;
end

always @(posedge Mclk)
begin
  if(~TraceEnable)
    BufferFullDetected<=#Tp 0;
  else
  if(ContinMode & BufferFull)
    BufferFullDetected<=#Tp 1;
end


always @(posedge Mclk or posedge Reset)
begin
  if(Reset)
    RiscStall<=#Tp 0;
  else
  if(SyncResetCpuStall)
    RiscStall<=#Tp 0;
  else
  if(SyncSetCpuStall)
    RiscStall<=#Tp 1;
end


always @(posedge Mclk)
begin
  if(ResetStallCounter)
    StallCounter<=#Tp 0;
  else
  if(RiscStall_q & (~BufferFull | ContinMode))
    StallCounter<=#Tp StallCounter+1;
end

assign ResetStallCounter = StallCounter==(`OPSELECTIONCOUNTER-1) & ~BufferFull | Reset;


/**********************************************************************************
*                                                                                 *
*   Valid status                                                                  *
*                                                                                 *
**********************************************************************************/
wire Valid = ~BufferEmpty;


/**********************************************************************************
*                                                                                 *
*   Writing and reading the sample to/from the buffer                             *
*                                                                                 *
**********************************************************************************/
always @ (posedge Mclk)
begin
  if(WriteSample)
    Buffer[WritePointer[`TRACECOUNTERWIDTH-1:0]]<={DataIn, 1'b0, OpSelect[`OPSELECTWIDTH-1:0]};
end

assign TraceChain = {Buffer[ReadPointer], 3'h0, Valid};
  


/**********************************************************************************
*                                                                                 *
*   Operation select (to select which kind of data appears on the DATAIN lines)   *
*                                                                                 *
**********************************************************************************/
assign OpSelect[`OPSELECTWIDTH-1:0] = StallCounter[`OPSELECTWIDTH-1:0];



/**********************************************************************************
*                                                                                 *
*   Selecting which parts are going to be recorded as part of the sample          *
*                                                                                 *
**********************************************************************************/
assign RecEnable = {1'b0, RecordINSTR,  RecordWriteSPR,  RecordReadSPR,  RecordSDATA,  RecordLDATA,  RecordLSEA,  RecordPC};


endmodule
