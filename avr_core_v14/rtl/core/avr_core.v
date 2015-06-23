//************************************************************************************************
//  Top entity for AVR core
//  Version 2.6
//  Designed by Ruslan Lepetenok 
//  Modified 12.14.2007
//  SLEEP and CLRWDT instructions support was added
//  BREAK instructions support was added 
//  PM clock enable was removed
// 	rampz_width/eind_width widths was fixed
// Modified 18.08.12 Verilog LINT
//************************************************************************************************

`timescale 1 ns / 1 ns

module avr_core #(
   		 parameter		impl_mul    = 1,
   		 parameter		use_rst     = 1,
   		 parameter		pc22b       = 0,
   		 parameter		eind_width  = 1,
   		 parameter		rampz_width = 1,
   		 parameter		irqs_width  = 23
                 ) 
		 (
   		  //Clock and reset
   		  input wire		      cp2,
   		  input wire		      cp2en,
   		  input wire		      ireset,
   		  // JTAG OCD support
   		  output wire		      valid_instr,
   		  input wire		      insert_nop,
   		  input wire		      block_irq,
   		  output wire		      change_flow,
   		  // Program Memory
   		  output wire [15:0]	      pc,
   		  input wire [15:0]	      inst,
   		  //   pm_ce	   : out  std_logic,
   		  
   		  // I/O control
   		  output wire [5:0]	      adr,
   		  output wire		      iore,
   		  output wire		      iowe,
   		  // Data memory control
   		  output wire [15:0]	      ramadr,
   		  output wire		      ramre,
   		  output wire		      ramwe,
   		  input wire		      cpuwait,
   		  // Data paths
   		  input wire [7:0]	      dbusin,
   		  output wire [7:0]	      dbusout,
   		  // Interrupt
   		  input wire [irqs_width-1:0] irqlines,
   		  output wire		      irqack,
   		  output wire [4:0]	      irqackad,
   		  //Sleep Control
   		  output wire		      sleepi,
   		  output wire		      irqok,
   		  output wire		      globint,
   		  //Watchdog
   		  output wire		      wdri,
   		  // SPM instruction support
   		  output wire [15:0]	      spm_out,
   		  output wire		      spm_inst,
   		  input wire		      spm_wait
		);

//************************************************************************************************
   
   wire [7:0]             dbusin_int;
   
   // SIGNALS FOR INSTRUCTION AND STATES
   wire                   idc_add;
   wire                   idc_adc;
   wire                   idc_adiw;
   wire                   idc_sub;
   wire                   idc_subi;
   wire                   idc_sbc;
   wire                   idc_sbci;
   wire                   idc_sbiw;
   wire                   adiw_st;
   wire                   sbiw_st;
   wire                   idc_and;
   wire                   idc_andi;
   wire                   idc_or;
   wire                   idc_ori;
   wire                   idc_eor;
   wire                   idc_com;
   wire                   idc_neg;
   wire                   idc_inc;
   wire                   idc_dec;
   wire                   idc_cp;
   wire                   idc_cpc;
   wire                   idc_cpi;
   wire                   idc_cpse;
   wire                   idc_lsr;
   wire                   idc_ror;
   wire                   idc_asr;
   wire                   idc_swap;
   wire                   sbi_st;
   wire                   cbi_st;
   wire                   idc_bst;
   wire                   idc_bset;
   wire                   idc_bclr;
   wire                   idc_sbic;
   wire                   idc_sbis;
   wire                   idc_sbrs;
   wire                   idc_sbrc;
   wire                   idc_brbs;
   wire                   idc_brbc;
   wire                   idc_reti;
   
   wire [7:0]             alu_data_r_in;
   wire [7:0]             alu_data_out;
   
   wire [7:0]             reg_rd_in;
   wire [7:0]             reg_rd_out;
   wire [7:0]             reg_rr_out;
   
   wire [4:0]             reg_rd_adr;
   wire [4:0]             reg_rr_adr;
   
   wire [15:0]            reg_h_out;
   wire [15:0]            reg_z_out;
   
   wire [2:0]             reg_h_adr;
   
   wire                   reg_rd_wr;
   wire                   post_inc;
   wire                   pre_dec;
   wire                   reg_h_wr;
   
   wire [7:0]             sreg_fl_in;
   wire [7:0]             sreg_out;
   wire [7:0]             sreg_fl_wr_en;
   wire [7:0]             spl_out;
   wire [7:0]             sph_out;
   wire [7:0]             rampz_out;
   
   wire                   sp_ndown_up;
   wire                   sp_en;
   
   wire [2:0]             bit_num_r_io;
   wire [2:0]             branch;
   
   wire [7:0]             bitpr_io_out;
   wire [7:0]             bit_pr_sreg_out;
   wire [7:0]             bld_op_out;
   
   wire                   bit_test_op_out;
   
   wire                   alu_c_flag_out;
   wire                   alu_z_flag_out;
   wire                   alu_n_flag_out;
   wire                   alu_v_flag_out;
   wire                   alu_s_flag_out;
   wire                   alu_h_flag_out;
   
   // Extended instructions 
   wire                   w_op;
   wire [7:0]             reg_rd_hb_in;
   wire [7:0]             reg_rr_hb_out;
   
   // Multiplier i/f
   wire                   fmul;		// FMUL/FMULS/FMULSU   									 
   wire                   muls;		// MULS/FMULS           									 
   wire                   mulsu;		// MULSU/FMULSU         									 
   wire [15:0]            mr_out;
   wire                   mc_out;		// C flag           									 
   wire                   mz_out;		// Z flag            									 
   
   // Devices with 22 bit PC
   wire [7:0]             eind_out;
 
 //************************************************************************************************  
   
   // Clock and reset
   // JTAG OCD support
   // Program memory
   //									  pm_ce    => pm_ce,
   // I/O control
   // Data memory control
   // Data paths
   // Interrupt
   //Sleep 
   //Watchdog
   // ALU interface(Data inputs)
   // ALU interface(Instruction inputs)
  
   
   // ALU interface(Data output)
   // ALU interface(Flag outputs)
   // General purpose register file interface
   
   // I/O register file interface
   //??   
   // SREG I flag   
   
   // Bit processor interface
  
   
   // Multipler i/f
   // FMUL/FMULS/FMULSU
   // MULS/FMULS
   // MULSU/FMULSU
   // C flag
   // SPM support
   // Devices with 22 bit PC
   // Z flag
   
   pm_fetch_dec #(
                  .pc22b            (pc22b), 
		  .irqs_width       (irqs_width)
		  ) 
   pm_fetch_dec_Inst (
                    .cp2             (cp2), 
		    .cp2en           (cp2en), 
		    .ireset          (ireset), 
		    .valid_instr     (valid_instr), 
		    .insert_nop      (insert_nop), 
		    .block_irq       (block_irq), 
		    .change_flow     (change_flow), 
		    .pc              (pc), 
		    .inst            (inst), 
		    .adr             (adr), 
		    .iore            (iore), 
		    .iowe            (iowe), 
		    .ramadr          (ramadr), 
		    .ramre           (ramre), 
		    .ramwe           (ramwe), 
		    .cpuwait         (cpuwait), 
		    .dbusin          (dbusin_int), 
		    .dbusout         (dbusout), 
		    .irqlines        (irqlines), 
		    .irqack          (irqack), 
		    .irqackad        (irqackad), 
		    .sleepi          (sleepi), 
		    .irqok           (irqok), 
		    .wdri            (wdri), 
		    .alu_data_r_in   (alu_data_r_in), 
		    .idc_add_out     (idc_add), 
		    .idc_adc_out     (idc_adc), 
		    .idc_adiw_out    (idc_adiw), 
		    .idc_sub_out     (idc_sub), 
		    .idc_subi_out    (idc_subi), 
		    .idc_sbc_out     (idc_sbc), 
		    .idc_sbci_out    (idc_sbci), 
		    .idc_sbiw_out    (idc_sbiw), 
		    .adiw_st_out     (adiw_st), 
		    .sbiw_st_out     (sbiw_st), 
		    .idc_and_out     (idc_and), 
		    .idc_andi_out    (idc_andi), 
		    .idc_or_out      (idc_or), 
		    .idc_ori_out     (idc_ori), 
		    .idc_eor_out     (idc_eor), 
		    .idc_com_out     (idc_com), 
		    .idc_neg_out     (idc_neg), 
		    .idc_inc_out     (idc_inc), 
		    .idc_dec_out     (idc_dec), 
		    .idc_cp_out      (idc_cp), 
		    .idc_cpc_out     (idc_cpc), 
		    .idc_cpi_out     (idc_cpi), 
		    .idc_cpse_out    (idc_cpse), 
		    .idc_lsr_out     (idc_lsr), 
		    .idc_ror_out     (idc_ror), 
		    .idc_asr_out     (idc_asr), 
		    .idc_swap_out    (idc_swap), 
		    .alu_data_out    (alu_data_out), 
		    .alu_c_flag_out  (alu_c_flag_out), 
		    .alu_z_flag_out  (alu_z_flag_out), 
		    .alu_n_flag_out  (alu_n_flag_out), 
		    .alu_v_flag_out  (alu_v_flag_out), 
		    .alu_s_flag_out  (alu_s_flag_out), 
		    .alu_h_flag_out  (alu_h_flag_out), 
		    .reg_rd_in       (reg_rd_in), 
		    .reg_rd_out      (reg_rd_out), 
		    .reg_rd_adr      (reg_rd_adr), 
		    .reg_rr_out      (reg_rr_out), 
		    .reg_rr_adr      (reg_rr_adr), 
		    .reg_rd_wr       (reg_rd_wr), 
		    .post_inc        (post_inc), 
		    .pre_dec         (pre_dec), 
		    .reg_h_wr        (reg_h_wr), 
		    .reg_h_out       (reg_h_out), 
		    .reg_h_adr       (reg_h_adr), 
		    .reg_z_out       (reg_z_out), 
		    .w_op            (w_op), 
		    .reg_rd_hb_in    (reg_rd_hb_in), 
		    .reg_rr_hb_out   (reg_rr_hb_out), 
		    .sreg_fl_in      (sreg_fl_in), 
		    .globint         (sreg_out[7]), 
		    .sreg_fl_wr_en   (sreg_fl_wr_en), 
		    .spl_out         (spl_out), 
		    .sph_out         (sph_out), 
		    .sp_ndown_up     (sp_ndown_up), 
		    .sp_en           (sp_en), 
		    .rampz_out       (rampz_out), 
		    .bit_num_r_io    (bit_num_r_io), 
		    .bitpr_io_out    (bitpr_io_out), 
		    .branch          (branch), 
		    .bit_pr_sreg_out (bit_pr_sreg_out), 
		    .bld_op_out      (bld_op_out), 
		    .bit_test_op_out (bit_test_op_out), 
		    .sbi_st_out      (sbi_st), 
		    .cbi_st_out      (cbi_st), 
		    .idc_bst_out     (idc_bst), 
		    .idc_bset_out    (idc_bset), 
		    .idc_bclr_out    (idc_bclr), 
		    .idc_sbic_out    (idc_sbic), 
		    .idc_sbis_out    (idc_sbis), 
		    .idc_sbrs_out    (idc_sbrs), 
		    .idc_sbrc_out    (idc_sbrc), 
		    .idc_brbs_out    (idc_brbs), 
		    .idc_brbc_out    (idc_brbc), 
		    .idc_reti_out    (idc_reti), 
		    .fmul            (fmul), 
		    .muls            (muls), 
		    .mulsu           (mulsu), 
		    .mr_out          (mr_out), 
		    .mc_out          (mc_out), 
		    .mz_out          (mz_out), 
		    .spm_inst        (spm_inst), 
		    .spm_wait        (spm_wait), 
		    .eind_out        (eind_out[5:0])
		    );		
   
   
   //Clock and reset
   
   
   // Extended instructions 
   reg_file #(
              .use_rst        (use_rst)
	      ) 
     GPRF_Inst(
               .cp2           (cp2), 
	       .cp2en         (cp2en), 
	       .ireset        (ireset), 
	       .reg_rd_in     (reg_rd_in), 
	       .reg_rd_out    (reg_rd_out), 
	       .reg_rd_adr    (reg_rd_adr), 
	       .reg_rr_out    (reg_rr_out), 
	       .reg_rr_adr    (reg_rr_adr), 
	       .reg_rd_wr     (reg_rd_wr), 
	       .post_inc      (post_inc), 
	       .pre_dec       (pre_dec), 
	       .reg_h_wr      (reg_h_wr), 
	       .reg_h_out     (reg_h_out), 
	       .reg_h_adr     (reg_h_adr), 
	       .reg_z_out     (reg_z_out), 
	       .w_op          (w_op), 
	       .reg_rd_hb_in  (reg_rd_hb_in), 
	       .reg_rr_hb_out (reg_rr_hb_out), 
	       .spm_out       (spm_out)
	       );
   
   
   //Clock and reset
   // Instructions and states
 
   
   
   bit_processor BP_Inst(
                         .cp2             (cp2), 
			 .cp2en           (cp2en), 
			 .ireset          (ireset), 
			 .bit_num_r_io    (bit_num_r_io), 
			 .dbusin          (dbusin_int), 
			 .bitpr_io_out    (bitpr_io_out), 
			 .sreg_out        (sreg_out), 
			 .branch          (branch), 
			 .bit_pr_sreg_out (bit_pr_sreg_out), 
			 .bld_op_out      (bld_op_out), 
			 .reg_rd_out      (reg_rd_out), 
			 .bit_test_op_out (bit_test_op_out), 
			 .sbi_st          (sbi_st), 
			 .cbi_st          (cbi_st), 
			 .idc_bst         (idc_bst), 
			 .idc_bset 	  (idc_bset), 
			 .idc_bclr 	  (idc_bclr), 
			 .idc_sbic 	  (idc_sbic), 
			 .idc_sbis 	  (idc_sbis), 
			 .idc_sbrs 	  (idc_sbrs), 
			 .idc_sbrc 	  (idc_sbrc), 
			 .idc_brbs 	  (idc_brbs), 
			 .idc_brbc 	  (idc_brbc), 
			 .idc_reti 	  (idc_reti)
			 );
   
   
   // LOCAL DATA BUS OUTPUT
   // SREG/SPL/SPH/RAMPZ i/f 
   io_adr_dec #(
                .pc22b     (pc22b)
	        ) 
   io_dec_Inst(
               .adr        (adr), 
	       .iore       (iore), 
	       .dbusin_int (dbusin_int), 
	       .dbusin_ext (dbusin), 
	       .spl_out    (spl_out), 
	       .sph_out    (sph_out), 
	       .sreg_out   (sreg_out), 
	       .rampz_out  (rampz_out), 
	       .eind_out   (eind_out)
	       );		// EXTERNAL DATA BUS INPUT
   
   
   //Clock and reset
   // I/O i/f
   // SREG related signals
   // SPL/SPH related signals
   // RAMPZ related signals
   // EIND related signals
   io_reg_file #(
                 .pc22b       (pc22b), 
		 .eind_width  (eind_width), 
		 .rampz_width (rampz_width)) 
   IORegs_Inst(
               .cp2           (cp2), 
	       .cp2en         (cp2en), 
	       .ireset        (ireset), 
	       .adr           (adr), 
	       .iowe          (iowe), 
	       .dbusout       (dbusout), 
	       .sreg_fl_in    (sreg_fl_in), 
	       .sreg_out      (sreg_out), 
	       .sreg_fl_wr_en (sreg_fl_wr_en), 
	       .spl_out       (spl_out), 
	       .sph_out       (sph_out), 
	       .sp_ndown_up   (sp_ndown_up), 
	       .sp_en         (sp_en), 
	       .rampz_out     (rampz_out), 
	       .eind_out      (eind_out)
	       );
   
   
   // Data inputs
   
   // Instructions and states
  
   
   // Data outputs
   // Flag outputs
   alu_avr ALU_Inst(
                    .alu_data_r_in  (alu_data_r_in), 
		    .alu_data_d_in  (reg_rd_out), 
		    .alu_c_flag_in  (sreg_out[0]), 
		    .alu_z_flag_in  (sreg_out[1]), 
		    .idc_add        (idc_add), 
		    .idc_adc        (idc_adc), 
		    .idc_adiw       (idc_adiw), 
		    .idc_sub        (idc_sub), 
		    .idc_subi       (idc_subi), 
		    .idc_sbc        (idc_sbc), 
		    .idc_sbci       (idc_sbci), 
		    .idc_sbiw       (idc_sbiw), 
		    .adiw_st        (adiw_st), 
		    .sbiw_st        (sbiw_st), 
		    .idc_and        (idc_and), 
		    .idc_andi       (idc_andi), 
		    .idc_or         (idc_or), 
		    .idc_ori        (idc_ori), 
		    .idc_eor        (idc_eor), 
		    .idc_com        (idc_com), 
		    .idc_neg        (idc_neg), 
		    .idc_inc        (idc_inc), 
		    .idc_dec        (idc_dec), 
		    .idc_cp         (idc_cp), 
		    .idc_cpc        (idc_cpc), 
		    .idc_cpi        (idc_cpi), 
		    .idc_cpse       (idc_cpse), 
		    .idc_lsr        (idc_lsr), 
		    .idc_ror        (idc_ror), 
		    .idc_asr        (idc_asr), 
		    .idc_swap       (idc_swap), 
		    .alu_data_out   (alu_data_out), 
		    .alu_c_flag_out (alu_c_flag_out), 
		    .alu_z_flag_out (alu_z_flag_out), 
		    .alu_n_flag_out (alu_n_flag_out), 
		    .alu_v_flag_out (alu_v_flag_out), 
		    .alu_s_flag_out (alu_s_flag_out), 
		    .alu_h_flag_out (alu_h_flag_out)
		    );
   
   generate
      if (impl_mul == 1)
      begin : mul_is_used
         
         // AVR global clock/reset signals
         //
         // FMUL/FMULS/FMULSU
         // MULS/FMULS
         // MULSU/FMULSU
         // rd_in,
         // rr_in,
         // Z flag
         avr_mul #(
	           .use_rst   (use_rst)
		   ) 
         avr_mul_Inst(
	              .ireset (ireset), 
		      .cp2    (cp2), 
		      .cp2en  (cp2en), 
		      .fmul   (fmul), 
		      .muls   (muls), 
		      .mulsu  (mulsu), 
		      .rd_in  (reg_rd_out), 
		      .rr_in  (reg_rr_out), 
		      .mr_out (mr_out), 
		      .mc_out (mc_out), 
		      .mz_out (mz_out)
		      );		// C flag
      end

     else // (impl_mul == 0)
      begin : no_mul
         assign mr_out = {16{1'b0}};
         assign mc_out = 1'b0;		// C flag
         assign mz_out = 1'b0;		// Z flag
      end
   endgenerate
   
   // Outputs
   
   // Sleep support
   assign globint = sreg_out[7];		// I flag
   
endmodule // avr_core
