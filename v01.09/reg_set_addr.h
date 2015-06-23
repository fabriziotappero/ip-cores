// internal register addresses
localparam	[15:0]				REG_BASE_ADDR	= 'hFFF0;
localparam							REG_ADDR_W = 4;
//
localparam	[REG_ADDR_W-1:0]	VER_ADDR			= 'h0;
localparam	[REG_ADDR_W-1:0]	THRD_ID_ADDR	= 'h1;
localparam	[REG_ADDR_W-1:0]	CLR_ADDR			= 'h2;
localparam	[REG_ADDR_W-1:0]	INTR_EN_ADDR	= 'h3;
localparam	[REG_ADDR_W-1:0]	OP_ER_ADDR		= 'h4;
localparam	[REG_ADDR_W-1:0]	STK_ER_ADDR		= 'h5;
localparam	[REG_ADDR_W-1:0]	IO_LO_ADDR		= 'h8;
localparam	[REG_ADDR_W-1:0]	IO_HI_ADDR		= 'h9;
