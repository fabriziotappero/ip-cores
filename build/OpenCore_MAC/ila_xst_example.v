//-----------------------------------------------------------------------------
// Copyright (c) 1999-2006 Xilinx Inc.  All rights reserved.
//-----------------------------------------------------------------------------
// Title      : ILA Core Xilinx XST Usage Example
// Project    : ChipScope
//-----------------------------------------------------------------------------
// File       : ila_xst_example.v
// Company    : Xilinx Inc.
// Created    : 2002/03/27
//-----------------------------------------------------------------------------
// Description: Example of how to instantiate the ILA core in a Verilog 
//              design for use with the Xilinx XST synthesis tool.
//-----------------------------------------------------------------------------

module ila_xst_example
  (
  );


  //-----------------------------------------------------------------
  //
  //  ILA Core wire declarations
  //
  //-----------------------------------------------------------------
  wire [35:0] control;
  wire clk;
  wire [63:0] data;
  wire [0:0] trig0;
  wire [0:0] trig1;
  wire [0:0] trig2;


  //-----------------------------------------------------------------
  //
  //  ILA core instance
  //
  //-----------------------------------------------------------------
  ila i_ila
    (
      .control(control),
      .clk(clk),
      .data(data),
      .trig0(trig0),
      .trig1(trig1),
      .trig2(trig2)
    );


endmodule


//-------------------------------------------------------------------
//
//  ILA core module declaration
//
//-------------------------------------------------------------------
module ila
  (
    control,
    clk,
    data,
    trig0,
    trig1,
    trig2
  );
  input [35:0] control;
  input clk;
  input [63:0] data;
  input [0:0] trig0;
  input [0:0] trig1;
  input [0:0] trig2;
endmodule

