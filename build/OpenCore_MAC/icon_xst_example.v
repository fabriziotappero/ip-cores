//-----------------------------------------------------------------------------
// Copyright (c) 1999-2006 Xilinx Inc.  All rights reserved.
//-----------------------------------------------------------------------------
// Title      : ICON Core Xilinx XST Usage Example
// Project    : ChipScope
//-----------------------------------------------------------------------------
// File       : icon_xst_example.v
// Company    : Xilinx Inc.
// Created    : 2002/03/27
//-----------------------------------------------------------------------------
// Description: Example of how to instantiate the ICON core in a Verilog 
//              design for use with the Xilinx XST synthesis tool.
//-----------------------------------------------------------------------------

module icon_xst_example
  (
  );


  //-----------------------------------------------------------------
  //
  //  ICON core wire declarations
  //
  //-----------------------------------------------------------------
  wire [35:0] control0;
  wire [35:0] control1;


  //-----------------------------------------------------------------
  //
  //  ICON core instance
  //
  //-----------------------------------------------------------------
  icon i_icon
    (
      .control0(control0),
      .control1(control1)
    );


endmodule


//-------------------------------------------------------------------
//
//  ICON core module declaration
//
//-------------------------------------------------------------------
module icon 
  (
      control0,
      control1
  );
  output [35:0] control0;
  output [35:0] control1;
endmodule
