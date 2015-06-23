--------------------------------------------------------------------------------
-- Wishbone Shared Bus Intercon                                               --
--------------------------------------------------------------------------------
-- Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.comt>         --
--                                                                            --
-- This program is free software: you can redistribute it and/or modify       --
-- it under the terms of the GNU General Public License as published by       --
-- the Free Software Foundation, either version 3 of the License, or          --
-- (at your option) any later version.                                        --
--                                                                            --
-- This program is distributed in the hope that it will be useful,            --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of             --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              --
-- GNU General Public License for more details.                               --
--                                                                            --
-- You should have received a copy of the GNU General Public License          --
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.      --
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.icon.all;
use work.iwb.all;

entity intercon is
   port(
      CLK50_I  : in  std_logic;
      CLK25_I  : in  std_logic;
      RST_I    : in  std_logic;
      mi       : out master_in_t;
      mo       : in  master_out_t;
      brami    : out slave_in_t;
      bramo    : in  slave_out_t;
      flasi    : out slave_in_t;
      flaso    : in  slave_out_t;
      ddri     : out slave_in_t;
      ddro     : in  slave_out_t;
      dispi    : out slave_in_t;
      dispo    : in  slave_out_t;
      keybi    : out slave_in_t;
      keybo    : in  slave_out_t;
      piti     : out slave_in_t;
      pito     : in  slave_out_t;
      uartri   : out slave_in_t;
      uartro   : in  slave_out_t;
      uartti   : out slave_in_t;
      uartto   : in  slave_out_t
   );
end intercon;

architecture sbus of intercon is

   -- Set default slave signals.
   function setDefault(mo : master_out_t; CLK, RST : std_logic)
   return slave_in_t is
      variable v : slave_in_t;
   begin
      v.clk := CLK;
      v.rst := RST;
      v.stb := '0';
      v.we  := '0';
      v.dat := mo.dat;
      v.sel := mo.sel;
      v.adr := mo.adr;
      return v;
   end setDefault;

begin
   mux : process(CLK50_I, RST_I, mo, bramo, dispo, keybo, pito, flaso, uartro,
                 uartto, ddro, CLK25_I)

      variable padr : std_logic_vector(27 downto 0);
   begin
      mi.clk <= CLK50_I;
      mi.rst <= RST_I;
      mi.dat <= (others => '0');

      -- NOTE: Set mi.ack = '1' if you want to continue execution outside the
      --       valid address space. If set to zero and your programm reads or
      --       writes outside the specified addresses the cpu waits infinitly
      --       for an acknolege.
      mi.ack <= '0';

      brami  <= setDefault(mo, CLK50_I, RST_I);
      flasi  <= setDefault(mo, CLK50_I, RST_I);
      ddri   <= setDefault(mo, CLK50_I, RST_I);
      dispi  <= setDefault(mo, CLK50_I, RST_I);
      keybi  <= setDefault(mo, CLK50_I, RST_I);
      piti   <= setDefault(mo, CLK50_I, RST_I);
      uartri <= setDefault(mo, CLK50_I, RST_I);
      uartti <= setDefault(mo, CLK50_I, RST_I);

      padr := mo.adr(27 downto 0);

      case mo.adr(31 downto 28) is

         -----------------------------------------------------------------------
         -- Block Memory                                                      --
         -----------------------------------------------------------------------
         when X"0" =>
         -- if (padr >= X"0000000") and (padr < X"0004000") then
            brami.stb <= mo.stb;
            brami.we  <= mo.we;
            mi.dat <= bramo.dat;
            mi.ack <= bramo.ack;
         -- end if;

         -----------------------------------------------------------------------
         -- Flash Memory                                                      --
         -----------------------------------------------------------------------
         when X"1" =>
            --if (padr >= X"0000000") and (padr < X"1000000") then
            flasi.stb <= mo.stb;
            flasi.we  <= mo.we;
            mi.dat <= flaso.dat;
            mi.ack <= flaso.ack;
            --end if;

         -----------------------------------------------------------------------
         -- DDR2 Memory                                                       --
         -----------------------------------------------------------------------            
         when x"2" =>
            ddri.stb <= mo.stb;
            ddri.we  <= mo.we;
            mi.dat <= ddro.dat;
            mi.ack <= ddro.ack;            
         
         -----------------------------------------------------------------------
         -- Peripheral IO                                                     --
         -----------------------------------------------------------------------
         when X"F" =>

            --------------------------------------------------------------------
            -- Display                                                        --
            --------------------------------------------------------------------
            -- 4096 blocks, 16bit per block = 8192 (0x2000)
            if (padr >= X"FFF0000") and (padr < X"FFF2000") then
               dispi.stb <= mo.stb;
               dispi.we  <= mo.we;
               mi.dat <= dispo.dat;
               mi.ack <= dispo.ack;

            -- NOTE: The following addresses are strict. If you try to load or
            --       store a halfword or a byte, the addresses obviously do NOT
            --       match.
            --------------------------------------------------------------------
            -- Keyboard                                                       --
            --------------------------------------------------------------------
            -- 1 block, 32bit, read only
            elsif padr = X"FFF3000" then
               keybi.stb <= mo.stb;
               keybi.we  <= mo.we;
               mi.dat <= keybo.dat;
               mi.ack <= keybo.ack;

            --------------------------------------------------------------------
            -- RS-232 Serial Port                                             --
            --------------------------------------------------------------------
            -- 1 block, 32bit, read only
            elsif padr = X"FFF4000" then
               uartri.stb <= mo.stb;
               uartri.we  <= mo.we;
               mi.dat <= uartro.dat;
               mi.ack <= uartro.ack;

            -- 1 block, 32bit, write only
            elsif padr = X"FFF4004" then
               uartti.stb <= mo.stb;
               uartti.we  <= mo.we;
               mi.dat <= uartto.dat;
               mi.ack <= uartto.ack;

            --------------------------------------------------------------------
            -- Timer                                                          --
            --------------------------------------------------------------------
            -- 1 block, 32bit, r/w
            elsif padr = X"FFFF000" then
               piti.stb <= mo.stb;
               piti.we  <= mo.we;
               mi.dat <= pito.dat;
               mi.ack <= pito.ack;
            end if;

         when others =>

      end case;
   end process;
end sbus;