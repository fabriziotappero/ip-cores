//******************************************************************************************
// Version 0.7
//
// Top wrapper for AVR Core (Verilog version)
// Modified 29.09.2012 
// Written by Ruslan Lepetenok (lepetenokr@yahoo.com)
// Parameter in_hex_file was removed
// sr_ctrl was added
//******************************************************************************************

`include "synth_ctrl_pack.vh"

// For the purpose of debug only
//`define C_DIS_DEFAULT_NETTYPE TRUE

module uc_top_wrp_vlog #(
	                 parameter tech  	       = 4, // !!! `c_tech, 
	                 parameter synth_on	       = `c_synth_on,
	                 parameter pm_size	       = `c_pm_size,
	                 parameter dm_size	       = `c_dm_size,
			 
			 parameter bm_use_ext_tmr      = `c_bm_use_ext_tmr, 
			 parameter dm_mst_num	       = `c_dm_mst_num, 
			 parameter dm_slv_num	       = `c_dm_slv_num,
			 parameter use_rst	       = `c_use_rst,
			 parameter irqs_width	       = `c_irqs_width,
			 parameter pc22b_core	       = `c_pc22b_core, 
			 parameter io_slv_num	       = `c_io_slv_num,
			 parameter sram_chip_num       = `c_sram_chip_num,
			 parameter impl_synth_core     = `c_impl_synth_core,
			 parameter impl_jtag_ocd_prg   = `c_impl_jtag_ocd_prg,
			 parameter impl_usart	       = `c_impl_usart,
			 parameter impl_ext_dbg_sys    = `c_impl_ext_dbg_sys,
			 parameter impl_smb	       = `c_impl_smb,
			 parameter impl_spi	       = `c_impl_spi,
			 parameter impl_wdt	       = `c_impl_wdt,
			 parameter impl_srctrl         = `c_impl_srctrl,
			 parameter impl_hw_bm	       = `c_impl_hw_bm,
			 parameter rst_act_high        = `c_rst_act_high,
			 parameter old_pm	       = `c_old_pm,
			 // Added 31.12.11
			 parameter dm_int_sram_read_ws = `c_dm_int_sram_read_ws,  // DM access(read) wait stait is inserted			
			 parameter impl_mul            = 1 // ???    
			 )
                        
			(
			 input nrst,
			 input clk,
			 
			 input pwr_on_nrst,
			 
			 // PORTA related 
			 output[7:0]                    porta_portx,
	                 output[7:0]                    porta_ddrx,
	                 input[7:0]                     porta_pinx,
			 
			 // Timer related
			 input                          tmr_ext_1,
			 input                          tmr_ext_2,
			 
			 // UART related
			 input                          rxd,
			 output                         txd,  
			  
			 // SPI related
			input	                        misoi,   
			input	                        mosii,   
			input	                        scki,    
			input	                        ss_b,    
					
			output wire                     misoo,	
			output wire                     mosio,	
			output wire                     scko,	
			output wire                     spe,        
			output wire                     spimaster,  
                        output wire                     spi_cs_n, 

                         //I2C related 
			 // TRI control and data for the slave channel
			 input                          sdain,	 
			 output wire                    sdaout,  
			 output wire                    sdaen,  
			 input                          sclin,	 
			 output wire                    sclout,  
			 output wire                    sclen,   
			 // TRI control and data for the master channel
			 input                          msdain,	  
			 output wire                    msdaout,  
			 output wire                    msdaen,   
			 input                          msclin,	  
			 output wire                    msclout,
			 output wire                    msclen,   
			 
			 // Interrupts
			 input[7:0]                     int,
			 
			 // JTAG related
			 input                          tck,
			 input                          tms,
			 input                          tdi,
			 output                         tdo,
			 output wire                    tdo_oe,
			 
			 // Static RAM interface
			 output wire[15:0]              sr_adr,	
			 input[7:0]                     sr_d_in,	
			 output wire[7:0]               sr_d_out,	
			 output wire	                sr_d_oe,	
			 output wire	                sr_we_n,	
			 output wire[sram_chip_num-1:0]	sr_cs_n,	
			 output wire                    sr_oe_n,
		
		         // PM interface
			 output wire[15:0]              pm_adr,
        		 output wire[15:0]              pm_dout,
        		 input[15:0]                    pm_din,		
                         output wire                    pm_we_h,
                         output wire                    pm_we_l,
                         output wire                    pm_ce,    // Optional 
			 
			 // DM interface
			 output wire[15:0]              dm_adr,
        		 output wire[7:0]               dm_dout,
        		 input[7:0]                    dm_din,
			 output wire                    dm_ce,		
                         output wire                    dm_we
			);

//******************************************************************************************

`include "avr_adr_pack.vh"

//==========================================================================================
// USART configuration

 `define C_DBG_USART_USED TRUE

localparam LP_USART_SYNC_RST	     = 0;    
localparam LP_USART_RXB_TXB_ADR	     = 6'h0C; // UDR0_Address
localparam LP_USART_STATUS_ADR	     = 6'h0A; // UCSR0B_Address
localparam LP_USART_CTRLA_ADR	     = 6'h0B; // UCSR0A_Address
localparam LP_USART_CTRLB_ADR	     = ADCSRA_Address; // TBD ???
localparam LP_USART_CTRLC_ADR	     = ADMUX_Address;  // TBD ???
localparam LP_USART_BAUDCTRLA_ADR    = 6'h09; // UBRR0L_Address 
localparam LP_USART_BAUDCTRLB_ADR    = ACSR_Address;   // TBD ???
localparam LP_USART_RXB_TXB_DM_LOC   = 0; 
localparam LP_USART_STATUS_DM_LOC    = 0; 
localparam LP_USART_CTRLA_DM_LOC     = 0; 
localparam LP_USART_CTRLB_DM_LOC     = 0; 
localparam LP_USART_CTRLC_DM_LOC     = 0; 
localparam LP_USART_BAUDCTRLA_DM_LOC = 0;
localparam LP_USART_BAUDCTRLB_DM_LOC = 0;
localparam LP_USART_RX_FIFO_DEPTH    = 2;
localparam LP_USART_TX_FIFO_DEPTH    = 2;
localparam LP_USART_MEGA_COMPAT_MODE = 1;
localparam LP_USART_COMPAT_MODE      = 0;
localparam LP_USART_IMPL_DFT         = 0;

//==========================================================================================

localparam LP_DM_START_ADR = 16'h0060; /*16'h0100  M103/M128*/

localparam LP_USE_INT_CTRL = 1; // TBD

// Wires connected to AVR core (begin)
localparam LP_NUM_OF_ASTA_CHAINS =  11; // TBD

wire core_astacp2 = 1'b0;
wire[1:0] core_astamode = {2{1'b0}};
wire[LP_NUM_OF_ASTA_CHAINS-1:0] core_astase = {LP_NUM_OF_ASTA_CHAINS{1'b0}};
wire[LP_NUM_OF_ASTA_CHAINS-1:0] core_astasi = {LP_NUM_OF_ASTA_CHAINS{1'b0}};
wire[LP_NUM_OF_ASTA_CHAINS-1:0] core_astaso;

wire[2:0] core_corese = {3{1'b0}};
wire[2:0] core_coresi = {3{1'b0}};
wire[2:0] core_coreso;

wire jtag_cp2en; 

wire core_valid_instr;
wire core_insert_nop;
wire core_block_irq;
wire core_change_flow;

wire[15:0] core_pc; 
wire[15:0] core_inst; 
wire[5:0] core_adr; 
wire core_iore; 
wire core_iowe; 
wire[15:0] core_ramadr; 
wire core_ramre; 
wire core_ramwe; 
wire core_cpuwait; 
wire[7:0] core_dbusout; 

wire[irqs_width-1:0] core_irqlines; 
wire      core_irqack; 
wire[4+pc22b_core:0] core_irqackad; 

wire core_sleepi; 
wire core_irqok; 
wire core_globint; 
wire core_wdri; 

wire[15:0] core_spm_out; 
wire core_spm_inst; 
wire core_spm_wait;
// Wires connected to AVR core (end)

wire core_ireset; // ?????



// To master(s)
wire[7:0]			   msts_dbusout; // Data from the selected slave(Common for all masters)
wire[dm_mst_num-1:0]		   msts_rdy;   // analog of !cpuwait
wire[dm_mst_num-1:0]		   msts_busy;  // analog of cpuwait
// To DM slave(s)
//wire[15:0]			   ramadr;  
//wire[7:0]			   ramdout; 
//wire				   ramre;   
//wire				   ramwe;   
// DM address decoder
wire				   avr_interconnect_sel_60_ff;	 
wire				   avr_interconnect_sel_100_1ff;
wire[3:0]			   avr_interconnect_dm_ext_slv_sel;     
// IRQ related
wire[irqs_width-1:0]		   avr_interconnect_ind_irq_ack;    
// Clock and reset
wire				   cp2;
// From master(s) 
wire[dm_mst_num*(16+8+1+1)-1:0]   msts_outs;  //  ramwe + ramre + ramadr[15:0] + ramdout[7:0]

// From DM slave(s) 
wire[dm_slv_num*(8+1+1)-1:0]	   dm_slv_outs;  // out_en + wait + ramdin[7:0]  
// From IO slave(s)
wire[io_slv_num*(8+1)-1:0]	   io_slv_outs; // out_en + dbusout[7:0] 

wire[7:0]                         core_dbusout_rg; 

// To DM slaves
wire[15:0]                        avr_interconnect_ramadr; 
wire[7:0]                         avr_interconnect_ramdout;
wire                              avr_interconnect_ramre;  
wire                              avr_interconnect_ramwe;  


wire[5:0] edbg_adr;    
wire edbg_iore;   
wire edbg_iowe;   
wire[7:0] edbg_io_dbusout;
wire edbg_wait;

wire[5:0] io_arb_mux_adr;    
wire      io_arb_mux_iore;   
wire      io_arb_mux_iowe;   
wire[7:0] io_arb_mux_dbusout;


// JTAG OCD PRG IO slave output
wire[7:0]jtag_io_slv_dbusout; 
wire jtag_io_slv_out_en;

wire jtag_tmr_cp2en;
wire jtag_stopped_mode;
wire jtag_tmr_running;
wire jtag_wdr_en;
wire jtag_ctrlx;

wire sleep_mode;  // Name TBD


wire[15:0]   jtag_pm_adr;  
wire	     jtag_pm_h_we;
wire	     jtag_pm_l_we;
wire  [15:0] jtag_pm_dout; // PM data output (from PM) 
wire[15:0]   jtag_pm_din;  // PM data input  (to PM) 

wire	    jtag_ee_prg_sel;
wire[11:0]  jtag_ee_adr;    
wire[7:0]   jtag_ee_wr_data;
wire[7:0]   jtag_ee_rd_data;
wire	    jtag_ee_wr;

wire[3:0]  jtag_tap_sm_st; // ???? Size (One hot encoding???)
wire[3:0]  jtag_ir;	     
wire	   jtag_tdo_ext;
wire	   jtag_tlr_st;


wire       jtag_rst;			

// WDT

// WDT IO slave output
wire[7:0]wdt_io_slv_dbusout; 
wire wdt_io_slv_out_en;

wire wdt_wdovf;

// Timer/Counter IO slave output
wire[7:0]tmr_io_slv_dbusout; 
wire     tmr_io_slv_out_en;

// PORTA slave output
wire[7:0] pport_a_io_slv_dbusout; 
wire      pport_a_io_slv_out_en;

// Demo CRC DMA slave
wire[7:0] demo_crc_dma_dm_slv_dbusout;
wire      demo_crc_dma_dm_slv_out_en;
wire      demo_crc_dma_dm_slv_wait;

// Demo CRC DMA slave master
wire[15:0]demo_crc_m_ramadr;    
wire      demo_crc_m_ramre;   	    
wire      demo_crc_m_ramwe;   						      
wire[7:0] demo_crc_m_dbus_out; 

// SPI slave output
wire[7:0] spi_io_slv_dbusout; 
wire      spi_io_slv_out_en;

localparam c_spi_slvs_num = 8;
wire[7:0] spi_slv_sel_n;

// UART
wire[7:0] uart_io_slv_dbusout; 
wire      uart_io_slv_out_en;

// SMBus
wire[7:0]smb_io_slv_dbusout; 
wire     smb_io_slv_out_en;

// ID module
wire[7:0]id_mod_io_slv_dbusout; 
wire id_mod_io_slv_out_en;

// SPM module
wire[7:0]spm_mod_io_slv_dbusout; 
wire spm_mod_io_slv_out_en;

// SPM
wire spm_mod_rwwsre_op; 
wire spm_mod_blbset_op;
wire spm_mod_pgwrt_op ;
wire spm_mod_pgers_op ;
wire spm_mod_spmen_op ;

wire spm_mod_rwwsre_rdy; 
wire spm_mod_blbset_rdy;
wire spm_mod_pgwrt_rdy ;
wire spm_mod_pgers_rdy ;
wire spm_mod_spmen_rdy ;

// External SRAM controller
wire[7:0]sr_ctrl_dm_slv_dbusout;
wire sr_ctrl_dm_slv_out_en;
wire sr_ctrl_dm_slv_wait;

// Interrupt controller
wire[7:0] ext_int_mod_io_dbus_out;
wire[7:0] ext_int_mod_dm_dbus_out;
wire ext_int_mod_io_out_en;	
wire ext_int_mod_dm_out_en;
wire ext_int_mod_wait;	


wire vcc = 1'b1;
wire gnd = 1'b0; 

// For the purpose of debug only
assign edbg_adr = {6{1'b0}};
assign edbg_io_dbusout = {8{1'b0}};


//******************************************************************************************

assign cp2 = clk;

avr_interconnect #(
                          .num_of_msts         (dm_mst_num), 
                          .io_slv_num          (io_slv_num), 
			  .mem_slv_num         (dm_slv_num), 
			  .irqs_width          (irqs_width), 
			  .pc22b               (0         ),
			  // Added
			  .dm_int_sram_read_ws (dm_int_sram_read_ws),
			  .dm_start_adr        (LP_DM_START_ADR /*16'h0100*/),
			  .dm_size             (dm_size * 1024),	 // Size of DM SRAM in Bytes
			  // 
			  .dm_ext_slv_adr0     (16'hE000),   
                          .dm_ext_slv_len0     (1*1024  ), 
			  .dm_ext_slv_adr1     (16'hD000),   
                          .dm_ext_slv_len1     (1*1024  ), 
			  .dm_ext_slv_adr2     (16'hE000),   
                          .dm_ext_slv_len2     (1*1024  ), 
			  .dm_ext_slv_adr3     (16'hF000),   
                          .dm_ext_slv_len3     (1*1024  ) 
			  )
avr_interconnect_inst(
	 // To master(s)
	 .msts_dbusout   (msts_dbusout), // Data from the selected slave(Common for all masters)
         .msts_rdy       (msts_rdy    ),   // analog of !cpuwait
         .msts_busy      (msts_busy   ),   // analog of cpuwait
	 // To DM slave(s)
	 .ramadr         (avr_interconnect_ramadr ),  
	 .ramdout        (avr_interconnect_ramdout), 
         .ramre          (avr_interconnect_ramre  ),   
         .ramwe          (avr_interconnect_ramwe  ),   
         // DM address decoder
	 .sel_60_ff      (avr_interconnect_sel_60_ff     ),    
	 .sel_100_1ff    (avr_interconnect_sel_100_1ff   ),
	 .dm_ext_slv_sel (avr_interconnect_dm_ext_slv_sel),     
	 // IRQ related
	 .ind_irq_ack    (avr_interconnect_ind_irq_ack),    
         // Clock and reset
         .ireset         (core_ireset),  
         .cp2            (cp2),
         // From master(s) 
	 .msts_outs      (msts_outs/*!!! Check the width !!!*/), //  ramwe + ramre + ramadr[15:0] + ramdout[7:0]
         // From DM slave(s) 
	 .dm_slv_outs    (dm_slv_outs), // out_en + wait + ramdin[7:0]  
	 .dm_dout        (dm_din[7:0]), // From DM
	 // From IO slave(s)
	 .io_slv_outs    (io_slv_outs/*!!! Check the width !!!*/), // out_en + dbusout[7:0] 
	 // IRQ related
         .irqack         (core_irqack),	 
         .irqackad       (core_irqackad)	
	);


// AVR core (with DFT structures)

localparam eind_width  = 1;
localparam rampz_width = 8;

avr_core_dft_wrapper  #(
                       .impl_mul    (impl_mul   ),  
                       .use_rst     (use_rst	), 
                       .pc22b       (pc22b_core	),
                       .eind_width  (eind_width ),
                       .rampz_width (rampz_width),
                       .irqs_width  (irqs_width )
                       ) 
avr_core_dft_wrapper_inst(
                .astacp2     (core_astacp2 ),
		.astamode    (core_astamode),
		.astase      (core_astase  ),
		.astasi      (core_astasi  ),
		.astaso      (core_astaso  ),
		
		.corese      (core_corese),
		.coresi      (core_coresi),
		.coreso      (core_coreso),

                .cp2         (cp2), 
                .cp2en       (jtag_cp2en), 
		.ireset      (core_ireset), 
		
		.valid_instr (core_valid_instr), 
		.insert_nop  (core_insert_nop ), 
		.block_irq   (core_block_irq  ), 
		.change_flow (core_change_flow), 
		
		.pc          (core_pc      ), 
		.inst        (core_inst    ), 
		.adr         (core_adr     ), 
		.iore        (core_iore    ), 
		.iowe        (core_iowe    ), 
		.ramadr      (core_ramadr  ), 
		.ramre       (core_ramre   ), 
		.ramwe       (core_ramwe   ), 
		.cpuwait     (core_cpuwait ), 
		.dbusin      (msts_dbusout ), 
		.dbusout     (core_dbusout ), 
		.irqlines    (core_irqlines), 
		.irqack      (core_irqack  ), 
		.irqackad    (core_irqackad), 
		.sleepi      (core_sleepi  ), 
		.irqok       (core_irqok   ), 
		.globint     (core_globint ), 
		.wdri        (core_wdri    ), 
		
		.spm_out     (core_spm_out ), 
		.spm_inst    (core_spm_inst), 
		.spm_wait    (core_spm_wait)
		);




ram_data_rg ram_data_rg_inst(	
	                   // Clock and Reset 
                           .ireset   (core_ireset),
                           .cp2      (cp2   ),
		           // Data and Control
                           .cpuwait   (core_cpuwait),
			   .data_in   (core_dbusout),
			   .data_out  (core_dbusout_rg)
	                   );				

assign msts_outs = {
                   demo_crc_m_ramwe,demo_crc_m_ramre,demo_crc_m_ramadr[15:0],demo_crc_m_dbus_out[7:0], // demo crc DMA (Master 1)
                   core_ramwe,core_ramre,core_ramadr[15:0],core_dbusout_rg[7:0]                        // avr_core     (Master 0)
                   };  


assign core_cpuwait = msts_busy[0]; // cpuwait for Master 0

assign edbg_iore = 1'b0;
assign edbg_iowe = 1'b0;

io_arb_mux io_arb_mux_inst(
  			  // AVR Core
  			  .c_adr     (core_adr),
  			  .c_iore    (core_iore),
  			  .c_iowe    (core_iowe),
  			  .c_ramre   (core_ramre),
			  .c_ramwe   (core_ramwe),
  			  .c_dbusout (core_dbusout),
  			  // Debugger
  			  .d_adr     (edbg_adr),    
  			  .d_iore    (edbg_iore),   
  			  .d_iowe    (edbg_iowe),   
  			  .d_dbusout (edbg_io_dbusout),
  			  .d_wait    (edbg_wait),
  			  // I/O i/f
  			  .adr       (io_arb_mux_adr	),  //	<< NAMES
  			  .iore      (io_arb_mux_iore	),
  			  .iowe      (io_arb_mux_iowe	),
  			  .dbusout   (io_arb_mux_dbusout)
  			  );


// JTAG
 generate
 if(impl_jtag_ocd_prg) begin : jtag_ocd_is_implemented

        jtag_ocd_prg_top_vlog #(
	                           .P_DEMO_VERSION    (0),
	                           .P_IMPL_PROGRAMMER (1) // By default "Flash/EEPROM" programmer is always implemented
	                           )
	    jtag_ocd_prg_top_vlog_inst(
	                      // AVR Control
                                                  .ireset       (core_ireset),
                                                  .cp2	        (cp2),
                                                  .adr          (io_arb_mux_adr/* Note 1*/),
						  .ramadr       (core_ramadr),
						  .ramre        (core_ramre),
						  .ramwe        (core_ramwe),
						  .dbus_in      (io_arb_mux_dbusout/* Note 1*/),
                                                  .dbus_out     (jtag_io_slv_dbusout),     // To the interconnect (IO port out)
                                                  .iore         (io_arb_mux_iore/* Note 1*/),
                                                  .iowe         (io_arb_mux_iowe/* Note 1*/),
                                                  .out_en       (jtag_io_slv_out_en), 
					      // Core control signals[!!!TBD!!!]
						  .cp2en        (jtag_cp2en),
						  .valid_instr  (core_valid_instr),
						  .insert_nop   (core_insert_nop ),
						  .block_irq    (core_block_irq  ),
						  .change_flow  (core_change_flow),
						  .tmr_cp2en    (jtag_tmr_cp2en   ),
						  .stopped_mode (jtag_stopped_mode), // ??
						  .tmr_running  (jtag_tmr_running ), // ??
						  .wdr_en       (jtag_wdr_en      ),
						  .sleep_mode   (sleep_mode       ), // Name
						  .ctrlx        (jtag_ctrlx       ),
						  // JTAG related inputs/outputs
						  .TRSTn        (pwr_on_nrst)	, // Optional
	                                          .TMS	        (tms),
                                                  .TCK	        (tck),
                                                  .TDI	        (tdi),
                                                  .TDO	        (tdo),
						  .TDO_OE       (tdo_oe),
						  // INTERNAL SCAN CHAIN
						  .PC           (core_pc) ,
						  .Inst         (core_inst),
						  // To the PM["Flash"]
						  .pm_adr	(jtag_pm_adr ),   
						  .pm_h_we	(jtag_pm_h_we),
						  .pm_l_we	(jtag_pm_l_we),
						  .pm_dout	(jtag_pm_dout),  
						  .pm_din	(jtag_pm_din ),
						  // To the "EEPROM" 
						  .EEPrgSel     (jtag_ee_prg_sel),
						  .EEAdr        (jtag_ee_adr    ),    
						  .EEWrData     (jtag_ee_wr_data),
						  .EERdData     (jtag_ee_rd_data),
						  .EEWr         (jtag_ee_wr     ),
						  // CPU reset
						  .jtag_rst     (jtag_rst),
						  // Additional chains i/f
					          .TAP_SM_St   (jtag_tap_sm_st),
					          .IR          (jtag_ir       ), // !TBD!
					          .TDO_Ext     (jtag_tdo_ext  ),
					          .TLR_St      (jtag_tlr_st   ),
						  // Power on reset input
						  .pwr_on_rstn (pwr_on_nrst)    
                                                   );



 end // jtag_ocd_is_implemented  
 else begin : jtag_ocd_is_not_implemented
 
 // If jtag_ocd_prg_top_vlog is not used
 
  assign jtag_cp2en	  = 1'b1;
  assign core_insert_nop  = 1'b0;
  assign core_block_irq   = 1'b0;
  assign jtag_tmr_cp2en   = 1'b1;
  assign jtag_tmr_running = 1'b0;
  assign jtag_wdr_en	  = 1'b1; // WDT is on 

 assign jtag_rst	  = 1'b0; // JTAG reset is inactive

 assign core_inst         = pm_din[15:0];
 assign pm_adr[15:0]      = core_pc[15:0];

 // I/O slave
 assign jtag_io_slv_out_en = 1'b0;
 assign jtag_io_slv_dbusout = {8{1'b0}};

 // Write to PM is disabled
 assign jtag_pm_h_we = 1'b0;
 assign jtag_pm_l_we = 1'b0;

 // TDO related
 assign tdo	= 1'b0;
 assign tdo_oe  = 1'b0;

// ???TBD???
//assign jtag_pm_din[15:0]    = {16{1'b0}};  // PM data input  (to PM) 
assign jtag_ee_prg_sel      = 1'b0;
assign jtag_ee_adr[11:0]    = {12{1'b0}};    
assign jtag_ee_wr_data[7:0] = {8{1'b0}};
assign jtag_ee_rd_data[7:0] = {8{1'b0}};
assign jtag_ee_wr	    = 1'b0;
assign jtag_tap_sm_st[3:0]  = {4{1'b0}}; // ???? Size (One hot encoding???)
assign jtag_ir[3:0]	    = {4{1'b0}};	    
assign jtag_tdo_ext	    = 1'b0;
assign jtag_tlr_st	    = 1'b0;
//assign jtag_pm_adr[15:0]    = {16{1'b0}}; 

 end // jtag_ocd_is_not_implemented
 endgenerate


// PM interface
assign pm_adr[15:0]  = jtag_pm_adr[15:0]; 
assign jtag_pm_dout[15:0] = pm_din[15:0];

// PM data output
assign pm_dout[15:0] = jtag_pm_din[15:0];

assign pm_we_h = jtag_pm_h_we;
assign pm_we_l = jtag_pm_l_we;
assign pm_ce   = vcc;

// DM interface
assign dm_ce        = vcc;  // avr_interconnect_ramre
assign dm_adr[15:0] = avr_interconnect_ramadr[15:0];  
assign dm_dout[7:0] = avr_interconnect_ramdout[7:0];
assign dm_we        = avr_interconnect_ramwe;


generate 
if(impl_wdt) begin : wdt_is_implemented
wdt_mod wdt_mod_inst(
	                 // Clock and Reset
                     .ireset         (core_ireset),
                     .cp2	     (cp2),   
		      // AVR Control
                     .adr            (io_arb_mux_adr),  	   
                     .dbus_in        (io_arb_mux_dbusout),	   
                     .dbus_out       (wdt_io_slv_dbusout),
                     .iore           (io_arb_mux_iore), 	   
                     .iowe           (io_arb_mux_iowe), 	   
                     .out_en         (wdt_io_slv_out_en), 
		      // Watchdog timer 
		     .runmod         (jtag_wdr_en),
                     .wdt_irqack     (gnd),
                     .wdri	     (core_wdri),
                     .wdt_irq	     ( ),
                     .wdtmout	     (wdt_wdovf),
                     .wdtcnt 	     ( )
                     );
end // wdt_is_implemented
else begin : wdt_is_not_implemented
 assign wdt_wdovf          = gnd;
 assign wdt_io_slv_dbusout = {8{1'b0}};
 assign wdt_io_slv_out_en  = gnd;
end // wdt_is_not_implemented

endgenerate

rst_gen #(.rst_high(rst_act_high)) 
	             rst_gen_inst(
	                        // Clock inputs
				.cp2	    (cp2),
				// Reset inputs
	                        .nrst       (nrst),
				.npwrrst    (pwr_on_nrst),  // !!!! From the POWER-ON reset generator
				.wdovf      (wdt_wdovf),
			        .jtagrst    (jtag_rst),
      				// Reset outputs
				.nrst_cp2   (core_ireset),
				.nrst_clksw ()
				);	

// Timer counter 
Timer_Counter Timer_Counter_inst(
   // AVR Control
   .ireset         (core_ireset),
   .cp2            (cp2   ),
   .cp2en          (jtag_cp2en),
   .tmr_cp2en      (jtag_tmr_cp2en    ),
   .stopped_mode   (jtag_stopped_mode ),	      // ??
   .tmr_running    (jtag_tmr_running  ),	      // ??
   .adr            (io_arb_mux_adr    ),
   .dbus_in        (io_arb_mux_dbusout),
   .dbus_out       (tmr_io_slv_dbusout),
   .iore           (io_arb_mux_iore),
   .iowe           (io_arb_mux_iowe),
   .out_en         (tmr_io_slv_out_en),
   // External inputs/outputs
   .EXT1           (tmr_ext_1),
   .EXT2           (tmr_ext_2),
   .OC0_PWM0       (/*Not used*/),
   .OC1A_PWM1A     (/*Not used*/),
   .OC1B_PWM1B     (/*Not used*/),
   .OC2_PWM2       (/*Not used*/),
   // Interrupt related signals
   .TC0OvfIRQ      (core_irqlines[15]),
   .TC0OvfIRQ_Ack  (avr_interconnect_ind_irq_ack[15]),
   .TC0CmpIRQ      (core_irqlines[14]),
   .TC0CmpIRQ_Ack  (avr_interconnect_ind_irq_ack[14]),
   .TC2OvfIRQ      (core_irqlines[9] ),
   .TC2OvfIRQ_Ack  (avr_interconnect_ind_irq_ack[9] ),
   .TC2CmpIRQ      (core_irqlines[8] ),
   .TC2CmpIRQ_Ack  (avr_interconnect_ind_irq_ack[8] ),
   .TC1OvfIRQ      (core_irqlines[13]),
   .TC1OvfIRQ_Ack  (avr_interconnect_ind_irq_ack[13]),
   .TC1CmpAIRQ     (core_irqlines[11]),
   .TC1CmpAIRQ_Ack (avr_interconnect_ind_irq_ack[11]),
   .TC1CmpBIRQ     (core_irqlines[12]),
   .TC1CmpBIRQ_Ack (avr_interconnect_ind_irq_ack[12]),
   .TC1ICIRQ       (core_irqlines[10]),
   .TC1ICIRQ_Ack   (avr_interconnect_ind_irq_ack[10])
);


//################################################ PORTA #################################################

         pport#(
	       .portx_adr    (PORTA_Address),
	       .ddrx_adr     (DDRA_Address),
	       .pinx_adr     (PINA_Address),
	       .portx_dm_loc (0), 
	       .ddrx_dm_loc  (0),
	       .pinx_dm_loc  (0),					       
	       .port_width   (8),
	       .port_rs_type (0 /*c_pport_rs_md_fre*/),
	       .port_mode    (0 /*c_pport_mode_bidir*/)					       
	       ) 
   pport_a_inst(
	           // Clock and Reset
               .ireset      (core_ireset),
               .cp2	    (cp2),
	        // I/O 
               .adr	    (io_arb_mux_adr), 	    
               .dbus_in     (io_arb_mux_dbusout),	    
               .dbus_out    (pport_a_io_slv_dbusout),
               .iore	    (io_arb_mux_iore),	    
               .iowe	    (io_arb_mux_iowe),	    
               .io_out_en   (pport_a_io_slv_out_en), 
	        // DM
	       .ramadr      ({8{1'b0}} ),
	       .dm_dbus_in  ({8{1'b0}}),
               .dm_dbus_out (/*Not used*/),
               .ramre	    (gnd),
               .ramwe	    (gnd),
	       .dm_sel      (gnd),
	       .cpuwait     (/*Not used*/),
	       .dm_out_en   (/*Not used*/),
		// External connection
	       .portx	    (porta_portx),
	       .ddrx	    (porta_ddrx),
	       .pinx	    (porta_pinx),
		//
	       .resync_out  (/*Not used*/)
	        );


// I/O slaves outputs
assign io_slv_outs =  {
                      jtag_io_slv_out_en,jtag_io_slv_dbusout[7:0],
                      wdt_io_slv_out_en,wdt_io_slv_dbusout[7:0], 
                      tmr_io_slv_out_en,tmr_io_slv_dbusout[7:0],
		      pport_a_io_slv_out_en,pport_a_io_slv_dbusout[7:0],
		      spi_io_slv_out_en,spi_io_slv_dbusout[7:0],
		      uart_io_slv_out_en,uart_io_slv_dbusout[7:0],
		      smb_io_slv_out_en,smb_io_slv_dbusout[7:0],
		      spm_mod_io_slv_out_en,spm_mod_io_slv_dbusout[7:0],
		      id_mod_io_slv_out_en,id_mod_io_slv_dbusout[7:0],		      		      
                      ext_int_mod_io_out_en,ext_int_mod_io_dbus_out[7:0]
		      };



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

demo_crc_dma demo_crc_dma_inst(
         //    Clock and reset
         .ireset      (core_ireset),        
         .cp2         (cp2),           
         // DM i/f (Slave part)
         .s_sel       (avr_interconnect_dm_ext_slv_sel[0]),
         .s_ramadr    (avr_interconnect_ramadr[3:0]),  // !!! [3:0]
         .s_ramre     (avr_interconnect_ramre),        
         .s_ramwe     (avr_interconnect_ramwe),        
         .s_dbus_out  (demo_crc_dma_dm_slv_dbusout), 
         .s_dbus_in   (avr_interconnect_ramdout),
         .s_out_en    (demo_crc_dma_dm_slv_out_en),
	 .s_wait      (demo_crc_dma_dm_slv_wait),
         // DM i/f (Master part)                                          
         .m_ramadr    (demo_crc_m_ramadr),  
         .m_ramre     (demo_crc_m_ramre),        
         .m_ramwe     (demo_crc_m_ramwe),                                                  
         .m_dbus_in   (msts_dbusout),              // Common for all masters 
         .m_dbus_out  (demo_crc_m_dbus_out), 
         .m_ack       (msts_rdy[1]),              // Master 1          
         // Interrupts                                  
         .dma_irq     (core_irqlines[1]),     
         .dma_irqack  (avr_interconnect_ind_irq_ack[1])
         );


// DM located slaves
assign dm_slv_outs = {
                      demo_crc_dma_dm_slv_out_en,demo_crc_dma_dm_slv_wait,demo_crc_dma_dm_slv_dbusout[7:0],
                      sr_ctrl_dm_slv_out_en,sr_ctrl_dm_slv_wait,sr_ctrl_dm_slv_dbusout[7:0],
		      ext_int_mod_dm_out_en,ext_int_mod_wait,ext_int_mod_dm_dbus_out[7:0]
		      };


// SPI module
generate
if(impl_spi) begin : spi_is_implemented	

spi_mod spi_mod_inst(
	                // AVR Control
                    .ireset     (core_ireset),
                    .cp2	(cp2),
                    .adr        (io_arb_mux_adr),    
                    .dbus_in    (io_arb_mux_dbusout),
                    .dbus_out   (spi_io_slv_dbusout), 
                    .iore       (io_arb_mux_iore),   
                    .iowe       (io_arb_mux_iowe),   
                    .out_en     (spi_io_slv_out_en),        
                    // SPI i/f
		    .misoi       (misoi), 
		    .mosii       (mosii), 
		    .scki        (scki), 
		    .ss_b        (ss_b), 
		    .misoo       (misoo), 
		    .mosio       (mosio), 
		    .scko        (scko), 
		    .spe         (spe), 
		    .spimaster   (spimaster), 
		    // IRQ
		    .spiirq      (core_irqlines[16]),
		    .spiack      (avr_interconnect_ind_irq_ack[16]),  
		    // Slave Programming Mode
		    .por	 (gnd),
		    .spiextload  (gnd),
		    .spidwrite   (/*Not used*/),
		    .spiload     (/*Not used*/)
                    );					


// SPI slave select module
spi_slv_sel #(.num_of_slvs (c_spi_slvs_num))
	spi_slv_sel_inst(
	                // AVR Control
                    .ireset     (core_ireset),      
                    .cp2	(cp2),         
                    .adr        (io_arb_mux_adr),    
                    .dbus_in    (io_arb_mux_dbusout),
                    .dbus_out   (/*Not used*/),
                    .iore       (io_arb_mux_iore),
                    .iowe       (io_arb_mux_iowe),
                    .out_en     (/*Not used*/),
		     // Output
                    .slv_sel_n  (spi_slv_sel_n)
                    );			

end // spi_is_implemented
else begin : spi_is_not_implemented

assign spi_io_slv_dbusout = {8{1'b0}};
assign spi_io_slv_out_en  = gnd;
assign spi_slv_sel_n      = {c_spi_slvs_num{1'b1}};

end // spi_is_not_implemented

endgenerate

assign spi_cs_n = spi_slv_sel_n[0];


// UART/USART

// TBD hardware flow control support
wire rtsn;
wire ctsn; 
// assign ctsn = rtsn; // Support for loopback tests

generate

if(!impl_usart) begin : uart_is_implemented

`ifdef C_DBG_USART_USED
// USART 
      usart #(
             .SYNC_RST	       (LP_USART_SYNC_RST	 ),   
             .RXB_TXB_ADR      (LP_USART_RXB_TXB_ADR	 ),  
             .STATUS_ADR       (LP_USART_STATUS_ADR	 ),  
             .CTRLA_ADR        (LP_USART_CTRLA_ADR	 ),  
             .CTRLB_ADR        (LP_USART_CTRLB_ADR	 ),  
             .CTRLC_ADR        (LP_USART_CTRLC_ADR	 ),  
             .BAUDCTRLA_ADR    (LP_USART_BAUDCTRLA_ADR   ),  
             .BAUDCTRLB_ADR    (LP_USART_BAUDCTRLB_ADR   ),  
             .RXB_TXB_DM_LOC   (LP_USART_RXB_TXB_DM_LOC  ),
             .STATUS_DM_LOC    (LP_USART_STATUS_DM_LOC   ),  
             .CTRLA_DM_LOC     (LP_USART_CTRLA_DM_LOC	 ),  
             .CTRLB_DM_LOC     (LP_USART_CTRLB_DM_LOC	 ),  
             .CTRLC_DM_LOC     (LP_USART_CTRLC_DM_LOC	 ),
             .BAUDCTRLA_DM_LOC (LP_USART_BAUDCTRLA_DM_LOC),
             .BAUDCTRLB_DM_LOC (LP_USART_BAUDCTRLB_DM_LOC),
	     .RX_FIFO_DEPTH    (LP_USART_RX_FIFO_DEPTH   ),
             .TX_FIFO_DEPTH    (LP_USART_TX_FIFO_DEPTH   ),
	     .MEGA_COMPAT_MODE (LP_USART_MEGA_COMPAT_MODE),
	     .COMPAT_MODE      (LP_USART_COMPAT_MODE	 ),
             .IMPL_DFT         (LP_USART_IMPL_DFT        )	     
	     )
   usart_inst(
             // Clock and Reset
             .ireset      (core_ireset                     ), 
             .cp2         (cp2	                           ), 
             .adr         (io_arb_mux_adr                  ), 
             .dbus_in     (io_arb_mux_dbusout              ), 
             .dbus_out    (uart_io_slv_dbusout             ), 
             .iore        (io_arb_mux_iore	           ), 
             .iowe        (io_arb_mux_iowe	           ), 
             .io_out_en   (uart_io_slv_out_en              ), 
             .ramadr 	  ({3{1'b0}}                       ), 
             .dm_dbus_in  ({8{1'b0}}                       ),
             .dm_dbus_out (                                ),
             .ramre	  (1'b0			           ),
             .ramwe	  (1'b0			           ),
             .dm_sel	  (1'b0                            ),
             .cpuwait	  (                                ),
             .dm_out_en   (                                ),
             .rxcintlvl   (                                ),
             .txcintlvl   (                                ),
             .dreintlvl   (                                ),
             .rxd	  (rxd  			   ),
             .rx_en	  (/*Not used*/ 		   ),
             .txd	  (txd  			   ), 
             .tx_en	  (/*Not used*/ 		   ), 
             .txcirq	  (core_irqlines[19]               ), 
             .txc_irqack  (avr_interconnect_ind_irq_ack[19]),
             .udreirq	  (core_irqlines[18]               ),
             .rxcirq	  (core_irqlines[17]               ),
	     .rtsn        (rtsn                            ),
	     .ctsn        (ctsn                            ),
	      // Test related
	     .test_se     (1'b0                            ),
	     .test_si1    (1'b0                            ),
	     .test_si2    (1'b0                            ),
	     
	     .test_so1    (                                ),
	     .test_so2	  (                                )  	       
	         );

`else	
				
uart uart_inst(
	             // AVR Control
                    .ireset     (core_ireset),
                    .cp2	(cp2),   
                    .adr        (io_arb_mux_adr),             
                    .dbus_in    (io_arb_mux_dbusout),         
                    .dbus_out   (uart_io_slv_dbusout),
                    .iore       (io_arb_mux_iore),	      
                    .iowe       (io_arb_mux_iowe),	      
                    .out_en     (uart_io_slv_out_en), 
                    // External connection
                    .rxd        (rxd),  
                    .rx_en      (/*Not used*/), 
                    .txd        (txd),  
                    .tx_en      (/*Not used*/), 
                    // IRQ
                    .txcirq     (core_irqlines[19]),
                    .txc_irqack (avr_interconnect_ind_irq_ack[19]),  
                    .udreirq    (core_irqlines[18]),
	            .rxcirq     (core_irqlines[17]) 
		);
`endif
		
end // uart_is_implemented		
else begin : uart_is_not_implemented		

assign uart_io_slv_dbusout = {8{1'b0}};
assign uart_io_slv_out_en  = 1'b0;

assign core_irqlines[17] = 1'b0;
assign core_irqlines[18] = 1'b0;
assign core_irqlines[19] = 1'b0;


end // uart_is_not_implemented
					
endgenerate				




generate
if(impl_smb) begin : smb_is_implemented	
            smb_mod #(.impl_pec (1))
	    smb_mod_inst(
	                 // AVR Control
                        .ireset       (core_ireset),
                        .cp2	      (cp2),   
                        .adr          (io_arb_mux_adr),             
                        .dbus_in      (io_arb_mux_dbusout),         
                        .dbus_out     (smb_io_slv_dbusout),
                        .iore         (io_arb_mux_iore),	    
                        .iowe         (io_arb_mux_iowe),	    
                        .out_en       (smb_io_slv_out_en), 
                        // Slave IRQ
                        .twiirq       (core_irqlines[21]),
                        // Master IRQ
			.msmbirq      (core_irqlines[20]),
			 // "Off state" timer IRQ
                        .offstirq     (core_irqlines[22]),
                        .offstirq_ack (avr_interconnect_ind_irq_ack[22]),   
			 // TRI control and data for the slave channel
			.sdain        (sdain  ), // in  std_logic;
			.sdaout       (sdaout ),// out std_logic;
			.sdaen        (sdaen  ), // out std_logic;
			.sclin        (sclin  ), // in  std_logic;
			.sclout       (sclout ),// out std_logic;
			.sclen        (sclen  ), // out std_logic;
		        // TRI control and data for the master channel
			.msdain       (msdain ), // in  std_logic;
			.msdaout      (msdaout),// out std_logic;
			.msdaen       (msdaen ), // out std_logic;
			.msclin       (msclin ), // in  std_logic;
			.msclout      (msclout),// out std_logic;
			.msclen       (msclen )  // out std_logic
			);

end // smb_is_implemented
else begin : smb_is_not_implemented

assign smb_io_slv_dbusout = {8{1'b0}};
assign smb_io_slv_out_en  = 1'b0;

// Slave related
assign sdaout = 1'b0;
assign sdaen  = 1'b0;
assign sclout = 1'b0;
assign sclen  = 1'b0;
 
// Master related 
assign msdaout = 1'b0;
assign msdaen  = 1'b0;
assign msclout = 1'b0;
assign msclen  = 1'b0;
 
assign core_irqlines[22:20] = {3{1'b0}}; // !!! Width
 
end // smb_is_not_implemented

endgenerate

          id_mod id_mod_inst(
	                   // AVR Control
                          .ireset   (core_ireset),
                          .cp2	    (cp2),   
                          .adr      (io_arb_mux_adr),             
                          .dbus_in  (io_arb_mux_dbusout),         
                          .dbus_out (id_mod_io_slv_dbusout),
                          .iore     (io_arb_mux_iore),  	  
                          .iowe     (io_arb_mux_iowe),  	  
                          .out_en   (id_mod_io_slv_out_en) 
                          );


// TBD
localparam SPMCSR_IO_Address = PORTD_Address;

   spm_mod #(
	     .use_dm_loc (0),
	     .csr_adr	 (SPMCSR_IO_Address) 
	    )
       spm_mod_inst(
	                // AVR Control
                    .ireset      (core_ireset),
                    .cp2	 (cp2), 
	             // I/O 
                    .adr         (io_arb_mux_adr),             
                    .dbus_in     (io_arb_mux_dbusout),         
                    .dbus_out    (spm_mod_io_slv_dbusout),
                    .iore        (io_arb_mux_iore),	       
                    .iowe        (io_arb_mux_iowe),	       
                    .io_out_en   (spm_mod_io_slv_out_en),  
		     // DM
		    .ramadr      ({8{1'b0}}),
		    .dm_dbus_in  ({8{1'b0}}),
                    .dm_dbus_out (/*Not used*/),
                    .ramre       (gnd),
                    .ramwe       (gnd),
		    .dm_sel      (gnd),
		    .cpuwait     (/*Not used*/),
		    .dm_out_en   (/*Not used*/),
		    //
		   .spm_out      (core_spm_out), 
		   .spm_inst     (core_spm_inst),
		   .spm_wait     (core_spm_wait),
		    // IRQ
		   .spm_irq      (core_irqlines[7]),
		   .spm_irq_ack  (avr_interconnect_ind_irq_ack[7]),  
		    //
		   .rwwsre_op    (spm_mod_rwwsre_op), 
		   .blbset_op    (spm_mod_blbset_op),
		   .pgwrt_op     (spm_mod_pgwrt_op), 
		   .pgers_op     (spm_mod_pgers_op), 
		   .spmen_op     (spm_mod_spmen_op), 
		    //
		   .rwwsre_rdy   (spm_mod_rwwsre_rdy),  
                   .blbset_rdy   (spm_mod_blbset_rdy),
                   .pgwrt_rdy    (spm_mod_pgwrt_rdy), 
                   .pgers_rdy    (spm_mod_pgers_rdy), 
                   .spmen_rdy    (spm_mod_spmen_rdy)  
		   );

// ?? Width ??
wire[sram_chip_num-1:0]   sr_ctrl_sel; 
wire[sram_chip_num*4-1:0] sr_ctrl_ws_in;

assign sr_ctrl_ws_in = {(sram_chip_num*4){1'b0}};          // For the purpose of debug only
assign sr_ctrl_sel   = avr_interconnect_dm_ext_slv_sel[1]; // For the purpose of debug only 

generate
if(impl_srctrl) begin : sr_ctrl_is_implemented							 

sr_ctrl #(.chip_num (sram_chip_num))
	 sr_ctrl_inst(
	                 // AVR Control
                        .ireset     (core_ireset),
                        .cp2	    (cp2),
                        .ramadr     (avr_interconnect_ramadr),
                        .dbus_in    (avr_interconnect_ramdout),
                        .dbus_out   (sr_ctrl_dm_slv_dbusout),
                        .ramre      (avr_interconnect_ramre),
                        .ramwe      (avr_interconnect_ramwe),
			.cpuwait    (sr_ctrl_dm_slv_wait),
			.out_en     (sr_ctrl_dm_slv_out_en),
			// Address decoder
			.ram_sel    (sr_ctrl_sel),
			// Configuration
			.ws_in      (sr_ctrl_ws_in),
			// Static RAM interface
			.sr_adr     (sr_adr  ),
			.sr_d_in    (sr_d_in ),
			.sr_d_out   (sr_d_out),
			.sr_d_oe    (sr_d_oe ),
			.sr_we_n    (sr_we_n ),
			.sr_cs_n    (sr_cs_n ),
			.sr_oe_n    (sr_oe_n )
			);

end // sr_ctrl_is_implemented
else begin : sr_ctrl_is_not_implemented
 
 assign sr_ctrl_dm_slv_wait    = 1'b0;
 assign sr_ctrl_dm_slv_out_en  = 1'b0;
 assign sr_ctrl_dm_slv_dbusout = {8{1'b0}};

 assign sr_adr   = {16{1'b0}}; 
 assign sr_d_out = {8{1'b0}};
 assign sr_d_oe  = 1'b0;
 assign sr_we_n  = 1'b1;
 assign sr_cs_n  = 1'b1; 
 assign sr_oe_n  = 1'b1;
end // sr_ctrl_is_not_implemented

endgenerate


generate

 wire[1:0] dummy_irqlines; // Leav unconnected
 // int[7:8] are not used due to the lack of interrupt request inputs of CPU

 if(LP_USE_INT_CTRL) begin : ext_int_mod_is_used
       ext_int_mod ext_int_mod_inst(
                   .ireset      (core_ireset), 
		   .cp2         (cp2), 
		   .adr         (io_arb_mux_adr), 
		   .iowe        (io_arb_mux_iore), 
		   .iore        (io_arb_mux_iowe), 
		   .dbus_in     (io_arb_mux_dbusout), 
		   .dbus_out    (ext_int_mod_io_dbus_out), 
		   .io_out_en   (ext_int_mod_io_out_en), 
		   .ramadr      (avr_interconnect_ramadr[7:0]), 
		   .ramre       (avr_interconnect_ramre), 
		   .ramwe       (avr_interconnect_ramwe), 
		   .dm_sel      (avr_interconnect_sel_60_ff), // ??? TBD !!!!! RAM space is already occupied 
		   .dm_dbus_in  (avr_interconnect_ramdout), 
		   .dm_dbus_out (ext_int_mod_dm_dbus_out), 
		   .dm_out_en   (ext_int_mod_dm_out_en), 
		   .e_int_in    (int), 
		   .irq         ({dummy_irqlines[1:0],core_irqlines[6:2],core_irqlines[0]}), 
		   .irq_ack     ({{2{1'b0}},avr_interconnect_ind_irq_ack[6:2],avr_interconnect_ind_irq_ack[0]})
		   );
		   	
 end // ext_int_mod_is_used
 else begin : ext_int_mod_is_not_used	
 
  assign ext_int_mod_io_dbus_out = {8{1'b0}};
  assign ext_int_mod_dm_dbus_out = {8{1'b0}};
  assign ext_int_mod_io_out_en   = 1'b0;   
  assign ext_int_mod_dm_out_en   = 1'b0;
  assign ext_int_mod_wait        = 1'b0;   

  // Unused core_irqlines (TBD)
  assign core_irqlines[0]   = 1'b0;
  assign core_irqlines[6:2] = {5{1'b0}};

 end // ext_int_mod_is_not_used 
	
endgenerate	
			
endmodule // uc_top_wrp_vlog			
