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
`include "timescale.vh"
// synopsys translate_on


module avr2wb_async_avr #(
	                  parameter         P_IO_LOC    = 0
	                  )
	                  (
	                   // AVR DM i/f
                           //    Clock and reset
                           input wire			      ireset,	
                           input wire			      cp2,		
                           // DM i/f (Slave part)
                           input wire			      sel,
                           input wire[8:0]		      ramadr, 
                           input wire			      ramre,        
                           input wire			      ramwe,        
                           input wire[7:0]		      dbus_in,
                           output wire[7:0]		      dbus_out,						
		           output wire                        dm_wait,
			   output wire			      dm_out_en,
			   // Address/Control/Status registers
			   input wire[7:0] 		      out_regs,
			   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			   output wire[7:0]		      wb_adr,
			   output wire[31:0]		      wb_wdata,
			   input wire[31:0]		      wb_rdata,
			   output wire			      wb_read,
			   output wire			      wb_write,
                           input wire                         wb_done
	                   );
//***************************************************************************************************
wire wb_data_0_7_rg_we;
wire wb_data_8_15_rg_we;
wire wb_data_16_23_rg_we;
wire wb_data_24_31_rg_we;

wire[31:0] wb_rdata_rg;
reg[7:0]  rd_mux;

wire latch_rdata;  

reg wb_read_current;
reg wb_read_next;
reg wb_write_current;
reg wb_write_next;			 

reg wb_done_rg_current;

wire wb_done_re;
wire wb_done_fe;

// State machine
localparam lp_sm_st_idle    = 2'h0,
           lp_sm_st_wr_wait = 2'h1, 
           lp_sm_st_rd_wait = 2'h2; 
		   
reg[1:0] sm_st_current;
reg[1:0] sm_st_next;

wire do_read;
wire do_write;

//**********************************************************************************
localparam LP_AVR_DEL_CNT_WIDTH = 4;

reg[(LP_AVR_DEL_CNT_WIDTH-1):0] avr_req_del_cnt_current;
reg[(LP_AVR_DEL_CNT_WIDTH-1):0] avr_req_del_cnt_next;

wire start_read;
wire start_write;


//***************************************************************************************************

assign wb_data_0_7_rg_we   = (sel && !ramadr[8] && ramadr[1:0] == 2'h3 && ramwe) ? 1'b1 : 1'b0;
assign wb_data_8_15_rg_we  = (sel && !ramadr[8] && ramadr[1:0] == 2'h2 && ramwe) ? 1'b1 : 1'b0;
assign wb_data_16_23_rg_we = (sel && !ramadr[8] && ramadr[1:0] == 2'h1 && ramwe) ? 1'b1 : 1'b0;
assign wb_data_24_31_rg_we = (sel && !ramadr[8] && ramadr[1:0] == 2'h0 && ramwe) ? 1'b1 : 1'b0;

assign wb_done_re          = ~wb_done_rg_current & wb_done;
assign wb_done_fe          = wb_done_rg_current & ~wb_done; 

rg_md #(
	                   .p_width     (8),
                       .p_init_val  ({8{1'b0}}),
					   .p_impl_mask ({8{1'b1}}),
					   .p_sync_rst  (0))   
	 rg_md_adr_0_7_inst    (
					   .clk         (cp2),
					   .nrst        (ireset),
					   .wdata       ({ramadr[7:2],{2{1'b0}}}),	// wb_adr[1:0] should always be 2'b00 for the 32-bit transfers				   
					   .wbe         (do_read | do_write/*sel*/),
					   .rdata       (wb_adr[7:0])
					   );	

		
// Data write
rg_md #(
	                   .p_width     (8),
                       .p_init_val  ({8{1'b0}}),
					   .p_impl_mask ({8{1'b1}}),
					   .p_sync_rst  (0))   
	 rg_md_d_wr_0_7_inst    (
					   .clk         (cp2),
					   .nrst        (ireset),
					   .wdata       (dbus_in),					   
					   .wbe         (wb_data_0_7_rg_we),
					   .rdata       (wb_wdata[7:0])
					   );	
					   
rg_md #(
	                   .p_width     (8),
                       .p_init_val  ({8{1'b0}}),
					   .p_impl_mask ({8{1'b1}}),
					   .p_sync_rst  (0))   
	 rg_md_d_wr_8_15_inst    (
					   .clk         (cp2),
					   .nrst        (ireset),
					   .wdata       (dbus_in),					   
					   .wbe         (wb_data_8_15_rg_we),
					   .rdata       (wb_wdata[15:8])
					   );						   

rg_md #(
	                   .p_width     (8),
                       .p_init_val  ({8{1'b0}}),
					   .p_impl_mask ({8{1'b1}}),
					   .p_sync_rst  (0))   
	 rg_md_d_wr_16_23_inst    (
					   .clk         (cp2),
					   .nrst        (ireset),
					   .wdata       (dbus_in),					   
					   .wbe         (wb_data_16_23_rg_we),
					   .rdata       (wb_wdata[23:16])
					   );						   
					   
rg_md #(
	                   .p_width     (8),
                       .p_init_val  ({8{1'b0}}),
					   .p_impl_mask ({8{1'b1}}),
					   .p_sync_rst  (0))   
	 rg_md_d_wr_24_31_inst    (
					   .clk         (cp2),
					   .nrst        (ireset),
					   .wdata       (dbus_in),					   
					   .wbe         (wb_data_24_31_rg_we),
					   .rdata       (wb_wdata[31:24])
					   );	
					   
// Data read
rg_md #(
	                   .p_width     (32),
                       .p_init_val  ({32{1'b0}}),
					   .p_impl_mask ({32{1'b1}}),
					   .p_sync_rst  (0))   
	 rg_md_d_rd_inst    (
					   .clk         (cp2),
					   .nrst        (ireset),
					   .wdata       (wb_rdata),					   
					   .wbe         ({4{latch_rdata}}),
					   .rdata       (wb_rdata_rg)
					   );	
					   
assign latch_rdata = wb_done_re;					   

assign do_read   = (sel && !ramadr[8] && ramadr[1:0] == 2'h0 && ramre) ? 1'b1 : 1'b0;
assign do_write  = wb_data_0_7_rg_we;

 assign start_read = (!wb_read_current && do_read && sm_st_current == lp_sm_st_idle) ? 1'b1 : 1'b0;
 assign start_write = (!wb_write_current && do_write && sm_st_current == lp_sm_st_idle) ? 1'b1 : 1'b0;

  
always@(*) begin : main_comb
 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
 rd_mux = {8{1'b0}};	
 wb_read_next  = wb_read_current; 
 wb_write_next = wb_write_current;
 sm_st_next    =  sm_st_current;
 avr_req_del_cnt_next = avr_req_del_cnt_current;
 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
 if(ramadr[8] && !P_IO_LOC)
  rd_mux = out_regs;
 else
 case(ramadr[1:0])
  2'h0    : rd_mux = wb_rdata_rg[31:24];
  2'h1    : rd_mux = wb_rdata_rg[23:16];
  2'h2    : rd_mux = wb_rdata_rg[15:8];
  2'h3    : rd_mux = wb_rdata_rg[7:0];
  default : rd_mux = {8{1'b0}};
 endcase	 
 
// if(start_read)  wb_read_next = 1'b1;
// if(start_write) wb_write_next = 1'b1;

 case(wb_read_current)
  1'b0    : if(start_read) wb_read_next = 1'b1; 	 
  1'b1    : if(&avr_req_del_cnt_current) wb_read_next = 1'b0; 	 	 
  default :	wb_read_next = 1'b0; 
 endcase 
 
 case(wb_write_current)
  1'b0    : if(start_write)  wb_write_next = 1'b1; 	 
  1'b1    : if(&avr_req_del_cnt_current) wb_write_next = 1'b0; 	 	 
  default :	wb_write_next = 1'b0; 
 endcase  
 
 if(wb_write_current || wb_read_current)
 avr_req_del_cnt_next = avr_req_del_cnt_current + 1;

 
 case(sm_st_current)
  lp_sm_st_idle    : 
  begin
   if(start_read)	sm_st_next =  lp_sm_st_rd_wait; 	 
   else if(start_write) sm_st_next = lp_sm_st_wr_wait;	   
  end	
  lp_sm_st_wr_wait : if(wb_done_fe/*wb_done_re*/) sm_st_next = lp_sm_st_idle; 
  lp_sm_st_rd_wait : if(wb_done_fe/*wb_done_re*/) sm_st_next = lp_sm_st_idle; 
  default          : sm_st_next    = lp_sm_st_idle; 
 endcase	 	 
	 
end // main_comb	

assign dm_wait = (((do_read || do_write) && sm_st_current == lp_sm_st_idle) || 
				  ((sm_st_current == lp_sm_st_wr_wait || sm_st_current == lp_sm_st_rd_wait) && !wb_done_fe/*!wb_done_re*/)
                  ) ? 1'b1 : 1'b0;


always@(posedge cp2 or negedge ireset) begin : main_seq
 if(!ireset) begin	
  wb_read_current      <= 1'b0; 
  wb_write_current     <= 1'b0;
  wb_done_rg_current   <= 1'b0;
  sm_st_current        <= lp_sm_st_idle; 
  avr_req_del_cnt_current <=  {LP_AVR_DEL_CNT_WIDTH{1'b0}};
 end	 
 else begin       
  wb_read_current    <= wb_read_next;
  wb_write_current   <= wb_write_next;	 
  wb_done_rg_current <= wb_done;
  sm_st_current <= sm_st_next;  
  avr_req_del_cnt_current <= avr_req_del_cnt_next;
 end
end // main_seq 	 

assign wb_read   = wb_read_current;
assign wb_write  = wb_write_current;
assign dbus_out  = rd_mux;
assign dm_out_en = sel & ramre;

endmodule // avr2wb_async_avr
