//**********************************************************************************************
// Power on reset generator for the AVR Core
// Version 0.4
// Modified 27.11.2008
// Designed by Ruslan Lepetenok
// Verilog version was modified 21.10.12 -> (lpm_ff wrapper for Quartus was added) 
//**********************************************************************************************

`timescale 1 ns / 1 ns

module por_rst_gen #(parameter  tech = 0) 
  (
   input wire  clk,
   input wire  por_n_i,
   output wire por_n_o,
   output wire por_n_o_g
  );


`include "tech_def_pack.vh"
   
   localparam  c_xilinx_used = tech == c_tech_virtex    | 
                               tech == c_tech_virtex_e  | 
			       tech == c_tech_virtex_ii | 
			       tech == c_tech_virtex_4  | 
			       tech == c_tech_virtex_5  | 
			       tech == c_tech_spartan_3;
			      
   localparam c_altera_used = c_tech_acex; 			      
			      
   
   wire [2:0]  rst_chain_current;
   wire [2:0]  rst_chain_next;
   wire        vcc;
   wire        gnd;
   
   assign vcc = 1'b1;
   assign gnd = 1'b0;
   
   assign rst_chain_next = {rst_chain_current[2 - 1:0], vcc};
   
   // Generic
   generate
      if (!c_xilinx_used && !c_altera_used)
      begin : impl_gen
/*         
         always @(negedge por_n_i or posedge clk)
         begin: reset_dffs
            if (!por_n_i)		// Reset
               rst_chain_current <= {3{1'b0}};
            else 		// Clock
               rst_chain_current <= rst_chain_next;
         end
*/         
      end
   endgenerate
   
   // impl_gen 

localparam LP_FOR_SIM = 0 /* pragma translate_off */ + 1  /* pragma translate_on */;
   
   // Xilinx
   generate
      if (c_xilinx_used)
      begin : impl_xilinx
               
               FDC #(.INIT(1'b0)) 
	       FDC_inst[2:0](
                        .Q   (rst_chain_current[2:0]),
                        .C   (clk),
                        .CLR (~por_n_i),
                        .D   (rst_chain_next[2:0])
                        );
      end    // impl_xilinx 
      
      else begin : not_xilinx
      if(c_altera_used) begin : impl_altera 
       if(LP_FOR_SIM) begin : altera_for_sim
        dff dff_inst[2:0] (
	                   .d    (rst_chain_next[2:0]), 
			   .clk  (clk), 
			   .clrn (por_n_i), 
			   .prn  (gnd), 
			   .q    (rst_chain_current[2:0]) 
			   );
       end // altera_for_sim
       else begin : altera_for_synth  

/*lpm_ff lpm_ff_inst[2:0]*/ 
altera_lpm_ff_wrp altera_lpm_ff_wrp_inst[2:0] ( 
                          .q      (rst_chain_current[2:0]), 
                          .data   (rst_chain_next[2:0]), 
			  .clock  (clk), 
			  .enable (vcc), 
			  .aclr   (~por_n_i), 
                          .aset   (gnd),
		          .sclr   (gnd), 
			  .sset   (gnd), 
			  .aload  (gnd), 
			  .sload  (gnd) 
			  ); 
        end // : altera_for_synth
 
      end // impl_altera
      end // impl_xilinx
      
   endgenerate
 
   
   // Reset outputs
   assign por_n_o   = rst_chain_current[2];
   assign por_n_o_g = rst_chain_current[2];
   
endmodule // por_rst_gen
