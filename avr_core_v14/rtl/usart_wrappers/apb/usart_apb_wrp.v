//**************************************************************************************************
// APB wrapper for USART
// Version 0.3
// Modified 04.10.2012
// Written by Ruslan Lepetenok (lepetenokr@yahoo.com)
//**************************************************************************************************

// All nets must be declared
`default_nettype none

module usart_apb_wrp #(
                       parameter RX_FIFO_DEPTH    = 2,
                       parameter TX_FIFO_DEPTH    = 2,
                       parameter MEGA_COMPAT_MODE = 1,
                       parameter COMPAT_MODE	  = 0,
                       parameter IMPL_DFT	  = 0
                       )
                (
		// Global control signals
	        input  wire	  PRESETn, 
		input  wire	  PCLK,    
                // APB signals
		input  wire[15:0] PADDR,   
		input  wire[31:0] PWDATA,  
		output wire[31:0] PRDATA,  
		input  wire	  PENABLE, 
		input  wire	  PWRITE,  
		input  wire	  PSEL,
		// APB 3.0 support
		output wire	  PSLVERR,
		output wire	  PREADY,
				
		output wire[2:0]  irq_o,
                // USART related pins
		output wire	  rx_en,
		output wire	  tx_en,
                output wire	  txd,
                output wire	  rtsn,
                input  wire	  rxd,
                input  wire	  ctsn
	        );

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

localparam LP_USART_SYNC_RST	     = 0;    
localparam LP_USART_RXB_TXB_ADR	     = 3'h0; // UDR0_Address
localparam LP_USART_STATUS_ADR	     = 3'h1; // UCSR0B_Address
localparam LP_USART_CTRLA_ADR	     = 3'h3; // UCSR0A_Address
localparam LP_USART_CTRLB_ADR	     = 3'h4; // TBD ???
localparam LP_USART_CTRLC_ADR	     = 3'h5;  // TBD ???
localparam LP_USART_BAUDCTRLA_ADR    = 3'h6; // UBRR0L_Address 
localparam LP_USART_BAUDCTRLB_ADR    = 3'h7;   // TBD ???
localparam LP_USART_RXB_TXB_DM_LOC   = 1; 
localparam LP_USART_STATUS_DM_LOC    = 1; 
localparam LP_USART_CTRLA_DM_LOC     = 1; 
localparam LP_USART_CTRLB_DM_LOC     = 1; 
localparam LP_USART_CTRLC_DM_LOC     = 1; 
localparam LP_USART_BAUDCTRLA_DM_LOC = 1;
localparam LP_USART_BAUDCTRLB_DM_LOC = 1;

wire usart_we = PENABLE &  PWRITE; 
wire usart_re = PENABLE & ~PWRITE;

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
	     .RX_FIFO_DEPTH    (RX_FIFO_DEPTH	         ),
             .TX_FIFO_DEPTH    (TX_FIFO_DEPTH	         ),
	     .MEGA_COMPAT_MODE (MEGA_COMPAT_MODE         ),
	     .COMPAT_MODE      (COMPAT_MODE	         ),
             .IMPL_DFT         (IMPL_DFT	         )	    
	     )
   usart_inst(
             // Clock and Reset
             .ireset      (PRESETn      ),  // !!!!!!!!!!!!!!
             .cp2         (PCLK  	), 
             .adr         (PADDR[7:2]   ), 
             .dbus_in     (PWDATA[7:0] 	), 
             .dbus_out    (/*Not used*/ ), 
             .iore        (1'b0 	), 
             .iowe        (1'b0 	), 
             .io_out_en   (/*Not used*/ ), 
             .ramadr 	  (PADDR[4:2]   ), 
             .dm_dbus_in  (PWDATA[7:0]  ),
             .dm_dbus_out (PRDATA[7:0]  ),
             .ramre	  (usart_re	),
             .ramwe	  (usart_we	),
             .dm_sel	  (PSEL         ),
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


assign PRDATA[31:8] = {(32-8){1'b0}}; 


// APB 3.0 support
assign PSLVERR = 1'b0;
assign PREADY  = 1'b1;


endmodule // usart_apb_wrp

