--------------------------------------------------------------------------------
-- MIPS™ I CPU - Wishbone Master                                              --
--------------------------------------------------------------------------------
--                                                                            --
-- KNOWN BUGS:                                                                --
--                                                                            --
--  o The master cause some severe trouble when communicating with slave      --
--    interfaces that run on a different frequency than the master itself.    --
--       In order to get the DDR to work with a 50 MHz master, I added an     --
--    interface solely running at 50 MHz while the remaining DDR controller   --
--    runs at 25 MHz.                                                         --
--                                                                            --
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
use work.iwb.all;
use work.icpu.all;

entity wbm is
   port(
      mi  : in  master_in_t;
      mo  : out master_out_t;
   -- Non Wishbone Signals
      ci  : out cpu_in_t;
      co  : in  cpu_out_t;
      irq : in  std_logic_vector(7 downto 0)
   );
end wbm;

architecture rtl of wbm is

   type state_t is (Init, I0, I1, I2, D0, D1, D2, Cpu);

   type regs_t is
   record
      s : state_t;
      i : std_logic_vector(31 downto 0);
      d : std_logic_vector(31 downto 0);
   end record;
   
   constant regs_d : regs_t := 
      regs_t'( Init, (others => '0'), (others => '0') );
   
   signal r, rin : regs_t := regs_d;
begin

   ci.clk <= mi.clk;
   ci.rst <= mi.rst;

   process(irq, r, co, mi.ack, mi.dat)
   
      variable t2 : std_logic_vector(31 downto 0);
   begin

      rin <= r;

      t2 := (others => '0');
      
      ci.hld <= '1';
      ci.ins <= (others => '0');       -- AREA: (others => '-');
      ci.dat <= (others => '0');       -- AREA: (others => '-');
      ci.irq <= irq;

      mo.adr <= (others => '0');       -- AREA: (others => '-');
      mo.dat <= (others => '0');       -- AREA: (others => '-');
      mo.we  <= '0';
      mo.sel <= (others => '0');
      mo.stb <= '0';

      case r.s is
      
         when Init =>
            rin.s <= I0;
            
         -----------------------------------------------------------------------
         -- Instruction                                                       --
         -----------------------------------------------------------------------        
         -- First stage of instruction fetch. Wait for memory device to be done
         -- loading desired data.
         when I0 =>
            mo.adr <= co.iadr;
            mo.sel <= "1111";
            mo.stb <= '1';
            if mi.ack = '1' then
               --rin.i <= mi.dat;
               rin.s <= I1;
            end if;
         
         -- Latch fetched instruction.
         -- If co.sel is not null, there is data to be processed from the memory
         -- stage. Else directly execute instruction.
         when I1 =>
            mo.adr <= co.iadr;
            mo.sel <= "1111";
            mo.stb <= '1';
            rin.i  <= mi.dat;
            rin.s  <= I2; 
 
         when I2 =>
            if mi.ack = '0' then
               if co.sel = x"0" then
                  rin.s <= Cpu;
               else
                  rin.s <= D0;
               end if;               
            end if;
         
         -----------------------------------------------------------------------
         -- Data                                                              --
         -----------------------------------------------------------------------            
         -- Set data to be written to propper location on the 32bit bus, 
         -- according to co.sel.
         -- Wait until I/O device is ready.
         when D0 =>
            mo.adr <= co.dadr;
            case co.sel is
               when "0001" => mo.dat(7 downto 0)   <= co.dat(7 downto 0);
               when "0010" => mo.dat(15 downto 8)  <= co.dat(7 downto 0);
               when "0100" => mo.dat(23 downto 16) <= co.dat(7 downto 0);
               when "1000" => mo.dat(31 downto 24) <= co.dat(7 downto 0);
               when "0011" => mo.dat(15 downto 0)  <= co.dat(15 downto 0);
               when "1100" => mo.dat(31 downto 16) <= co.dat(15 downto 0);
               when others => mo.dat               <= co.dat;
            end case;
            mo.we  <= co.we;
            mo.sel <= co.sel;
            mo.stb <= '1';
            if mi.ack = '1' then
               rin.s <= D1;
            end if;
         
         -- Finish write cycle or latch read data.
         when D1 =>
            mo.adr <= co.dadr;
            
            -- Read.
            case co.sel is
               when "0001" => t2(7 downto 0)  := mi.dat(7 downto 0);
               when "0010" => t2(7 downto 0)  := mi.dat(15 downto 8);
               when "0100" => t2(7 downto 0)  := mi.dat(23 downto 16);
               when "1000" => t2(7 downto 0)  := mi.dat(31 downto 24);
               when "0011" => t2(15 downto 0) := mi.dat(15 downto 0);
               when "1100" => t2(15 downto 0) := mi.dat(31 downto 16);
               when others => t2              := mi.dat;
            end case;
            
            -- Write.
            case co.sel is
               when "0001" => mo.dat(7 downto 0)   <= co.dat(7 downto 0);
               when "0010" => mo.dat(15 downto 8)  <= co.dat(7 downto 0);
               when "0100" => mo.dat(23 downto 16) <= co.dat(7 downto 0);
               when "1000" => mo.dat(31 downto 24) <= co.dat(7 downto 0);
               when "0011" => mo.dat(15 downto 0)  <= co.dat(15 downto 0);
               when "1100" => mo.dat(31 downto 16) <= co.dat(15 downto 0);
               when others => mo.dat               <= co.dat;
            end case;
            
            mo.we  <= co.we;
            mo.sel <= co.sel;
            mo.stb <= '1';
            rin.d  <= t2;
            rin.s  <= D2;
  
         when D2 =>
            if mi.ack = '0' then
               rin.s <= Cpu;
            end if;

         -----------------------------------------------------------------------
         -- Run CPU                                                           --
         -----------------------------------------------------------------------             
         -- Enable CPU and run it for one cycle, then at least fetch the next 
         -- instruction.
         when Cpu =>
            ci.hld <= '0';
            ci.ins <= r.i;
            ci.dat <= r.d;
            rin.s  <= I0;
      end case;
   end process;

   reg : process(mi.clk)
   begin
      if rising_edge(mi.clk) then        
         if mi.rst = '1' then r <= regs_d; else r <= rin; end if;
      end if;
   end process;
end architecture;