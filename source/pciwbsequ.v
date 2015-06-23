// Copyright (C) 2005 Peio Azkarate, peio@opencores.org
//
//   This source file is free software; you can redistribute it
//   and/or modify it under the terms of the GNU Lesser General
//   Public License as published by the Free Software Foundation;
//   either version 2.1 of the License, or (at your option) any
//   later version.
//

(* signal_encoding = "user" *)
(* safe_implementation = "yes" *)

module pciwbsequ_new ( clk_i, nrst_i, cmd_i, cbe_i, frame_i, irdy_i, devsel_o, 
	trdy_o, adrcfg_i, adrmem_i, pciadrLD_o, pcidOE_o, parOE_o, wbdatLD_o, 
	wbrgdMX_o, wbd16MX_o, wrcfg_o, rdcfg_o, wb_sel_o, wb_we_o, wb_stb_o, 
	wb_cyc_o, wb_ack_i, wb_err_i, debug_init, debug_access );

   	// General 
	input clk_i;
	input nrst_i;
	// pci 
	// adr_i
	input [3:0] cmd_i;
	input [3:0] cbe_i;
	input frame_i;
	input irdy_i;
	output devsel_o;
	output trdy_o;
	// control
	input adrcfg_i;
	input adrmem_i;
	output pciadrLD_o;
	output pcidOE_o;
	output reg parOE_o;
	output wbdatLD_o;
	output wbrgdMX_o;
	output wbd16MX_o;
	output wrcfg_o;
	output rdcfg_o;
	// whisbone
	output [1:0] wb_sel_o;
	output wb_we_o;
	inout wb_stb_o;
	output wb_cyc_o;
	input wb_ack_i;
	input wb_err_i;
	// debug signals
	output reg debug_init;
	output reg debug_access;

	//type PciFSM is ( PCIIDLE, B_BUSY, S_DATA1, S_DATA2, TURN_AR );	
  	//wire pst_pci 		: PciFSM;
  	//wire nxt_pci 		: PciFSM;

	//	typedef enum reg [2:0] {
	//		RED, GREEN, BLUE, CYAN, MAGENTA, YELLOW
	//	} color_t;
	//
	//	color_t   my_color = GREEN;

	// parameter PCIIDLE    = 2'b00;
	// parameter B_BUSY     = 2'b01;
	// parameter S_DATA1    = 2'b10;
	// parameter S_DATA2    = 2'b11;
	// parameter TURN_AR    = 3'b100;

  	reg [2:0] pst_pci;
  	reg [2:0] nxt_pci;

	parameter [2:0] 
		PCIIDLE    = 3'b000,
		B_BUSY     = 3'b001,
		S_DATA1    = 3'b010,
		S_DATA2    = 3'b011,
		TURN_AR    = 3'b100;


	initial begin
		pst_pci = 3'b000;
	end

	initial begin
		nxt_pci = 3'b000;
	end
	
  	wire sdata1;
  	wire sdata2;
	wire idleNX;
	wire sdata1NX;
	wire sdata2NX;
	wire turnarNX;
	wire idle;
  	reg  devselNX_n;
  	reg  trdyNX_n;
  	reg  devsel;
  	reg  trdy;
  	wire adrpci;
  	wire acking;
  	wire rdcfg;
	reg  targOE;
	reg  pcidOE;

	// always @(nrst_i or clk_i or nxt_pci)
	always @(negedge nrst_i or posedge clk_i)
	begin
    	if( nrst_i == 0 )
			pst_pci <= PCIIDLE;
  		else 
			pst_pci <= nxt_pci; 
	end

	// always @(negedge nrst_i or posedge clk_i)
	always @( pst_pci or frame_i or irdy_i or adrcfg_i or adrpci or acking )
	begin
		devselNX_n 	<= 1'b1;
		trdyNX_n 	<= 1'b1;	
		case (pst_pci)
            PCIIDLE : 
			begin
				if ( frame_i == 0 )
					nxt_pci <= B_BUSY; 	
				else
					nxt_pci <= PCIIDLE;
			end
           	B_BUSY:
				if ( adrpci == 0 )
					nxt_pci <= TURN_AR;
				else
					begin
					nxt_pci <= S_DATA1;
					devselNX_n <= 0; 
					end
			S_DATA1:
				if ( acking == 1 )
					begin
					nxt_pci 	<= S_DATA2;
					devselNX_n 	<= 0; 					
					trdyNX_n 	<= 0;	
					end
				else
					begin
					nxt_pci <= S_DATA1;
					devselNX_n <= 0; 					
					end
			S_DATA2:
	       		if ( frame_i == 1 && irdy_i == 0 )
					nxt_pci <= TURN_AR;
				else
					begin
					nxt_pci <= S_DATA2;
					devselNX_n <= 0;
					trdyNX_n <= 0;
					end
			TURN_AR:
				if ( frame_i == 1 )
					nxt_pci <= PCIIDLE;
				else
					nxt_pci <= TURN_AR;
	    endcase
	end

	// FSM control signals
	assign adrpci = adrmem_i;
	
	assign acking = (
		( wb_ack_i == 1 || wb_err_i == 1 ) || 
		( adrcfg_i == 1 &&   irdy_i == 0)
	) ? 1'b1 : 1'b0; 

	// FSM derived Control signals
	assign idle 		= ( pst_pci <= PCIIDLE ) ? 1'b1 : 1'b0;
	assign sdata1 		= ( pst_pci <= S_DATA1 ) ? 1'b1 : 1'b0;
	assign sdata2 		= ( pst_pci <= S_DATA2 ) ? 1'b1 : 1'b0;
	assign idleNX 		= ( nxt_pci <= PCIIDLE ) ? 1'b1 : 1'b0;
	assign sdata1NX 	= ( nxt_pci <= S_DATA1 ) ? 1'b1 : 1'b0;
	assign sdata2NX 	= ( nxt_pci <= S_DATA2 ) ? 1'b1 : 1'b0;
	assign turnarNX 	= ( nxt_pci <= TURN_AR ) ? 1'b1 : 1'b0;

	// PCI Data Output Enable
	// always @( nrst_i or clk_i or cmd_i [0] or sdata1NX or turnarNX )
	always @(negedge nrst_i or posedge clk_i)
	begin
    	if ( nrst_i == 0 )
			pcidOE <= 0;
  		else
			if ( sdata1NX == 1 && cmd_i [0] == 0 )
				pcidOE <= 1;
			else 
				if ( turnarNX == 1 )
					pcidOE <= 0;
	end

	assign pcidOE_o = pcidOE;

	// PAR Output Enable
	// PCI Read data phase
	// PAR is valid 1 cicle after data is valid
	// always @( nrst_i or clk_i or cmd_i [0] or sdata2NX or turnarNX )
	always @(negedge nrst_i or posedge clk_i)
	begin
    	if ( nrst_i == 0 )
			parOE_o <= 0;
  		else
			if ( ( sdata2NX == 1 || turnarNX == 1 ) && cmd_i [0] == 0 )
				parOE_o <= 1;
			else
				parOE_o <= 0;
	end

	// Target s/t/s signals OE control
	// targOE <= '1' when ( idle = '0' and adrpci = '1' ) else '0';
	// always @( nrst_i or clk_i or sdata1NX or idleNX )
	always @(negedge nrst_i or posedge clk_i)
	begin
    	if ( nrst_i == 0 )
			targOE <= 0;
		else
			if ( sdata1NX == 1 )
				targOE <= 1;
			else 
				if ( idleNX == 1 )
					targOE <= 0;
	end
		
    // WHISBONE outs
	assign wb_cyc_o = (adrmem_i == 1 && sdata1 == 1) ? 1'b1 : 1'b0;
    assign wb_stb_o = (adrmem_i == 1 && sdata1 == 1 && irdy_i == 0 ) ? 1'b1 : 1'b0;

	// PCI(Little endian) to WB(Big endian)
	assign wb_sel_o [1] = (! cbe_i [0]) || (! cbe_i [2]);
	assign wb_sel_o [0] = (! cbe_i [1]) || (! cbe_i [3]);	

	assign wb_we_o = cmd_i [0];

	// Syncronized PCI outs
	always @(negedge nrst_i or posedge clk_i)
	begin
		if( nrst_i == 0 )
			begin
			devsel 	<= 1;
			trdy 	<= 1;
			end
		else
			begin
			devsel <= devselNX_n;
			trdy   <= trdyNX_n;
			end
	end

	assign devsel_o = ( targOE == 1 ) ? devsel : 1'bZ;
	assign trdy_o   = ( targOE == 1 ) ? trdy   : 1'bZ;

	// rd/wr Configuration Space Registers
	assign wrcfg_o = (
		adrcfg_i == 1 &&
		cmd_i [0] == 1 &&
		sdata2 == 1
	) ? 1'b1 : 1'b0;

	assign rdcfg = (
		adrcfg_i == 1 &&
		cmd_i [0] == 0 &&
		(sdata1 == 1 || sdata2 == 1)
	) ? 1'b1 : 1'b0;

	assign rdcfg_o = rdcfg;

	// LoaD enable signals
	assign pciadrLD_o = ! frame_i;
	assign wbdatLD_o  = wb_ack_i;

	// Mux control signals
	assign wbrgdMX_o = ! rdcfg;
	assign wbd16MX_o = (cbe_i [3] == 0 || cbe_i [2] == 0) ? 1'b1 : 1'b0;
	
	// debug outs 
	always @(negedge nrst_i or posedge clk_i)
	begin
		if ( nrst_i == 0 )
			debug_init <= 0;
		else
			if (devsel == 0)
				debug_init <= 1;
	end

	always @(negedge nrst_i or posedge clk_i)
	begin
		if ( nrst_i == 0 )
			debug_access <= 0;
		else
			if (wb_stb_o == 1)
				debug_access <= 1;
	end

endmodule
