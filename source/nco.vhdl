-- ------------------------------------------------------------------------
-- Copyright (C) 2004 Arif Endro Nugroho
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY ARIF ENDRO NUGROHO "AS IS" AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL ARIF ENDRO NUGROHO BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
-- ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
-- 
-- End Of License.
-- ------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity nco is
      port (
           clock       : in  bit;
	   clear       : in  bit;
           input_nco   : in  bit_vector (17 downto 0);
           offset      : in  bit_vector (17 downto 0);
           output_nco  : out bit_vector (07 downto 0)
           );
end nco;

architecture structural of nco is
   component addacc 
     port (
           clock       : in  bit;
           acc         : in  bit_vector (17 downto 0);
           result      : out bit_vector (17 downto 0);
           offset      : in  bit_vector (17 downto 0)
           );
   end component;

   component rom
     port (
           address     : in  bit_vector (09 downto 0);
           data        : out bit_vector (07 downto 0)
           );
   end component;

   signal adder_output : bit_vector (17 downto 0);
   signal address_in   : bit_vector (09 downto 0);
   signal output_rom   : bit_vector (07 downto 0);

begin
 
 myaddacc  : addacc
     port map (
              clock                 => clock,
              acc                   => input_nco,
              result (17 downto 0)  => adder_output,
              offset                => offset
              );
 myrom     : rom
     port map (
              address (09 downto 0) => address_in,
              data    (07 downto 0) => output_rom
              );

   address_in (09) <= (adder_output(17));
   address_in (08) <= (adder_output(16));
   address_in (07) <= (adder_output(15));
   address_in (06) <= (adder_output(14));
   address_in (05) <= (adder_output(13));
   address_in (04) <= (adder_output(12));
   address_in (03) <= (adder_output(11));
   address_in (02) <= (adder_output(10));
   address_in (01) <= (adder_output(09));
   address_in (00) <= (adder_output(08));

--   process (clock, clear)
   process (clock)

   begin

-- 20080625
-- fixme
-- how to enable clear signal in here... :(

--   if    (clear = '1') then
   if ((clock = '1') and clock'event) then

--	output_nco      <= (others => '0');

--   elsif (((clock = '1') and (not(clear) = '1')) and clock'event) then

	output_nco (07) <= (output_rom(07));
	output_nco (06) <= (output_rom(06));
	output_nco (05) <= (output_rom(05));
	output_nco (04) <= (output_rom(04));
	output_nco (03) <= (output_rom(03));
	output_nco (02) <= (output_rom(02));
	output_nco (01) <= (output_rom(01));
	output_nco (00) <= (output_rom(00));

   end if;
   
   end process;

end structural;
