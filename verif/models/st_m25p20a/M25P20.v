// Author: Mehdi SEBBANE
// May 2002
// Verilog model
// project: M25P20 25 MHz,
// release: 1.4.1



// These Verilog HDL models are provided "as is" without warranty
// of any kind, included but not limited to, implied warranty
// of merchantability and fitness for a particular purpose.





`timescale 1ns/1ns
`ifdef SFLASH_SPDUP
`include "parameter_fast.v"
`else
`include "parameter.v"
`endif
 
module m25p20(c,data_in,s,w,hold,data_out);
   input c;
   input data_in;
   input s;
   input w;
   input hold;
   
   output data_out;
   ///reg data_out;

   wire [(`NB_BIT_ADD_MEM-1):0] adresse; 
   wire [(`NB_BIT_DATA-1):0] dtr; 
   wire [(`NB_BIT_DATA-1):0] data_to_write; 
   wire [(`LSB_TO_CODE_PAGE-1):0] page_index;
   
   wire wr_op; 
   wire rd_op; 
   wire s_en; 
   wire b_en; 
   wire add_pp_en; 
   wire pp_en; 
   wire r_en; 
   wire d_req; 
   wire clck; 
   
   assign clck = c ; 


   memory_access  mem_access(adresse, b_en, s_en, add_pp_en, pp_en, r_en, d_req, data_to_write, page_index, dtr); 

   acdc_check  acdc_watch(clck, data_in, s, hold, wr_op, rd_op); 
   
   internal_logic  spi_decoder(clck, data_in, w, s, hold, dtr, data_out, data_to_write, page_index, adresse, wr_op, rd_op, b_en, s_en, add_pp_en, pp_en, r_en, d_req); 
   
endmodule
