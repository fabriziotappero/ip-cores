`timescale  100 ps / 10 ps
//-------------------------------------
// SP601_BRD_CLOCKS.v
//-------------------------------------
// History of Changes:
//	5-5-2009 Initial creation
//  6-15-2009 Added PLL to generate MCB clocks, also used PLL to generate some others.
//-------------------------------------
// This module contains all of the clock related stuff
//-------------------------------------
//
module SP605_BRD_CLOCKS(

// Differential sys clock	  
input	wire		SYSCLK_P,SYSCLK_N,

output	wire		CLK20,      // 20 Mhz
output	wire		CLK200,     // 200 Mhz
output	wire		PROC_CLK,   // Processing Clock (200 Mhz?)
output	wire		CLK125,  // 125 Mhz

// Master Clock for memory controller block 
output	wire		MCBCLK_2X_0,   // CLKOUT0 from PLL @ 667 MHz
output	wire		MCBCLK_2X_180, // CLKOUT1 from PLL @ 667 MHz, 180 degree phase
output	wire		MCBCLK_PLL_LOCK, CLK_PLL_LOCK,// from PLL 
output	wire		CALIB_CLK, // GCLK.  MIN = 50MHz, MAX = 100MHz.

// 125 Mhz clocks (from PHY RXCLK)
input	wire		PHY_RXCLK,
output	wire		CLK125_RX,   // 125 Mhz
output  wire            CLK125_RX_BUFIO,
input	wire		RST // system reset - resets PLLs, DCM's

);

parameter [7:0]	PROC_CLK_FREQ = 8'd100;

/* System Clock */
// IBUFG the raw clock input
wire				osc_clk_ibufg;
IBUFGDS #(
  .DIFF_TERM("FALSE"),    // Differential Termination (Virtex-4/5, Spartan-3E/3A)
  .IBUF_DELAY_VALUE("0"), // Specify the amount of added input delay for 
                          //   the buffer, "0"-"16" (Spartan-3E/3A only)
  .IOSTANDARD("LVDS_25")  // Specify the input I/O standard
) inibufg (
  .O(osc_clk_ibufg),  // Clock buffer output
  .I(SYSCLK_P),  // Diff_p clock buffer input (connect directly to top-level port)
  .IB(SYSCLK_N) // Diff_n clock buffer input (connect directly to top-level port)
);

	wire	clk20_bufg_in, calib_clk_bufg_in, clk200_bufg_in, proc_clk_bufg_in; // raw PLL outputs
	BUFG clk20_bufg     (.I(clk20_bufg_in),     .O(CLK20) );
	BUFG calib_clk_bufg (.I(calib_clk_bufg_in), .O(CALIB_CLK) );
	BUFG clk200_bufg    (.I(clk200_bufg_in),    .O(CLK200) );
	BUFG proc_clk_bufg  (.I(proc_clk_bufg_in),  .O(PROC_CLK) );


	wire    clkfbout_clkfbin; // Clock from PLLFBOUT to PLLFBIN
	wire    clkfbout_clkfbin_125; // Clock from PLLFBOUT to PLLFBIN

	PLL_ADV #
		(
		.BANDWIDTH          ("OPTIMIZED"),
		.CLKIN1_PERIOD      (5), // 200 MHz = 5ns
		.CLKIN2_PERIOD      (1),
		.DIVCLK_DIVIDE      (3),
		.CLKFBOUT_MULT      (10), // 200 MHz x 10 / 3 = 667 Mhz
		.CLKFBOUT_PHASE     (0.0),
		.CLKOUT0_DIVIDE     (1), // 667 Mhz /1  = 667 Mhz
		.CLKOUT1_DIVIDE     (1), // 667 Mhz /1  = 667 Mhz
		.CLKOUT2_DIVIDE     (),
		.CLKOUT3_DIVIDE     (),
		.CLKOUT4_DIVIDE     (),
		.CLKOUT5_DIVIDE     (),
		.CLKOUT0_PHASE      (0.000),
		.CLKOUT1_PHASE      (180.000),
		.CLKOUT2_PHASE      (0.000),
		.CLKOUT3_PHASE      (0.000),
		.CLKOUT4_PHASE      (0.000),
		.CLKOUT5_PHASE      (0.000),
		.CLKOUT0_DUTY_CYCLE (0.500),
		.CLKOUT1_DUTY_CYCLE (0.500),
		.CLKOUT2_DUTY_CYCLE (0.500),
		.CLKOUT3_DUTY_CYCLE (0.500),
		.CLKOUT4_DUTY_CYCLE (0.500),
		.CLKOUT5_DUTY_CYCLE (0.500),
		.COMPENSATION       ("SYSTEM_SYNCHRONOUS"),
		.REF_JITTER         (0.005000)
		)
	u_pll_adv
		(
		.CLKFBIN     (clkfbout_clkfbin),
		.CLKINSEL    (1'b1),
		.CLKIN1      (osc_clk_ibufg),
		.CLKIN2      (1'b0),
		.DADDR       (5'b0),
		.DCLK        (1'b0),
		.DEN         (1'b0),
		.DI          (16'b0),
		.DWE         (1'b0),
		.REL         (1'b0),
		.RST         (RST),
		.CLKFBDCM    (),
		.CLKFBOUT    (clkfbout_clkfbin),
		.CLKOUTDCM0  (),
		.CLKOUTDCM1  (),
		.CLKOUTDCM2  (),
		.CLKOUTDCM3  (),
		.CLKOUTDCM4  (),
		.CLKOUTDCM5  (),
		.CLKOUT0     (MCBCLK_2X_0),
		.CLKOUT1     (MCBCLK_2X_180),
		.CLKOUT2     (),
		.CLKOUT3     (),
		.CLKOUT4     (),
		.CLKOUT5     (),
		.DO          (),
		.DRDY        (),
		.LOCKED      (MCBCLK_PLL_LOCK)
		);


wire			xclk125_tx;
BUFG bufg125_tx(.I(xclk125_tx), .O(CLK125));


	PLL_ADV #
		(
		.BANDWIDTH          ("OPTIMIZED"),
		.CLKIN1_PERIOD      (5), // 200 MHz = 5ns
		.CLKIN2_PERIOD      (1),
		.DIVCLK_DIVIDE      (1),
		.CLKFBOUT_MULT      (5), // 200 * 5 = 1000 MHz 
		.CLKFBOUT_PHASE     (0.0),
		.CLKOUT0_DIVIDE     (8), // 125 MHz
		.CLKOUT1_DIVIDE     (5), // 200 MHz
		.CLKOUT2_DIVIDE     (50), // 20 MHz
		.CLKOUT3_DIVIDE     (20), // 50 MHz
		.CLKOUT4_DIVIDE     (32), // 1000 / 32 = 31.25 MHz
		.CLKOUT5_DIVIDE     (),
		.CLKOUT0_PHASE      (0.000),
		.CLKOUT1_PHASE      (180.000),
		.CLKOUT2_PHASE      (0.000),
		.CLKOUT3_PHASE      (0.000),
		.CLKOUT4_PHASE      (0.000),
		.CLKOUT5_PHASE      (0.000),
		.CLKOUT0_DUTY_CYCLE (0.500),
		.CLKOUT1_DUTY_CYCLE (0.500),
		.CLKOUT2_DUTY_CYCLE (0.500),
		.CLKOUT3_DUTY_CYCLE (0.500),
		.CLKOUT4_DUTY_CYCLE (0.500),
		.CLKOUT5_DUTY_CYCLE (0.500),
		.COMPENSATION       ("SYSTEM_SYNCHRONOUS"),
		.REF_JITTER         (0.005000)
		)
	u_pll_adv_125
		(
		.CLKFBIN     (clkfbout_clkfbin_125),
		.CLKINSEL    (1'b1),
		.CLKIN1      (osc_clk_ibufg),
		.CLKIN2      (1'b0),
		.DADDR       (5'b0),
		.DCLK        (1'b0),
		.DEN         (1'b0),
		.DI          (16'b0),
		.DWE         (1'b0),
		.REL         (1'b0),
		.RST         (RST),
		.CLKFBDCM    (),
		.CLKFBOUT    (clkfbout_clkfbin_125),
		.CLKOUTDCM0  (),
		.CLKOUTDCM1  (),
		.CLKOUTDCM2  (),
		.CLKOUTDCM3  (),
		.CLKOUTDCM4  (),
		.CLKOUTDCM5  (),
		.CLKOUT0     (xclk125_tx),
		.CLKOUT1     (clk200_bufg_in),
		.CLKOUT2     (clk20_bufg_in),
		.CLKOUT3     (calib_clk_bufg_in),
		.CLKOUT4     (proc_clk_bufg_in),
		.CLKOUT5     (),
		.DO          (),
		.DRDY        (),
		.LOCKED      (CLK_PLL_LOCK)
		);



wire			phy_rxclk_ibufg;
//psk replaced IBUFG with BUFIO2 
IBUFG ibufg125rx(.I(PHY_RXCLK), .O(CLK125_RX_int));




//---------------------------------------------------------------------------
// GMII Receiver Clock Logic
//---------------------------------------------------------------------------

// Route gmii_rx_clk through a BUFIO2/BUFG and onto global clock routing
  BUFIO2 bufio_gmii_rx_clk (
     .DIVCLK           (),
     .I                (CLK125_RX_int),
     .IOCLK            (CLK125_RX_BUFIO),
     .SERDESSTROBE     ()
  );

   // Route rx_clk through a BUFG onto global clock routing
   BUFG bufg_gmii_rx_clk (
      .I                (CLK125_RX_int),
      .O                (CLK125_RX)
   );


endmodule
