--
--  testbed for entity clk_rst.vhd
--  (c) jul 2007...  Gerhard Hoffmann, opencores@hoffmann-hochfrequenz.de
--  open source under BSD conditions

library IEEE;
use     IEEE.STD_LOGIC_1164.all;
use     IEEE.numeric_std.all;	


entity clk_rst_tb is
end entity clk_rst_tb;

architecture rtl of clk_rst_tb is

signal tb_clk: std_logic;
signal tb_rst: std_logic;

begin

uut: entity work.clk_rst
  generic  map(
    verbose           => true,
    clock_frequency   => 100.0e6,
    min_resetwidth    => 153 ns
  )
  port map(            
    clk               => tb_clk,
    rst               => tb_rst
  );  


end architecture rtl; 

