//********************************************************************************************************
// Syncronizer and voter
// Version 0.3
// Modified 05.08.12
//********************************************************************************************************


module rc_sync_voter #(
                       parameter USE_RST  = 1,
		       parameter SYNC_RST = 0
		       ) 
                (
                input  wire  nrst,
		input  wire  clk,
		input  wire  en,
		input  wire  rxd,
		output wire  fe_det,
		output wire  re_det,
		output wire  rfe_det,
		output wire  dout  
                );

//********************************************************************************************************
		
reg[2:0]  sh_rg_current;		
wire[2:0] sh_rg_next;		
wire      rxd_clk;	

//********************************************************************************************************
	
             rsnc_cfg_vlog #(
	                     .P_ADD_STGS_NUM  ( 0    ), 
	                     .P_RST_ACT_HIGH  ( 0    ), // nrst is active high
			     .P_SYNC_RST      ( 0    ), // nrst is SYNCHRONOUS reset input
			     .P_NO_RST	      ( 0    ), // nrst is not used (no reset)
			     .P_RST_VAL       ( 1'b1 )  // Values of resynch FFs after reset
		             )
	 rsnc_cfg_vlog_inst   (	                   
			     .clk  (clk),
		             .nrst (nrst),
                             .din  (rxd),
                             .dout (rxd_clk)
                             );	
	
		
assign sh_rg_next[2:0] = (en) ? {sh_rg_current[1:0],rxd_clk} : sh_rg_current;


 always @(posedge clk or negedge nrst)
   begin: sh_seq
      if (!nrst)		// Reset 
      begin
       sh_rg_current <= {3{1'b1}};  
      end
      else 		// Clock 
      begin
       sh_rg_current <= sh_rg_next;
      end
   end // sh_seq

		
// Voter
 assign dout = (sh_rg_current[0] & sh_rg_current[1]) | 
               (sh_rg_current[0] & sh_rg_current[2]) | 
	       (sh_rg_current[1] & sh_rg_current[2]);

// Edge detectors
 assign fe_det  = ~sh_rg_current[1] &  sh_rg_current[2]; 		
 assign re_det  =  sh_rg_current[1] & ~sh_rg_current[2]; 	
 assign rfe_det =  sh_rg_current[1] ^  sh_rg_current[2]; 	
		
endmodule // rc_sync_voter		
