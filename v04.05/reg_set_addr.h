// `ifndef _reg_set_addr_h_
// `define _reg_set_addr_h_

// internal register addresses
localparam	integer	VER_ADDR			= 'h0;
localparam	integer	THRD_ID_ADDR	= 'h1;
localparam	integer	CLR_ADDR			= 'h2;
localparam	integer	INTR_EN_ADDR	= 'h3;
localparam	integer	OP_ER_ADDR		= 'h4;
localparam	integer	STK_ER_ADDR		= 'h5;
localparam	integer	IO_LO_ADDR		= 'h8;
localparam	integer	IO_HI_ADDR		= 'h9;
localparam	integer	UART_RX_ADDR	= 'hc;
localparam	integer	UART_TX_ADDR	= 'hd;

// `endif  // _reg_set_addr_h_