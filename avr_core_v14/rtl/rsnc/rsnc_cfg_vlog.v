//*******************************************************************************************
//
// 
//*******************************************************************************************

`ifndef C_DIS_DEFAULT_NETTYPE
 // All nets must be declared
 `default_nettype none
`endif

// pragma translate_off
//`include"timescale.vh"
// pragma translate_on

module rsnc_cfg_vlog #(
	                     parameter P_ADD_STGS_NUM  = 0, 
	                     parameter P_RST_ACT_HIGH  = 0, // nrst is active high
			     parameter P_SYNC_RST      = 0, // nrst is SYNCHRONOUS reset input
			     parameter P_NO_RST        = 0, // nrst is not used (no reset)
			     parameter P_RST_VAL       = 0  // Values of resynch FFs after reset
		             )
		            (	                   
			     input  wire clk,
		             input  wire nrst,
                             input  wire din,
                             output wire dout
                             );

//*****************************************************************************************							

reg[P_ADD_STGS_NUM+1:0] rsnc_rg_current;
reg[P_ADD_STGS_NUM+1:0] rsnc_rg_next;

wire nrst_int;

localparam LP_RST_VAL = (P_RST_VAL) ? 1'b1 : 1'b0;

//*****************************************************************************************

assign nrst_int =  (P_RST_ACT_HIGH)?  ~nrst : nrst;


always@(*)
 begin : shift_comb	
  rsnc_rg_next[0] = din;	
  rsnc_rg_next[P_ADD_STGS_NUM+1:1] = rsnc_rg_current[P_ADD_STGS_NUM+1-1:1-1];
  
  if(!P_NO_RST && !P_SYNC_RST) begin
   if(!nrst_int) rsnc_rg_next[P_ADD_STGS_NUM+1:0] = {(P_ADD_STGS_NUM+2){LP_RST_VAL}};  
  end 
 end // shift_comb	 
 
  
 generate 
 if(!P_SYNC_RST) begin : impl_async_rst  			
  always@(negedge nrst_int or posedge clk) begin
   if(!nrst_int)
    rsnc_rg_current[P_ADD_STGS_NUM+1:0] <= {(P_ADD_STGS_NUM+2){LP_RST_VAL}};	  
   else	  
    rsnc_rg_current[P_ADD_STGS_NUM+1:0] <= rsnc_rg_next[P_ADD_STGS_NUM+1:0];
  end 
  end // impl_async_rst
 else begin : no_async_rst 
  always@(posedge clk) begin
    rsnc_rg_current[P_ADD_STGS_NUM+1:0] <= rsnc_rg_next[P_ADD_STGS_NUM+1:0];
   end 
 end // no_async_rst
 endgenerate 
  
 assign dout = rsnc_rg_current[P_ADD_STGS_NUM+1];
 
endmodule // rsnc_cfg_vlog