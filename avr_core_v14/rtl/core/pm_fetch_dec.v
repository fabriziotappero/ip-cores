//************************************************************************************************
//  PM_FETCH_DEC(internal module) for AVR core
//	Version 3.0 (Special version for the JTAG OCD)
//  Designed by Ruslan Lepetenok 14.11.2001
//  Modified 08.01.2007 (13.01.06)
//  Modification:
//  Registered ramre/ramwe outputs
//  cpu_busy logic modified(affects RCALL/ICALL/CALL instruction interract with interrupt)
//  SLEEP and CLRWDT instructions support was added
//  V-flag bug fixed (AND/ANDI/OR/ORI/EOR)
//  V-flag bug fixed (ADIW/SBIW)
//  Unused outputs(sreg_bit_num[2..0],idc_sbi_out,idc_cbi_out,idc_bld_out) were removed.
//  Output alu_data_d_in[7..0] was removed.
//  Gloabal clock enable(cp2en) was added  
//  cpu_busy(push/pop) + irq bug was fixed 14.07.05
//  BRXX+IRQ interaction was modified -> cpu_busy
//  LDS/STS now requires only two cycles for execution (13.01.06 -> last modificatioon)
//  PM clock enable output was removed(commented) 16.11.2006
//	ELPM+IRQ interaction bug was fixed 	17.11.06 (cpu_busy)
//  std_library was added  03.01.07
//  Verilog version modified 23.01.12
//  IRQ vector address generation was modified 10.06.12
// 30.06.12 started modification for scan chains /TMR
// 01.07.12 Modification for DFT is finished
// 18.08.12 Verilog LINT
//************************************************************************************************

`timescale 1 ns / 1 ps

module pm_fetch_dec(
                    cp2, 
		    cp2en, 
		    ireset, 
		    valid_instr, 
		    insert_nop, 
		    block_irq, 
		    change_flow, 
		    pc, 
		    inst, 
		    adr, 
		    iore, 
		    iowe, 
		    ramadr, 
		    ramre, 
		    ramwe, 
		    cpuwait, 
		    dbusin, 
		    dbusout, 
		    irqlines, 
		    irqack, 
		    irqackad, 
		    sleepi, 
		    irqok, 
		    wdri, 
		    alu_data_r_in, 
		    idc_add_out, 
		    idc_adc_out, 
		    idc_adiw_out, 
		    idc_sub_out, 
		    idc_subi_out, 
		    idc_sbc_out, 
		    idc_sbci_out, 
		    idc_sbiw_out, 
		    adiw_st_out, 
		    sbiw_st_out, 
		    idc_and_out, 
		    idc_andi_out, 
		    idc_or_out, 
		    idc_ori_out, 
		    idc_eor_out, 
		    idc_com_out, 
		    idc_neg_out, 
		    idc_inc_out, 
		    idc_dec_out, 
		    idc_cp_out, 
		    idc_cpc_out, 
		    idc_cpi_out, 
		    idc_cpse_out, 
		    idc_lsr_out, 
		    idc_ror_out, 
		    idc_asr_out, 
		    idc_swap_out, 
		    alu_data_out, 
		    alu_c_flag_out, 
		    alu_z_flag_out, 
		    alu_n_flag_out, 
		    alu_v_flag_out, 
		    alu_s_flag_out, 
		    alu_h_flag_out, 
		    reg_rd_in, 
		    reg_rd_out, 
		    reg_rd_adr, 
		    reg_rr_out, 
		    reg_rr_adr, 
		    reg_rd_wr, 
		    post_inc, 
		    pre_dec, 
		    reg_h_wr, 
		    reg_h_out, 
		    reg_h_adr, 
		    reg_z_out, 
		    w_op, 
		    reg_rd_hb_in, 
		    reg_rr_hb_out, 
		    sreg_fl_in, 
		    globint, 
		    sreg_fl_wr_en, 
		    spl_out, 
		    sph_out, 
		    sp_ndown_up, 
		    sp_en, 
		    rampz_out, 
		    bit_num_r_io, 
		    bitpr_io_out, 
		    branch, 
		    bit_pr_sreg_out, 
		    bld_op_out, 
		    bit_test_op_out, 
		    sbi_st_out, 
		    cbi_st_out, 
		    idc_bst_out, 
		    idc_bset_out, 
		    idc_bclr_out, 
		    idc_sbic_out, 
		    idc_sbis_out, 
		    idc_sbrs_out, 
		    idc_sbrc_out, 
		    idc_brbs_out, 
		    idc_brbc_out, 
		    idc_reti_out, 
		    fmul, 
		    muls, 
		    mulsu, 
		    mr_out, 
		    mc_out, 
		    mz_out, 
		    spm_inst, 
		    spm_wait, 
		    eind_out
		    );

//*************************************************************************************************************************

   parameter              pc22b = 0;  // Reserved for the future use
   parameter              irqs_width = 23;
   
   // Clock and reset
   input                  cp2;
   input                  cp2en;
   input                  ireset;
   // JTAG OCD support
   output                 valid_instr;
   input                  insert_nop;
   input                  block_irq;
   output                 change_flow;
   // Program memory
   output [15:0]          pc;
   input [15:0]           inst;
   //							  pm_ce            : out  std_logic;
   // I/O control
   output [5:0]           adr;
   output                 iore;
   output                 iowe;
   // Data memory control
   output [15:0]          ramadr;
   output                 ramre;
   output                 ramwe;
   input                  cpuwait;
   // Data paths
   input [7:0]            dbusin;
   output [7:0]           dbusout;
   // Interrupt
   input [irqs_width-1:0] irqlines;
   output                 irqack;
   output [4:0]           irqackad;
   //Sleep 
   output                 sleepi;
   output                 irqok;
   //Watchdog
   output                 wdri;
   // ALU interface(Data inputs)
   output [7:0]           alu_data_r_in;
   // ALU interface(Instruction inputs)
   output                 idc_add_out;
   output                 idc_adc_out;
   output                 idc_adiw_out;
   output                 idc_sub_out;
   output                 idc_subi_out;
   output                 idc_sbc_out;
   output                 idc_sbci_out;
   output                 idc_sbiw_out;
   
   output                 adiw_st_out;
   output                 sbiw_st_out;
   
   output                 idc_and_out;
   output                 idc_andi_out;
   output                 idc_or_out;
   output                 idc_ori_out;
   output                 idc_eor_out;
   output                 idc_com_out;
   output                 idc_neg_out;
   
   output                 idc_inc_out;
   output                 idc_dec_out;
   
   output                 idc_cp_out;
   output                 idc_cpc_out;
   output                 idc_cpi_out;
   output                 idc_cpse_out;
   
   output                 idc_lsr_out;
   output                 idc_ror_out;
   output                 idc_asr_out;
   output                 idc_swap_out;
   
   // ALU interface(Data output)
   input [7:0]            alu_data_out;
   
   // ALU interface(Flag outputs)
   input                  alu_c_flag_out;
   input                  alu_z_flag_out;
   input                  alu_n_flag_out;
   input                  alu_v_flag_out;
   input                  alu_s_flag_out;
   input                  alu_h_flag_out;
   
   // General purpose register file interface
   output [7:0]           reg_rd_in;
   input [7:0]            reg_rd_out;
   output [4:0]           reg_rd_adr;
   input [7:0]            reg_rr_out;
   output [4:0]           reg_rr_adr;
   output                 reg_rd_wr;
   
   output                 post_inc;		// POST INCREMENT FOR LD/ST INSTRUCTIONS
   output                 pre_dec;		// PRE DECREMENT FOR LD/ST INSTRUCTIONS
   output                 reg_h_wr;
   input [15:0]           reg_h_out;
   output [2:0]           reg_h_adr;		// x,y,z
   input [15:0]           reg_z_out;		// OUTPUT OF R31:R30 FOR LPM/ELPM/IJMP INSTRUCTIONS
   
   output                 w_op;
   output [7:0]           reg_rd_hb_in;
   input [7:0]            reg_rr_hb_out;
   
   // I/O register file interface
   output [7:0]           sreg_fl_in;
   input                  globint;		// SREG I flag
   
   output [7:0]           sreg_fl_wr_en;		//FLAGS WRITE ENABLE SIGNALS       
   
   input [7:0]            spl_out;
   input [7:0]            sph_out;
   output                 sp_ndown_up;		// DIRECTION OF CHANGING OF STACK POINTER SPH:SPL 0->UP(+) 1->DOWN(-)
   output                 sp_en;		// WRITE ENABLE(COUNT ENABLE) FOR SPH AND SPL REGISTERS
   
   input [7:0]            rampz_out;
   
   // Bit processor interface
   output [2:0]           bit_num_r_io;		// BIT NUMBER FOR CBI/SBI/BLD/BST/SBRS/SBRC/SBIC/SBIS INSTRUCTIONS
   input [7:0]            bitpr_io_out;		// SBI/CBI OUT        
   output [2:0]           branch;		// NUMBER (0..7) OF BRANCH CONDITION FOR BRBS/BRBC INSTRUCTION
   input [7:0]            bit_pr_sreg_out;		// BCLR/BSET/BST(T-FLAG ONLY)             
   input [7:0]            bld_op_out;		// BLD OUT (T FLAG)
   input                  bit_test_op_out;		// OUTPUT OF SBIC/SBIS/SBRS/SBRC
   
   output                 sbi_st_out;
   output                 cbi_st_out;
   
   output                 idc_bst_out;
   output                 idc_bset_out;
   output                 idc_bclr_out;
   
   output                 idc_sbic_out;
   output                 idc_sbis_out;
   
   output                 idc_sbrs_out;
   output                 idc_sbrc_out;
   
   output                 idc_brbs_out;
   output                 idc_brbc_out;
   
   output                 idc_reti_out;
   
   // Multipler i/f
   output                 fmul;		// FMUL/FMULS/FMULSU
   output                 muls;		// MULS/FMULS
   output                 mulsu;		// MULSU/FMULSU
   input [15:0]           mr_out;
   input                  mc_out;		// C flag
   input                  mz_out;		// Z flag
   // SPM support
   output                 spm_inst;
   input                  spm_wait;
   // Devices with 22 bit PC
   input [5:0]            eind_out;
   
   // COPIES OF OUTPUTS
   wire [15:0]            ramadr_reg_in;		// INPUT OF THE ADDRESS REGISTER
   wire                   ramadr_reg_en;		// ADRESS REGISTER CLOCK ENABLE SIGNAL
   
   reg                    irqack_int_current;
   reg [4:0]              irqackad_int_current;
   
   // ####################################################
   // INTERNAL SIGNALS
   // ####################################################
   
   // NEW SIGNALS
   wire                   two_word_inst;		// CALL/JMP/STS/LDS INSTRUCTION INDICATOR
   
   // Constants
   localparam  const_ram_to_reg  = 11'b00000000000;	     // LD/LDS/LDD/ST/STS/STD ADDRESSING GENERAL PURPOSE REGISTER (R0-R31) 0x00..0x19
   localparam  const_ram_to_io_a = 11'b00000000001;	     // LD/LDS/LDD/ST/STS/STD ADDRESSING GENERAL I/O PORT 0x20 0x3F 
   localparam  const_ram_to_io_b = 11'b00000000010;	     // LD/LDS/LDD/ST/STS/STD ADDRESSING GENERAL I/O PORT 0x20 0x3F 
   
   // LD/LDD/ST/STD SIGNALS
   wire [4:0]             adiw_sbiw_encoder_out;
   reg [4:0]              adiw_sbiw_encoder_mux_out_current;
   
   // PROGRAM COUNTER SIGNALS
   reg [15:0]             program_counter_tmp_current;		// TO STORE PC DURING LPM/ELPM INSTRUCTIONS
   wire [15:0]            program_counter;
   wire [15:0]            program_counter_in;
   reg [7:0]              program_counter_high_fr_current;		// TO STORE PC FOR CALL,IRQ,RCALL,ICALL
   
   reg [7:0]              pc_low_current;
   reg [7:0]              pc_high_current;
   
   wire                   pc_low_en;
   wire                   pc_high_en;
   
   wire [15:0]            offset_brbx;		// OFFSET FOR BRCS/BRCC   INSTRUCTION  !!CHECKED
   wire [15:0]            offset_rxx;		// OFFSET FOR RJMP/RCALL  INSTRUCTION  !!CHECKED
   
   wire                   pa15_pm;		// ADDRESS LINE 15 FOR LPM/ELPM INSTRUCTIONS ('0' FOR LPM,RAMPZ(0) FOR ELPM) 
   
   wire                   alu_reg_wr;		// ALU INSTRUCTIONS PRODUCING WRITE TO THE GENERAL PURPOSE REGISTER FILE	
   
   // DATA MEMORY,GENERAL PURPOSE REGISTERS AND I/O REGISTERS LOGIC
   
   //! IMPORTANT NOTICE : OPERATIONS WHICH USE STACK POINTER (SPH:SPL) CAN NOT ACCCSESS GENERAL
   // PURPOSE REGISTER FILE AND INPUT/OUTPUT REGISTER FILE !
   // THESE OPERATIONS ARE : RCALL/ICALL/CALL/RET/RETI/PUSH/POP INSTRUCTIONS  AND INTERRUPT 
   
   reg                    reg_file_adr_space_current;		// ACCSESS TO THE REGISTER FILE
   reg                    io_file_adr_space_current;		// ACCSESS TO THE I/O FILE
   
   // STATE MACHINES SIGNALS
   wire                   irq_start;
   
   reg                    nirq_st0_current;
   reg                    irq_st1_current;
   reg                    irq_st2_current;
   reg                    irq_st3_current;
   
   reg                    ncall_st0_current;
   reg                    call_st1_current;
   reg                    call_st2_current;
   reg                    call_st3_current;
   
   reg                    nrcall_st0_current;
   reg                    rcall_st1_current;
   reg                    rcall_st2_current;
   
   reg                    nicall_st0_current;
   reg                    icall_st1_current;
   reg                    icall_st2_current;
   
   reg                    njmp_st0_current;
   reg                    jmp_st1_current;
   reg                    jmp_st2_current;
   
   reg                    ijmp_st_current;
   
   reg                    rjmp_st_current;
   
   reg                    nret_st0_current;
   reg                    ret_st1_current;
   reg                    ret_st2_current;
   reg                    ret_st3_current;
   
   reg                    nreti_st0_current;
   reg                    reti_st1_current;
   reg                    reti_st2_current;
   reg                    reti_st3_current;
   
   reg                    brxx_st_current;		// BRANCHES
   
   reg                    adiw_st_current;
   reg                    sbiw_st_current;
   
   reg                    nskip_inst_st0_current;
   reg                    skip_inst_st1_current;
   reg                    skip_inst_st2_current;		// ALL SKIP INSTRUCTIONS SBRS/SBRC/SBIS/SBIC/CPSE 
   
   wire                   skip_inst_start;
   
   reg                    nlpm_st0_current;
   reg                    lpm_st1_current;
   reg                    lpm_st2_current;
   
   //signal nelpm_st0      : std_logic;
   //signal elpm_st1_current       : std_logic;
   //signal elpm_st2_current       : std_logic;
   
   //signal nsts_st_current0       : std_logic;
   //signal sts_st_current1        : std_logic;
   //signal sts_st_current2        : std_logic;
   
   reg                    sts_st_current;
   
   //signal nlds_st_current0       : std_logic;
   //signal lds_st_current1        : std_logic;
   //signal lds_st_current2        : std_logic;
   
   reg                    lds_st_current;
   
   reg                    st_st_current;
   reg                    ld_st_current;
   
   reg                    sbi_st_current;
   reg                    cbi_st_current;
   
   reg                    push_st_current;
   reg                    pop_st_current;
   
   // INTERNAL STATE MACHINES
   wire                   nop_insert_st;
   wire                   cpu_busy;
   
   // INTERNAL COPIES OF OUTPUTS
   wire [5:0]             adr_int;
   wire                   iore_int;
   wire                   iowe_int;
   reg [15:0]             ramadr_int_current;
   reg                    ramre_int_current;
   reg                    ramwe_int_current;
   wire [7:0]             dbusout_int;
   
   // COMMAND REGISTER
   reg [15:0]             instruction_reg_current;		// OUTPUT OF THE INSTRUCTION REGISTER
   wire [15:0]            instruction_code_reg;		// OUTPUT OF THE INSTRUCTION REGISTER WITH NOP INSERTION
   
   // IRQ INTERNAL LOGIC
   wire                   irq_int;
   //wire [15:0]            irq_vector_adr;
   reg[15:0]              irq_vector_adr;
   
   // INTERRUPT RELATING REGISTERS
   reg [15:0]             pc_for_interrupt_current;
   
   // DATA EXTRACTOR SIGNALS
   wire [7:0]             dex_dat8_immed;		// IMMEDIATE CONSTANT (DATA) -> ANDI,ORI,SUBI,SBCI,CPI,LDI
   wire [5:0]             dex_dat6_immed;		// IMMEDIATE CONSTANT (DATA) -> ADIW,SBIW
   wire [11:0]            dex_adr12mem_s;		// RELATIVE ADDRESS (SIGNED) -> RCALL,RJMP
   wire [5:0]             dex_adr6port;		// I/O PORT ADDRESS -> IN,OUT
   wire [4:0]             dex_adr5port;		// I/O PORT ADDRESS -> CBI,SBI,SBIC,SBIS
   wire [5:0]             dex_adr_disp;		// DISPLACEMENT FO ADDDRESS -> STD,LDD
   wire [2:0]             dex_condition;		// CONDITION -> BRBC,BRBS
   wire [2:0]             dex_bitnum_sreg;		// NUMBER OF BIT IN SREG -> BCLR,BSET
   wire [4:0]             dex_adrreg_r;		// SOURCE REGISTER ADDRESS -> .......
   wire [4:0]             dex_adrreg_d;		// DESTINATION REGISTER ADDRESS -> ......
   wire [2:0]             dex_bitop_bitnum;		// NUMBER OF BIT FOR BIT ORIENTEDE OPERATION -> BST/BLD+SBI/CBI+SBIC/SBIS+SBRC/SBRS !! CHECKED
   wire [6:0]             dex_brxx_offset;		// RELATIVE ADDRESS (SIGNED) -> BRBC,BRBS !! CHECKED
   wire [1:0]             dex_adiw_sbiw_reg_adr;		// ADDRESS OF THE LOW REGISTER FOR ADIW/SBIW INSTRUCTIONS
   
   reg [4:0]              dex_adrreg_d_latched_current;		//  STORE ADDRESS OF DESTINATION REGISTER FOR LDS/STS/POP INSTRUCTIONS
   reg [7:0]              gp_reg_tmp_current;		//  STORE DATA FROM THE REGISTERS FOR STS,ST INSTRUCTIONS
   reg [4:0]              cbi_sbi_io_adr_tmp_current;		//  STORE ADDRESS OF I/O PORT FOR CBI/SBI INSTRUCTION
   reg [2:0]              cbi_sbi_bit_num_tmp_current;		//  STORE ADDRESS OF I/O PORT FOR CBI/SBI INSTRUCTION
   
   // INSTRUCTIONS DECODER SIGNALS
   
   wire                   idc_adc;		// INSTRUCTION ADC
   wire                   idc_add;		// INSTRUCTION ADD
   wire                   idc_adiw;		// INSTRUCTION ADIW
   wire                   idc_and;		// INSTRUCTION AND
   wire                   idc_andi;		// INSTRUCTION ANDI
   wire                   idc_asr;		// INSTRUCTION ASR
   
   wire                   idc_bclr;		// INSTRUCTION BCLR
   wire                   idc_bld;		// INSTRUCTION BLD
   wire                   idc_brbc;		// INSTRUCTION BRBC
   wire                   idc_brbs;		// INSTRUCTION BRBS
   wire                   idc_bset;		// INSTRUCTION BSET
   wire                   idc_bst;		// INSTRUCTION BST
   
   wire                   idc_call;		// INSTRUCTION CALL
   wire                   idc_cbi;		// INSTRUCTION CBI
   wire                   idc_com;		// INSTRUCTION COM
   wire                   idc_cp;		// INSTRUCTION CP
   wire                   idc_cpc;		// INSTRUCTION CPC
   wire                   idc_cpi;		// INSTRUCTION CPI
   wire                   idc_cpse;		// INSTRUCTION CPSE
   
   wire                   idc_dec;		// INSTRUCTION DEC
   
   wire                   idc_elpm;		// INSTRUCTION ELPM
   wire                   idc_eor;		// INSTRUCTION EOR
   
   wire                   idc_icall;		// INSTRUCTION ICALL
   wire                   idc_ijmp;		// INSTRUCTION IJMP
   
   wire                   idc_in;		// INSTRUCTION IN
   wire                   idc_inc;		// INSTRUCTION INC
   
   wire                   idc_jmp;		// INSTRUCTION JMP
   
   wire                   idc_ld_x;		// INSTRUCTION LD Rx,X ; LD Rx,X+ ;LD Rx,-X
   wire                   idc_ld_y;		// INSTRUCTION LD Rx,Y ; LD Rx,Y+ ;LD Rx,-Y
   wire                   idc_ldd_y;		// INSTRUCTION LDD Rx,Y+q
   wire                   idc_ld_z;		// INSTRUCTION LD Rx,Z ; LD Rx,Z+ ;LD Rx,-Z
   wire                   idc_ldd_z;		// INSTRUCTION LDD Rx,Z+q
   
   wire                   idc_ldi;		// INSTRUCTION LDI
   wire                   idc_lds;		// INSTRUCTION LDS
   wire                   idc_lpm;		// INSTRUCTION LPM
   wire                   idc_lsr;		// INSTRUCTION LSR
   
   wire                   idc_mov;		// INSTRUCTION MOV
   //signal idc_mul     : std_logic; -- INSTRUCTION MUL
   
   wire                   idc_neg;		// INSTRUCTION NEG
   wire                   idc_nop;		// INSTRUCTION NOP
   
   wire                   idc_or;		// INSTRUCTION OR
   wire                   idc_ori;		// INSTRUCTION ORI
   wire                   idc_out;		// INSTRUCTION OUT
   
   wire                   idc_pop;		// INSTRUCTION POP
   wire                   idc_push;		// INSTRUCTION PUSH
   
   wire                   idc_rcall;		// INSTRUCTION RCALL
   wire                   idc_ret;		// INSTRUCTION RET
   wire                   idc_reti;		// INSTRUCTION RETI
   wire                   idc_rjmp;		// INSTRUCTION RJMP
   wire                   idc_ror;		// INSTRUCTION ROR
   
   wire                   idc_sbc;		// INSTRUCTION SBC
   wire                   idc_sbci;		// INSTRUCTION SBCI
   wire                   idc_sbi;		// INSTRUCTION SBI
   wire                   idc_sbic;		// INSTRUCTION SBIC
   wire                   idc_sbis;		// INSTRUCTION SBIS
   wire                   idc_sbiw;		// INSTRUCTION SBIW
   wire                   idc_sbrc;		// INSTRUCTION SBRC
   wire                   idc_sbrs;		// INSTRUCTION SBRS
   wire                   idc_sleep;		// INSTRUCTION SLEEP
   
   wire                   idc_st_x;		// INSTRUCTION LD X,Rx ; LD X+,Rx ;LD -X,Rx
   wire                   idc_st_y;		// INSTRUCTION LD Y,Rx ; LD Y+,Rx ;LD -Y,Rx
   wire                   idc_std_y;		// INSTRUCTION LDD Y+q,Rx
   wire                   idc_st_z;		// INSTRUCTION LD Z,Rx ; LD Z+,Rx ;LD -Z,Rx
   wire                   idc_std_z;		// INSTRUCTION LDD Z+q,Rx
   
   wire                   idc_sts;		// INSTRUCTION STS
   wire                   idc_sub;		// INSTRUCTION SUB
   wire                   idc_subi;		// INSTRUCTION SUBI
   wire                   idc_swap;		// INSTRUCTION SWAP
   
   wire                   idc_wdr;		// INSTRUCTION WDR
   
   // ADDITIONAL SIGNALS
   wire                   idc_psinc;		// POST INCREMENT FLAG FOR LD,ST INSTRUCTIONS
   wire                   idc_prdec;		// PRE DECREMENT  FLAG FOR LD,ST INSTRUCTIONS
   
   // Extended instruction set (Mega128)	
   wire                   idc_lpm_ext;
   wire                   idc_elpm_ext;
   wire                   lpm_e_ext_post_inc;
   
   wire                   idc_movw;
   wire                   idc_spm;
   
   wire                   idc_mul;
   wire                   idc_muls;
   wire                   idc_mulsu;
   wire                   idc_fmul;
   wire                   idc_fmuls;
   wire                   idc_fmulsu;
   
   // State machines
   reg                    nlpm_e_st0_current;
   reg                    lpm_e_st1_current;
   reg                    lpm_e_st2_current;
   
   reg                    reg_z_out_lsb_rg_current;		// For LMP/ELPM and LMP/ELPM Extended
   
   reg                    mul_st_current;		// MUL   
   reg                    muls_st_current;		// MULS
   reg                    xmulx_st_current;		// MULSU + FMUL/FMULS/FMULSU
   reg                    fmulx_st_current;		// FMUL/FMULS/FMULSU
   
   //signal spm_st             : std_logic; 
   reg                    nspm_st0_current;
   reg                    spm_st1_current;
   reg                    spm_st2_current;
   
   // Extended instruction set (Mega128)	
   
`ifdef C_DBG_XMEGA
   // 22-bit devices
   wire                   idc_eicall;
   wire                   idc_eijmp;
   wire                   n_eicall_st0;
   wire                   eicall_st1_current;
   wire                   eicall_st2_current;
   wire                   eicall_st3_current;
   wire                   eijmp_st;
   
   // ???
   wire                   idc_espm;
   // ???
`endif  
   
   // ##################################################
   
   wire [7:0]             sreg_bop_wr_en;
   
   wire                   sreg_adr_eq;
   
   parameter P_SREG_Address = 6'h3F; // Conversion -> must be checked
   
   // Alias replacement
   wire sreg_c_wr_en  ; // sreg_fl_wr_en(0)
   wire sreg_z_wr_en  ; // sreg_fl_wr_en(1)
   wire sreg_n_wr_en  ; // sreg_fl_wr_en(2)
   wire sreg_v_wr_en  ; // sreg_fl_wr_en(3)
   wire sreg_s_wr_en  ; // sreg_fl_wr_en(4)
   wire sreg_h_wr_en  ; // sreg_fl_wr_en(5)
   wire sreg_t_wr_en  ; // sreg_fl_wr_en(6)
   wire sreg_i_wr_en  ; // sreg_fl_wr_en(7)

   // &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
   
   // SREG FLAGS WRITE ENABLE SIGNALS
   // Added for VHDL alias replacement
   assign sreg_fl_wr_en[0] = sreg_c_wr_en;
   assign sreg_fl_wr_en[1] = sreg_z_wr_en;
   assign sreg_fl_wr_en[2] = sreg_n_wr_en;
   assign sreg_fl_wr_en[3] = sreg_v_wr_en;
   assign sreg_fl_wr_en[4] = sreg_s_wr_en;
   assign sreg_fl_wr_en[5] = sreg_h_wr_en;
   assign sreg_fl_wr_en[6] = sreg_t_wr_en;
   assign sreg_fl_wr_en[7] = sreg_i_wr_en;
   //********************************************************

   
   // TWO WORDS INSTRUCTION DETECTOR (CONNECTED DIRECTLY TO THE INSTRUCTION REGISTER)
   // CALL
   // JMP
   // LDS
   assign two_word_inst = ((({instruction_reg_current[15:9], instruction_reg_current[3:1]} == 10'b1001010111) | ({instruction_reg_current[15:9], instruction_reg_current[3:1]} == 10'b1001010110)) | ({instruction_reg_current[15:9], instruction_reg_current[3:0]} == 11'b10010000000) | ({instruction_reg_current[15:9], instruction_reg_current[3:0]} == 11'b10010010000)) ? 1'b1 : 		// STS
                          1'b0;		// TO DETECT CALL/JMP/LDS/STS INSTRUCTIONS FOR SBRS/SBRC/SBIS/SBIC/CPSE
   
   // DATA EXTRACTOR (CONNECTED DIRECTLY TO THE INSTRUCTION REGISTER)
   assign dex_dat8_immed = {instruction_reg_current[11:8], instruction_reg_current[3:0]};
   assign dex_dat6_immed = {instruction_reg_current[7:6], instruction_reg_current[3:0]};
   assign dex_adr12mem_s = instruction_reg_current[11:0];
   assign dex_adr6port = {instruction_reg_current[10:9], instruction_reg_current[3:0]};
   assign dex_adr5port = instruction_reg_current[7:3];
   assign dex_adr_disp = {instruction_reg_current[13], instruction_reg_current[11:10], instruction_reg_current[2:0]};
   assign dex_condition = instruction_reg_current[2:0];
   assign dex_bitop_bitnum = instruction_reg_current[2:0];		// NUMBER(POSITION) OF TESTING BIT IN SBRC/SBRS/SBIC/SBIS INSTRUCTION
   assign dex_bitnum_sreg = instruction_reg_current[6:4];
   assign dex_adrreg_r = {instruction_reg_current[9], instruction_reg_current[3:0]};
   assign dex_adrreg_d = instruction_reg_current[8:4];
   assign dex_brxx_offset = instruction_reg_current[9:3];		// OFFSET FOR BRBC/BRBS     
   assign dex_adiw_sbiw_reg_adr = instruction_reg_current[5:4];		// ADDRESS OF THE LOW REGISTER FOR ADIW/SBIW INSTRUCTIONS
   //dex_adrindreg <= instruction_reg_current(3 downto 2);     
   
   
   // +++++++++++++++++++++++++++++++++++++++++++++++++
   
   // R24:R25/R26:R27/R28:R29/R30:R31 ADIW/SBIW  ADDRESS CONTROL LOGIC
   assign adiw_sbiw_encoder_out = {2'b11, dex_adiw_sbiw_reg_adr, 1'b0};
   
  
   // ##########################
   
   // NOP INSERTION
   
   //instruction_code_reg <= instruction_reg_current when nop_insert_st='0' else (others => '0');
   assign instruction_code_reg = ((nop_insert_st == 1'b1 | insert_nop == 1'b1)) ? {16{1'b0}} : 		// NOP
                                 instruction_reg_current;		// Instruction 
   
   // Extended instruction set
   assign nop_insert_st = adiw_st_current | sbiw_st_current | cbi_st_current | sbi_st_current | rjmp_st_current | ijmp_st_current | pop_st_current | push_st_current | brxx_st_current | ld_st_current | st_st_current | ncall_st0_current | nirq_st0_current | nret_st0_current | nreti_st0_current | nlpm_st0_current | njmp_st0_current | nrcall_st0_current | nicall_st0_current | sts_st_current | lds_st_current | nskip_inst_st0_current | nlpm_e_st0_current | (mul_st_current | muls_st_current | xmulx_st_current) | nspm_st0_current;
   
   // INSTRUCTION DECODER (CONNECTED AFTER NOP INSERTION LOGIC)
   
   assign idc_adc = (instruction_code_reg[15:10] == 6'b000111) ? 1'b1 : 		// 000111XXXXXXXXXX
                    1'b0;
   assign idc_add = (instruction_code_reg[15:10] == 6'b000011) ? 1'b1 : 		// 000011XXXXXXXXXX
                    1'b0;
   
   assign idc_adiw = (instruction_code_reg[15:8] == 8'b10010110) ? 1'b1 : 		// 10010110XXXXXXXX
                     1'b0;
   
   assign idc_and = (instruction_code_reg[15:10] == 6'b001000) ? 1'b1 : 		// 001000XXXXXXXXXX
                    1'b0;
   assign idc_andi = (instruction_code_reg[15:12] == 4'b0111) ? 1'b1 : 		// 0111XXXXXXXXXXXX
                     1'b0;
   
   assign idc_asr = ({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010100101) ? 1'b1 : 		// 1001010XXXXX0101
                    1'b0;
   
   assign idc_bclr = ({instruction_code_reg[15:7], instruction_code_reg[3:0]} == 13'b1001010011000) ? 1'b1 : 		// 100101001XXX1000
                     1'b0;
   
   assign idc_bld = ({instruction_code_reg[15:9], instruction_code_reg[3]} == 8'b11111000) ? 1'b1 : 		// 1111100XXXXX0XXX
                    1'b0;
   
   assign idc_brbc = (instruction_code_reg[15:10] == 6'b111101) ? 1'b1 : 		// 111101XXXXXXXXXX
                     1'b0;
   assign idc_brbs = (instruction_code_reg[15:10] == 6'b111100) ? 1'b1 : 		// 111100XXXXXXXXXX
                     1'b0;
   
   assign idc_bset = ({instruction_code_reg[15:7], instruction_code_reg[3:0]} == 13'b1001010001000) ? 1'b1 : 		// 100101000XXX1000
                     1'b0;
   
   assign idc_bst = (instruction_code_reg[15:9] == 7'b1111101) ? 1'b1 : 		// 1111101XXXXXXXXX
                    1'b0;
   
   assign idc_call = ({instruction_code_reg[15:9], instruction_code_reg[3:1]} == 10'b1001010111) ? 1'b1 : 		// 1001010XXXXX111X
                     1'b0;
   
   assign idc_cbi = (instruction_code_reg[15:8] == 8'b10011000) ? 1'b1 : 		// 10011000XXXXXXXX
                    1'b0;
   
   assign idc_com = ({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010100000) ? 1'b1 : 		// 1001010XXXXX0000
                    1'b0;
   
   assign idc_cp = (instruction_code_reg[15:10] == 6'b000101) ? 1'b1 : 		// 000101XXXXXXXXXX
                   1'b0;
   
   assign idc_cpc = (instruction_code_reg[15:10] == 6'b000001) ? 1'b1 : 		// 000001XXXXXXXXXX
                    1'b0;
   
   assign idc_cpi = (instruction_code_reg[15:12] == 4'b0011) ? 1'b1 : 		// 0011XXXXXXXXXXXX
                    1'b0;
   
   assign idc_cpse = (instruction_code_reg[15:10] == 6'b000100) ? 1'b1 : 		// 000100XXXXXXXXXX
                     1'b0;
   
   assign idc_dec = ({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010101010) ? 1'b1 : 		// 1001010XXXXX1010
                    1'b0;
   
   assign idc_elpm = (instruction_code_reg == 16'b1001010111011000) ? 1'b1 : 		// 1001010111011000
                     1'b0;
   
   assign idc_eor = (instruction_code_reg[15:10] == 6'b001001) ? 1'b1 : 		// 001001XXXXXXXXXX
                    1'b0;
   
   assign idc_icall = ({instruction_code_reg[15:8], instruction_code_reg[3:0]} == 12'b100101011001) ? 1'b1 : 		// 10010101XXXX1001
                      1'b0;
   
   assign idc_ijmp = ({instruction_code_reg[15:8], instruction_code_reg[3:0]} == 12'b100101001001) ? 1'b1 : 		// 10010100XXXX1001
                     1'b0;
   
   assign idc_in = (instruction_code_reg[15:11] == 5'b10110) ? 1'b1 : 		// 10110XXXXXXXXXXX
                   1'b0;
   
   assign idc_inc = ({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010100011) ? 1'b1 : 		// 1001010XXXXX0011
                    1'b0;
   
   assign idc_jmp = ({instruction_code_reg[15:9], instruction_code_reg[3:1]} == 10'b1001010110) ? 1'b1 : 		// 1001010XXXXX110X
                    1'b0;
   
   // LD,LDD 
   assign idc_ld_x = ({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010001100 | {instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010001101 | {instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010001110) ? 1'b1 : 
                     1'b0;
   
   assign idc_ld_y = (({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010001001 | {instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010001010)) ? 1'b1 : 
                     1'b0;
   
   assign idc_ldd_y = ({instruction_code_reg[15:14], instruction_code_reg[12], instruction_code_reg[9], instruction_code_reg[3]} == 5'b10001) ? 1'b1 : 		// 10X0XX0XXXXX1XXX    
                      1'b0;
   
   assign idc_ld_z = (({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010000001 | {instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010000010)) ? 1'b1 : 
                     1'b0;
   
   assign idc_ldd_z = ({instruction_code_reg[15:14], instruction_code_reg[12], instruction_code_reg[9], instruction_code_reg[3]} == 5'b10000) ? 1'b1 : 		// 10X0XX0XXXXX0XXX       
                      1'b0;
   // ######
   
   assign idc_ldi = (instruction_code_reg[15:12] == 4'b1110) ? 1'b1 : 		// 1110XXXXXXXXXXXX
                    1'b0;
   
   assign idc_lds = ({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010000000) ? 1'b1 : 		// 1001000XXXXX0000
                    1'b0;
   
   assign idc_lpm = (instruction_code_reg == 16'b1001010111001000) ? 1'b1 : 		// 1001010111001000
                    1'b0;
   
   assign idc_lsr = ({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010100110) ? 1'b1 : 		// 1001010XXXXX0110
                    1'b0;
   
   assign idc_mov = (instruction_code_reg[15:10] == 6'b001011) ? 1'b1 : 		// 001011XXXXXXXXXX
                    1'b0;
   
   //idc_mul <= '1' when instruction_code_reg(15 downto 10) = "100111" else '0'; -- 100111XXXXXXXXXX
   
   assign idc_neg = ({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010100001) ? 1'b1 : 		// 1001010XXXXX0001
                    1'b0;
   
   assign idc_nop = (instruction_code_reg == 16'b0000000000000000) ? 1'b1 : 		// 0000000000000000
                    1'b0;
   
   assign idc_or = (instruction_code_reg[15:10] == 6'b001010) ? 1'b1 : 		// 001010XXXXXXXXXX
                   1'b0;
   
   assign idc_ori = (instruction_code_reg[15:12] == 4'b0110) ? 1'b1 : 		// 0110XXXXXXXXXXXX 
                    1'b0;
   
   assign idc_out = (instruction_code_reg[15:11] == 5'b10111) ? 1'b1 : 		// 10111XXXXXXXXXXX
                    1'b0;
   
   assign idc_pop = ({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010001111) ? 1'b1 : 		// 1001000XXXXX1111
                    1'b0;
   
   assign idc_push = ({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010011111) ? 1'b1 : 		// 1001001XXXXX1111
                     1'b0;
   
   assign idc_rcall = (instruction_code_reg[15:12] == 4'b1101) ? 1'b1 : 		// 1101XXXXXXXXXXXX
                      1'b0;
   
   assign idc_ret = ({instruction_code_reg[15:7], instruction_code_reg[4:0]} == 14'b10010101001000) ? 1'b1 : 		// 100101010XX01000
                    1'b0;
   
   assign idc_reti = ({instruction_code_reg[15:7], instruction_code_reg[4:0]} == 14'b10010101011000) ? 1'b1 : 		// 100101010XX11000
                     1'b0;
   
   assign idc_rjmp = (instruction_code_reg[15:12] == 4'b1100) ? 1'b1 : 		// 1100XXXXXXXXXXXX
                     1'b0;
   
   assign idc_ror = ({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010100111) ? 1'b1 : 		// 1001010XXXXX0111
                    1'b0;
   
   assign idc_sbc = (instruction_code_reg[15:10] == 6'b000010) ? 1'b1 : 		// 000010XXXXXXXXXX
                    1'b0;
   
   assign idc_sbci = (instruction_code_reg[15:12] == 4'b0100) ? 1'b1 : 		// 0100XXXXXXXXXXXX
                     1'b0;
   
   assign idc_sbi = (instruction_code_reg[15:8] == 8'b10011010) ? 1'b1 : 		// 10011010XXXXXXXX
                    1'b0;
   
   assign idc_sbic = (instruction_code_reg[15:8] == 8'b10011001) ? 1'b1 : 		// 10011001XXXXXXXX
                     1'b0;
   
   assign idc_sbis = (instruction_code_reg[15:8] == 8'b10011011) ? 1'b1 : 		// 10011011XXXXXXXX
                     1'b0;
   
   assign idc_sbiw = (instruction_code_reg[15:8] == 8'b10010111) ? 1'b1 : 		// 10010111XXXXXXXX
                     1'b0;
   
   assign idc_sbrc = (instruction_code_reg[15:9] == 7'b1111110) ? 1'b1 : 		// 1111110XXXXXXXXX
                     1'b0;
   
   assign idc_sbrs = (instruction_code_reg[15:9] == 7'b1111111) ? 1'b1 : 		// 1111111XXXXXXXXX
                     1'b0;
   
   assign idc_sleep = ({instruction_code_reg[15:5], instruction_code_reg[3:0]} == 15'b100101011001000) ? 1'b1 : 		// 10010101100X1000
                      1'b0;
   
   // ST,STD
   assign idc_st_x = ({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010011100 | {instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010011101 | {instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010011110) ? 1'b1 : 
                     1'b0;
   
   assign idc_st_y = (({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010011001 | {instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010011010)) ? 1'b1 : 
                     1'b0;
   
   assign idc_std_y = ({instruction_code_reg[15:14], instruction_code_reg[12], instruction_code_reg[9], instruction_code_reg[3]} == 5'b10011) ? 1'b1 : 		// 10X0XX1XXXXX1XXX    
                      1'b0;
   
   assign idc_st_z = (({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010010001 | {instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010010010)) ? 1'b1 : 
                     1'b0;
   
   assign idc_std_z = ({instruction_code_reg[15:14], instruction_code_reg[12], instruction_code_reg[9], instruction_code_reg[3]} == 5'b10010) ? 1'b1 : 		// 10X0XX1XXXXX0XXX 
                      1'b0;
   // ######
   
   assign idc_sts = ({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010010000) ? 1'b1 : 		// 1001001XXXXX0000
                    1'b0;
   
   assign idc_sub = (instruction_code_reg[15:10] == 6'b000110) ? 1'b1 : 		// 000110XXXXXXXXXX
                    1'b0;
   
   assign idc_subi = (instruction_code_reg[15:12] == 4'b0101) ? 1'b1 : 		// 0101XXXXXXXXXXXX
                     1'b0;
   
   assign idc_swap = ({instruction_code_reg[15:9], instruction_code_reg[3:0]} == 11'b10010100010) ? 1'b1 : 		// 1001010XXXXX0010
                     1'b0;
   
   assign idc_wdr = ({instruction_code_reg[15:5], instruction_code_reg[3:0]} == 15'b100101011011000) ? 1'b1 : 		// 10010101101X1000
                    1'b0;
   
   // ADDITIONAL SIGNALS
   assign idc_psinc = ((instruction_code_reg[1:0] == 2'b01 & (idc_st_x | idc_st_y | idc_st_z | idc_ld_x | idc_ld_y | idc_ld_z) == 1'b1)) ? 1'b1 : 		// POST INCREMENT FOR LD/ST INSTRUCTIONS
                      1'b0;
   
   assign idc_prdec = ((instruction_code_reg[1:0] == 2'b10 & (idc_st_x | idc_st_y | idc_st_z | idc_ld_x | idc_ld_y | idc_ld_z) == 1'b1)) ? 1'b1 : 		// PRE DECREMENT FOR LD/ST INSTRUCTIONS 
                      1'b0;
   
   // Extended instruction set (Mega128)
   
   // (ii)LPM Rd, Z               0 ? d ? 31                   
   // (iii)LPM Rd, Z+             0 ? d ? 31                  
   assign idc_lpm_ext = ((instruction_code_reg[15:9] == 7'b1001000 & instruction_code_reg[3:1] == 3'b010)) ? 1'b1 : 		// (ii)LPM Rd, Z / 
                        1'b0;
   // (iii)LPM Rd, Z+ -> -- 1001000ddddd010x 
   assign lpm_e_ext_post_inc = (instruction_code_reg[0] == 1'b1) ? 1'b1 : 		// (iii)LPM Rd, Z+ / (iii)ELPM Rd, Z+
                               1'b0;
   
   // (ii) ELPM Rd, Z     0 ? d ? 31                              
   // (iii) ELPM Rd, Z+    0 ? d ? 31                              
   assign idc_elpm_ext = ((instruction_code_reg[15:9] == 7'b1001000 & instruction_code_reg[3:1] == 3'b011)) ? 1'b1 : 		// ELPM Rd, Z / -- ELPM Rd, Z+ -> 1001000ddddd011x
                         1'b0;
   
   // (i) MOVW Rd+1:Rd,Rr+1Rr        d E {0,2,...,30}, r E {0,2,...,30}    
   assign idc_movw = ((instruction_code_reg[15:8] == 8'b00000001)) ? 1'b1 : 		// (i) MOVW Rd+1:Rd,Rr+1Rr -> 00000001ddddrrrr
                     1'b0;
   
   // SPM - Store Program Memory 
   assign idc_spm = ((instruction_code_reg == 16'b1001010111101000)) ? 1'b1 : 		// SPM -> "1001010111101000" !!! Multifunctional instruction
                    1'b0;
   
   // Multiplications
   //  MUL Rd,Rr    0 ? d ? 31, 0 ? r ? 31    
   assign idc_mul = ((instruction_code_reg[15:10] == 6'b100111)) ? 1'b1 : 		// MUL Rd,Rr -> 100111rdddddrrrr
                    1'b0;
   
   // MULS Rd,Rr       16 ? d ? 31, 16 ? r ? 31
   assign idc_muls = ((instruction_code_reg[15:8] == 8'b00000010)) ? 1'b1 : 		// MULS Rd,Rr -> 00000010ddddrrrr
                     1'b0;
   
   // MULSU Rd,R     r16 ? d ? 23, 16 ? r ? 23 
   assign idc_mulsu = ((instruction_code_reg[15:7] == 9'b000000110 & instruction_code_reg[3] == 1'b0)) ? 1'b1 : 		// MULSU Rd,R  -> 00000010ddddrrrr
                      1'b0;
   
   // FMUL Rd,Rr      16 ? d ? 23, 16? r ? 23
   assign idc_fmul = ((instruction_code_reg[15:7] == 9'b000000110 & instruction_code_reg[3] == 1'b1)) ? 1'b1 : 		// FMUL Rd,Rr ->  000000110ddd1rrr
                     1'b0;
   
   // FMULS Rd,Rr         16 ? d ? 23, 16? r ? 23  
   assign idc_fmuls = ((instruction_code_reg[15:7] == 9'b000000111 & instruction_code_reg[3] == 1'b0)) ? 1'b1 : 		// FMULS Rd,Rr ->  000000111ddd0rrr
                      1'b0;
   
   // FMULSU Rd,Rr          16 ? d ? 23, 16? r ? 23
   assign idc_fmulsu = ((instruction_code_reg[15:7] == 9'b000000111 & instruction_code_reg[3] == 1'b1)) ? 1'b1 : 		// FMULSU Rd,Rr ->  000000111ddd1rrr
                       1'b0;
   
   // Multiplications 
   
   // Extended instruction set (Mega128)
   
`ifdef C_DBG_XMEGA   
   // Extended instruction set (22-bit pc devices)
   // EICALL
   assign idc_eicall = ((instruction_code_reg == 16'b1001010100011001)) ? 1'b1 : 		// EICALL -> "1001010100011001" 
                       1'b0;
   
   // EIJMP	
   assign idc_eijmp = ((instruction_code_reg == 16'b1001010000011001)) ? 1'b1 : 		// EIJMP -> "1001010000011001" 	
                      1'b0;
   // Extended instruction set (22-bit pc devices)
`endif
   
   // ##########################################################################################################
   
   // WRITE ENABLE SIGNALS FOR ramadr_reg
   // LD/LDD/LDS(two cycle execution) 
   // RCALL/ICALL
   // CALL/IRQ
   assign ramadr_reg_en = idc_ld_x | idc_ld_y | idc_ldd_y | idc_ld_z | idc_ldd_z | idc_lds | idc_st_x | idc_st_y | idc_std_y | idc_st_z | idc_std_z | idc_sts | idc_push | idc_pop | idc_rcall | (rcall_st1_current & (~cpuwait)) | idc_icall | (icall_st1_current & (~cpuwait)) | call_st1_current | (call_st2_current & (~cpuwait)) | irq_st1_current | (irq_st2_current & (~cpuwait)) | idc_ret | (ret_st1_current & (~cpuwait)) | idc_reti | (reti_st1_current & (~cpuwait));		// ST/STS/STS(two cycle execution)
   // RET/RETI  -- ??
   
   // RAMADR MUX
   // CALL/IRQ
   assign ramadr_reg_in = ((idc_rcall | (rcall_st1_current & (~cpuwait)) | idc_icall | (icall_st1_current & (~cpuwait)) | call_st1_current | (call_st2_current & (~cpuwait)) | irq_st1_current | (irq_st2_current & (~cpuwait)) | idc_push) == 1'b1) ? {sph_out, spl_out} : // RCALL/ICALL/PUSH
                          ((idc_ret | (ret_st1_current & (~cpuwait)) | idc_reti | (reti_st1_current & (~cpuwait)) | idc_pop) == 1'b1) ? ({sph_out, spl_out}) + 16'd1 : 		// RET/RETI/POP
                          ((idc_lds | idc_sts) == 1'b1) ? inst : 		// LDS/STS (two cycle execution)	
                          ((idc_ld_x | idc_ld_y | idc_ld_z | idc_st_x | idc_st_y | idc_st_z) == 1'b1) ? reg_h_out : 		// LD/ST	  
                          (reg_h_out + ({9'b000000000, dex_adr_disp}));		// LDD/STD  
   
   assign ramadr = ramadr_int_current;
   
   
   // ##########################################################################################################
   
   // REGRE/REGWE LOGIC (5 BIT ADDSRESS BUS (INTERNAL ONLY) 32 LOCATIONS (R0-R31))
   
   // WRITE ENABLE FOR Rd REGISTERS 
   assign alu_reg_wr = idc_adc | idc_add | idc_adiw | adiw_st_current | idc_sub | idc_subi | idc_sbc | idc_sbci | idc_sbiw | sbiw_st_current | idc_and | idc_andi | idc_or | idc_ori | idc_eor | idc_com | idc_neg | idc_inc | idc_dec | idc_lsr | idc_ror | idc_asr | idc_swap;
   
   // ALU INSTRUCTIONS + IN/BLD INSRTRUCTION                
   // ST/STD/STS INSTRUCTION 	      
   // LPM/LDI/MOV INSTRUCTION
   // Extended instruction set
   // LPM/ELPM Extended
   assign reg_rd_wr = idc_in | alu_reg_wr | idc_bld | (pop_st_current | ld_st_current | lds_st_current) | ((st_st_current | sts_st_current) & reg_file_adr_space_current) | lpm_st2_current | idc_ldi | idc_mov | lpm_e_st2_current | idc_movw | (mul_st_current | muls_st_current | xmulx_st_current);		// POP/LD/LDD/LDS INSTRUCTIONS
   // Multiplications Extended 
   
   assign reg_rd_adr = ((idc_subi | idc_sbci | idc_andi | idc_ori | idc_cpi | idc_ldi | idc_muls) == 1'b1) ? {1'b1, dex_adrreg_d[3:0]} : 		// + MULS Extended
                       ((lpm_st2_current == 1'b1 | mul_st_current == 1'b1 | muls_st_current == 1'b1 | xmulx_st_current == 1'b1)) ? 5'b00000 : 		// + Multiplications Extendes
                       ((idc_adiw | idc_sbiw) == 1'b1) ? adiw_sbiw_encoder_out : 
                       ((adiw_st_current | sbiw_st_current) == 1'b1) ? adiw_sbiw_encoder_mux_out_current : 
                       ((((st_st_current | sts_st_current) & (~reg_file_adr_space_current)) | ld_st_current | lds_st_current | pop_st_current | lpm_e_st2_current) == 1'b1) ? dex_adrreg_d_latched_current : 		// +Extended
                       (((st_st_current | sts_st_current) & reg_file_adr_space_current) == 1'b1) ? ramadr_int_current[4:0] : 		//!!??
                       ((idc_movw == 1'b1)) ? {dex_adrreg_d[4 - 1:0], 1'b0} : 		// MOVW Extended	   
                       ((idc_mulsu == 1'b1 | idc_fmul == 1'b1 | idc_fmuls == 1'b1 | idc_fmulsu == 1'b1)) ? {2'b10, dex_adrreg_d[2:0]} : 		// MULS/FMUL/FMULS/FMULSU Extended				  				   
                       dex_adrreg_d;
   
   assign reg_rr_adr = (((ld_st_current | lds_st_current) & reg_file_adr_space_current) == 1'b1) ? ramadr_int_current[4:0] : 		//!!??
                       (((st_st_current | sts_st_current) & reg_file_adr_space_current) == 1'b1) ? dex_adrreg_d_latched_current : 		//!!??
                       ((idc_movw == 1'b1)) ? {dex_adrreg_r[3:0], 1'b0} : 		// MOVW Extended
                       ((idc_muls == 1'b1)) ? {1'b1, dex_adrreg_r[3:0]} : 		// MULS Extended	  
                       ((idc_mulsu == 1'b1 | idc_fmul == 1'b1 | idc_fmuls == 1'b1 | idc_fmulsu == 1'b1)) ? {2'b10, dex_adrreg_r[2:0]} : 		// MULS/FMUL/FMULS/FMULSU Extended				  
                       dex_adrreg_r;
   
   // MULTIPLEXER FOR REGISTER FILE Rd INPUT
   assign reg_rd_in = ((idc_in | ((lds_st_current | ld_st_current) & (~reg_file_adr_space_current)) | pop_st_current) == 1'b1) ? dbusin : 		// FROM INPUT DATA BUS
                      (((lds_st_current | ld_st_current) & reg_file_adr_space_current) == 1'b1) ? reg_rr_out : 
                      (((st_st_current | sts_st_current) & reg_file_adr_space_current) == 1'b1) ? gp_reg_tmp_current : 		// ST/STD/STS &  ADDRESS FROM 0 TO 31 (REGISTER FILE)
                      ((idc_bld == 1'b1)) ? bld_op_out : 		// FROM BIT PROCESSOR BLD COMMAND
                      ((idc_mov == 1'b1 | idc_movw == 1'b1)) ? reg_rr_out : 		// MOV/MOVW
                      (((lpm_st2_current == 1'b1 | lpm_e_st2_current == 1'b1) & reg_z_out_lsb_rg_current == 1'b1)) ? instruction_reg_current[15:8] : 		// LPM/ELPM (+Extended)
                      (((lpm_st2_current == 1'b1 | lpm_e_st2_current == 1'b1) & reg_z_out_lsb_rg_current == 1'b0)) ? instruction_reg_current[7:0] : 		// LPM/ELPM (+Extended)
                      (idc_ldi == 1'b1) ? dex_dat8_immed : 
                      ((mul_st_current == 1'b1 | muls_st_current == 1'b1 | xmulx_st_current == 1'b1)) ? mr_out[7:0] : 		// Multiplications Extended 
                      alu_data_out;		// FROM ALU DATA OUT
   
   // IORE/IOWE LOGIC (6 BIT ADDRESS adr[5..0] FOR I/O PORTS(64 LOCATIONS))
   assign iore_int = idc_in | idc_sbi | idc_cbi | idc_sbic | idc_sbis | ((ld_st_current | lds_st_current) & io_file_adr_space_current);		// IN/SBI/CBI 
   assign iowe_int = (((idc_out | sbi_st_current | cbi_st_current) | ((st_st_current | sts_st_current) & io_file_adr_space_current)) == 1'b1) ? 1'b1 : 		// OUT/SBI/CBI + !! ST/STS/STD
                     1'b0;
   
   // adr[5..0] BUS MULTIPLEXER
   assign adr_int = ((idc_in | idc_out) == 1'b1) ? dex_adr6port : 		// IN/OUT INSTRUCTIONS  
                    ((idc_cbi | idc_sbi | idc_sbic | idc_sbis) == 1'b1) ? {1'b0, dex_adr5port} : 		// CBI/SBI (READ PHASE) + SBIS/SBIC
                    ((cbi_st_current | sbi_st_current) == 1'b1) ? {1'b0, cbi_sbi_io_adr_tmp_current} : 		// CBI/SBI (WRITE PHASE)
                    {ramadr_int_current[6], ramadr_int_current[4:0]};		// LD/LDS/LDD/ST/STS/STD
   
   
   // DBUSOUT MULTIPLEXER
   generate
         genvar                 i;
         for (i = 0; i < 8; i = i + 1)
         begin : dbusout_mux_logic
            // NEW
            // CBI/SBI  INSTRUCTIONS
            // LOW  PART OF PC
            // HIGH PART OF PC
            assign dbusout_int[i] = (reg_rd_out[i] & (idc_push | idc_sts | (idc_st_x | idc_st_y | idc_std_y | idc_st_z | idc_std_z))) | (gp_reg_tmp_current[i] & (st_st_current | sts_st_current)) | (bitpr_io_out[i] & (cbi_st_current | sbi_st_current)) | (program_counter[i] & (idc_rcall | idc_icall | call_st1_current)) | (program_counter_high_fr_current[i] & (rcall_st1_current | icall_st1_current | call_st2_current)) | (pc_for_interrupt_current[i] & irq_st1_current) | (pc_for_interrupt_current[i + 8] & irq_st2_current) | (reg_rd_out[i] & idc_out);		// PUSH/ST/STD/STS INSTRUCTIONS
         end
      endgenerate
      // OUT
      
      // ALU CONNECTION
      
      // ALU Rr INPUT MUX
      assign alu_data_r_in = ((idc_subi | idc_sbci | idc_andi | idc_ori | idc_cpi) == 1'b1) ? dex_dat8_immed : 
                             ((idc_adiw | idc_sbiw) == 1'b1) ? {2'b00, dex_dat6_immed} : 
                             ((adiw_st_current | sbiw_st_current) == 1'b1) ? 8'b00000000 : 
                             reg_rr_out;
      
      // **********************************************************************************************************
      

      
      // SPM support was added 05.12.2006
      assign pa15_pm = rampz_out[0] & (idc_elpm | idc_elpm_ext | idc_spm);		// '0' WHEN LPM INSTRUCTIONS  RAMPZ(0) WHEN ELPM INSTRUCTION (+Extended)
      
      // OFFSET FOR BRBC/BRBS INSTRUCTIONS +63/-64
      assign offset_brbx = ((dex_brxx_offset[6] == 1'b0)) ? {10'b0000000000, dex_brxx_offset[5:0]} : 		// +
                           {10'b1111111111, dex_brxx_offset[5:0]};		// - 
      
      // OFFSET FOR RJMP/RCALL INSTRUCTIONS +2047/-2048
      assign offset_rxx = ((dex_adr12mem_s[11] == 1'b0)) ? {5'b00000, dex_adr12mem_s[10:0]} : 		// +
                          {5'b11111, dex_adr12mem_s[10:0]};		// -
      
      assign program_counter = {pc_high_current, pc_low_current};
      
      assign program_counter_in = (((idc_brbc | idc_brbs) & bit_test_op_out) == 1'b1) ? program_counter + offset_brbx : 		// BRBC/BRBS                  
                                  ((idc_rjmp | idc_rcall) == 1'b1) ? program_counter + offset_rxx : 		// RJMP/RCALL
                                  ((idc_ijmp | idc_icall) == 1'b1) ? reg_z_out : 		// IJMP/ICALL
                                  ((idc_lpm | idc_elpm | idc_lpm_ext | idc_elpm_ext | idc_spm) == 1'b1) ? {pa15_pm, reg_z_out[15:1]} : 		// LPM/ELPM (+ Extended) +SPM
                                  ((jmp_st1_current | call_st1_current) == 1'b1) ? instruction_reg_current : 		// JMP/CALL
                                  (irq_st1_current == 1'b1) ? {10'b0000000000, irqackad_int_current, 1'b0} : 		// INTERRUPT      
                                  ((ret_st1_current | reti_st1_current) == 1'b1) ? {dbusin, 8'b00000000} : 		// RET/RETI -> PC HIGH BYTE                  
                                  ((ret_st2_current | reti_st2_current) == 1'b1) ? {8'b00000000, dbusin} : 		// RET/RETI -> PC LOW BYTE                       
                                  ((lpm_st1_current | lpm_e_st1_current | (spm_st1_current & (~spm_wait))) == 1'b1) ? program_counter_tmp_current : 		// AFTER LPM/ELPM SPM INSTRUCTION (+ Extended)   
                                  program_counter + 16'd1;		// THE MOST USUAL CASE
      
      // Extended
      assign pc_low_en = (~(idc_ld_x | idc_ld_y | idc_ld_z | idc_ldd_y | idc_ldd_z | idc_st_x | idc_st_y | idc_st_z | idc_std_y | idc_std_z | ((sts_st_current | lds_st_current) & cpuwait) | idc_adiw | idc_sbiw | idc_push | idc_pop | idc_cbi | idc_sbi | rcall_st1_current | icall_st1_current | call_st2_current | irq_st2_current | cpuwait | ret_st1_current | reti_st1_current | (idc_mul | idc_muls | idc_mulsu | idc_fmul | idc_fmuls | idc_fmulsu) | (spm_st1_current & spm_wait)));		// Multiplications
      // SPM
      
      // Extended
      assign pc_high_en = (~(idc_ld_x | idc_ld_y | idc_ld_z | idc_ldd_y | idc_ldd_z | idc_st_x | idc_st_y | idc_st_z | idc_std_y | idc_std_z | ((sts_st_current | lds_st_current) & cpuwait) | idc_adiw | idc_sbiw | idc_push | idc_pop | idc_cbi | idc_sbi | rcall_st1_current | icall_st1_current | call_st2_current | irq_st2_current | cpuwait | ret_st2_current | reti_st2_current | (idc_mul | idc_muls | idc_mulsu | idc_fmul | idc_fmuls | idc_fmulsu) | (spm_st1_current & spm_wait)));		// Multiplications
      // SPM
      
      assign pc = program_counter;
      
      // END OF PROGRAM COUNTER 
      
      // STATE MACHINES
      
      assign skip_inst_start = ((idc_sbrc | idc_sbrs | idc_sbic | idc_sbis) & bit_test_op_out) | (idc_cpse & alu_z_flag_out);
      
      
      // INTERRUPT LOGIC AND STATE MACHINE 
      
      assign irq_int = |irqlines;
      
	always@*
	 begin : irq_vector_adr_gen
	  integer i;
	  reg[15:0] i_plus_one;
	  irq_vector_adr = {16{1'b0}};
	  for(i = irqs_width-1;i >= 0;i = i - 1) begin
	    i_plus_one = i[15:0] + 16'h1;
	    if(irqlines[i]) irq_vector_adr = {i_plus_one[14:0],1'b0};
	   end
	 end // irq_vector_adr_gen 
      
      
      // MULTI CYCLE INSTRUCTION FLAG FOR IRQ
      //			idc_brbs or idc_brbc or -- Old variant
      // RCALL
      // ICALL
      // CALL
      // PUSH (added 14.07.05)
      // POP  (added 14.07.05)
      // ??? CLI
      // ??? Writing '0' to I flag (OUT/STD/ST/STD)
      //			idc_ret  or nret_st0_current or                             -- Old variant 
      //			idc_reti or nreti_st0_current;                              -- At least one instruction must be executed after RETI and before the new interrupt.
      // Extended instructions
      // LPM/ELPM ext
      // Multiplications
      assign cpu_busy = idc_adiw | idc_sbiw | idc_cbi | idc_sbi | idc_rjmp | idc_ijmp | idc_jmp | jmp_st1_current | ((idc_brbc | idc_brbs) & bit_test_op_out) | idc_lpm | idc_elpm | lpm_st1_current | skip_inst_start | (skip_inst_st1_current & two_word_inst) | idc_ld_x | idc_ld_y | idc_ldd_y | idc_ld_z | idc_ldd_z | (ld_st_current & cpuwait) | idc_st_x | idc_st_y | idc_std_y | idc_st_z | idc_std_z | (st_st_current & cpuwait) | idc_lds | (lds_st_current & cpuwait) | idc_sts | (sts_st_current & cpuwait) | idc_rcall | rcall_st1_current | (rcall_st2_current & cpuwait) | idc_icall | icall_st1_current | (icall_st2_current & cpuwait) | idc_call | call_st1_current | call_st2_current | (call_st3_current & cpuwait) | idc_push | (push_st_current & cpuwait) | idc_pop | (pop_st_current & cpuwait) | (idc_bclr & sreg_bop_wr_en[7]) | (iowe_int & sreg_adr_eq & (~dbusout_int[7])) | nirq_st0_current | idc_ret | ret_st1_current | ret_st2_current | idc_reti | reti_st1_current | reti_st2_current | idc_lpm_ext | idc_elpm_ext | lpm_e_st1_current | (idc_mul | idc_muls | idc_mulsu | idc_fmul | idc_fmuls | idc_fmulsu) | (idc_spm | spm_st1_current);		// LPM/ELPM () 
      // SPM		
      
      assign sreg_adr_eq = (adr_int == P_SREG_Address[5:0]) ? 1'b1 : 1'b0; // Must be checked
                           
      
      //irq_start <= irq_int and not cpu_busy and globint;
      assign irq_start = irq_int & (~cpu_busy) & globint & (~block_irq);		// JTAG OCD Support
      
      assign irqack = irqack_int_current;
      
      assign irqackad = irqackad_int_current;
      
      // *******************************************************************************************
      
      // ########################################################################################
      
      // SREG FLAGS WRITE ENABLE LOGIC
      
      generate
         begin : sreg_bop_wr_en_gen
            genvar                 i;
            for (i = 0; i < 8; i = i + 1)
            begin : bclr_bset_op_en_logic
               assign sreg_bop_wr_en[i] = (dex_bitnum_sreg == i[2:0] && (idc_bclr | idc_bset) == 1'b1) ? 1'b1 : 1'b0; // Conversion -> TBD
            end
         end
         endgenerate
         
         // Extended (multiplications)
         assign sreg_c_wr_en = idc_add | idc_adc | (idc_adiw | adiw_st_current) | idc_sub | idc_subi | idc_sbc | idc_sbci | (idc_sbiw | sbiw_st_current) | idc_com | idc_neg | idc_cp | idc_cpc | idc_cpi | idc_lsr | idc_ror | idc_asr | sreg_bop_wr_en[0] | mul_st_current | muls_st_current | xmulx_st_current;
         
         // Extended	(multiplications)
         assign sreg_z_wr_en = idc_add | idc_adc | (idc_adiw | adiw_st_current) | idc_sub | idc_subi | idc_sbc | idc_sbci | (idc_sbiw | sbiw_st_current) | idc_cp | idc_cpc | idc_cpi | idc_and | idc_andi | idc_or | idc_ori | idc_eor | idc_com | idc_neg | idc_inc | idc_dec | idc_lsr | idc_ror | idc_asr | sreg_bop_wr_en[1] | mul_st_current | muls_st_current | xmulx_st_current;
         
         assign sreg_n_wr_en = idc_add | idc_adc | adiw_st_current | idc_sub | idc_subi | idc_sbc | idc_sbci | sbiw_st_current | idc_cp | idc_cpc | idc_cpi | idc_and | idc_andi | idc_or | idc_ori | idc_eor | idc_com | idc_neg | idc_inc | idc_dec | idc_lsr | idc_ror | idc_asr | sreg_bop_wr_en[2];
         
         // idc_adiw
         assign sreg_v_wr_en = idc_add | idc_adc | adiw_st_current | idc_sub | idc_subi | idc_sbc | idc_sbci | sbiw_st_current | idc_neg | idc_com | idc_inc | idc_dec | idc_cp | idc_cpc | idc_cpi | idc_lsr | idc_ror | idc_asr | sreg_bop_wr_en[3] | idc_and | idc_andi | idc_or | idc_ori | idc_eor;		// idc_sbiw
         // V-flag bug fixing
         
         assign sreg_s_wr_en = idc_add | idc_adc | adiw_st_current | idc_sub | idc_subi | idc_sbc | idc_sbci | sbiw_st_current | idc_cp | idc_cpc | idc_cpi | idc_and | idc_andi | idc_or | idc_ori | idc_eor | idc_com | idc_neg | idc_inc | idc_dec | idc_lsr | idc_ror | idc_asr | sreg_bop_wr_en[4];
         
         assign sreg_h_wr_en = idc_add | idc_adc | idc_sub | idc_subi | idc_cp | idc_cpc | idc_cpi | idc_sbc | idc_sbci | idc_neg | sreg_bop_wr_en[5];
         
         assign sreg_t_wr_en = idc_bst | sreg_bop_wr_en[6];
         
         assign sreg_i_wr_en = irq_st1_current | reti_st3_current | sreg_bop_wr_en[7];		// WAS "irq_start"
         
         //sreg_fl_in <=  bit_pr_sreg_out when (idc_bst or idc_bclr or idc_bset)='1' else		           -- TO THE SREG
         //reti_st3_current&'0'&alu_h_flag_out&alu_s_flag_out&alu_v_flag_out&alu_n_flag_out&alu_z_flag_out&alu_c_flag_out;      
         
         assign sreg_fl_in = ((idc_bst | idc_bclr | idc_bset) == 1'b1) ? bit_pr_sreg_out : 
                             ((mul_st_current == 1'b1 | muls_st_current == 1'b1 | xmulx_st_current == 1'b1)) ? {6'b000000, mz_out, mc_out} : 		// Multiplications (Extended)
                             {reti_st3_current, 1'b0, alu_h_flag_out, alu_s_flag_out, alu_v_flag_out, alu_n_flag_out, alu_z_flag_out, alu_c_flag_out};
         
         // #################################################################################################################
         
         // *********************************************************************************************
         // ************** INSTRUCTION DECODER OUTPUTS FOR THE OTHER BLOCKS  ****************************
         // *********************************************************************************************
         
         // FOR ALU
         
         assign idc_add_out = idc_add;
         assign idc_adc_out = idc_adc;
         assign idc_adiw_out = idc_adiw;
         assign idc_sub_out = idc_sub;
         assign idc_subi_out = idc_subi;
         assign idc_sbc_out = idc_sbc;
         assign idc_sbci_out = idc_sbci;
         assign idc_sbiw_out = idc_sbiw;
         assign adiw_st_out = adiw_st_current;
         assign sbiw_st_out = sbiw_st_current;
         assign idc_and_out = idc_and;
         assign idc_andi_out = idc_andi;
         assign idc_or_out = idc_or;
         assign idc_ori_out = idc_ori;
         assign idc_eor_out = idc_eor;
         assign idc_com_out = idc_com;
         assign idc_neg_out = idc_neg;
         assign idc_inc_out = idc_inc;
         assign idc_dec_out = idc_dec;
         assign idc_cp_out = idc_cp;
         assign idc_cpc_out = idc_cpc;
         assign idc_cpi_out = idc_cpi;
         assign idc_cpse_out = idc_cpse;
         assign idc_lsr_out = idc_lsr;
         assign idc_ror_out = idc_ror;
         assign idc_asr_out = idc_asr;
         assign idc_swap_out = idc_swap;
         
         // FOR THE BIT PROCESSOR
         assign sbi_st_out = sbi_st_current;
         assign cbi_st_out = cbi_st_current;
         assign idc_bst_out = idc_bst;
         assign idc_bset_out = idc_bset;
         assign idc_bclr_out = idc_bclr;
         assign idc_sbic_out = idc_sbic;
         assign idc_sbis_out = idc_sbis;
         assign idc_sbrs_out = idc_sbrs;
         assign idc_sbrc_out = idc_sbrc;
         assign idc_brbs_out = idc_brbs;
         assign idc_brbc_out = idc_brbc;
         assign idc_reti_out = idc_reti;
         
         // POST INCREMENT/PRE DECREMENT FOR THE X,Y,Z REGISTERS
         //post_inc <= idc_psinc;
         assign post_inc = idc_psinc | ((idc_lpm_ext | idc_elpm_ext) & lpm_e_ext_post_inc);		// +Extended 
         assign pre_dec = idc_prdec;
         
         //reg_h_wr <= (idc_st_x or idc_st_y or idc_st_z or idc_ld_x or idc_ld_y or idc_ld_z) and (idc_psinc or idc_prdec);
         assign reg_h_wr = ((idc_st_x | idc_st_y | idc_st_z | idc_ld_x | idc_ld_y | idc_ld_z) & (idc_psinc | idc_prdec)) | ((idc_lpm_ext | idc_elpm_ext) & lpm_e_ext_post_inc);		// +Extended
         
         assign reg_h_adr[0] = idc_st_x | idc_ld_x;
         assign reg_h_adr[1] = idc_st_y | idc_std_y | idc_ld_y | idc_ldd_y;
         
         //reg_h_adr(2)<= idc_st_z or idc_std_z or idc_ld_z or idc_ldd_z;
         assign reg_h_adr[2] = idc_st_z | idc_std_z | idc_ld_z | idc_ldd_z | ((idc_lpm_ext | idc_elpm_ext) & lpm_e_ext_post_inc);		// +Extended
         
         // STACK POINTER CONTROL
         assign sp_ndown_up = idc_pop | idc_ret | (ret_st1_current & (~cpuwait)) | idc_reti | (reti_st1_current & (~cpuwait));		// ?????????
         assign sp_en = idc_push | idc_pop | idc_rcall | (rcall_st1_current & (~cpuwait)) | idc_icall | (icall_st1_current & (~cpuwait)) | idc_ret | (ret_st1_current & (~cpuwait)) | idc_reti | (reti_st1_current & (~cpuwait)) | call_st1_current | (call_st2_current & (~cpuwait)) | irq_st1_current | (irq_st2_current & (~cpuwait));		//????????
         
         assign branch = dex_condition;
         assign bit_num_r_io = ((cbi_st_current | sbi_st_current) == 1'b1) ? cbi_sbi_bit_num_tmp_current : 
                               dex_bitop_bitnum;
         
         assign adr = adr_int;
         
         assign ramre = ramre_int_current;
         assign ramwe = ramwe_int_current;
         
         assign iore = iore_int;
         assign iowe = iowe_int;
         
         assign dbusout = dbusout_int;
         
         // Sleep Control
         assign sleepi = idc_sleep;
         assign irqok = irq_int;
         
         // Watchdog
         assign wdri = idc_wdr;
         
         // Extended instructions
         assign w_op = idc_movw | (mul_st_current | muls_st_current | xmulx_st_current);		// !TBD!
         assign reg_rd_hb_in = ((idc_movw == 1'b1)) ? reg_rr_hb_out : 		// TBD
                               mr_out[15:8];
         
         // ************************** JTAG OCD support ************************************
         
         // Change of flow	
         assign change_flow = rjmp_st_current | nrcall_st0_current | brxx_st_current | ncall_st0_current | ijmp_st_current | nirq_st0_current | njmp_st0_current | nicall_st0_current | nskip_inst_st0_current;
         // ??? nret_st0_current or nreti_st0_current ???			   
         
         // WAS => nop_insert_st
         assign valid_instr = (~(adiw_st_current | sbiw_st_current | cbi_st_current | sbi_st_current | rjmp_st_current | ijmp_st_current | pop_st_current | push_st_current | brxx_st_current | ld_st_current | st_st_current | ncall_st0_current | nirq_st0_current | nret_st0_current | nreti_st0_current | nlpm_st0_current | njmp_st0_current | nrcall_st0_current | nicall_st0_current | sts_st_current | lds_st_current | nskip_inst_st0_current | nlpm_e_st0_current | (mul_st_current | muls_st_current | xmulx_st_current) | nspm_st0_current));		// + Extended
         
         // **************************** Preventing "bogus" fetches ********************************************************			   
         
         // Commented 16.11.2006
         //pm_ce <= '0' when (((idc_brbc='1' or idc_brbs='1') and  bit_test_op_out='1') or          -- BRXX instruction
         //                    (idc_rjmp='1' or idc_ijmp='1' or idc_rcall='1' or idc_icall='1') or	 -- RJMP/IJMP/RCALL/ICALL 
         //					(jmp_st1_current='1' or call_st1_current='1' or call_st2_current='1')or                      -- JMP/CALL? 
         //					(ret_st1_current='1' or ret_st2_current='1' or reti_st1_current='1' or reti_st2_current='1'))        -- RET/RETI ?? 
         //         else '1'; 																	
         // Commented 16.11.2006	
         
         // Multiplier control
         assign fmul = fmulx_st_current;		// FMUL/FMULS/FMULSU
         assign muls = idc_muls | idc_fmuls;		// MULS/FMULS
         assign mulsu = idc_mulsu | idc_fmulsu;		// MULSU/FMULSU
         
         // SPM support
         assign spm_inst = idc_spm;
         
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//                            FFs (Begin) 
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reg [15:0]instruction_reg_next;		  // OUTPUT OF THE INSTRUCTION REGISTER
reg [4:0] dex_adrreg_d_latched_next;	  //  STORE ADDRESS OF DESTINATION REGISTER FOR LDS/STS/POP INSTRUCTIONS
reg [4:0] adiw_sbiw_encoder_mux_out_next;
reg [15:0]ramadr_int_next;
reg       reg_file_adr_space_next;       // ACCSESS TO THE REGISTER FILE
reg       io_file_adr_space_next;	 // ACCSESS TO THE I/O FILE
reg       ramre_int_next;
reg       ramwe_int_next;
reg [7:0] gp_reg_tmp_next;		 //  STORE DATA FROM THE REGISTERS FOR STS,ST INSTRUCTIONS
reg [7:0] program_counter_high_fr_next;		// TO STORE PC FOR CALL,IRQ,RCALL,ICALL
reg [15:0]program_counter_tmp_next;		// TO STORE PC DURING LPM/ELPM INSTRUCTIONS
reg [7:0] pc_low_next;
reg [7:0] pc_high_next;
reg [15:0]pc_for_interrupt_next;
reg	  nskip_inst_st0_next;
reg	  skip_inst_st1_next;
reg	  skip_inst_st2_next;		     // ALL SKIP INSTRUCTIONS SBRS/SBRC/SBIS/SBIC/CPSE 
reg	  adiw_st_next;
reg	  sbiw_st_next;
reg	  nlpm_st0_next;
reg	  lpm_st1_next;
reg	  lpm_st2_next;
reg	  nlpm_e_st0_next;
reg	  lpm_e_st1_next;
reg	  lpm_e_st2_next;
reg       reg_z_out_lsb_rg_next;		// For LMP/ELPM and LMP/ELPM Extended
reg	  mul_st_next;  	     // MUL   
reg	  muls_st_next; 	     // MULS
reg	  xmulx_st_next;	     // MULSU + FMUL/FMULS/FMULSU
reg	  fmulx_st_next;	     // FMUL/FMULS/FMULSU
reg	  nspm_st0_next;
reg	  spm_st1_next;
reg	  spm_st2_next;
reg	  lds_st_next;
reg	  sts_st_next;
reg	  njmp_st0_next;
reg	  jmp_st1_next;
reg	  jmp_st2_next;
reg	  nrcall_st0_next;
reg	  rcall_st1_next;
reg	  rcall_st2_next;
reg	  nicall_st0_next;
reg	  icall_st1_next;
reg	  icall_st2_next;
reg	  ncall_st0_next;
reg	  call_st1_next;
reg	  call_st2_next;
reg	  call_st3_next;
reg	  nret_st0_next;
reg	  ret_st1_next;
reg	  ret_st2_next;
reg	  ret_st3_next;
reg	  nreti_st0_next;
reg	  reti_st1_next;
reg	  reti_st2_next;
reg	  reti_st3_next;
reg	  nirq_st0_next;
reg	  irq_st1_next;
reg	  irq_st2_next;
reg	  irq_st3_next;
reg	  irqack_int_next;
reg [4:0] irqackad_int_next;
reg	  ijmp_st_next;
reg	  rjmp_st_next;
reg	  brxx_st_next; 	     // BRANCHES
reg	  st_st_next;
reg	  ld_st_next;
reg	  sbi_st_next;
reg	  cbi_st_next;
reg	  push_st_next;
reg	  pop_st_next;
reg [4:0] cbi_sbi_io_adr_tmp_next;	     //  STORE ADDRESS OF I/O PORT FOR CBI/SBI INSTRUCTION
reg [2:0] cbi_sbi_bit_num_tmp_next;	     //  STORE ADDRESS OF I/O PORT FOR CBI/SBI INSTRUCTION

// End of wires

always @(posedge cp2 or negedge ireset)
 begin: main_seq
  if (!ireset) begin		// RESET
   instruction_reg_current           <= {16{1'b0}};
   dex_adrreg_d_latched_current      <= {5{1'b0}};
   adiw_sbiw_encoder_mux_out_current <= {5{1'b0}};
   ramadr_int_current                <= {16{1'b0}};
   reg_file_adr_space_current        <= 1'b0;
   io_file_adr_space_current         <= 1'b0;
   ramre_int_current                 <= 1'b0;
   ramwe_int_current                 <= 1'b0;
   gp_reg_tmp_current                <= {8{1'b0}};
   program_counter_high_fr_current   <= {8{1'b0}};
   program_counter_tmp_current       <= {16{1'b0}};
   pc_low_current                    <= {8{1'b0}};
   pc_high_current                   <= {8{1'b0}};
   pc_for_interrupt_current          <= {16{1'b0}};
   
   nskip_inst_st0_current            <= 1'b0;
   skip_inst_st1_current             <= 1'b0;
   skip_inst_st2_current             <= 1'b0;
   
   adiw_st_current                   <= 1'b0;
   sbiw_st_current                   <= 1'b0;
   
   nlpm_st0_current                  <= 1'b0;
   lpm_st1_current                   <= 1'b0;
   lpm_st2_current                   <= 1'b0;
   
   nlpm_e_st0_current                <= 1'b0;
   lpm_e_st1_current                 <= 1'b0;
   lpm_e_st2_current                 <= 1'b0;
   
   reg_z_out_lsb_rg_current          <= 1'b0;
   
   mul_st_current                    <= 1'b0;
   muls_st_current                   <= 1'b0;
   xmulx_st_current                  <= 1'b0;
   fmulx_st_current                  <= 1'b0;

   nspm_st0_current                  <= 1'b0;
   spm_st1_current                   <= 1'b0;
   spm_st2_current                   <= 1'b0;
   
   lds_st_current                    <= 1'b0;
   sts_st_current                    <= 1'b0; 
   
   njmp_st0_current      	     <= 1'b0;
   jmp_st1_current  	             <= 1'b0;
   jmp_st2_current  	             <= 1'b0;
   
   nrcall_st0_current                <= 1'b0;
   rcall_st1_current                 <= 1'b0;
   rcall_st2_current                 <= 1'b0;
   
   nicall_st0_current                <= 1'b0;
   icall_st1_current                 <= 1'b0;
   icall_st2_current                 <= 1'b0;

   ncall_st0_current                 <= 1'b0;
   call_st1_current                  <= 1'b0;
   call_st2_current                  <= 1'b0;
   call_st3_current                  <= 1'b0;

   nret_st0_current                  <= 1'b0;
   ret_st1_current                   <= 1'b0;
   ret_st2_current                   <= 1'b0;
   ret_st3_current                   <= 1'b0;

   nreti_st0_current                 <= 1'b0;
   reti_st1_current                  <= 1'b0;
   reti_st2_current                  <= 1'b0;
   reti_st3_current                  <= 1'b0;

   nirq_st0_current                  <= 1'b0;
   irq_st1_current                   <= 1'b0;
   irq_st2_current                   <= 1'b0;
   irq_st3_current                   <= 1'b0;
   
   irqack_int_current	             <= 1'b0;
   irqackad_int_current              <= {5{1'b0}};

   rjmp_st_current	             <= 1'b0;
   ijmp_st_current	             <= 1'b0;
   push_st_current	             <= 1'b0;
   pop_st_current	             <= 1'b0;
   brxx_st_current	             <= 1'b0;

   ld_st_current	             <= 1'b0;
   st_st_current	             <= 1'b0;

   sbi_st_current	             <= 1'b0;
   cbi_st_current	             <= 1'b0;
   cbi_sbi_io_adr_tmp_current        <= {5{1'b0}};
   cbi_sbi_bit_num_tmp_current       <= {3{1'b0}};
  
  end	 
  else begin		       // CLOCK
   instruction_reg_current           <= instruction_reg_next;
   dex_adrreg_d_latched_current      <= dex_adrreg_d_latched_next;
   adiw_sbiw_encoder_mux_out_current <= adiw_sbiw_encoder_mux_out_next;
   ramadr_int_current                <= ramadr_int_next;
   reg_file_adr_space_current        <= reg_file_adr_space_next;
   io_file_adr_space_current         <= io_file_adr_space_next;
   ramre_int_current                 <= ramre_int_next;
   ramwe_int_current                 <= ramwe_int_next;
   gp_reg_tmp_current                <= gp_reg_tmp_next;
   program_counter_high_fr_current   <= program_counter_high_fr_next;
   program_counter_tmp_current       <= program_counter_tmp_next;
   pc_low_current                    <= pc_low_next;
   pc_high_current                   <= pc_high_next;
   pc_for_interrupt_current          <= pc_for_interrupt_next;
   
   nskip_inst_st0_current	     <= nskip_inst_st0_next;
   skip_inst_st1_current	     <= skip_inst_st1_next;
   skip_inst_st2_current	     <= skip_inst_st2_next;
   
   adiw_st_current		     <= adiw_st_next;
   sbiw_st_current		     <= sbiw_st_next;
   
   nlpm_st0_current                  <= nlpm_st0_next;
   lpm_st1_current                   <= lpm_st1_next;
   lpm_st2_current                   <= lpm_st2_next;
   
   nlpm_e_st0_current		     <= nlpm_e_st0_next;
   lpm_e_st1_current		     <= lpm_e_st1_next;
   lpm_e_st2_current		     <= lpm_e_st2_next;
   
   reg_z_out_lsb_rg_current          <= reg_z_out_lsb_rg_next;

   mul_st_current  		     <= mul_st_next;  
   muls_st_current 		     <= muls_st_next; 
   xmulx_st_current		     <= xmulx_st_next;
   fmulx_st_current		     <= fmulx_st_next;

   nspm_st0_current		     <= nspm_st0_next;
   spm_st1_current 		     <= spm_st1_next;
   spm_st2_current 		     <= spm_st2_next;
   
   lds_st_current  		     <= lds_st_next;
   sts_st_current  		     <= sts_st_next;
   
   njmp_st0_current		     <= njmp_st0_next;
   jmp_st1_current 		     <= jmp_st1_next;
   jmp_st2_current 		     <= jmp_st2_next; 
   
   nrcall_st0_current                <= nrcall_st0_next;
   rcall_st1_current                 <= rcall_st1_next;
   rcall_st2_current                 <= rcall_st2_next;

   nicall_st0_current                <= nicall_st0_next;
   icall_st1_current                 <= icall_st1_next;
   icall_st2_current                 <= icall_st2_next;

   ncall_st0_current                 <= ncall_st0_next;
   call_st1_current                  <= call_st1_next;
   call_st2_current                  <= call_st2_next;
   call_st3_current                  <= call_st3_next;

   nret_st0_current                  <= nret_st0_next;
   ret_st1_current                   <= ret_st1_next;
   ret_st2_current                   <= ret_st2_next;
   ret_st3_current                   <= ret_st3_next;

   nreti_st0_current                 <= nreti_st0_next;
   reti_st1_current                  <= reti_st1_next;
   reti_st2_current                  <= reti_st2_next;
   reti_st3_current                  <= reti_st3_next;

   nirq_st0_current                  <= nirq_st0_next;
   irq_st1_current                   <= irq_st1_next;
   irq_st2_current                   <= irq_st2_next;
   irq_st3_current                   <= irq_st3_next;

   irqack_int_current	             <= irqack_int_next;
   irqackad_int_current              <= irqackad_int_next;

   rjmp_st_current	             <= rjmp_st_next;
   ijmp_st_current	             <= ijmp_st_next;
   push_st_current	             <= push_st_next;
   pop_st_current	             <= pop_st_next;
   brxx_st_current	             <= brxx_st_next;

   ld_st_current	             <= ld_st_next;
   st_st_current	             <= st_st_next;

   sbi_st_current	             <= sbi_st_next;
   cbi_st_current	             <= cbi_st_next;
   cbi_sbi_io_adr_tmp_current        <= cbi_sbi_io_adr_tmp_next;
   cbi_sbi_bit_num_tmp_current       <= cbi_sbi_bit_num_tmp_next;

  end
 end


always @*
 begin: main_comb
  // Latch avoidance
   instruction_reg_next           = instruction_reg_current;
   dex_adrreg_d_latched_next      = dex_adrreg_d_latched_current;
   adiw_sbiw_encoder_mux_out_next = adiw_sbiw_encoder_mux_out_current; 
   ramadr_int_next                = ramadr_int_current;
   reg_file_adr_space_next        = reg_file_adr_space_current;
   io_file_adr_space_next         = io_file_adr_space_current; 
   ramre_int_next                 = ramre_int_current; 
   ramwe_int_next                 = ramwe_int_current;
   gp_reg_tmp_next                = gp_reg_tmp_current;
   program_counter_high_fr_next   = program_counter_high_fr_current; 
   program_counter_tmp_next       = program_counter_tmp_current; 
   pc_low_next                    = pc_low_current; 	 
   pc_high_next 		  = pc_high_current;
   pc_for_interrupt_next          = pc_for_interrupt_current;

   nskip_inst_st0_next            = nskip_inst_st0_current; 
   skip_inst_st1_next             = skip_inst_st1_current;  
   skip_inst_st2_next             = skip_inst_st2_current;  

   adiw_st_next                   = adiw_st_current;
   sbiw_st_next                   = sbiw_st_current;

   nlpm_st0_next                  = nlpm_st0_current;	      
   lpm_st1_next                   = lpm_st1_current;	      
   lpm_st2_next                   = lpm_st2_current;		     

   nlpm_e_st0_next                = nlpm_e_st0_current; 
   lpm_e_st1_next                 = lpm_e_st1_current;  
   lpm_e_st2_next                 = lpm_e_st2_current;  

   reg_z_out_lsb_rg_next          = reg_z_out_lsb_rg_current;
   
   mul_st_next                    = mul_st_current;	
   muls_st_next                   = muls_st_current;	
   xmulx_st_next                  = xmulx_st_current;	
   fmulx_st_next                  = fmulx_st_current;
   
   nspm_st0_next                  = nspm_st0_current; 
   spm_st1_next                   = spm_st1_current;  
   spm_st2_next                   = spm_st2_current;  

   lds_st_next                    = lds_st_current;
   sts_st_next                    = sts_st_current;  

   njmp_st0_next                  = njmp_st0_current;
   jmp_st1_next                   = jmp_st1_current;  
   jmp_st2_next                   = jmp_st2_current;	

   nrcall_st0_next                = nrcall_st0_current;
   rcall_st1_next                 = rcall_st1_current;
   rcall_st2_next                 = rcall_st2_current;

   nicall_st0_next                = nicall_st0_current;
   icall_st1_next                 = icall_st1_current; 
   icall_st2_next                 = icall_st2_current; 

   ncall_st0_next                 = ncall_st0_current; 
   call_st1_next                  = call_st1_current;  
   call_st2_next                  = call_st2_current;  
   call_st3_next                  = call_st3_current;  

   nret_st0_next                  = nret_st0_current;  
   ret_st1_next                   = ret_st1_current;	
   ret_st2_next                   = ret_st2_current;	
   ret_st3_next                   = ret_st3_current;	

   nreti_st0_next                 = nreti_st0_current; 
   reti_st1_next                  = reti_st1_current;  
   reti_st2_next                  = reti_st2_current;  
   reti_st3_next                  = reti_st3_current;  

   nirq_st0_next                  = nirq_st0_current;  
   irq_st1_next                   = irq_st1_current;	
   irq_st2_next                   = irq_st2_current;	
   irq_st3_next                   = irq_st3_current;	

   irqack_int_next	          =  irqack_int_current;	     
   irqackad_int_next	          =  irqackad_int_current;       

   rjmp_st_next 	          =  rjmp_st_current;	    
   ijmp_st_next 	          =  ijmp_st_current;	    
   push_st_next 	          =  push_st_current;	    
   pop_st_next  	          =  pop_st_current;	    
   brxx_st_next 	          =  brxx_st_current;	    

   ld_st_next		          =  ld_st_current; 	    
   st_st_next		          =  st_st_current; 	    

   sbi_st_next  	          =  sbi_st_current;	    
   cbi_st_next  	          =  cbi_st_current;	    
   cbi_sbi_io_adr_tmp_next        =  cbi_sbi_io_adr_tmp_current; 
   cbi_sbi_bit_num_tmp_next       =  cbi_sbi_bit_num_tmp_current;

  // Latch avoidance

  if (cp2en) begin		// Clock enable

   instruction_reg_next = inst;

   // LATCH Rd ADDDRESS FOR LDS/STS/POP and extended LPM/ELPM INSTRUCTIONS
   // Extended
   if (((idc_ld_x || idc_ld_y || idc_ldd_y || idc_ld_z || idc_ldd_z) || idc_sts || (idc_st_x || idc_st_y || idc_std_y || idc_st_z || idc_std_z) || idc_lds || idc_pop || idc_lpm_ext || idc_elpm_ext))
    dex_adrreg_d_latched_next = dex_adrreg_d;

   adiw_sbiw_encoder_mux_out_next = adiw_sbiw_encoder_out + 1; 

   // ADDRESS REGISTER 
   if (ramadr_reg_en)
    ramadr_int_next = ramadr_reg_in;

   // GENERAL PURPOSE REGISTERS ADDRESSING FLAG FOR ST/STD/STS INSTRUCTIONS
   if (ramadr_reg_en)
   begin
      if (ramadr_reg_in[15:5] == const_ram_to_reg)
   	 reg_file_adr_space_next = 1'b1;	       // ADRESS RANGE 0x0000-0x001F -> REGISTERS (R0-R31)
      else
   	 reg_file_adr_space_next = 1'b0;
   end
 
  // I/O REGISTERS ADDRESSING FLAG FOR ST/STD/STS INSTRUCTIONS
   if (ramadr_reg_en)
   begin
      if (ramadr_reg_in[15:5] == const_ram_to_io_a || ramadr_reg_in[15:5] == const_ram_to_io_b)
   	 io_file_adr_space_next = 1'b1;	       // ADRESS RANGE 0x0020-0x005F -> I/O PORTS (0x00-0x3F)
      else
   	 io_file_adr_space_next = 1'b0;
   end

   case (ramre_int_current)
      1'b0 :
   	 // LDS instruction(two cycle execution)
   	 // POP instruction
   	 // RET instruction 
   	 // RETI instruction 
   	 if (ramadr_reg_in[15:5] != const_ram_to_io_a && ramadr_reg_in[15:5] != const_ram_to_io_b && ramadr_reg_in[15:5] != const_ram_to_reg
	 && (idc_ld_x || idc_ld_y || idc_ldd_y || idc_ld_z || idc_ldd_z || idc_lds || idc_pop || idc_ret || idc_reti)) 	       // LD/LDD instruction   
   	    ramre_int_next = 1'b1;
      1'b1 :
   	 if (((ld_st_current || lds_st_current || pop_st_current || ret_st2_current || reti_st2_current) && (~cpuwait)))
   	    ramre_int_next = 1'b0;
      default : ramre_int_next = 1'b0;
   endcase 

   case (ramwe_int_current)
      1'b0 :
   	 // STS instruction (two cycle execution)      
   	 // PUSH instruction
   	 // RCALL instruction
   	 // ICALL instruction
   	 // CALL instruction
   	 // Interrupt  
   	 if (ramadr_reg_in[15:5] != const_ram_to_io_a && ramadr_reg_in[15:5] != const_ram_to_io_b && ramadr_reg_in[15:5] != const_ram_to_reg
	 && (idc_st_x || idc_st_y || idc_std_y || idc_st_z || idc_std_z || idc_sts || idc_push || idc_rcall || idc_icall || call_st1_current
	 || irq_st1_current))	       // ST/STD instruction   
   	    ramwe_int_next = 1'b1;
      1'b1 :
   	 if (((st_st_current || sts_st_current || push_st_current || rcall_st2_current || icall_st2_current ||
	 call_st3_current || irq_st3_current) && (~cpuwait)))
   	    ramwe_int_next = 1'b0;
      default : ramwe_int_next = 1'b0;
   endcase

   // gp_reg_tmp_current STORES TEMPREOARY THE VALUE OF SOURCE REGISTER DURING ST/STD/STS INSTRUCTION
   // if ((idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z) or sts_st_current1)='1' then  -- CLOCK ENABLE
   if (((idc_st_x || idc_st_y || idc_std_y || idc_st_z || idc_std_z) || idc_sts))		   
    gp_reg_tmp_next = reg_rd_out;

      // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      // +++++++++++++++++++++++++++++++++++++++ PROGRAM COUNTER ++++++++++++++++++++++++++++++++++++++++++++++++++
      // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   if ((idc_rcall || idc_icall || call_st1_current || irq_st1_current))
    program_counter_high_fr_next = program_counter[15:8];	     // STORE HIGH BYTE OF THE PROGRAMM COUNTER FOR RCALL/ICALL/CALL INSTRUCTIONS AND INTERRUPTS   

   if ((idc_lpm || idc_elpm || idc_lpm_ext || idc_elpm_ext || idc_spm))	    // (+Extended)	
    program_counter_tmp_next = program_counter;

   if (pc_low_en)
      pc_low_next  = program_counter_in[7:0];

   if (pc_high_en)
      pc_high_next = program_counter_in[15:8];

   if (irq_start)
      pc_for_interrupt_next = program_counter;

 
   // skip_instruction_sm
   nskip_inst_st0_next = ((~nskip_inst_st0_current) & skip_inst_start) | (nskip_inst_st0_current & (~((skip_inst_st1_current & (~two_word_inst)) | skip_inst_st2_current)));
   skip_inst_st1_next  = ((~skip_inst_st1_current) & (~nskip_inst_st0_current) & skip_inst_start);
   skip_inst_st2_next  = (~skip_inst_st2_current) & skip_inst_st1_current & two_word_inst;

   // alu_state_machines
   adiw_st_next = (~adiw_st_current) & idc_adiw;
   sbiw_st_next = (~sbiw_st_current) & idc_sbiw;

   // lpm_state_machine
   nlpm_st0_next = ((~nlpm_st0_current) & (idc_lpm | idc_elpm)) | (nlpm_st0_current & (~lpm_st2_current));
   lpm_st1_next  = ((~lpm_st1_current) & (~nlpm_st0_current) & (idc_lpm | idc_elpm));	    // ?? 
   lpm_st2_next  = (~lpm_st2_current) & lpm_st1_current;

   // lpm_ext_s_m
   case (nlpm_e_st0_current)
      1'b0 :
   	 if (idc_lpm_ext || idc_elpm_ext)
   	    nlpm_e_st0_next = 1'b1;
      1'b1 :
   	 if (lpm_e_st2_current)
   	    nlpm_e_st0_next = 1'b0;
      default : nlpm_e_st0_next = 1'b0;
   endcase
   
   case (lpm_e_st1_current)
      1'b0 :
   	 if (!nlpm_e_st0_current && (idc_lpm_ext || idc_elpm_ext))
   	    lpm_e_st1_next = 1'b1;
      1'b1 :
   	 lpm_e_st1_next = 1'b0;
      default : lpm_e_st1_next = 1'b0;
   endcase
   
   lpm_e_st2_next = lpm_e_st1_current;

    // lpm_byte_sel_rg
    if (idc_lpm || idc_elpm || idc_lpm_ext || idc_elpm_ext)
       reg_z_out_lsb_rg_next = reg_z_out[0];

    // mult_seq
    // MUL    
    case (mul_st_current)
       1'b0 :
    	  if (idc_mul)
    	     mul_st_next = 1'b1;
       1'b1 :
    	  mul_st_next = 1'b0;
       default : mul_st_next = 1'b0;
    endcase
    
    // MULS   
    case (muls_st_current)
       1'b0 :
    	  if (idc_muls)
    	     muls_st_next = 1'b1;
       1'b1 :
    	  muls_st_next = 1'b0;
       default : muls_st_next = 1'b0;
    endcase
    
    // MULSU + FMUL/FMULS/FMULSU
    case (xmulx_st_current)
       1'b0 :
    	  if (idc_mulsu || idc_fmul || idc_fmuls || idc_fmulsu)
    	     xmulx_st_next = 1'b1;
       1'b1 :
    	  xmulx_st_next = 1'b0;
       default :  xmulx_st_next = 1'b0;
    endcase
    
    // FMUL/FMULS/FMULSU
    case (fmulx_st_current)
       1'b0 :
    	  if (idc_fmul || idc_fmuls || idc_fmulsu)
    	     fmulx_st_next = 1'b1;
       1'b1 :
    	  fmulx_st_next = 1'b0;
       default : fmulx_st_next = 1'b0;
    endcase

    // spm_sm_seq
    case (nspm_st0_current)
       1'b0 :
    	  if (idc_spm)
    	     nspm_st0_next = 1'b1;
       1'b1 :
    	  if (spm_st2_current)
    	     nspm_st0_next = 1'b0;
       default : nspm_st0_next = 1'b0;
    endcase
    
    case (spm_st1_current)
       1'b0 :
    	  if (!nspm_st0_current && idc_spm)
    	     spm_st1_next = 1'b1;
       1'b1 :
    	  if (!spm_wait)
    	     spm_st1_next = 1'b0;
       default : spm_st1_next = 1'b0;
    endcase
    
    case (spm_st2_current)
       1'b0 :
    	  if (spm_st1_current && !spm_wait)
    	     spm_st2_next = 1'b1;
       1'b1 :
    	  spm_st2_next = 1'b0;
       default : spm_st2_next = 1'b0;
    endcase

    // lds_st_state_machine
    lds_st_next = ((~lds_st_current) & idc_lds) | (lds_st_current & cpuwait);

    // sts_st_state_machine
    sts_st_next = ((~sts_st_current) & idc_sts) | (sts_st_current & cpuwait);

    // jmp_state_machine
    njmp_st0_next = ((~njmp_st0_current) & idc_jmp) | (njmp_st0_current & (~jmp_st2_current));
    jmp_st1_next  = (~jmp_st1_current) & (~njmp_st0_current) & idc_jmp;	    // ?? 
    jmp_st2_next  = (~jmp_st2_current) & jmp_st1_current;

    // rcall_state_machine
    nrcall_st0_next = ((~nrcall_st0_current) & idc_rcall) | (nrcall_st0_current & (~(rcall_st2_current & (~cpuwait))));
    rcall_st1_next  = ((~rcall_st1_current) & (~nrcall_st0_current) & idc_rcall) | (rcall_st1_current & cpuwait);
    rcall_st2_next  = ((~rcall_st2_current) & rcall_st1_current & (~cpuwait)) | (rcall_st2_current & cpuwait);

    // icall_state_machine
    nicall_st0_next = ((~nicall_st0_current) & idc_icall) | (nicall_st0_current & (~(icall_st2_current & (~cpuwait))));
    icall_st1_next  = ((~icall_st1_current) & (~nicall_st0_current) & idc_icall) | (icall_st1_current & cpuwait);
    icall_st2_next  = ((~icall_st2_current) & icall_st1_current & (~cpuwait)) | (icall_st2_current & cpuwait);
																            
    // call_state_machine  
    ncall_st0_next = ((~ncall_st0_current) & idc_call) | (ncall_st0_current & (~(call_st3_current & (~cpuwait))));
    call_st1_next  = (~call_st1_current) & (~ncall_st0_current) & idc_call;
    call_st2_next  = ((~call_st2_current) & call_st1_current) | (call_st2_current & cpuwait);
    call_st3_next  = ((~call_st3_current) & call_st2_current & (~cpuwait)) | (call_st3_current & cpuwait);

    // ret_state_machine      
    nret_st0_next = ((~nret_st0_current) & idc_ret) | (nret_st0_current & (~ret_st3_current));
    ret_st1_next  = ((~ret_st1_current) & (~nret_st0_current) & idc_ret) | (ret_st1_current & cpuwait);
    ret_st2_next  = ((~ret_st2_current) & ret_st1_current & (~cpuwait)) | (ret_st2_current & cpuwait);
    ret_st3_next  = (~ret_st3_current) & ret_st2_current & (~cpuwait);

    // reti_state_machine 
    nreti_st0_next = ((~nreti_st0_current) & idc_reti) | (nreti_st0_current & (~reti_st3_current));
    reti_st1_next  = ((~reti_st1_current) & (~nreti_st0_current) & idc_reti) | (reti_st1_current & cpuwait);
    reti_st2_next  = ((~reti_st2_current) & reti_st1_current & (~cpuwait)) | (reti_st2_current & cpuwait);
    reti_st3_next  = (~reti_st3_current) & reti_st2_current & (~cpuwait);

    // irq_state_machine      
    nirq_st0_next = ((~nirq_st0_current) & irq_start) | (nirq_st0_current & (~(irq_st3_current & (~cpuwait))));
    irq_st1_next = ((~irq_st1_current) & (~nirq_st0_current) & irq_start);
    irq_st2_next = ((~irq_st2_current) & irq_st1_current) | (irq_st2_current & cpuwait);
    irq_st3_next = ((~irq_st3_current) & irq_st2_current & (~cpuwait)) | (irq_st3_current & cpuwait);

    // irqack_reg
    irqack_int_next = (~irqack_int_current) & irq_start;

    // irqackad_reg
    irqackad_int_next = irq_vector_adr[5:1]; // <<<<<<<<< !!!!!

    // rjmp_push_pop_ijmp_state_brxx_machine
    rjmp_st_next = idc_rjmp;	     // ??
    ijmp_st_next = idc_ijmp;
    push_st_next = ((~push_st_current) & idc_push) | (push_st_current & cpuwait);
    pop_st_next = ((~pop_st_current) & idc_pop) | (pop_st_current & cpuwait);
    brxx_st_next = (~brxx_st_current) & (idc_brbc | idc_brbs) & bit_test_op_out;

    // LD/LDD/ST/STD
    // ld_st_state_machine
    ld_st_next = ((~ld_st_current) & (idc_ld_x | idc_ld_y | idc_ldd_y | idc_ld_z | idc_ldd_z)) | (ld_st_current & cpuwait);
    st_st_next = ((~st_st_current) & (idc_st_x | idc_st_y | idc_std_y | idc_st_z | idc_std_z)) | (st_st_current & cpuwait);


    // SBI/CBI
    // sbi_cbi_machine
    sbi_st_next = (~sbi_st_current) & idc_sbi;
    cbi_st_next = (~cbi_st_current) & idc_cbi;
    cbi_sbi_io_adr_tmp_next = dex_adr5port;
    cbi_sbi_bit_num_tmp_next = dex_bitop_bitnum;

   end // if (cp2en)	 
  end

      
      // Extended instruction set (Mega128)
      // Extended instruction set (Mega128)
      

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//                            FFs (End) 
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	 
	 
endmodule // pm_fetch_dec

