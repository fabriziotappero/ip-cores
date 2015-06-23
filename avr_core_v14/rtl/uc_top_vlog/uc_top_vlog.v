//******************************************************************************************
// Top module for AVR Core (Verilog version)
// Versuion 0.61
// Modified 09.06.2012
// Written by Ruslan Lepetenok (lepetenokr@yahoo.com)
// Parameter in_hex_file was removed
//******************************************************************************************

`include "synth_ctrl_pack.vh"

module uc_top_vlog #(
	                 parameter tech  	       = `c_tech,      // TBD 
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
			 parameter dm_int_sram_read_ws = `c_dm_int_sram_read_ws  			
			 )
                        
			(
			 input                         nrst,
			 input                         clk,
			 
			 // PORTA
			 inout[7:0]                    porta,
			 
			 // UART related
			 input                         rxd,
			 output wire                   txd,  
			  
			 // SPI related
			 inout                         mosi,
			 inout                         miso,
			 inout                         sck, 
			 output wire                   spi_cs_n,
			 
			 //I2C related
			inout                          m_scl,
			inout                          m_sda,
			inout                          s_scl,
			inout                          s_sda,
			 
			 // Interrupts
			input[7:0]                     int,
			 
			 // JTAG related
			input                          tck,
			input                          tms,
			input                          tdi,
			output wire                    tdo,
		
  			// SRAM i/f
			output wire[15:0]              sram_a,    
			inout[7:0]                     sram_d,     
			output wire[sram_chip_num-1:0] sram_csn,    
			output wire                    sram_oen,    
			output wire                    sram_wen    	     
			);
			

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire                     pwr_on_nrst;
 
// PORTA related 
wire[7:0]                porta_portx;
wire[7:0]                porta_ddrx;
// SPI related
wire	                 misoi;   
wire	                 mosii;   
wire	                 scki;    
wire	                 ss_b;    
		
wire                     misoo;	
wire                     mosio;	
wire                     scko;	
wire                     spe;        
wire                     spimaster;  

 // I2C related 
 // TRI control and data for the slave channel
 wire                    sdaout;  
 wire                    sdaen;  
 wire                    sclout;  
 wire                    sclen;   
 // TRI control and data for the master channel
 wire                    msdaout;  
 wire                    msdaen;   
 wire                    msclout;
 wire                    msclen;   
 
 wire                    tdo_int;
 wire                    tdo_oe;
 
 // Static RAM interface
 wire[7:0]               sr_d_out;	
 wire	                 sr_d_oe;	

 // PM interface
 wire[15:0]              pm_adr;
 wire[15:0]              pm_dout;
 wire[15:0]              pm_din;		
 wire                    pm_we_h;
 wire                    pm_we_l;
 wire                    pm_ce;    // Optional 
 
 // DM interface
 wire[15:0]              dm_adr;
 wire[7:0]               dm_dout;
 wire[7:0]               dm_din;
 wire                    dm_ce;		
 wire                    dm_we;

 wire                    clkn; // Inverted clock (For PM and DM)


 wire[7:0]               sr_d_in; 

// ~~~~~~~~~~~~~~~~~

// Clock invertor			
assign clkn = ~clk;			
			
uc_top_wrp_vlog #(
	                 .tech  	      ( tech), // !!! tech), 
	                 .synth_on	      ( synth_on),
	                 .pm_size	      ( pm_size),
	                 .dm_size	      ( dm_size),
			 
			 .bm_use_ext_tmr      ( bm_use_ext_tmr), 
			 .dm_mst_num	      ( dm_mst_num), 
			 .dm_slv_num	      ( dm_slv_num),
			 .use_rst	      ( use_rst),
			 .irqs_width	      ( irqs_width),
			 .pc22b_core	      ( pc22b_core), 
			 .io_slv_num	      ( io_slv_num),
			 .sram_chip_num       ( sram_chip_num),
			 .impl_synth_core     ( impl_synth_core),
			 .impl_jtag_ocd_prg   ( impl_jtag_ocd_prg),
			 .impl_usart	      ( impl_usart),
			 .impl_ext_dbg_sys    ( impl_ext_dbg_sys),
			 .impl_smb	      ( impl_smb),
			 .impl_spi	      ( impl_spi),
			 .impl_wdt	      ( impl_wdt),
			 .impl_srctrl         ( impl_srctrl),
			 .impl_hw_bm	      ( impl_hw_bm),
			 .rst_act_high        ( rst_act_high),
			 .old_pm	      ( old_pm),
			 // Added 31.12.11
			 .dm_int_sram_read_ws ( dm_int_sram_read_ws),  // DM access(read) wait stait is inserted			
			 .impl_mul            ( 1 )// ???    
			 )
                        
     uc_top_wrp_vlog_inst(
			 .nrst        (nrst),
			 .clk         (clk ),
			 .pwr_on_nrst (pwr_on_nrst),
			 // PORTA related 
			 .porta_portx (porta_portx),
	                 .porta_ddrx  (porta_ddrx),
	                 .porta_pinx  (porta),
			 // Timer related
			 .tmr_ext_1   (1'b0),
			 .tmr_ext_2   (1'b0),
			 // UART related
			 .rxd         (rxd),
			 .txd         (txd),  
			 // SPI related
			 .misoi        (miso),   
			 .mosii        (mosi),   
			 .scki         (sck),    
			 .ss_b         (ss_b),    
			 .misoo        (misoo	),	 
			 .mosio        (mosio	),	 
			 .scko         (scko	),	 
			 .spe          (spe	),	  
			 .spimaster    (spimaster),  
                         .spi_cs_n     (spi_cs_n), 
                         //I2C related 
			 // TRI control and data for the slave channel
			 .sdain       (s_sda),   
			 .sdaout      (sdaout),                                     
			 .sdaen       (sdaen),     				      
			 .sclin       (s_scl),   				    
			 .sclout      (sclout),  				      
			 .sclen       (sclen),   					     
			 // TRI control and data for the master channel 	    
			 .msdain      (m_sda),   				    
			 .msdaout     (msdaout),  				
			 .msdaen      (msdaen),   				
			 .msclin      (m_scl),   
			 .msclout     (msclout),
			 .msclen      (msclen),   
			 // Interrupts
			 .int         (int),
			 // JTAG related
			 .tck         (tck),
			 .tms         (tms),
			 .tdi         (tdi),
			 .tdo         (tdo_int),
			 .tdo_oe      (tdo_oe),
			 // Static RAM interface
			 .sr_adr      (sram_a), 
			 .sr_d_in     (sr_d_in ),	 
			 .sr_d_out    (sr_d_out),	 
			 .sr_d_oe     (sr_d_oe),	 
			 .sr_we_n     (sram_wen),	
			 .sr_cs_n     (sram_csn),	
			 .sr_oe_n     (sram_oen),
		         // PM interface
			 .pm_adr      (pm_adr ),
        		 .pm_dout     (pm_dout),
        		 .pm_din      (pm_din ),	
                         .pm_we_h     (pm_we_h),
                         .pm_we_l     (pm_we_l),
                         .pm_ce       (pm_ce  ),    // Optional 
			 // DM interface
			 .dm_adr      (dm_adr ),
        		 .dm_dout     (dm_dout),
        		 .dm_din      (dm_din ),
			 .dm_ce       (dm_ce  ),	
                         .dm_we       (dm_we  )
			);			
			

generate

if(!old_pm) begin : old_pm_is_not_impl

p_mem #(
        .tech(tech),
	.pm_size(pm_size)
	) 
p_mem_inst(
   .clk     (clkn),
   .ce      (pm_ce),
   .address (pm_adr),
   .din     (pm_dout),
   .dout    (pm_din),
   .weh     (pm_we_h),
   .wel     (pm_we_l)
);

end // old_pm_is_not_impl

else begin : old_pm_is_impl

prom prom_inst(
               .addr_in (pm_adr),
               .rom_out (pm_din)
              );

end // old_pm_is_impl

endgenerate


d_mem #(
        .tech(tech), 
	.dm_size(dm_size), 
	.read_ws(dm_int_sram_read_ws)
	) 
d_mem_inst(
   .cp2     (clk),
   .cp2n    (clkn),
   .ce      (dm_ce),
   .address (dm_adr),
   .din     (dm_dout),
   .dout    (dm_din),
   .we      (dm_we)  
);

	
tri_buf #(.tech(tech)) tri_buf_tdo_inst(
	       .out (tdo),
	       .in  (tdo_int),
	       .en  (tdo_oe)
	       );	


tri_buf #(.tech(tech)) tri_buf_s_sda_inst(
	       .out (s_sda),
	       .in  (sdaout),
	       .en  (sdaen)
	       );	

tri_buf #(.tech(tech)) tri_buf_s_scl_inst(
	       .out (s_scl),
	       .in  (sclout),
	       .en  (sclen)
	       );	

tri_buf #(.tech(tech)) tri_buf_m_sda_inst(
	       .out (m_sda),
	       .in  (msdaout),
	       .en  (msdaen)
	       );	

tri_buf #(.tech(tech)) tri_buf_m_scl_inst(
	       .out (m_scl),
	       .in  (msclout),
	       .en  (msclen)
	       );	

tri_buf_vect #(.tech(tech),.width(8),.en_inv_pol(0)) tri_buf_vect_porta_inst(
	       .out (porta),
	       .in  (porta_portx),
	       .en  (porta_ddrx) 
	       );

assign sr_d_in = sram_d;

tri_buf_vect #(.tech(tech),.width(8),.en_inv_pol(0)) tri_buf_vect_sr_d_out_inst(
	       .out (sram_d),
	       .in  (sr_d_out),
	       .en  ({8{sr_d_oe}}) 
	       );

/*
tri_buf #(.tech(tech)) tri_buf_xxxxx_inst(
	       .out (),
	       .in  (),
	       .en  ()
	       );	
*/


tri_buf #(.tech(tech)) tri_buf_mosi_inst(
	       .out (mosi),
	       .in  (mosio),
	       .en  (spimaster)
	       );	

tri_buf #(.tech(tech)) tri_buf_sck_inst(
	       .out (sck),
	       .in  (scko),
	       .en  (spimaster)
	       );	


tri_buf #(.tech(tech)) tri_buf_miso_inst(
	       .out (miso),
	       .in  (misoo),
	       .en  (~spimaster)
	       );	


assign ss_b = 1'b1;

// assign xxx = spe;

por_rst_gen #(.tech(tech)) por_rst_gen_inst(
   .clk       (clk),
   .por_n_i   (1'b1),
   .por_n_o   (pwr_on_nrst),
   .por_n_o_g ()
   );


		
endmodule // uc_top_vlog			
