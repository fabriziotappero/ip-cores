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


module avr2wb_ctrl_regs #( 
	                  parameter             P_IO_LOC    = 0, 
	                  parameter[5:0]	P_IO_A1_ADR = 6'h0,
		          parameter[5:0]	P_IO_A2_ADR = 6'h1,
		          parameter[5:0]	P_IO_A3_ADR = 6'h2,						  
		          parameter[5:0]	P_IO_BE_ADR = 6'h3,						  						  
		          parameter[5:0]	P_IO_ST_ADR = 6'h4						  						  						  
 	                 )
		         (
		         // AVR DM i/f
                         //    Clock and reset
                         input wire                            ireset,        
                         input wire                            cp2,           
                         // DM i/f (Slave part)
                         input wire                            sel,
                         input wire[8:0]                       ramadr, 
                         input wire                            ramre,        
                         input wire                            ramwe,        
                         input wire[7:0]                       dbus_in,      // Common for DM and IO interfaces
                         output wire[7:0]                      dbus_out,     // Common for DM and IO interfaces						  
			 // IO i/f
                         input wire[5:0]                       adr,
                         input wire                            iore,      
                         input wire                            iowe,      
                         output wire                           io_out_en,   
			 // WB related
			 output wire[31:8]		       wb_adr_hi,
                         output wire[3:0]                      wb_be,
			 output	wire                           wb_rst_o,
                         output	wire                           int_o,						 
			 input  wire			       wb_rst_i,
			 input  wire			       wb_int_i,
			 input  wire			       wb_err_i   
	                     );

//*************************************************************************************************************						 						 
localparam lp_wb_adr_8_15_rg_adr   = 8'h00;
localparam lp_wb_adr_16_23_rg_adr  = 8'h01;
localparam lp_wb_adr_24_31_rg_adr  = 8'h02;
localparam lp_wb_be_rg_adr         = 8'h03;
localparam lp_wb_stat_rg_adr       = 8'h04;

wire wb_adr_8_15_rg_we;							
wire wb_adr_16_23_rg_we;
wire wb_adr_24_31_rg_we;						 
wire wb_be_rg_we;
wire wb_stat_rg_we;

wire[7:0] wb_be_tmp;

// Status(control)  register
//************************************************************
// | bit | Reset value | Description
// | 0   |             | WB reset status (RO)    
// | 1   |             | WB reset (R/W)    
// | 2   |             | WB interrupt type (0 - level, 1 - rising edge)    
// | 3   |             | Reserve (0)    
// | 4   |             | Interrupt flag + Clear WB interrupt (RM1W)   
// | 5   |             | WB interrupt enable    
// | 6   |             | Reserve (0)     
// | 7   |             | WB Erorr Status    (RO)
//************************************************************
localparam lp_stat_rg_impl_msk = 8'b00100110;

wire[7:0] stat_rg;
wire[7:0] stat_rg_rd_tmp;

// Interrupts
wire set_int;
wire clr_int;

reg  int_current;
reg  int_next;

reg[7:0]  rd_mux;

reg wb_int_i_reg;

wire wb_int_i_re;
//*************************************************************************************************************						 

generate
if(!P_IO_LOC) begin : dm_loc
 assign wb_adr_8_15_rg_we   = (sel && ramadr[8] && ramadr[7:0] == lp_wb_adr_8_15_rg_adr && ramwe) ? 1'b1 : 1'b0;							
 assign wb_adr_16_23_rg_we  = (sel && ramadr[8] && ramadr[7:0] == lp_wb_adr_16_23_rg_adr && ramwe) ? 1'b1 : 1'b0;
 assign wb_adr_24_31_rg_we  = (sel && ramadr[8] && ramadr[7:0] == lp_wb_adr_24_31_rg_adr && ramwe) ? 1'b1 : 1'b0;						 
 assign wb_be_rg_we         = (sel && ramadr[8] && ramadr[7:0] == lp_wb_be_rg_adr && ramwe) ? 1'b1 : 1'b0;
 assign wb_stat_rg_we       = (sel && ramadr[8] && ramadr[7:0] == lp_wb_stat_rg_adr && ramwe) ? 1'b1 : 1'b0; 
 assign io_out_en              = 1'b0;

always@(*) begin : out_mux_comb
 rd_mux   = {8{1'b0}};
 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 case(ramadr[7:0])
  lp_wb_adr_8_15_rg_adr    : rd_mux = wb_adr_hi[15:8];
  lp_wb_adr_16_23_rg_adr   : rd_mux = wb_adr_hi[23:16];
  lp_wb_adr_24_31_rg_adr   : rd_mux = wb_adr_hi[31:24];
  lp_wb_be_rg_adr          : rd_mux = wb_be_tmp;
  lp_wb_stat_rg_adr        : rd_mux = stat_rg_rd_tmp;
  default  				   : rd_mux = {8{1'b0}};
 endcase 									   
end // out_mux_comb					    
end // dm_loc
else begin : io_loc
 assign wb_adr_8_15_rg_we   = (adr == P_IO_A1_ADR && iowe) ? 1'b1 : 1'b0;							
 assign wb_adr_16_23_rg_we  = (adr == P_IO_A2_ADR && iowe) ? 1'b1 : 1'b0;
 assign wb_adr_24_31_rg_we  = (adr == P_IO_A3_ADR && iowe) ? 1'b1 : 1'b0;						 
 assign wb_be_rg_we         = (adr == P_IO_BE_ADR && iowe) ? 1'b1 : 1'b0;
 assign wb_stat_rg_we       = (adr == P_IO_ST_ADR && iowe) ? 1'b1 : 1'b0; 
 assign io_out_en              = ((adr == P_IO_A1_ADR | adr == P_IO_A2_ADR | 
                                adr == P_IO_A3_ADR | adr == P_IO_BE_ADR | 
                                adr == P_IO_ST_ADR) && iore) ? 1'b1 : 1'b0;

always@(*) begin : out_mux_comb
 rd_mux   = {8{1'b0}};
 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 case(adr)
  P_IO_A1_ADR   : rd_mux = wb_adr_hi[15:8];
  P_IO_A2_ADR   : rd_mux = wb_adr_hi[23:16];
  P_IO_A3_ADR   : rd_mux = wb_adr_hi[31:24];
  P_IO_BE_ADR   : rd_mux = wb_be_tmp;
  P_IO_ST_ADR   : rd_mux = stat_rg_rd_tmp;
  default  		: rd_mux = {8{1'b0}};
 endcase 									   
end // out_mux_comb					    								

								
								
end // io_loc
endgenerate


rg_md #(
	                   .p_width     (8),
                       .p_init_val  ({8{1'b0}}),
					   .p_impl_mask ({8{1'b1}}),
					   .p_sync_rst  (0))   
	 rg_md_adr_8_15_inst    (
					   .clk         (cp2),
					   .nrst        (ireset),
					   .wdata       (dbus_in),					   
					   .wbe         (wb_adr_8_15_rg_we),
					   .rdata       (wb_adr_hi[15:8])
					   );	

rg_md #(
	                   .p_width     (8),
                       .p_init_val  ({8{1'b0}}),
					   .p_impl_mask ({8{1'b1}}),
					   .p_sync_rst  (0))   
	 rg_md_adr_16_23_inst    (
					   .clk         (cp2),
					   .nrst        (ireset),
					   .wdata       (dbus_in),					   
					   .wbe         (wb_adr_16_23_rg_we),
					   .rdata       (wb_adr_hi[23:16])
					   );						   
					   
rg_md #(
	                   .p_width     (8),
                       .p_init_val  ({8{1'b0}}),
					   .p_impl_mask ({8{1'b1}}),
					   .p_sync_rst  (0))   
	 rg_md_adr_24_31_inst    (
					   .clk         (cp2),
					   .nrst        (ireset),
					   .wdata       (dbus_in),					   
					   .wbe         (wb_adr_24_31_rg_we),
					   .rdata       (wb_adr_hi[31:24])
					   );				

					   
rg_md #(
	                   .p_width     (8),
                       .p_init_val  ({{4{1'b0}},{4{1'b1}}}),  // BE are enabled after reset
					   .p_impl_mask ({{4{1'b0}},{4{1'b1}}}),
					   .p_sync_rst  (0))   
	 rg_md_wb_be_inst    (
					   .clk         (cp2),
					   .nrst        (ireset),
					   .wdata       (dbus_in),					   
					   .wbe         (wb_be_rg_we),
					   .rdata       (wb_be_tmp)
					   );						   
					   
assign wb_be = wb_be_tmp[3:0];							   


// Status(control) register
rg_md #(
	                   .p_width     (8),
                       .p_init_val  ({8{1'b0}}),
					   .p_impl_mask (lp_stat_rg_impl_msk),
					   .p_sync_rst  (0))   
	 rg_md_stat_inst    (
					   .clk         (cp2),
					   .nrst        (ireset),
					   .wdata       (dbus_in),					   
					   .wbe         (wb_stat_rg_we),
					   .rdata       (stat_rg)
					   );						   




always@(*) begin : main_comb
  int_next = int_current;
 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 // Interrupt
 case(int_current)
  1'b0    : if(set_int) int_next = 1'b1; // Set interrupt flag
  1'b1    : if(clr_int && !set_int) int_next = 1'b0; // Clear interrupt flag
  default : int_next = 1'b0; 
 endcase
end // main_comb	

always@(posedge cp2 or negedge ireset) begin : main_seq
 if(!ireset) begin	
  int_current  <= 1'b0;
  wb_int_i_reg <= 1'b0;
 end	 
 else begin       
  int_current  <= int_next;
  wb_int_i_reg <= wb_int_i;
 end
end // main_seq 	

assign wb_int_i_re = ~wb_int_i_reg & wb_int_i;

assign set_int = (~stat_rg[2] && wb_int_i) ||   // Level (High)
                 (stat_rg[2] && wb_int_i_re);   // Rising edge  

// Clear interrupt				 
assign	clr_int = wb_stat_rg_we & dbus_in[4];			 
				 
// Interrupt output (masked)				 
assign int_o = int_current & stat_rg[5];			 

// WB reset input
assign wb_rst_o = stat_rg[1];

// Statur register(read)
assign stat_rg_rd_tmp[7] = wb_err_i;    // WB error
assign stat_rg_rd_tmp[6] = 1'b0;        // Reserve (0)                                 
assign stat_rg_rd_tmp[5] = stat_rg[5];  // WB interrupt enable                        
assign stat_rg_rd_tmp[4] = int_current; // Interrupt flag + Clear WB interrupt (RM1W) 
assign stat_rg_rd_tmp[3] = 1'b0;        // Reserve (0)                                
assign stat_rg_rd_tmp[2] = stat_rg[2];  // WB interrupt type
assign stat_rg_rd_tmp[1] = stat_rg[1];  // WB reset output
assign stat_rg_rd_tmp[0] = wb_rst_i;    // WB reset input

assign dbus_out = rd_mux;

endmodule // avr2wb_ctrl_regs
