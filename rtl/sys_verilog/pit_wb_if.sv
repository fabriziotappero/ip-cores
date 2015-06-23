////////////////////////////////////////////////////////////////////////////////
//
//  WISHBONE revB.2 compliant -- Wishbone Bus interface
//
//  Author: Bob Hayes
//          rehayes@opencores.org
//
//  Downloaded from: http://www.opencores.org/projects/pit.....
//
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2011, Robert Hayes
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY Robert Hayes ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL Robert Hayes BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
////////////////////////////////////////////////////////////////////////////////
// 45678901234567890123456789012345678901234567890123456789012345678901234567890

// The signal names lose their "_i", "_o" postfix since that is relative to
//  their usage in a specific instance declaration.

interface wishbone_if #(parameter D_WIDTH = 16,
                        parameter A_WIDTH = 3,
                        parameter S_WIDTH = 2)

  // These signals are connected in the top-most instance instantation
  (input logic          wb_clk,     // master clock input
   input logic          arst,       // asynchronous reset
   input logic          wb_rst);    // synchronous active high reset

   // These signals are hierarchal to the instance instantation and bridge
   //   between all the modules that use the same top-most instantiation.
   // These signals may change direction based on interface usage
   logic [D_WIDTH-1:0] wb_dat;      // databus
   logic [A_WIDTH-1:0] wb_adr;      // address bits
   logic               wb_we;       // write enable input
   logic               wb_cyc;      // valid bus cycle input
   logic [S_WIDTH-1:0] wb_sel;      // Select bytes in word bus transaction
  
  // Define the signal directions when the interface is used as a slave
  modport slave (input   wb_clk,
                         arst,
                         wb_rst,
                         wb_adr,
                         wb_we,
                         wb_cyc,
                         wb_sel,
                         wb_dat);

  // define the signal directions when the interface is used as a master
  modport master (output wb_adr,
                         wb_we,
                         wb_cyc,
                         wb_sel,
                         wb_dat,
                  input  wb_clk,
                         arst,
                         wb_rst);

endinterface  // wishbone_if  
