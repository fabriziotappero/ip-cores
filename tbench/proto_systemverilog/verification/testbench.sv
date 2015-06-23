/**
 * Testbench file for verification environment of 10GE MAC Core.
 * @file: testbench.sv
 * @author: Pratik Mahajan
 * @par Contact: pratik@e-pigeonpost.com
 * @par Company: UCSC (SV 1896 Systemverilog for Advanced verification course)
 * 
 * @version: $LastChangedRevision$
 * @par Last Changed Date:
 * $LastChangedDate$
 * @par Last Changed By:
 * $LastChangedBy$
 */

/**
 * top block (module) mainly to instantiate all programs/modules and to generate clocks.
 * Clocks are generated as per specification requirements:
 * 	Wishbone interface clock: 30 - 156MHz
 * 	Simple Tx-Rx interface clock: 156.25 MHz
 * 	XGMII Rx interface clock: 156.25 MHz
 * 	XGMII Tx interface clock: 156.25 MHz
 * 
 * This clock generator will create Wishbone interface clock at 78.125 MHz (cause it has
 * clock time of half of 156.25)
 * @param: clkWishboneInterface (wishbone interface clock or main clock, will be used to generate all other clocks)
 * @param: clkSimpleTxRxInterface
 * @param: clkXGMIIInterfaceRx
 * @param: clkXGMIIInterfaceTx
 */

module top ();

   bit 	clkWishboneInterface;
   bit 	clkSimpleTxRxInterface;
   bit 	clkXGMIIInterfaceRx;
   bit 	clkXGMIIInterfaceTx;

   initial begin
      clkWishboneInterface   = 0;
      clkSimpleTxRxInterface = 0;
      clkXGMIIInterfaceRx    = 0;
      clkXGMIIInterfaceTx    = 0;
   end

   initial forever #1600 clkWishboneInterface = ~clkWishboneInterface;

   // Creating all other clocks from wishbone clock to make it look better and easily
   // portable (arguable) However wishbone interface clock looses flexibility of having
   // any value to create 30-156MHz range
   // Following block can be modified to have each clock generated independently
   // and having more flexibility.
   always @(posedge clkWishboneInterface) begin
//   initial forever #3200 begin
      clkSimpleTxRxInterface = ~clkSimpleTxRxInterface;
      clkXGMIIInterfaceRx    = ~clkXGMIIInterfaceRx;
      clkXGMIIInterfaceTx    = ~clkXGMIIInterfaceTx;
   end

   initial begin
      $dumpfile ("toTest.dump");
      $dumpvars (0, top);
   end
   
   // Instantiation of Interface
   macCoreInterface instInterface (	.clkWishboneInterface	(clkWishboneInterface),
					.clkTxRxInterface	(clkSimpleTxRxInterface),
					.clkXGMIIInterfaceRx	(clkXGMIIInterfaceRx),
					.clkXGMIIInterfaceTx	(clkXGMIIInterfaceTx)
					);

   // Instantiation of MAC DUT
   xge_mac instMAC ( 	// Simple Tx-Rx interface signals
		     	.clk_156m25	(instInterface.clkTxRxInterface),
		     	
			.pkt_rx_ren	(instInterface.receiveReadEnable),
			.pkt_rx_avail	(instInterface.receiveAvailable),
			.pkt_rx_data	(instInterface.receivedData),
			.pkt_rx_eop	(instInterface.receiveEndOfPacket),
			.pkt_rx_err	(instInterface.receiveError),
			.pkt_rx_mod 	(instInterface.receivePacketLengthModulus),
			.pkt_rx_sop	(instInterface.receiveStartOfPacket),
			.pkt_rx_val	(instInterface.receiveValid),
			
			.pkt_tx_data	(instInterface.transmitData),
			.pkt_tx_eop	(instInterface.transmitEndOfPacket),
			.pkt_tx_mod	(instInterface.transmitPacketLengthModulus),
			.pkt_tx_sop	(instInterface.transmitStartOfPacket),
			.pkt_tx_full	(instInterface.transmitFIFOFull),
			.pkt_tx_val	(instInterface.transmitValid),
			
			.reset_156m25_n (instInterface.rstTxRxInterface_n),

			// XGMII interface signals
			.clk_xgmii_rx	(instInterface.clkXGMIIInterfaceRx),
			.reset_xgmii_rx_n (instInterface.rstXGMIIInterfaceRx_n),
			.xgmii_rxc	(instInterface.xgmiiTransmitControl),
			.xgmii_rxd	(instInterface.xgmiiTransmitData),

			.clk_xgmii_tx	(instInterface.clkXGMIIInterfaceTx),
			.reset_xgmii_tx_n (instInterface.rstXGMIIInterfaceTx_n),
			.xgmii_txc	(instInterface.xgmiiTransmitControl),
			.xgmii_txd	(instInterface.xgmiiTransmitData),

			// Wishbone interface signals
			.wb_clk_i	(instInterface.clkWishboneInterface),
			.wb_rst_i	(instInterface.rstWishboneInterface),
			.wb_adr_i	(instInterface.wishboneInputAddress),
			.wb_cyc_i	(instInterface.wishboneCycle),
			.wb_dat_i	(instInterface.wishboneInputData),
			.wb_stb_i	(instInterface.wishboneStrobe),
			.wb_we_i	(instInterface.wishboneWriteEnable),

			.wb_ack_o	(instInterface.wishboneAck),
			.wb_dat_o	(instInterface.wishboneOutputData),
			.wb_int_o	(instInterface.wishboneInterrupt)
			);

   // Testcase instatiation
   testcase instTest (  .driverTestInterface	(instInterface.TESTMOD	),
			.monitorTestInterface	(instInterface.TESTMOD	)
			);

endmodule // top
