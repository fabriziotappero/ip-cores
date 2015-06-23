----------------------------------------------------------------------------------
-- Company: ISI/Nallatech
-- Engineer: Luis Munoz
-- 
-- Create Date:        09:09:53 07/07/2011 
--
-- Module Name:        patternGen_tb - Behavioral 
--
-- Project Name:       Video Pattern Generator Test Bench
--
-- Target Devices:     Xilinx Spartan-LX150T-2 using Xilinx ISE 13.1 and ISIM 13.1
--
-- Description:        Test Bench for the patternGen module
--
--
-- Revision:           1.0 Initial Release
--
-- Additional Comments:  The assumption is that the width is larger than the height
--       
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity patterGen_tb is
end patterGen_tb;

architecture Behavioral of patterGen_tb is
    -- toplevel constants for patterGen component
   constant FrameWidth      : integer := 640; -- # of pixels per line
   constant FrameHeight     : integer := 512; -- # of lines in a frame
   constant PIXEL_SIZE      : integer := 8;   -- # of bits each pixel has
   constant REG_SIZE        : integer := 16;   -- # size of register to store width count and heigh count
    -- toplevel signals for patternGen component
   signal CLK_i             : std_logic;
   signal RST_i             : std_logic;
   signal SEL_i             : std_logic_vector(2 downto 0);
   signal CLKen_i           : std_logic;          
   signal VALID_o           : std_logic;
   signal ENDline_o         : std_logic;
   signal ENDframe_o        : std_logic;
   signal PIXEL_o           : std_logic_vector(7 downto 0);

begin
------------------------------------------------------
   ---------------------------------------------------
   -- stimulus 
   ---------------------------------------------------
   stim : process
   begin
       RST_i    <= '1';
       SEL_i    <= "010"; -- vertical line pattern
       CLKen_i  <= '0';
       wait for 80 ns;    -- wait two cycles and release reset
       RST_i    <= '0';
       wait for 80 ns;    -- wait two cycles and enable output 
         
       wait for 106000000 ns;
       report "End of simulation! (ignore this failure)"
           severity failure;
       wait;
   end process;

   ---------------------------------------------------
   -- unit under test
   ---------------------------------------------------
   Inst_patternGen: entity work.patternGen 
    generic map(
      FrameWidth   => 80,  -- # of pixels per line
      FrameHeight  => 40,  -- # of lines in a frame
      PIXEL_SIZE   => 8,   -- # of bits each pixel has
      REG_SIZE     => 16   -- # size of register to store width count and heigh count    
    )
    port map(
        CLK_i       => CLK_i,
        RST_i       => RST_i,
        SEL_i       => SEL_i,
        CLKen_i     => CLKen_i,
        VALID_o     => VALID_o,
        ENDline_o   => ENDline_o,
        ENDframe_o  => ENDframe_o,
        PIXEL_o     => PIXEL_o
    );
   ---------------------------------------------------
   -- clock
   ---------------------------------------------------
   clock_gen : process
   begin
      CLK_i <= '0';
      wait for 20 ns;
      CLK_i <= '1';
      wait for 20 ns;
   end process;

------------------------------------------------------
end Behavioral;

