//////////////////////////////////////////////////////////////////////
////
//// Copyright (C) 2014 avram ionut, avramionut@opencores.org
////
//// This source file may be used and distributed without
//// restriction provided that this copyright statement is not
//// removed from the file and that any derivative work contains
//// the original copyright notice and the associated disclaimer.
////
//// This source file is free software; you can redistribute it
//// and/or modify it under the terms of the GNU Lesser General
//// Public License as published by the Free Software Foundation;
//// either version 2.1 of the License, or (at your option) any
//// later version.
////
//// This source is distributed in the hope that it will be
//// useful, but WITHOUT ANY WARRANTY; without even the implied
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
//// PURPOSE. See the GNU Lesser General Public License for more
//// details.
////
//// You should have received a copy of the GNU Lesser General
//// Public License along with this source; if not, download it
//// from http://www.opencores.org/lgpl.shtml
////
//
// Revisions: 
// Revision 0.01 - File Created
// Additional Comments: 
//                     
//
//////////////////////////////////////////////////////////////////////////////////
module stageen #(parameter N_BITS=8)
(
    input   clk,
    input   load,
    input  [N_BITS-1:0] data_i,
    output [N_BITS-1:0] data_o,
    input   swap_i,
    output  swap_o,
    input   run_i,
    input   run_late_i,
    output  run_o,
    input   bit_i,
    output  bit_o,
    input   value_i,
    output  value_o
    );

    reg[N_BITS-1:0]    r_data;
    
    wire    w_large_bit;
    wire    w_small_bit;
    wire    w_swap_o;
    wire    w_run_o;
    
    always @(posedge clk)
        begin
            if (load) begin
                r_data <= data_i;                        end
            else if (run_i | run_late_i) begin
                r_data <= {r_data[N_BITS-2:0],value_i};  end
        end
        
    bitsplit split_module (
        .clk(clk),
        .bit1_i(bit_i),
        .bit2_i(r_data[N_BITS-1]),
        .largebit_o(w_large_bit),
        .smallbit_o(w_small_bit),
        .swap_i(swap_i),
        .swap_o(w_swap_o),
        .run_i(run_i),
        .run_o(w_run_o)
        );
    
    assign data_o = r_data;
    assign swap_o = w_swap_o;
    assign run_o = w_run_o;
    assign bit_o = w_large_bit;
    assign value_o = w_small_bit;
    
endmodule
