-- <File header>
-- Project
--    pAVR (pipelined AVR) is an 8 bit RISC controller, compatible with Atmel's
--    AVR core, but about 3x faster in terms of both clock frequency and MIPS.
--    The increase in speed comes from a relatively deep pipeline. The original
--    AVR core has only two pipeline stages (fetch and execute), while pAVR has
--    6 pipeline stages:
--       1. PM    (read Program Memory)
--       2. INSTR (load Instruction)
--       3. RFRD  (decode Instruction and read Register File)
--       4. OPS   (load Operands)
--       5. ALU   (execute ALU opcode or access Unified Memory)
--       6. RFWR  (write Register File)
-- Version
--    0.32
-- Date
--    2002 August 07
-- Author
--    Doru Cuturela, doruu@yahoo.com
-- License
--    This program is free software; you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation; either version 2 of the License, or
--    (at your option) any later version.
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--    You should have received a copy of the GNU General Public License
--    along with this program; if not, write to the Free Software
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-- </File header>



-- <File info>
-- This defines pAVR's Register File.
-- The Register File has 3 ports: 2 for reading and 1 for writing. All these
--    access all 32 locations in the register file. Apart from these 3 ports,
--    there are 3 special ports that access 16 bit pointer registers X, Y, Z, for
--    both reading and writing. The pointer registers are mapped on the register
--    file, at addresses 26-27 (pointer register X), 28-29 (Y) and 30-31 (Z).
-- Physically, the register file consists of a memory-like entity with 26 8 bit
--    locations, and 3 16 bit registers. Together, these form the 32 locations
--    of the register file. The physical separation of locations <26 and >=26 is
--    is invisible from outside.
-- Writing on the write port and on every pointer register port can be done
--    in parallel. However, if writing at the same time a location via the write
--    port and one of the pointer registers, writing via pointer register port
--    has priority.
-- </File info>



-- <File body>
library work;
use work.std_util.all;
use work.pavr_util.all;
use work.pavr_constants.all;
library IEEE;
use IEEE.std_logic_1164.all;



entity pavr_rf is
   port(
      pavr_rf_clk:     in std_logic;
      pavr_rf_res:     in std_logic;
      pavr_rf_syncres: in std_logic;

      -- Read port 1
      pavr_rf_rd1_addr: in  std_logic_vector(4 downto 0);
      pavr_rf_rd1_rd:   in  std_logic;
      pavr_rf_rd1_do:   out std_logic_vector(7 downto 0);

      -- Read port 2
      pavr_rf_rd2_addr: in  std_logic_vector(4 downto 0);
      pavr_rf_rd2_rd:   in  std_logic;
      pavr_rf_rd2_do:   out std_logic_vector(7 downto 0);

      -- Write port
      pavr_rf_wr_addr: in std_logic_vector(4 downto 0);
      pavr_rf_wr_wr:   in std_logic;
      pavr_rf_wr_di:   in std_logic_vector(7 downto 0);

      -- Pointer registers
      pavr_rf_x:    out std_logic_vector(15 downto 0);
      pavr_rf_x_wr: in  std_logic;
      pavr_rf_x_di: in  std_logic_vector(15 downto 0);

      pavr_rf_y:    out std_logic_vector(15 downto 0);
      pavr_rf_y_wr: in  std_logic;
      pavr_rf_y_di: in  std_logic_vector(15 downto 0);

      pavr_rf_z:    out std_logic_vector(15 downto 0);
      pavr_rf_z_wr: in  std_logic;
      pavr_rf_z_di: in  std_logic_vector(15 downto 0)
   );
end;



architecture pavr_rf_arch of pavr_rf is

   signal pavr_rf_x_int: std_logic_vector(15 downto 0);
   signal pavr_rf_y_int: std_logic_vector(15 downto 0);
   signal pavr_rf_z_int: std_logic_vector(15 downto 0);

   type t_pavr_rf_data_array is array (0 to 25) of std_logic_vector(7 downto 0);
   signal pavr_rf_data_array: t_pavr_rf_data_array;

begin

   -- Read port 1
   process
      variable is_x, is_y, is_z: std_logic;
      variable tv: std_logic_vector(2 downto 0);
   begin
      tv := int_to_std_logic_vector(0, 3);

      wait until ((pavr_rf_clk'event) and (pavr_rf_clk = '1'));

      if (pavr_rf_rd1_addr(4 downto 1) = "1101") then
         is_x := '1';
      else
         is_x := '0';
      end if;

      if (pavr_rf_rd1_addr(4 downto 1) = "1110") then
         is_y := '1';
      else
         is_y := '0';
      end if;

      if (pavr_rf_rd1_addr(4 downto 1) = "1111") then
         is_z := '1';
      else
         is_z := '0';
      end if;

      if (pavr_rf_rd1_rd = '1') then
         tv := is_x & is_y & is_z;
         case tv is
            when "000" =>
               pavr_rf_rd1_do <= pavr_rf_data_array(std_logic_vector_to_nat(pavr_rf_rd1_addr));
            when "100" =>
               if (pavr_rf_rd1_addr(0) = '0') then
                  pavr_rf_rd1_do <= pavr_rf_x_int(7 downto 0);
               else
                  pavr_rf_rd1_do <= pavr_rf_x_int(15 downto 8);
               end if;
            when "010" =>
               if (pavr_rf_rd1_addr(0) = '0') then
                  pavr_rf_rd1_do <= pavr_rf_y_int(7 downto 0);
               else
                  pavr_rf_rd1_do <= pavr_rf_y_int(15 downto 8);
               end if;
            when others =>
               if (pavr_rf_rd1_addr(0) = '0') then
                  pavr_rf_rd1_do <= pavr_rf_z_int(7 downto 0);
               else
                  pavr_rf_rd1_do <= pavr_rf_z_int(15 downto 8);
               end if;
         end case;
      end if;
   end process;



   -- Read port 2
   process
      variable is_x, is_y, is_z: std_logic;
      variable tv: std_logic_vector(2 downto 0);
   begin
      tv := int_to_std_logic_vector(0, 3);

      wait until ((pavr_rf_clk'event) and (pavr_rf_clk = '1'));

      if (pavr_rf_rd2_addr(4 downto 1) = "1101") then
         is_x := '1';
      else
         is_x := '0';
      end if;

      if (pavr_rf_rd2_addr(4 downto 1) = "1110") then
         is_y := '1';
      else
         is_y := '0';
      end if;

      if (pavr_rf_rd2_addr(4 downto 1) = "1111") then
         is_z := '1';
      else
         is_z := '0';
      end if;

      if (pavr_rf_rd2_rd = '1') then
         tv := is_x & is_y & is_z;
         case tv is
            when "000" =>
               pavr_rf_rd2_do <= pavr_rf_data_array(std_logic_vector_to_nat(pavr_rf_rd2_addr));
            when "100" =>
               if (pavr_rf_rd2_addr(0) = '0') then
                  pavr_rf_rd2_do <= pavr_rf_x_int(7 downto 0);
               else
                  pavr_rf_rd2_do <= pavr_rf_x_int(15 downto 8);
               end if;
            when "010" =>
               if (pavr_rf_rd2_addr(0) = '0') then
                  pavr_rf_rd2_do <= pavr_rf_y_int(7 downto 0);
               else
                  pavr_rf_rd2_do <= pavr_rf_y_int(15 downto 8);
               end if;
            when others =>
               if (pavr_rf_rd2_addr(0) = '0') then
                  pavr_rf_rd2_do <= pavr_rf_z_int(7 downto 0);
               else
                  pavr_rf_rd2_do <= pavr_rf_z_int(15 downto 8);
               end if;
         end case;
      end if;
   end process;



   -- Write port and pointer registers
   process(pavr_rf_clk, pavr_rf_res, pavr_rf_syncres,
           pavr_rf_wr_addr, pavr_rf_wr_wr, pavr_rf_wr_di, pavr_rf_x_wr, pavr_rf_y_wr, pavr_rf_z_wr,
           pavr_rf_x_di, pavr_rf_y_di, pavr_rf_z_di)
      variable is_x, is_y, is_z: std_logic;
      variable tv: std_logic_vector(2 downto 0);
   begin
      tv := int_to_std_logic_vector(0, 3);

      if (pavr_rf_wr_addr(4 downto 1) = "1101") then
         is_x := '1';
      else
         is_x := '0';
      end if;

      if (pavr_rf_wr_addr(4 downto 1) = "1110") then
         is_y := '1';
      else
         is_y := '0';
      end if;

      if (pavr_rf_wr_addr(4 downto 1) = "1111") then
         is_z := '1';
      else
         is_z := '0';
      end if;

      if (pavr_rf_res = '1') then
         -- Asynchronous reset
         pavr_rf_x_int <= int_to_std_logic_vector(0, 16);
         pavr_rf_y_int <= int_to_std_logic_vector(0, 16);
         pavr_rf_z_int <= int_to_std_logic_vector(0, 16);
      elsif ((pavr_rf_clk'event) and (pavr_rf_clk = '1')) then

         -- Write port
         if (pavr_rf_wr_wr = '1') then
            tv := is_x & is_y & is_z;
            case tv is
               when "000" =>
                  pavr_rf_data_array(std_logic_vector_to_nat(pavr_rf_wr_addr)) <= pavr_rf_wr_di;
               when "100" =>
                  if (pavr_rf_wr_addr(0) = '0') then
                     pavr_rf_x_int(7 downto 0) <= pavr_rf_wr_di;
                  else
                     pavr_rf_x_int(15 downto 8) <= pavr_rf_wr_di;
                  end if;
               when "010" =>
                  if (pavr_rf_wr_addr(0) = '0') then
                     pavr_rf_y_int(7 downto 0) <= pavr_rf_wr_di;
                  else
                     pavr_rf_y_int(15 downto 8) <= pavr_rf_wr_di;
                  end if;
               when others =>
                  if (pavr_rf_wr_addr(0) = '0') then
                     pavr_rf_z_int(7 downto 0) <= pavr_rf_wr_di;
                  else
                     pavr_rf_z_int(15 downto 8) <= pavr_rf_wr_di;
                  end if;
            end case;
         end if;

         -- Write pointer registers. Possibly overwrite the above write.
         if (pavr_rf_x_wr = '1') then
            pavr_rf_x_int <= pavr_rf_x_di;
         end if;
         if (pavr_rf_y_wr = '1') then
            pavr_rf_y_int <= pavr_rf_y_di;
         end if;
         if (pavr_rf_z_wr = '1') then
            pavr_rf_z_int <= pavr_rf_z_di;
         end if;

         if (pavr_rf_syncres = '1') then
            -- Synchronous reset
            pavr_rf_x_int <= int_to_std_logic_vector(0, 16);
            pavr_rf_y_int <= int_to_std_logic_vector(0, 16);
            pavr_rf_z_int <= int_to_std_logic_vector(0, 16);
         end if;
      end if;
   end process;



   -- Zero-level assignments
   pavr_rf_x <= pavr_rf_x_int;
   pavr_rf_y <= pavr_rf_y_int;
   pavr_rf_z <= pavr_rf_z_int;

end;
-- </File body>
