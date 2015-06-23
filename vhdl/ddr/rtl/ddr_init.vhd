--------------------------------------------------------------------------------
-- Mycron® DDR SDRAM - MT46V32M16 - 8 Meg x 16 x 4 banks                      --
--------------------------------------------------------------------------------
-- Copyright (C)2012  Mathias Hörtnagl <mathias.hoertnagl@gmail.comt>         --
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

entity ddr_init is
   port (
      clk0      : in  std_logic;
      rst       : in  std_logic;
      SD_CKE    : out std_logic;
      SD_BA     : out std_logic_vector(1 downto 0);
      SD_A      : out std_logic_vector(12 downto 0);
      SD_CMD    : out std_logic_vector(3 downto 0);
      init_done : out boolean
   );
end ddr_init;

architecture rtl of ddr_init is

   -----------------------------------------------------------------------------
   -- Controller Commands                                                     --
   -----------------------------------------------------------------------------
   constant CMD_LMR          : std_logic_vector(3 downto 0) := "0000";
   constant CMD_AUTO_REFRESH : std_logic_vector(3 downto 0) := "0001";
   constant CMD_PRECHARGE    : std_logic_vector(3 downto 0) := "0010";
   constant CMD_NOP          : std_logic_vector(3 downto 0) := "0111";

   -----------------------------------------------------------------------------
   -- Mode Rgister Addresses                                                  --
   -----------------------------------------------------------------------------
   -- Addresses for the two mode registers, selected via SD_BA.
   constant BMR_ADDR : std_logic_vector(1 downto 0) := "00";
   constant EMR_ADDR : std_logic_vector(1 downto 0) := "01";

   -----------------------------------------------------------------------------
   -- Base Mode Rgister                                                       --
   -----------------------------------------------------------------------------
   -- Operating modes.
   constant OP_NORMAL  : std_logic_vector(5 downto 0) := "000000";
   constant OP_DLL_RST : std_logic_vector(5 downto 0) := "000010";

   -- CAS latency.
   constant CAS_2  : std_logic_vector(2 downto 0) := "010";

   -- Burst type.
   constant BT_S : std_logic := '0';      -- Sequential.

   -- Burst lengths.
   constant BL_2 : std_logic_vector(2 downto 0) := "001";

   -----------------------------------------------------------------------------
   -- Extended Mode Rgister                                                   --
   -----------------------------------------------------------------------------
   -- DLL.
   constant DLL_ENABLE  : std_logic := '0';
   constant DLL_DISABLE : std_logic := '1';

   -- Drive strength.
   constant DS_NORMAL  : std_logic := '0';


   -----------------------------------------------------------------------------
   -- Initialization                                                          --
   -----------------------------------------------------------------------------
   type init_state_t is (
      Wait20000,                          -- Wait for 200µs.
      CKE_High,                           -- Assert CKE.
      Precharge0, Precharge0Wait,         -- First precharge.
      ProgramEMR, ProgramEMRWait,         -- Set Extended Mode Register.
      ProgramMR, ProgramMRWait,           -- Set Base Mode Register.
      Precharge1, Precharge1Wait,         -- second precharge.
      AutoRefresh0, AutoRefresh0Wait,     -- First autorefresh.
      AutoRefresh1, AutoRefresh1Wait,     -- Second autorefresh.
      ProgramMR1, ProgramMR1Wait,         -- Set Base Mode Register.
      Wait200,                            -- Wait for 200 cycles.
      Done                                -- Initialization done!
   );

   type init_t is record
      s   : init_state_t;
      c   : natural range 0 to 19999;
   end record;

   constant init_d  : init_t := init_t'( Wait20000, 0);
   signal i, iin    : init_t := init_d;
begin

   -----------------------------------------------------------------------------
   -- Initialization                                                          --
   -----------------------------------------------------------------------------
   initial : process(i)
   begin

      iin       <= i;
      SD_CKE    <= '1';
      SD_BA     <= "00";
      SD_CMD    <= CMD_NOP;
      SD_A      <= (others => '0');
      init_done <= false;

      case i.s is

         -----------------------------------------------------------------------
         -- 5. Wait for 200µs.                                                --
         -----------------------------------------------------------------------
         when Wait20000 =>
            SD_CKE <= '0';
            if i.c = 19999 then
               iin.c <= 0;
               iin.s <= CKE_High;
            else
               iin.c <= i.c + 1;
            end if;

         -----------------------------------------------------------------------
         -- 6. Bring CKE high.                                                --
         -----------------------------------------------------------------------
         when CKE_High =>
            iin.s <= Precharge0;

         -----------------------------------------------------------------------
         -- 7. Precharge all banks.                                           --
         -----------------------------------------------------------------------
         when Precharge0 =>
            SD_CMD      <= CMD_PRECHARGE;
            SD_A(10) <= '1';               -- Precharge all operation.
            iin.s       <= Precharge0Wait;

         -- PRECHARGE command period tRP: 15ns
         when Precharge0Wait =>
            if i.c = 1 then
               iin.c <= 0;
               iin.s <= ProgramEMR;
            else
               iin.c <= i.c + 1;
            end if;

         -----------------------------------------------------------------------
         -- 9. Program the Extended Mode Register.                            --
         -----------------------------------------------------------------------
         when ProgramEMR =>
            SD_CMD  <= CMD_LMR;
            SD_BA   <= EMR_ADDR;              -- Select Extended Mode Register.
            SD_A    <= "00000000000" & DS_NORMAL & DLL_DISABLE;
            iin.s   <= ProgramEMRWait;

         -- LOAD MODE REGISTER command cycle time tMRD: 12ns
         when ProgramEMRWait =>
            if i.c = 1 then
               iin.c <= 0;
               iin.s <= ProgramMR;
            else
               iin.c <= i.c + 1;
            end if;

         -----------------------------------------------------------------------
         -- 11. Program the Mode Rgister                                      --
         -----------------------------------------------------------------------
         when ProgramMR =>
            SD_CMD  <= CMD_LMR;
            SD_BA   <= BMR_ADDR;              -- Select Base Mode Register.
            SD_A    <= OP_NORMAL & CAS_2 & BT_S & BL_2;
            iin.s   <= ProgramMRWait;

         -- LOAD MODE REGISTER command cycle time tMRD: 12ns
         when ProgramMRWait =>
            if i.c = 1 then
               iin.c <= 0;
               iin.s <= Precharge1;
            else
               iin.c <= i.c + 1;
            end if;

         -----------------------------------------------------------------------
         -- 13. Precharge all banks.                                          --
         -----------------------------------------------------------------------
         when Precharge1 =>
            SD_CMD   <= CMD_PRECHARGE;
            SD_A(10) <= '1';               -- Precharge all operation.
            iin.s    <= Precharge1Wait;

         -- PRECHARGE command period tRP: 15ns
         when Precharge1Wait =>
            if i.c = 1 then
               iin.c <= 0;
               iin.s <= AutoRefresh0;
            else
               iin.c <= i.c + 1;
            end if;

         -----------------------------------------------------------------------
         -- 15. Auto Refresh.                                                 --
         -----------------------------------------------------------------------
         when AutoRefresh0 =>
            SD_CMD <= CMD_AUTO_REFRESH;
            iin.s  <= AutoRefresh0Wait;

         -- AUTO REFRESH command period tRFC: 72ns
         when AutoRefresh0Wait =>
            if i.c = 7 then
               iin.c <= 0;
               iin.s <= AutoRefresh1;
            else
               iin.c <= i.c + 1;
            end if;

         -----------------------------------------------------------------------
         -- 17. Auto Refresh.                                                 --
         -----------------------------------------------------------------------
         when AutoRefresh1 =>
            SD_CMD <= CMD_AUTO_REFRESH;
            iin.s  <= AutoRefresh1Wait;

         -- AUTO REFRESH command period tRFC: 72ns
         when AutoRefresh1Wait =>
            if i.c = 7 then
               iin.c <= 0;
               iin.s <= ProgramMR1;
            else
               iin.c <= i.c + 1;
            end if;

         -----------------------------------------------------------------------
         -- 19. Program the Mode Rgister (Clear DLL Bit)                      --
         -----------------------------------------------------------------------
         when ProgramMR1 =>
            SD_CMD  <= CMD_LMR;
            SD_BA   <= BMR_ADDR;              -- Select Base Mode Register.
            SD_A    <= OP_NORMAL & CAS_2 & BT_S & BL_2;
            iin.s   <= ProgramMR1Wait;

         -- LOAD MODE REGISTER command cycle time tMRD: 12ns
         when ProgramMR1Wait =>
            if i.c = 1 then
               iin.c <= 0;
               iin.s <= Wait200;
            else
               iin.c <= i.c + 1;
            end if;            
            
         -----------------------------------------------------------------------
         -- 21. Wait for 200 cycles.                                          --
         -----------------------------------------------------------------------
         when Wait200 =>
            if i.c = 199 then
               iin.c <= 0;
               iin.s <= Done;
            else
               iin.c <= i.c + 1;
            end if;

         -----------------------------------------------------------------------
         -- Initialization done.                                              --
         -----------------------------------------------------------------------
         when Done =>
            init_done <= true;
      end case;
   end process;


   -----------------------------------------------------------------------------
   -- Register                                                                --
   -----------------------------------------------------------------------------
   reg : process(clk0)
   begin
      if rising_edge(clk0) then
         if rst = '1' then i <= init_d; else i <= iin; end if;
      end if;
   end process;
end rtl;