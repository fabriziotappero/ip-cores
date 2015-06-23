// `include" was replaced by `include " (space was inserted) to avoid 
// error during compilation in VCS


`ifndef C_DIS_DEFAULT_NETTYPE
 // All nets must be declared
 `default_nettype none
`endif

// TBD 
// pragma translate_off
`timescale 1 ns / 10 ps
// pragma translate_on

module rg_md #(
	                   parameter              p_width     = 32,   
                       parameter[p_width-1:0] p_init_val  = {p_width{1'b0}},
					   parameter[p_width-1:0] p_impl_mask = {p_width{1'b1}},
					   parameter              p_sync_rst  = 0,   
					   //
					   parameter              p_be_width  = (p_width%8) ? (p_width/8 + 1) : (p_width/8)	
					   )
	                  (
					   input wire            clk,
					   input wire            nrst,
					   input wire[p_width-1:0]    wdata,					   
					   input wire[p_be_width-1:0] wbe,
					   output wire[p_width-1:0]   rdata					   					   
					  );
					  
				  
// reg[31:0] rg_current;					  
// reg[31:0] rg_next;					  
reg[p_width-1:0] rg_current;					  
reg[p_width-1:0] rg_next;

//********************************************************************************************
generate
genvar i;
 for(i=0;i<p_width;i=i+1) begin : main_gen_block
  if(p_impl_mask[i] != 1'b0) begin : bit_is_implemented	
	  
   if(p_sync_rst    != 0) begin : sync_rst_imp

   always@(posedge clk) begin : main_alw_seq
     begin : main_alw_seq_clk
      rg_current[i] <= rg_next[i];	// Modified 27.11.09
     end // main_alw_seq_clk
    end	// main_alw_seq	   	   
	
    always@* begin : main_alw_comb
     if(!nrst) begin
	   rg_next[i] = p_init_val[i];
	  end
	 else begin 
     rg_next[i] = rg_current[i];
     if(wbe[i/8]) begin
       rg_next[i] = wdata[i]; 	 
      end
	end 
    end // main_alw_comb		
	
    end // sync_rst_imp
   else begin : async_rst_imp
	   
   always@(posedge clk or negedge nrst) begin : main_alw_seq
    if(!nrst) begin	: main_alw_seq_rst
      rg_current[i] <= p_init_val[i]; 	
     end // main_alw_seq_rst
    else begin	: main_alw_seq_clk
     rg_current[i] <= rg_next[i];	
     end // main_alw_seq_clk
    end	// main_alw_seq	   
	
    always@* begin : main_alw_comb
     rg_next[i] = rg_current[i];
     if(wbe[i/8]) begin
       rg_next[i] = wdata[i]; 	 
      end
    end // main_alw_comb	
	
	end // async_rst_imp  
   end // bit_is_implemented	  
   
 else begin : bit_is_not_implemented
	 
   always@* begin : unused_bits
	rg_next[i]    =  rg_current[i]; // Avoid "x" TBD
    rg_current[i] = p_init_val[i];
    rg_next[i]    = 1'b0;
   end // unused_bits
   
  end // bit_is_not_implemented	  
 end // main_gen_block	
endgenerate
//********************************************************************************************

assign rdata = rg_current;

endmodule // rg_md
