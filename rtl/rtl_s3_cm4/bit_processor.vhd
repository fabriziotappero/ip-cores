--************************************************************************************************
-- "Bit processor" for AVR core
-- Version 1.3(Special version for the JTAG OCD)
-- Designed by Ruslan Lepetenok
-- Modified 29.08.2003
-- Unused inputs(sreg_bit_num[2..0],idc_sbi,idc_cbi,idc_bld) was removed.
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity bit_processor_cm4 is port(
		cp2_cml_1 : in std_logic;
		cp2_cml_2 : in std_logic;
		cp2_cml_3 : in std_logic;
		
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

end bit_processor_cm4;

architecture RTL of bit_processor_cm4 is

signal sreg_t_flag     : std_logic;                      --  FOR  BLD INSTRUCTION

signal temp_in_data    : std_logic_vector(7 downto 0);
signal sreg_t_temp     : std_logic_vector(7 downto 0);
signal bit_num_decode   : std_logic_vector(7 downto 0);
signal bit_pr_sreg_out_int : std_logic_vector(7 downto 0);

-- SBIS/SBIC/SBRS/SBRC SIGNALS
signal bit_test_in      : std_logic_vector(7 downto 0);
signal bit_test_mux_out : std_logic_vector(7 downto 0);

-- BRBS/BRBC SIGNALS
signal branch_decode    : std_logic_vector(7 downto 0);
signal branch_mux       : std_logic_vector(7 downto 0);

signal bld_op_out_cml_out :  std_logic_vector ( 7 downto 0 );
signal bit_num_r_io_cml_3 :  std_logic_vector ( 2 downto 0 );
signal bit_num_r_io_cml_2 :  std_logic_vector ( 2 downto 0 );
signal bit_num_r_io_cml_1 :  std_logic_vector ( 2 downto 0 );
signal dbusin_cml_3 :  std_logic_vector ( 7 downto 0 );
signal sreg_out_cml_3 :  std_logic_vector ( 7 downto 0 );
signal sreg_out_cml_2 :  std_logic_vector ( 7 downto 0 );
signal sreg_out_cml_1 :  std_logic_vector ( 7 downto 0 );
signal reg_rd_out_cml_3 :  std_logic_vector ( 7 downto 0 );
signal reg_rd_out_cml_2 :  std_logic_vector ( 7 downto 0 );
signal bit_test_op_out_cml_out :  std_logic;
signal idc_sbic_cml_3 :  std_logic;
signal idc_sbis_cml_3 :  std_logic;
signal temp_in_data_cml_3 :  std_logic_vector ( 7 downto 0 );
signal temp_in_data_cml_2 :  std_logic_vector ( 7 downto 0 );
signal temp_in_data_cml_1 :  std_logic_vector ( 7 downto 0 );
signal bit_num_decode_cml_3 :  std_logic_vector ( 7 downto 0 );
signal bit_num_decode_cml_2 :  std_logic_vector ( 7 downto 0 );
signal bit_num_decode_cml_1 :  std_logic_vector ( 7 downto 0 );
signal bit_test_mux_out_cml_3 :  std_logic_vector ( 7 downto 0 );
signal branch_mux_cml_3 :  std_logic_vector ( 7 downto 0 );

begin



process(cp2_cml_1) begin
if (cp2_cml_1 = '1' and cp2_cml_1'event) then
	bit_num_r_io_cml_1 <= bit_num_r_io;
	sreg_out_cml_1 <= sreg_out;
	temp_in_data_cml_1 <= temp_in_data;
	bit_num_decode_cml_1 <= bit_num_decode;
end if;
end process;

process(cp2_cml_2) begin
if (cp2_cml_2 = '1' and cp2_cml_2'event) then
	bit_num_r_io_cml_2 <= bit_num_r_io_cml_1;
	sreg_out_cml_2 <= sreg_out_cml_1;
	reg_rd_out_cml_2 <= reg_rd_out;
	temp_in_data_cml_2 <= temp_in_data_cml_1;
	bit_num_decode_cml_2 <= bit_num_decode_cml_1;
end if;
end process;

process(cp2_cml_3) begin
if (cp2_cml_3 = '1' and cp2_cml_3'event) then
	bit_num_r_io_cml_3 <= bit_num_r_io_cml_2;
	dbusin_cml_3 <= dbusin;
	sreg_out_cml_3 <= sreg_out_cml_2;
	reg_rd_out_cml_3 <= reg_rd_out_cml_2;
	idc_sbic_cml_3 <= idc_sbic;
	idc_sbis_cml_3 <= idc_sbis;
	temp_in_data_cml_3 <= temp_in_data_cml_2;
	bit_num_decode_cml_3 <= bit_num_decode_cml_2;
	bit_test_mux_out_cml_3 <= bit_test_mux_out;
	branch_mux_cml_3 <= branch_mux;
end if;
end process;
bld_op_out <= bld_op_out_cml_out;
bit_test_op_out <= bit_test_op_out_cml_out;


-- SynEDA CoreMultiplier
-- assignment(s): sreg_t_flag
-- replace(s): sreg_out

sreg_t_flag <= sreg_out_cml_3(6);


-- SynEDA CoreMultiplier
-- assignment(s): temp_in_data
-- replace(s): dbusin, temp_in_data

-- SBI/CBI STORE REGISTER
sbi_cbi:process(cp2,ireset)
begin
if ireset='0' then
temp_in_data <= (others =>'0');
elsif (cp2='1' and cp2'event) then temp_in_data <= temp_in_data_cml_3;
 if (cp2en='1') then 							  -- Clock enable
  temp_in_data <= dbusin_cml_3;
 end if; 
end if;
end process;

sbi_cbi_logic:for i in dbusin'range generate
bitpr_io_out(i) <= '1' when (sbi_st='1' and bit_num_decode(i)='1') else  -- SBI
				   '0' when (cbi_st='1' and bit_num_decode(i)='1') else	 -- CBI
				   temp_in_data(i);									     -- ???
end generate;


-- ########################################################################################

-- BST PART (LOAD T BIT OF SREG FROM THE GENERAL PURPOSE REGISTER)
bit_num_decode_logic:for i in bit_num_decode'range generate
bit_num_decode(i) <= '1' when (i=bit_num_r_io) else '0';
end generate;

sreg_t_temp(0) <= reg_rd_out_cml_3(0) when bit_num_decode_cml_3(0)='1' else '0';
bld_logic:for i in 1 to 7 generate
-- SynEDA CoreMultiplier
-- assignment(s): sreg_t_temp
-- replace(s): reg_rd_out, bit_num_decode

sreg_t_temp(i)<= reg_rd_out_cml_3(i) when bit_num_decode_cml_3(i)='1' else sreg_t_temp(i-1);
end generate;

-- BLD LOGIC
bld_inst:for i in reg_rd_out'range generate
-- SynEDA CoreMultiplier
-- assignment(s): bld_op_out
-- replace(s): bit_num_r_io, reg_rd_out

bld_op_out_cml_out(i) <= sreg_t_flag when (i=bit_num_r_io_cml_3) else reg_rd_out_cml_3(i);
end generate; 


-- ########################################################################################

-- BCLR/BSET/BST/RETI LOGIC
bclr_bset_logic:for i in 0 to 6 generate
bit_pr_sreg_out_int(i) <= (idc_bset and not reg_rd_out_cml_3(i)) or (not idc_bclr and reg_rd_out_cml_3(i));
end generate;
-- SynEDA CoreMultiplier
-- assignment(s): bit_pr_sreg_out_int
-- replace(s): reg_rd_out

-- SREG REGISTER BIT 7 - INTERRUPT ENABLE FLAG
bit_pr_sreg_out_int(7) <= (idc_bset and not reg_rd_out_cml_3(7)) or (not idc_bclr and reg_rd_out_cml_3(7)) or idc_reti;

bit_pr_sreg_out <= bit_pr_sreg_out_int(7)&sreg_t_temp(7)&bit_pr_sreg_out_int(5 downto 0) when (idc_bst='1')
                                                                                   else bit_pr_sreg_out_int;

-- SynEDA CoreMultiplier
-- assignment(s): bit_test_in
-- replace(s): reg_rd_out

-- SBIC/SBIS/SBRS/SBRC LOGIC
bit_test_in <= dbusin when (idc_sbis='1' or idc_sbic='1') else reg_rd_out_cml_2; 

bit_test_mux_out(0) <= bit_test_in(0) when bit_num_decode_cml_2(0)='1' else '0';
it_test_mux:for i in 1 to 7 generate
-- SynEDA CoreMultiplier
-- assignment(s): bit_test_mux_out
-- replace(s): bit_num_decode

bit_test_mux_out(i)<= bit_test_in(i) when bit_num_decode_cml_2(i)='1' else bit_test_mux_out(i-1);
end generate;

-- SynEDA CoreMultiplier
-- assignment(s): bit_test_op_out
-- replace(s): idc_sbic, idc_sbis, bit_test_mux_out, branch_mux

bit_test_op_out_cml_out <= (bit_test_mux_out_cml_3(7) and (idc_sbis_cml_3 or idc_sbrs)) or
                   (not bit_test_mux_out_cml_3(7) and (idc_sbic_cml_3 or idc_sbrc)) or
                   (branch_mux_cml_3(7) and idc_brbs) or
                   (not branch_mux_cml_3(7) and idc_brbc);

-- BRBS/BRBC LOGIC

branch_decode_logic:for i in branch_decode'range generate
branch_decode(i) <= '1' when (i=branch) else '0';
end generate;

branch_mux(0) <= sreg_out_cml_2(0) when branch_decode(0)='1' else '0';
branch_mux_logic:for i in 1 to 7 generate
-- SynEDA CoreMultiplier
-- assignment(s): branch_mux
-- replace(s): sreg_out

branch_mux(i)<= sreg_out_cml_2(i) when branch_decode(i)='1' else branch_mux(i-1);
end generate;


end RTL;
