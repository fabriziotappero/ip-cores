
--------------------------------------------------------------------------------
-- (c) 2010.. Hoffmann RF & DSP  opencores@hoffmann-hochfrequenz.de
-- V1.0 published under BSD license
--------------------------------------------------------------------------------
-- file name:      sincos_tc.vhd
-- tool version:   ISE12.3  Modelsim 6.1, 6.5
-- description:    test chip for portable sine table
--------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sincos_tc is

   port (
      clk:        in  std_logic;
      ce:         in  std_logic := '1';
      rst:        in  std_logic := '0';

      theta:      in  unsigned(17 downto 0);
      sine:       out signed(17 downto 0);
      cosine:     out signed(17 downto 0)
   );  
end entity sincos_tc; 


architecture rtl of sincos_tc is

signal   verbose:         boolean := true;
constant pipestages:      integer :=5;


----------------------------------------------------------------------------------------------------

BEGIN
   
u_sin: entity work.sincostab   -- convert phase to sine
  generic map (
     pipestages => pipestages  
  )
  port map (
    clk         => clk,
    ce          => ce,
    rst         => rst,

    theta       => theta,
    sine        => sine,
    cosine      => cosine
  );  

END ARCHITECTURE rtl;
