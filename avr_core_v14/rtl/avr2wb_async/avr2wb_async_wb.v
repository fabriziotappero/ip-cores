//*************************************************************************************************************
// AVR bus to Wishbone bridge
//
// Version 0.2
// Modified 13.06.12
// Written by Ruslan Lepetenok (lepetenokr@yahoo.com)
// `include" replaced with `include " to avoid error in VCS 
//*************************************************************************************************************

`ifndef C_DIS_DEFAULT_NETTYPE
 // All nets must be declared
 `default_nettype none
`endif

// synopsys translate_off
`include"timescale.vh"
// synopsys translate_on

module avr2wb_async_wb #(
	                        parameter P_WB_DATA_WIDTH    = 32, /* 32/64/128 ??? */
                            parameter P_WB_DEL_CNT_WIDTH = 4 
					        )
	                       (
	                          // WISHBONE master interface
                          input wire                            rst_i,
                          input wire                            clk_i,

                          output wire[31:0]                     adr_o,
                          input  wire[(P_WB_DATA_WIDTH-1):0]    dat_i,
                          output wire[(P_WB_DATA_WIDTH-1):0]    dat_o,
                          output wire                           we_o,

                          output wire                           stb_o,
                          output wire                           cyc_o,
                          input wire                            ack_i,
                          input wire                            err_i,
                          input wire                            rty_i,
    
                          output wire                           lock_o,
                          output wire[(P_WB_DATA_WIDTH/8-1):0]  sel_o, // Byte enables
                          output wire[2:0]                      cti_o,
	                      output wire[1:0]                      bte_o, // Burst type
						  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						  input wire[31:0]                     wb_adr,
						  input wire[31:0]                     wb_wdata,
                          input wire[3:0]                      wb_be,							 
						  output wire[31:0]                    wb_rdata,
						  input wire                           wb_read,
						  input wire                           wb_write,
                          output wire                          wb_done,
                          output wire                          wb_error							 
                          );

wire latch_adr_wdata;						  
wire latch_rdata;

reg wb_read_rg_current;
reg wb_read_rg_next;
reg wb_write_rg_current;
reg wb_write_rg_next;

wire start_read;
wire start_write;

reg wb_done_current;
reg wb_done_next;

localparam lp_sm_st_idle   = 3'h0,
           lp_sm_st_wr     = 3'h1,
           lp_sm_st_rd     = 3'h2,
           lp_sm_st_wr_rty = 3'h3,
           lp_sm_st_rd_rty = 3'h4;

reg[3:0] wb_sm_st_current;		   
reg[3:0] wb_sm_st_next;

reg stb_o_current;
reg stb_o_next;

reg cyc_o_current;
reg cyc_o_next;

reg we_o_current;
reg we_o_next;   

reg[(P_WB_DEL_CNT_WIDTH-1):0] wb_done_del_cnt_current;
reg[(P_WB_DEL_CNT_WIDTH-1):0] wb_done_del_cnt_next;

reg wb_error_current;
reg wb_error_next;	

//****************************************************************************************************

always@(*) begin : main_comb
 //------ Latch avoidance -----------
 wb_read_rg_next  = wb_read;
 wb_write_rg_next = wb_write;
 wb_sm_st_next = wb_sm_st_current;
 stb_o_next    = 1'b0;
 cyc_o_next	   = 1'b0;
 we_o_next     = 1'b0;
 wb_done_next  =  wb_done_current;
 
 wb_done_del_cnt_next = wb_done_del_cnt_current;
 
 wb_error_next     = wb_error_current;
 //------ Latch avoidance ----------- 
 
 if(rst_i) begin : reset_active	
  wb_read_rg_next       = 1'b0; 
  wb_write_rg_next      = 1'b0;	
  wb_sm_st_next        = lp_sm_st_idle;
  stb_o_next           = 1'b0;
  cyc_o_next           = 1'b0;
  we_o_next            = 1'b0;
  wb_done_next         = 1'b0;
  wb_done_del_cnt_next = {P_WB_DEL_CNT_WIDTH{1'b0}};
  wb_error_next        = 1'b0;
 end // reset_active	 
 else begin : reset_not_active       
 
 case(wb_sm_st_current)
  lp_sm_st_idle   : 
   begin 
    if(start_read) wb_sm_st_next = lp_sm_st_rd; 
    else 
	 if(start_write) 
	  wb_sm_st_next = lp_sm_st_wr; 
	end 
  lp_sm_st_wr     :	
   begin
	if(ack_i || err_i) wb_sm_st_next = lp_sm_st_idle;  
	else if(rty_i) wb_sm_st_next = lp_sm_st_wr_rty;
   end	   
  lp_sm_st_rd     :
   begin
	if(ack_i || err_i) wb_sm_st_next = lp_sm_st_idle;  
	else if(rty_i) wb_sm_st_next = lp_sm_st_rd_rty;
   end	  
  lp_sm_st_wr_rty : wb_sm_st_next = lp_sm_st_wr;
  lp_sm_st_rd_rty : wb_sm_st_next = lp_sm_st_rd;
  default		  : wb_sm_st_next = lp_sm_st_idle;
 endcase	 

 if(wb_sm_st_next == lp_sm_st_wr || wb_sm_st_next == lp_sm_st_rd) stb_o_next = 1'b1;
 if(wb_sm_st_next == lp_sm_st_wr || wb_sm_st_next == lp_sm_st_rd) cyc_o_next = 1'b1;
 if(wb_sm_st_next == lp_sm_st_wr) we_o_next     = 1'b1; 
 
 if(wb_done_current)	 
  wb_done_del_cnt_next = wb_done_del_cnt_current + 1;	 
  
 case(wb_done_current)  
  1'b0    : if((wb_sm_st_current == lp_sm_st_rd || wb_sm_st_current == lp_sm_st_wr) && (ack_i || err_i)) wb_done_next = 1'b1;
  1'b1    :	if(&wb_done_del_cnt_current) wb_done_next = 1'b0;
  default : wb_done_next = 1'b0;
 endcase 
 
  // Error flag 
  if(latch_rdata) 
   wb_error_next = err_i;

 end // reset_not_active  
   
end // main_comb	

assign start_read  = wb_read  & ~wb_read_rg_current;
assign start_write = wb_write & ~wb_write_rg_current;

assign latch_adr_wdata = ((start_read || start_write) && wb_sm_st_current == lp_sm_st_idle) ? 1'b1 : 1'b0;
assign latch_rdata     = (wb_sm_st_current == lp_sm_st_rd && (ack_i || err_i)) ? 1'b1 : 1'b0;    

always@(posedge clk_i) begin : main_seq
  wb_read_rg_current      <= wb_read_rg_next;
  wb_write_rg_current     <= wb_write_rg_next;
  wb_sm_st_current        <= wb_sm_st_next;
  stb_o_current           <= stb_o_next;
  cyc_o_current           <= cyc_o_next;
  we_o_current            <= we_o_next;  
  wb_done_current         <= wb_done_next; 
  wb_done_del_cnt_current <= wb_done_del_cnt_next;
  wb_error_current        <= wb_error_next;
end // main_seq 	 

assign stb_o = stb_o_current;
assign cyc_o = cyc_o_current;
assign we_o  = we_o_current; 
assign lock_o = 1'b0;
assign cti_o = {3{1'b0}}; 
assign bte_o = {2{1'b0}};

assign wb_done  = wb_done_current;
assign wb_error = wb_error_current;

rg_md #(
	                   .p_width     (32),
                       .p_init_val  ({32{1'b0}}),
					   .p_impl_mask ({32{1'b1}}),
					   .p_sync_rst  (1))   
	 rg_md_adr_inst    (
					   .clk         (clk_i),
					   .nrst        (~rst_i),
					   .wdata       (wb_adr),					   
					   .wbe         ({4{latch_adr_wdata}}),
					   .rdata       (adr_o)
					   );							  
					   
rg_md #(
	                   .p_width     (32),
                       .p_init_val  ({32{1'b0}}),
					   .p_impl_mask ({32{1'b1}}),
					   .p_sync_rst  (1))   
	 rg_md_wdata_inst    (
					   .clk         (clk_i),
					   .nrst        (~rst_i),
					   .wdata       (wb_wdata),					   
					   .wbe         ({4{latch_adr_wdata}}),
					   .rdata       (dat_o)
					   );							  					   
					   

rg_md #(
	                   .p_width     (4),
                       .p_init_val  ({4{1'b0}}),
					   .p_impl_mask ({4{1'b1}}),
					   .p_sync_rst  (1))   
	 rg_md_be_inst    (
					   .clk         (clk_i),
					   .nrst        (~rst_i),
					   .wdata       (wb_be),					   
					   .wbe         (latch_adr_wdata),
					   .rdata       (sel_o)
					   );							  					   					   


					   
rg_md #(
	                   .p_width     (32),
                       .p_init_val  ({32{1'b0}}),
					   .p_impl_mask ({32{1'b1}}),
					   .p_sync_rst  (1))   
	 rg_md_rdata_inst    (
					   .clk         (clk_i),
					   .nrst        (~rst_i),
					   .wdata       (dat_i),					   
					   .wbe         ({4{latch_rdata}}),
					   .rdata       (wb_rdata)
					   );							  					   					   
					   
					   
endmodule // avr2wb_async_wb
