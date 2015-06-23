`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:  ziti, Uni. HD
// Engineer:  wgao
//            weng.ziti@gmail.com
// 
// Create Date:   16:54:18 04 Nov 2008
// Design Name:   tlpControl
// Module Name:   tf64_pcie_trn.v
// Project Name:  PCIE_SG_DMA
// Target Device:  
// Tool versions:  
// Description:  PIO and DMA are both simulated.
//
// Verilog Test Fixture created by ISE for module: tlpControl
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// 
// Revision 1.00 - Released to OpenCores.org   14.09.2011
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////


//`define  RANDOM_SEQUENCE

  /*  Time parameters  */
`define  T_HALF_CYCLE_CLK                   4.0
`define  T_HALF_CYCLE_MEMCLK                5.0
`define  T_DELAY_AFTER                      0.0
`define  T_DELTA                            0.1
`define  T_PIO_INTERVAL                    50.0
`define  T_DMA_INTERVAL                   300.0
`define  T_RX_NO_FC_PERIOD            1900000.0
`define  T_TX_NO_FC_PERIOD            1500000.0

  /* Memory size for simulation */
`define  C_ARRAY_DIMENSION              4096

  /* Start indices */
`define  PIO_START_INDEX                'H0300
`define  DMA_START_INDEX                'H0000

  /* Request completion boundary */
`define  C_RCB_16_DW                    'H10
`define  C_RCB_32_DW                    'H20

  /* BAR */
`define  C_BAR0_HIT                    7'H7E
`define  C_BAR1_HIT                    7'H7D
`define  C_BAR2_HIT                    7'H7B
`define  C_BAR3_HIT                    7'H77
`define  C_BAR4_HIT                    7'H6F
`define  C_BAR5_HIT                    7'H5F
`define  C_BAR6_HIT                    7'H3F
`define  C_NO_BAR_HIT                  7'H7F


  /* Requester ID and Completer ID */
`define  C_HOST_WRREQ_ID              16'H0ABC
`define  C_HOST_RDREQ_ID              16'HE1E2
`define  C_HOST_CPLD_ID               16'HC01D

  /* 1st header */
`define  HEADER0_MWR3_                32'H40000000
`define  HEADER0_MWR4_                32'H60000000
`define  HEADER0_MRD3_                32'H00000000
`define  HEADER0_MRD4_                32'H20000000
`define  HEADER0_CPLD                 32'H4A000000
`define  HEADER0_CPL                  32'H0A000000
`define  HEADER0_MSG                  32'H34000001

  /* Message codes */
`define  C_MSG_CODE_INTA               8'H20
`define  C_MSG_CODE_INTA_N             8'H24

  /* Payload type */
`define  USE_PRIVATE                    1
`define  USE_PUBLIC                     0

  /* General registers */
`define  C_ADDR_VERSION                 32'H0000
`define  C_ADDR_IRQ_STAT                32'H0008
`define  C_ADDR_IRQ_EN                  32'H0010
`define  C_ADDR_GSR                     32'H0020
`define  C_ADDR_GCR                     32'H0028

  /* Control registers for special ports */
`define  C_ADDR_MRD_CTRL                32'H0074
`define  C_ADDR_TX_CTRL                 32'H0078
`define  C_ADDR_ICAP                    32'H007C
`define  C_ADDR_EB_STACON               32'H0090

  /* Downstream DMA channel registers */
`define  C_ADDR_DMA_DS_PAH              32'H0050
`define  C_ADDR_DMA_DS_CTRL             32'H006C
`define  C_ADDR_DMA_DS_STA              32'H0070

  /* Upstream DMA channel registers */
`define  C_ADDR_DMA_US_PAH              32'H002C
`define  C_ADDR_DMA_US_CTRL             32'H0048
`define  C_ADDR_DMA_US_STA              32'H004C

  /* DMA-specific constants */
`define  C_DMA_RST_CMD                  32'H0200000A


module tf64_pcie_trn();

   // Inputs
   reg  trn_reset_n;
   reg  trn_lnk_up_n;
   reg  trn_clk;
   reg  trn_rsof_n;
   reg  trn_reof_n;
   reg  [63:0] trn_rd;
   reg  [7:0] trn_rrem_n;
   reg  trn_rsrc_rdy_n;
   wire trn_rdst_rdy_n;
   reg  [6:0] trn_rbar_hit_n;
   wire trn_rnp_ok_n;
   reg  trn_rerrfwd_n;
   reg  trn_rsrc_dsc_n;
   wire trn_tsof_n;
   wire trn_teof_n;
   wire [63:0] trn_td;
   wire [7:0] trn_trem_n;
   wire trn_tsrc_rdy_n;
   reg  trn_tdst_rdy_n;
   wire trn_terrfwd_n;
   wire trn_tsrc_dsc_n;
   reg  trn_tdst_dsc_n;
   reg  [3:0] trn_tbuf_av;
//   reg cfg_interrupt_rdy_n;
//   reg [2:0] cfg_interrupt_mmenable;
//   reg cfg_interrupt_msienable;
//   reg [7:0] cfg_interrupt_do;
   reg [5:0] pcie_link_width;
   reg [15:0] cfg_dcommand;
   reg [15:0] localID;

   // Outputs
   wire DDR_wr_v;
   wire DDR_wr_sof;
   wire DDR_wr_eof;
   wire DDR_wr_Shift;
   wire [1:0] DDR_wr_Mask;
   wire [63:0] DDR_wr_din;
   wire DDR_wr_full;
   wire DDR_rdc_v;
   wire DDR_rdc_sof;
   wire DDR_rdc_eof;
   wire DDR_rdc_Shift;
   wire [63:0] DDR_rdc_din;
   wire DDR_rdc_full;
   wire DDR_FIFO_RdEn;
   wire DDR_FIFO_Empty;
   wire [63:0] DDR_FIFO_RdQout;
   reg  mbuf_UserFull;
   wire DDR_Ready;
   wire trn_Blinker;
   reg  mem_clk;

   // FIFO
   wire           eb_FIFO_we; 
   wire [64-1:00] eb_FIFO_din;
   wire           eb_FIFO_re; 
   wire [72-1:00] eb_FIFO_qout;
   wire [64-1:00] eb_FIFO_Status;
   wire           eb_FIFO_Rst;

   wire           eb_pfull;
   wire           eb_full;
   wire           eb_pempty;
   wire           eb_empty;

   wire [27-1:0]  eb_FIFO_Data_Count;

   // flow control toggles
   reg            Rx_No_Flow_Control;
   reg            Tx_No_Flow_Control;

   // message counters 
   reg  [31:00] Accum_Msg_INTA        = 0;
   reg  [31:00] Accum_Msg_INTA_n      = 0;

   // random seed
   reg [127: 0]  Op_Random;

   // Generated Array
   reg [15:00]  ii;
   reg [31:00]  D_Array[`C_ARRAY_DIMENSION-1:00];

   //
   reg  [ 7: 0] FSM_Trn;
   reg  [31: 0] Hdr_Array[3:0];
   reg  [31: 0] Private_Array[15:0];
   reg  [10: 0] Rx_TLP_Length;
   reg  [ 7: 0] Rx_MWr_Tag;
   reg  [ 4: 0] Rx_MRd_Tag;
   reg  [31:00] Tx_MRd_Addr;
   reg  [31:00] Tx_MRd_Leng;
   reg  [10: 0] tx_MRd_Length;
   reg  [ 7: 0] tx_MRd_Tag;
   reg  [ 7: 0] tx_MRd_Tag_k;

   reg  [31:00] DMA_PA;
   reg  [63:00] DMA_HA;
   reg  [63:00] DMA_BDA;
   reg  [31:00] DMA_Leng;
   reg  [31:00] DMA_L1;
   reg  [31:00] DMA_L2;
   reg  [02:00] DMA_bar;
   reg          DMA_ds_is_Last;
   reg          DMA_us_is_Last;
   reg  [31:00] CplD_Index;

   reg          Desc_tx_MRd_Valid;
   reg  [10:00] Desc_tx_MRd_Leng;
   reg  [31:00] Desc_tx_MRd_Addr;
   reg  [07:00] Desc_tx_MRd_TAG;
   reg          tx_MRd_come;

   reg  [63:00] PIO_Addr;
   reg  [31:00] PIO_Leng;
   reg  [ 3:00] PIO_1st_BE;
   reg  [ 6:00] PIO_bar;
   
   //
   wire           DBG_dma_start;



	// Instantiate the Unit Under Test (UUT)
	tlpControl uut (
		.mbuf_UserFull(mbuf_UserFull), 
		.trn_Blinker(trn_Blinker), 
      .eb_FIFO_we     (eb_FIFO_we    ) , //          : OUT std_logic; 
      .eb_FIFO_din    (eb_FIFO_din   ) , //          : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      .eb_FIFO_re     (eb_FIFO_re    ) , //          : OUT std_logic; 
      .eb_FIFO_empty  (eb_empty      ) , //          : IN  std_logic; 
      .eb_FIFO_qout   (eb_FIFO_qout[63:0]  ) , //          : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      .eb_FIFO_Data_Count   (eb_FIFO_Data_Count  ) , //          : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      .eb_FIFO_Status (eb_FIFO_Status) , //          : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      .eb_FIFO_Rst    (eb_FIFO_Rst   ) , //          : OUT std_logic;
      .Link_Buf_full  (eb_pfull   ) ,
      .DMA_ds_Start   (DBG_dma_start),
		.DDR_Ready      (DDR_Ready), 
		.DDR_wr_sof(DDR_wr_sof), 
		.DDR_wr_eof(DDR_wr_eof), 
		.DDR_wr_v(DDR_wr_v), 
		.DDR_wr_FA(   ), 
		.DDR_wr_Shift(DDR_wr_Shift), 
		.DDR_wr_Mask(DDR_wr_Mask), 
		.DDR_wr_din(DDR_wr_din), 
		.DDR_wr_full(DDR_wr_full), 
		.DDR_rdc_sof(DDR_rdc_sof), 
		.DDR_rdc_eof(DDR_rdc_eof), 
		.DDR_rdc_v(DDR_rdc_v), 
		.DDR_rdc_FA(   ), 
      .DDR_rdc_Shift(DDR_rdc_Shift),
		.DDR_rdc_din(DDR_rdc_din), 
		.DDR_rdc_full(DDR_rdc_full), 
		.DDR_FIFO_RdEn(DDR_FIFO_RdEn), 
		.DDR_FIFO_Empty(DDR_FIFO_Empty), 
		.DDR_FIFO_RdQout(DDR_FIFO_RdQout), 
		.trn_clk(trn_clk), 
		.trn_reset_n(trn_reset_n), 
		.trn_lnk_up_n(trn_lnk_up_n), 
		.trn_rsof_n(trn_rsof_n), 
		.trn_reof_n(trn_reof_n), 
		.trn_rd(trn_rd), 
      .trn_rrem_n(trn_rrem_n),
		.trn_rerrfwd_n(trn_rerrfwd_n), 
		.trn_rsrc_rdy_n(trn_rsrc_rdy_n), 
		.trn_rdst_rdy_n(trn_rdst_rdy_n), 
		.trn_rnp_ok_n(trn_rnp_ok_n), 
		.trn_rsrc_dsc_n(trn_rsrc_dsc_n), 
		.trn_rbar_hit_n(trn_rbar_hit_n), 
		.trn_tsof_n(trn_tsof_n), 
		.trn_teof_n(trn_teof_n), 
		.trn_td(trn_td), 
      .trn_trem_n(trn_trem_n),
		.trn_terrfwd_n(trn_terrfwd_n), 
		.trn_tsrc_rdy_n(trn_tsrc_rdy_n), 
		.trn_tdst_rdy_n(trn_tdst_rdy_n), 
		.trn_tsrc_dsc_n(trn_tsrc_dsc_n), 
		.trn_tdst_dsc_n(trn_tdst_dsc_n), 
		.trn_tbuf_av(trn_tbuf_av), 
//		.cfg_interrupt_n(cfg_interrupt_n), 
//		.cfg_interrupt_rdy_n(cfg_interrupt_rdy_n), 
//		.cfg_interrupt_mmenable(cfg_interrupt_mmenable), 
//		.cfg_interrupt_msienable(cfg_interrupt_msienable), 
//		.cfg_interrupt_di(cfg_interrupt_di), 
//		.cfg_interrupt_do(cfg_interrupt_do), 
//		.cfg_interrupt_assert_n(cfg_interrupt_assert_n), 
		.pcie_link_width(pcie_link_width), 
		.cfg_dcommand(cfg_dcommand), 
		.localID(localID)
	);



	// Instantiate the BRAM module
   bram_Control
   bram_controller(
    .DDR_wr_sof(DDR_wr_sof), 
    .DDR_wr_eof(DDR_wr_eof), 
    .DDR_wr_v(DDR_wr_v), 
    .DDR_wr_FA(1'b0), 
    .DDR_wr_Shift(DDR_wr_Shift), 
    .DDR_wr_Mask(DDR_wr_Mask), 
    .DDR_wr_din(DDR_wr_din), 
//    .DDR_wr_full(DDR_wr_full), 
    .DDR_rdc_sof(DDR_rdc_sof), 
    .DDR_rdc_eof(DDR_rdc_eof), 
    .DDR_rdc_v(DDR_rdc_v), 
    .DDR_rdc_FA(1'b0), 
    .DDR_rdc_Shift(DDR_rdc_Shift),
    .DDR_rdc_din(DDR_rdc_din), 
    .DDR_rdc_full(DDR_rdc_full), 
    .DDR_FIFO_RdEn(DDR_FIFO_RdEn), 
    .DDR_FIFO_Empty(DDR_FIFO_Empty), 
    .DDR_FIFO_RdQout(DDR_FIFO_RdQout), 
    .DBG_dma_start(DBG_dma_start),
    .DDR_Ready(DDR_Ready), 
    .DDR_blinker(DDR_blinker), 
    .Sim_Zeichen(Sim_Zeichen), 
    .mem_clk(mem_clk), 
    .trn_clk(trn_clk), 
    .trn_reset_n(trn_reset_n)
    );

   assign  DDR_wr_full = 0;


	// Instantiate the FIFO module
   FIFO_wrapper
   queue_buffer(
         .wr_clk     (  trn_clk        ),
         .wr_en      (  eb_FIFO_we     ),
         .din        (  {8'H0, eb_FIFO_din}    ),
         .pfull      (  eb_pfull       ),
         .full       (  eb_full        ),

         .rd_clk     (  trn_clk        ),
         .rd_en      (  eb_FIFO_re     ),
         .dout       (  eb_FIFO_qout   ),
         .pempty     (  eb_pempty      ),
         .empty      (  eb_empty       ),
         .data_count (  eb_FIFO_Data_Count[14:1]),

         .rst        (  eb_FIFO_Rst    )
         );

   assign  eb_FIFO_Data_Count[26:15] = 0;
   assign  eb_FIFO_Data_Count[0] = 0;
   assign  eb_FIFO_Status = {34'H0, eb_FIFO_Data_Count, eb_pfull, eb_empty};



   // initialiation
	initial begin
		// Initialize Inputs
		trn_clk = 0;
      mem_clk = 1;
		trn_reset_n = 0;
		trn_lnk_up_n = 1;
		trn_rerrfwd_n = 1;
		trn_rsrc_dsc_n = 1;
		trn_tdst_dsc_n = 1;
		trn_tbuf_av = -1;

//		cfg_interrupt_rdy_n = 0;
//		cfg_interrupt_mmenable = 0;
//		cfg_interrupt_msienable = 0;
//		cfg_interrupt_do = 0;

		mbuf_UserFull = 0;
		pcie_link_width = 'H19;
      cfg_dcommand = 'H2000;
		localID = 'HD841;

      Rx_No_Flow_Control = 1;    // = 0;  // Set to 0 to enable the Rx throttling
      Tx_No_Flow_Control = 1;    // = 0;  // Set to 0 to enable the Tx throttling

		// Wait some nanoseconds for global reset to finish
		#100;
		trn_reset_n = 1;
		trn_lnk_up_n = 0;

		#10000;
//      $stop();

	end

   // trn_clk toggles
   always #`T_HALF_CYCLE_CLK
   trn_clk = ~trn_clk;

   // mem_clk toggles
   always #`T_HALF_CYCLE_MEMCLK
   mem_clk = ~mem_clk;

   // Randoms generated for process flow
   always @(posedge trn_clk) begin
     Op_Random[ 31:00] = $random();
     Op_Random[ 63:32] = $random();
     Op_Random[ 95:64] = $random();
     Op_Random[127:96] = $random();
   end


   /// Rx Flow Control
   always # `T_RX_NO_FC_PERIOD
   Rx_No_Flow_Control = ~Rx_No_Flow_Control;

   /// Tx Flow Control
   always # `T_TX_NO_FC_PERIOD
   Tx_No_Flow_Control = ~Tx_No_Flow_Control;

   // Signal prepared for trn_rsrc_rdy_n
   reg trn_rsrc_rdy_n_seed;
   always @(posedge trn_clk) begin
     trn_rsrc_rdy_n_seed <= Op_Random[8] & Op_Random[10] & ~Rx_No_Flow_Control;
   end

   // trn_tdst_rdy_n
   always @(posedge trn_clk )
   begin
     # `T_DELAY_AFTER
      trn_tdst_rdy_n <= (Op_Random[24] & Op_Random[21] & ~Tx_No_Flow_Control) | ~trn_reset_n;
   end



   // Initialization mem in host
   initial begin
     for (ii = 0; ii< `C_ARRAY_DIMENSION; ii= ii+1) begin
`ifdef  RANDOM_SEQUENCE
        D_Array[ii]    <= $random ();
`else
        D_Array[ii]    <= Inv_Endian ('H8760_0000 + ii + 1);
`endif
     end
   end


  //  Simulation procedure
  initial begin

    // Simulation Initialization
    FSM_Trn               <= 'H00;
    Gap_Insert_Rx;

    PIO_bar               <= -1;
    DMA_bar               <= 'H1;
    Rx_MWr_Tag            <= 'H80;
    Rx_MRd_Tag            <= 'H10;


    // Initialization: TLP
    # 400
      Rx_TLP_Length    <= 'H01;

    # `T_DELTA    // reset TX module
      Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
      Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
      Hdr_Array[2] <= `C_ADDR_TX_CTRL;
      Private_Array[0] <= 'H0000000A;

    # `T_DELTA
      TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
      Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
      Gap_Insert_Rx;


    # `T_DELTA     // Test MRd with 4-DW header  BAR[0]
      Hdr_Array[0] <= `HEADER0_MRD4_ | Rx_TLP_Length[9:0];
      Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 8'HA1, 4'Hf, 4'Hf};
      Hdr_Array[2] <= -1;
      Hdr_Array[3] <= `C_ADDR_VERSION;


    # `T_DELTA
      TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
      Gap_Insert_Rx;


    # 100
      Rx_TLP_Length    <= 'H01;


    # `T_DELTA    // reset upstream DMA channel
      Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
      Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
      Hdr_Array[2] <= `C_ADDR_DMA_US_CTRL;
      Private_Array[0] <= `C_DMA_RST_CMD;

    # `T_DELTA
      TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
      Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
      Gap_Insert_Rx;

    # `T_DELTA    // reset downstream DMA channel
      Hdr_Array[0] <= `HEADER0_MWR4_ | Rx_TLP_Length[9:0];
      Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
      Hdr_Array[2] <= -1;
      Hdr_Array[3] <= `C_ADDR_DMA_DS_CTRL;
      Private_Array[0] <= `C_DMA_RST_CMD;

    # `T_DELTA
      TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
      Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
      Gap_Insert_Rx;


    # `T_DELTA    // reset Event Buffer FIFO
      Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
      Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
      Hdr_Array[2] <= `C_ADDR_EB_STACON;
      Private_Array[0] <= 'H0000000A;

    # `T_DELTA
      TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
      Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
      Gap_Insert_Rx;


    # `T_DELTA    // Enable INTerrupts
      Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
      Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
      Hdr_Array[2] <= `C_ADDR_IRQ_EN;
      Private_Array[0] <= 'H0000_0003;

    # `T_DELTA
      TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
      Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
      Gap_Insert_Rx;




    /////////////////////////////////////////////////////////////////////
    //                       PIO simulation                            //
    /////////////////////////////////////////////////////////////////////


     # `T_PIO_INTERVAL
       ;

       FSM_Trn          <= 'H04;

    //  ///////////////////////////////////////////////////////////////////
    //  PIO write & read BAR[0]

       PIO_Addr         <= `C_ADDR_DMA_US_PAH + 'H8;
       PIO_bar          <= `C_BAR0_HIT;
       PIO_1st_BE       <= 4'Hf;
       Gap_Insert_Rx;
       Hdr_Array[0]     <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1]     <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, PIO_1st_BE};
       Hdr_Array[2]     <= {PIO_Addr[31:2], 2'b00};
       Private_Array[0] <= 'HF000_8888;
       Rx_TLP_Length    <= 'H01;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, PIO_bar);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;

     # `T_PIO_INTERVAL
       ;

     # `T_DELTA
       Hdr_Array[0]     <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1]     <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, PIO_1st_BE};
       Hdr_Array[2]     <= {PIO_Addr[31:2], 2'b00};

     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, `PIO_START_INDEX, PIO_bar);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H08;



    //  ///////////////////////////////////////////////////////////////////
    //  PIO write & read BAR[1]
       PIO_Addr         <= 'H8000;
       PIO_bar          <= `C_BAR1_HIT;
       PIO_1st_BE       <= 4'Hf;
       Gap_Insert_Rx;
       Hdr_Array[0]     <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1]     <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, PIO_1st_BE};
       Hdr_Array[2]     <= {PIO_Addr[31:2], 2'b00};
       Private_Array[0] <= 'HA1111111;
       Rx_TLP_Length    <= 'H01;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, PIO_bar);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;

     # `T_PIO_INTERVAL
       ;

     # `T_DELTA
       Hdr_Array[0]     <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1]     <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, PIO_1st_BE};
       Hdr_Array[2]     <= {PIO_Addr[31:2], 2'b00};

     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, `PIO_START_INDEX, PIO_bar);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H10;



    //  ///////////////////////////////////////////////////////////////////
    //  PIO write & read BAR[2]
    //  NOTE:  FIFO address is 64-bit aligned, only the lower 32-bit is
    //         accessible by BAR[2] PIO write and is returned in BAR[2] 
    //         PIO read.
       PIO_Addr         <= 'H0;
       PIO_bar          <= `C_BAR2_HIT;
       PIO_1st_BE       <= 4'Hf;
       Gap_Insert_Rx;
       Hdr_Array[0]     <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1]     <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, PIO_1st_BE};
       Hdr_Array[2]     <= {PIO_Addr[31:2], 2'b00};
       Private_Array[0] <= 'HB222_2222;
       Rx_TLP_Length    <= 'H01;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, PIO_bar);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;

     # `T_PIO_INTERVAL
       ;

     # `T_DELTA
       Hdr_Array[0]     <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1]     <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, PIO_1st_BE};
       Hdr_Array[2]     <= {PIO_Addr[31:2], 2'b00};

     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, `PIO_START_INDEX, PIO_bar);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H14;



     # `T_DMA_INTERVAL
       ;


    //  ///////////////////////////////////////////////////////////////////
    //  DMA write & read BAR[1]
    //  Single-descriptor case

       DMA_PA   <= 'H1234;
       DMA_HA   <= 'H5000;
       DMA_BDA  <= 'Hffff;
		 DMA_Leng <= 'H0100;
       DMA_bar  <= 'H1;
       DMA_ds_is_Last  <= 'B1;

     # `T_DELTA
       // Initial DMA descriptor
       Private_Array[0] <= -1;
       Private_Array[1] <= DMA_PA[31:00];       //'H0300;
       Private_Array[2] <= DMA_HA[63:32];       // 0;
       Private_Array[3] <= DMA_HA[31:00];       // 'H4000;
       Private_Array[4] <= DMA_BDA[63:32];      // 0;
       Private_Array[5] <= DMA_BDA[31:00];      //'H0BDA0090;
       Private_Array[6] <= DMA_Leng;            //'H100;
       Private_Array[7] <=  {4'H0
                            ,3'H1, DMA_ds_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, DMA_bar
                            ,1'B1
                            ,15'H0
                            };


       //  DMA write

       Rx_TLP_Length    <= 'H01;

     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_DS_PAH;

       //  Write PA_H
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write PA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H1, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_H
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H2, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H3, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_H
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H4, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H5, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write LENG
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H6, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write CTRL and start the DMA
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H7, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;


     # `T_DELTA     // Polling the DMA status
       Hdr_Array[0] <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_DS_STA;

   
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H18;


       // feeding the payload CplD
       wait (tx_MRd_come);
       Gap_Insert_Rx;
       tx_MRd_come  <= 'B0;
       Tx_MRd_Leng  <= DMA_Leng>>2;
       Tx_MRd_Addr  <= DMA_HA[31:0];
       tx_MRd_Tag_k <= tx_MRd_Tag;
       CplD_Index   <= 'H0;

       Gap_Insert_Rx;
       Rx_TLP_Length    <= 'H10;

     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
//       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;


       Rx_TLP_Length    <= 'H01;
     # `T_DELTA     // Polling the DMA status
       Hdr_Array[0] <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_DS_STA;

   
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;


       FSM_Trn          <= 'H1C;

     # `T_DMA_INTERVAL
       ;



       //  DMA read

       Rx_TLP_Length    <= 'H01;

     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_PAH;

       //  Write PA_H
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write PA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H1, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_H
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H2, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H3, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_H
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H4, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H5, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write LENG
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H6, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write CTRL and start the DMA
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H7, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;


       Rx_TLP_Length    <= 'H01;
     # `T_DELTA     // Polling the DMA status
       Hdr_Array[0] <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_STA;

   
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H20;

     # (`T_DMA_INTERVAL*4)
       ;


  //////////////////////////////////////////////////////////////////////////////////

       Rx_TLP_Length    <= 'H01;
     # `T_DELTA    // reset downstream DMA channel
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_DS_CTRL;
       Private_Array[0] <= `C_DMA_RST_CMD;

     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;

       Rx_TLP_Length    <= 'H01;
     # `T_DELTA    // reset upstream DMA channel
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_CTRL;
       Private_Array[0] <= `C_DMA_RST_CMD;

     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;

  //////////////////////////////////////////////////////////////////////////////////


       FSM_Trn          <= 'H24;


     # `T_PIO_INTERVAL
       ;



    //  ///////////////////////////////////////////////////////////////////
    //  DMA write & read BAR[2]
    //  Multiple-descriptor case
    //  

       DMA_PA   <= 'H789ABC;
       DMA_HA   <= 'HDF0000;
       DMA_BDA  <= 'H0BDABDA0;
		 DMA_Leng <= 'H0208;
     # `T_DELTA
		 DMA_L1   <= 'H0100;
     # `T_DELTA
		 DMA_L2   <= DMA_Leng - DMA_L1;
       DMA_bar  <= 'H2;
       DMA_ds_is_Last  <= 'B0;

     # `T_DELTA
       // Initial DMA descriptor
       Private_Array[0] <= -1;
       Private_Array[1] <= DMA_PA[31:00];
       Private_Array[2] <= DMA_HA[63:32];       // 0;
       Private_Array[3] <= DMA_HA[31:00];
       Private_Array[4] <= DMA_BDA[63:32];      // 0;
       Private_Array[5] <= DMA_BDA[31:00];
       Private_Array[6] <= DMA_L1;
       Private_Array[7] <=  {4'H0
                            ,3'H1, DMA_ds_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, DMA_bar
                            ,1'B1
                            ,15'H0
                            };

       Rx_TLP_Length    <= 'H01;

     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_DS_PAH;

       //  Write PA_H
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write PA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H1, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_H
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H2, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H3, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_H
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H4, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H5, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write LENG
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H6, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write CTRL and start the DMA
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H7, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;


       FSM_Trn          <= 'H28;


       // feeding the descriptor CplD
       wait (Desc_tx_MRd_Valid);
       Gap_Insert_Rx;
       Desc_tx_MRd_Valid <= 'B0;
       DMA_ds_is_Last    <= 'B1;
       Gap_Insert_Rx;

       // Initial DMA descriptor
       Private_Array[0] <= 0;
       Private_Array[1] <= DMA_PA[31:00] + 'H500;
       Private_Array[2] <= DMA_HA[63:32];          // 0;
       Private_Array[3] <= DMA_HA[31:00] + 'H500;
       Private_Array[4] <= -1;                     // dont-care
       Private_Array[5] <= -1;                     // dont-care
       Private_Array[6] <= DMA_L2;
       Private_Array[7] <=  {4'H0
                            ,3'H1, DMA_ds_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, DMA_bar
                            ,1'B1
                            ,15'H0
                            };

       Rx_TLP_Length    <= 'H08;
       Gap_Insert_Rx;
       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Rx_TLP_Length[9:0], 2'b00};
       Hdr_Array[2] <= {localID, Desc_tx_MRd_TAG, 1'b0, DMA_BDA[6:0]};
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 0, `C_NO_BAR_HIT);
       Gap_Insert_Rx;


       // feeding the payload CplD
       wait (tx_MRd_come);
       Gap_Insert_Rx;
       tx_MRd_come  <= 'B0;
       Tx_MRd_Leng  <= DMA_L1>>2;
       Tx_MRd_Addr  <= DMA_HA[31:0];
       tx_MRd_Tag_k <= tx_MRd_Tag;
       CplD_Index   <= 'H0;

       Gap_Insert_Rx;
       Rx_TLP_Length    <= 'H10;

     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
//       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
//       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;


       Rx_TLP_Length    <= 'H01;
     # `T_DELTA     // Polling the DMA status
       Hdr_Array[0] <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_DS_STA;

   
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;


       FSM_Trn          <= 'H2C;


       // feeding the payload CplD (2nd descriptor)
       wait (tx_MRd_come);
       Gap_Insert_Rx;
       tx_MRd_come  <= 'B0;
       Tx_MRd_Leng  <= (DMA_L2>>2) - 'H2;
       Tx_MRd_Addr  <= DMA_HA[31:0] + 'H500;
       tx_MRd_Tag_k <= tx_MRd_Tag_k + 'H1;
       CplD_Index   <= 'H40;

       Gap_Insert_Rx;
       Rx_TLP_Length    <= 'H10;

     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
//       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;

       Rx_TLP_Length    <= 'H02;
       Tx_MRd_Leng      <= 'H2;
       tx_MRd_Tag_k     <= tx_MRd_Tag_k + 'H1;
     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H30;



     # (`T_DMA_INTERVAL*2)
       ;

       DMA_us_is_Last   <= 'B0;
     # `T_DELTA
       //  DMA read
       Private_Array[0] <= 0;
       Private_Array[1] <= DMA_PA[31:00];
       Private_Array[2] <= DMA_HA[63:32];          // 0;
       Private_Array[3] <= DMA_HA[31:00];
       Private_Array[4] <= DMA_BDA[63:32];         // 0;
       Private_Array[5] <= DMA_BDA[31:00] + 'H10000;
       Private_Array[6] <= DMA_L1;
       Private_Array[7] <=  {4'H0
                            ,3'H1, DMA_us_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, DMA_bar
                            ,1'B1
                            ,15'H0
                            };
       Rx_TLP_Length    <= 'H01;

     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_PAH;

       //  Write PA_H
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write PA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H1, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_H
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H2, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H3, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_H
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H4, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H5, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write LENG
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H6, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write CTRL and start the DMA
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H7, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;


       Rx_TLP_Length    <= 'H01;
     # `T_DELTA     // Polling the DMA status
       Hdr_Array[0] <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_STA;

   
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H34;


       // feeding the descriptor CplD
       wait (Desc_tx_MRd_Valid);
       Gap_Insert_Rx;
       Desc_tx_MRd_Valid <= 'B0;
       DMA_us_is_Last    <= 'B1;
       Gap_Insert_Rx;

       // Initial DMA descriptor
       Private_Array[0] <= 0;
       Private_Array[1] <= DMA_PA[31:00] + 'H500;
       Private_Array[2] <= DMA_HA[63:32];          // 0;
       Private_Array[3] <= DMA_HA[31:00] + 'H500;
       Private_Array[4] <= -1;                     // dont-care
       Private_Array[5] <= -1;                     // dont-care
       Private_Array[6] <= DMA_L2;
       Private_Array[7] <=  {4'H0
                            ,3'H1, DMA_us_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, DMA_bar
                            ,1'B1
                            ,15'H0
                            };

       Rx_TLP_Length    <= 'H08;
       Gap_Insert_Rx;
       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Rx_TLP_Length[9:0], 2'b00};
       Hdr_Array[2] <= {localID, Desc_tx_MRd_TAG, 1'b0, DMA_BDA[6:0]};
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 0, `C_NO_BAR_HIT);
       Gap_Insert_Rx;


       Rx_TLP_Length    <= 'H01;
     # `T_DELTA     // Polling the DMA status
       Hdr_Array[0] <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_STA;

   
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;


     # (`T_DMA_INTERVAL*4)
       ;

       Rx_TLP_Length    <= 'H01;
     # `T_DELTA     // Polling the DMA status
       Hdr_Array[0] <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_STA;

   
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H38;

     # (`T_DMA_INTERVAL*4)
       ;


  //////////////////////////////////////////////////////////////////////////////////

       Rx_TLP_Length    <= 'H01;
     # `T_DELTA    // reset downstream DMA channel
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_DS_CTRL;
       Private_Array[0] <= `C_DMA_RST_CMD;

     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;

       Rx_TLP_Length    <= 'H01;
     # `T_DELTA    // reset upstream DMA channel
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_CTRL;
       Private_Array[0] <= `C_DMA_RST_CMD;

     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;

  //////////////////////////////////////////////////////////////////////////////////


       FSM_Trn          <= 'H40;


  end




// ========================================== //
//         Checking and verification          //
//                                            //
   reg           Err_signal;
//                                            //
//                                            //
// ========================================== //

   // TLP format check out Rx
   //  in case stimuli incorrect: verification over verification
   reg [ 7: 0]   FSM_Rx_Fmt;
   reg [10: 0]   rxchk_TLP_Length;
   reg           rxchk_TLP_Has_Data;
   reg           rxchk_TLP_4DW_Hdr;
   reg           rxchk_Mem_TLP;
   always @(negedge trn_clk )
   if (!trn_reset_n) begin
      FSM_Rx_Fmt      <= 0;
   end
   else begin

      case (FSM_Rx_Fmt)

        'H00: begin
            FSM_Rx_Fmt    <= 'H010;
         end

        'H10: begin
            if ( trn_rsrc_rdy_n | trn_rdst_rdy_n) begin
              FSM_Rx_Fmt        <= 'H10;
            end
            else if (~trn_reof_n) begin
                  $display ("\n %t:\n !! Unexpected trn_reof_n !!", $time);
                  Err_signal <= 1;
            end
            else if (~trn_rsof_n&trn_reof_n) begin
                rxchk_TLP_Has_Data    <= trn_rd[30+32];
                rxchk_TLP_4DW_Hdr     <= trn_rd[29+32];
                rxchk_TLP_Length[10]  <= (trn_rd[9+32:0+32]=='H0);
                rxchk_TLP_Length[9:0] <= trn_rd[9+32:0+32];
                if (trn_rd[28+32:25+32]) rxchk_Mem_TLP    <= 0;    // Msg or MsgD
                else                     rxchk_Mem_TLP    <= 1;    // MWr, MRd or Cpl/D
                FSM_Rx_Fmt        <= 'H12;
            end
            else begin
                $display ("\n %t:\n !! trn_rsof_n error!", $time);
                Err_signal <= 1;
            end
         end


        'H12: begin
            if ( trn_rsrc_rdy_n | trn_rdst_rdy_n) begin
              FSM_Rx_Fmt        <= 'H12;
            end
            else if (!trn_rsof_n) begin
              $display ("\n %t:\n !! trn_rsof_n error! should be 1.", $time);
              Err_signal <= 1;
            end
            else begin
              if (rxchk_TLP_4DW_Hdr & rxchk_TLP_Has_Data) begin
                if (trn_reof_n) begin
                  Err_signal <= 0;
                  FSM_Rx_Fmt        <= 'H20;
                end
                else begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! trn_reof_n error (4-Header, with Payload)! should be 1.", $time);
                end
              end
              else if (rxchk_TLP_4DW_Hdr & !rxchk_TLP_Has_Data) begin
                if (trn_reof_n) begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! trn_reof_n error (4-Header, no Payload)! should be 0.", $time);
                end
                else if (trn_rrem_n=='H00) begin
                    Err_signal <= 0;
                    FSM_Rx_Fmt        <= 'H10;
                end
                else begin
                    Err_signal <= 1;
                    $display ("\n %t:\n !! trn_rrem_n error (4-Header, no Payload)!", $time);
                end
              end
              else if (!rxchk_TLP_4DW_Hdr & !rxchk_TLP_Has_Data) begin
                if (trn_reof_n) begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! trn_reof_n error (3-Header, with Payload)! should be 0.", $time);
                end
                else if (trn_rrem_n=='H0f) begin
                  Err_signal <= 0;
                  FSM_Rx_Fmt        <= 'H10;
                end
                else begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! trn_rrem_n error (3-Header, no Payload)!", $time);
                end
              end
              else if (rxchk_TLP_Length=='H1) begin  // (!rxchk_TLP_4DW_Hdr & rxchk_TLP_Has_Data)
                if (trn_reof_n) begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! trn_reof_n error (3-Header, with Payload)! should be 0.", $time);
                end
                else if (trn_rrem_n=='H00) begin
                  Err_signal <= 0;
                  FSM_Rx_Fmt        <= 'H10;
                end
                else begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! trn_rrem_n error (3-Header, no Payload)!", $time);
                end
              end
              else begin  // (!rxchk_TLP_4DW_Hdr & rxchk_TLP_Has_Data) & (rxchk_TLP_Length>'H1)
                if (trn_reof_n) begin
                  Err_signal <= 0;
                  rxchk_TLP_Length      <= rxchk_TLP_Length - 1;
                  FSM_Rx_Fmt        <= 'H20;
                end
                else begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! trn_reof_n error (3-Header, no Payload)! should be 1.", $time);
                end
              end

              // Address-Length combination check
              if (rxchk_TLP_4DW_Hdr) begin
                if (({1'b0, trn_rd[11:2]} + rxchk_TLP_Length[9:0])>11'H400) begin
                  $display ("\n\n %t:\n !! Rx 4KB straddled !!", $time);
                  $display ("\n Address=%08X  Length=%04X (%04X bytes)\n\n", trn_rd[31:0], rxchk_TLP_Length, rxchk_TLP_Length<<2);
//                  Err_signal <= 1;
                end
                if (trn_rd[63:32]=='H0 && rxchk_Mem_TLP==1) begin
                  $display ("\n %t:\n !! Rx TLP should not be 4-DW headher !!", $time);
                  Err_signal <= 1;
                end
              end 
              else begin
                if (({1'b0, trn_rd[11+32:2+32]} + rxchk_TLP_Length[9:0])>11'H400) begin
                  $display ("\n\n %t:\n !! Rx 4KB straddled !!", $time);
                  $display ("\n Address=%08X  Length=%04X (%04X bytes)\n\n", trn_rd[63:32], rxchk_TLP_Length, rxchk_TLP_Length<<2);
//                  Err_signal <= 1;
                end
              end
            end
          end


        'H20: begin
            if ( trn_rsrc_rdy_n | trn_rdst_rdy_n) begin
              FSM_Rx_Fmt        <= 'H20;
            end
            else if (rxchk_TLP_Length==2) begin
              if (trn_rrem_n=='H00 && trn_reof_n==0) begin
                FSM_Rx_Fmt        <= 'H10;
              end
              else begin
                $display ("\n %t:\n !! trn_reof_n/trn_rrem_n error !!", $time);
                Err_signal <= 1;
              end
            end
            else if (rxchk_TLP_Length==1) begin
              if (trn_rrem_n=='H0f && trn_reof_n==0) begin
                FSM_Rx_Fmt        <= 'H10;
              end
              else begin
                $display ("\n %t:\n !! trn_reof_n/trn_rrem_n error !!", $time);
                Err_signal <= 1;
              end
            end
            else if (rxchk_TLP_Length==0) begin
              $display ("\n %t:\n !! Rx TLP Length error !!", $time);
              Err_signal <= 1;
            end
            else if (!trn_reof_n) begin
              $display ("\n %t:\n !! trn_reof_n too early !!", $time);
              Err_signal <= 1;
            end
            else begin
              rxchk_TLP_Length      <= rxchk_TLP_Length - 2;
              FSM_Rx_Fmt        <= 'H20;
            end
         end

        default: begin
           FSM_Rx_Fmt     <= 'H00;
         end

      endcase
   end




   // TLP format check by Tx
   reg [ 7: 0]   FSM_TLP_Fmt;
   reg [10: 0]   tx_TLP_Length;
   reg [12: 0]   tx_TLP_Address;
   reg           tx_TLP_Has_Data;
   reg           tx_TLP_is_CplD;
   reg           tx_TLP_4DW_Hdr;
   reg           tx_Mem_TLP;
   always @(negedge trn_clk )
   if (!trn_reset_n) begin
      FSM_TLP_Fmt      <= 0;
   end
   else begin

      case (FSM_TLP_Fmt)

        'H00: begin
            FSM_TLP_Fmt    <= 'H010;
         end

        'H10: begin
            if ( trn_tsrc_rdy_n | trn_tdst_rdy_n) begin
              FSM_TLP_Fmt        <= 'H10;
            end
            else if (~trn_teof_n) begin
                  $display ("\n %t:\n !! Unexpected trn_teof_n !!", $time);
                  Err_signal <= 1;
            end
            else if (~trn_tsof_n&trn_teof_n) begin
                tx_TLP_Has_Data    <= trn_td[30+32];
                tx_TLP_4DW_Hdr     <= trn_td[29+32];
                tx_TLP_Length[10]  <= (trn_td[9+32:0+32]=='H0);
                tx_TLP_Length[9:0] <= trn_td[9+32:0+32];
                tx_TLP_is_CplD     <= trn_td[27+32];
                if (trn_td[28+32:25+32]) tx_Mem_TLP    <= 0;    // Msg or MsgD
                else                     tx_Mem_TLP    <= 1;    // MWr, MRd or Cpl/D
                FSM_TLP_Fmt        <= 'H12;
                if (trn_td[31:16] == localID) begin
                   Err_signal <= 0;
                end
                else begin
                   $display ("\n %t:\n !! Tx Bad TLP ReqID for TLP !!", $time);
                   Err_signal <= 1;
                end
            end
            else begin
                $display ("\n %t:\n !! trn_tsof_n error!", $time);
                Err_signal <= 1;
            end
         end


        'H12: begin
            if ( trn_tsrc_rdy_n | trn_tdst_rdy_n) begin
              FSM_TLP_Fmt        <= 'H12;
            end
            else if (!trn_tsof_n) begin
              $display ("\n %t:\n !! trn_tsof_n error! should be 1.", $time);
              Err_signal <= 1;
            end
            else begin
              if (tx_TLP_4DW_Hdr & tx_TLP_Has_Data) begin
                if (trn_teof_n) begin
                  Err_signal   <= 0;
                  FSM_TLP_Fmt        <= 'H20;
                end
                else begin
                  Err_signal   <= 1;
                  $display ("\n %t:\n !! trn_teof_n error (4-Header, with Payload)! should be 1.", $time);
                end
              end
              else if (tx_TLP_4DW_Hdr & !tx_TLP_Has_Data) begin
                if (trn_teof_n) begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! trn_teof_n error (4-Header, no Payload)! should be 0.", $time);
                end
                else if (trn_trem_n=='H00) begin
                    Err_signal <= 0;
                    FSM_TLP_Fmt        <= 'H10;
                end
                else begin
                    Err_signal <= 1;
                    $display ("\n %t:\n !! trn_trem_n error (4-Header, no Payload)!", $time);
                end
              end
              else if (!tx_TLP_4DW_Hdr & !tx_TLP_Has_Data) begin
                if (trn_teof_n) begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! trn_teof_n error (3-Header, with Payload)! should be 0.", $time);
                end
                else if (trn_trem_n=='H0f) begin
                  Err_signal <= 0;
                  FSM_TLP_Fmt        <= 'H10;
                end
                else begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! trn_trem_n error (3-Header, no Payload)!", $time);
                end
              end
              else if (tx_TLP_Length=='H1) begin  // (!tx_TLP_4DW_Hdr & tx_TLP_Has_Data)
                if (trn_teof_n) begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! trn_teof_n error (3-Header, with Payload)! should be 0.", $time);
                end
                else if (trn_trem_n=='H00) begin
                  if (tx_TLP_is_CplD && (trn_td[31+32:16+32]==`C_HOST_RDREQ_ID)) begin
                    Err_signal    <= 0;
                    FSM_TLP_Fmt      <= 'H10;
                  end
                  else if (tx_TLP_is_CplD) begin
                    Err_signal   <= 1;
                    $display ("\n %t:\n !! Tx CplD Requester ID Wrong (TLP Length ==1 )!! ", $time);
                    FSM_TLP_Fmt      <= 'H10;
                  end
                  else begin
                    Err_signal    <= 0;
                    FSM_TLP_Fmt      <= 'H10;
                  end
                end
                else begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! trn_trem_n error (3-Header, no Payload)!", $time);
                end
              end
              else begin  // (!tx_TLP_4DW_Hdr & tx_TLP_Has_Data) & (tx_TLP_Length>'H1)
                if (trn_teof_n) begin
                  if (tx_TLP_is_CplD && (trn_td[31+32:16+32]==`C_HOST_RDREQ_ID)) begin
                    tx_TLP_Length      <= tx_TLP_Length - 1;
                    FSM_TLP_Fmt        <= 'H20;
                  end
                  else if (tx_TLP_is_CplD) begin
                    Err_signal   <= 1;
                    $display ("\n %t:\n !! Tx CplD Requester ID Wrong (TLP Length !=1 )!! ", $time);
                    FSM_TLP_Fmt        <= 'H20;
                  end
                  else begin
                    tx_TLP_Length      <= tx_TLP_Length - 1;
                    FSM_TLP_Fmt        <= 'H20;
                  end
                end
                else begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! trn_teof_n error (3-Header, no Payload)! should be 1.", $time);
                end
              end

              // Address-Length combination check
              if (tx_TLP_4DW_Hdr) begin
                if (({1'b0, trn_td[11:2]} + tx_TLP_Length[9:0])>11'H400) begin
                  $display ("\n %t:\n !! Tx 4KB straddled !!", $time);
                  $display ("\n Address=%08X  Length=%04X (%04X bytes)\n", trn_td[31:0], tx_TLP_Length, tx_TLP_Length<<2);
                  Err_signal <= 1;
                end
                if (trn_td[63:32]=='H0 && tx_Mem_TLP==1) begin
                  $display ("\n %t:\n !! Tx TLP should not be 4-DW headher !!", $time);
                  Err_signal <= 1;
                end
              end 
              else begin
                if (({1'b0, trn_td[11+32:2+32]} + tx_TLP_Length[9:0])>11'H400) begin
                  $display ("\n %t:\n !! Tx 4KB straddled !!", $time);
                  $display ("\n Address=%08X  Length=%04X (%04X bytes)\n", trn_td[63:32], tx_TLP_Length, tx_TLP_Length<<2);
                  Err_signal <= 1;
                end
              end

            end
          end


        'H20: begin
            if ( trn_tsrc_rdy_n | trn_tdst_rdy_n) begin
              FSM_TLP_Fmt        <= 'H20;
            end
            else if (tx_TLP_Length==2) begin
              if (trn_trem_n=='H00 && trn_teof_n==0) begin
                FSM_TLP_Fmt        <= 'H10;
              end
              else begin
                $display ("\n %t:\n !! trn_teof_n/trn_trem_n error !!\n", $time);
                Err_signal <= 1;
              end
            end
            else if (tx_TLP_Length==1) begin
              if (trn_trem_n=='H0f && trn_teof_n==0) begin
                FSM_TLP_Fmt        <= 'H10;
              end
              else begin
                $display ("\n %t:\n !! trn_teof_n/trn_trem_n error !!\n", $time);
                Err_signal <= 1;
              end
            end
            else if (tx_TLP_Length==0) begin
              $display ("\n %t:\n !! Tx TLP Length error !!", $time);
              Err_signal <= 1;
            end
            else if (!trn_teof_n) begin
              $display ("\n %t:\n !! trn_teof_n too early !!", $time);
              Err_signal <= 1;
            end
            else begin
              tx_TLP_Length      <= tx_TLP_Length - 2;
              FSM_TLP_Fmt        <= 'H20;
            end
         end

        default: begin
           FSM_TLP_Fmt     <= 'H00;
         end

      endcase
   end




   //************************************************//
   //************************************************//
   //************************************************//

   reg  [ 7:00] FSM_Tx_Desc_MRd;
  // Descriptors MRd
   always @(negedge trn_clk )
   if (!trn_reset_n) begin
      FSM_Tx_Desc_MRd        <= 0;
      Desc_tx_MRd_Valid      <= 0;
   end
   else begin

      case (FSM_Tx_Desc_MRd)

        'H00: begin
            FSM_Tx_Desc_MRd       <= 'H10;
         end

        'H10: begin
           case ({ trn_tsrc_rdy_n
                 , trn_tdst_rdy_n
                 , trn_tsof_n
                 , trn_td[15]
                 })

             'B0001:
                 if ( (trn_td[31+32:24+32]=='H00 || trn_td[31+32:24+32]=='H20)
                    &&(trn_td[9+32:32]=='H8)) begin
                      Desc_tx_MRd_Leng[10]  <= (trn_td[9+32:32]==0);
                      Desc_tx_MRd_Leng[9:0] <= trn_td[9+32:32];
                      Desc_tx_MRd_TAG       <= trn_td[15:8];
                      FSM_Tx_Desc_MRd <= 'H31;
                 end
                 else begin
                      FSM_Tx_Desc_MRd <= 'H10;
                 end

              default: begin
                 FSM_Tx_Desc_MRd <= 'H10;
              end

           endcase
         end


        'H31: begin   // Low 32 bits Address
           if (trn_tsrc_rdy_n|trn_tdst_rdy_n) begin
             FSM_Tx_Desc_MRd   <= 'H31;
           end
           else begin
               Desc_tx_MRd_Addr      <= trn_td[31:00];
               Desc_tx_MRd_Valid     <= 1;
               FSM_Tx_Desc_MRd       <= 'H10;
           end
         end


        default: begin
           FSM_Tx_Desc_MRd <= 'H00;
         end

      endcase
   end



   // DMA MRd out of Tx
   reg [ 7: 0]   FSM_Tx_MRd;
   reg           tx_DMA_MRd_A64b;
   always @(negedge trn_clk )
   if (!trn_reset_n) begin
      FSM_Tx_MRd      <= 0;
      tx_MRd_come     <= 0;
   end
   else begin

      case (FSM_Tx_MRd)

        'H00: begin
            FSM_Tx_MRd       <= 'H10;
         end

        'H10: begin
           case ({ trn_tsrc_rdy_n
                 , trn_tdst_rdy_n
                 , trn_tsof_n
                 , trn_td[15]
                 })

             'B0000:
                 case (trn_td[31+32:24+32])
                   'H00: begin   // 3-dw header
                      tx_MRd_Length[9:0] <= trn_td[9+32:32];
                      tx_MRd_Length[10]  <= (trn_td[9+32:32]=='H0)?1:0;
                      tx_MRd_Tag         <= trn_td[15:8];
                      FSM_Tx_MRd         <= 'H30;
                      tx_DMA_MRd_A64b    <= 0;
                    end

                   'H20: begin   // 4-dw header
                      tx_MRd_Length[9:0] <= trn_td[9+32:32];
                      tx_MRd_Length[10]  <= (trn_td[9+32:32]=='H0)?1:0;
                      tx_MRd_Tag         <= trn_td[15:8];
                      FSM_Tx_MRd         <= 'H30;
                      tx_DMA_MRd_A64b    <= 1;
                    end

                   default: begin
                      FSM_Tx_MRd <= 'H10;   // Idle
                    end
                 endcase

              default: begin
                 FSM_Tx_MRd <= 'H10;
              end

           endcase
         end


        'H30: begin
           if (trn_tsrc_rdy_n|trn_tdst_rdy_n) begin
             FSM_Tx_MRd <= 'H30;
           end
           else if( trn_td[1:0]==0) begin
             FSM_Tx_MRd <= 'H10;
             tx_MRd_come <= 'B1;
           end
           else begin
             $display ("\n %t:\n !! Bad TLP Address for Tx MRd !!", $time);
             Err_signal <= 1;
           end
        end

        default: begin
           FSM_Tx_MRd <= 'H00;
         end

      endcase
   end



   // Msg checking ...
   reg [7: 0] fsm_Tx_Msg;
   reg [3: 0] tx_Msg_Tag_Lo;
   always @(negedge trn_clk )
   if (!trn_reset_n) begin
      fsm_Tx_Msg      <= 0;
      tx_Msg_Tag_Lo   <= 1;
   end

   else begin

      case (fsm_Tx_Msg)

        'H00: begin
            fsm_Tx_Msg    <= 'H10;
         end

        'H10: begin
           case ({ trn_tsrc_rdy_n
                 , trn_tdst_rdy_n
                 , trn_tsof_n
                 })

             'B000:
                 if (trn_td[31+32:28+32]=='H3) begin
                    fsm_Tx_Msg    <= 'H30;
                    if ( trn_td[11:8] != tx_Msg_Tag_Lo ) begin
                      $display ("\n %t:\n !! Msg Tag bad !!", $time, trn_td[11:8]);
                      Err_signal <= 1;
                    end
                    else if ( trn_td[7:0] == `C_MSG_CODE_INTA ) begin
//                      fsm_Tx_Msg   <= 'H30;
                      Accum_Msg_INTA <= Accum_Msg_INTA + 1;
                    end
                    else if ( trn_td[7:0] == `C_MSG_CODE_INTA_N ) begin
//                      fsm_Tx_Msg   <= 'H30;
                      Accum_Msg_INTA_n <= Accum_Msg_INTA_n + 1;
                    end
                    else begin
                      $display ("\n %t:\n !! Bad Msg code (0x%2x) !!", $time, trn_td[7:0]);
                      Err_signal <= 1;
                    end
                 end
                 else begin
                      fsm_Tx_Msg    <= 'H10;
                 end

              default: begin
                 fsm_Tx_Msg    <= 'H10;
              end

           endcase
         end


        'H30: begin
           if (trn_tsrc_rdy_n|trn_tdst_rdy_n) begin
             fsm_Tx_Msg <= 'H30;
           end
           else if (trn_td) begin
             $display ("\n %t:\n !! Msg data bad!!", $time);
             Err_signal <= 1;
           end
           else begin
             fsm_Tx_Msg <= 'H10;
             tx_Msg_Tag_Lo  <= tx_Msg_Tag_Lo + 1;
           end
         end


        default: begin
           fsm_Tx_Msg  <= 'H00;
         end

      endcase
   end



   // ================================================= //
   // =======     Interrupt uneven checking     ======= //
   // ================================================= //
   always @ Accum_Msg_INTA
     if (Accum_Msg_INTA>Accum_Msg_INTA_n+1) begin
        $display("\n\n  INTA overrun at %t\n\n", $time);
        Err_signal <= 1;
     end

   // 
   always @ Accum_Msg_INTA_n
     if (Accum_Msg_INTA_n>Accum_Msg_INTA) begin
        $display("\n\n  #INTA overrun at %t\n\n", $time);
        Err_signal <= 1;
     end




  // ***************************************** //
  //                   Tasks                   //
  // ***************************************** //

  ///////////////////////////////////////////////
  //   Wait for the next positive clock event  //
  ///////////////////////////////////////////////
  task To_the_next_Event;
  begin
    wait (!trn_clk);
    wait (trn_clk);
    # `T_DELAY_AFTER ;
  end
  endtask

  ///////////////////////////////////////////////
  //   Wait for the next negative clock event  //
  ///////////////////////////////////////////////
  task To_the_next_Tx_Data;
  begin
    wait (trn_clk);
    wait (!trn_clk);
    # `T_DELAY_AFTER ;
  end
  endtask


  ///////////////////////////////////////////////
  //   Insert GAP                              //
  ///////////////////////////////////////////////
  task Gap_Insert_Rx;
  begin
    To_the_next_Event;
    trn_rsof_n <= 1;
    trn_reof_n <= 1;
    trn_rsrc_rdy_n <= 1;
    trn_rbar_hit_n <= `C_NO_BAR_HIT;
    trn_rd <= -1;
    trn_rrem_n <= -1;
  end
  endtask


  ///////////////////////////////////////////////
  //                                           //
  //   Feed TLP to Rx: MRd, MWr, Cpl/D, Msg    //
  //                                           //
  ///////////////////////////////////////////////
  task TLP_Feed_Rx;
    input         Use_Private_Array;   // Public or private
    input [11:0]  IndexA;              // Start point in the Array
    input [ 6:0]  BAR_Hit_N;           // Which BAR is hit

//    integer       hdr_Leng;
    reg           TLP_has_Payload;
    reg           TLP_hdr_4DW;
    reg   [10:0]  jr;
    reg   [10:0]  payload_Leng;

  begin

    // TLP format extraction
    TLP_has_Payload     <= Hdr_Array[0][30] ;
//    hdr_Leng            <= Hdr_Array[0][29] + 3;
    TLP_hdr_4DW         <= Hdr_Array[0][29];

    // Header #0
    To_the_next_Event;
    trn_rsof_n          <= 0;
    trn_reof_n          <= 1;
    trn_rsrc_rdy_n      <= 0;
    trn_rbar_hit_n      <= BAR_Hit_N;
    trn_rd              <= {Hdr_Array[0], Hdr_Array[1]};
    trn_rrem_n          <= 0;

    payload_Leng        <= {Hdr_Array[0][9:0]?1'b0:1'b1, Hdr_Array[0][9:0]};

    // Header words # 1
    for (jr=1; jr<2; jr=jr+1) begin
      To_the_next_Event;
      trn_rsrc_rdy_n  <= trn_rsrc_rdy_n_seed;
      if (trn_rsrc_rdy_n_seed) begin
          trn_rsof_n    <= trn_rsof_n;
          trn_rd        <= trn_rd;
          trn_rrem_n    <= trn_rrem_n;
          trn_reof_n    <= trn_reof_n;
//          #0.1    jr    <= jr-1;
          jr             = jr-1;      // !! not <= !!
        end
      else begin
          trn_rsof_n    <= 1;
          if (TLP_hdr_4DW) begin
            trn_rrem_n    <= 'H00;
            trn_rd        <= {Hdr_Array[2], Hdr_Array[3]};
          end
          else if (TLP_has_Payload) begin
            trn_rrem_n    <= 'H00;
            if (Use_Private_Array)
              trn_rd        <= {Hdr_Array[2],Inv_Endian (Private_Array[IndexA])};
            else
              trn_rd        <= {Hdr_Array[2],Inv_Endian (D_Array[IndexA])};
          end
          else begin
            trn_rrem_n    <= 'H0f;
            trn_rd        <= {Hdr_Array[2], 32'H0};
          end
          if (payload_Leng<='H1 && TLP_hdr_4DW==0) begin
            trn_reof_n    <= 0;
          end
          else if (!TLP_has_Payload) begin
            trn_reof_n    <= 0;
          end
          else begin
            trn_reof_n    <= 1;
          end
        end
    end    // Header done.

    // Payload data ...
    if ((TLP_has_Payload && TLP_hdr_4DW) || (TLP_has_Payload && (payload_Leng>'H1) && !TLP_hdr_4DW))

       for (jr=(!TLP_hdr_4DW); jr<payload_Leng; jr=jr+2) begin
         To_the_next_Event;
         trn_rsrc_rdy_n <= trn_rsrc_rdy_n_seed;
         if (trn_rsrc_rdy_n_seed) begin
           trn_rd       <= trn_rd;
           trn_rrem_n   <= trn_rrem_n;
           trn_reof_n   <= trn_reof_n;
//           #0.1    jr   <= jr-1;
           jr            = jr-2;      // !! not <= !!
         end
         else begin
           if (jr==payload_Leng-1 || jr==payload_Leng-2) begin
             trn_reof_n   <= 0;
           end
           else begin
             trn_reof_n   <= 1;
           end

           if (jr==payload_Leng-1) begin
             trn_rrem_n   <= 'H0f;
             if (Use_Private_Array)
               trn_rd     <= {Inv_Endian(Private_Array[IndexA+jr]), 32'Hffff_ffff};
             else
               trn_rd     <= {Inv_Endian(D_Array[IndexA+jr]), 32'Hffff_ffff};
           end
           else begin
             trn_rrem_n   <= 'H00;
             if (Use_Private_Array)
               trn_rd     <= {Inv_Endian(Private_Array[IndexA+jr]), Inv_Endian(Private_Array[IndexA+jr+1])};
             else
               trn_rd     <= {Inv_Endian(D_Array[IndexA+jr]), Inv_Endian(D_Array[IndexA+jr+1])};
           end


         end
       end
    // Payload done.

  end
  endtask


    /////////////////////////////////////////////
   //                                         //
  //   Function -  Endian Inversion 64-bit   //
 //                                         //
/////////////////////////////////////////////
   function [31:00] Inv_Endian;
   input [31:00] Data;
   begin
      Inv_Endian = {Data[ 7: 0], Data[15: 8], Data[23:16], Data[31:24]};
   end
   endfunction


endmodule
