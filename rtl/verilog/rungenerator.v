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
module rungenerator #(parameter N_BITS=8)
    (
    input   clk,
    input   rst,
    input   start_i,
    input   all_sorted_i,
    output  run_o
    );

    reg [N_BITS+4-1:0]  r_count;
    reg     r_job_done;
    
    wire    w_ready_to_stop;
    wire    w_next_bit;
    
    always @(posedge clk)
        begin
            if (rst) begin
                r_count <= {{N_BITS{1'd0}},4'b0000};             end
            else if(start_i) begin
                r_count <= {{N_BITS{1'd1}},4'b0000};             end
            else  begin
                r_count <= {r_count[N_BITS+4-2:0],w_next_bit};   end
        end
        
    always @(posedge clk)
        begin
            if (rst) begin
                r_job_done <= 1'b1;          end
            else if (all_sorted_i) begin
                r_job_done <= 1'b1;          end            
            else if (start_i) begin
                r_job_done <= 1'b0;          end            
        end
    
    assign w_ready_to_stop = ~r_count[0];
    assign w_next_bit = (r_job_done & w_ready_to_stop) ? 1'b0 : r_count[N_BITS+4-1];
    
    assign run_o = r_count[0];
    
endmodule
