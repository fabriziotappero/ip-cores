module rx_shift_reg #(
		     parameter SYNC_RST = 1,
		     parameter SH_LEN   = 8 + 1 + 1
		     ) 
                     (
                     input  wire              nrst,
		     input  wire              clk,
		     input  wire              en,
		     input  wire              rxd,
		     output wire[SH_LEN-1:0]  data_o
                     );

		
reg[SH_LEN-1:0]  sh_rg_current;		
wire[SH_LEN-1:0] sh_rg_next;		
		
// assign sh_rg_next[SH_LEN-1:0] = (en) ? {sh_rg_next[SH_LEN-2:0],rxd} : sh_rg_current;

assign sh_rg_next[SH_LEN-1:0] = (en) ? {rxd,sh_rg_current[SH_LEN-1:1]} : sh_rg_current;

 always @(posedge clk or negedge nrst)
   begin: sh_seq
      if (!nrst)		// Reset 
      begin
       sh_rg_current <= {SH_LEN{1'b0}};  
      end
      else 		// Clock 
      begin
       sh_rg_current <= sh_rg_next;
      end
   end // sh_seq
		
assign data_o = sh_rg_current;		
		
endmodule // rx_shift_reg		
