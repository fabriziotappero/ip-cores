//**************************************************************************************************
// Wishbone wrapper for USART
// Version 0.1
// Modified 02.10.2012
// Written by Ruslan Lepetenok (lepetenokr@yahoo.com)
//**************************************************************************************************

// All nets must be declared
`default_nettype none


module usart_wb_wrp #(
	             parameter P_WB_DATA_WIDTH    = 32 /* 32/64/128 ??? */
		    )
	            (
                     input  wire 			   rst_i,
                     input  wire 			   clk_i,
                      // WISHBONE slave i/f
                     input  wire[11:0]			   s_adr_i,
                     input  wire[(P_WB_DATA_WIDTH-1):0]    s_dat_i,
                     output wire [(P_WB_DATA_WIDTH-1):0]   s_dat_o,
                     input  wire 			   s_we_i,

                     input  wire 			   s_stb_i,
                     input  wire 			   s_cyc_i,
			   		     
                     output wire			   s_ack_o,
                     output wire			   s_err_o,
                     output wire			   s_rty_o,
    
                     input  wire 			   s_lock_i,
                     input  wire[(P_WB_DATA_WIDTH/8-1):0]  s_sel_i, // Byte enables
                     input  wire[2:0]			   s_cti_i,
	             input  wire[1:0]			   s_bte_i, // Burst type
		     output wire[2:0]			   irq_o,
                     // USART related pins
		     output wire			   rx_en,
		     output wire			   tx_en,
                     output wire			   txd,
                     output wire			   rtsn,
                     input  wire 			   rxd,
                     input  wire 			   ctsn
                     );

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

localparam LP_USART_SYNC_RST	     = 0;    
localparam LP_USART_RXB_TXB_ADR	     = 3'h00; // UDR0_Address
localparam LP_USART_STATUS_ADR	     = 3'h01; // UCSR0B_Address
localparam LP_USART_CTRLA_ADR	     = 3'h03; // UCSR0A_Address
localparam LP_USART_CTRLB_ADR	     = 3'h04; // TBD ???
localparam LP_USART_CTRLC_ADR	     = 3'h05;  // TBD ???
localparam LP_USART_BAUDCTRLA_ADR    = 3'h06; // UBRR0L_Address 
localparam LP_USART_BAUDCTRLB_ADR    = 3'h07;   // TBD ???
localparam LP_USART_RXB_TXB_DM_LOC   = 1; 
localparam LP_USART_STATUS_DM_LOC    = 1; 
localparam LP_USART_CTRLA_DM_LOC     = 1; 
localparam LP_USART_CTRLB_DM_LOC     = 1; 
localparam LP_USART_CTRLC_DM_LOC     = 1; 
localparam LP_USART_BAUDCTRLA_DM_LOC = 1;
localparam LP_USART_BAUDCTRLB_DM_LOC = 1;
localparam LP_USART_RX_FIFO_DEPTH    = 2;
localparam LP_USART_TX_FIFO_DEPTH    = 2;
localparam LP_USART_MEGA_COMPAT_MODE = 1;
localparam LP_USART_COMPAT_MODE      = 0;
localparam LP_USART_IMPL_DFT         = 0;


wire usart_we = s_cyc_i &  s_we_i; 
wire usart_re = s_cyc_i & ~s_we_i;

// USART 
      usart #(
             .SYNC_RST	       (LP_USART_SYNC_RST	 ),   
             .RXB_TXB_ADR      (LP_USART_RXB_TXB_ADR	 ),  
             .STATUS_ADR       (LP_USART_STATUS_ADR	 ),  
             .CTRLA_ADR        (LP_USART_CTRLA_ADR	 ),  
             .CTRLB_ADR        (LP_USART_CTRLB_ADR	 ),  
             .CTRLC_ADR        (LP_USART_CTRLC_ADR	 ),  
             .BAUDCTRLA_ADR    (LP_USART_BAUDCTRLA_ADR   ),  
             .BAUDCTRLB_ADR    (LP_USART_BAUDCTRLB_ADR   ),  
             .RXB_TXB_DM_LOC   (LP_USART_RXB_TXB_DM_LOC  ),
             .STATUS_DM_LOC    (LP_USART_STATUS_DM_LOC   ),  
             .CTRLA_DM_LOC     (LP_USART_CTRLA_DM_LOC	 ),  
             .CTRLB_DM_LOC     (LP_USART_CTRLB_DM_LOC	 ),  
             .CTRLC_DM_LOC     (LP_USART_CTRLC_DM_LOC	 ),
             .BAUDCTRLA_DM_LOC (LP_USART_BAUDCTRLA_DM_LOC),
             .BAUDCTRLB_DM_LOC (LP_USART_BAUDCTRLB_DM_LOC),
	     .RX_FIFO_DEPTH    (LP_USART_RX_FIFO_DEPTH   ),
             .TX_FIFO_DEPTH    (LP_USART_TX_FIFO_DEPTH   ),
	     .MEGA_COMPAT_MODE (LP_USART_MEGA_COMPAT_MODE),
	     .COMPAT_MODE      (LP_USART_COMPAT_MODE	 ),
             .IMPL_DFT         (LP_USART_IMPL_DFT        )	     
	     )
   usart_inst(
             // Clock and Reset
             .ireset      (~rst_i       ),  // !!!!!!!!!!!!!!
             .cp2         (clk_i	), 
             .adr         (s_adr_i[5:0] ), 
             .dbus_in     (s_dat_i[7:0] ), 
             .dbus_out    (s_dat_o[7:0] ), 
             .iore        (1'b0	        ), 
             .iowe        (1'b0	        ), 
             .io_out_en   (/*Not used*/ ), 
             .ramadr 	  (s_adr_i[2:0] ), 
             .dm_dbus_in  (s_dat_i[7:0] ),
             .dm_dbus_out (s_dat_o[7:0] ),
             .ramre	  (usart_re	),
             .ramwe	  (usart_we	),
             .dm_sel	  (s_stb_i      ),
             .cpuwait	  (/*Not used*/ ),
             .dm_out_en   (/*Not used*/ ),
             .rxcintlvl   (/*Not used*/ ),
             .txcintlvl   (/*Not used*/ ),
             .dreintlvl   (/*Not used*/ ),
             .rxd	  (rxd  	),
             .rx_en	  (rx_en    	),
             .txd	  (txd  	), 
             .tx_en	  (tx_en    	), 
             .txcirq	  (irq_o[0]     ), 
             .txc_irqack  (1'b0         ),
             .udreirq	  (irq_o[1]     ),
             .rxcirq	  (irq_o[2]     ),
	     .rtsn        (rtsn         ),
	     .ctsn        (ctsn         ),
	      // Test related
	     .test_se     (1'b0         ),
	     .test_si1    (1'b0         ),
	     .test_si2    (1'b0         ),
	     
	     .test_so1    (             ),
	     .test_so2	  (             )	    
	         );

assign s_dat_o[31:8] = {(P_WB_DATA_WIDTH-8){1'b0}};

//*******************************************************************************8
assign s_ack_o = 1'b1;
assign s_err_o = 1'b0;
assign s_rty_o = 1'b0;

endmodule // usart_wb_wrp
