----------------------------------------------------------------------------------
-- Company: TUM - Technischen Universität München
-- Engineer: N.Alachiotiss
-- 
-- Create Date:    11:57:33 06/24/2009 
-- Design Name: 
-- Module Name:    Construct_sp_fp_mult_factor - Behavioral 
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

entity Construct_sp_fp_mult_factor is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  input_exponent : in  STD_LOGIC_VECTOR (10 downto 0);
           sp_fp_mult_fact : out  STD_LOGIC_VECTOR (31 downto 0));
end Construct_sp_fp_mult_factor;

architecture Behavioral of Construct_sp_fp_mult_factor is


component get_exp_LUT_index is
    Port ( input_val : in  STD_LOGIC_VECTOR (10 downto 0);
           output_val : out  STD_LOGIC_VECTOR (9 downto 0);
			  get_negative_val : out std_logic);
end component;

component exp_lut_MEM is
  port (
    clka : in STD_LOGIC := 'X'; 
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 ); 
    douta : out STD_LOGIC_VECTOR ( 12 downto 0 ) 
  );
end component;

component comp_eq_111111111 is
  port (
    sclr : in STD_LOGIC := 'X'; 
    qa_eq_b : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 8 downto 0 ) 
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

component reg_32b_1c is
  port (
    sclr : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    d : in STD_LOGIC_VECTOR ( 31 downto 0 ); 
    q : out STD_LOGIC_VECTOR ( 31 downto 0 ) 
  );
end component;

signal case_0 , case_1, case_greater_1: std_logic;
signal case_0_vec , case_1_vec, case_greater_1_vec : std_logic_vector(3 downto 0);

signal sp_fp_val_fact : std_logic_Vector(31 downto 0);

signal exp_lut_index_LSB_in , exp_lut_index_LSB_out : std_logic_vector(0 downto 0);

signal eq_11111111 : std_logic;

signal exp_lut_dout : std_logic_vector(12 downto 0);  -- 4 LSBs from exponent and 9 MSBs from mantissa

signal exp_LUT_index : std_logic_vector(9 downto 0);
signal get_negative_val_out : std_logic;
signal get_negative_val_vec_in , get_negative_val_vec_out: std_logic_vector(0 downto 0);





begin


-- Get Exp Lut Index
get_exp_LUT_index_port_map: get_exp_LUT_index port map (input_exponent,exp_LUT_index,get_negative_val_out);

-- Exp Lut
exp_lut_MEM_port_map : exp_lut_MEM port map(clk,exp_LUT_index,exp_lut_dout);

-- Register for sign 
get_negative_val_vec_in(0)<=get_negative_val_out;
reg_for_sign_indicator_port_map: reg_1b_1c port map (rst,clk,get_negative_val_vec_in,get_negative_val_vec_out); -- merge with next reg

--Compararor with constant b port 111111111
comp_eq_111111111_port_map : comp_eq_111111111 port map (rst,eq_11111111,clk,exp_LUT_index(9 downto 1));

-- Register for exp_LUT_index_LSB 
exp_lut_index_LSB_in(0)<=exp_LUT_index(0);
reg_for_exp_LUT_index_LSB_port_map: reg_1b_1c port map (rst,clk,exp_lut_index_LSB_in,exp_lut_index_LSB_out);




case_0<= eq_11111111 and exp_lut_index_LSB_out(0);
case_1<= eq_11111111 and (not exp_lut_index_LSB_out(0));
case_greater_1 <= not eq_11111111;

case_0_vec<=(others=>case_0);
case_1_vec<=(others=>case_1);
case_greater_1_vec<=(others=>case_greater_1);



-- Constract sp_fp_mult_factor

sp_fp_val_fact(31) <= not get_negative_val_vec_out(0); 
sp_fp_val_fact(30 downto 27)<=("0000" and case_0_vec)or ("0111" and case_1_vec) or ("1000" and case_greater_1_vec); 
sp_fp_val_fact(26 downto 23)<=exp_lut_dout(12 downto 9); 
sp_fp_val_fact(22 downto 14)<=exp_lut_dout(8 downto 0); 
sp_fp_val_fact(13 downto 0)<=(others=>'0'); 

--Final output register

reg_32b_1c_port_map : reg_32b_1c port map(
rst,
clk,
sp_fp_val_fact,
sp_fp_mult_fact
);

end Behavioral;

