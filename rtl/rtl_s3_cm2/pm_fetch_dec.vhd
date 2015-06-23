--************************************************************************************************
--  PM_FETCH_DEC(internal module) for AVR core
--	Version 2.6! (Special version for the JTAG OCD)
--  Designed by Ruslan Lepetenok 14.11.2001
--  Modified 31.05.06
--  Modification:
--  Registered ramre/ramwe outputs
--  cpu_busy logic modified(affects RCALL/ICALL/CALL instruction interract with interrupt)
--  SLEEP and CLRWDT instructions support was added
--  V-flag bug fixed (AND/ANDI/OR/ORI/EOR)
--  V-flag bug fixed (ADIW/SBIW)
--  Unused outputs(sreg_bit_num[2..0],idc_sbi_out,idc_cbi_out,idc_bld_out) were removed.
--  Output alu_data_d_in[7..0] was removed.
--  Gloabal clock enable(cp2en) was added  
--  cpu_busy(push/pop) + irq bug was fixed 14.07.05
--  BRXX+IRQ interaction was modified -> cpu_busy
--  LDS/STS now requires only two cycles for execution (13.01.06 -> last modificatioon)
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use WORK.AVRuCPackage.all;

entity pm_fetch_dec_cm2 is port(
		cp2_cml_1 : in std_logic;
		
                              -- Clock and reset
                              cp2              : in  std_logic;
							  cp2en            : in  std_logic; 
                              ireset           : in  std_logic;
							  -- JTAG OCD support
							  valid_instr      : out  std_logic;
						      insert_nop       : in   std_logic; 
						      block_irq        : in   std_logic;
						      change_flow      : out  std_logic;
							  -- Program memory
                              pc               : out std_logic_vector (15 downto 0);   
                              inst             : in  std_logic_vector (15 downto 0);
                              -- I/O control
                              adr              : out std_logic_vector (5 downto 0); 	
                              iore             : out std_logic;                       
                              iowe             : out std_logic;						
                              -- Data memory control
                              ramadr           : out std_logic_vector (15 downto 0);
                              ramre            : out std_logic;
                              ramwe            : out std_logic;
                              cpuwait          : in  std_logic;
							  -- Data paths
                              dbusin           : in  std_logic_vector (7 downto 0);
                              dbusout          : out std_logic_vector (7 downto 0);
                              dbusout_int_route : out std_logic_vector (7 downto 0);
                              -- Interrupt
                              irqlines         : in  std_logic_vector (22 downto 0);
                              irqack           : out std_logic;
                              irqackad         : out std_logic_vector(4 downto 0);
						      --Sleep 
                              sleepi	       : out std_logic;
                              irqok	           : out std_logic;
                              --Watchdog
                              wdri	           : out std_logic;
							  -- ALU interface(Data inputs)
                              alu_data_r_in    : out std_logic_vector(7 downto 0);
							  -- ALU interface(Instruction inputs)
							  idc_add_out      : out std_logic;
                              idc_adc_out      : out std_logic;
                              idc_adiw_out     : out std_logic;
                              idc_sub_out      : out std_logic;
                              idc_subi_out     : out std_logic;
                              idc_sbc_out      : out std_logic;
                              idc_sbci_out     : out std_logic;
                              idc_sbiw_out     : out std_logic;

                              adiw_st_out      : out std_logic;
                              sbiw_st_out      : out std_logic;

                              idc_and_out      : out std_logic;
                              idc_andi_out     : out std_logic;
                              idc_or_out       : out std_logic;
                              idc_ori_out      : out std_logic;
                              idc_eor_out      : out std_logic;              
                              idc_com_out      : out std_logic;              
                              idc_neg_out      : out std_logic;

                              idc_inc_out      : out std_logic;
                              idc_dec_out      : out std_logic;

                              idc_cp_out       : out std_logic;              
                              idc_cpc_out      : out std_logic;
                              idc_cpi_out      : out std_logic;
                              idc_cpse_out     : out std_logic;                            

                              idc_lsr_out      : out std_logic;
                              idc_ror_out      : out std_logic;
                              idc_asr_out      : out std_logic;
                              idc_swap_out     : out std_logic;

                               -- ALU interface(Data output)
                               alu_data_out    : in std_logic_vector(7 downto 0);

                               -- ALU interface(Flag outputs)
                               alu_c_flag_out  : in std_logic;
                               alu_z_flag_out  : in std_logic;
                               alu_n_flag_out  : in std_logic;
                               alu_v_flag_out  : in std_logic;
                               alu_s_flag_out  : in std_logic;
                               alu_h_flag_out  : in std_logic;

							   -- General purpose register file interface
                               reg_rd_in       : out std_logic_vector  (7 downto 0);
                               reg_rd_out      : in  std_logic_vector  (7 downto 0);
                               reg_rd_out_int  : in std_logic_vector(7 downto 0);
                               reg_rd_adr      : out std_logic_vector  (4 downto 0);
                               reg_rd_adr_int      : out std_logic_vector  (4 downto 0);
                               reg_rr_out      : in  std_logic_vector  (7 downto 0);
                               reg_rr_adr      : out std_logic_vector  (4 downto 0);
                               reg_rd_wr       : out std_logic;

                               post_inc        : out std_logic;                       -- POST INCREMENT FOR LD/ST INSTRUCTIONS
                               pre_dec         : out std_logic;                        -- PRE DECREMENT FOR LD/ST INSTRUCTIONS
                               reg_h_wr        : out std_logic;
                               reg_h_out       : in  std_logic_vector (15 downto 0);
                               reg_h_adr       : out std_logic_vector (2 downto 0);    -- x,y,z
   		                       reg_z_out       : in  std_logic_vector (15 downto 0);  -- OUTPUT OF R31:R30 FOR LPM/ELPM/IJMP INSTRUCTIONS
							   
                               -- I/O register file interface
                               sreg_fl_in      : out std_logic_vector(7 downto 0); 
                               globint         : in  std_logic; -- SREG I flag

                               sreg_fl_wr_en   : out std_logic_vector(7 downto 0);   --FLAGS WRITE ENABLE SIGNALS       

                               spl_out         : in  std_logic_vector(7 downto 0);         
                               sph_out         : in  std_logic_vector(7 downto 0);         
                               sp_ndown_up     : out std_logic; -- DIRECTION OF CHANGING OF STACK POINTER SPH:SPL 0->UP(+) 1->DOWN(-)
                               sp_en           : out std_logic; -- WRITE ENABLE(COUNT ENABLE) FOR SPH AND SPL REGISTERS
  
                               rampz_out       : in  std_logic_vector(7 downto 0);
							   
							   -- Bit processor interface
                               bit_num_r_io    : out std_logic_vector (2 downto 0); -- BIT NUMBER FOR CBI/SBI/BLD/BST/SBRS/SBRC/SBIC/SBIS INSTRUCTIONS
                               bitpr_io_out    : in  std_logic_vector(7 downto 0);  -- SBI/CBI OUT        
                               branch          : out std_logic_vector (2 downto 0); -- NUMBER (0..7) OF BRANCH CONDITION FOR BRBS/BRBC INSTRUCTION
                               bit_pr_sreg_out : in  std_logic_vector(7 downto 0);  -- BCLR/BSET/BST(T-FLAG ONLY)             
                               bld_op_out      : in  std_logic_vector(7 downto 0);  -- BLD OUT (T FLAG)
                               bit_test_op_out : in  std_logic;                     -- OUTPUT OF SBIC/SBIS/SBRS/SBRC

                               sbi_st_out      : out std_logic;
                               cbi_st_out      : out std_logic;

                               idc_bst_out     : out std_logic;
                               idc_bset_out    : out std_logic;
                               idc_bclr_out    : out std_logic;

                               idc_sbic_out    : out std_logic;
                               idc_sbis_out    : out std_logic;
              
                               idc_sbrs_out    : out std_logic;
                               idc_sbrc_out    : out std_logic;
              
                               idc_brbs_out    : out std_logic;
                               idc_brbc_out    : out std_logic;

                               idc_reti_out    : out std_logic);
end pm_fetch_dec_cm2;

architecture RTL of pm_fetch_dec_cm2 is

-- COPIES OF OUTPUTS
signal ramadr_reg_in  : std_logic_vector(15 downto 0); -- INPUT OF THE ADDRESS REGISTER
signal ramadr_reg_en  : std_logic;                     -- ADRESS REGISTER CLOCK ENABLE SIGNAL

signal irqack_int     : std_logic;
signal irqackad_int   : std_logic_vector(irqackad'range);

-- ####################################################
-- INTERNAL SIGNALS
-- ####################################################

-- NEW SIGNALS
signal   two_word_inst       : std_logic;                    -- CALL/JMP/STS/LDS INSTRUCTION INDICATOR

signal   ram_adr_int         : std_logic_vector (15 downto 0);
constant const_ram_to_reg    : std_logic_vector := "00000000000";  -- LD/LDS/LDD/ST/STS/STD ADDRESSING GENERAL PURPOSE REGISTER (R0-R31) 0x00..0x19
constant const_ram_to_io_a   : std_logic_vector := "00000000001";  -- LD/LDS/LDD/ST/STS/STD ADDRESSING GENERAL I/O PORT 0x20 0x3F 
constant const_ram_to_io_b   : std_logic_vector := "00000000010";  -- LD/LDS/LDD/ST/STS/STD ADDRESSING GENERAL I/O PORT 0x20 0x3F 

-- LD/LDD/ST/STD SIGNALS
signal adiw_sbiw_encoder_out : std_logic_vector (4 downto 0);
signal adiw_sbiw_encoder_mux_out : std_logic_vector (4 downto 0);


-- PROGRAM COUNTER SIGNALS
signal program_counter_tmp : std_logic_vector (15 downto 0); -- TO STORE PC DURING LPM/ELPM INSTRUCTIONS
signal program_counter     : std_logic_vector (15 downto 0);
signal program_counter_in  : std_logic_vector (15 downto 0);
signal program_counter_high_fr  : std_logic_vector (7 downto 0); -- TO STORE PC FOR CALL,IRQ,RCALL,ICALL

signal pc_low       : std_logic_vector (7 downto 0);
signal pc_high      : std_logic_vector (7 downto 0);


signal pc_low_en       : std_logic;
signal pc_high_en      : std_logic;

signal offset_brbx     : std_logic_vector (15 downto 0);    -- OFFSET FOR BRCS/BRCC   INSTRUCTION  !!CHECKED
signal offset_rxx      : std_logic_vector (15 downto 0);    -- OFFSET FOR RJMP/RCALL  INSTRUCTION  !!CHECKED

signal pa15_pm         : std_logic; -- ADDRESS LINE 15 FOR LPM/ELPM INSTRUCTIONS ('0' FOR LPM,RAMPZ(0) FOR ELPM) 

signal alu_reg_wr      : std_logic; -- ALU INSTRUCTIONS PRODUCING WRITE TO THE GENERAL PURPOSE REGISTER FILE	

-- DATA MEMORY,GENERAL PURPOSE REGISTERS AND I/O REGISTERS LOGIC

--! IMPORTANT NOTICE : OPERATIONS WHICH USE STACK POINTER (SPH:SPL) CAN NOT ACCCSESS GENERAL
-- PURPOSE REGISTER FILE AND INPUT/OUTPUT REGISTER FILE !
-- THESE OPERATIONS ARE : RCALL/ICALL/CALL/RET/RETI/PUSH/POP INSTRUCTIONS  AND INTERRUPT 

signal reg_file_adr_space  : std_logic; -- ACCSESS TO THE REGISTER FILE
signal io_file_adr_space   : std_logic; -- ACCSESS TO THE I/O FILE

-- STATE MACHINES SIGNALS
signal irq_start      : std_logic;

signal nirq_st0       : std_logic;
signal irq_st1        : std_logic;
signal irq_st2        : std_logic;
signal irq_st3        : std_logic;

signal ncall_st0      : std_logic;
signal call_st1       : std_logic;
signal call_st2       : std_logic;
signal call_st3       : std_logic;

signal nrcall_st0     : std_logic;
signal rcall_st1      : std_logic;
signal rcall_st2      : std_logic;

signal nicall_st0     : std_logic;
signal icall_st1      : std_logic;
signal icall_st2      : std_logic;

signal njmp_st0       : std_logic;
signal jmp_st1        : std_logic;
signal jmp_st2        : std_logic;

signal ijmp_st        : std_logic;

signal rjmp_st        : std_logic;

signal nret_st0       : std_logic;
signal ret_st1        : std_logic;
signal ret_st2        : std_logic;
signal ret_st3        : std_logic;

signal nreti_st0      : std_logic;
signal reti_st1       : std_logic;
signal reti_st2       : std_logic;
signal reti_st3       : std_logic;

signal brxx_st        : std_logic;  -- BRANCHES

signal adiw_st        : std_logic;
signal sbiw_st        : std_logic;

signal nskip_inst_st0 : std_logic;
signal skip_inst_st1  : std_logic;
signal skip_inst_st2  : std_logic;  -- ALL SKIP INSTRUCTIONS SBRS/SBRC/SBIS/SBIC/CPSE 

signal skip_inst_start  : std_logic;

signal nlpm_st0       : std_logic;
signal lpm_st1        : std_logic;
signal lpm_st2        : std_logic;

signal nelpm_st0      : std_logic;
signal elpm_st1       : std_logic;
signal elpm_st2       : std_logic;

--signal nsts_st0       : std_logic;
--signal sts_st1        : std_logic;
--signal sts_st2        : std_logic;

signal sts_st         : std_logic;

--signal nlds_st0       : std_logic;
--signal lds_st1        : std_logic;
--signal lds_st2        : std_logic;

signal lds_st           : std_logic;

signal st_st          : std_logic;
signal ld_st          : std_logic;

signal sbi_st         : std_logic;
signal cbi_st         : std_logic;

signal push_st        : std_logic;
signal pop_st	      : std_logic;

-- INTERNAL STATE MACHINES
signal nop_insert_st  : std_logic;
signal cpu_busy       : std_logic;

-- INTERNAL COPIES OF OUTPUTS
signal pc_int              : std_logic_vector (15 downto 0);
signal adr_int             : std_logic_vector (5 downto 0);
signal iore_int 		   : std_logic;
signal iowe_int            : std_logic;
signal ramadr_int          : std_logic_vector (15 downto 0);
signal ramre_int           : std_logic;
signal ramwe_int           : std_logic;
signal dbusout_int         : std_logic_vector (7 downto 0);

-- COMMAND REGISTER
signal instruction_reg      : std_logic_vector (15 downto 0); -- OUTPUT OF THE INSTRUCTION REGISTER
signal instruction_code_reg : std_logic_vector (15 downto 0); -- OUTPUT OF THE INSTRUCTION REGISTER WITH NOP INSERTION
signal instruction_reg_ena  : std_logic;                               -- CLOCK ENABLE


-- IRQ INTERNAL LOGIC
signal irq_int              : std_logic;
signal irq_vector_adr       : std_logic_vector(15 downto 0);

-- INTERRUPT RELATING REGISTERS
signal pc_for_interrupt : std_logic_vector(15 downto 0); 

-- DATA EXTRACTOR SIGNALS
signal dex_dat8_immed  : std_logic_vector (7 downto 0);  -- IMMEDIATE CONSTANT (DATA) -> ANDI,ORI,SUBI,SBCI,CPI,LDI
signal dex_dat6_immed  : std_logic_vector (5 downto 0);  -- IMMEDIATE CONSTANT (DATA) -> ADIW,SBIW
signal dex_adr12mem_s  : std_logic_vector (11 downto 0); -- RELATIVE ADDRESS (SIGNED) -> RCALL,RJMP
signal dex_adr6port    : std_logic_vector (5 downto 0);  -- I/O PORT ADDRESS -> IN,OUT
signal dex_adr5port    : std_logic_vector (4 downto 0);  -- I/O PORT ADDRESS -> CBI,SBI,SBIC,SBIS
signal dex_adr_disp    : std_logic_vector (5 downto 0);  -- DISPLACEMENT FO ADDDRESS -> STD,LDD
signal dex_condition   : std_logic_vector (2 downto 0);  -- CONDITION -> BRBC,BRBS
signal dex_bitnum_sreg : std_logic_vector (2 downto 0);  -- NUMBER OF BIT IN SREG -> BCLR,BSET
signal dex_adrreg_r    : std_logic_vector (4 downto 0);  -- SOURCE REGISTER ADDRESS -> .......
signal dex_adrreg_d    : std_logic_vector (4 downto 0);  -- DESTINATION REGISTER ADDRESS -> ......
signal dex_bitop_bitnum : std_logic_vector(2 downto 0);  -- NUMBER OF BIT FOR BIT ORIENTEDE OPERATION -> BST/BLD+SBI/CBI+SBIC/SBIS+SBRC/SBRS !! CHECKED
signal dex_brxx_offset : std_logic_vector (6 downto 0);  -- RELATIVE ADDRESS (SIGNED) -> BRBC,BRBS !! CHECKED
signal dex_adiw_sbiw_reg_adr  : std_logic_vector (1 downto 0);  -- ADDRESS OF THE LOW REGISTER FOR ADIW/SBIW INSTRUCTIONS

signal dex_adrreg_d_latched : std_logic_vector (4 downto 0);   --  STORE ADDRESS OF DESTINATION REGISTER FOR LDS/STS/POP INSTRUCTIONS
signal gp_reg_tmp           : std_logic_vector (7 downto 0);   --  STORE DATA FROM THE REGISTERS FOR STS,ST INSTRUCTIONS
signal cbi_sbi_io_adr_tmp   : std_logic_vector (4 downto 0);   --  STORE ADDRESS OF I/O PORT FOR CBI/SBI INSTRUCTION
signal cbi_sbi_bit_num_tmp  : std_logic_vector (2 downto 0);   --  STORE ADDRESS OF I/O PORT FOR CBI/SBI INSTRUCTION

-- INSTRUCTIONS DECODER SIGNALS

signal idc_adc     : std_logic; -- INSTRUCTION ADC
signal idc_add     : std_logic; -- INSTRUCTION ADD
signal idc_adiw    : std_logic; -- INSTRUCTION ADIW
signal idc_and     : std_logic; -- INSTRUCTION AND
signal idc_andi    : std_logic; -- INSTRUCTION ANDI
signal idc_asr     : std_logic; -- INSTRUCTION ASR

signal idc_bclr    : std_logic; -- INSTRUCTION BCLR
signal idc_bld     : std_logic; -- INSTRUCTION BLD
signal idc_brbc    : std_logic; -- INSTRUCTION BRBC
signal idc_brbs    : std_logic; -- INSTRUCTION BRBS
signal idc_bset    : std_logic; -- INSTRUCTION BSET
signal idc_bst     : std_logic; -- INSTRUCTION BST

signal idc_call    : std_logic; -- INSTRUCTION CALL
signal idc_cbi     : std_logic; -- INSTRUCTION CBI
signal idc_com     : std_logic; -- INSTRUCTION COM
signal idc_cp      : std_logic; -- INSTRUCTION CP
signal idc_cpc     : std_logic; -- INSTRUCTION CPC
signal idc_cpi     : std_logic; -- INSTRUCTION CPI
signal idc_cpse    : std_logic; -- INSTRUCTION CPSE

signal idc_dec     : std_logic; -- INSTRUCTION DEC

signal idc_elpm    : std_logic; -- INSTRUCTION ELPM
signal idc_eor     : std_logic; -- INSTRUCTION EOR

signal idc_icall   : std_logic; -- INSTRUCTION ICALL
signal idc_ijmp    : std_logic; -- INSTRUCTION IJMP

signal idc_in      : std_logic; -- INSTRUCTION IN
signal idc_inc     : std_logic; -- INSTRUCTION INC

signal idc_jmp     : std_logic; -- INSTRUCTION JMP

signal idc_ld_x    : std_logic; -- INSTRUCTION LD Rx,X ; LD Rx,X+ ;LD Rx,-X
signal idc_ld_y    : std_logic; -- INSTRUCTION LD Rx,Y ; LD Rx,Y+ ;LD Rx,-Y
signal idc_ldd_y   : std_logic; -- INSTRUCTION LDD Rx,Y+q
signal idc_ld_z    : std_logic; -- INSTRUCTION LD Rx,Z ; LD Rx,Z+ ;LD Rx,-Z
signal idc_ldd_z   : std_logic; -- INSTRUCTION LDD Rx,Z+q

signal idc_ldi     : std_logic; -- INSTRUCTION LDI
signal idc_lds     : std_logic; -- INSTRUCTION LDS
signal idc_lpm     : std_logic; -- INSTRUCTION LPM
signal idc_lsr     : std_logic; -- INSTRUCTION LSR

signal idc_mov     : std_logic; -- INSTRUCTION MOV
signal idc_mul     : std_logic; -- INSTRUCTION MUL

signal idc_neg     : std_logic; -- INSTRUCTION NEG
signal idc_nop     : std_logic; -- INSTRUCTION NOP

signal idc_or      : std_logic; -- INSTRUCTION OR
signal idc_ori     : std_logic; -- INSTRUCTION ORI
signal idc_out     : std_logic; -- INSTRUCTION OUT

signal idc_pop     : std_logic; -- INSTRUCTION POP
signal idc_push    : std_logic; -- INSTRUCTION PUSH

signal idc_rcall   : std_logic; -- INSTRUCTION RCALL
signal idc_ret     : std_logic; -- INSTRUCTION RET
signal idc_reti    : std_logic; -- INSTRUCTION RETI
signal idc_rjmp    : std_logic; -- INSTRUCTION RJMP
signal idc_ror     : std_logic; -- INSTRUCTION ROR

signal idc_sbc     : std_logic; -- INSTRUCTION SBC
signal idc_sbci    : std_logic; -- INSTRUCTION SBCI
signal idc_sbi     : std_logic; -- INSTRUCTION SBI
signal idc_sbic    : std_logic; -- INSTRUCTION SBIC
signal idc_sbis    : std_logic; -- INSTRUCTION SBIS
signal idc_sbiw    : std_logic; -- INSTRUCTION SBIW
signal idc_sbrc    : std_logic; -- INSTRUCTION SBRC
signal idc_sbrs    : std_logic; -- INSTRUCTION SBRS
signal idc_sleep   : std_logic; -- INSTRUCTION SLEEP

signal idc_st_x    : std_logic; -- INSTRUCTION LD X,Rx ; LD X+,Rx ;LD -X,Rx
signal idc_st_y    : std_logic; -- INSTRUCTION LD Y,Rx ; LD Y+,Rx ;LD -Y,Rx
signal idc_std_y   : std_logic; -- INSTRUCTION LDD Y+q,Rx
signal idc_st_z    : std_logic; -- INSTRUCTION LD Z,Rx ; LD Z+,Rx ;LD -Z,Rx
signal idc_std_z   : std_logic; -- INSTRUCTION LDD Z+q,Rx

signal idc_sts     : std_logic; -- INSTRUCTION STS
signal idc_sub     : std_logic; -- INSTRUCTION SUB
signal idc_subi    : std_logic; -- INSTRUCTION SUBI
signal idc_swap    : std_logic; -- INSTRUCTION SWAP

signal idc_wdr     : std_logic; -- INSTRUCTION WDR

-- ADDITIONAL SIGNALS
signal idc_psinc   :  std_logic; -- POST INCREMENT FLAG FOR LD,ST INSTRUCTIONS
signal idc_prdec   :  std_logic; -- PRE DECREMENT  FLAG FOR LD,ST INSTRUCTIONS

-- ##################################################

-- SREG FLAGS WRITE ENABLE SIGNALS

--alias sreg_c_wr_en  : std_logic is sreg_fl_wr_en(0);
--alias sreg_z_wr_en  : std_logic is sreg_fl_wr_en(1);
--alias sreg_n_wr_en  : std_logic is sreg_fl_wr_en(2);
--alias sreg_v_wr_en  : std_logic is sreg_fl_wr_en(3);
--alias sreg_s_wr_en  : std_logic is sreg_fl_wr_en(4);
--alias sreg_h_wr_en  : std_logic is sreg_fl_wr_en(5);
--alias sreg_t_wr_en  : std_logic is sreg_fl_wr_en(6);
--alias sreg_i_wr_en  : std_logic is sreg_fl_wr_en(7);

signal sreg_c_wr_en  : std_logic; --  is sreg_fl_wr_en(0);
signal sreg_z_wr_en  : std_logic; --  is sreg_fl_wr_en(1);
signal sreg_n_wr_en  : std_logic; --  is sreg_fl_wr_en(2);
signal sreg_v_wr_en  : std_logic; --  is sreg_fl_wr_en(3);
signal sreg_s_wr_en  : std_logic; --  is sreg_fl_wr_en(4);
signal sreg_h_wr_en  : std_logic; --  is sreg_fl_wr_en(5);
signal sreg_t_wr_en  : std_logic; --  is sreg_fl_wr_en(6);
signal sreg_i_wr_en  : std_logic; --  is sreg_fl_wr_en(7);

signal sreg_bop_wr_en : std_logic_vector (7 downto 0);                

signal sreg_adr_eq  : std_logic;
-- &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

signal inst_cml_1 :  std_logic_vector ( 15 downto 0 );
signal sp_ndown_up_cml_out :  std_logic;
signal sp_en_cml_out :  std_logic;
signal cpuwait_cml_1 :  std_logic;
signal irqlines_cml_1 :  std_logic_vector ( 22 downto 0 );
signal reg_rd_out_cml_1 :  std_logic_vector ( 7 downto 0 );
signal reg_rd_in_cml_out :  std_logic_vector ( 7 downto 0 );
signal reg_rr_out_cml_1 :  std_logic_vector ( 7 downto 0 );
signal spl_out_cml_1 :  std_logic_vector ( 7 downto 0 );
signal sph_out_cml_1 :  std_logic_vector ( 7 downto 0 );
signal rampz_out_cml_1 :  std_logic_vector ( 7 downto 0 );
signal bitpr_io_out_cml_1 :  std_logic_vector ( 7 downto 0 );
signal irqack_cml_out :  std_logic;
signal irqack_int_cml_1 :  std_logic;
signal irqackad_cml_out :  std_logic_vector ( 4 downto 0 );
signal irqackad_int_cml_1 :  std_logic_vector ( irqackad 'range);
signal two_word_inst_cml_1 :  std_logic;
signal adiw_sbiw_encoder_out_cml_1 :  std_logic_vector ( 4 downto 0 );
signal adiw_sbiw_encoder_mux_out_cml_1 :  std_logic_vector ( 4 downto 0 );
signal program_counter_tmp_cml_1 :  std_logic_vector ( 15 downto 0 );
signal program_counter_cml_1 :  std_logic_vector ( 15 downto 0 );
signal program_counter_high_fr_cml_1 :  std_logic_vector ( 7 downto 0 );
signal pc_low_cml_1 :  std_logic_vector ( 7 downto 0 );
signal pc_high_cml_1 :  std_logic_vector ( 7 downto 0 );
signal reg_rd_wr_cml_out :  std_logic;
signal reg_file_adr_space_cml_1 :  std_logic;
signal io_file_adr_space_cml_1 :  std_logic;
signal nirq_st0_cml_1 :  std_logic;
signal irq_st1_cml_1 :  std_logic;
signal irq_st2_cml_1 :  std_logic;
signal irq_st3_cml_1 :  std_logic;
signal ncall_st0_cml_1 :  std_logic;
signal call_st1_cml_1 :  std_logic;
signal call_st2_cml_1 :  std_logic;
signal call_st3_cml_1 :  std_logic;
signal nrcall_st0_cml_1 :  std_logic;
signal rcall_st1_cml_1 :  std_logic;
signal rcall_st2_cml_1 :  std_logic;
signal nicall_st0_cml_1 :  std_logic;
signal icall_st1_cml_1 :  std_logic;
signal icall_st2_cml_1 :  std_logic;
signal njmp_st0_cml_1 :  std_logic;
signal jmp_st1_cml_1 :  std_logic;
signal jmp_st2_cml_1 :  std_logic;
signal ijmp_st_cml_1 :  std_logic;
signal rjmp_st_cml_1 :  std_logic;
signal nret_st0_cml_1 :  std_logic;
signal ret_st1_cml_1 :  std_logic;
signal ret_st2_cml_1 :  std_logic;
signal ret_st3_cml_1 :  std_logic;
signal nreti_st0_cml_1 :  std_logic;
signal reti_st1_cml_1 :  std_logic;
signal reti_st2_cml_1 :  std_logic;
signal sreg_fl_in_cml_out :  std_logic_vector ( 7 downto 0 );
signal reti_st3_cml_1 :  std_logic;
signal brxx_st_cml_1 :  std_logic;
signal adiw_st_cml_1 :  std_logic;
signal sbiw_st_cml_1 :  std_logic;
signal nskip_inst_st0_cml_1 :  std_logic;
signal skip_inst_st1_cml_1 :  std_logic;
signal skip_inst_st2_cml_1 :  std_logic;
signal nlpm_st0_cml_1 :  std_logic;
signal lpm_st1_cml_1 :  std_logic;
signal lpm_st2_cml_1 :  std_logic;
signal sts_st_cml_1 :  std_logic;
signal lds_st_cml_1 :  std_logic;
signal st_st_cml_1 :  std_logic;
signal ld_st_cml_1 :  std_logic;
signal sbi_st_cml_1 :  std_logic;
signal cbi_st_cml_1 :  std_logic;
signal push_st_cml_1 :  std_logic;
signal pop_st_cml_1 :  std_logic;
signal iowe_cml_out :  std_logic;
signal iowe_int_cml_1 :  std_logic;
signal ramadr_int_cml_1 :  std_logic_vector ( 15 downto 0 );
signal ramre_int_cml_1 :  std_logic;
signal ramwe_int_cml_1 :  std_logic;
signal instruction_reg_cml_1 :  std_logic_vector ( 15 downto 0 );
signal instruction_code_reg_cml_1 :  std_logic_vector ( 15 downto 0 );
signal pc_for_interrupt_cml_1 :  std_logic_vector ( 15 downto 0 );
signal dex_dat8_immed_cml_1 :  std_logic_vector ( 7 downto 0 );
signal dex_adr5port_cml_1 :  std_logic_vector ( 4 downto 0 );
signal dex_adrreg_d_cml_1 :  std_logic_vector ( 4 downto 0 );
signal dex_bitop_bitnum_cml_1 :  std_logic_vector ( 2 downto 0 );
signal dex_adrreg_d_latched_cml_1 :  std_logic_vector ( 4 downto 0 );
signal gp_reg_tmp_cml_1 :  std_logic_vector ( 7 downto 0 );
signal cbi_sbi_io_adr_tmp_cml_1 :  std_logic_vector ( 4 downto 0 );
signal cbi_sbi_bit_num_tmp_cml_1 :  std_logic_vector ( 2 downto 0 );
signal idc_adc_cml_1 :  std_logic;
signal idc_add_cml_1 :  std_logic;
signal idc_adiw_cml_1 :  std_logic;
signal idc_and_cml_1 :  std_logic;
signal idc_andi_cml_1 :  std_logic;
signal idc_asr_cml_1 :  std_logic;
signal idc_bclr_out_cml_out :  std_logic;
signal idc_bclr_cml_1 :  std_logic;
signal idc_brbc_cml_1 :  std_logic;
signal idc_brbs_cml_1 :  std_logic;
signal idc_bset_out_cml_out :  std_logic;
signal idc_bset_cml_1 :  std_logic;
signal idc_call_cml_1 :  std_logic;
signal idc_cbi_cml_1 :  std_logic;
signal idc_com_cml_1 :  std_logic;
signal idc_cp_cml_1 :  std_logic;
signal idc_cpc_cml_1 :  std_logic;
signal idc_cpi_cml_1 :  std_logic;
signal idc_cpse_cml_1 :  std_logic;
signal idc_dec_cml_1 :  std_logic;
signal idc_elpm_cml_1 :  std_logic;
signal idc_eor_cml_1 :  std_logic;
signal idc_icall_cml_1 :  std_logic;
signal idc_ijmp_cml_1 :  std_logic;
signal idc_in_cml_1 :  std_logic;
signal idc_inc_cml_1 :  std_logic;
signal idc_jmp_cml_1 :  std_logic;
signal reg_h_wr_cml_out :  std_logic;
signal reg_h_adr_cml_out :  std_logic_vector ( 2 downto 0 );
signal idc_ld_x_cml_1 :  std_logic;
signal idc_ld_y_cml_1 :  std_logic;
signal idc_ldd_y_cml_1 :  std_logic;
signal idc_ld_z_cml_1 :  std_logic;
signal idc_ldd_z_cml_1 :  std_logic;
signal idc_ldi_cml_1 :  std_logic;
signal idc_lds_cml_1 :  std_logic;
signal idc_lpm_cml_1 :  std_logic;
signal idc_lsr_cml_1 :  std_logic;
signal idc_neg_cml_1 :  std_logic;
signal idc_or_cml_1 :  std_logic;
signal idc_ori_cml_1 :  std_logic;
signal idc_out_cml_1 :  std_logic;
signal idc_pop_cml_1 :  std_logic;
signal idc_push_cml_1 :  std_logic;
signal idc_rcall_cml_1 :  std_logic;
signal idc_ret_cml_1 :  std_logic;
signal idc_reti_out_cml_out :  std_logic;
signal idc_reti_cml_1 :  std_logic;
signal idc_rjmp_cml_1 :  std_logic;
signal idc_ror_cml_1 :  std_logic;
signal idc_sbc_cml_1 :  std_logic;
signal idc_sbci_cml_1 :  std_logic;
signal idc_sbi_cml_1 :  std_logic;
signal idc_sbic_cml_1 :  std_logic;
signal idc_sbis_cml_1 :  std_logic;
signal idc_sbiw_cml_1 :  std_logic;
signal idc_sbrc_cml_1 :  std_logic;
signal idc_sbrs_cml_1 :  std_logic;
signal idc_st_x_cml_1 :  std_logic;
signal idc_st_y_cml_1 :  std_logic;
signal idc_std_y_cml_1 :  std_logic;
signal idc_st_z_cml_1 :  std_logic;
signal idc_std_z_cml_1 :  std_logic;
signal idc_sts_cml_1 :  std_logic;
signal idc_sub_cml_1 :  std_logic;
signal idc_subi_cml_1 :  std_logic;
signal idc_swap_cml_1 :  std_logic;
signal sreg_bop_wr_en_cml_1 :  std_logic_vector ( 7 downto 0 );
signal sreg_adr_eq_cml_1 :  std_logic;

begin



process(cp2_cml_1) begin
if (cp2_cml_1 = '1' and cp2_cml_1'event) then
	inst_cml_1 <= inst;
	cpuwait_cml_1 <= cpuwait;
	irqlines_cml_1 <= irqlines;
	reg_rd_out_cml_1 <= reg_rd_out;
	reg_rr_out_cml_1 <= reg_rr_out;
	spl_out_cml_1 <= spl_out;
	sph_out_cml_1 <= sph_out;
	rampz_out_cml_1 <= rampz_out;
	bitpr_io_out_cml_1 <= bitpr_io_out;
	irqack_int_cml_1 <= irqack_int;
	irqackad_int_cml_1 <= irqackad_int;
	two_word_inst_cml_1 <= two_word_inst;
	adiw_sbiw_encoder_out_cml_1 <= adiw_sbiw_encoder_out;
	adiw_sbiw_encoder_mux_out_cml_1 <= adiw_sbiw_encoder_mux_out;
	program_counter_tmp_cml_1 <= program_counter_tmp;
	program_counter_cml_1 <= program_counter;
	program_counter_high_fr_cml_1 <= program_counter_high_fr;
	pc_low_cml_1 <= pc_low;
	pc_high_cml_1 <= pc_high;
	reg_file_adr_space_cml_1 <= reg_file_adr_space;
	io_file_adr_space_cml_1 <= io_file_adr_space;
	nirq_st0_cml_1 <= nirq_st0;
	irq_st1_cml_1 <= irq_st1;
	irq_st2_cml_1 <= irq_st2;
	irq_st3_cml_1 <= irq_st3;
	ncall_st0_cml_1 <= ncall_st0;
	call_st1_cml_1 <= call_st1;
	call_st2_cml_1 <= call_st2;
	call_st3_cml_1 <= call_st3;
	nrcall_st0_cml_1 <= nrcall_st0;
	rcall_st1_cml_1 <= rcall_st1;
	rcall_st2_cml_1 <= rcall_st2;
	nicall_st0_cml_1 <= nicall_st0;
	icall_st1_cml_1 <= icall_st1;
	icall_st2_cml_1 <= icall_st2;
	njmp_st0_cml_1 <= njmp_st0;
	jmp_st1_cml_1 <= jmp_st1;
	jmp_st2_cml_1 <= jmp_st2;
	ijmp_st_cml_1 <= ijmp_st;
	rjmp_st_cml_1 <= rjmp_st;
	nret_st0_cml_1 <= nret_st0;
	ret_st1_cml_1 <= ret_st1;
	ret_st2_cml_1 <= ret_st2;
	ret_st3_cml_1 <= ret_st3;
	nreti_st0_cml_1 <= nreti_st0;
	reti_st1_cml_1 <= reti_st1;
	reti_st2_cml_1 <= reti_st2;
	reti_st3_cml_1 <= reti_st3;
	brxx_st_cml_1 <= brxx_st;
	adiw_st_cml_1 <= adiw_st;
	sbiw_st_cml_1 <= sbiw_st;
	nskip_inst_st0_cml_1 <= nskip_inst_st0;
	skip_inst_st1_cml_1 <= skip_inst_st1;
	skip_inst_st2_cml_1 <= skip_inst_st2;
	nlpm_st0_cml_1 <= nlpm_st0;
	lpm_st1_cml_1 <= lpm_st1;
	lpm_st2_cml_1 <= lpm_st2;
	sts_st_cml_1 <= sts_st;
	lds_st_cml_1 <= lds_st;
	st_st_cml_1 <= st_st;
	ld_st_cml_1 <= ld_st;
	sbi_st_cml_1 <= sbi_st;
	cbi_st_cml_1 <= cbi_st;
	push_st_cml_1 <= push_st;
	pop_st_cml_1 <= pop_st;
	iowe_int_cml_1 <= iowe_int;
	ramadr_int_cml_1 <= ramadr_int;
	ramre_int_cml_1 <= ramre_int;
	ramwe_int_cml_1 <= ramwe_int;
	instruction_reg_cml_1 <= instruction_reg;
	instruction_code_reg_cml_1 <= instruction_code_reg;
	pc_for_interrupt_cml_1 <= pc_for_interrupt;
	dex_dat8_immed_cml_1 <= dex_dat8_immed;
	dex_adr5port_cml_1 <= dex_adr5port;
	dex_adrreg_d_cml_1 <= dex_adrreg_d;
	dex_bitop_bitnum_cml_1 <= dex_bitop_bitnum;
	dex_adrreg_d_latched_cml_1 <= dex_adrreg_d_latched;
	gp_reg_tmp_cml_1 <= gp_reg_tmp;
	cbi_sbi_io_adr_tmp_cml_1 <= cbi_sbi_io_adr_tmp;
	cbi_sbi_bit_num_tmp_cml_1 <= cbi_sbi_bit_num_tmp;
	idc_adc_cml_1 <= idc_adc;
	idc_add_cml_1 <= idc_add;
	idc_adiw_cml_1 <= idc_adiw;
	idc_and_cml_1 <= idc_and;
	idc_andi_cml_1 <= idc_andi;
	idc_asr_cml_1 <= idc_asr;
	idc_bclr_cml_1 <= idc_bclr;
	idc_brbc_cml_1 <= idc_brbc;
	idc_brbs_cml_1 <= idc_brbs;
	idc_bset_cml_1 <= idc_bset;
	idc_call_cml_1 <= idc_call;
	idc_cbi_cml_1 <= idc_cbi;
	idc_com_cml_1 <= idc_com;
	idc_cp_cml_1 <= idc_cp;
	idc_cpc_cml_1 <= idc_cpc;
	idc_cpi_cml_1 <= idc_cpi;
	idc_cpse_cml_1 <= idc_cpse;
	idc_dec_cml_1 <= idc_dec;
	idc_elpm_cml_1 <= idc_elpm;
	idc_eor_cml_1 <= idc_eor;
	idc_icall_cml_1 <= idc_icall;
	idc_ijmp_cml_1 <= idc_ijmp;
	idc_in_cml_1 <= idc_in;
	idc_inc_cml_1 <= idc_inc;
	idc_jmp_cml_1 <= idc_jmp;
	idc_ld_x_cml_1 <= idc_ld_x;
	idc_ld_y_cml_1 <= idc_ld_y;
	idc_ldd_y_cml_1 <= idc_ldd_y;
	idc_ld_z_cml_1 <= idc_ld_z;
	idc_ldd_z_cml_1 <= idc_ldd_z;
	idc_ldi_cml_1 <= idc_ldi;
	idc_lds_cml_1 <= idc_lds;
	idc_lpm_cml_1 <= idc_lpm;
	idc_lsr_cml_1 <= idc_lsr;
	idc_neg_cml_1 <= idc_neg;
	idc_or_cml_1 <= idc_or;
	idc_ori_cml_1 <= idc_ori;
	idc_out_cml_1 <= idc_out;
	idc_pop_cml_1 <= idc_pop;
	idc_push_cml_1 <= idc_push;
	idc_rcall_cml_1 <= idc_rcall;
	idc_ret_cml_1 <= idc_ret;
	idc_reti_cml_1 <= idc_reti;
	idc_rjmp_cml_1 <= idc_rjmp;
	idc_ror_cml_1 <= idc_ror;
	idc_sbc_cml_1 <= idc_sbc;
	idc_sbci_cml_1 <= idc_sbci;
	idc_sbi_cml_1 <= idc_sbi;
	idc_sbic_cml_1 <= idc_sbic;
	idc_sbis_cml_1 <= idc_sbis;
	idc_sbiw_cml_1 <= idc_sbiw;
	idc_sbrc_cml_1 <= idc_sbrc;
	idc_sbrs_cml_1 <= idc_sbrs;
	idc_st_x_cml_1 <= idc_st_x;
	idc_st_y_cml_1 <= idc_st_y;
	idc_std_y_cml_1 <= idc_std_y;
	idc_st_z_cml_1 <= idc_st_z;
	idc_std_z_cml_1 <= idc_std_z;
	idc_sts_cml_1 <= idc_sts;
	idc_sub_cml_1 <= idc_sub;
	idc_subi_cml_1 <= idc_subi;
	idc_swap_cml_1 <= idc_swap;
	sreg_bop_wr_en_cml_1 <= sreg_bop_wr_en;
	sreg_adr_eq_cml_1 <= sreg_adr_eq;
end if;
end process;
sp_ndown_up <= sp_ndown_up_cml_out;
sp_en <= sp_en_cml_out;
reg_rd_in <= reg_rd_in_cml_out;
irqack <= irqack_cml_out;
irqackad <= irqackad_cml_out;
reg_rd_wr <= reg_rd_wr_cml_out;
sreg_fl_in <= sreg_fl_in_cml_out;
iowe <= iowe_cml_out;
idc_bclr_out <= idc_bclr_out_cml_out;
idc_bset_out <= idc_bset_out_cml_out;
reg_h_wr <= reg_h_wr_cml_out;
reg_h_adr <= reg_h_adr_cml_out;
idc_reti_out <= idc_reti_out_cml_out;


sreg_fl_wr_en <= sreg_i_wr_en & sreg_t_wr_en & sreg_h_wr_en & sreg_s_wr_en & sreg_v_wr_en & sreg_n_wr_en & sreg_z_wr_en & sreg_c_wr_en;


-- INSTRUCTION FETCH
instruction_reg_ena <= '1'; -- FOR TEST

-- SynEDA CoreMultiplier
-- assignment(s): instruction_reg
-- replace(s): inst, instruction_reg

instruction_fetch:process(cp2,ireset)
begin
if ireset='0' then                              -- RESET
instruction_reg <= (others => '0');
elsif (cp2='1' and cp2'event) then instruction_reg <= instruction_reg_cml_1;            -- CLOCK
 if (cp2en='1') then 							  -- Clock enable
  if instruction_reg_ena='1' then               
   instruction_reg <= inst_cml_1;
  end if;
 end if; 
end if;
end process;

-- TWO WORDS INSTRUCTION DETECTOR (CONNECTED DIRECTLY TO THE INSTRUCTION REGISTER)
two_word_inst <= '1' when 
((instruction_reg(15 downto 9)&instruction_reg(3 downto 1)="1001010111") or    -- CALL
 (instruction_reg(15 downto 9)&instruction_reg(3 downto 1)="1001010110")) or   -- JMP
 (instruction_reg(15 downto 9)&instruction_reg(3 downto 0) = "10010000000") or -- LDS
 (instruction_reg(15 downto 9)&instruction_reg(3 downto 0) = "10010010000")    -- STS
   else '0';  -- TO DETECT CALL/JMP/LDS/STS INSTRUCTIONS FOR SBRS/SBRC/SBIS/SBIC/CPSE

	
	
-- DATA EXTRACTOR (CONNECTED DIRECTLY TO THE INSTRUCTION REGISTER)
dex_dat8_immed <= instruction_reg(11 downto 8) & instruction_reg(3 downto 0);
dex_dat6_immed <= instruction_reg(7 downto 6) & instruction_reg(3 downto 0);
-- SynEDA CoreMultiplier
-- assignment(s): dex_adr12mem_s
-- replace(s): instruction_reg

dex_adr12mem_s <= instruction_reg_cml_1(11 downto 0); 
dex_adr6port <= instruction_reg(10 downto 9) & instruction_reg(3 downto 0);    
dex_adr5port <= instruction_reg(7 downto 3);  
-- SynEDA CoreMultiplier
-- assignment(s): dex_adr_disp
-- replace(s): instruction_reg

dex_adr_disp <= instruction_reg_cml_1(13) & instruction_reg_cml_1(11 downto 10) & instruction_reg_cml_1(2 downto 0);      
dex_condition <= instruction_reg(2 downto 0);   
dex_bitop_bitnum <= instruction_reg(2 downto 0);      -- NUMBER(POSITION) OF TESTING BIT IN SBRC/SBRS/SBIC/SBIS INSTRUCTION
dex_bitnum_sreg <= instruction_reg(6 downto 4);    
dex_adrreg_r  <=  instruction_reg(9) & instruction_reg(3 downto 0);
dex_adrreg_d  <= instruction_reg(8 downto 4);     
-- SynEDA CoreMultiplier
-- assignment(s): dex_brxx_offset
-- replace(s): instruction_reg

dex_brxx_offset <= instruction_reg_cml_1(9 downto 3);       -- OFFSET FOR BRBC/BRBS     
dex_adiw_sbiw_reg_adr <= instruction_reg(5 downto 4); -- ADDRESS OF THE LOW REGISTER FOR ADIW/SBIW INSTRUCTIONS
--dex_adrindreg <= instruction_reg(3 downto 2);     

-- SynEDA CoreMultiplier
-- assignment(s): dex_adrreg_d_latched
-- replace(s): dex_adrreg_d, dex_adrreg_d_latched, idc_ld_x, idc_ld_y, idc_ldd_y, idc_ld_z, idc_ldd_z, idc_lds, idc_pop, idc_st_x, idc_st_y, idc_std_y, idc_st_z, idc_std_z, idc_sts

-- LATCH Rd ADDDRESS FOR LDS/STS/POP INSTRUCTIONS
latcht_rd_adr:process(cp2,ireset)
begin
if ireset ='0' then
dex_adrreg_d_latched <= (others => '0');
elsif (cp2='1' and cp2'event) then dex_adrreg_d_latched <= dex_adrreg_d_latched_cml_1;
 if (cp2en='1') then 							  -- Clock enable
  if ((idc_ld_x_cml_1 or idc_ld_y_cml_1 or idc_ldd_y_cml_1 or idc_ld_z_cml_1 or idc_ldd_z_cml_1) or idc_sts_cml_1 or 
	  (idc_st_x_cml_1  or idc_st_y_cml_1 or idc_std_y_cml_1 or idc_st_z_cml_1 or idc_std_z_cml_1)or idc_lds_cml_1 or 
	   idc_pop_cml_1)='1' then 
   dex_adrreg_d_latched <= dex_adrreg_d_cml_1;
  end if;
 end if;
end if;
end process;
-- +++++++++++++++++++++++++++++++++++++++++++++++++


-- R24:R25/R26:R27/R28:R29/R30:R31 ADIW/SBIW  ADDRESS CONTROL LOGIC
adiw_sbiw_encoder_out <= "11"&dex_adiw_sbiw_reg_adr&'0';

-- SynEDA CoreMultiplier
-- assignment(s): adiw_sbiw_encoder_mux_out
-- replace(s): adiw_sbiw_encoder_out, adiw_sbiw_encoder_mux_out

adiw_sbiw_high_reg_adr:process(cp2,ireset)
begin
if ireset ='0' then
adiw_sbiw_encoder_mux_out <= (others=>'0'); 
elsif(cp2='1' and cp2'event) then adiw_sbiw_encoder_mux_out <= adiw_sbiw_encoder_mux_out_cml_1;
 if (cp2en='1') then 							  -- Clock enable
  adiw_sbiw_encoder_mux_out <= adiw_sbiw_encoder_out_cml_1 +1;
 end if;
end if;
end process;
	
-- ##########################

-- NOP INSERTION

--instruction_code_reg <= instruction_reg when nop_insert_st='0' else (others => '0');
instruction_code_reg <= (others => '0') when (nop_insert_st='1') else -- NOP
                        instruction_reg;												-- Instruction 

	
nop_insert_st <= adiw_st or sbiw_st or cbi_st or sbi_st or rjmp_st or ijmp_st or pop_st or push_st or
              brxx_st or ld_st or st_st or ncall_st0 or nirq_st0 or nret_st0 or nreti_st0 or nlpm_st0 or njmp_st0 or
              nrcall_st0 or nicall_st0 or sts_st or lds_st or nskip_inst_st0;

			  
-- INSTRUCTION DECODER (CONNECTED AFTER NOP INSERTION LOGIC)

idc_adc  <= '1' when instruction_code_reg(15 downto 10) = "000111" else '0'; -- 000111XXXXXXXXXX
idc_add  <= '1' when instruction_code_reg(15 downto 10) = "000011" else '0'; -- 000011XXXXXXXXXX

idc_adiw <= '1' when instruction_code_reg(15 downto 8) = "10010110" else '0'; -- 10010110XXXXXXXX

idc_and  <= '1' when instruction_code_reg(15 downto 10) = "001000" else '0'; -- 001000XXXXXXXXXX
idc_andi <= '1' when instruction_code_reg(15 downto 12) = "0111" else '0'; -- 0111XXXXXXXXXXXX

idc_asr  <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010100101" else '0'; -- 1001010XXXXX0101

idc_bclr <= '1' when instruction_code_reg(15 downto 7)&instruction_code_reg(3 downto 0) = "1001010011000" else '0'; -- 100101001XXX1000

-- SynEDA CoreMultiplier
-- assignment(s): idc_bld
-- replace(s): instruction_code_reg

idc_bld  <= '1' when instruction_code_reg_cml_1(15 downto 9)&instruction_code_reg_cml_1(3) = "11111000" else '0'; -- 1111100XXXXX0XXX

idc_brbc <= '1' when instruction_code_reg(15 downto 10) = "111101" else '0'; -- 111101XXXXXXXXXX
idc_brbs <= '1' when instruction_code_reg(15 downto 10) = "111100" else '0'; -- 111100XXXXXXXXXX

idc_bset <= '1' when instruction_code_reg(15 downto 7)&instruction_code_reg(3 downto 0) = "1001010001000" else '0'; -- 100101000XXX1000

-- SynEDA CoreMultiplier
-- assignment(s): idc_bst
-- replace(s): instruction_code_reg

idc_bst  <= '1' when instruction_code_reg_cml_1(15 downto 9) = "1111101" else '0'; -- 1111101XXXXXXXXX

idc_call <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 1) = "1001010111" else '0'; -- 1001010XXXXX111X

idc_cbi  <= '1' when instruction_code_reg(15 downto 8) = "10011000" else '0'; -- 10011000XXXXXXXX

idc_com  <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010100000" else '0'; -- 1001010XXXXX0000

idc_cp   <= '1' when instruction_code_reg(15 downto 10) = "000101" else '0'; -- 000101XXXXXXXXXX

idc_cpc  <= '1' when instruction_code_reg(15 downto 10) = "000001" else '0'; -- 000001XXXXXXXXXX

idc_cpi  <= '1' when instruction_code_reg(15 downto 12) = "0011" else '0'; -- 0011XXXXXXXXXXXX

idc_cpse <= '1' when instruction_code_reg(15 downto 10) = "000100" else '0'; -- 000100XXXXXXXXXX

idc_dec  <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010101010" else '0'; -- 1001010XXXXX1010

idc_elpm <= '1' when instruction_code_reg = "1001010111011000" else '0'; -- 1001010111011000

idc_eor  <= '1' when instruction_code_reg(15 downto 10) = "001001" else '0'; -- 001001XXXXXXXXXX

idc_icall<= '1' when instruction_code_reg(15 downto 8)&instruction_code_reg(3 downto 0) = "100101011001" else '0'; -- 10010101XXXX1001

idc_ijmp <= '1' when instruction_code_reg(15 downto 8)&instruction_code_reg(3 downto 0) = "100101001001" else '0'; -- 10010100XXXX1001

idc_in   <= '1' when instruction_code_reg(15 downto 11) = "10110" else '0'; -- 10110XXXXXXXXXXX

idc_inc  <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010100011" else '0'; -- 1001010XXXXX0011

idc_jmp  <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 1) = "1001010110" else '0'; -- 1001010XXXXX110X


-- LD,LDD 
idc_ld_x <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010001100" or 
                     instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010001101"	or
					 instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010001110" else '0';
		
idc_ld_y <= '1' when (instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010001001" or 
					  instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010001010") else '0'; 

idc_ldd_y<= '1' when instruction_code_reg(15 downto 14)&instruction_code_reg(12)&instruction_code_reg(9)&instruction_code_reg(3) = "10001" else '0'; -- 10X0XX0XXXXX1XXX    

idc_ld_z <= '1' when (instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010000001" or 
					  instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010000010") else '0'; 

idc_ldd_z<= '1' when instruction_code_reg(15 downto 14)&instruction_code_reg(12)&instruction_code_reg(9)&instruction_code_reg(3) = "10000" else '0'; -- 10X0XX0XXXXX0XXX       
-- ######


idc_ldi <= '1' when instruction_code_reg(15 downto 12) = "1110" else '0'; -- 1110XXXXXXXXXXXX

idc_lds <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010000000" else '0'; -- 1001000XXXXX0000

idc_lpm <= '1' when instruction_code_reg = "1001010111001000" else '0'; -- 1001010111001000

idc_lsr <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010100110" else '0'; -- 1001010XXXXX0110

-- SynEDA CoreMultiplier
-- assignment(s): idc_mov
-- replace(s): instruction_code_reg

idc_mov <= '1' when instruction_code_reg_cml_1(15 downto 10) = "001011" else '0'; -- 001011XXXXXXXXXX

idc_mul <= '1' when instruction_code_reg(15 downto 10) = "100111" else '0'; -- 100111XXXXXXXXXX

idc_neg <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010100001" else '0'; -- 1001010XXXXX0001

idc_nop <= '1' when instruction_code_reg = "0000000000000000" else '0'; -- 0000000000000000

idc_or  <= '1' when instruction_code_reg(15 downto 10) = "001010" else '0'; -- 001010XXXXXXXXXX

idc_ori <= '1' when instruction_code_reg(15 downto 12) = "0110" else '0'; -- 0110XXXXXXXXXXXX 

idc_out <= '1' when instruction_code_reg(15 downto 11) = "10111" else '0'; -- 10111XXXXXXXXXXX

idc_pop <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010001111" else '0'; -- 1001000XXXXX1111

idc_push<= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010011111" else '0'; -- 1001001XXXXX1111

idc_rcall<= '1' when instruction_code_reg(15 downto 12) = "1101" else '0'; -- 1101XXXXXXXXXXXX

idc_ret  <= '1' when instruction_code_reg(15 downto 7)&instruction_code_reg(4 downto 0) = "10010101001000" else '0'; -- 100101010XX01000

idc_reti <= '1' when instruction_code_reg(15 downto 7)&instruction_code_reg(4 downto 0) = "10010101011000" else '0'; -- 100101010XX11000

idc_rjmp <= '1' when instruction_code_reg(15 downto 12) = "1100" else '0'; -- 1100XXXXXXXXXXXX

idc_ror  <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010100111" else '0'; -- 1001010XXXXX0111

idc_sbc  <= '1' when instruction_code_reg(15 downto 10) = "000010" else '0'; -- 000010XXXXXXXXXX

idc_sbci <= '1' when instruction_code_reg(15 downto 12) = "0100" else '0'; -- 0100XXXXXXXXXXXX

idc_sbi  <= '1' when instruction_code_reg(15 downto 8) = "10011010" else '0'; -- 10011010XXXXXXXX

idc_sbic <= '1' when instruction_code_reg(15 downto 8) = "10011001" else '0'; -- 10011001XXXXXXXX

idc_sbis <= '1' when instruction_code_reg(15 downto 8) = "10011011" else '0'; -- 10011011XXXXXXXX

idc_sbiw <= '1' when instruction_code_reg(15 downto 8) = "10010111" else '0'; -- 10010111XXXXXXXX

idc_sbrc <= '1' when instruction_code_reg(15 downto 9) = "1111110" else '0'; -- 1111110XXXXXXXXX

idc_sbrs <= '1' when instruction_code_reg(15 downto 9) = "1111111" else '0'; -- 1111111XXXXXXXXX

-- SynEDA CoreMultiplier
-- assignment(s): idc_sleep
-- replace(s): instruction_code_reg

idc_sleep<= '1' when instruction_code_reg_cml_1(15 downto 5)&instruction_code_reg_cml_1(3 downto 0) = "100101011001000" else '0'; -- 10010101100X1000


-- ST,STD
idc_st_x <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010011100" or 
                     instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010011101" or 
                     instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010011110" else '0';
	
idc_st_y <= '1' when (instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010011001" or 
					  instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010011010") else '0'; 

idc_std_y<= '1' when instruction_code_reg(15 downto 14)&instruction_code_reg(12)&instruction_code_reg(9)&instruction_code_reg(3) = "10011" else '0'; -- 10X0XX1XXXXX1XXX    

idc_st_z <= '1' when (instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010010001" or 
					  instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0)="10010010010") else '0'; 

idc_std_z<= '1' when instruction_code_reg(15 downto 14)&instruction_code_reg(12)&instruction_code_reg(9)&instruction_code_reg(3) = "10010" else '0'; -- 10X0XX1XXXXX0XXX 
-- ######

idc_sts  <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010010000" else '0'; -- 1001001XXXXX0000

idc_sub  <= '1' when instruction_code_reg(15 downto 10) = "000110" else '0'; -- 000110XXXXXXXXXX

idc_subi <= '1' when instruction_code_reg(15 downto 12) = "0101" else '0'; -- 0101XXXXXXXXXXXX

idc_swap <= '1' when instruction_code_reg(15 downto 9)&instruction_code_reg(3 downto 0) = "10010100010" else '0'; -- 1001010XXXXX0010

-- SynEDA CoreMultiplier
-- assignment(s): idc_wdr
-- replace(s): instruction_code_reg

idc_wdr  <= '1' when instruction_code_reg_cml_1(15 downto 5)&instruction_code_reg_cml_1(3 downto 0) = "100101011011000" else '0'; -- 10010101101X1000

-- SynEDA CoreMultiplier
-- assignment(s): idc_psinc
-- replace(s): instruction_code_reg, idc_ld_x, idc_ld_y, idc_ld_z, idc_st_x, idc_st_y, idc_st_z

-- ADDITIONAL SIGNALS
idc_psinc <= '1' when (instruction_code_reg_cml_1(1 downto 0) = "01" and 
 (idc_st_x_cml_1 or idc_st_y_cml_1 or idc_st_z_cml_1 or idc_ld_x_cml_1 or idc_ld_y_cml_1 or idc_ld_z_cml_1)='1') else '0';  -- POST INCREMENT FOR LD/ST INSTRUCTIONS

-- SynEDA CoreMultiplier
-- assignment(s): idc_prdec
-- replace(s): instruction_code_reg, idc_ld_x, idc_ld_y, idc_ld_z, idc_st_x, idc_st_y, idc_st_z

idc_prdec <= '1' when (instruction_code_reg_cml_1(1 downto 0)	= "10" and
 (idc_st_x_cml_1 or idc_st_y_cml_1 or idc_st_z_cml_1 or idc_ld_x_cml_1 or idc_ld_y_cml_1 or idc_ld_z_cml_1)='1') else '0';  -- PRE DECREMENT FOR LD/ST INSTRUCTIONS 
				
	
-- ##########################################################################################################

-- SynEDA CoreMultiplier
-- assignment(s): ramadr_reg_en
-- replace(s): cpuwait, irq_st1, irq_st2, call_st1, call_st2, rcall_st1, icall_st1, ret_st1, reti_st1, idc_icall, idc_ld_x, idc_ld_y, idc_ldd_y, idc_ld_z, idc_ldd_z, idc_lds, idc_pop, idc_push, idc_rcall, idc_ret, idc_reti, idc_st_x, idc_st_y, idc_std_y, idc_st_z, idc_std_z, idc_sts

-- WRITE ENABLE SIGNALS FOR ramadr_reg
ramadr_reg_en <= idc_ld_x_cml_1 or idc_ld_y_cml_1 or idc_ldd_y_cml_1 or idc_ld_z_cml_1 or idc_ldd_z_cml_1 or idc_lds_cml_1 or    -- LD/LDD/LDS(two cycle execution) 
                 idc_st_x_cml_1 or idc_st_y_cml_1 or idc_std_y_cml_1 or idc_st_z_cml_1 or idc_std_z_cml_1 or idc_sts_cml_1 or    -- ST/STS/STS(two cycle execution)
				 idc_push_cml_1 or idc_pop_cml_1 or
				 idc_rcall_cml_1 or (rcall_st1_cml_1 and not cpuwait_cml_1) or idc_icall_cml_1 or (icall_st1_cml_1 and not cpuwait_cml_1) or -- RCALL/ICALL
				 call_st1_cml_1 or  (call_st2_cml_1 and not cpuwait_cml_1) or irq_st1_cml_1 or (irq_st2_cml_1 and not cpuwait_cml_1) or      -- CALL/IRQ
				 idc_ret_cml_1 or (ret_st1_cml_1 and not cpuwait_cml_1 ) or idc_reti_cml_1 or (reti_st1_cml_1 and not cpuwait_cml_1);		 -- RET/RETI  -- ??


-- SynEDA CoreMultiplier
-- assignment(s): ramadr_reg_in
-- replace(s): inst, cpuwait, spl_out, sph_out, irq_st1, irq_st2, call_st1, call_st2, rcall_st1, icall_st1, ret_st1, reti_st1, idc_icall, idc_ld_x, idc_ld_y, idc_ld_z, idc_lds, idc_pop, idc_push, idc_rcall, idc_ret, idc_reti, idc_st_x, idc_st_y, idc_st_z, idc_sts

-- RAMADR MUX
ramadr_reg_in <= sph_out_cml_1&spl_out_cml_1 when 
  (idc_rcall_cml_1 or (rcall_st1_cml_1 and not cpuwait_cml_1)or idc_icall_cml_1 or (icall_st1_cml_1 and not cpuwait_cml_1)or  -- RCALL/ICALL
   call_st1_cml_1  or (call_st2_cml_1 and not cpuwait_cml_1) or irq_st1_cml_1   or (irq_st2_cml_1 and not cpuwait_cml_1)  or  -- CALL/IRQ
   idc_push_cml_1 )='1' else 	                                                                  -- PUSH
   (sph_out_cml_1&spl_out_cml_1)+1 when (idc_ret_cml_1 or (ret_st1_cml_1 and not cpuwait_cml_1)  or idc_reti_cml_1  or (reti_st1_cml_1 and not cpuwait_cml_1) or idc_pop_cml_1)='1' else  -- RET/RETI/POP
   inst_cml_1 when (idc_lds_cml_1 or idc_sts_cml_1) ='1' else     -- LDS/STS (two cycle execution)	
   reg_h_out when (idc_ld_x_cml_1 or idc_ld_y_cml_1 or idc_ld_z_cml_1 or idc_st_x_cml_1 or idc_st_y_cml_1 or idc_st_z_cml_1)='1' else  -- LD/ST	  
   (reg_h_out + ("000000000"&dex_adr_disp));                                                       -- LDD/STD  
	  
								
-- SynEDA CoreMultiplier
-- assignment(s): ramadr_int
-- replace(s): ramadr_int

-- ADDRESS REGISTER								
ramadr_reg:process(cp2,ireset)
begin
if ireset='0' then 
ramadr_int <= (others => '0');
elsif(cp2='1' and cp2'event) then ramadr_int <= ramadr_int_cml_1;
 if (cp2en='1') then 							  -- Clock enable
  if (ramadr_reg_en='1') then                            
   ramadr_int <= ramadr_reg_in;
  end if;
 end if;
end if;
end process;

ramadr <= ramadr_int;

-- SynEDA CoreMultiplier
-- assignment(s): reg_file_adr_space
-- replace(s): reg_file_adr_space

-- GENERAL PURPOSE REGISTERS ADDRESSING FLAG FOR ST/STD/STS INSTRUCTIONS
gp_reg_adr:process(cp2,ireset)
begin
if ireset='0' then 
reg_file_adr_space <='0';
elsif(cp2='1' and cp2'event) then reg_file_adr_space <= reg_file_adr_space_cml_1;
 if (cp2en='1') then 							  -- Clock enable
  if (ramadr_reg_en='1') then                            
   if (ramadr_reg_in(15 downto 5)=const_ram_to_reg) then 
    reg_file_adr_space <= '1';                             -- ADRESS RANGE 0x0000-0x001F -> REGISTERS (R0-R31)
   else 
    reg_file_adr_space <= '0';
   end if;
  end if;
 end if;
end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): io_file_adr_space
-- replace(s): io_file_adr_space

-- I/O REGISTERS ADDRESSING FLAG FOR ST/STD/STS INSTRUCTIONS
io_reg_adr:process(cp2,ireset)
begin
if ireset='0' then io_file_adr_space<='0';
elsif(cp2='1' and cp2'event) then io_file_adr_space <= io_file_adr_space_cml_1;
 if (cp2en='1') then 							  -- Clock enable
  if (ramadr_reg_en='1') then                           
   if (ramadr_reg_in(15 downto 5)=const_ram_to_io_a or ramadr_reg_in(15 downto 5)=const_ram_to_io_b) then 
    io_file_adr_space <= '1';                             -- ADRESS RANGE 0x0020-0x005F -> I/O PORTS (0x00-0x3F)
   else 
    io_file_adr_space <= '0';
   end if;
  end if;
 end if;
end if;
end process;



-- ##########################################################################################################


-- REGRE/REGWE LOGIC (5 BIT ADDSRESS BUS (INTERNAL ONLY) 32 LOCATIONS (R0-R31))

-- SynEDA CoreMultiplier
-- assignment(s): alu_reg_wr
-- replace(s): adiw_st, sbiw_st, idc_adc, idc_add, idc_adiw, idc_and, idc_andi, idc_asr, idc_com, idc_dec, idc_eor, idc_inc, idc_lsr, idc_neg, idc_or, idc_ori, idc_ror, idc_sbc, idc_sbci, idc_sbiw, idc_sub, idc_subi, idc_swap

-- WRITE ENABLE FOR Rd REGISTERS 
alu_reg_wr <= idc_adc_cml_1 or idc_add_cml_1 or idc_adiw_cml_1 or adiw_st_cml_1 or idc_sub_cml_1 or idc_subi_cml_1 or idc_sbc_cml_1 or idc_sbci_cml_1 or
              idc_sbiw_cml_1 or  sbiw_st_cml_1 or idc_and_cml_1 or idc_andi_cml_1 or idc_or_cml_1 or idc_ori_cml_1 or idc_eor_cml_1 or idc_com_cml_1 or
   			  idc_neg_cml_1 or idc_inc_cml_1 or idc_dec_cml_1 or idc_lsr_cml_1 or idc_ror_cml_1 or idc_asr_cml_1 or idc_swap_cml_1;
			  

-- SynEDA CoreMultiplier
-- assignment(s): reg_rd_wr
-- replace(s): reg_file_adr_space, lpm_st2, sts_st, lds_st, st_st, ld_st, pop_st, idc_in, idc_ldi

reg_rd_wr_cml_out <= idc_in_cml_1 or alu_reg_wr or idc_bld or             -- ALU INSTRUCTIONS + IN/BLD INSRTRUCTION                
 (pop_st_cml_1 or ld_st_cml_1 or lds_st_cml_1)or			                    -- POP/LD/LDD/LDS INSTRUCTIONS
 ((st_st_cml_1 or sts_st_cml_1) and reg_file_adr_space_cml_1)or              -- ST/STD/STS INSTRUCTION 	      
  lpm_st2_cml_1 or idc_ldi_cml_1 or idc_mov;                            -- LPM/LDI/MOV INSTRUCTION
 
  
  reg_rd_adr <= '1'&dex_adrreg_d(3 downto 0) when (idc_subi or idc_sbci or idc_andi or idc_ori or idc_cpi or idc_ldi)='1' else
			   "00000" when lpm_st2='1' else 
               adiw_sbiw_encoder_out     when (idc_adiw or idc_sbiw)='1' else
               adiw_sbiw_encoder_mux_out when (adiw_st or sbiw_st)='1' else
			   dex_adrreg_d_latched      when (((st_st or sts_st) and not reg_file_adr_space) or ld_st or lds_st or pop_st)='1' else
               ramadr_int(4 downto 0)    when ((st_st or sts_st) and reg_file_adr_space)='1'else --!!??
			   dex_adrreg_d;

  reg_rd_adr_int <= '1'&dex_adrreg_d(3 downto 0) when (idc_subi or idc_sbci or idc_andi or idc_ori or idc_cpi or idc_ldi)='1' else
			   "00000" when lpm_st2='1' else 
               adiw_sbiw_encoder_out     when (idc_adiw or idc_sbiw)='1' else
               adiw_sbiw_encoder_mux_out when (adiw_st or sbiw_st)='1' else
			   dex_adrreg_d_latched      when (((st_st or sts_st) and not reg_file_adr_space) or ld_st or lds_st or pop_st)='1' else
               ramadr_int(4 downto 0)    when ((st_st or sts_st) and reg_file_adr_space)='1'else --!!??
			   dex_adrreg_d;

reg_rr_adr <= ramadr_int(4 downto 0) when ((ld_st or lds_st) and reg_file_adr_space)='1'else --!!??
	          dex_adrreg_d_latched   when ((st_st or sts_st) and reg_file_adr_space)='1'else --!!??
	          dex_adrreg_r;		   
  
-- SynEDA CoreMultiplier
-- assignment(s): reg_rd_in
-- replace(s): reg_rr_out, reg_file_adr_space, lpm_st2, sts_st, lds_st, st_st, ld_st, pop_st, instruction_reg, dex_dat8_immed, gp_reg_tmp, idc_in, idc_ldi

-- MULTIPLEXER FOR REGISTER FILE Rd INPUT
reg_rd_in_cml_out <= dbusin when (idc_in_cml_1 or ((lds_st_cml_1 or ld_st_cml_1)and not reg_file_adr_space_cml_1) or pop_st_cml_1)='1' else -- FROM INPUT DATA BUS
			 reg_rr_out_cml_1 when ((lds_st_cml_1 or ld_st_cml_1)  and reg_file_adr_space_cml_1)='1' else
             gp_reg_tmp_cml_1 when ((st_st_cml_1 or sts_st_cml_1)  and reg_file_adr_space_cml_1)='1' else -- ST/STD/STS &  ADDRESS FROM 0 TO 31 (REGISTER FILE)
			 bld_op_out when (idc_bld='1')else                                     -- FROM BIT PROCESSOR BLD COMMAND
             reg_rr_out_cml_1 when (idc_mov='1')else                                     -- FOR MOV INSTRUCTION 
			 instruction_reg_cml_1(15 downto 8) when (lpm_st2_cml_1='1' and reg_z_out(0)='1') else -- LPM/ELPM
			 instruction_reg_cml_1(7 downto 0) when  (lpm_st2_cml_1='1' and reg_z_out(0)='0') else -- LPM/ELPM
             dex_dat8_immed_cml_1 when idc_ldi_cml_1='1' else
			 alu_data_out;                                               -- FROM ALU DATA OUT

-- IORE/IOWE LOGIC (6 BIT ADDRESS adr[5..0] FOR I/O PORTS(64 LOCATIONS))
iore_int <= idc_in or idc_sbi or idc_cbi or idc_sbic or idc_sbis or ((ld_st or lds_st) and io_file_adr_space);   -- IN/SBI/CBI 
iowe_int <= '1' when ((idc_out or sbi_st or cbi_st) or 
                     ((st_st or sts_st) and io_file_adr_space))='1' else '0'; -- OUT/SBI/CBI + !! ST/STS/STD


-- adr[5..0] BUS MULTIPLEXER
adr_int <= dex_adr6port when (idc_in or idc_out) = '1' else                          -- IN/OUT INSTRUCTIONS  
           '0'&dex_adr5port when (idc_cbi or idc_sbi or idc_sbic or idc_sbis) ='1'    else  -- CBI/SBI (READ PHASE) + SBIS/SBIC
		   '0'&cbi_sbi_io_adr_tmp when (cbi_st or sbi_st)='1' else	-- CBI/SBI (WRITE PHASE)
		    ramadr_int(6)&ramadr_int(4 downto 0);                                                   -- LD/LDS/LDD/ST/STS/STD

-- ramre LOGIC (16 BIT ADDRESS ramadr[15..0] FOR DATA RAM (64*1024-64-32 LOCATIONS))
--ramre_int <= not(reg_file_adr_space or io_file_adr_space) and 
--            (ld_st or lds_st2 or pop_st or                    -- LD/LDD/LDS/POP/
--             ret_st1 or ret_st2 or reti_st1 or reti_st2);     -- RET/RETI

-- SynEDA CoreMultiplier
-- assignment(s): ramre_int
-- replace(s): cpuwait, ret_st2, reti_st2, lds_st, ld_st, pop_st, ramre_int, idc_ld_x, idc_ld_y, idc_ldd_y, idc_ld_z, idc_ldd_z, idc_lds, idc_pop, idc_ret, idc_reti

DataMemoryRead:process(cp2,ireset)
begin
if ireset='0' then -- Reset
 ramre_int <= '0';
elsif (cp2='1' and cp2'event) then ramre_int <= ramre_int_cml_1; -- Clock
 if (cp2en='1') then 							  -- Clock enable	
  case ramre_int_cml_1 is
   when '0' =>	
    if(ramadr_reg_in(15 downto 5)/=const_ram_to_io_a and 
	   ramadr_reg_in(15 downto 5)/=const_ram_to_io_b and   
       ramadr_reg_in(15 downto 5)/=const_ram_to_reg  and  
      (idc_ld_x_cml_1 or idc_ld_y_cml_1 or idc_ldd_y_cml_1 or idc_ld_z_cml_1 or idc_ldd_z_cml_1 or  -- LD/LDD instruction	
	   idc_lds_cml_1 or                                                     -- LDS instruction(two cycle execution)
	   idc_pop_cml_1 or                                                     -- POP instruction
       idc_ret_cml_1 or 	                                                -- RET instruction 
	   idc_reti_cml_1)='1') 												    -- RETI instruction 
	   then ramre_int <='1';
    end if;
   when '1' =>	
    if ((ld_st_cml_1 or lds_st_cml_1 or pop_st_cml_1 or ret_st2_cml_1 or reti_st2_cml_1)and not cpuwait_cml_1)='1' then 
     ramre_int <='0';
    end if;
   when others  =>	null;
  end case;
 end if;  
end if;
end process;			 
			 
-- ramwe LOGIC (16 BIT ADDRESS ramadr[15..0] FOR DATA RAM (64*1024-64-32 LOCATIONS))
--ramwe_int <= not(reg_file_adr_space or io_file_adr_space) and 
--            (st_st or sts_st2 or push_st or rcall_st1 or rcall_st2 or -- ST/STD/STS/PUSH/RCALL
--			                                icall_st1 or icall_st2 or -- ICALL
--			                                call_st2 or call_st3 or   -- CALL
--											irq_st2 or irq_st3);      -- INTERRUPT

-- SynEDA CoreMultiplier
-- assignment(s): ramwe_int
-- replace(s): cpuwait, irq_st1, irq_st3, call_st1, call_st3, rcall_st2, icall_st2, sts_st, st_st, push_st, ramwe_int, idc_icall, idc_push, idc_rcall, idc_st_x, idc_st_y, idc_std_y, idc_st_z, idc_std_z, idc_sts

DataMemoryWrite:process(cp2,ireset)
begin
if ireset='0' then -- Reset
 ramwe_int <= '0';
elsif (cp2='1' and cp2'event) then ramwe_int <= ramwe_int_cml_1; -- Clock
 if (cp2en='1') then 							  -- Clock enable
  case ramwe_int_cml_1 is
   when '0' =>	
    if(ramadr_reg_in(15 downto 5)/=const_ram_to_io_a and 
	   ramadr_reg_in(15 downto 5)/=const_ram_to_io_b and   
       ramadr_reg_in(15 downto 5)/=const_ram_to_reg  and  
      (idc_st_x_cml_1 or idc_st_y_cml_1 or idc_std_y_cml_1 or idc_st_z_cml_1 or idc_std_z_cml_1 or  -- ST/STD instruction	
	   idc_sts_cml_1 or                                                     -- STS instruction (two cycle execution)	
	   idc_push_cml_1 or                                                    -- PUSH instruction
	   idc_rcall_cml_1 or													  -- RCALL instruction
	   idc_icall_cml_1 or													  -- ICALL instruction
	   call_st1_cml_1 or                                                    -- CALL instruction
	   irq_st1_cml_1)='1')                                                  -- Interrupt  
	  then ramwe_int <='1';
    end if;
   when '1' =>	
    if ((st_st_cml_1 or sts_st_cml_1 or push_st_cml_1 or rcall_st2_cml_1 or 
	     icall_st2_cml_1 or call_st3_cml_1 or irq_st3_cml_1)and not cpuwait_cml_1)='1' then ramwe_int <='0';
    end if;
   when others  =>	null;
  end case;
end if;
end if;
end process;

-- DBUSOUT MULTIPLEXER
--dbusout_mux_logic: for i in dbusout_int'range generate
--dbusout_int(i)<= (reg_rd_out(i) and (idc_push or idc_sts or
--                 (idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
--				 (gp_reg_tmp(i) and (st_st or sts_st))or                            -- NEW
--				 (bitpr_io_out(i) and (cbi_st or sbi_st))or                          -- CBI/SBI  INSTRUCTIONS
--                 (program_counter(i)         and (idc_rcall or idc_icall or call_st1))or                        -- LOW  PART OF PC                 (program_counter_high_fr(i) and (rcall_st1 or icall_st1 or call_st2))or                        -- HIGH PART OF PC
--                 (pc_for_interrupt(i) and irq_st1) or
--				 (pc_for_interrupt(8) and irq_st2) or
--				 (reg_rd_out(i) and  idc_out); -- OUT
--end generate;

dbusout_int(0)<= (reg_rd_out_cml_1(0) and (idc_push_cml_1 or idc_sts_cml_1 or
                 (idc_st_x_cml_1 or idc_st_y_cml_1 or idc_std_y_cml_1 or idc_st_z_cml_1 or idc_std_z_cml_1)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp_cml_1(0) and (st_st_cml_1 or sts_st_cml_1))or                            -- NEW
				 (bitpr_io_out_cml_1(0) and (cbi_st_cml_1 or sbi_st_cml_1))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter_cml_1(0)         and (idc_rcall_cml_1 or idc_icall_cml_1 or call_st1_cml_1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr_cml_1(0) and (rcall_st1_cml_1 or icall_st1_cml_1 or call_st2_cml_1))or                        -- HIGH PART OF PC
                 (pc_for_interrupt_cml_1(0) and irq_st1_cml_1) or
				 (pc_for_interrupt_cml_1(8) and irq_st2_cml_1) or
				 (reg_rd_out_cml_1(0) and  idc_out_cml_1); -- OUT

dbusout_int(1)<= (reg_rd_out_cml_1(1) and (idc_push_cml_1 or idc_sts_cml_1 or
                 (idc_st_x_cml_1 or idc_st_y_cml_1 or idc_std_y_cml_1 or idc_st_z_cml_1 or idc_std_z_cml_1)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp_cml_1(1) and (st_st_cml_1 or sts_st_cml_1))or                            -- NEW
				 (bitpr_io_out_cml_1(1) and (cbi_st_cml_1 or sbi_st_cml_1))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter_cml_1(1)         and (idc_rcall_cml_1 or idc_icall_cml_1 or call_st1_cml_1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr_cml_1(1) and (rcall_st1_cml_1 or icall_st1_cml_1 or call_st2_cml_1))or                        -- HIGH PART OF PC
                 (pc_for_interrupt_cml_1(1) and irq_st1_cml_1) or
				 (pc_for_interrupt_cml_1(9) and irq_st2_cml_1) or
				 (reg_rd_out_cml_1(1) and  idc_out_cml_1); -- OUT

dbusout_int(2)<= (reg_rd_out_cml_1(2) and (idc_push_cml_1 or idc_sts_cml_1 or
                 (idc_st_x_cml_1 or idc_st_y_cml_1 or idc_std_y_cml_1 or idc_st_z_cml_1 or idc_std_z_cml_1)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp_cml_1(2) and (st_st_cml_1 or sts_st_cml_1))or                            -- NEW
				 (bitpr_io_out_cml_1(2) and (cbi_st_cml_1 or sbi_st_cml_1))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter_cml_1(2)         and (idc_rcall_cml_1 or idc_icall_cml_1 or call_st1_cml_1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr_cml_1(2) and (rcall_st1_cml_1 or icall_st1_cml_1 or call_st2_cml_1))or                        -- HIGH PART OF PC
                 (pc_for_interrupt_cml_1(2) and irq_st1_cml_1) or
				 (pc_for_interrupt_cml_1(10) and irq_st2_cml_1) or
				 (reg_rd_out_cml_1(2) and  idc_out_cml_1); -- OUT

dbusout_int(3)<= (reg_rd_out_cml_1(3) and (idc_push_cml_1 or idc_sts_cml_1 or
                 (idc_st_x_cml_1 or idc_st_y_cml_1 or idc_std_y_cml_1 or idc_st_z_cml_1 or idc_std_z_cml_1)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp_cml_1(3) and (st_st_cml_1 or sts_st_cml_1))or                            -- NEW
				 (bitpr_io_out_cml_1(3) and (cbi_st_cml_1 or sbi_st_cml_1))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter_cml_1(3)         and (idc_rcall_cml_1 or idc_icall_cml_1 or call_st1_cml_1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr_cml_1(3) and (rcall_st1_cml_1 or icall_st1_cml_1 or call_st2_cml_1))or                        -- HIGH PART OF PC
                 (pc_for_interrupt_cml_1(3) and irq_st1_cml_1) or
				 (pc_for_interrupt_cml_1(11) and irq_st2_cml_1) or
				 (reg_rd_out_cml_1(3) and  idc_out_cml_1); -- OUT

dbusout_int(4)<= (reg_rd_out_cml_1(4) and (idc_push_cml_1 or idc_sts_cml_1 or
                 (idc_st_x_cml_1 or idc_st_y_cml_1 or idc_std_y_cml_1 or idc_st_z_cml_1 or idc_std_z_cml_1)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp_cml_1(4) and (st_st_cml_1 or sts_st_cml_1))or                            -- NEW
				 (bitpr_io_out_cml_1(4) and (cbi_st_cml_1 or sbi_st_cml_1))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter_cml_1(4)         and (idc_rcall_cml_1 or idc_icall_cml_1 or call_st1_cml_1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr_cml_1(4) and (rcall_st1_cml_1 or icall_st1_cml_1 or call_st2_cml_1))or                        -- HIGH PART OF PC
                 (pc_for_interrupt_cml_1(4) and irq_st1_cml_1) or
				 (pc_for_interrupt_cml_1(12) and irq_st2_cml_1) or
				 (reg_rd_out_cml_1(4) and  idc_out_cml_1); -- OUT

dbusout_int(5)<= (reg_rd_out_cml_1(5) and (idc_push_cml_1 or idc_sts_cml_1 or
                 (idc_st_x_cml_1 or idc_st_y_cml_1 or idc_std_y_cml_1 or idc_st_z_cml_1 or idc_std_z_cml_1)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp_cml_1(5) and (st_st_cml_1 or sts_st_cml_1))or                            -- NEW
				 (bitpr_io_out_cml_1(5) and (cbi_st_cml_1 or sbi_st_cml_1))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter_cml_1(5)         and (idc_rcall_cml_1 or idc_icall_cml_1 or call_st1_cml_1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr_cml_1(5) and (rcall_st1_cml_1 or icall_st1_cml_1 or call_st2_cml_1))or                        -- HIGH PART OF PC
                 (pc_for_interrupt_cml_1(5) and irq_st1_cml_1) or
				 (pc_for_interrupt_cml_1(13) and irq_st2_cml_1) or
				 (reg_rd_out_cml_1(5) and  idc_out_cml_1); -- OUT

dbusout_int(6)<= (reg_rd_out_cml_1(6) and (idc_push_cml_1 or idc_sts_cml_1 or
                 (idc_st_x_cml_1 or idc_st_y_cml_1 or idc_std_y_cml_1 or idc_st_z_cml_1 or idc_std_z_cml_1)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp_cml_1(6) and (st_st_cml_1 or sts_st_cml_1))or                            -- NEW
				 (bitpr_io_out_cml_1(6) and (cbi_st_cml_1 or sbi_st_cml_1))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter_cml_1(6)         and (idc_rcall_cml_1 or idc_icall_cml_1 or call_st1_cml_1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr_cml_1(6) and (rcall_st1_cml_1 or icall_st1_cml_1 or call_st2_cml_1))or                        -- HIGH PART OF PC
                 (pc_for_interrupt_cml_1(6) and irq_st1_cml_1) or
				 (pc_for_interrupt_cml_1(14) and irq_st2_cml_1) or
				 (reg_rd_out_cml_1(6) and  idc_out_cml_1); -- OUT

-- SynEDA CoreMultiplier
-- assignment(s): dbusout_int
-- replace(s): reg_rd_out, bitpr_io_out, program_counter, program_counter_high_fr, irq_st1, irq_st2, call_st1, call_st2, rcall_st1, icall_st1, sts_st, st_st, sbi_st, cbi_st, pc_for_interrupt, gp_reg_tmp, idc_icall, idc_out, idc_push, idc_rcall, idc_st_x, idc_st_y, idc_std_y, idc_st_z, idc_std_z, idc_sts

dbusout_int(7)<= (reg_rd_out_cml_1(7) and (idc_push_cml_1 or idc_sts_cml_1 or
                 (idc_st_x_cml_1 or idc_st_y_cml_1 or idc_std_y_cml_1 or idc_st_z_cml_1 or idc_std_z_cml_1)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp_cml_1(7) and (st_st_cml_1 or sts_st_cml_1))or                            -- NEW
				 (bitpr_io_out_cml_1(7) and (cbi_st_cml_1 or sbi_st_cml_1))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter_cml_1(7)         and (idc_rcall_cml_1 or idc_icall_cml_1 or call_st1_cml_1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr_cml_1(7) and (rcall_st1_cml_1 or icall_st1_cml_1 or call_st2_cml_1))or                        -- HIGH PART OF PC
                 (pc_for_interrupt_cml_1(7) and irq_st1_cml_1) or
				 (pc_for_interrupt_cml_1(15) and irq_st2_cml_1) or
				 (reg_rd_out_cml_1(7) and  idc_out_cml_1); -- OUT

dbusout_int_route <= dbusout_int;

dbusout(0)<= (reg_rd_out_int(0) and (idc_push or idc_sts or
                 (idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp(0) and (st_st or sts_st))or                            -- NEW
				 (bitpr_io_out(0) and (cbi_st or sbi_st))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter(0)         and (idc_rcall or idc_icall or call_st1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr(0) and (rcall_st1 or icall_st1 or call_st2))or                        -- HIGH PART OF PC
                 (pc_for_interrupt(0) and irq_st1) or
				 (pc_for_interrupt(8) and irq_st2) or
				 (reg_rd_out_int(0) and  idc_out); -- OUT

dbusout(1)<= (reg_rd_out_int(1) and (idc_push or idc_sts or
                 (idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp(1) and (st_st or sts_st))or                            -- NEW
				 (bitpr_io_out(1) and (cbi_st or sbi_st))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter(1)         and (idc_rcall or idc_icall or call_st1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr(1) and (rcall_st1 or icall_st1 or call_st2))or                        -- HIGH PART OF PC
                 (pc_for_interrupt(1) and irq_st1) or
				 (pc_for_interrupt(9) and irq_st2) or
				 (reg_rd_out_int(1) and  idc_out); -- OUT

dbusout(2)<= (reg_rd_out_int(2) and (idc_push or idc_sts or
                 (idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp(2) and (st_st or sts_st))or                            -- NEW
				 (bitpr_io_out(2) and (cbi_st or sbi_st))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter(2)         and (idc_rcall or idc_icall or call_st1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr(2) and (rcall_st1 or icall_st1 or call_st2))or                        -- HIGH PART OF PC
                 (pc_for_interrupt(2) and irq_st1) or
				 (pc_for_interrupt(10) and irq_st2) or
				 (reg_rd_out_int(2) and  idc_out); -- OUT

dbusout(3)<= (reg_rd_out_int(3) and (idc_push or idc_sts or
                 (idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp(3) and (st_st or sts_st))or                            -- NEW
				 (bitpr_io_out(3) and (cbi_st or sbi_st))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter(3)         and (idc_rcall or idc_icall or call_st1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr(3) and (rcall_st1 or icall_st1 or call_st2))or                        -- HIGH PART OF PC
                 (pc_for_interrupt(3) and irq_st1) or
				 (pc_for_interrupt(11) and irq_st2) or
				 (reg_rd_out_int(3) and  idc_out); -- OUT

dbusout(4)<= (reg_rd_out_int(4) and (idc_push or idc_sts or
                 (idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp(4) and (st_st or sts_st))or                            -- NEW
				 (bitpr_io_out(4) and (cbi_st or sbi_st))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter(4)         and (idc_rcall or idc_icall or call_st1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr(4) and (rcall_st1 or icall_st1 or call_st2))or                        -- HIGH PART OF PC
                 (pc_for_interrupt(4) and irq_st1) or
				 (pc_for_interrupt(12) and irq_st2) or
				 (reg_rd_out_int(4) and  idc_out); -- OUT

dbusout(5)<= (reg_rd_out_int(5) and (idc_push or idc_sts or
                 (idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp(5) and (st_st or sts_st))or                            -- NEW
				 (bitpr_io_out(5) and (cbi_st or sbi_st))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter(5)         and (idc_rcall or idc_icall or call_st1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr(5) and (rcall_st1 or icall_st1 or call_st2))or                        -- HIGH PART OF PC
                 (pc_for_interrupt(5) and irq_st1) or
				 (pc_for_interrupt(13) and irq_st2) or
				 (reg_rd_out_int(5) and  idc_out); -- OUT

dbusout(6)<= (reg_rd_out_int(6) and (idc_push or idc_sts or
                 (idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp(6) and (st_st or sts_st))or                            -- NEW
				 (bitpr_io_out(6) and (cbi_st or sbi_st))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter(6)         and (idc_rcall or idc_icall or call_st1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr(6) and (rcall_st1 or icall_st1 or call_st2))or                        -- HIGH PART OF PC
                 (pc_for_interrupt(6) and irq_st1) or
				 (pc_for_interrupt(14) and irq_st2) or
				 (reg_rd_out_int(6) and  idc_out); -- OUT

dbusout(7)<= (reg_rd_out_int(7) and (idc_push or idc_sts or
                 (idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z)))or      -- PUSH/ST/STD/STS INSTRUCTIONS
				 (gp_reg_tmp(7) and (st_st or sts_st))or                            -- NEW
				 (bitpr_io_out(7) and (cbi_st or sbi_st))or                          -- CBI/SBI  INSTRUCTIONS
                 (program_counter(7)         and (idc_rcall or idc_icall or call_st1))or                        -- LOW  PART OF PC
                 (program_counter_high_fr(7) and (rcall_st1 or icall_st1 or call_st2))or                        -- HIGH PART OF PC
                 (pc_for_interrupt(7) and irq_st1) or
				 (pc_for_interrupt(15) and irq_st2) or
				 (reg_rd_out_int(7) and  idc_out); -- OUT


-- ALU CONNECTION

-- ALU Rr INPUT MUX
alu_data_r_in <= dex_dat8_immed       when (idc_subi or idc_sbci or idc_andi or idc_ori or idc_cpi)='1' else
                 "00"&dex_dat6_immed  when (idc_adiw or idc_sbiw) ='1' else
                 "00000000"           when (adiw_st or sbiw_st) ='1' else
                 reg_rr_out;


-- SynEDA CoreMultiplier
-- assignment(s): gp_reg_tmp
-- replace(s): reg_rd_out, gp_reg_tmp, idc_st_x, idc_st_y, idc_std_y, idc_st_z, idc_std_z, idc_sts

-- gp_reg_tmp STORES TEMPREOARY THE VALUE OF SOURCE REGISTER DURING ST/STD/STS INSTRUCTION
gp_registers_trig:process(cp2,ireset)
begin
if (ireset='0') then
gp_reg_tmp <= (others=>'0');
elsif (cp2='1' and cp2'event) then gp_reg_tmp <= gp_reg_tmp_cml_1;
 if (cp2en='1') then 							  -- Clock enable
  -- if ((idc_st_x or idc_st_y or idc_std_y or idc_st_z or idc_std_z) or sts_st1)='1' then  -- CLOCK ENABLE
  if ((idc_st_x_cml_1 or idc_st_y_cml_1 or idc_std_y_cml_1 or idc_st_z_cml_1 or idc_std_z_cml_1) or idc_sts_cml_1)='1' then  -- CLOCK ENABLE
     gp_reg_tmp <= reg_rd_out_cml_1;
  end if;
 end if;
end if;
end process;

-- **********************************************************************************************************

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- +++++++++++++++++++++++++++++++++++++++ PROGRAM COUNTER ++++++++++++++++++++++++++++++++++++++++++++++++++
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- SynEDA CoreMultiplier
-- assignment(s): program_counter_high_fr
-- replace(s): program_counter, program_counter_high_fr, irq_st1, call_st1, idc_icall, idc_rcall

program_counter_high_store:process(cp2,ireset)
begin
if ireset='0' then                         -- RESET
program_counter_high_fr <=(others => '0');
elsif (cp2='1' and cp2'event) then program_counter_high_fr <= program_counter_high_fr_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable
  if (idc_rcall_cml_1 or idc_icall_cml_1 or call_st1_cml_1 or irq_st1_cml_1) ='1' then   
   program_counter_high_fr <= program_counter_cml_1(15 downto 8);       -- STORE HIGH BYTE OF THE PROGRAMM COUNTER FOR RCALL/ICALL/CALL INSTRUCTIONS AND INTERRUPTS   
  end if;
 end if;
end if;
end process;


-- SynEDA CoreMultiplier
-- assignment(s): program_counter_tmp
-- replace(s): program_counter_tmp, program_counter, idc_elpm, idc_lpm

program_counter_for_lpm_elpm:process(cp2,ireset)
begin
if ireset='0' then                         -- RESET
program_counter_tmp<=(others => '0');
elsif (cp2='1' and cp2'event) then program_counter_tmp <= program_counter_tmp_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable
  if (idc_lpm_cml_1 or idc_elpm_cml_1) ='1' then       
   program_counter_tmp <= program_counter_cml_1;               
  end if;
 end if; 
end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): pa15_pm
-- replace(s): rampz_out, idc_elpm

pa15_pm <= rampz_out_cml_1(0) and idc_elpm_cml_1; -- '0' WHEN LPM INSTRUCTIONS  RAMPZ(0) WHEN ELPM INSTRUCTION

-- OFFSET FOR BRBC/BRBS INSTRUCTIONS +63/-64
offset_brbx <= "0000000000"&dex_brxx_offset(5 downto 0) when (dex_brxx_offset(6)='0') else -- +
               "1111111111"&dex_brxx_offset(5 downto 0);                                   -- - 

-- OFFSET FOR RJMP/RCALL INSTRUCTIONS +2047/-2048
offset_rxx <= "00000"&dex_adr12mem_s(10 downto 0) when (dex_adr12mem_s(11)='0') else       -- +
              "11111"&dex_adr12mem_s(10 downto 0);                                          -- -

program_counter <= pc_high&pc_low;

-- SynEDA CoreMultiplier
-- assignment(s): program_counter_in
-- replace(s): irqackad_int, program_counter_tmp, program_counter, irq_st1, call_st1, jmp_st1, ret_st1, ret_st2, reti_st1, reti_st2, lpm_st1, instruction_reg, idc_brbc, idc_brbs, idc_elpm, idc_icall, idc_ijmp, idc_lpm, idc_rcall, idc_rjmp

program_counter_in <= program_counter_cml_1 + offset_brbx when ((idc_brbc_cml_1 or idc_brbs_cml_1) and  bit_test_op_out) ='1'else  -- BRBC/BRBS                  
                      program_counter_cml_1 + offset_rxx when (idc_rjmp_cml_1 or idc_rcall_cml_1)='1'else     -- RJMP/RCALL
                      reg_z_out when (idc_ijmp_cml_1 or idc_icall_cml_1)='1'else                        -- IJMP/ICALL
                      pa15_pm&reg_z_out(15 downto 1) when (idc_lpm_cml_1 or idc_elpm_cml_1) ='1'else    -- LPM/ELPM
                      instruction_reg_cml_1  when (jmp_st1_cml_1 or call_st1_cml_1)='1'else                    -- JMP/CALL
                      "0000000000"&irqackad_int_cml_1&'0' when irq_st1_cml_1 ='1' else                 -- INTERRUPT      
                      dbusin&"00000000"  when (ret_st1_cml_1 or reti_st1_cml_1)='1' else                 -- RET/RETI -> PC HIGH BYTE                  
                      "00000000"&dbusin  when (ret_st2_cml_1 or reti_st2_cml_1)='1' else                 -- RET/RETI -> PC LOW BYTE                       
                      program_counter_tmp_cml_1 when (lpm_st1_cml_1)='1'                                 -- AFTER LPM/ELPM INSTRUCTION   
                      else program_counter_cml_1+1;      -- THE MOST USUAL CASE

						  

-- SynEDA CoreMultiplier
-- assignment(s): pc_low_en
-- replace(s): cpuwait, irq_st2, call_st2, rcall_st1, icall_st1, ret_st1, reti_st1, sts_st, lds_st, idc_adiw, idc_cbi, idc_ld_x, idc_ld_y, idc_ldd_y, idc_ld_z, idc_ldd_z, idc_pop, idc_push, idc_sbi, idc_sbiw, idc_st_x, idc_st_y, idc_std_y, idc_st_z, idc_std_z

pc_low_en  <= not (idc_ld_x_cml_1 or idc_ld_y_cml_1 or idc_ld_z_cml_1 or idc_ldd_y_cml_1 or idc_ldd_z_cml_1 or
	               idc_st_x_cml_1 or idc_st_y_cml_1 or idc_st_z_cml_1 or idc_std_y_cml_1 or idc_std_z_cml_1 or
				   ((sts_st_cml_1 or lds_st_cml_1) and cpuwait_cml_1)or 
				   idc_adiw_cml_1 or idc_sbiw_cml_1 or
				   idc_push_cml_1 or idc_pop_cml_1 or
				   idc_cbi_cml_1 or idc_sbi_cml_1 or
				   rcall_st1_cml_1 or icall_st1_cml_1 or call_st2_cml_1 or irq_st2_cml_1 or cpuwait_cml_1 or
				   ret_st1_cml_1 or reti_st1_cml_1); 


-- SynEDA CoreMultiplier
-- assignment(s): pc_high_en
-- replace(s): cpuwait, irq_st2, call_st2, rcall_st1, icall_st1, ret_st2, reti_st2, sts_st, lds_st, idc_adiw, idc_cbi, idc_ld_x, idc_ld_y, idc_ldd_y, idc_ld_z, idc_ldd_z, idc_pop, idc_push, idc_sbi, idc_sbiw, idc_st_x, idc_st_y, idc_std_y, idc_st_z, idc_std_z

pc_high_en <= not (idc_ld_x_cml_1 or idc_ld_y_cml_1 or idc_ld_z_cml_1 or idc_ldd_y_cml_1 or idc_ldd_z_cml_1 or
	               idc_st_x_cml_1 or idc_st_y_cml_1 or idc_st_z_cml_1 or idc_std_y_cml_1 or idc_std_z_cml_1 or
				   ((sts_st_cml_1 or lds_st_cml_1) and cpuwait_cml_1) or 
				   idc_adiw_cml_1 or idc_sbiw_cml_1 or
				   idc_push_cml_1 or idc_pop_cml_1 or
				   idc_cbi_cml_1 or idc_sbi_cml_1 or
				   rcall_st1_cml_1 or icall_st1_cml_1 or call_st2_cml_1 or irq_st2_cml_1 or cpuwait_cml_1 or
				   ret_st2_cml_1 or reti_st2_cml_1);
				   
-- SynEDA CoreMultiplier
-- assignment(s): pc_low
-- replace(s): pc_low

program_counter_low:process(cp2,ireset)
begin
if ireset='0' then                              -- RESET
pc_low<=(others => '0');
elsif (cp2='1' and cp2'event) then pc_low <= pc_low_cml_1;              -- CLOCK
 if (cp2en='1') then 							-- Clock enable
  if pc_low_en ='1' then                          
   pc_low <= program_counter_in(7 downto 0);
  end if;
 end if;
end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): pc_high
-- replace(s): pc_high

program_counter_high:process(cp2,ireset)
begin
if ireset='0' then                               -- RESET
pc_high<=(others => '0');
elsif (cp2='1' and cp2'event) then pc_high <= pc_high_cml_1;               -- CLOCK
 if (cp2en='1') then 							 -- Clock enable
  if pc_high_en ='1' then                          
   pc_high <= program_counter_in(15 downto 8);
  end if;
 end if;
end if;
end process;

pc <= program_counter;														   


-- SynEDA CoreMultiplier
-- assignment(s): pc_for_interrupt
-- replace(s): program_counter, pc_for_interrupt

program_counter_for_interrupt:process(cp2,ireset)
begin
if ireset='0' then                                 -- RESET
pc_for_interrupt <=(others => '0');
elsif (cp2='1' and cp2'event) then pc_for_interrupt <= pc_for_interrupt_cml_1;               -- CLOCK
 if (cp2en='1') then 							 -- Clock enable
  if irq_start ='1' then                           
   pc_for_interrupt <= program_counter_cml_1;
  end if;
 end if;
end if;
end process;

-- END OF PROGRAM COUNTER 

-- STATE MACHINES

-- SynEDA CoreMultiplier
-- assignment(s): skip_inst_start
-- replace(s): idc_cpse, idc_sbic, idc_sbis, idc_sbrc, idc_sbrs

skip_inst_start <= ((idc_sbrc_cml_1 or idc_sbrs_cml_1 or idc_sbic_cml_1 or idc_sbis_cml_1) and bit_test_op_out)or
                   (idc_cpse_cml_1 and alu_z_flag_out);

-- SynEDA CoreMultiplier
-- assignment(s): nskip_inst_st0, skip_inst_st1, skip_inst_st2
-- replace(s): two_word_inst, nskip_inst_st0, skip_inst_st1, skip_inst_st2

skip_instruction_sm:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
nskip_inst_st0 <= '0';
skip_inst_st1  <= '0';
skip_inst_st2  <= '0';
elsif (cp2='1' and cp2'event) then skip_inst_st2 <= skip_inst_st2_cml_1; skip_inst_st1 <= skip_inst_st1_cml_1; nskip_inst_st0 <= nskip_inst_st0_cml_1;       -- CLOCK
 if (cp2en='1') then 				     -- Clock enable
  nskip_inst_st0 <= (not nskip_inst_st0_cml_1 and skip_inst_start) or 
                    (nskip_inst_st0_cml_1 and not((skip_inst_st1_cml_1 and not two_word_inst_cml_1) or skip_inst_st2_cml_1));
  skip_inst_st1  <= (not skip_inst_st1_cml_1 and not nskip_inst_st0_cml_1 and skip_inst_start);
  skip_inst_st2  <=  not skip_inst_st2_cml_1 and skip_inst_st1_cml_1 and two_word_inst_cml_1;
 end if;
end if;
end process;



-- SynEDA CoreMultiplier
-- assignment(s): adiw_st, sbiw_st
-- replace(s): adiw_st, idc_adiw, sbiw_st, idc_sbiw

alu_state_machines:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
adiw_st <= '0';
sbiw_st <= '0';
elsif (cp2='1' and cp2'event) then sbiw_st <= sbiw_st_cml_1; adiw_st <= adiw_st_cml_1;       -- CLOCK
 if (cp2en='1') then 					 -- Clock enable
  adiw_st <= not adiw_st_cml_1 and idc_adiw_cml_1;
  sbiw_st <= not sbiw_st_cml_1 and idc_sbiw_cml_1;
 end if;
end if;
end process;


-- SynEDA CoreMultiplier
-- assignment(s): nlpm_st0, lpm_st1, lpm_st2
-- replace(s): nlpm_st0, lpm_st2, idc_elpm, idc_lpm, lpm_st1

lpm_state_machine:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
nlpm_st0 <= '0';
lpm_st1 <= '0';
lpm_st2 <= '0';
elsif (cp2='1' and cp2'event) then lpm_st2 <= lpm_st2_cml_1; lpm_st1 <= lpm_st1_cml_1; nlpm_st0 <= nlpm_st0_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable
  nlpm_st0 <= (not nlpm_st0_cml_1 and (idc_lpm_cml_1 or idc_elpm_cml_1)) or (nlpm_st0_cml_1 and not lpm_st2_cml_1);
  lpm_st1  <= (not lpm_st1_cml_1 and not nlpm_st0_cml_1 and (idc_lpm_cml_1 or idc_elpm_cml_1)); -- ?? 
  lpm_st2  <=  not lpm_st2_cml_1 and lpm_st1_cml_1;
 end if;
end if;
end process;


-- SynEDA CoreMultiplier
-- assignment(s): lds_st
-- replace(s): cpuwait, lds_st, idc_lds

lds_state_machine:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
 lds_st <= '0';
elsif (cp2='1' and cp2'event) then lds_st <= lds_st_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable	
  lds_st  <= (not lds_st_cml_1 and idc_lds_cml_1) or (lds_st_cml_1 and cpuwait_cml_1);
 end if;
end if;
end process;


-- SynEDA CoreMultiplier
-- assignment(s): sts_st
-- replace(s): cpuwait, sts_st, idc_sts

sts_state_machine:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
 sts_st <= '0';
elsif (cp2='1' and cp2'event) then sts_st <= sts_st_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable
  sts_st  <= (not sts_st_cml_1 and idc_sts_cml_1) or (sts_st_cml_1 and cpuwait_cml_1);
 end if;
end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): njmp_st0, jmp_st1, jmp_st2
-- replace(s): njmp_st0, jmp_st2, idc_jmp, jmp_st1

jmp_state_machine:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
njmp_st0 <= '0';
jmp_st1 <= '0';
jmp_st2 <= '0';
elsif (cp2='1' and cp2'event) then jmp_st2 <= jmp_st2_cml_1; jmp_st1 <= jmp_st1_cml_1; njmp_st0 <= njmp_st0_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable
  njmp_st0 <= (not njmp_st0_cml_1 and idc_jmp_cml_1) or (njmp_st0_cml_1 and not jmp_st2_cml_1);
  jmp_st1  <= not jmp_st1_cml_1 and not njmp_st0_cml_1 and idc_jmp_cml_1; -- ?? 
  jmp_st2  <= not jmp_st2_cml_1 and jmp_st1_cml_1;
 end if;
end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): nrcall_st0, rcall_st1, rcall_st2
-- replace(s): cpuwait, nrcall_st0, rcall_st2, idc_rcall, rcall_st1

rcall_state_machine:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
nrcall_st0 <= '0';
rcall_st1 <= '0';
rcall_st2 <= '0';
elsif (cp2='1' and cp2'event) then rcall_st2 <= rcall_st2_cml_1; rcall_st1 <= rcall_st1_cml_1; nrcall_st0 <= nrcall_st0_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable	
  nrcall_st0 <= (not nrcall_st0_cml_1 and idc_rcall_cml_1) or (nrcall_st0_cml_1 and not (rcall_st2_cml_1 and not cpuwait_cml_1));
  rcall_st1  <= (not rcall_st1_cml_1 and not nrcall_st0_cml_1 and idc_rcall_cml_1) or (rcall_st1_cml_1 and cpuwait_cml_1);
  rcall_st2  <= (not rcall_st2_cml_1 and rcall_st1_cml_1 and not cpuwait_cml_1) or (rcall_st2_cml_1 and cpuwait_cml_1);
 end if;
end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): nicall_st0, icall_st1, icall_st2
-- replace(s): cpuwait, nicall_st0, icall_st2, idc_icall, icall_st1

icall_state_machine:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
nicall_st0 <= '0';
icall_st1 <= '0';
icall_st2 <= '0';
elsif (cp2='1' and cp2'event) then icall_st2 <= icall_st2_cml_1; icall_st1 <= icall_st1_cml_1; nicall_st0 <= nicall_st0_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable	
  nicall_st0 <= (not nicall_st0_cml_1 and idc_icall_cml_1) or (nicall_st0_cml_1 and not (icall_st2_cml_1 and not cpuwait_cml_1));
  icall_st1  <= (not icall_st1_cml_1 and not nicall_st0_cml_1 and idc_icall_cml_1) or (icall_st1_cml_1 and cpuwait_cml_1);
  icall_st2  <= (not icall_st2_cml_1 and icall_st1_cml_1 and not cpuwait_cml_1) or (icall_st2_cml_1 and cpuwait_cml_1);
 end if;
end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): ncall_st0, call_st1, call_st2, call_st3
-- replace(s): cpuwait, ncall_st0, call_st3, idc_call, call_st1, call_st2

call_state_machine:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
ncall_st0 <= '0';
call_st1 <= '0';
call_st2 <= '0';
call_st3  <= '0';
elsif (cp2='1' and cp2'event) then call_st3 <= call_st3_cml_1; call_st2 <= call_st2_cml_1; call_st1 <= call_st1_cml_1; ncall_st0 <= ncall_st0_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable
  ncall_st0 <= (not ncall_st0_cml_1 and idc_call_cml_1) or (ncall_st0_cml_1 and not( call_st3_cml_1 and not cpuwait_cml_1));
  call_st1  <= not call_st1_cml_1 and not ncall_st0_cml_1 and idc_call_cml_1;
  call_st2  <= (not call_st2_cml_1 and call_st1_cml_1) or (call_st2_cml_1 and cpuwait_cml_1);
  call_st3  <= (not call_st3_cml_1 and call_st2_cml_1 and not cpuwait_cml_1) or (call_st3_cml_1 and cpuwait_cml_1);
 end if;
end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): nret_st0, ret_st1, ret_st2, ret_st3
-- replace(s): nret_st0, ret_st3, idc_ret, cpuwait, ret_st1, ret_st2

ret_state_machine:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
nret_st0 <= '0';
ret_st1 <= '0';
ret_st2 <= '0';
ret_st3  <= '0';
elsif (cp2='1' and cp2'event) then ret_st3 <= ret_st3_cml_1; ret_st2 <= ret_st2_cml_1; ret_st1 <= ret_st1_cml_1; nret_st0 <= nret_st0_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable
  nret_st0 <= (not nret_st0_cml_1 and idc_ret_cml_1) or (nret_st0_cml_1 and not ret_st3_cml_1);
  ret_st1  <= (not ret_st1_cml_1 and not nret_st0_cml_1 and idc_ret_cml_1) or (ret_st1_cml_1 and cpuwait_cml_1);
  ret_st2  <= (not ret_st2_cml_1 and ret_st1_cml_1 and not cpuwait_cml_1) or (ret_st2_cml_1 and cpuwait_cml_1) ;
  ret_st3  <= not ret_st3_cml_1 and ret_st2_cml_1 and not cpuwait_cml_1; 
 end if;
end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): nreti_st0, reti_st1, reti_st2, reti_st3
-- replace(s): nreti_st0, reti_st3, idc_reti, cpuwait, reti_st1, reti_st2

reti_state_machine:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
nreti_st0 <= '0';
reti_st1 <= '0';
reti_st2 <= '0';
reti_st3  <= '0';
elsif (cp2='1' and cp2'event) then reti_st3 <= reti_st3_cml_1; reti_st2 <= reti_st2_cml_1; reti_st1 <= reti_st1_cml_1; nreti_st0 <= nreti_st0_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable
  nreti_st0 <= (not nreti_st0_cml_1 and idc_reti_cml_1) or (nreti_st0_cml_1 and not reti_st3_cml_1);
  reti_st1  <= (not reti_st1_cml_1 and not nreti_st0_cml_1 and idc_reti_cml_1) or (reti_st1_cml_1 and cpuwait_cml_1);
  reti_st2  <= (not reti_st2_cml_1 and reti_st1_cml_1 and not cpuwait_cml_1) or (reti_st2_cml_1 and cpuwait_cml_1) ;
  reti_st3  <= not reti_st3_cml_1 and reti_st2_cml_1 and not cpuwait_cml_1; 
 end if;
end if;
end process;


-- INTERRUPT LOGIC AND STATE MACHINE 

-- SynEDA CoreMultiplier
-- assignment(s): irq_int
-- replace(s): irqlines

irq_int <= '0' when	irqlines_cml_1="00000000000000000000000" else '1';
 
irq_vector_adr(15 downto 6)<=(others => '0');
irq_vector_adr(0) <= '0';
-- SynEDA CoreMultiplier
-- assignment(s): irq_vector_adr
-- replace(s): irqlines

-- PRIORITY ENCODER
irq_vector_adr(5 downto 1) <= "00001" when irqlines_cml_1(0)='1'  else -- 0x0002
                              "00010" when irqlines_cml_1(1)='1'  else -- 0x0004  
                              "00011" when irqlines_cml_1(2)='1'  else -- 0x0006  
                              "00100" when irqlines_cml_1(3)='1'  else -- 0x0008  
                              "00101" when irqlines_cml_1(4)='1'  else -- 0x000A  
                              "00110" when irqlines_cml_1(5)='1'  else -- 0x000C  
                              "00111" when irqlines_cml_1(6)='1'  else -- 0x000E  
                              "01000" when irqlines_cml_1(7)='1'  else -- 0x0010  
                              "01001" when irqlines_cml_1(8)='1'  else -- 0x0012  
                              "01010" when irqlines_cml_1(9)='1'  else -- 0x0014
                              "01011" when irqlines_cml_1(10)='1' else -- 0x0016
                              "01100" when irqlines_cml_1(11)='1' else -- 0x0018
                              "01101" when irqlines_cml_1(12)='1' else -- 0x001A
                              "01110" when irqlines_cml_1(13)='1' else -- 0x001C
                              "01111" when irqlines_cml_1(14)='1' else -- 0x001E
                              "10000" when irqlines_cml_1(15)='1' else -- 0x0020
                              "10001" when irqlines_cml_1(16)='1' else -- 0x0022
                              "10010" when irqlines_cml_1(17)='1' else -- 0x0024
                              "10011" when irqlines_cml_1(18)='1' else -- 0x0026
                              "10100" when irqlines_cml_1(19)='1' else -- 0x0028
                              "10101" when irqlines_cml_1(20)='1' else -- 0x002A
                              "10110" when irqlines_cml_1(21)='1' else -- 0x002C
                              "10111" when irqlines_cml_1(22)='1' else -- 0x002E  								  
							  "00000";	  

-- SynEDA CoreMultiplier
-- assignment(s): cpu_busy
-- replace(s): cpuwait, two_word_inst, nirq_st0, call_st1, call_st2, call_st3, rcall_st1, rcall_st2, icall_st1, icall_st2, jmp_st1, ret_st1, ret_st2, reti_st1, reti_st2, skip_inst_st1, lpm_st1, sts_st, lds_st, st_st, ld_st, push_st, pop_st, iowe_int, idc_adiw, idc_bclr, idc_brbc, idc_brbs, idc_call, idc_cbi, idc_icall, idc_ijmp, idc_jmp, idc_ld_x, idc_ld_y, idc_ldd_y, idc_ld_z, idc_ldd_z, idc_lds, idc_lpm, idc_pop, idc_push, idc_rcall, idc_ret, idc_reti, idc_rjmp, idc_sbi, idc_sbiw, idc_st_x, idc_st_y, idc_std_y, idc_st_z, idc_std_z, idc_sts, sreg_bop_wr_en, sreg_adr_eq

-- MULTI CYCLE INSTRUCTION FLAG FOR IRQ
cpu_busy <= idc_adiw_cml_1 or idc_sbiw_cml_1 or idc_cbi_cml_1 or idc_sbi_cml_1 or
            idc_rjmp_cml_1 or idc_ijmp_cml_1 or
			idc_jmp_cml_1 or jmp_st1_cml_1 or
--			idc_brbs or idc_brbc or -- Old variant
            ((idc_brbc_cml_1 or idc_brbs_cml_1) and  bit_test_op_out) or
			idc_lpm_cml_1 or lpm_st1_cml_1 or
			skip_inst_start or (skip_inst_st1_cml_1 and two_word_inst_cml_1) or
			idc_ld_x_cml_1 or idc_ld_y_cml_1 or idc_ldd_y_cml_1 or idc_ld_z_cml_1 or idc_ldd_z_cml_1 or (ld_st_cml_1 and cpuwait_cml_1) or
			idc_st_x_cml_1 or idc_st_y_cml_1 or idc_std_y_cml_1 or idc_st_z_cml_1 or idc_std_z_cml_1 or (st_st_cml_1 and cpuwait_cml_1) or
			idc_lds_cml_1 or (lds_st_cml_1 and cpuwait_cml_1) or 
			idc_sts_cml_1 or (sts_st_cml_1 and cpuwait_cml_1) or
			idc_rcall_cml_1 or rcall_st1_cml_1 or (rcall_st2_cml_1 and cpuwait_cml_1) or           -- RCALL
			idc_icall_cml_1 or icall_st1_cml_1 or (icall_st2_cml_1 and cpuwait_cml_1) or		   -- ICALL
			idc_call_cml_1 or call_st1_cml_1 or call_st2_cml_1 or (call_st3_cml_1 and cpuwait_cml_1) or  -- CALL
			idc_push_cml_1 or (push_st_cml_1 and cpuwait_cml_1) or                           -- PUSH (added 14.07.05)
			idc_pop_cml_1 or (pop_st_cml_1 and cpuwait_cml_1) or                             -- POP  (added 14.07.05)
		    (idc_bclr_cml_1 and sreg_bop_wr_en_cml_1(7)) or                 -- ??? CLI
		    (iowe_int_cml_1 and sreg_adr_eq_cml_1 and not dbusout_int(7))or -- ??? Writing '0' to I flag (OUT/STD/ST/STD)
			nirq_st0_cml_1 or
--			idc_ret  or nret_st0 or                             -- Old variant 
			idc_ret_cml_1 or ret_st1_cml_1 or ret_st2_cml_1 or
--			idc_reti or nreti_st0;                              -- At least one instruction must be executed after RETI and before the new interrupt.
			idc_reti_cml_1 or reti_st1_cml_1 or reti_st2_cml_1;
			
sreg_adr_eq <= '1' when adr_int=SREG_Address else '0';			

--irq_start <= irq_int and not cpu_busy and globint;
irq_start <= irq_int and not cpu_busy and globint;

-- SynEDA CoreMultiplier
-- assignment(s): nirq_st0, irq_st1, irq_st2, irq_st3
-- replace(s): cpuwait, nirq_st0, irq_st3, irq_st1, irq_st2

irq_state_machine:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
nirq_st0 <= '0';
irq_st1 <= '0';
irq_st2 <= '0';
irq_st3 <= '0';
elsif (cp2='1' and cp2'event) then irq_st3 <= irq_st3_cml_1; irq_st2 <= irq_st2_cml_1; irq_st1 <= irq_st1_cml_1; nirq_st0 <= nirq_st0_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable	
  nirq_st0 <= (not nirq_st0_cml_1 and irq_start) or (nirq_st0_cml_1 and not (irq_st3_cml_1 and not cpuwait_cml_1));
  irq_st1  <= (not irq_st1_cml_1 and not nirq_st0_cml_1 and irq_start);
  irq_st2  <= (not irq_st2_cml_1 and irq_st1_cml_1) or (irq_st2_cml_1 and cpuwait_cml_1);
  irq_st3  <= (not irq_st3_cml_1 and irq_st2_cml_1 and not cpuwait_cml_1) or (irq_st3_cml_1 and cpuwait_cml_1);
 end if;
end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): irqack_int
-- replace(s): irqack_int

irqack_reg:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
irqack_int<='0';
elsif (cp2='1' and cp2'event) then irqack_int <= irqack_int_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable	
  irqack_int<= not irqack_int_cml_1 and irq_start;
 end if;
end if;
end process;
-- SynEDA CoreMultiplier
-- assignment(s): irqack
-- replace(s): irqack_int

irqack_cml_out <= irqack_int_cml_1;

-- SynEDA CoreMultiplier
-- assignment(s): irqackad_int
-- replace(s): irqackad_int

irqackad_reg:process(cp2,ireset)
begin
if ireset='0' then                                -- RESET
irqackad_int<=(others=>'0');
elsif (cp2='1' and cp2'event) then irqackad_int <= irqackad_int_cml_1;              -- CLOCK
 if (cp2en='1') then 							  -- Clock enable
  irqackad_int <= irq_vector_adr(5 downto 1);
 end if;
end if;
end process;
-- SynEDA CoreMultiplier
-- assignment(s): irqackad
-- replace(s): irqackad_int

irqackad_cml_out <= irqackad_int_cml_1;

-- *******************************************************************************************

-- SynEDA CoreMultiplier
-- assignment(s): ijmp_st, rjmp_st, brxx_st, push_st, pop_st
-- replace(s): ijmp_st, idc_ijmp, rjmp_st, idc_rjmp, brxx_st, idc_brbc, idc_brbs, cpuwait, push_st, idc_push, pop_st, idc_pop

rjmp_push_pop_ijmp_state_brxx_machine:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
rjmp_st <= '0';
ijmp_st <= '0';
push_st <= '0';
pop_st <= '0';
brxx_st <= '0';
elsif (cp2='1' and cp2'event) then pop_st <= pop_st_cml_1; push_st <= push_st_cml_1; brxx_st <= brxx_st_cml_1; rjmp_st <= rjmp_st_cml_1; ijmp_st <= ijmp_st_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable
  rjmp_st <= idc_rjmp_cml_1;    -- ??
  ijmp_st <= idc_ijmp_cml_1;
  push_st <= (not push_st_cml_1 and idc_push_cml_1) or (push_st_cml_1 and cpuwait_cml_1);
  pop_st  <= (not pop_st_cml_1  and idc_pop_cml_1) or (pop_st_cml_1 and cpuwait_cml_1);
  brxx_st <= not brxx_st_cml_1 and (idc_brbc_cml_1 or idc_brbs_cml_1) and bit_test_op_out;
 end if;
end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): st_st, ld_st
-- replace(s): cpuwait, st_st, idc_st_x, idc_st_y, idc_std_y, idc_st_z, idc_std_z, ld_st, idc_ld_x, idc_ld_y, idc_ldd_y, idc_ld_z, idc_ldd_z

-- LD/LDD/ST/STD
ld_st_state_machine:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
ld_st <= '0';
st_st <= '0';
elsif (cp2='1' and cp2'event) then ld_st <= ld_st_cml_1; st_st <= st_st_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable	
  ld_st <= (not ld_st_cml_1 and (idc_ld_x_cml_1 or idc_ld_y_cml_1 or idc_ldd_y_cml_1 or idc_ld_z_cml_1 or idc_ldd_z_cml_1)) or (ld_st_cml_1 and cpuwait_cml_1);
  st_st <= (not st_st_cml_1 and (idc_st_x_cml_1 or idc_st_y_cml_1 or idc_std_y_cml_1 or idc_st_z_cml_1 or idc_std_z_cml_1)) or (st_st_cml_1 and cpuwait_cml_1);
 end if;
end if;
end process;

-- SynEDA CoreMultiplier
-- assignment(s): sbi_st, cbi_st, cbi_sbi_io_adr_tmp, cbi_sbi_bit_num_tmp
-- replace(s): sbi_st, idc_sbi, cbi_st, idc_cbi, dex_adr5port, cbi_sbi_io_adr_tmp, dex_bitop_bitnum, cbi_sbi_bit_num_tmp

-- SBI/CBI
sbi_cbi_machine:process(cp2,ireset)
begin
if ireset='0' then                       -- RESET
sbi_st <= '0';
cbi_st <= '0';
cbi_sbi_io_adr_tmp  <= (others => '0');
cbi_sbi_bit_num_tmp	<= (others => '0');
elsif (cp2='1' and cp2'event) then cbi_sbi_bit_num_tmp <= cbi_sbi_bit_num_tmp_cml_1; cbi_sbi_io_adr_tmp <= cbi_sbi_io_adr_tmp_cml_1; cbi_st <= cbi_st_cml_1; sbi_st <= sbi_st_cml_1;       -- CLOCK
 if (cp2en='1') then 							  -- Clock enable
  sbi_st <= not sbi_st_cml_1 and idc_sbi_cml_1;
  cbi_st <= not cbi_st_cml_1 and idc_cbi_cml_1;
  cbi_sbi_io_adr_tmp <= dex_adr5port_cml_1;
  cbi_sbi_bit_num_tmp <= dex_bitop_bitnum_cml_1;
 end if;
end if;
end process;

-- ########################################################################################

-- SREG FLAGS WRITE ENABLE LOGIC

--bclr_bset_op_en_logic:for i in sreg_bop_wr_en'range generate
--sreg_bop_wr_en(i) <= '1' when (dex_bitnum_sreg=i and (idc_bclr or idc_bset)='1') else '0';
--end generate;

sreg_bop_wr_en(0) <= '1' when (dex_bitnum_sreg=0 and (idc_bclr or idc_bset)='1') else '0';
sreg_bop_wr_en(1) <= '1' when (dex_bitnum_sreg=1 and (idc_bclr or idc_bset)='1') else '0';
sreg_bop_wr_en(2) <= '1' when (dex_bitnum_sreg=2 and (idc_bclr or idc_bset)='1') else '0';
sreg_bop_wr_en(3) <= '1' when (dex_bitnum_sreg=3 and (idc_bclr or idc_bset)='1') else '0';
sreg_bop_wr_en(4) <= '1' when (dex_bitnum_sreg=4 and (idc_bclr or idc_bset)='1') else '0';
sreg_bop_wr_en(5) <= '1' when (dex_bitnum_sreg=5 and (idc_bclr or idc_bset)='1') else '0';
sreg_bop_wr_en(6) <= '1' when (dex_bitnum_sreg=6 and (idc_bclr or idc_bset)='1') else '0';
sreg_bop_wr_en(7) <= '1' when (dex_bitnum_sreg=7 and (idc_bclr or idc_bset)='1') else '0';

-- SynEDA CoreMultiplier
-- assignment(s): sreg_c_wr_en
-- replace(s): adiw_st, sbiw_st, idc_adc, idc_add, idc_adiw, idc_asr, idc_com, idc_cp, idc_cpc, idc_cpi, idc_lsr, idc_neg, idc_ror, idc_sbc, idc_sbci, idc_sbiw, idc_sub, idc_subi, sreg_bop_wr_en

sreg_c_wr_en <= idc_add_cml_1 or idc_adc_cml_1 or (idc_adiw_cml_1 or adiw_st_cml_1) or idc_sub_cml_1  or idc_subi_cml_1 or 
                idc_sbc_cml_1 or idc_sbci_cml_1 or (idc_sbiw_cml_1 or sbiw_st_cml_1) or idc_com_cml_1 or idc_neg_cml_1 or
				idc_cp_cml_1 or idc_cpc_cml_1 or idc_cpi_cml_1 or
                idc_lsr_cml_1 or idc_ror_cml_1 or idc_asr_cml_1 or sreg_bop_wr_en_cml_1(0);

-- SynEDA CoreMultiplier
-- assignment(s): sreg_z_wr_en
-- replace(s): adiw_st, sbiw_st, idc_adc, idc_add, idc_adiw, idc_and, idc_andi, idc_asr, idc_com, idc_cp, idc_cpc, idc_cpi, idc_dec, idc_eor, idc_inc, idc_lsr, idc_neg, idc_or, idc_ori, idc_ror, idc_sbc, idc_sbci, idc_sbiw, idc_sub, idc_subi, sreg_bop_wr_en

sreg_z_wr_en <= idc_add_cml_1 or idc_adc_cml_1 or (idc_adiw_cml_1 or adiw_st_cml_1) or idc_sub_cml_1  or idc_subi_cml_1 or 
                idc_sbc_cml_1 or idc_sbci_cml_1 or (idc_sbiw_cml_1 or sbiw_st_cml_1) or
				idc_cp_cml_1 or idc_cpc_cml_1 or idc_cpi_cml_1 or
                idc_and_cml_1 or idc_andi_cml_1 or idc_or_cml_1 or idc_ori_cml_1 or idc_eor_cml_1 or idc_com_cml_1 or idc_neg_cml_1 or
                idc_inc_cml_1 or idc_dec_cml_1 or idc_lsr_cml_1 or idc_ror_cml_1 or idc_asr_cml_1 or sreg_bop_wr_en_cml_1(1);
                

-- SynEDA CoreMultiplier
-- assignment(s): sreg_n_wr_en
-- replace(s): adiw_st, sbiw_st, idc_adc, idc_add, idc_and, idc_andi, idc_asr, idc_com, idc_cp, idc_cpc, idc_cpi, idc_dec, idc_eor, idc_inc, idc_lsr, idc_neg, idc_or, idc_ori, idc_ror, idc_sbc, idc_sbci, idc_sub, idc_subi, sreg_bop_wr_en

sreg_n_wr_en <= idc_add_cml_1 or idc_adc_cml_1 or adiw_st_cml_1 or idc_sub_cml_1  or idc_subi_cml_1 or 
                idc_sbc_cml_1 or idc_sbci_cml_1 or sbiw_st_cml_1 or
				idc_cp_cml_1 or idc_cpc_cml_1 or idc_cpi_cml_1 or
                idc_and_cml_1 or idc_andi_cml_1 or idc_or_cml_1 or idc_ori_cml_1 or idc_eor_cml_1 or idc_com_cml_1 or idc_neg_cml_1 or
                idc_inc_cml_1 or idc_dec_cml_1 or idc_lsr_cml_1 or idc_ror_cml_1 or idc_asr_cml_1 or sreg_bop_wr_en_cml_1(2);

-- SynEDA CoreMultiplier
-- assignment(s): sreg_v_wr_en
-- replace(s): adiw_st, sbiw_st, idc_adc, idc_add, idc_and, idc_andi, idc_asr, idc_com, idc_cp, idc_cpc, idc_cpi, idc_dec, idc_eor, idc_inc, idc_lsr, idc_neg, idc_or, idc_ori, idc_ror, idc_sbc, idc_sbci, idc_sub, idc_subi, sreg_bop_wr_en

sreg_v_wr_en <= idc_add_cml_1 or idc_adc_cml_1 or adiw_st_cml_1 or idc_sub_cml_1  or idc_subi_cml_1 or -- idc_adiw
                idc_sbc_cml_1 or idc_sbci_cml_1 or sbiw_st_cml_1 or idc_neg_cml_1 or idc_com_cml_1 or  -- idc_sbiw
                idc_inc_cml_1 or idc_dec_cml_1 or
				idc_cp_cml_1 or idc_cpc_cml_1 or idc_cpi_cml_1 or
                idc_lsr_cml_1 or idc_ror_cml_1 or idc_asr_cml_1 or sreg_bop_wr_en_cml_1(3) or
				idc_and_cml_1 or idc_andi_cml_1 or idc_or_cml_1 or idc_ori_cml_1 or idc_eor_cml_1; -- V-flag bug fixing

-- SynEDA CoreMultiplier
-- assignment(s): sreg_s_wr_en
-- replace(s): adiw_st, sbiw_st, idc_adc, idc_add, idc_and, idc_andi, idc_asr, idc_com, idc_cp, idc_cpc, idc_cpi, idc_dec, idc_eor, idc_inc, idc_lsr, idc_neg, idc_or, idc_ori, idc_ror, idc_sbc, idc_sbci, idc_sub, idc_subi, sreg_bop_wr_en

sreg_s_wr_en <= idc_add_cml_1 or idc_adc_cml_1 or adiw_st_cml_1 or idc_sub_cml_1 or idc_subi_cml_1 or 
                idc_sbc_cml_1 or idc_sbci_cml_1 or sbiw_st_cml_1 or 
				idc_cp_cml_1 or idc_cpc_cml_1 or idc_cpi_cml_1 or				
				idc_and_cml_1 or idc_andi_cml_1 or idc_or_cml_1 or idc_ori_cml_1 or idc_eor_cml_1 or idc_com_cml_1 or idc_neg_cml_1 or
				idc_inc_cml_1 or idc_dec_cml_1 or idc_lsr_cml_1 or idc_ror_cml_1 or idc_asr_cml_1 or sreg_bop_wr_en_cml_1(4);

-- SynEDA CoreMultiplier
-- assignment(s): sreg_h_wr_en
-- replace(s): idc_adc, idc_add, idc_cp, idc_cpc, idc_cpi, idc_neg, idc_sbc, idc_sbci, idc_sub, idc_subi, sreg_bop_wr_en

sreg_h_wr_en <= idc_add_cml_1 or idc_adc_cml_1 or idc_sub_cml_1  or idc_subi_cml_1 or
				idc_cp_cml_1 or idc_cpc_cml_1 or idc_cpi_cml_1 or
                idc_sbc_cml_1 or idc_sbci_cml_1 or idc_neg_cml_1 or sreg_bop_wr_en_cml_1(5);

-- SynEDA CoreMultiplier
-- assignment(s): sreg_t_wr_en
-- replace(s): sreg_bop_wr_en

sreg_t_wr_en <=  idc_bst or sreg_bop_wr_en_cml_1(6);

-- SynEDA CoreMultiplier
-- assignment(s): sreg_i_wr_en
-- replace(s): irq_st1, reti_st3, sreg_bop_wr_en

sreg_i_wr_en <= irq_st1_cml_1 or reti_st3_cml_1 or sreg_bop_wr_en_cml_1(7); -- WAS "irq_start"

-- SynEDA CoreMultiplier
-- assignment(s): sreg_fl_in
-- replace(s): reti_st3, idc_bclr, idc_bset

sreg_fl_in_cml_out <=  bit_pr_sreg_out when (idc_bst or idc_bclr_cml_1 or idc_bset_cml_1)='1' else		           -- TO THE SREG
reti_st3_cml_1&'0'&alu_h_flag_out&alu_s_flag_out&alu_v_flag_out&alu_n_flag_out&alu_z_flag_out&alu_c_flag_out;      
               
-- #################################################################################################################

-- *********************************************************************************************
-- ************** INSTRUCTION DECODER OUTPUTS FOR THE OTHER BLOCKS  ****************************
-- *********************************************************************************************

-- FOR ALU

idc_add_out   <= idc_add;
idc_adc_out   <= idc_adc;
idc_adiw_out  <= idc_adiw;
idc_sub_out   <= idc_sub;
idc_subi_out  <= idc_subi;
idc_sbc_out   <= idc_sbc;
idc_sbci_out  <= idc_sbci;
idc_sbiw_out  <= idc_sbiw;
adiw_st_out   <= adiw_st;
sbiw_st_out   <= sbiw_st;
idc_and_out   <= idc_and;
idc_andi_out  <= idc_andi;
idc_or_out    <= idc_or;
idc_ori_out   <= idc_ori;
idc_eor_out   <= idc_eor;              
idc_com_out   <= idc_com;              
idc_neg_out   <= idc_neg;
idc_inc_out   <= idc_inc;
idc_dec_out   <= idc_dec;
idc_cp_out    <= idc_cp;              
idc_cpc_out   <= idc_cpc;
idc_cpi_out   <= idc_cpi;
idc_cpse_out  <= idc_cpse;                            
idc_lsr_out   <= idc_lsr;
idc_ror_out   <= idc_ror;
idc_asr_out   <= idc_asr;
idc_swap_out  <= idc_swap;

-- FOR THE BIT PROCESSOR
sbi_st_out   <= sbi_st;
cbi_st_out   <= cbi_st;
idc_bst_out  <= idc_bst;
-- SynEDA CoreMultiplier
-- assignment(s): idc_bset_out
-- replace(s): idc_bset

idc_bset_out_cml_out <= idc_bset_cml_1;
-- SynEDA CoreMultiplier
-- assignment(s): idc_bclr_out
-- replace(s): idc_bclr

idc_bclr_out_cml_out <= idc_bclr_cml_1;
idc_sbic_out <= idc_sbic;
idc_sbis_out <= idc_sbis;
idc_sbrs_out <= idc_sbrs;
idc_sbrc_out <= idc_sbrc;
idc_brbs_out <= idc_brbs;
idc_brbc_out <= idc_brbc;
-- SynEDA CoreMultiplier
-- assignment(s): idc_reti_out
-- replace(s): idc_reti

idc_reti_out_cml_out <= idc_reti_cml_1;

-- POST INCREMENT/PRE DECREMENT FOR THE X,Y,Z REGISTERS
post_inc <= idc_psinc;
pre_dec  <= idc_prdec;
-- SynEDA CoreMultiplier
-- assignment(s): reg_h_wr
-- replace(s): idc_ld_x, idc_ld_y, idc_ld_z, idc_st_x, idc_st_y, idc_st_z

reg_h_wr_cml_out <= (idc_st_x_cml_1 or idc_st_y_cml_1 or idc_st_z_cml_1 or idc_ld_x_cml_1 or idc_ld_y_cml_1 or idc_ld_z_cml_1) and (idc_psinc or idc_prdec);

reg_h_adr_cml_out(0)<= idc_st_x_cml_1 or idc_ld_x_cml_1;
reg_h_adr_cml_out(1)<= idc_st_y_cml_1 or idc_std_y_cml_1 or idc_ld_y_cml_1 or idc_ldd_y_cml_1;
-- SynEDA CoreMultiplier
-- assignment(s): reg_h_adr
-- replace(s): idc_ld_x, idc_ld_y, idc_ldd_y, idc_ld_z, idc_ldd_z, idc_st_x, idc_st_y, idc_std_y, idc_st_z, idc_std_z

reg_h_adr_cml_out(2)<= idc_st_z_cml_1 or idc_std_z_cml_1 or idc_ld_z_cml_1 or idc_ldd_z_cml_1;

-- SynEDA CoreMultiplier
-- assignment(s): sp_en
-- replace(s): cpuwait, irq_st1, irq_st2, call_st1, call_st2, rcall_st1, icall_st1, ret_st1, reti_st1, idc_icall, idc_pop, idc_push, idc_rcall, idc_ret, idc_reti

-- SynEDA CoreMultiplier
-- assignment(s): sp_ndown_up
-- replace(s): cpuwait, ret_st1, reti_st1, idc_pop, idc_ret, idc_reti

-- STACK POINTER CONTROL
sp_ndown_up_cml_out <= idc_pop_cml_1 or idc_ret_cml_1 or (ret_st1_cml_1 and not cpuwait_cml_1) or idc_reti_cml_1 or (reti_st1_cml_1 and not cpuwait_cml_1); -- ?????????
sp_en_cml_out <= idc_push_cml_1 or idc_pop_cml_1 or idc_rcall_cml_1 or (rcall_st1_cml_1 and not cpuwait_cml_1) or idc_icall_cml_1 or (icall_st1_cml_1 and not cpuwait_cml_1) or 
idc_ret_cml_1 or (ret_st1_cml_1 and not cpuwait_cml_1) or idc_reti_cml_1 or (reti_st1_cml_1 and not cpuwait_cml_1) or
call_st1_cml_1 or (call_st2_cml_1 and not cpuwait_cml_1) or irq_st1_cml_1 or (irq_st2_cml_1 and not cpuwait_cml_1); --????????


branch  <= dex_condition;
bit_num_r_io <= cbi_sbi_bit_num_tmp when (cbi_st or sbi_st)='1' else dex_bitop_bitnum;

adr <= adr_int;

ramre <= ramre_int;
ramwe <= ramwe_int;

iore <= iore_int;
-- SynEDA CoreMultiplier
-- assignment(s): iowe
-- replace(s): iowe_int

iowe_cml_out <= iowe_int_cml_1;

--dbusout <= dbusout_int;

-- Sleep Control
sleepi <= idc_sleep; 	 
irqok  <= irq_int;	 

-- Watchdog
wdri <= idc_wdr; 	 

-- ************************** JTAG OCD support ************************************

-- Change of flow	
change_flow <= '0';
valid_instr <= '0';

			   
end RTL;
