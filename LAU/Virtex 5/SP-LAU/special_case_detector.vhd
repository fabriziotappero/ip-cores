----------------------------------------------------------------------------------
-- Company: TUM - Technischen Universität München
-- Engineer: N.Alachiotis
-- 
-- Create Date:    11:08:46 06/24/2009 
-- Design Name: 
-- Module Name:    special_case_detector - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity special_case_detector is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           input_val : in  STD_LOGIC_VECTOR (31 downto 0);
			  special_val_sel : out STD_LOGIC;
			  output_special_val : out STD_LOGIC_VECTOR(31 downto 0));
end special_case_detector;

architecture Behavioral of special_case_detector is


component comp_eq_8ones is
  port (
    sclr : in STD_LOGIC := 'X'; 
    qa_eq_b : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 7 downto 0 ) 
  );
end component;

component comp_eq_22zeros is
  port (
    sclr : in STD_LOGIC := 'X'; 
    qa_eq_b : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 21 downto 0 ) 
  );
end component;

component reg_2b_1c is
  port (
    sclr : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    d : in STD_LOGIC_VECTOR ( 1 downto 0 ); 
    q : out STD_LOGIC_VECTOR ( 1 downto 0 ) 
  );
end component;

component reg_3b_1c is
  port (
    sclr : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    d : in STD_LOGIC_VECTOR ( 2 downto 0 ); 
    q : out STD_LOGIC_VECTOR ( 2 downto 0 ) 
  );
end component;

component reg_32b_1c is
  port (
    sclr : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    d : in STD_LOGIC_VECTOR ( 31 downto 0 ); 
    q : out STD_LOGIC_VECTOR ( 31 downto 0 ) 
  );
end component;

component reg_1b_1c is
  port (
    sclr : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    d : in STD_LOGIC_VECTOR ( 0 downto 0 ); 
    q : out STD_LOGIC_VECTOR ( 0 downto 0 ) 
  );
end component;

component comp_eq_000000000 is
  port (
    sclr : in STD_LOGIC := 'X'; 
    qa_eq_b : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 8 downto 0 ) 
  );
end component;

constant special_value_nan 		: std_logic_vector(31 downto 0) :="01111111110000000000000000000000";  -- conditions for NAN : input nan or sign 1
constant special_value_minus_inf : std_logic_vector(31 downto 0) :="11111111100000000000000000000000";  -- input zero
constant special_value_inf			: std_logic_vector(31 downto 0) :="01111111100000000000000000000000";  -- input inf

signal eq_8ones , eq_23zeros : std_logic;

signal inputMSBsYA,
		 match_check_sig		,
		 sp_case_0_NAN 		,
		 sp_case_1_minus_INF	,
		 sp_case_2_INF			,
		 sp_case_NO				: std_logic ; 
		 
signal sp_case_0_NAN_vec 					,
		 sp_case_1_minus_INF_vec			,
		 sp_case_2_INF_vec					,
		 special_value_nan_checked 		,
		 special_value_minus_inf_checked	,
		 special_value_inf_checked 		,
		 special_value_checked				: std_logic_vector(31 downto 0); 
		 
signal tmp_2bit_signal , tmp_2bit_signal_reg: std_logic_vector(1 downto 0);
signal tmp_3bit_signal , tmp_3bit_signal_reg: std_logic_vector(2 downto 0);
signal sp_case_NO_1b_vec , sp_case_NO_1b_vec_reg : std_logic_vector(0 downto 0);
		
signal output_special_val_tmp : std_logic_vector(31 downto 0);		

begin

-- Check for Special Values
comp_eq_8ones_port_map : comp_eq_8ones port map (rst,eq_8ones,clk,input_val(30 downto 23));
comp_eq_23zeros_port_map : comp_eq_22zeros port map (rst,eq_23zeros,clk,input_val(21 downto 0));

match_check_sig <= eq_8ones and eq_23zeros;

-- Check for zero input
comp_eq_000000000_inputs_MSBS : comp_eq_000000000 port map (rst,inputMSBsYA,clk,input_val(30 downto 22));

--Register 

tmp_2bit_signal(1)<=input_val(22);
tmp_2bit_signal(0)<=input_val(31);
reg_2b_1c_port_map: reg_2b_1c port map (rst,clk,tmp_2bit_signal,tmp_2bit_signal_reg);

--Check for the conditions
sp_case_0_NAN<= (match_check_sig and tmp_2bit_signal_reg(1)) or tmp_2bit_signal_reg(0);
sp_case_1_minus_INF<=eq_23zeros and inputMSBsYA;
sp_case_2_INF<= ((not tmp_2bit_signal_reg(0)) and match_check_sig and (not tmp_2bit_signal_reg(1)));


--Register for special case bits
tmp_3bit_signal(2)<=sp_case_0_NAN;
tmp_3bit_signal(1)<=sp_case_1_minus_INF;
tmp_3bit_signal(0)<=sp_case_2_INF;
reg_3b_1c_port_map: reg_3b_1c port map (rst,clk,tmp_3bit_signal,tmp_3bit_signal_reg);


-- Check Special case or not
sp_case_NO<=(tmp_3bit_signal_reg(2) or tmp_3bit_signal_reg(1) or tmp_3bit_signal_reg(0)); -- This is special case YES



-- Create special case output
sp_case_0_NAN_vec<=(others=>tmp_3bit_signal_reg(2));
sp_case_1_minus_INF_vec<=(others=>tmp_3bit_signal_reg(1));
sp_case_2_INF_vec<=(others=>tmp_3bit_signal_reg(0));

special_value_nan_checked<= special_value_nan and sp_case_0_NAN_vec;
special_value_minus_inf_checked<= special_value_minus_inf and sp_case_1_minus_INF_vec;
special_value_inf_checked<= special_value_inf and sp_case_2_INF_vec ;

special_value_checked<= special_value_nan_checked or special_value_minus_inf_checked or special_value_inf_checked ;


-- Registers 

sp_case_NO_1b_vec(0)<=sp_case_NO;
reg_1b_1c_port_map: reg_1b_1c port map (rst,clk,sp_case_NO_1b_vec,sp_case_NO_1b_vec_reg);
reg_32b_1c_port_map: reg_32b_1c port map (rst,clk,special_value_checked,output_special_val_tmp);

special_val_sel<=sp_case_NO_1b_vec_reg(0);


output_special_val<=output_special_val_tmp;


end Behavioral;

