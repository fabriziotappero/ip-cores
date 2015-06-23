
// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on


`include "oc8051_defines.v"
module turbo8051  (

             reset_n                ,
             fastsim_mode           ,
             mastermode             ,
             xtal_clk               ,
             clkout                 ,
             reset_out_n            ,

        // Reg Bus Interface Signal
             ext_reg_cs             ,
             ext_reg_tid            ,
             ext_reg_wr             ,
             ext_reg_addr           ,
             ext_reg_wdata          ,
             ext_reg_be             ,

            // Outputs
             ext_reg_rdata          ,
             ext_reg_ack            ,


          // Line Side Interface TX Path
             phy_tx_en              ,
             phy_txd                ,
             phy_tx_clk             ,

          // Line Side Interface RX Path
             phy_rx_clk             ,
             phy_rx_dv              ,
             phy_rxd                ,

          //MDIO interface
             MDC                    ,
             MDIO                   ,


       // UART Line Interface
             si                     ,
             so                     ,


             spi_sck                ,
             spi_so                 ,
             spi_si                 ,
             spi_cs_n               ,


         // External ROM interface
             wb_xrom_adr            ,
             wb_xrom_ack            ,
             wb_xrom_err            ,
             wb_xrom_wr             ,
             wb_xrom_rdata          ,
             wb_xrom_wdata          ,
             
             wb_xrom_stb            ,
             wb_xrom_cyc            ,

         // External RAM interface
             wb_xram_adr            ,
             wb_xram_ack            ,
             wb_xram_err            ,
             wb_xram_wr             ,
             wb_xram_be             ,
             wb_xram_rdata          ,
             wb_xram_wdata          ,
             
             wb_xram_stb            ,
             wb_xram_cyc,

             ea_in



        );


//----------------------------------------
// Global Clock Defination
//----------------------------------------
input            reset_n               ; // Active Low Reset           
input            fastsim_mode          ; // Fast Sim Mode
input            mastermode            ; // 1 : Risc master mode

input            xtal_clk              ; // xtal clock 25Mhz
output           clkout                ; // clock output
output           reset_out_n           ; // clock output

//---------------------------------
// Reg Bus Interface Signal
//---------------------------------
input            ext_reg_cs            ;
input            ext_reg_wr            ;
input [3:0]      ext_reg_tid           ;
input [14:0]     ext_reg_addr          ;
input [31:0]     ext_reg_wdata         ;
input [3:0]      ext_reg_be            ;

// Outputs
output [31:0]    ext_reg_rdata         ;
output           ext_reg_ack           ;

//----------------------------------------
// MAC Line Side Interface TX Path
//----------------------------------------
output           phy_tx_en              ; // MAC Tx Enable
output [7:0]     phy_txd                ; // MAC Tx Data
input           phy_tx_clk             ; // MAC Tx Clock

//----------------------------------------
// MAC Line Side Interface RX Path
//----------------------------------------
input           phy_rx_clk             ; // MAC Rx Clock
output           phy_rx_dv              ; // MAC Rx Dv
output [7:0]     phy_rxd                ; // MAC Rxd

//----------------------------------------
// MDIO interface
//----------------------------------------
output           MDC                    ; // MDIO Clock
inout            MDIO                   ; // MDIO Data


//----------------------------------------
// UART Line Interface
//----------------------------------------
input            si                     ; // serial in
output           so                     ; // serial out

//----------------------------------------
// SPI Line Interface
//----------------------------------------

output           spi_sck                ; // clock
output           spi_so                 ; // data out
input            spi_si                 ; // data in
output  [3:0]    spi_cs_n               ; // chip select

//----------------------------------------
// 8051 core ROM related signals
//---------------------------------------
output [15:0]    wb_xrom_adr            ; // instruction address
input            wb_xrom_ack            ; // instruction acknowlage
output           wb_xrom_err            ; // instruction error
output           wb_xrom_wr             ; // instruction error
input  [31:0]    wb_xrom_rdata          ; // rom data input
output [31:0]    wb_xrom_wdata          ; // rom data input

output           wb_xrom_stb            ; // instruction strobe
output           wb_xrom_cyc            ; // instruction cycle


//----------------------------------------
// 8051 core RAM related signals
//---------------------------------------
output [15:0]    wb_xram_adr            ; // data-ram address
input            wb_xram_ack            ; // data-ram acknowlage
output           wb_xram_err            ; // data-ram error
output           wb_xram_wr             ; // data-ram error
output [3:0]     wb_xram_be             ; // Byte enable
input  [31:0]    wb_xram_rdata          ; // ram data input
output [31:0]    wb_xram_wdata          ; // ram data input

output           wb_xram_stb            ; // data-ram strobe
output           wb_xram_cyc            ; // data-ram cycle


input            ea_in                  ; // input for external access (ea signal)
                                          // ea=0 program is in external rom
                                          // ea=1 program is in internal rom
//---------------------------------------------
// 8051 Instruction ROM interface
//---------------------------------------------
wire    [15:0]   wbi_risc_adr;
wire    [31:0]   wbi_risc_rdata;


//-----------------------------
// MAC Related wire Decleration
//-----------------------------
wire [8:0]       app_rxfifo_rddata_o    ;
wire [31:0]      app_rx_desc_data       ;
wire             mdio_out_en            ;
wire             mdio_out               ;
wire             gen_resetn             ;


//---------------------------------------------
// 8051 Instruction RAM interface
//---------------------------------------------
wire    [15:0]   wbd_risc_adr           ;
wire    [7:0]    wbd_risc_rdata         ;
wire    [7:0]    wbd_risc_wdata         ;
           
wire    [14:0]   reg_mac_addr           ;
wire    [31:0]   reg_mac_wdata          ;
wire    [3:0]    reg_mac_be             ;
wire    [31:0]   reg_mac_rdata          ;
wire             reg_mac_ack            ;

wire    [14:0]   reg_uart_addr          ;
wire    [31:0]   reg_uart_wdata         ;
wire    [3:0]    reg_uart_be            ;
wire    [31:0]   reg_uart_rdata         ;
wire             reg_uart_ack           ;
                                          
wire    [14:0]   reg_spi_addr           ;
wire    [31:0]   reg_spi_wdata          ;
wire    [3:0]    reg_spi_be             ;
wire    [31:0]   reg_spi_rdata          ;
wire             reg_spi_ack            ;

wire    [3:0]    wb_xrom_be            ;
wire    [3:0]    wb_xram_be            ;

wire    [7:0]    p0              ;
wire    [7:0]    p1              ;
wire    [7:0]    p2              ;
wire    [7:0]    p3              ;

wire [3:0]       wbgt_taddr      ;
wire [31:0]      wbgt_din        ;
wire [31:0]      wbgt_dout       ;
wire [12:0]      wbgt_addr       ;
wire [3:0]       wbgt_be         ;
wire             wbgt_we         ;
wire             wbgt_ack        ;
wire             wbgt_stb        ;
wire             wbgt_cyc        ;

wire [3:0]       wbgr_taddr      ;
wire [31:0]      wbgr_din        ;
wire [31:0]      wbgr_dout       ;
wire [12:0]      wbgr_addr       ;
wire [3:0]       wbgr_be         ;
wire             wbgr_we         ;
wire             wbgr_ack        ;
wire             wbgr_stb        ;
wire             wbgr_cyc        ;

wire [8:0]       app_txfifo_wrdata_i;
wire [15:0]      app_txfifo_addr;
wire [15:0]      app_rxfifo_addr;
wire [3:0]       tx_qcnt    ;
wire [3:0]       rx_qcnt    ;

wire tx_q_empty  = (tx_qcnt == 0);
wire rx_q_empty  = (rx_qcnt == 0);

wire [31:0] reg_rdata = (reg_mac_ack)  ? reg_mac_rdata :
                   (reg_uart_ack) ? reg_uart_rdata :
                   (reg_spi_ack)  ? reg_spi_rdata : 'h0;

wire reg_ack = reg_mac_ack | reg_uart_ack | reg_spi_ack;


assign reset_out_n = gen_resetn;


assign wb_xram_adr[15]    = 0;
assign wb_xram_adr[1:0]   = 2'b00;
assign wb_xrom_adr[15:13] = 0;

wire [9:0] cfg_tx_buf_qbase_addr;
wire [9:0] cfg_rx_buf_qbase_addr;

// QCounter Inc/dec generation

wire tx_qcnt_inc = (cfg_tx_buf_qbase_addr == wb_xram_adr[15:6]) & wb_xram_stb & wb_xram_wr & wb_xram_ack && (wb_xram_be[3] == 1'b1);
wire tx_qcnt_dec = (cfg_tx_buf_qbase_addr == wb_xram_adr[15:6]) & wb_xram_stb & !wb_xram_wr & wb_xram_ack && (wb_xram_be[3] == 1'b1);
wire rx_qcnt_inc = (cfg_rx_buf_qbase_addr == wb_xram_adr[15:6]) & wb_xram_stb & wb_xram_wr & wb_xram_ack && (wb_xram_be[3] == 1'b1);
wire rx_qcnt_dec = (cfg_rx_buf_qbase_addr == wb_xram_adr[15:6]) & wb_xram_stb & !wb_xram_wr & wb_xram_ack && (wb_xram_be[3] == 1'b1);

assign reg_mac_addr[1:0] = 2'b0;
assign reg_uart_addr[1:0] = 2'b0;
assign reg_spi_addr[1:0] = 2'b0;
//-------------------------------------------
// clock-gen  instantiation
//-------------------------------------------
clkgen u_clkgen (
               . reset_n                (reset_n               ),
               . fastsim_mode           (fastsim_mode          ),
               . mastermode             (mastermode            ),
               . xtal_clk               (xtal_clk              ),
               . clkout                 (clkout                ),
               . gen_resetn             (gen_resetn            ),
               . risc_reset             (risc_reset            ),
               . app_clk                (app_clk               ),
               . uart_ref_clk           (uart_clk_16x          )

              );

//--------------------------------------------------------------
// Target ID Mapping
// 4'b0100 -- MAC core
// 4'b0011 -- UART
// 4'b0010 -- SPI core
// 4'b0001 -- External RAM
// 4'b0000 -- External ROM
//--------------------------------------------------------------


wire [31:0] wb_master2_rdata;

wire [3:0] wb_master2_be = (wbd_risc_adr[1:0] == 2'b00) ? 4'b0001:
                           (wbd_risc_adr[1:0] == 2'b01) ? 4'b0010:
                           (wbd_risc_adr[1:0] == 2'b10) ? 4'b0100: 4'b1000;

assign     wbd_risc_rdata = (wbd_risc_adr[1:0] == 2'b00) ? wb_master2_rdata[7:0]:
                            (wbd_risc_adr[1:0] == 2'b01) ? wb_master2_rdata[15:8]:
                            (wbd_risc_adr[1:0] == 2'b10) ? wb_master2_rdata[23:16]: 
                            wb_master2_rdata[31:24];

//------------------------------
// RISC Data Memory Map
// 0x0000 to 0x7FFFF  - Data Memory
// 0x8000 to 0x8FFF   - SPI 
// 0x9000 to 0x9FFF   - UART
// 0xA000 to 0xAFFF   - MAC Core
//-----------------------------
// 
wire [3:0] wbd_tar_id     = (wbd_risc_adr[15]    == 1'b0 ) ? 4'b0001 :
                            (wbd_risc_adr[15:12] == 4'b1000 ) ? 4'b0010 :
                            (wbd_risc_adr[15:12] == 4'b1001 ) ? 4'b0011 : 4'b0100;

wb_crossbar #(5,5,32,4,13,4) u_wb_crossbar (

              .rst_n                    (gen_resetn           ), 
              .clk                      (app_clk              ),


    // Master Interface Signal
              .wbd_taddr_master         ({4'b0000,
                                          wbd_tar_id,
                                          ext_reg_tid,
                                          wbgt_taddr,
                                          wbgr_taddr}),
              .wbd_din_master           ({32'h0 ,
                                          {wbd_risc_wdata[7:0],
                                          wbd_risc_wdata[7:0],
                                          wbd_risc_wdata[7:0],
                                          wbd_risc_wdata[7:0]},
                                          ext_reg_wdata,
                                          wbgt_din,
                                          wbgr_din}
                                         ),
              .wbd_dout_master          ({wbi_risc_rdata,
                                          wb_master2_rdata,
                                          ext_reg_rdata,
                                          wbgt_dout,
                                          wbgr_dout}
                                           ),
              .wbd_adr_master           ({wbi_risc_adr[12:0],
                                          wbd_risc_adr[14:2],
                                          ext_reg_addr[14:2],
                                          wbgt_addr,
                                          wbgr_addr}
                                          ), 
              .wbd_be_master            ({4'b1111,
                                          wb_master2_be,
                                          ext_reg_be,
                                          wbgt_be,
                                          wbgr_be}
                                           ), 
              .wbd_we_master            ({1'b0,wbd_risc_we,ext_reg_wr,
                                         wbgt_we,wbgr_we}   ), 
              .wbd_ack_master           ({wbi_risc_ack,
                                          wbd_risc_ack,
                                          ext_reg_ack,
                                          wbgt_ack,
                                          wbgr_ack} ),
              .wbd_stb_master           ({wbi_risc_stb,
                                          wbd_risc_stb,
                                          ext_reg_cs,
                                          wbgt_stb,
                                          wbgr_stb} ), 
              .wbd_cyc_master           ({wbi_risc_stb|wbi_risc_ack,
                                          wbd_risc_stb|wbd_risc_ack,
                                          ext_reg_cs|ext_reg_ack,
                                          wbgt_cyc,wbgr_cyc}), 
              .wbd_err_master           (),
              .wbd_rty_master           (),
 
    // Slave Interface Signal
              .wbd_din_slave            ({
                                          reg_mac_wdata,
                                          reg_uart_wdata,
                                          reg_spi_wdata,
                                          wb_xram_wdata,
                                          wb_xrom_wdata
                                          }), 
              .wbd_dout_slave           ({
                                          reg_mac_rdata,
                                          reg_uart_rdata,
                                          reg_spi_rdata,
                                          {wb_xram_rdata},
                                          wb_xrom_rdata
                                         }),
              .wbd_adr_slave            ({reg_mac_addr[14:2],
                                          reg_uart_addr[14:2],
                                          reg_spi_addr[14:2],
                                          wb_xram_adr[14:2],
                                          wb_xrom_adr[12:0]}
                                        ), 
              .wbd_be_slave             ({reg_mac_be,
                                          reg_uart_be,
                                          reg_spi_be,
                                          wb_xram_be,
                                          wb_xrom_be}
                                        ), 
              .wbd_we_slave             ({reg_mac_wr,
                                          reg_uart_wr,
                                          reg_spi_wr,
                                          wb_xram_wr,
                                          wb_xrom_wr
                                          }), 
              .wbd_ack_slave            ({reg_mac_ack,
                                          reg_uart_ack,
                                          reg_spi_ack,
                                          wb_xram_ack,
                                          wb_xrom_ack
                                         }),
              .wbd_stb_slave            ({reg_mac_cs,
                                          reg_uart_cs,
                                          reg_spi_cs,
                                          wb_xram_stb,
                                          wb_xrom_stb
                                         }), 
              .wbd_cyc_slave            (), 
              .wbd_err_slave            (),
              .wbd_rty_slave            ()
         );


//-------------------------------------------
// GMAC core instantiation
//-------------------------------------------

g_mac_top u_eth_dut (

          .scan_mode                    (1'b0                  ), 
          .s_reset_n                    (gen_resetn            ), 
          .tx_reset_n                   (gen_resetn            ),
          .rx_reset_n                   (gen_resetn            ),
          .reset_mdio_clk_n             (gen_resetn            ),
          .app_reset_n                  (gen_resetn            ),

        // Reg Bus Interface Signal
          . reg_cs                      (reg_mac_cs            ),
          . reg_wr                      (reg_mac_wr            ),
          . reg_addr                    (reg_mac_addr[5:2]     ),
          . reg_wdata                   (reg_mac_wdata         ),
          . reg_be                      (reg_mac_be            ),

            // Outputs
          . reg_rdata                   (reg_mac_rdata         ),
          . reg_ack                     (reg_mac_ack           ),


          .app_clk                      (app_clk               ),

          // Application RX FIFO Interface
          .app_txfifo_wren_i            (app_txfifo_wren_i   ),
          .app_txfifo_wrdata_i          (app_txfifo_wrdata_i ),
          .app_txfifo_addr              (app_txfifo_addr     ),
          .app_txfifo_full_o            (app_txfifo_full_o   ),
          .app_txfifo_afull_o           (app_txfifo_afull_o  ),
          .app_txfifo_space_o           (                    ),

          // Application TX FIFO Interface
          .app_rxfifo_rden_i            (app_rxfifo_rden_i   ),
          .app_rxfifo_empty_o           (app_rxfifo_empty_o  ),
          .app_rxfifo_aempty_o          (app_rxfifo_aempty_o ),
          .app_rxfifo_cnt_o             (                    ),
          .app_rxfifo_rdata_o           (app_rxfifo_rddata_o ),
          .app_rxfifo_addr              (app_rxfifo_addr     ),

          .app_rx_desc_req              (app_rx_desc_req     ),
          .app_rx_desc_ack              (app_rx_desc_ack     ),
          .app_rx_desc_discard          (app_rx_desc_discard ),
          .app_rx_desc_data             (app_rx_desc_data    ),

          // Line Side Interface TX Path
          .phy_tx_en                    (phy_tx_en           ),
          .phy_tx_er                    (                    ),
          .phy_txd                      (phy_txd             ),
          .phy_tx_clk                   (phy_tx_clk          ),

          // Line Side Interface RX Path
          .phy_rx_clk                   (phy_rx_clk          ),
          .phy_rx_er                    (1'b0                ),
          .phy_rx_dv                    (phy_rx_dv           ),
          .phy_rxd                      (phy_rxd             ),
          .phy_crs                      (1'b0                ),

          //MDIO interface
          .mdio_clk                     (MDC                 ),
          .mdio_in                      (MDIO                ),
          .mdio_out_en                  (mdio_out_en         ),
          .mdio_out                     (mdio_out            ),

          // QCounter
          .rx_buf_qbase_addr            (cfg_rx_buf_qbase_addr),
          .tx_buf_qbase_addr            (cfg_tx_buf_qbase_addr),

          .tx_qcnt_inc                  (tx_qcnt_inc),
          .tx_qcnt_dec                  (tx_qcnt_dec),
          .rx_qcnt_inc                  (rx_qcnt_inc),
          .rx_qcnt_dec                  (rx_qcnt_dec),
          .tx_qcnt                      (tx_qcnt),
          .rx_qcnt                      (rx_qcnt)


       );


assign MDIO = (mdio_out_en) ? mdio_out : 1'bz;



wb_rd_mem2mem #(32,4,13,4) u_wb_gmac_tx (

          .rst_n               ( gen_resetn         ),
          .clk                 ( app_clk            ),

    // descriptor handshake
          .cfg_desc_baddr      (cfg_tx_buf_qbase_addr),
          .desc_q_empty        (tx_q_empty           ),

    // Master Interface Signal
          .mem_taddr           ( 4'h1               ),
          .mem_full            (app_txfifo_full_o   ),
          .mem_afull           (app_txfifo_afull_o  ),
          .mem_wr              (app_txfifo_wren_i   ), 
          .mem_din             (app_txfifo_wrdata_i ),
 
    // Slave Interface Signal
          .wbo_dout            ( wbgt_dout          ),
          .wbo_taddr           ( wbgt_taddr         ),
          .wbo_addr            ( wbgt_addr          ),
          .wbo_be              ( wbgt_be            ),
          .wbo_we              ( wbgt_we            ),
          .wbo_ack             ( wbgt_ack           ),
          .wbo_stb             ( wbgt_stb           ), 
          .wbo_cyc             ( wbgt_cyc           ), 
          .wbo_err             ( wbgt_err           ),
          .wbo_rty             ( wbgt_rty           )
         );


wb_wr_mem2mem #(32,4,13,4) u_wb_gmac_rx(

          .rst_n               ( gen_resetn   ), 
          .clk                 ( app_clk      ),


    // Master Interface Signal
          .mem_taddr           ( 4'h1                 ),
          .mem_addr            (app_rxfifo_addr       ),
          .mem_empty           (app_rxfifo_empty_o    ),
          .mem_aempty          (app_rxfifo_aempty_o   ),
          .mem_rd              (app_rxfifo_rden_i     ), 
          .mem_dout            (app_rxfifo_rddata_o[7:0]),
          .mem_eop             (app_rxfifo_rddata_o[8]),
 
          .cfg_desc_baddr      (cfg_rx_buf_qbase_addr ),
          .desc_req            (app_rx_desc_req       ),
          .desc_ack            (app_rx_desc_ack       ),
          .desc_disccard       (app_rx_desc_discard   ),
          .desc_data           (app_rx_desc_data      ),
    // Slave Interface Signal
          .wbo_din             ( wbgr_din     ), 
          .wbo_taddr           ( wbgr_taddr   ), 
          .wbo_addr            ( wbgr_addr    ), 
          .wbo_be              ( wbgr_be      ), 
          .wbo_we              ( wbgr_we      ), 
          .wbo_ack             ( wbgr_ack     ),
          .wbo_stb             ( wbgr_stb     ), 
          .wbo_cyc             ( wbgr_cyc     ), 
          .wbo_err             ( wbgr_err     ),
          .wbo_rty             ( wbgr_rty     )
         );

//-------------------------------------
// UART core instantiation
//-------------------------------------

uart_core  u_uart_core

     (  
          . line_reset_n                (gen_resetn            ),
          . line_clk_16x                (uart_clk_16x          ),

          . app_reset_n                 (gen_resetn            ),
          . app_clk                     (app_clk               ),


        // Reg Bus Interface Signal
          . reg_cs                      (reg_uart_cs           ),
          . reg_wr                      (reg_uart_wr           ),
          . reg_addr                    (reg_uart_addr[5:2]    ),
          . reg_wdata                   (reg_uart_wdata        ),
          . reg_be                      (reg_uart_be           ),

            // Outputs
          . reg_rdata                   (reg_uart_rdata        ),
          . reg_ack                     (reg_uart_ack          ),



       // Line Interface
          . si                          (si                    ),
          . so                          (so                    )

     );


//--------------------------------
// SPI core instantiation
//--------------------------------


spi_core u_spi_core (

          . clk                         (app_clk               ),
          . reset_n                     (gen_resetn            ),
               
        // Reg Bus Interface Signal
          . reg_cs                      (reg_spi_cs            ),
          . reg_wr                      (reg_spi_wr            ),
          . reg_addr                    (reg_spi_addr[5:2]     ),
          . reg_wdata                   (reg_spi_wdata         ),
          . reg_be                      (reg_spi_be            ),

            // Outputs
          . reg_rdata                   (reg_spi_rdata         ),
          . reg_ack                     (reg_spi_ack           ),


          . sck                         (spi_sck               ),
          . so                          (spi_so                ),
          . si                          (spi_si                ),
          . cs_n                        (spi_cs_n              )

           );



oc8051_top u_8051_core (
          . wb_rst_i                    (risc_reset            ), 
          . wb_clk_i                    (app_clk               ),

//interface to instruction rom
          . wbi_adr_o                   (wbi_risc_adr          ), 
          . wbi_dat_i                   (wbi_risc_rdata        ), 
          . wbi_stb_o                   (wbi_risc_stb          ), 
          . wbi_ack_i                   (wbi_risc_ack          ), 
          . wbi_cyc_o                   (wbi_risc_cyc          ), 
          . wbi_err_i                   (wbi_risc_err          ),

//interface to data ram
          . wbd_dat_i                   (wbd_risc_rdata        ), 
          . wbd_dat_o                   (wbd_risc_wdata        ),
          . wbd_adr_o                   (wbd_risc_adr          ), 
          . wbd_we_o                    (wbd_risc_we           ), 
          . wbd_ack_i                   (wbd_risc_ack          ),
          . wbd_stb_o                   (wbd_risc_stb          ),
          . wbd_cyc_o                   (wbd_risc_cyc          ),
          . wbd_err_i                   (wbd_risc_err          ),

// interrupt interface
          . int0_i                      (                      ), 
          . int1_i                      (                      ),


// port interface
  `ifdef OC8051_PORTS
        `ifdef OC8051_PORT0
          .p0_i                         ( p0                    ),
          .p0_o                         ( p0                    ),
        `endif

        `ifdef OC8051_PORT1
           .p1_i                        ( p1                    ),
           .p1_o                        ( p1                    ),
        `endif

        `ifdef OC8051_PORT2
           .p2_i                        ( p2                    ),
           .p2_o                        ( p2                    ),
        `endif

        `ifdef OC8051_PORT3
           .p3_i                        ( p3                    ),
           .p3_o                        ( p3                    ),
        `endif
  `endif

// serial interface
        `ifdef OC8051_UART
           .rxd_i                       (                      ), 
           .txd_o                       (                      ),
        `endif

// counter interface
        `ifdef OC8051_TC01
           .t0_i                        (                      ), 
           .t1_i                        (                      ),
        `endif

        `ifdef OC8051_TC2
           .t2_i                        (                      ),
           .t2ex_i                      (                      ),
        `endif

// BIST
`ifdef OC8051_BIST
            .scanb_rst                  (                      ),
            .scanb_clk                  (                      ),
            .scanb_si                   (                      ),
            .scanb_so                   (                      ),
            .scanb_en                   (                      ),
`endif
// external access (active low)
            .ea_in                      (ea_in                 )
         );

endmodule
