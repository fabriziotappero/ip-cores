--************************************************************************************************
-- Internal I/O registers decoder/multiplexer for the AVR core
-- Version 1.11
-- Modified 05.06.2003
-- Designed by Ruslan Lepetenok
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;

use WORK.AVRuCPackage.all;

entity io_adr_dec is port (
          adr          : in std_logic_vector(5 downto 0);         
          iore         : in std_logic;         
          dbusin_ext   : in std_logic_vector(7 downto 0);
          dbusin_int   : out std_logic_vector(7 downto 0);
                    
          spl_out      : in std_logic_vector(7 downto 0); 
          sph_out      : in std_logic_vector(7 downto 0);           
          sreg_out     : in std_logic_vector(7 downto 0);           
          rampz_out    : in std_logic_vector(7 downto 0));
end io_adr_dec;

architecture RTL of io_adr_dec is

begin

dbusin_int <= spl_out   when (adr=SPL_Address  and iore='1') else
              sph_out  when  (adr=SPH_Address  and iore='1') else
              sreg_out when  (adr=SREG_Address  and iore='1') else
              rampz_out when (adr=RAMPZ_Address and iore='1') else
              dbusin_ext;

end RTL;
