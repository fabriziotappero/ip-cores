--************************************************************************************************
--  Top entity for AVR core
--  Version 1.82? (Special version for the JTAG OCD)
--  Designed by Ruslan Lepetenok 
--  Modified 31.08.2006
--  SLEEP and CLRWDT instructions support was added
--  BREAK instructions support was added 
--  PM clock enable was added
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;


entity AVR_Core_cm3 is port(
		cp2_cml_1 : in std_logic;
		cp2_cml_2 : in std_logic;
		
                        --Clock and reset
	                    cp2         : in  std_logic;
						cp2en       : in  std_logic;
                        ireset      : in  std_logic;
					    -- JTAG OCD support
					    valid_instr : out std_logic;
						insert_nop  : in  std_logic; 
						block_irq   : in  std_logic;
						change_flow : out std_logic;
                        -- Program Memory
                        pc          : out std_logic_vector(15 downto 0);   
                        inst        : in  std_logic_vector(15 downto 0);
                        -- I/O control
                        adr         : out std_logic_vector(5 downto 0); 	
                        iore        : out std_logic;                       
                        iowe        : out std_logic;						
                        -- Data memory control
                        ramadr      : out std_logic_vector(15 downto 0);
                        ramre       : out std_logic;
                        ramwe       : out std_logic;
						cpuwait     : in  std_logic;
						-- Data paths
                        dbusin      : in  std_logic_vector(7 downto 0);
                        dbusout     : out std_logic_vector(7 downto 0);
                        -- Interrupt
                        irqlines    : in  std_logic_vector(22 downto 0);
                        irqack      : out std_logic;
                        irqackad    : out std_logic_vector(4 downto 0);
                        --Sleep Control
                        sleepi	    : out std_logic;
                        irqok	    : out std_logic;
                        globint	    : out std_logic;
                        --Watchdog
                        wdri	    : out std_logic
						);
end AVR_Core_cm3;


architecture Struct of avr_core_cm3 is

component pm_fetch_dec_cm3 is port(
		cp2_cml_1 : in std_logic; 
		cp2_cml_2 : in std_logic; 
                              -- Clock and reset
                              cp2              : in  std_logic;
							  cp2en            : in  std_logic; 
                              ireset           : in  std_logic;
							  -- JTAG OCD support
					          valid_instr      : out  std_logic;
						      insert_nop       : in std_logic; 
						      block_irq        : in std_logic;
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
                               bit_num_r_io    : out std_logic_vector(2 downto 0); -- BIT NUMBER FOR CBI/SBI/BLD/BST/SBRS/SBRC/SBIC/SBIS INSTRUCTIONS
                               bitpr_io_out    : in  std_logic_vector(7 downto 0); -- SBI/CBI OUT        
                               branch          : out std_logic_vector(2 downto 0); -- NUMBER (0..7) OF BRANCH CONDITION FOR BRBS/BRBC INSTRUCTION
                               bit_pr_sreg_out : in  std_logic_vector(7 downto 0); -- BCLR/BSET/BST(T-FLAG ONLY)             
                               bld_op_out      : in  std_logic_vector(7 downto 0); -- BLD OUT (T FLAG)
                               bit_test_op_out : in  std_logic;                    -- OUTPUT OF SBIC/SBIS/SBRS/SBRC

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

end component;


component alu_avr_cm3 is port(
		cp2_cml_1 : in std_logic; 
		cp2_cml_2 : in std_logic; 

              alu_data_r_in   : in std_logic_vector(7 downto 0);
              alu_data_d_in   : in std_logic_vector(7 downto 0);
              
              alu_c_flag_in   : in std_logic;
              alu_z_flag_in   : in std_logic;


-- OPERATION SIGNALS INPUTS
              idc_add         :in std_logic;
              idc_adc         :in std_logic;
              idc_adiw        :in std_logic;
              idc_sub         :in std_logic;
              idc_subi        :in std_logic;
              idc_sbc         :in std_logic;
              idc_sbci        :in std_logic;
              idc_sbiw        :in std_logic;

              adiw_st         : in std_logic;
              sbiw_st         : in std_logic;

              idc_and         :in std_logic;
              idc_andi        :in std_logic;
              idc_or          :in std_logic;
              idc_ori         :in std_logic;
              idc_eor         :in std_logic;              
              idc_com         :in std_logic;              
              idc_neg         :in std_logic;

              idc_inc         :in std_logic;
              idc_dec         :in std_logic;

              idc_cp          :in std_logic;              
              idc_cpc         :in std_logic;
              idc_cpi         :in std_logic;
              idc_cpse        :in std_logic;                            

              idc_lsr         :in std_logic;
              idc_ror         :in std_logic;
              idc_asr         :in std_logic;
              idc_swap        :in std_logic;


-- DATA OUTPUT
              alu_data_out    : out std_logic_vector(7 downto 0);

-- FLAGS OUTPUT
              alu_c_flag_out  : out std_logic;
              alu_z_flag_out  : out std_logic;
              alu_n_flag_out  : out std_logic;
              alu_v_flag_out  : out std_logic;
              alu_s_flag_out  : out std_logic;
              alu_h_flag_out  : out std_logic
);

end component;


component reg_file_cm3 is port (
		cp2_cml_1 : in std_logic; 
		cp2_cml_2 : in std_logic; 
							--Clock and reset
					        cp2         : in  std_logic;
							cp2en       : in  std_logic;
                            ireset      : in  std_logic;
						  
                            reg_rd_in   : in std_logic_vector  (7 downto 0);
                            reg_rd_out  : out std_logic_vector (7 downto 0);
                            reg_rd_out_int  : out std_logic_vector(7 downto 0);
                            reg_rd_adr  : in std_logic_vector  (4 downto 0);
                            reg_rd_adr_int      : in std_logic_vector  (4 downto 0);
                            reg_rr_out  : out std_logic_vector (7 downto 0);
                            reg_rr_adr  : in std_logic_vector  (4 downto 0);
                            reg_rd_wr   : in std_logic;

                            post_inc    : in std_logic;                       -- POST INCREMENT FOR LD/ST INSTRUCTIONS
                            pre_dec     : in std_logic;                        -- PRE DECREMENT FOR LD/ST INSTRUCTIONS
                            reg_h_wr    : in std_logic;
                            reg_h_out   : out std_logic_vector (15 downto 0);
                            reg_h_adr   : in std_logic_vector (2 downto 0);    -- x,y,z
   		                    reg_z_out   : out std_logic_vector (15 downto 0)  -- OUTPUT OF R31:R30 FOR LPM/ELPM/IJMP INSTRUCTIONS
                            );
end component;

component io_reg_file_cm3 is port (
		cp2_cml_1 : in std_logic; 
		cp2_cml_2 : in std_logic; 
          		               --Clock and reset
	                           cp2           : in  std_logic;
							   cp2en         : in  std_logic;							   
                               ireset        : in  std_logic;

                               adr           : in  std_logic_vector(5 downto 0);         
                               iowe          : in  std_logic;         
                               dbusout       : in  std_logic_vector(7 downto 0);         

                               sreg_fl_in    : in  std_logic_vector(7 downto 0);         
                               sreg_out      : out std_logic_vector(7 downto 0);         

                               sreg_fl_wr_en : in std_logic_vector (7 downto 0);   --FLAGS WRITE ENABLE SIGNALS       

                               spl_out       : out std_logic_vector(7 downto 0);         
                               sph_out       : out std_logic_vector(7 downto 0);         
                               sp_ndown_up   : in  std_logic; -- DIRECTION OF CHANGING OF STACK POINTER SPH:SPL 0->UP(+) 1->DOWN(-)
                               sp_en         : in  std_logic; -- WRITE ENABLE(COUNT ENABLE) FOR SPH AND SPL REGISTERS
  
                               rampz_out     : out std_logic_vector(7 downto 0));
end component;


component bit_processor_cm3 is port(
		cp2_cml_1 : in std_logic; 
		cp2_cml_2 : in std_logic; 
  							  --Clock and reset
                              cp2             : in  std_logic;
							  cp2en           : in  std_logic;
                              ireset          : in  std_logic;            
              
                              bit_num_r_io    : in  std_logic_vector(2 downto 0); -- BIT NUMBER FOR CBI/SBI/BLD/BST/SBRS/SBRC/SBIC/SBIS INSTRUCTIONS
                              dbusin          : in  std_logic_vector(7 downto 0); -- SBI/CBI/SBIS/SBIC  IN
                              bitpr_io_out    : out std_logic_vector(7 downto 0); -- SBI/CBI OUT        
                              sreg_out        : in  std_logic_vector(7 downto 0); -- BRBS/BRBC/BLD IN 
                              branch          : in  std_logic_vector(2 downto 0); -- NUMBER (0..7) OF BRANCH CONDITION FOR BRBS/BRBC INSTRUCTION
                              bit_pr_sreg_out : out std_logic_vector(7 downto 0); -- BCLR/BSET/BST(T-FLAG ONLY)             
                              bld_op_out      : out std_logic_vector(7 downto 0); -- BLD OUT (T FLAG)
                              reg_rd_out      : in  std_logic_vector(7 downto 0); -- BST/SBRS/SBRC IN    
                              bit_test_op_out : out std_logic;                    -- OUTPUT OF SBIC/SBIS/SBRS/SBRC/BRBC/BRBS
                              -- Instructions and states
                              sbi_st          : in  std_logic;
                              cbi_st          : in  std_logic;
                              idc_bst         : in  std_logic;
                              idc_bset        : in  std_logic;
                              idc_bclr        : in  std_logic;
                              idc_sbic        : in  std_logic;
                              idc_sbis        : in  std_logic;
                              idc_sbrs        : in  std_logic;
                              idc_sbrc        : in  std_logic;
                              idc_brbs        : in  std_logic;
                              idc_brbc        : in  std_logic;
                              idc_reti        : in  std_logic
							  );

end component;

component io_adr_dec_cm3 is port (
		cp2_cml_1 : in std_logic; 
          adr          : in std_logic_vector(5 downto 0);         
          iore         : in std_logic;         
          dbusin_ext   : in std_logic_vector(7 downto 0);
          dbusin_int   : out std_logic_vector(7 downto 0);
                    
          spl_out      : in std_logic_vector(7 downto 0); 
          sph_out      : in std_logic_vector(7 downto 0);           
          sreg_out     : in std_logic_vector(7 downto 0);           
          rampz_out    : in std_logic_vector(7 downto 0));
end component;

signal dbusin_int  : std_logic_vector(7 downto 0);
signal dbusout_int : std_logic_vector(7 downto 0);

signal adr_int     : std_logic_vector(5 downto 0);      

signal iowe_int    : std_logic;
signal iore_int    : std_logic;

-- SIGNALS FOR INSTRUCTION AND STATES
signal idc_add  : std_logic;
signal idc_adc  : std_logic;
signal idc_adiw : std_logic;
signal idc_sub 	: std_logic;
signal idc_subi : std_logic;
signal idc_sbc 	: std_logic;
signal idc_sbci : std_logic;
signal idc_sbiw : std_logic;
signal adiw_st 	: std_logic;
signal sbiw_st 	: std_logic;
signal idc_and 	: std_logic;
signal idc_andi : std_logic;
signal idc_or 	: std_logic;
signal idc_ori 	: std_logic;
signal idc_eor 	: std_logic;
signal idc_com 	: std_logic;
signal idc_neg 	: std_logic;
signal idc_inc 	: std_logic;
signal idc_dec 	: std_logic;
signal idc_cp 	: std_logic;
signal idc_cpc 	: std_logic;
signal idc_cpi 	: std_logic;
signal idc_cpse : std_logic;
signal idc_lsr 	: std_logic;
signal idc_ror 	: std_logic;
signal idc_asr 	: std_logic;
signal idc_swap : std_logic;
signal sbi_st 	: std_logic;
signal cbi_st 	: std_logic;
signal idc_bst 	: std_logic;
signal idc_bset : std_logic;
signal idc_bclr : std_logic;
signal idc_sbic : std_logic;
signal idc_sbis : std_logic;
signal idc_sbrs : std_logic;
signal idc_sbrc : std_logic;
signal idc_brbs : std_logic;
signal idc_brbc : std_logic;
signal idc_reti : std_logic;

signal alu_data_r_in : std_logic_vector(7 downto 0);
signal alu_data_out  : std_logic_vector(7 downto 0);

signal reg_rd_in     : std_logic_vector(7 downto 0);
signal reg_rd_out    : std_logic_vector(7 downto 0);
signal reg_rd_out_int : std_logic_vector(7 downto 0);
signal reg_rr_out    : std_logic_vector(7 downto 0);

signal reg_rd_adr    : std_logic_vector(4 downto 0);
signal reg_rd_adr_int    : std_logic_vector(4 downto 0);
signal reg_rr_adr    : std_logic_vector(4 downto 0);

signal reg_h_out     : std_logic_vector(15 downto 0);
signal reg_z_out     : std_logic_vector(15 downto 0);

signal reg_h_adr     : std_logic_vector(2 downto 0);

signal reg_rd_wr     : std_logic;
signal post_inc      : std_logic;
signal pre_dec       : std_logic;
signal reg_h_wr      : std_logic;

signal sreg_fl_in    : std_logic_vector(7 downto 0);
signal sreg_out      : std_logic_vector(7 downto 0);

signal sreg_out_0      : std_logic;
signal sreg_out_1      : std_logic;
signal sreg_out_7      : std_logic;

signal sreg_fl_wr_en : std_logic_vector(7 downto 0);
signal spl_out       : std_logic_vector(7 downto 0);
signal sph_out       : std_logic_vector(7 downto 0);
signal rampz_out     : std_logic_vector(7 downto 0);
	   
signal sp_ndown_up   : std_logic;
signal sp_en         : std_logic;

signal bit_num_r_io  : std_logic_vector(2 downto 0);
signal branch        : std_logic_vector(2 downto 0);

signal bitpr_io_out    : std_logic_vector(7 downto 0);
signal bit_pr_sreg_out : std_logic_vector(7 downto 0);
signal sreg_flags      : std_logic_vector(7 downto 0);
signal bld_op_out      : std_logic_vector(7 downto 0);
signal reg_file_rd_in  : std_logic_vector(7 downto 0);

signal bit_test_op_out : std_logic;

signal alu_c_flag_out  : std_logic;
signal alu_z_flag_out  : std_logic;
signal alu_n_flag_out  : std_logic;
signal alu_v_flag_out  : std_logic;
signal alu_s_flag_out  : std_logic;
signal alu_h_flag_out  : std_logic;

signal globint_cml_out :  std_logic;
signal globint_cml_2 :  std_logic;
signal adr_cml_out :  std_logic_vector ( 5 downto 0 );
signal adr_int_cml_2 :  std_logic_vector ( 5 downto 0 );
signal iore_cml_out :  std_logic;
signal iore_int_cml_2 :  std_logic;
signal sreg_out_cml_1 :  std_logic_vector ( 7 downto 0 );

begin



process(cp2_cml_1) begin
if (cp2_cml_1 = '1' and cp2_cml_1'event) then
	sreg_out_cml_1 <= sreg_out;
end if;
end process;

process(cp2_cml_2) begin
if (cp2_cml_2 = '1' and cp2_cml_2'event) then
	globint_cml_2 <= globint_cml_out;
	adr_int_cml_2 <= adr_int;
	iore_int_cml_2 <= iore_int;
end if;
end process;
globint <= globint_cml_out;
adr <= adr_cml_out;
iore <= iore_cml_out;


pm_fetch_dec_Inst:component pm_fetch_dec_cm3 port map (
		cp2_cml_1 => cp2_cml_1,
		cp2_cml_2 => cp2_cml_2,
                                      -- Clock and reset
                                      cp2      => cp2,
									  cp2en    => cp2en,
                                      ireset   => ireset,
									  -- JTAG OCD support
							          valid_instr => valid_instr,
						              insert_nop  => insert_nop,
						              block_irq   => block_irq,
						              change_flow => change_flow,
                                      -- Program memory
                                      pc       => pc,    
                                      inst     => inst,
                                      -- I/O control
                                      adr      => adr_int,
                                      iore     => iore_int,
                                      iowe     => iowe_int,
                                      -- Data memory control
                                      ramadr   => ramadr,
                                      ramre    => ramre,
                                      ramwe    => ramwe,
                                      cpuwait  => cpuwait,
                                      -- Data paths
                                      dbusin   => dbusin_int,
                                      dbusout  => dbusout,
		                          dbusout_int_route => dbusout_int,
                                      -- Interrupt
                                      irqlines => irqlines,
                                      irqack   => irqack,
                                      irqackad => irqackad,
                                      --Sleep 
                                      sleepi	 => sleepi,
                                      irqok	 => irqok,
                                      --Watchdog
                                      wdri	 => wdri,
									 -- ALU interface(Data inputs)
                                     alu_data_r_in   => alu_data_r_in,
									 -- ALU interface(Instruction inputs)
                                     idc_add_out  => idc_add,
                                     idc_adc_out  => idc_adc,
                                     idc_adiw_out => idc_adiw,
                                     idc_sub_out  => idc_sub,
                                     idc_subi_out => idc_subi,
                                     idc_sbc_out  => idc_sbc,
                                     idc_sbci_out => idc_sbci,
                                     idc_sbiw_out => idc_sbiw,

                                     adiw_st_out  => adiw_st,
                                     sbiw_st_out  => sbiw_st,

                                     idc_and_out  => idc_and,
                                     idc_andi_out => idc_andi,
                                     idc_or_out   => idc_or,
                                     idc_ori_out  => idc_ori,
                                     idc_eor_out  => idc_eor,
                                     idc_com_out  => idc_com,
                                     idc_neg_out  => idc_neg,

                                     idc_inc_out  => idc_inc,
                                     idc_dec_out  => idc_dec,

                                     idc_cp_out   => idc_cp,
                                     idc_cpc_out  => idc_cpc,
                                     idc_cpi_out  => idc_cpi,
                                     idc_cpse_out => idc_cpse,

                                     idc_lsr_out  => idc_lsr,
                                     idc_ror_out  => idc_ror,
                                     idc_asr_out  => idc_asr,
                                     idc_swap_out => idc_swap,
                                     -- ALU interface(Data output)
                                     alu_data_out => alu_data_out,
                                     -- ALU interface(Flag outputs)
                                     alu_c_flag_out => alu_c_flag_out,
                                     alu_z_flag_out => alu_z_flag_out,
                                     alu_n_flag_out => alu_n_flag_out,
                                     alu_v_flag_out => alu_v_flag_out,
                                     alu_s_flag_out => alu_s_flag_out,
                                     alu_h_flag_out => alu_h_flag_out,
                                     -- General purpose register file interface
                                     reg_rd_in   => reg_rd_in,
                                     reg_rd_out  => reg_rd_out,
                         		 reg_rd_out_int => reg_rd_out_int,
                                     reg_rd_adr  => reg_rd_adr,
                                     reg_rd_adr_int  => reg_rd_adr_int,
                                     reg_rr_out  => reg_rr_out,
                                     reg_rr_adr  => reg_rr_adr,
                                     reg_rd_wr   => reg_rd_wr,

                                     post_inc    => post_inc,
                                     pre_dec     => pre_dec,
                                     reg_h_wr    => reg_h_wr,
                                     reg_h_out   => reg_h_out,
                                     reg_h_adr   => reg_h_adr,
   		                             reg_z_out   => reg_z_out,
                                     -- I/O register file interface
                                     sreg_fl_in    => sreg_fl_in, --??   
                                     globint       => sreg_out_7, -- SREG I flag   

                                     sreg_fl_wr_en => sreg_fl_wr_en,

                                     spl_out       => spl_out,       
                                     sph_out       => sph_out,       
                                     sp_ndown_up   => sp_ndown_up,
                                     sp_en         => sp_en,
  
                                     rampz_out     => rampz_out,
                                     -- Bit processor interface
                                     bit_num_r_io    => bit_num_r_io,  
                                     bitpr_io_out    => bitpr_io_out, 
                                     branch          => branch, 
					                 bit_pr_sreg_out => bit_pr_sreg_out,
					                 bld_op_out      => bld_op_out, 
					                 bit_test_op_out => bit_test_op_out,

                                     sbi_st_out   => sbi_st,
                                     cbi_st_out   => cbi_st,

                                     idc_bst_out  => idc_bst,
                                     idc_bset_out => idc_bset,
                                     idc_bclr_out => idc_bclr,

                                     idc_sbic_out => idc_sbic,
                                     idc_sbis_out => idc_sbis,
              
                                     idc_sbrs_out => idc_sbrs,
                                     idc_sbrc_out => idc_sbrc,
              
                                     idc_brbs_out => idc_brbs,
                                     idc_brbc_out => idc_brbc,

                                     idc_reti_out => idc_reti);


GPRF_Inst:component reg_file_cm3 port map (
		cp2_cml_1 => cp2_cml_1,
		cp2_cml_2 => cp2_cml_2,
		  	                           --Clock and reset
					                   cp2         => cp2,
									   cp2en       => cp2en,
                                       ireset      => ireset,
		  
                                       reg_rd_in   => reg_rd_in,
                                       reg_rd_out  => reg_rd_out,
                          		   reg_rd_out_int => reg_rd_out_int,
                                       reg_rd_adr  => reg_rd_adr,
                                       reg_rd_adr_int  => reg_rd_adr_int,
                                       reg_rr_out  => reg_rr_out,
                                       reg_rr_adr  => reg_rr_adr,
                                       reg_rd_wr   => reg_rd_wr,

                                       post_inc    => post_inc,
                                       pre_dec     => pre_dec,
                                       reg_h_wr    => reg_h_wr,
                                       reg_h_out   => reg_h_out,
                                       reg_h_adr   => reg_h_adr,
   		                               reg_z_out   => reg_z_out);


BP_Inst:component bit_processor_cm3 port map (
		cp2_cml_1 => cp2_cml_1,
		cp2_cml_2 => cp2_cml_2,
		  	                             --Clock and reset
					                     cp2         => cp2,
										 cp2en    => cp2en,
                                         ireset      => ireset, 

                                         bit_num_r_io  => bit_num_r_io,  
                                         dbusin        => dbusin_int,   
                                         bitpr_io_out  => bitpr_io_out,   

                                         sreg_out      => sreg_out,   
                                         branch   => branch,  

                                         bit_pr_sreg_out => bit_pr_sreg_out,

                                         bld_op_out      => bld_op_out,
                                         reg_rd_out      => reg_rd_out,

                                         bit_test_op_out => bit_test_op_out,

                                         -- Instructions and states
                                         sbi_st   => sbi_st,       
                                         cbi_st   => cbi_st,       

                                         idc_bst  => idc_bst,       
                                         idc_bset => idc_bset,       
                                         idc_bclr => idc_bclr,       

                                         idc_sbic => idc_sbic,       
                                         idc_sbis => idc_sbis,       
              
                                         idc_sbrs => idc_sbrs,        
                                         idc_sbrc => idc_sbrc,        
              
                                         idc_brbs => idc_brbs,        
                                         idc_brbc => idc_brbc,        

                                         idc_reti => idc_reti);                      


io_dec_Inst:component io_adr_dec_cm3 port map (
		cp2_cml_1 => cp2_cml_1,
          adr          => adr_int,
          iore         => iore_int,
          dbusin_int   => dbusin_int,			-- LOCAL DATA BUS OUTPUT
          dbusin_ext   => dbusin,               -- EXTERNAL DATA BUS INPUT
                   
          spl_out      => spl_out,
          sph_out      => sph_out,
          sreg_out     => sreg_out,
          rampz_out    => rampz_out
);

IORegs_Inst: component io_reg_file_cm3 port map (
		cp2_cml_1 => cp2_cml_1,
		cp2_cml_2 => cp2_cml_2,
	          		                        --Clock and reset
	                                        cp2        => cp2,
											cp2en    => cp2en,
                                            ireset     => ireset,     
	                                        
											adr        => adr_int,       
                                            iowe       => iowe_int,
                                            dbusout    => dbusout_int,     

                                            sreg_fl_in => sreg_fl_in,
                                            sreg_out   => sreg_out,

                                            sreg_fl_wr_en => sreg_fl_wr_en,

                                            spl_out    => spl_out,    
                                            sph_out    => sph_out,    
                                            sp_ndown_up => sp_ndown_up, 
                                            sp_en      => sp_en,   
  
                                            rampz_out  => rampz_out);



ALU_Inst:component alu_avr_cm3 port map (
		cp2_cml_1 => cp2_cml_1,
		cp2_cml_2 => cp2_cml_2,
			  -- Data inputs
              alu_data_r_in => alu_data_r_in,
              alu_data_d_in => reg_rd_out,
              
              alu_c_flag_in => sreg_out_0,
              alu_z_flag_in => sreg_out_1,
              -- Instructions and states
              idc_add  => idc_add,
              idc_adc  => idc_adc,      
              idc_adiw => idc_adiw,     
              idc_sub  => idc_sub,     
              idc_subi => idc_subi,     
              idc_sbc  => idc_sbc,     
              idc_sbci => idc_sbci,     
              idc_sbiw => idc_sbiw,     

              adiw_st  => adiw_st,     
              sbiw_st  => sbiw_st,     

              idc_and  => idc_and,     
              idc_andi => idc_andi,     
              idc_or   => idc_or,     
              idc_ori  => idc_ori,     
              idc_eor  => idc_eor,     
              idc_com  => idc_com,     
              idc_neg  => idc_neg,     

              idc_inc  => idc_inc,     
              idc_dec  => idc_dec,     

              idc_cp   => idc_cp,     
              idc_cpc  => idc_cpc,     
              idc_cpi  => idc_cpi,    
              idc_cpse => idc_cpse,     

              idc_lsr  => idc_lsr,     
              idc_ror  => idc_ror,      
              idc_asr  => idc_asr,      
              idc_swap => idc_swap,      
              -- Data outputs
              alu_data_out => alu_data_out,  
			  -- Flag outputs
              alu_c_flag_out => alu_c_flag_out,
              alu_z_flag_out => alu_z_flag_out,
              alu_n_flag_out => alu_n_flag_out,
              alu_v_flag_out => alu_v_flag_out,
              alu_s_flag_out => alu_s_flag_out,
              alu_h_flag_out => alu_h_flag_out);


-- SynEDA CoreMultiplier
-- assignment(s): adr
-- replace(s): adr_int

-- Outputs
adr_cml_out      <= adr_int_cml_2;     
iowe     <= iowe_int;
-- SynEDA CoreMultiplier
-- assignment(s): iore
-- replace(s): iore_int

iore_cml_out     <= iore_int_cml_2;

-- SynEDA CoreMultiplier
-- assignment(s): globint
-- replace(s): globint, sreg_out

-- Sleep support
globint_cml_out	<= sreg_out_cml_1(7); -- I flag
sreg_out_0 <= sreg_out(0);
-- SynEDA CoreMultiplier
-- assignment(s): sreg_out_1
-- replace(s): sreg_out

sreg_out_1 <= sreg_out_cml_1(1);
-- SynEDA CoreMultiplier
-- assignment(s): sreg_out_7
-- replace(s): sreg_out

sreg_out_7 <= sreg_out_cml_1(7);

end Struct;
