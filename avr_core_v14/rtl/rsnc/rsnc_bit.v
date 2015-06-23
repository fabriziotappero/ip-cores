// `include" was replaced by `include " (space was inserted) to avoid 
// error during compilation in VCS

`ifndef C_DIS_DEFAULT_NETTYPE
 // All nets must be declared
 `default_nettype none
`endif

// TBD 
// synopsys translate_off
`include "/../../dummy_ahb_slv/timescale.h"
// synopsys translate_on

module rsnc_bit #(
	              parameter add_stgs_num = 0,
                  parameter inv_f_stgs   = 0
				  )
		          (	                   
                  input  wire clk,
                  input  wire di,
                  output wire	do
                  );

							



reg[add_stgs_num+1:0] rsnc_rg_current;
reg[add_stgs_num+1:0] rsnc_rg_next;

always@(*)
 begin : shift_comb	
  rsnc_rg_next[0] = di;	
  rsnc_rg_next[add_stgs_num+1:1] = rsnc_rg_current[add_stgs_num+1-1:1-1]; 
 end // shift_comb	 
 
 generate
  if(inv_f_stgs == 0) begin : normal_first_stage
   always@(posedge clk)        
    rsnc_rg_current[0] <= rsnc_rg_next[0];
  end
 endgenerate
 
 generate
  if(inv_f_stgs != 0) begin : inverted_first_stage
   always@(negedge clk)        
    rsnc_rg_current[0] <= rsnc_rg_next[0];
  end
 endgenerate
  			
 always@(posedge clk)
  rsnc_rg_current[add_stgs_num+1:1] <= rsnc_rg_next[add_stgs_num+1:1];
  
 assign do = rsnc_rg_current[add_stgs_num+1];
  
 endmodule // rsnc_bit
