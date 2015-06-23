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

module avr2wb_async #(
	              parameter         P_WB_DATA_WIDTH     = 32, /* 32/64/128 ??? */
		      parameter	        P_WB_DEL_CNT_WIDTH  = 4,
		      // AVR related
	              parameter         P_IO_LOC    = 0, 
	              parameter[5:0]	P_IO_A1_ADR = 6'h0,
		      parameter[5:0]	P_IO_A2_ADR = 6'h1,
		      parameter[5:0]	P_IO_A3_ADR = 6'h2,						  
		      parameter[5:0]	P_IO_BE_ADR = 6'h3,						  						  
		      parameter[5:0]	P_IO_ST_ADR = 6'h4						  						  						  
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
			  input  wire                           wb_irq,   
                          // AVR DM i/f
                          //    Clock and reset
                          input wire                            ireset,        
                          input wire                            cp2,           
                          // DM i/f (Slave part)
                          input wire                            sel,
                          input wire[8:0]                       ramadr, 
                          input wire                            ramre,        
                          input wire                            ramwe,        
                          input wire[7:0]                       ramdin,
                          output wire[7:0]                      ramdout, 						  
		          output wire                           dm_wait,
			  output wire                           dm_out_en,						  
						  // IO i/f
                          input wire[5:0]                       adr,
                          input wire                            iore,      
                          input wire                            iowe,      
                          output wire                           io_out_en,   						  
                          input wire[7:0]                       dbus_in,
                          output wire[7:0]                      dbus_out, 						  						  
			  // IRQ
			  output wire				avr_irq,
			  // WB reset
			  output wire                           rst_o
			  );
					  
						  
wire[31:0]  wb_adr;
wire[31:0]  wb_wdata;
wire[3:0]   wb_be;							 
wire[31:0]  wb_rdata;
wire        wb_read_cp2;
wire        wb_write_cp2;
wire        wb_done_clk;
wire        wb_done_cp2;
wire        wb_error_clk;							 						  
wire        wb_error_cp2;							 						  

wire        wb_read_clk; 
wire        wb_write_clk;

// wire[7:0]   out_regs;

wire[7:0]   dbus_out_regs;
wire[7:0]   dbus_in_regs;

wire        wb_rst_i_cp2;
wire        wb_rst_o_cp2;

wire        wb_irq_cp2;

generate
 if(!P_IO_LOC) begin : dm_loc
  assign dbus_in_regs =	ramdin;
  assign dbus_out     = {8{1'b0}};
 end // dm_loc
 else begin : io_loc
  assign dbus_in_regs = dbus_in;  
  assign dbus_out     =	dbus_out_regs;
 end // io_loc
endgenerate 

avr2wb_async_avr#(
                      .P_IO_LOC(P_IO_LOC)
					  ) 
 
 avr2wb_async_avr_inst(
	                         // AVR DM i/f
                             //    Clock and reset
                             .ireset   (ireset),        
                             .cp2      (cp2),           
                             // DM i/f (Slave part)
                             .sel      (sel     ),
                             .ramadr   (ramadr  ), 
                             .ramre    (ramre   ),        
                             .ramwe    (ramwe   ),        
                             .dbus_in  (ramdin  ),
                             .dbus_out (ramdout ), 						  
		                     .dm_wait  (dm_wait),
							 .dm_out_en(dm_out_en),
							 //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
							 .out_regs (dbus_out_regs),
							 //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
							 .wb_adr   (wb_adr[7:0] ),
							 .wb_wdata (wb_wdata    ),
							 .wb_rdata (wb_rdata    ),
							 .wb_read  (wb_read_cp2 ),
							 .wb_write (wb_write_cp2),
                             .wb_done  (wb_done_cp2 )
	                        );						  
						  
avr2wb_async_wb #(
                      .P_WB_DATA_WIDTH    (P_WB_DATA_WIDTH),
					  .P_WB_DEL_CNT_WIDTH (P_WB_DEL_CNT_WIDTH)
					  )
avr2wb_async_wb_inst(
	                          // WISHBONE master interface
                          .rst_i    (rst_i ),
                          .clk_i    (clk_i ),

                          .adr_o    (adr_o ),
                          .dat_i    (dat_i ),
                          .dat_o    (dat_o ),
                          .we_o     (we_o  ),

                          .stb_o    (stb_o),
                          .cyc_o    (cyc_o),
                          .ack_i    (ack_i),
                          .err_i    (err_i),
                          .rty_i    (rty_i),
    
                          .lock_o   (lock_o),
                          .sel_o    (sel_o ), // Byte enables
                          .cti_o    (cti_o ),
	                      .bte_o    (bte_o ), // Burst type
						  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						  .wb_adr   (wb_adr  ),
						  .wb_wdata (wb_wdata),
                          .wb_be    (wb_be   ),							 
						  .wb_rdata (wb_rdata),
						  .wb_read  (wb_read_clk ),
						  .wb_write (wb_write_clk),
                          .wb_done  (wb_done_clk ),
                          .wb_error (wb_error_clk)							 
                          );							


rsnc_bit_vlog #(
	              .add_stgs_num (0),
                  .inv_f_stgs   (0)
				  )
rsnc_bit_vlog_wb_read_inst(	                   
                  .clk  (clk_i),
                  .din  (wb_read_cp2),
                  .dout (wb_read_clk)
                  );						  
				  
rsnc_bit_vlog #(
	              .add_stgs_num (0),
                  .inv_f_stgs   (0)
				  )
rsnc_bit_vlog_wb_write_inst(	                   
                  .clk  (clk_i),
                  .din  (wb_write_cp2),
                  .dout (wb_write_clk)
                  );						  				  
				  
rsnc_bit_vlog #(
	              .add_stgs_num (0),
                  .inv_f_stgs   (0)
				  )
rsnc_bit_vlog_wb_done_inst(	                   
                  .clk  (cp2),
                  .din  (wb_done_clk),
                  .dout (wb_done_cp2)
                  );						  				  				  
		
// ... Registers				  
avr2wb_ctrl_regs #( 
	                      .P_IO_LOC    (P_IO_LOC   ), 
	                      .P_IO_A1_ADR (P_IO_A1_ADR),
		                  .P_IO_A2_ADR (P_IO_A2_ADR),
		                  .P_IO_A3_ADR (P_IO_A3_ADR),						  
		                  .P_IO_BE_ADR (P_IO_BE_ADR),						  						  
		                  .P_IO_ST_ADR (P_IO_ST_ADR)						  						  						  
 	                      )
     avr2wb_ctrl_regs_inst(
		                 // AVR DM i/f
                         //    Clock and reset
                         .ireset    (ireset),        
                         .cp2       (cp2   ),           
                         // DM i/f (Slave part)
                         .sel       (sel    ),
                         .ramadr    (ramadr ), 
                         .ramre     (ramre  ),        
                         .ramwe     (ramwe  ),        
                         .dbus_in   (dbus_in_regs ),     // Common for DM and IO interfaces
                         .dbus_out  (dbus_out_regs),     // Common for DM and IO interfaces						  
						 // IO i/f
                         .adr       (adr   ),
                         .iore      (iore  ),      
                         .iowe      (iowe  ),      
                         .io_out_en (io_out_en),   
						 // WB related
						 .wb_adr_hi (wb_adr[31:8]),
                         .wb_be     (wb_be),
						 .wb_rst_o  (wb_rst_o_cp2),
                         .int_o     (avr_irq),						 
						 .wb_rst_i  (wb_rst_i_cp2),
						 .wb_int_i  (wb_irq_cp2),
						 .wb_err_i  (wb_error_cp2)   
	                     );				  

rsnc_bit_vlog #(
	              .add_stgs_num (0),
                  .inv_f_stgs   (0)
				  )
rsnc_bit_vlog_wb_rst_i_inst(	                   
                  .clk  (cp2),
                  .din  (rst_i),
                  .dout (wb_rst_i_cp2)
                  );								 

// WB reset	(TBD)			  
rsnc_bit_vlog #(
	              .add_stgs_num (0),
                  .inv_f_stgs   (0)
				  )
rsnc_bit_vlog_wb_rst_o_inst(	                   
                  .clk  (clk_i),
                  .din  (wb_rst_o_cp2),
                  .dout (rst_o)
                  );								 				  

// WB Error flag				  
rsnc_bit_vlog #(
	              .add_stgs_num (0),
                  .inv_f_stgs   (0)
				  )
rsnc_bit_vlog_wb_error_inst(	                   
                  .clk  (cp2),
                  .din  (wb_error_clk),
                  .dout (wb_error_cp2)
                  );								 				  				  

// WB IRQ				  
rsnc_bit_vlog #(
	              .add_stgs_num (0),
                  .inv_f_stgs   (0)
				  )
rsnc_bit_vlog_wb_irq_inst(	                   
                  .clk  (cp2),
                  .din  (wb_irq),
                  .dout (wb_irq_cp2)
                  );								 				  
				  
endmodule // avr2wb_async
