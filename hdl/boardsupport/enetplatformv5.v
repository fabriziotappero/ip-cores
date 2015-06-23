// Ethernet Platform Top Module

//-----------------------------------------------------------------------------
// Title      : Virtex-5 Ethernet MAC Example Design Wrapper
// Project    : Virtex-5 Ethernet MAC Wrappers
//-----------------------------------------------------------------------------
// File       : v5_emac_v1_6_example_design.v
//-----------------------------------------------------------------------------
// Copyright (c) 2004-2008 by Xilinx, Inc. All rights reserved.
// This text/file contains proprietary, confidential
// information of Xilinx, Inc., is distributed under license
// from Xilinx, Inc., and may be used, copied and/or
// disclosed only pursuant to the terms of a valid license
// agreement with Xilinx, Inc. Xilinx hereby grants you
// a license to use this text/file solely for design, simulation,
// implementation and creation of design files limited
// to Xilinx devices or technologies. Use with non-Xilinx
// devices or technologies is expressly prohibited and
// immediately terminates your license unless covered by
// a separate agreement.
//
// Xilinx is providing this design, code, or information
// "as is" solely for use in developing programs and
// solutions for Xilinx devices. By providing this design,
// code, or information as one possible implementation of
// this feature, application or standard, Xilinx is making no
// representation that this implementation is free from any
// claims of infringement. You are responsible for
// obtaining any rights you may require for your implementation.
// Xilinx expressly disclaims any warranty whatsoever with
// respect to the adequacy of the implementation, including
// but not limited to any warranties or representations that this
// implementation is free from claims of infringement, implied
// warranties of merchantability or fitness for a particular
// purpose.
//
// Xilinx products are not intended for use in life support
// appliances, devices, or systems. Use in such applications are
// expressly prohibited.
//
// This copyright and support notice must be retained as part
// of this text at all times. (c) Copyright 2004-2008 Xilinx, Inc.
// All rights reserved.
//
//-----------------------------------------------------------------------------
// Description:  This is the Verilog example design for the Virtex-5 
//               Embedded Ethernet MAC.  It is intended that
//               this example design can be quickly adapted and downloaded onto
//               an FPGA to provide a real hardware test environment.
//
//               This level:
//
//               * instantiates the TEMAC local link file that instantiates 
//                 the TEMAC top level together with a RX and TX FIFO with a 
//                 local link interface;
//
//               * instantiates a simple client I/F side example design,
//                 providing an address swap and a simple
//                 loopback function;
//
//               * Instantiates IBUFs on the GTX_CLK, REFCLK and HOSTCLK inputs 
//                 if required;
//
//               Please refer to the Datasheet, Getting Started Guide, and
//               the Virtex-5 Embedded Tri-Mode Ethernet MAC User Gude for
//               further information.
//
//
//
//    ---------------------------------------------------------------------
//    | EXAMPLE DESIGN WRAPPER                                            |
//    |           --------------------------------------------------------|
//    |           |LOCAL LINK WRAPPER                                     |
//    |           |              -----------------------------------------|
//    |           |              |BLOCK LEVEL WRAPPER                     |
//    |           |              |    ---------------------               |
//    | --------  |  ----------  |    | ETHERNET MAC      |               |
//    | |      |  |  |        |  |    | WRAPPER           |  ---------    |
//    | |      |->|->|        |--|--->| Tx            Tx  |--|       |--->|
//    | |      |  |  |        |  |    | client        PHY |  |       |    |
//    | | ADDR |  |  | LOCAL  |  |    | I/F           I/F |  |       |    |  
//    | | SWAP |  |  |  LINK  |  |    |                   |  | PHY   |    |
//    | |      |  |  |  FIFO  |  |    |                   |  | I/F   |    |
//    | |      |  |  |        |  |    |                   |  |       |    |
//    | |      |  |  |        |  |    | Rx            Rx  |  |       |    |
//    | |      |  |  |        |  |    | client        PHY |  |       |    |
//    | |      |<-|<-|        |<-|----| I/F           I/F |<-|       |<---|
//    | |      |  |  |        |  |    |                   |  ---------    |
//    | --------  |  ----------  |    ---------------------               |
//    |           |              -----------------------------------------|
//    |           --------------------------------------------------------|
//    ---------------------------------------------------------------------
//
//-----------------------------------------------------------------------------


`timescale 1 ps / 1 ps


//-----------------------------------------------------------------------------
// The module declaration for the example design.
//-----------------------------------------------------------------------------
module enetplatform
(
    // SGMII Interface - EMAC0
    TXP_0,
    TXN_0,
    RXP_0,
    RXN_0,

    // SGMII MGT Clock buffer inputs 
    MGTCLK_N,
    MGTCLK_P, 

    // reset for ethernet phy
    PHY_RESET_0,

    // GTP link status
    GTP_READY,

    // Asynchronous Reset
    RESET,
	
	// CPU RESET
	RESET_CPU,
	
	// User Connections
	in_src_rdy_usr,
	out_dst_rdy_usr,
	in_data_usr,
	in_sof_usr,
	in_eof_usr,
	in_dst_rdy_usr,
	out_src_rdy_usr,
	out_data_usr,
	out_sof_usr,
	out_eof_usr,
	outport_usr,
	inport_usr,
	clk_local,
	rst_local
);


//-----------------------------------------------------------------------------
// Port Declarations 
//-----------------------------------------------------------------------------

    // SGMII Interface - EMAC0
    output          TXP_0;
    output          TXN_0;
    input           RXP_0;
    input           RXN_0;
   
    // SGMII MGT Clock buffer inputs 
    input           MGTCLK_N;
    input           MGTCLK_P;

    // reset for ethernet phy
    output          PHY_RESET_0;

    // GTP link status
    output          GTP_READY;

    // Asynchronous Reset
    input           RESET;
	 
	 // CPU RESET
	 input 				RESET_CPU;
    
	 // User Connections
	 input in_src_rdy_usr;
	 input out_dst_rdy_usr;
	 input [7:0] in_data_usr;
	 input in_sof_usr;
	 input in_eof_usr;
	 output in_dst_rdy_usr;
	 output out_src_rdy_usr;
	 output [7:0] out_data_usr;
	 output out_sof_usr;
	 output out_eof_usr;
	 output [3:0] outport_usr;
	 output [3:0] inport_usr;
	 output clk_local;
	 output rst_local;
	 
//-----------------------------------------------------------------------------
// Wire and Reg Declarations 
//-----------------------------------------------------------------------------

    // Global asynchronous reset
    wire            reset_i;
    // Local Link Interface Clocking Signal - EMAC0
    wire            ll_clk_0_i;

    // address swap transmitter connections - EMAC0
    wire      [7:0] tx_ll_data_0_i;
    wire            tx_ll_sof_n_0_i;
    wire            tx_ll_eof_n_0_i;
    wire            tx_ll_src_rdy_n_0_i;
    wire            tx_ll_dst_rdy_n_0_i;

    // address swap receiver connections - EMAC0
    wire      [7:0] rx_ll_data_0_i;
    wire            rx_ll_sof_n_0_i;
    wire            rx_ll_eof_n_0_i;
    wire            rx_ll_src_rdy_n_0_i;
    wire            rx_ll_dst_rdy_n_0_i;

    // create a synchronous reset in the local link clock domain
    reg       [5:0] ll_pre_reset_0_i;
    reg             ll_reset_0_i;

    // synthesis attribute ASYNC_REG of tx_pre_reset_0_i is "TRUE";

    // Reset signals from the transceiver
    wire            resetdone_0_i;

    // EMAC0 Clocking signals

    // Transceiver output clock (REFCLKOUT at 125MHz)
    wire            clk125_o;
    // 125MHz clock input to wrappers
	 (* KEEP = "True" *)
    wire            clk125;
    // Input 125MHz differential clock for transceiver
    wire            clk_ds;

    // 1.25/12.5/125MHz clock signals for tri-speed SGMII
    wire            client_clk_0_o;
	 (* KEEP = "True" *)
    wire            client_clk_0;

    // GT reset signal
    wire gtreset;
    reg  [3:0] reset_r;
    // synthesis attribute ASYNC_REG of reset_r             is "TRUE";

	wire	sysclk_u;
	wire	sysclk_l;
	wire	reset_cpu_h, reset_cpu_i;



//-----------------------------------------------------------------------------
// Main Body of Code 
//-----------------------------------------------------------------------------

    // Phy reset
    assign PHY_RESET_0 = ~reset_i;
    
    assign GND = 0;

	 reg [4:0] reset_cpu_cnt = {1,1,1,1,1};
	 always @(posedge ll_clk_0_i)
	 begin
		if (reset_cpu_i | ~sysclk_l)
		begin
			reset_cpu_cnt <= {1,1,1,1,1};
		end
		else
		begin
			reset_cpu_cnt[3:0] <= reset_cpu_cnt[4:1];
			reset_cpu_cnt[4] <= 0;
		end
	 end
	 
    // Reset input buffer
    IBUF reset_ibuf (.I(RESET), .O(reset_i));
	 assign reset_cpu_i = RESET_CPU;
	 assign reset_cpu_h = reset_cpu_cnt[0];
	 assign rst_local = reset_cpu_h;
	 

    // EMAC0 Clocking

    // Generate the clock input to the GTP
    // clk_ds can be shared between multiple MAC instances.
    IBUFDS clkingen (
      .I(MGTCLK_P),
      .IB(MGTCLK_N),
      .O(clk_ds));

    // 125MHz from transceiver is routed through a BUFG and
    // input to the MAC wrappers.
    // This clock can be shared between multiple MAC instances.
    BUFG bufg_clk125 (.I(clk125_o), .O(clk125));

	 
	 // Processor Clock Generation
	 DCM_BASE #(
		.CLKIN_PERIOD(8),
		.CLK_FEEDBACK("NONE"),
		.CLKFX_DIVIDE(5),
		.CLKFX_MULTIPLY(3)
	 ) dcm_patlpp (
		.CLKFX(sysclk_u),
		.LOCKED(sysclk_l),
		.CLKIN(clk125),
		.RST(gtreset)
	 );
	 BUFG bufg_ll_clk (.I(sysclk_u), .O(ll_clk_0_i));
	 
    //assign ll_clk_0_i = clk125;

    // 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    // input to the MAC wrappers to clock the client interface.
    BUFG bufg_client_0 (.I(client_clk_0_o), .O(client_clk_0));
    //--------------------------------------------------------------------
    //-- RocketIO PMA reset circuitry
    //--------------------------------------------------------------------
    always@(posedge reset_i, posedge clk125)
    begin
      if (reset_i == 1'b1)
      begin
        reset_r <= 4'b1111;
      end
      else
      begin
        reset_r <= {reset_r[2:0], reset_i};
      end
    end

    assign gtreset = reset_r[3];

    //------------------------------------------------------------------------
    // Instantiate the EMAC Wrapper with LL FIFO 
    // (v5_emac_v1_6_locallink.v) 
    //------------------------------------------------------------------------
    v5_emac_v1_6_locallink v5_emac_ll
    (
    // EMAC0 Clocking
    // 125MHz clock output from transceiver
    .CLK125_OUT                          (clk125_o),
    // 125MHz clock input from BUFG
    .CLK125                              (clk125),
    // Tri-speed clock output from EMAC0
    .CLIENT_CLK_OUT_0                    (client_clk_0_o),
    // EMAC0 Tri-speed clock input from BUFG
    .CLIENT_CLK_0                        (client_clk_0),

    // Local link Receiver Interface - EMAC0
    .RX_LL_CLOCK_0                       (ll_clk_0_i),
    .RX_LL_RESET_0                       (ll_reset_0_i),
    .RX_LL_DATA_0                        (rx_ll_data_0_i),
    .RX_LL_SOF_N_0                       (rx_ll_sof_n_0_i),
    .RX_LL_EOF_N_0                       (rx_ll_eof_n_0_i),
    .RX_LL_SRC_RDY_N_0                   (rx_ll_src_rdy_n_0_i),
    .RX_LL_DST_RDY_N_0                   (rx_ll_dst_rdy_n_0_i),
    .RX_LL_FIFO_STATUS_0                 (),

    // Unused Receiver signals - EMAC0
    .EMAC0CLIENTRXDVLD                   (),
    .EMAC0CLIENTRXFRAMEDROP              (),
    .EMAC0CLIENTRXSTATS                  (),
    .EMAC0CLIENTRXSTATSVLD               (),
    .EMAC0CLIENTRXSTATSBYTEVLD           (),

    // Local link Transmitter Interface - EMAC0
    .TX_LL_CLOCK_0                       (ll_clk_0_i),
    .TX_LL_RESET_0                       (ll_reset_0_i),
    .TX_LL_DATA_0                        (tx_ll_data_0_i),
    .TX_LL_SOF_N_0                       (tx_ll_sof_n_0_i),
    .TX_LL_EOF_N_0                       (tx_ll_eof_n_0_i),
    .TX_LL_SRC_RDY_N_0                   (tx_ll_src_rdy_n_0_i),
    .TX_LL_DST_RDY_N_0                   (tx_ll_dst_rdy_n_0_i),

    // Unused Transmitter signals - EMAC0
    .CLIENTEMAC0TXIFGDELAY               (8'h00),
    .EMAC0CLIENTTXSTATS                  (),
    .EMAC0CLIENTTXSTATSVLD               (),
    .EMAC0CLIENTTXSTATSBYTEVLD           (),

    // MAC Control Interface - EMAC0
    .CLIENTEMAC0PAUSEREQ                 (1'b0),
    .CLIENTEMAC0PAUSEVAL                 (16'h0000),

    //EMAC-MGT link status
    .EMAC0CLIENTSYNCACQSTATUS            (GTP_READY),
    .EMAC0ANINTERRUPT                    (),



    // SGMII Interface - EMAC0
    .TXP_0                               (TXP_0),
    .TXN_0                               (TXN_0),
    .RXP_0                               (RXP_0),
    .RXN_0                               (RXN_0),
    .PHYAD_0                             (5'b00010),
    .RESETDONE_0                         (resetdone_0_i),

    // unused transceiver
    .TXN_1_UNUSED                        (),
    .TXP_1_UNUSED                        (),
    .RXN_1_UNUSED                        (1'b1),
    .RXP_1_UNUSED                        (1'b0),

    // SGMII MGT Clock buffer inputs 
    .CLK_DS                              (clk_ds), 
    .GTRESET                             (gtreset), 

    // Asynchronous Reset Input
    .RESET                               (reset_i)
	 );

    //-------------------------------------------------------------------
    //  Instatiate the address swapping module
    //-------------------------------------------------------------------
    /*address_swap_module_8 client_side_asm_emac0 
      (.rx_ll_clock(ll_clk_0_i),
       .rx_ll_reset(ll_reset_0_i),
       .rx_ll_data_in(rx_ll_data_0_i),
       .rx_ll_sof_in_n(rx_ll_sof_n_0_i),
       .rx_ll_eof_in_n(rx_ll_eof_n_0_i),
       .rx_ll_src_rdy_in_n(rx_ll_src_rdy_n_0_i),
       .rx_ll_data_out(tx_ll_data_0_i),
       .rx_ll_sof_out_n(tx_ll_sof_n_0_i),
       .rx_ll_eof_out_n(tx_ll_eof_n_0_i),
       .rx_ll_src_rdy_out_n(tx_ll_src_rdy_n_0_i),
       .rx_ll_dst_rdy_in_n(tx_ll_dst_rdy_n_0_i)
    );*/

	wire out_sof_p, out_eof_p, out_src_rdy_p, out_dst_rdy_p;
	wire in_sof_p, in_eof_p, in_src_rdy_p, in_dst_rdy_p;
	wire pp_enable;
	wire [3:0] port_addr;
	wire [3:0] outport_addr;
	wire [3:0] inport_addr;
	reg [7:0] in_data_p;
	reg [7:0] DIP_r;
	
	reg out_sof_pr, out_eof_pr, out_src_rdy_pr, out_dst_rdy_pr;
	reg in_sof_pr, in_eof_pr, in_src_rdy_pr, in_dst_rdy_pr;

	assign pp_enable = 1;

	 patlpp pp
	 (
		 .en(pp_enable),
		 .clk(ll_clk_0_i),
		 .rst(reset_cpu_h),
		 .in_sof(in_sof_p),
		 .in_eof(in_eof_p),
		 .in_src_rdy(in_src_rdy_p),
		 .in_dst_rdy(in_dst_rdy_p),
		 .out_sof(out_sof_p),
		 .out_eof(out_eof_p),
		 .out_src_rdy(out_src_rdy_p),
		 .out_dst_rdy(out_dst_rdy_p),
		 .in_data(in_data_p),
		 .out_data(tx_ll_data_0_i),
		 .outport_addr(outport_addr),
		 .inport_addr(inport_addr)//,
		 //.chipscope_data(chipscope_data_pp)
	 );

	 assign tx_ll_sof_n_0_i = ~out_sof_p;
	 assign tx_ll_eof_n_0_i = ~out_eof_p;
	 assign tx_ll_src_rdy_n_0_i = ~out_src_rdy_pr;
	 assign rx_ll_dst_rdy_n_0_i = ~in_dst_rdy_pr;
	 assign in_sof_p = in_sof_pr;
	 assign in_eof_p = in_eof_pr;
	 assign in_src_rdy_p = in_src_rdy_pr;
	 assign out_dst_rdy_p = out_dst_rdy_pr;
	 
	 assign in_dst_rdy_usr = in_dst_rdy_p;
	 assign out_src_rdy_usr = out_src_rdy_p;
	 assign outport_usr = outport_addr;
	 assign inport_usr = inport_addr;
	 assign out_data_usr = tx_ll_data_0_i;
	 assign out_sof_usr = out_sof_p;
	 assign out_eof_usr = out_eof_p;
	 
	 assign clk_local = ll_clk_0_i;
	 
	 // In Port
	 always @(inport_addr or rx_ll_src_rdy_n_0_i or rx_ll_data_0_i or in_dst_rdy_p or rx_ll_sof_n_0_i or rx_ll_eof_n_0_i or in_src_rdy_usr or in_data_usr or in_sof_usr or in_eof_usr)
	 begin
		case (inport_addr)
			0:
			begin
				in_src_rdy_pr <= ~rx_ll_src_rdy_n_0_i;
				in_dst_rdy_pr <= in_dst_rdy_p;
				in_data_p <= rx_ll_data_0_i;
				in_sof_pr <= ~rx_ll_sof_n_0_i;
				in_eof_pr <= ~rx_ll_eof_n_0_i;
			end
			default:
			begin
				in_src_rdy_pr <= in_src_rdy_usr;
				in_dst_rdy_pr <= 0;
				in_data_p <= in_data_usr;
				in_sof_pr <= in_sof_usr;
				in_eof_pr <= in_eof_usr;
			end
		endcase
	 end
	 
	 // Out Port
	 always @(outport_addr or out_src_rdy_p or tx_ll_dst_rdy_n_0_i)
	 begin
		case (outport_addr)
			0:
			begin
				out_src_rdy_pr <= out_src_rdy_p;
				out_dst_rdy_pr <= ~tx_ll_dst_rdy_n_0_i;
			end
			default:
			begin
				out_src_rdy_pr <= 0;
				out_dst_rdy_pr <= out_dst_rdy_usr;
			end
		endcase
	 end
	 
	 
   //assign rx_ll_dst_rdy_n_0_i   = tx_ll_dst_rdy_n_0_i;

    // Create synchronous reset in the transmitter clock domain.
    always @(posedge ll_clk_0_i, posedge reset_i)
    begin
      if (reset_i === 1'b1)
      begin
        ll_pre_reset_0_i <= 6'h3F;
        ll_reset_0_i     <= 1'b1;
      end
      else if (resetdone_0_i === 1'b1)
      begin
        ll_pre_reset_0_i[0]   <= 1'b0;
        ll_pre_reset_0_i[5:1] <= ll_pre_reset_0_i[4:0];
        ll_reset_0_i          <= ll_pre_reset_0_i[5];
      end
    end
     

endmodule
