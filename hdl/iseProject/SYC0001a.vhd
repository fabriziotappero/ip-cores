--! @file
--! @brief SYSCON core avaible at: http://www.pldworld.com/_hdl/2/_ip/-silicore.net/wishbone.htm

library ieee;
use ieee.std_logic_1164.all;


entity SYC0001a is
    port(
           -- WISHBONE Interface
            CLK_O:  out std_logic;	--! Clock output
            RST_O:  out std_logic;	--! Reset output
            -- NON-WISHBONE Signals
            EXTCLK: in  std_logic;	--! Clock input
            EXTRST: in  std_logic	--! Reset input
         );

end SYC0001a;



--! @brief Architecture definition. of SYSCON core
--! @details Architecture definition. of SYSCON core
architecture SYC0001a1 of SYC0001a IS

begin
    

    MAKE_VISIBLE: process( EXTCLK, EXTRST )
    begin

        CLK_O <= EXTCLK;
        RST_O <= EXTRST;

    end process MAKE_VISIBLE;

end architecture SYC0001a1;
