//*****************************************************************************/
// Module :     sata_phy
// Version:     1.0
// Author:      Ashwin Mendon 
// Description: This module provides a wrapper for the SATA GTX wrapper modules
//              the Out of Band Signaling controller module and the clock generating
//              modules
//              It has been modified from Xilinx XAPP870 to support Virtex 6 GTX
//              transceivers 
//*****************************************************************************/

module sata_phy 
(
	sata_phy_ila_control,
	oob_control_ila_control,
        REFCLK_PAD_P_IN,	       
	REFCLK_PAD_N_IN,	       
	TXP0_OUT,
	TXN0_OUT,
	RXP0_IN,
	RXN0_IN,		
	PLLLKDET_OUT_N,			
	DCMLOCKED_OUT,
	LINKUP_led,
 	GEN2_led,
	sata_user_clk,
	LINKUP,
	align_en_out,
        tx_datain,
        tx_charisk_in,
	rx_dataout,
	rx_charisk_out,
        CurrentState_out,
        rxelecidle_out,
	GTXRESET_IN,			
        CLKIN_150
 );
    
        parameter  CHIPSCOPE            = "FALSE";
        input  [35:0]   sata_phy_ila_control;
        input  [35:0]   oob_control_ila_control;
	input		REFCLK_PAD_P_IN;	// GTX reference clock input
	input		REFCLK_PAD_N_IN;	// GTX reference clock input
	input           RXP0_IN;		// Receiver input
	input           RXN0_IN;		// Receiver input
	input		GTXRESET_IN;		// Main GTX reset
        input           CLKIN_150;              // GTX reference clock input
        // Input from Link Layer
        input  [31:0]   tx_datain;              
        input           tx_charisk_in;          
       	
	output		DCMLOCKED_OUT;		// DCM locked 
	output 		PLLLKDET_OUT_N;	        // PLL Lock Detect
	output		TXP0_OUT;
	output		TXN0_OUT;
	output		LINKUP;
	output		LINKUP_led;
	output		GEN2_led;
	output		align_en_out;
	output		sata_user_clk;
        // Outputs to Link Layer
        output  [31:0]  rx_dataout;       
	output  [3:0]   rx_charisk_out;
	output	[7:0]	CurrentState_out;
        output          rxelecidle_out;
        

	wire	[3:0]	rxcharisk;
        // OOB generate and detect
	wire		txcominit, txcomwake;
	wire		cominitdet, comwakedet;
        // OOB generate and detect
	wire		sync_det_out, align_det_out;
	wire		tx_charisk_out;
	wire		txelecidle,   rxelecidle0, rxelecidle1, rxenelecidleresetb; 
	wire		resetdone0, resetdone1;
	wire	[31:0]	txdata, rxdata; // TX/RX data
	wire	[31:0]	rxdataout; // RX USER data
	wire	[4:0]	state_out;
	wire		PLLLKDET_OUT;
 	wire 		linkup, linkup_led_out;
 	wire 		align_en_out;
	wire		clk0, clk2x, dcm_clk0, dcm_clkdv, dcm_clk2x; // DCM output clocks
	wire		mmcm_locked;
	wire		GEN2; //this is the selection for GEN2 when set to 1
	wire		speed_neg_rst;
	wire		rxreset;	//GTX Rxreset
	wire 	        RXBYTEREALIGN0, RXBYTEISALIGNED0;
	wire 		RXRECCLK0;
	wire 		mmcm_reset;
	wire 		rst_debounce;
	wire 		mmcm_clk_in;   
	wire 		gtx_refclk;   
	wire 		gtx_refclk_bufg;   
	wire 		gtx_reset;   
   
	wire 		rst_0;
	reg  		rst_1;  
	reg  		rst_2;
	reg  		rst_3;

        // Clock counters to check clock toggle
        reg    [15:0]   gtx_refclk_count;
        reg    [15:0]   gtx_refclk_bufg_count;
        reg    [15:0]   gtx_txoutclk_count;
        reg    [15:0]   gtx_txusrclk_count;
        reg    [15:0]   gtx_txusrclk2_count;
        reg    [15:0]   CLKIN_150_count;

	
//------------------------ MGT Wrapper Wires ------------------------------
    //________________________________________________________________________
    //________________________________________________________________________
    //GTX0   (X0Y4)

    //---------------------- Loopback and Powerdown Ports ----------------------
    wire    [2:0]   gtx0_loopback_i;
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    wire    [3:0]   gtx0_rxdisperr_i;
    wire    [3:0]   gtx0_rxnotintable_i;
    //----------------- Receive Ports - Clock Correction Ports -----------------
    wire    [2:0]   gtx0_rxclkcorcnt_i;
    //------------- Receive Ports - Comma Detection and Alignment --------------
    wire            gtx0_rxbyteisaligned_i;
    wire            gtx0_rxbyterealign_i;
    wire            gtx0_rxenmcommaalign_i;
    wire            gtx0_rxenpcommaalign_i;
    //----------------- Receive Ports - RX Data Path interface -----------------
    wire    [31:0]  gtx0_rxdata_i;
    wire            gtx0_rxrecclk_i;
    wire            gtx0_rxreset_i;
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    wire            gtx0_rxelecidle_i;
    wire    [2:0]   gtx0_rxeqmix_i;
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    wire            gtx0_rxbufreset_i;
    wire    [2:0]   gtx0_rxstatus_i;
    //---------------------- Receive Ports - RX PLL Ports ----------------------
    wire            gtx0_gtxrxreset_i;
    wire            gtx0_pllrxreset_i;
    wire            gtx0_rxplllkdet_i;
    wire            gtx0_rxresetdone_i;
    //------------------- Receive Ports - RX Ports for SATA --------------------
    wire            gtx0_cominitdet_i;
    wire            gtx0_comwakedet_i;
    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    wire    [3:0]   gtx0_txcharisk_i;
    //---------------- Transmit Ports - TX Data Path interface -----------------
    wire    [31:0]  gtx0_txdata_i;
    wire            gtx0_txoutclk_i;
    wire            gtx0_txreset_i;
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    wire    [3:0]   gtx0_txdiffctrl_i;
    wire    [4:0]   gtx0_txpostemphasis_i;
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    wire    [3:0]   gtx0_txpreemphasis_i;
    //--------------------- Transmit Ports - TX PLL Ports ----------------------
    wire            gtx0_gtxtxreset_i;
    wire            gtx0_txresetdone_i;
    //--------------- Transmit Ports - TX Ports for PCI Express ----------------
    wire            gtx0_txelecidle_i;
    //------------------- Transmit Ports - TX Ports for SATA -------------------
    wire            comfinish;
    wire            gtx0_txcominit_i;
    wire            gtx0_txcomwake_i;


    //________________________________________________________________________
    //________________________________________________________________________
    //GTX1   (X0Y5)

    //---------------------- Loopback and Powerdown Ports ----------------------
    wire    [2:0]   gtx1_loopback_i;
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    wire    [3:0]   gtx1_rxdisperr_i;
    wire    [3:0]   gtx1_rxnotintable_i;
    //----------------- Receive Ports - Clock Correction Ports -----------------
    wire    [2:0]   gtx1_rxclkcorcnt_i;
    //------------- Receive Ports - Comma Detection and Alignment --------------
    wire            gtx1_rxbyteisaligned_i;
    wire            gtx1_rxbyterealign_i;
    wire            gtx1_rxenmcommaalign_i;
    wire            gtx1_rxenpcommaalign_i;
    //----------------- Receive Ports - RX Data Path interface -----------------
    wire    [31:0]  gtx1_rxdata_i;
    wire            gtx1_rxrecclk_i;
    wire            gtx1_rxreset_i;
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    wire            gtx1_rxelecidle_i;
    wire    [2:0]   gtx1_rxeqmix_i;
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    wire            gtx1_rxbufreset_i;
    wire    [2:0]   gtx1_rxstatus_i;
    //---------------------- Receive Ports - RX PLL Ports ----------------------
    wire            gtx1_gtxrxreset_i;
    wire            gtx1_pllrxreset_i;
    wire            gtx1_rxplllkdet_i;
    wire            gtx1_rxresetdone_i;
    //------------------- Receive Ports - RX Ports for SATA --------------------
    wire            gtx1_cominitdet_i;
    wire            gtx1_comwakedet_i;
    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    wire    [3:0]   gtx1_txcharisk_i;
    //---------------- Transmit Ports - TX Data Path interface -----------------
    wire    [31:0]  gtx1_txdata_i;
    wire            gtx1_txoutclk_i;
    wire            gtx1_txreset_i;
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    wire    [3:0]   gtx1_txdiffctrl_i;
    wire    [4:0]   gtx1_txpostemphasis_i;
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    wire    [3:0]   gtx1_txpreemphasis_i;
    //--------------------- Transmit Ports - TX PLL Ports ----------------------
    wire            gtx1_gtxtxreset_i;
    wire            gtx1_txresetdone_i;
    //--------------- Transmit Ports - TX Ports for PCI Express ----------------
    wire            gtx1_txelecidle_i;
    //------------------- Transmit Ports - TX Ports for SATA -------------------
    wire            gtx1_comfinish_i;
    wire            gtx1_txcominit_i;
    wire            gtx1_txcomwake_i;



    //----------------------------- Global Signals -----------------------------
    wire            gtx0_tx_system_reset_c;
    wire            gtx0_rx_system_reset_c;
    wire            gtx1_tx_system_reset_c;
    wire            gtx1_rx_system_reset_c;
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [7:0]   tied_to_vcc_vec_i;
    wire            drp_clk_in_i;

    //--------------------------- User Clocks ---------------------------------
    wire            gtx0_txusrclk_i;
    wire            gtx0_txusrclk2_i;
    wire            txoutclk_mmcm0_locked_i;
    wire            txoutclk_mmcm0_reset_i;
    wire            gtx0_txoutclk_to_mmcm_i;


    //--------------------------- Reference Clocks ----------------------------
    
    wire            q1_clk1_refclk_i;
    wire            q1_clk1_refclk_i_bufg;
    //--------------------------- Reference Clocks ----------------------------


        // Static signal Assigments    
        assign tied_to_ground_i             = 1'b0;
        assign tied_to_ground_vec_i         = 64'h0000000000000000;
        assign tied_to_vcc_i                = 1'b1;
        assign tied_to_vcc_vec_i            = 8'hff;
 
        // GTX Reset
        assign rst_0 = GTXRESET_IN;  
         
        always @(posedge CLKIN_150)
        begin
            rst_1 <= rst_0;
            rst_2 <= rst_1;
            rst_3 <= rst_2;
        end

        assign rst_debounce = (rst_1 & rst_2 & rst_3);

	//assign gtx_reset = rst_debounce|| speed_neg_rst;	
	assign gtx_reset = rst_debounce;	
	//assign mmcm_reset = ~PLLLKDET_OUT || speed_neg_rst;
	assign mmcm_reset = ~PLLLKDET_OUT;
	
	assign	GEN2_led =  GEN2;
	assign LINKUP    = linkup;	
	assign LINKUP_led = linkup_led_out;	
	assign align_en_out = align_en_out;	
	assign	DCMLOCKED_OUT	=  mmcm_locked; // LED active high 

	assign PLLLKDET_OUT_N = PLLLKDET_OUT;         
	assign  rxelecidlereset0          =   (rxelecidle0 && resetdone0);
	assign  rxenelecidleresetb        =   !rxelecidlereset0; 

        assign rx_dataout = rxdataout;

        // SATA PHY output clock assignments
        assign sata_user_clk = gtx0_txusrclk2_i;


OOB_control OOB_control_i 
    (
 	.oob_control_ila_control        (oob_control_ila_control),
       //-------- GTX Ports --------/
     	.clk				(gtx0_txusrclk2_i),
 	.reset		      		(gtx_reset),
	.rxreset			(rxreset),
 	.rx_locked			(PLLLKDET_OUT),
         // OOB generation and detection signals from GTX
 	.txcominit			(txcominit),
 	.txcomwake			(txcomwake),
 	.cominitdet                     (cominitdet),
 	.comwakedet                     (comwakedet),

 	.rxelecidle			(rxelecidle0),
 	.txelecidle_out			(txelecidle),
 	.rxbyteisaligned		(RXBYTEISALIGNED0), 	
 	.tx_dataout			(txdata),		// outgoing GTX data
 	.tx_charisk_out			(tx_charisk_out),       // GTX charisk out    
 	.rx_datain			(rxdata),              	// incoming GTX data 
 	.rx_charisk_in			(rxcharisk),            // GTX charisk in 	
	.gen2             		(1'b1),                 // for SATA Generation 2
        
       //----- USER DATA PORTS---------//        
 	.tx_datain			(tx_datain),		// User datain port
        .tx_charisk_in                  (tx_charisk_in),        // User charisk in port 
 	.rx_dataout			(rxdataout),         	// User dataout port
 	.rx_charisk_out			(rx_charisk_out),       // User charisk out port 	
 	.linkup                 	(linkup),
 	.linkup_led_out                 (linkup_led_out),
 	.align_en_out                   (align_en_out),
	.CurrentState_out       	(CurrentState_out)
 );

    assign rxelecidle_out  = rxelecidle0;


    
//---------------------Dedicated GTX Reference Clock Inputs ---------------
    // The dedicated reference clock inputs you selected in the GUI are implemented using
    // IBUFDS_GTXE1 instances.
    //
    // In the UCF file for this example design, you will see that each of
    // these IBUFDS_GTXE1 instances has been LOCed to a particular set of pins. By LOCing to these
    // locations, we tell the tools to use the dedicated input buffers to the GTX reference
    // clock network, rather than general purpose IOs. To select other pins, consult the 
    // Implementation chapter of UG___, or rerun the wizard.
    //
    // This network is the highest performace (lowest jitter) option for providing clocks
    // to the GTX transceivers.
    
    IBUFDS_GTXE1 gtx_refclk_ibufds_i
    (
        .O                              (gtx_refclk),
        .ODIV2                          (),
        .CEB                            (tied_to_ground_i),
        .I                              (REFCLK_PAD_P_IN),
        .IB                             (REFCLK_PAD_N_IN)
    );

 
    BUFG gtx_refclk_bufg_i
    (
        .I                              (gtx_refclk),
        .O                              (gtx_refclk_bufg)
    );

   

    //--------------------------------- User Clocks ---------------------------
    
    // The clock resources in this section were added based on userclk source selections on
    // the Latency, Buffering, and Clocking page of the GUI. A few notes about user clocks:
    // * The userclk and userclk2 for each GTX datapath (TX and RX) must be phase aligned to 
    //   avoid data errors in the fabric interface whenever the datapath is wider than 10 bits
    // * To minimize clock resources, you can share clocks between GTXs. GTXs using the same frequency
    //   or multiples of the same frequency can be accomadated using MMCMs. Use caution when
    //   using RXRECCLK as a clock source, however - these clocks can typically only be shared if all
    //   the channels using the clock are receiving data from TX channels that share a reference clock 
    //   source with each other.

   // assign  txoutclk_mmcm0_reset_i               =  !gtx0_rxplllkdet_i;



    BUFG txoutclk_bufg_i
    (
        .I                              (gtx0_txoutclk_i),
        .O                              (mmcm_clk_in)
    );


    MGT_USRCLK_SOURCE_MMCM #
    (
        .MULT                           (8.0),
        .DIVIDE                         (2),
        .CLK_PERIOD                     (6.666),
        .OUT0_DIVIDE                    (4.0),
        .OUT1_DIVIDE                    (2.0),
        .OUT2_DIVIDE                    (1),
        .OUT3_DIVIDE                    (1)
    )
    txoutclk_mmcm0_i
    (
        .CLK0_OUT                       (gtx0_txusrclk2_i),
        .CLK1_OUT                       (gtx0_txusrclk_i),
        .CLK2_OUT                       (),
        .CLK3_OUT                       (),
        .CLK_IN                         (mmcm_clk_in),
        .MMCM_LOCKED_OUT                (mmcm_locked),
        .MMCM_RESET_IN                  (mmcm_reset)
    );


//instantiate GTX tile(two transceivers)

SATA_GTX_DUAL #
    (
        .WRAPPER_SIM_GTXRESET_SPEEDUP (0),
    )
    sata_gtx_dual_i
    (
 
 
        //_____________________________________________________________________
        //_____________________________________________________________________
        //GTX0  (X0Y4)
        //---------------------- Loopback and Powerdown Ports ----------------------
        .GTX0_LOOPBACK_IN               (gtx0_loopback_i),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .GTX0_RXCHARISK_OUT             (rxcharisk),
        .GTX0_RXDISPERR_OUT             (gtx0_rxdisperr_i),
        .GTX0_RXNOTINTABLE_OUT          (gtx0_rxnotintable_i),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .GTX0_RXCLKCORCNT_OUT           (gtx0_rxclkcorcnt_i),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .GTX0_RXBYTEISALIGNED_OUT       (RXBYTEISALIGNED0),
        .GTX0_RXBYTEREALIGN_OUT         (gtx0_rxbyterealign_i),
        .GTX0_RXENMCOMMAALIGN_IN        (gtx0_rxenmcommaalign_i),
        .GTX0_RXENPCOMMAALIGN_IN        (gtx0_rxenpcommaalign_i),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .GTX0_RXDATA_OUT                (rxdata),
        .GTX0_RXRECCLK_OUT              (gtx0_rxrecclk_i),
        .GTX0_RXRESET_IN                (rxreset),
        .GTX0_RXUSRCLK_IN               (gtx0_txusrclk_i),
        .GTX0_RXUSRCLK2_IN              (gtx0_txusrclk2_i),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .GTX0_RXELECIDLE_OUT            (rxelecidle0),
        .GTX0_RXEQMIX_IN                (gtx0_rxeqmix_i),
        .GTX0_RXN_IN                    (RXN0_IN),
        .GTX0_RXP_IN                    (RXP0_IN),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .GTX0_RXBUFRESET_IN             (gtx_reset),
        .GTX0_RXSTATUS_OUT              (gtx0_rxstatus_i),
        //---------------------- Receive Ports - RX PLL Ports ----------------------
        .GTX0_GTXRXRESET_IN             (gtx_reset),
        .GTX0_MGTREFCLKRX_IN            (CLKIN_150),
        .GTX0_PLLRXRESET_IN             (),
        .GTX0_RXPLLLKDET_OUT            (PLLLKDET_OUT),
        .GTX0_RXRESETDONE_OUT           (gtx0_rxresetdone_i),
        //------------------- Receive Ports - RX Ports for SATA --------------------
        .GTX0_COMINITDET_OUT            (cominitdet),
        .GTX0_COMWAKEDET_OUT            (comwakedet),
        //----------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        // Speed Negotiation Control module is disabled here and the design is fixed for 
        //  SATA GEN2 disks
        .DADDR                          (7'b0),
        .DCLK                           (mmcm_clk_in),
        .DEN                            (1'b0),
        .DI                             (16'b0),
        .DRDY                           (),
        .DO                             (),
        .DWE                            (1'b0),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .GTX0_TXCHARISK_IN              ({1'b0,1'b0,1'b0,tx_charisk_out}),
        //.GTX0_TXCHARISK_IN              ({1'b0,tx_charisk_out,1'b0,tx_charisk_out}),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .GTX0_TXDATA_IN                 (txdata),
        .GTX0_TXOUTCLK_OUT              (gtx0_txoutclk_i),
        .GTX0_TXRESET_IN                (),
        .GTX0_TXUSRCLK_IN               (gtx0_txusrclk_i),
        .GTX0_TXUSRCLK2_IN              (gtx0_txusrclk2_i),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .GTX0_TXDIFFCTRL_IN             (gtx0_txdiffctrl_i),
        .GTX0_TXN_OUT                   (TXN0_OUT),
        .GTX0_TXP_OUT                   (TXP0_OUT),
        .GTX0_TXPOSTEMPHASIS_IN         (gtx0_txpostemphasis_i),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .GTX0_TXPREEMPHASIS_IN          (gtx0_txpreemphasis_i),
        //--------------------- Transmit Ports - TX PLL Ports ----------------------
        .GTX0_GTXTXRESET_IN             (gtx_reset),
        .GTX0_TXRESETDONE_OUT           (gtx0_txresetdone_i),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .GTX0_TXELECIDLE_IN             (txelecidle),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .GTX0_COMFINISH_OUT             (comfinish),
        .GTX0_TXCOMINIT_IN              (txcominit),
        .GTX0_TXCOMWAKE_IN              (txcomwake),

 
        //_____________________________________________________________________
        //_____________________________________________________________________
        //GTX1  (X0Y5)
        //---------------------- Loopback and Powerdown Ports ----------------------
        .GTX1_LOOPBACK_IN               (gtx1_loopback_i),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .GTX1_RXDISPERR_OUT             (gtx1_rxdisperr_i),
        .GTX1_RXNOTINTABLE_OUT          (gtx1_rxnotintable_i),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .GTX1_RXCLKCORCNT_OUT           (gtx1_rxclkcorcnt_i),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .GTX1_RXBYTEISALIGNED_OUT       (),
        .GTX1_RXBYTEREALIGN_OUT         (gtx1_rxbyterealign_i),
        .GTX1_RXENMCOMMAALIGN_IN        (gtx1_rxenmcommaalign_i),
        .GTX1_RXENPCOMMAALIGN_IN        (gtx1_rxenpcommaalign_i),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .GTX1_RXDATA_OUT                (),
        .GTX1_RXRECCLK_OUT              (gtx1_rxrecclk_i),
        .GTX1_RXRESET_IN                (rxreset),
        .GTX1_RXUSRCLK_IN               (gtx0_txusrclk_i),
        .GTX1_RXUSRCLK2_IN              (gtx0_txusrclk2_i),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .GTX1_RXELECIDLE_OUT            (rxelecidle1),
        .GTX1_RXEQMIX_IN                (gtx1_rxeqmix_i),
        .GTX1_RXN_IN                    (),
        .GTX1_RXP_IN                    (),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .GTX1_RXBUFRESET_IN             (gtx_reset),
        .GTX1_RXSTATUS_OUT              (),
        //---------------------- Receive Ports - RX PLL Ports ----------------------
        .GTX1_GTXRXRESET_IN             (gtx_reset),
        .GTX1_MGTREFCLKRX_IN            (CLKIN_150),
        .GTX1_PLLRXRESET_IN             (),
        .GTX1_RXPLLLKDET_OUT            (gtx1_rxplllkdet_i),
        .GTX1_RXRESETDONE_OUT           (gtx1_rxresetdone_i),
        //------------------- Receive Ports - RX Ports for SATA --------------------
        .GTX1_COMINITDET_OUT            (gtx1_cominitdet_i),
        .GTX1_COMWAKEDET_OUT            (gtx1_comwakedet_i),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .GTX1_TXCHARISK_IN              ({1'b0,1'b0,1'b0,tx_charisk_out}),
        //.GTX1_TXCHARISK_IN              ({1'b0,tx_charisk_out,1'b0,tx_charisk_out}),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .GTX1_TXDATA_IN                 (txdata),
        .GTX1_TXOUTCLK_OUT              (gtx1_txoutclk_i),
        .GTX1_TXRESET_IN                (),
        .GTX1_TXUSRCLK_IN               (gtx0_txusrclk_i),
        .GTX1_TXUSRCLK2_IN              (gtx0_txusrclk2_i),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .GTX1_TXDIFFCTRL_IN             (gtx1_txdiffctrl_i),
        .GTX1_TXN_OUT                   (),
        .GTX1_TXP_OUT                   (),
        .GTX1_TXPOSTEMPHASIS_IN         (gtx1_txpostemphasis_i),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .GTX1_TXPREEMPHASIS_IN          (gtx1_txpreemphasis_i),
        //--------------------- Transmit Ports - TX PLL Ports ----------------------
        .GTX1_GTXTXRESET_IN             (gtx_reset),
        .GTX1_TXRESETDONE_OUT           (gtx1_txresetdone_i),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .GTX1_TXELECIDLE_IN             (txelecidle),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .GTX1_COMFINISH_OUT             (gtx1_comfinish_i),
        .GTX1_TXCOMINIT_IN              (gtx1_txcominit_i),
        .GTX1_TXCOMWAKE_IN              (gtx1_txcomwake_i)

    );
/* Note: The Transmitter Differential Voltage Swing is set by the TXDIFFCTRL parameter
         in the GTX transceivers. It defaults to 4'b0000 resulting in a voltage of 110 mV p-p. 
         Set it to 4'b1000 to raise the voltage to 810 mV p-p. (Refer Pg 174 of V6 GTX user guide). 
         This is necessary for the transmission of OOB signals during PHY Initialization. */ 
assign gtx0_txdiffctrl_i = 4'b1000; 
assign gtx1_txdiffctrl_i = 4'b1000; 



// Debugging
always @(posedge gtx_refclk_bufg)
begin : GTX_REF_CLK_CNT
      begin
            gtx_refclk_count <= gtx_refclk_count + 1;
      end 
end

always @(posedge mmcm_clk_in)
begin : GTX_TXOUTCLK_CNT
      begin
            gtx_txoutclk_count <= gtx_txoutclk_count + 1;
      end 
end


always @(posedge gtx0_txusrclk_i)
begin : GTX_TXUSRCLK_CNT
      begin
            gtx_txusrclk_count <= gtx_txusrclk_count + 1;
      end 
end

always @(posedge gtx0_txusrclk2_i)
begin : GTX_TXUSRCLK2_CNT
      begin
            gtx_txusrclk2_count <= gtx_txusrclk2_count + 1;
      end 
end


always @(posedge CLKIN_150)
begin : CLKIN_150_CNT
      begin
            CLKIN_150_count <= CLKIN_150_count + 1;
      end 
end


// SATA PHY ILA
wire [7:0] trig0;
wire [15:0] trig1;
wire [1:0] trig2;
wire [15:0] trig3;
wire [15:0] trig4;
wire [15:0] trig5;
wire [15:0] trig6;
wire [15:0] trig7;
wire [15:0] trig8;
wire [15:0] trig9;
wire [15:0] trig10;
wire [35:0] control;

if (CHIPSCOPE == "TRUE") begin
 sata_phy_ila  i_sata_phy_ila  
    (
      .control(sata_phy_ila_control),
      .clk(gtx0_txusrclk2_i),
      .trig0(trig0),
      .trig1(trig1),
      .trig2(trig2),
      .trig3(trig3),
      .trig4(trig4),
      .trig5(trig5),
      .trig6(trig6),
      .trig7(trig7),
      .trig8(trig8),
      .trig9(trig9),
      .trig10(trig10)
    );
end

assign trig0  = CurrentState_out;
assign trig1[0] = gtx0_rxstatus_i;
assign trig1[1] = gtx0_txusrclk_i;
assign trig1[2] = gtx0_txusrclk2_i;
assign trig1[3] = gtx_reset; 
assign trig1[4] = comfinish;
assign trig1[5] = PLLLKDET_OUT;
assign trig1[6] = mmcm_reset;
assign trig1[7] = mmcm_locked;
assign trig1[8] = rxelecidle0;
assign trig1[9] = RXBYTEISALIGNED0;
assign trig1[10] = gtx0_rxresetdone_i;
assign trig1[11] = txelecidle;
assign trig1[12] = txcominit;
assign trig1[13] = txcomwake;
assign trig1[14] = cominitdet;
assign trig1[15] = comwakedet;
assign trig2     = 2'b0;
assign trig3[0]  = gtx0_txresetdone_i;
assign trig3[1]  = speed_neg_rst;
assign trig3[2]  = GTXRESET_IN;
assign trig3[3]  = rst_1;
assign trig3[6:4]  = rxcharisk;
assign trig3[15:7] = 9'b0;
assign trig4     = gtx_refclk_count;
assign trig5     = gtx_txoutclk_count;
assign trig6     = gtx_txusrclk_count;
assign trig7     = gtx_txusrclk2_count;
assign trig8     = 16'b0;
assign trig9     = 16'b0;
assign trig10    = CLKIN_150_count;

endmodule


module sata_phy_ila 
  (
    control,
    clk,
    trig0,
    trig1,
    trig2,
    trig3,
    trig4,
    trig5,
    trig6,
    trig7,
    trig8,
    trig9,
    trig10
  );
  input [35:0] control;
  input clk;
  input [7:0]  trig0;
  input [15:0] trig1;
  input [1:0]  trig2;
  input [15:0] trig3;
  input [15:0] trig4;
  input [15:0] trig5;
  input [15:0] trig6;
  input [15:0] trig7;
  input [15:0] trig8;
  input [15:0] trig9;
  input [15:0] trig10;
  
endmodule
