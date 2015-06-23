----------------------------------------------------------------------------------
-- Company: TUM - Technischen Universität München
-- Engineer: N.Alachiotis
-- 
-- Create Date:    11:03:31 06/24/2009 
-- Design Name: 	SP-LAU (Single Precision Logarithm Approximation Unit)
-- Module Name:    sp_fp_log_v2 - Behavioral 
-- Project Name: 
-- Target Devices: Virtex 5 SX
-- Tool versions: Xilinx ISE 10.1
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

entity sp_fp_log_v2 is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           valid_in : in  STD_LOGIC;
           input_val : in  STD_LOGIC_VECTOR (31 downto 0);
           valid_out : out  STD_LOGIC;
           output_val : out  STD_LOGIC_VECTOR (31 downto 0));
end sp_fp_log_v2;

architecture Behavioral of sp_fp_log_v2 is

component reg_64b_1c is
  port (
    sclr : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    d : in STD_LOGIC_VECTOR ( 63 downto 0 ); 
    q : out STD_LOGIC_VECTOR ( 63 downto 0 ) 
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

signal valid_output_1bvec_in, valid_output_1bvec_out : std_logic_vector(0 downto 0);
signal tmp_valid_out : std_logic;
component reg_1b_2c is
  port (
    sclr : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    d : in STD_LOGIC_VECTOR ( 0 downto 0 ); 
    q : out STD_LOGIC_VECTOR ( 0 downto 0 ) 
  );
end component;

component reg_32b_8c is
  port (
    sclr : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    d : in STD_LOGIC_VECTOR ( 31 downto 0 ); 
    q : out STD_LOGIC_VECTOR ( 31 downto 0 ) 
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

signal input_val_valid_reg : std_logic_Vector (31 downto 0);

constant log_base_e_of_2 : std_logic_vector(31 downto 0):="00111111001100010111001000011000";

component special_case_detector is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           input_val : in  STD_LOGIC_VECTOR (31 downto 0);
			  special_val_sel : out STD_LOGIC;
			  output_special_val : out STD_LOGIC_VECTOR(31 downto 0));
end component;

signal scd_out_special_val_sel , scd_out_special_val_sel_reg : std_logic;
signal scd_out_special_val_sel_1bvec , scd_out_special_val_sel_reg_1bvec : std_logic_vector(0 downto 0);
signal scd_out_output_special_val , scd_out_output_special_val_reg: std_logic_vector(31 downto 0);

signal scd_out_special_val_sel_reg_vec , scd_out_special_val_not_sel_reg_vec,
       temp_final_result ,
		 temp_final_result_reg: std_logic_vector(31 downto 0);



component Construct_sp_fp_mult_factor is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  input_exponent : in  STD_LOGIC_VECTOR (7 downto 0);
           sp_fp_mult_fact : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

signal csfmf_sp_fp_mult_fact : std_logic_vector(31 downto 0);


component sp_fp_mult is
  port (
    sclr : in STD_LOGIC := 'X'; 
    rdy : out STD_LOGIC; 
    operation_nd : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 31 downto 0 ); 
    b : in STD_LOGIC_VECTOR ( 31 downto 0 ); 
    result : out STD_LOGIC_VECTOR ( 31 downto 0 ) 
  );
end component;

signal mult_result : std_logic_vector(31 downto 0);
signal mult_valid_out : std_logic;


signal tmp_valid_in_vec_in1,tmp_valid_in_vec_out1,
		 tmp_valid_in_vec_in2,tmp_valid_in_vec_out2: std_logic_vector(0 downto 0);
		 
component Construct_sp_fp_add_offset is
  Port ( rst : in  STD_LOGIC;
         clk : in  STD_LOGIC;
         lut_index : in  STD_LOGIC_VECTOR(12 downto 0);
         sp_fp_add_offset : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

signal sp_fp_val_offset_reg_in , sp_fp_val_offset_reg_out: std_logic_vector(31 downto 0);

component sp_fp_add is
  port (
    sclr : in STD_LOGIC := 'X'; 
    rdy : out STD_LOGIC; 
    operation_nd : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 31 downto 0 ); 
    b : in STD_LOGIC_VECTOR ( 31 downto 0 ); 
    result : out STD_LOGIC_VECTOR ( 31 downto 0 ) 
  );
end component;

signal add_result : std_logic_vector(31 downto 0);
signal add_valid_out : std_logic;

signal no_special_case_result_32b : std_logic_Vector(31 downto 0);

component reg_1b_18c is
  port (
    sclr : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    d : in STD_LOGIC_VECTOR ( 0 downto 0 ); 
    q : out STD_LOGIC_VECTOR ( 0 downto 0 ) 
  );
end component;

component reg_32b_18c is
  port (
    sclr : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    d : in STD_LOGIC_VECTOR ( 31 downto 0 ); 
    q : out STD_LOGIC_VECTOR ( 31 downto 0 ) 
  );
end component;

component reg_33b_1c is
  port (
    sclr : in STD_LOGIC := 'X'; 
    clk : in STD_LOGIC := 'X'; 
    d : in STD_LOGIC_VECTOR ( 32 downto 0 ); 
    q : out STD_LOGIC_VECTOR ( 32 downto 0 ) 
  );
end component;

signal tmp_final_output_vec , tmp_final_output_vec_out : std_logic_vector(32 downto 0);

signal rst_reg_in , rst_reg_out : std_logic_vector(0 downto 0);

begin

rst_reg_in(0) <=rst;
Reset_Register : reg_1b_1c port map (rst, clk, rst_reg_in, rst_reg_out);


Valid_Input_Pipeline_Reg : reg_32b_1c port map (rst, clk, input_val, input_val_valid_reg);

tmp_valid_in_vec_in1(0)<=valid_in;
Valid_Input_Pipeline_Reg1 : reg_1b_1c port map (rst, clk, tmp_valid_in_vec_in1, tmp_valid_in_vec_out1);

-- Special Case Detector
special_case_detector_port_map: special_case_detector port map (
rst,
clk,
input_val_valid_reg,
scd_out_special_val_sel,
scd_out_output_special_val
);

-- Construct_sp_fp_mult_factor
Construct_sp_fp_mult_factor_port_map : Construct_sp_fp_mult_factor port map (
rst,
clk,
input_val_valid_reg(30 downto 23),
csfmf_sp_fp_mult_fact
);

-- Multiplier with constant port b : log10(2)

Valid_Input_Pipeline_Reg2 : reg_1b_2c port map (rst, clk, tmp_valid_in_vec_out1, tmp_valid_in_vec_out2);


sp_fp_mult_port_map : sp_fp_mult port map (
rst,
mult_valid_out,
tmp_valid_in_vec_out2(0),
clk,
csfmf_sp_fp_mult_fact,
log_base_e_of_2,
mult_result
);


-- Construct sp_fp_add_offset

Construct_sp_fp_add_offset_port_map: Construct_sp_fp_add_offset port map (
rst,
clk,
input_val_valid_reg(22 downto 10),
sp_fp_val_offset_reg_in

);

-- Pipeline Register for sp_fp_val_offset
val_offset_pipeline_reg : reg_32b_8c port map(rst,clk,sp_fp_val_offset_reg_in,sp_fp_val_offset_reg_out);

-- Final adder

sp_fp_add_port_map : sp_fp_add port map (
rst_reg_out(0),
tmp_valid_out,
mult_valid_out,
clk,
mult_result,
sp_fp_val_offset_reg_out,
no_special_case_result_32b
);

valid_output_1bvec_in(0) <= tmp_valid_out ;
reg_1b_1c_port_map_for_valid_out : reg_1b_1c port map (rst_reg_out(0), clk, valid_output_1bvec_in , valid_output_1bvec_out );
valid_out<=valid_output_1bvec_out(0);

-- Pipeline Register for special case value selection
scd_out_special_val_sel_1bvec(0)<=scd_out_special_val_sel;
reg_1b_21c_port_map : reg_1b_18c port map (rst_reg_out(0), clk, scd_out_special_val_sel_1bvec , scd_out_special_val_sel_reg_1bvec );
reg_32b_21c_port_map: reg_32b_18c port map (rst_reg_out(0),clk,scd_out_output_special_val,scd_out_output_special_val_reg);

scd_out_special_val_sel_reg_vec<=(others=>scd_out_special_val_sel_reg_1bvec(0));
scd_out_special_val_not_sel_reg_vec<=(others=>not scd_out_special_val_sel_reg_1bvec(0));


temp_final_result<= (scd_out_special_val_sel_reg_vec and scd_out_output_special_val_reg) or
						  (scd_out_special_val_not_sel_reg_vec and no_special_case_result_32b) ;


reg_32b_1c_port_map : reg_32b_1c port map (rst_reg_out(0), clk, temp_final_result , temp_final_result_reg );


output_val<=temp_final_result_reg;




end Behavioral;

