module tx_shift_reg #(
		     parameter SYNC_RST = 1,
		     parameter DATA_LEN   = 8 + 1 + 1
		     ) 
                     (
                     input  wire               nrst,
		     input  wire               clk,
		     input  wire               en,
		     input  wire               load,   
		     input  wire[DATA_LEN-1:0] data_i,
		     output wire               txd
                     );


localparam LP_REG_LEN = DATA_LEN + 1;
		
reg[LP_REG_LEN-1:0] sh_rg_current;		
reg[LP_REG_LEN-1:0] sh_rg_next;		
		

always@*
 begin
   sh_rg_next = sh_rg_current; 
   if(load) begin
    sh_rg_next = {data_i,1'b0};
   end
   else if(en) begin
    sh_rg_next = {1'b1,sh_rg_current[LP_REG_LEN-1:1]};   
   end

  // Async reset
  if(SYNC_RST) begin 
   if(nrst) sh_rg_next = {{(LP_REG_LEN-1){1'b0}},1'b1};
  end 
  
 end

 always @(posedge clk or negedge nrst)
   begin: sh_seq
      if (!nrst)		// Reset 
      begin
       sh_rg_current <= {{(LP_REG_LEN-1){1'b0}},1'b1};  
      end
      else 		// Clock 
      begin
       sh_rg_current <= sh_rg_next;
      end
   end // sh_seq
		
assign txd = sh_rg_current[0];		
		
endmodule // tx_shift_reg		
