----------------------------------------------------------------------------------
-- Company: TUM - Technischen Universität München
-- Engineer: N.Alachiotis
-- 
-- Create Date:    14:49:49 06/24/2009 
-- Design Name: 
-- Module Name:    Construct_sp_fp_add_offset - Behavioral 
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

entity Construct_sp_fp_add_offset is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           lut_index : in  STD_LOGIC_VECTOR(12 downto 0);
           sp_fp_add_offset : out  STD_LOGIC_VECTOR (31 downto 0));
end Construct_sp_fp_add_offset;

architecture Behavioral of Construct_sp_fp_add_offset is

component mant_lut_MEM is
  port (
    clka : in STD_LOGIC := 'X'; 
    addra : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
    douta : out STD_LOGIC_VECTOR ( 26 downto 0 ) 
  );
end component;

component comp_eq_000000000000 is
  port (
    sclr : in STD_LOGIC := 'X'; 
    qa_eq_b : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 11 downto 0 ) 
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

signal eq_000000000000 : std_logic;

signal mant_lut_addra : std_logic_vector(11 downto 0);
signal mant_lut_dout : std_logic_vector(26 downto 0);

signal sp_fp_val_offset , sp_fp_val_offset_reg: std_logic_vector(31 downto 0);

begin

-- Mantissa Look Up Table
mant_lut_addra(11 downto 1) <= lut_index(12 downto 2);
mant_lut_addra(0) <= lut_index(1);-- or lut_index(0);

mant_lut_MEM_port_map:  mant_lut_MEM port map (clk,mant_lut_addra,mant_lut_dout);

-- Comparator for the MSBs of mantLUT dout
comp_eq_000000000000_port_map : comp_eq_000000000000 port map (rst, eq_000000000000 , clk , lut_index(12 downto 1));

sp_fp_val_offset(31 downto 30) <= "00";
sp_fp_val_offset(29 downto 27) <=(others=>not eq_000000000000);
sp_fp_val_offset(26 downto 0) <= mant_lut_dout;

-- Output Register

reg_32b_1c_port_map : reg_32b_1c port map (rst, clk, sp_fp_val_offset , sp_fp_add_offset);



end Behavioral;

