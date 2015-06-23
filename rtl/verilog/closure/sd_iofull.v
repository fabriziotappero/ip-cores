//----------------------------------------------------------------------
// Srdy/Drdy input/output block
//
// Halts timing on all signals with efficiency of 1.0.  Note that this
// block is simply a combination of sd_input and sd_output.
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

module sd_iofull
  #(parameter width = 8)
  (
   input              clk,
   input              reset,
   input              c_srdy,
   output             c_drdy,
   input [width-1:0]  c_data,

   output             p_srdy,
   input              p_drdy,
   output [width-1:0] p_data
   );

  wire 		      i_irdy, i_drdy;
  wire [width-1:0]    i_data;

  sd_input #(width) in
    (
     .c_drdy				(c_drdy),
     .ip_srdy				(i_srdy),
     .ip_data				(i_data),
     .clk				(clk),
     .reset				(reset),
     .c_srdy				(c_srdy),
     .c_data				(c_data),
     .ip_drdy				(i_drdy));

  sd_output #(width) out
    (
     .ic_drdy				(i_drdy),
     .p_srdy				(p_srdy),
     .p_data				(p_data),
     .clk				(clk),
     .reset				(reset),
     .ic_srdy				(i_srdy),
     .ic_data				(i_data),
     .p_drdy				(p_drdy));

endmodule