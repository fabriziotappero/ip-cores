//-----------------------------------------------------------------------------
// Title      : Virtex-4 Ethernet MAC Example Design Wrapper
// Project    : Virtex-4 Embedded Tri-Mode Ethernet MAC Wrapper
// File       : v4_emac_v4_8_example_design.v
// Version    : 4.8
//-----------------------------------------------------------------------------
//
// (c) Copyright 2004-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Description:  This is the Verilog example design for the Virtex-4 
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
//               the Virtex-4 Embedded Tri-Mode Ethernet MAC User Gude for
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
    // MII Interface - EMAC0
    MII_COL_0,
    MII_CRS_0,
    MII_TXD_0,
    MII_TX_EN_0,
    MII_TX_ER_0,
    MII_TX_CLK_0,
    MII_RXD_0,
    MII_RX_DV_0,
    MII_RX_ER_0,
    MII_RX_CLK_0,

    // Preserved Tie-Off Pins for EMAC0
    //SPEED_VECTOR_IN_0,
    HOSTCLK,
	 PHY_RESET_0,
    // Asynchronous Reset
    RESET,
	
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
	clk_local
);


//-----------------------------------------------------------------------------
// Port Declarations 
//-----------------------------------------------------------------------------
    // MII Interface - EMAC0
    input           MII_COL_0;
    input           MII_CRS_0;
    output   [3:0]  MII_TXD_0;
    output          MII_TX_EN_0;
    output          MII_TX_ER_0;
    input           MII_TX_CLK_0;
    input    [3:0]  MII_RXD_0;
    input           MII_RX_DV_0;
    input           MII_RX_ER_0;
    input           MII_RX_CLK_0;

    // Preserved Tie-Off Pins for EMAC0
    //input    [1:0]  SPEED_VECTOR_IN_0;
    input           HOSTCLK;
	 output				PHY_RESET_0;
   
    // Asynchronous Reset
    input           RESET;
	 
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


//-----------------------------------------------------------------------------
// Wire and Reg Declarations 
//-----------------------------------------------------------------------------

    // Global asynchronous reset
    wire            reset_i;
    // Client Interface Clocking Signals - EMAC0
    wire            tx_clk_0_i;
    wire            rx_clk_0_i;

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

    // create a synchronous reset in the transmitter clock domain
    reg       [5:0] tx_pre_reset_0_i;
    reg             tx_reset_0_i;

    // synthesis attribute ASYNC_REG of tx_pre_reset_0_i is "TRUE";

    wire host_clk_i;
	 
	 wire [1:0] SPEED_VECTOR_IN_0;

     // synthesis attribute buffer_type of host_clk_i is none;

//-----------------------------------------------------------------------------
// Main Body of Code 
//-----------------------------------------------------------------------------

   wire [7:0]  CLIENTEMAC0TXIFGDELAY;
   wire [7:0]  CLIENTEMAC1TXIFGDELAY;
   wire        CLIENTEMAC0PAUSEREQ;
   wire        CLIENTEMAC1PAUSEREQ;
   wire [15:0] CLIENTEMAC0PAUSEVAL;
   wire [15:0] CLIENTEMAC1PAUSEVAL;

   assign  CLIENTEMAC0TXIFGDELAY = 8'h3F;
   assign  CLIENTEMAC1TXIFGDELAY = 8'h3F;
   assign  CLIENTEMAC0PAUSEREQ = 0;
   assign  CLIENTEMAC1PAUSEREQ = 0;
   assign  CLIENTEMAC0PAUSEVAL = 0;
   assign  CLIENTEMAC1PAUSEVAL = 0;

    // Reset input buffer
	 
	 assign PHY_RESET_0 = ~RESET;
	 assign reset_i = RESET;

    //------------------------------------------------------------------------
    // Instantiate the EMAC Wrapper with LL FIFO 
    // (v4_emac_v4_8_locallink.v) 
    //------------------------------------------------------------------------
    v4_emac_v4_8_locallink v4_emac_ll
    (
    // Local link Receiver Interface - EMAC0
    .RX_LL_CLOCK_0                       (clk_local),
    .RX_LL_RESET_0                       (tx_reset_0_i),
    .RX_LL_DATA_0                        (rx_ll_data_0_i),
    .RX_LL_SOF_N_0                       (rx_ll_sof_n_0_i),
    .RX_LL_EOF_N_0                       (rx_ll_eof_n_0_i),
    .RX_LL_SRC_RDY_N_0                   (rx_ll_src_rdy_n_0_i),
    .RX_LL_DST_RDY_N_0                   (rx_ll_dst_rdy_n_0_i),
    .RX_LL_FIFO_STATUS_0                 (),

    // Client Clocks and Unused Receiver signals - EMAC0
    .RX_CLIENT_CLK_0                     (rx_clk_0_i),
    .EMAC0CLIENTRXDVLD                   (EMAC0CLIENTRXDVLD),
    .EMAC0CLIENTRXFRAMEDROP              (EMAC0CLIENTRXFRAMEDROP),
    .EMAC0CLIENTRXSTATS                  (EMAC0CLIENTRXSTATS),
    .EMAC0CLIENTRXSTATSVLD               (EMAC0CLIENTRXSTATSVLD),
    .EMAC0CLIENTRXSTATSBYTEVLD           (EMAC0CLIENTRXSTATSBYTEVLD),

    // Local link Transmitter Interface - EMAC0
    .TX_LL_CLOCK_0                       (clk_local),
    .TX_LL_RESET_0                       (tx_reset_0_i),
    .TX_LL_DATA_0                        (tx_ll_data_0_i),
    .TX_LL_SOF_N_0                       (tx_ll_sof_n_0_i),
    .TX_LL_EOF_N_0                       (tx_ll_eof_n_0_i),
    .TX_LL_SRC_RDY_N_0                   (tx_ll_src_rdy_n_0_i),
    .TX_LL_DST_RDY_N_0                   (tx_ll_dst_rdy_n_0_i),

    // Client Clocks and Unused Transmitter signals - EMAC0
    .TX_CLIENT_CLK_0                     (tx_clk_0_i),
    .CLIENTEMAC0TXIFGDELAY               (CLIENTEMAC0TXIFGDELAY),
    .EMAC0CLIENTTXSTATS                  (EMAC0CLIENTTXSTATS),
    .EMAC0CLIENTTXSTATSVLD               (EMAC0CLIENTTXSTATSVLD),
    .EMAC0CLIENTTXSTATSBYTEVLD           (EMAC0CLIENTTXSTATSBYTEVLD),

    // MAC Control Interface - EMAC0
    .CLIENTEMAC0PAUSEREQ                 (CLIENTEMAC0PAUSEREQ),
    .CLIENTEMAC0PAUSEVAL                 (CLIENTEMAC0PAUSEVAL),




    // MII Interface - EMAC0
    .MII_COL_0                           (MII_COL_0),
    .MII_CRS_0                           (MII_CRS_0),
    .MII_TXD_0                           (MII_TXD_0),
    .MII_TX_EN_0                         (MII_TX_EN_0),
    .MII_TX_ER_0                         (MII_TX_ER_0),
    .MII_TX_CLK_0                        (MII_TX_CLK_0),
    .MII_RXD_0                           (MII_RXD_0),
    .MII_RX_DV_0                         (MII_RX_DV_0),
    .MII_RX_ER_0                         (MII_RX_ER_0),
    .MII_RX_CLK_0                        (MII_RX_CLK_0),

    // Preserved Tie-Off Pins for EMAC0
    .SPEED_VECTOR_IN_0                  (SPEED_VECTOR_IN_0), 
    .HOSTCLK                             (host_clk_i),
    // Asynchronous Reset Input
    .RESET                               (reset_i));

	 assign SPEED_VECTOR_IN_0 = 2'b01;

    //-------------------------------------------------------------------
    //  Instatiate the address swapping module
    //-------------------------------------------------------------------
    /*address_swap_module_8 client_side_asm_emac0 
      (.rx_ll_clock(tx_clk_0_i),
       .rx_ll_reset(tx_reset_0_i),
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
		 .clk(clk_local),
		 .rst(reset_i),
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
	 
	 // Processor Clock Generation
	 
	wire	sysclk_u;
	wire	sysclk_l;
	wire	dcmreset;
	 
	 DCM_BASE #(
		.CLKIN_PERIOD(10),
		.CLK_FEEDBACK("NONE"),
		.CLKFX_DIVIDE(4),
		.CLKFX_MULTIPLY(2)
	 ) dcm_patlpp (
		.CLKFX(sysclk_u),
		.LOCKED(sysclk_l),
		.CLKIN(host_clk_i),
		.RST(reset_i)
	 );
	 BUFG bufg_ll_clk (.I(sysclk_u), .O(clk_local));
	 
	 dcm_reset dcm_reset_inst (
		.ref_reset(reset_i),
		.ref_clk(host_clk_i),
		.dcm_locked(sysclk_l),
		.dcm_reset(dcmreset)
	);
	 
	 //assign clk_local = host_clk_i;
	 
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
	 always @(outport_addr or out_src_rdy_p or tx_ll_dst_rdy_n_0_i or out_dst_rdy_usr)
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
    always @(posedge clk_local, posedge reset_i)
    begin
      if (reset_i === 1'b1)
      begin
        tx_pre_reset_0_i <= 6'h3F;
        tx_reset_0_i     <= 1'b1;
      end
      else
      begin
        tx_pre_reset_0_i[0]   <= 1'b0;
        tx_pre_reset_0_i[5:1] <= tx_pre_reset_0_i[4:0];
        tx_reset_0_i          <= tx_pre_reset_0_i[5];
      end
    end
     


    //----------------------------------------------------------------------
    // HOSTCLK Clock Management - Clock input for the generic management 
    // interface. This clock could be tied to a 125MHz reference clock 
    // to save on clocking resources
    //----------------------------------------------------------------------
   IBUF host_clk      (.I(HOSTCLK),              .O(host_clk_i));

//    assign host_clk_i = HOSTCLK;


endmodule
