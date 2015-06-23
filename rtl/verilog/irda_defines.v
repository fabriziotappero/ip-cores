// Timescale

`timescale 1ns/10ps

// Defines

// if IRDA_SIR_ONLY is defined then only the
// SIR (slow, async, up to 115kb) version will be
// implemented.
// Generally it wraps the the uart16550 core with
// LED bit encoding and decoding.
`define IRDA_SIR_ONLY

// IRDA_MASTER CONTROL REGISTER
`define	IRDA_MASTER			4'd8

`define	IRDA_MASTER_MODE	  	1
`define	IRDA_MASTER_LB			2
`define	IRDA_MASTER_SPEED		4:3
`define	IRDA_MASTER_NEGATE_T	5
`define	IRDA_MASTER_NEGATE_R	6
`define	IRDA_MASTER_USE_DMA	7

// Fast mode register addresses
`define	IRDA_TRANSMITTER	4'd0
`define	IRDA_RECEIVER		4'd0
`define	IRDA_F_IER			4'd1	// Interrupt Enable register
`define	IRDA_F_IIR			4'd2	// Interrupt Identification Register
`define	IRDA_F_FCR			4'd3	// fifo Contorl Register
`define	IRDA_F_LCR			4'd4	// Line Control Register
`define	IRDA_F_OFDLR		4'd5	// Outgoing Data Frame Data Length Register
`define	IRDA_F_IFDLR		4'd6	// Incoming Data Frame Data Length Register
`define	IRDA_F_CDR			4'd7	// Clock Divisor Register

`define	IRDA_FIFO_SIZE		16
`define	IRDA_FIFO_WIDTH		32
`define	IRDA_FIFO_POINTER_W	4

`define	IRDA_F_CDR_WIDTH 24
