----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:03:52 06/22/2009 
-- Design Name: 
-- Module Name:    synthTest - Behavioral 
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

entity synthTest is
  port (
    clk : in std_logic;
    ce_i    :  in  std_logic;    
    reset   :  in  std_logic;
    data_i  :  in  std_logic;
    out_new     :  out std_logic_vector(3 downto 0);
    nd_new :  out std_logic
  );
end synthTest;

architecture Behavioral of synthTest is


  COMPONENT singleDouble
	PORT(
    clk_i   :  in  std_logic;
    ce_i    :  in  std_logic;    
    rst_i   :  in  std_logic;
    data_i  :  in  std_logic;
    q_o     :  out std_logic_vector(3 downto 0);
    ready_o :  out std_logic
		);
	END COMPONENT;

begin


  Inst_modified: singleDouble PORT MAP(
    clk_i =>  clk,
    ce_i  =>  ce_i,
    rst_i  =>  reset,
    data_i   =>  data_i,
    q_o     =>  out_new,
    ready_o    =>  nd_new
  );

end Behavioral;

