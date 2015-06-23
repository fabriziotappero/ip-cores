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

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.iwb.all;
use work.iddr.all;

entity ddr is
   port (
      si       : in    slave_in_t;
      so       : out   slave_out_t;
   -- Non Wishbone Signals
      clk0     : in    std_logic;
      clk90    : in    std_logic;
      SD_CK_N  : out   std_logic;
      SD_CK_P  : out   std_logic;
      SD_CKE   : out   std_logic;
      SD_BA    : out   std_logic_vector(1 downto 0);
      SD_A     : out   std_logic_vector(12 downto 0);
      SD_CMD   : out   std_logic_vector(3 downto 0);
      SD_DM    : out   std_logic_vector(1 downto 0);
      SD_DQS   : inout std_logic_vector(1 downto 0);
      SD_DQ    : inout std_logic_vector(15 downto 0)
   );
end ddr;

architecture rtl of ddr is

   -----------------------------------------------------------------------------
   -- General                                                                 --
   -----------------------------------------------------------------------------
   -- Average periodic refresh interval tREFI: 7.8 µs
   constant AR_RATE : natural := 160; -- x 40 ns = 5.8 µs.

   -----------------------------------------------------------------------------
   -- Controller Commands                                                     --
   -----------------------------------------------------------------------------
   constant CMD_AUTO_REFRESH : std_logic_vector(3 downto 0) := "0001";
   constant CMD_PRECHARGE    : std_logic_vector(3 downto 0) := "0010";
   constant CMD_ACTIVE       : std_logic_vector(3 downto 0) := "0011";
   constant CMD_WRITE        : std_logic_vector(3 downto 0) := "0100";
   constant CMD_READ         : std_logic_vector(3 downto 0) := "0101";
   constant CMD_NOP          : std_logic_vector(3 downto 0) := "0111";

   -----------------------------------------------------------------------------
   -- Wishbone Controller                                                     --
   -----------------------------------------------------------------------------
   type wb_state_t is (
      Initialize,                            -- Initialization.
      Idle,                                  -- Wait for user or autorefresh.
      Ack                                    -- WB wait for ack.
   );

   signal w, win  : wb_state_t := Initialize;
   
   signal ddr_done : boolean;                -- Successful read or wirte.
   signal read_wb  : boolean;                -- Pending WB read.
   signal write_wb : boolean;                -- Pending WB write.
   
   -----------------------------------------------------------------------------
   -- Main Controller                                                         --
   -----------------------------------------------------------------------------
   type main_state_t is (
      Initialize,                            -- Initialization.
      Idle,                                  -- Wait for user or autorefresh.
      AutoRefresh, AutoRefreshWait,          -- Autorefresh when idle.
      Active, ActiveWait,                    -- Activate Row.
      Write, RecoverWrite,                   -- Write 32 bit.
      Read, WaitRead,                        -- Read 32 bit.
      PrechargeWait,                         -- Wait for precharge after Write.
      Ack                                    -- WB wait for ack.
   );

   type main_t is record
      s    : main_state_t;
      c    : natural range 0 to 7;
      a    : natural range 0 to AR_RATE-1;    -- Auto refresh counter.
      rfsh : boolean;                         -- Pending autorefresh.
      cmd  : std_logic_vector(3 downto 0);    -- SD_CS SD_RAS SD_CAS SD_WE.
      ba   : std_logic_vector(1 downto 0);    -- DDR bank address.
      adr  : std_logic_vector(12 downto 0);   -- DDR address bus.
   end record;

   constant main_d : main_t := 
      main_t'(Initialize, 0, 0, false, CMD_NOP, "00", (others => '0') );

   signal m, min  : main_t := main_d;
   
   signal dq      : std_logic_vector(15 downto 0);    -- Data tb be written.
   signal dqs     : std_logic_vector(1 downto 0);     -- Data strobe signal.
   signal dm      : std_logic_vector(1 downto 0);     -- Data mask signal.
   signal mask    : std_logic_vector(3 downto 0);

   signal wr_en   : boolean;
   signal wr_en2  : boolean;

   signal rd      : std_logic_vector(31 downto 0);    -- Read data latch.
   signal rd_en   : boolean;                          -- Read latch enable.
   signal rd_en2  : boolean;


   -----------------------------------------------------------------------------
   -- Initialization                                                          --
   -----------------------------------------------------------------------------
   component ddr_init is
      port (
         clk0      : in  std_logic;
         rst       : in  std_logic;
         SD_CKE    : out std_logic;
         SD_BA     : out std_logic_vector(1 downto 0);
         SD_A      : out std_logic_vector(12 downto 0);
         SD_CMD    : out std_logic_vector(3 downto 0);
         init_done : out boolean
      );
   end component;

   type init_c is record
      cmd  : std_logic_vector(3 downto 0);   -- SD_CS | SD_RAS | SD_CAS | SD_WE.
      ba   : std_logic_vector(1 downto 0);   -- DDR bank address.
      adr  : std_logic_vector(12 downto 0);  -- DDR address bus.
      done : boolean;                        -- True on Init completion.
   end record;

   signal init : init_c;
begin

   SD_CK_P <= not clk0;
   SD_CK_N <= clk0;


   -----------------------------------------------------------------------------
   -- Initialization                                                          --
   -----------------------------------------------------------------------------
   init_fsm : ddr_init port map(
      clk0      => clk0,
      rst       => si.rst,
      SD_CKE    => SD_CKE,
      SD_BA     => init.ba,
      SD_A      => init.adr,
      SD_CMD    => init.cmd,
      init_done => init.done
   );
   
   -----------------------------------------------------------------------------
   -- Wishbone Controller                                                     --
   -----------------------------------------------------------------------------
   -- NOTE: The Whishbone Controller runs at 50 MHz. There is a problem with the
   --       communication protocol implementation, which does not allow a master 
   --       and a slave running at different frequencies.
   --       If this problem happens to be fixed someday, the following state 
   --       machine can be deleted and the Wishbone signals can be tied directly
   --       into the main state machine.   
   wbone : process(w, si, init.done, ddr_done)
   begin
      
      win <= w;
      
      so.ack   <= '0';
      read_wb  <= false;
      write_wb <= false;
      
      case w is
         when Initialize =>
            if init.done then
               win <= Idle;
            end if;         
         
         when Idle =>
            if wb_read(si) then
               read_wb <= true;
            elsif wb_write(si) then
               write_wb <= true;
            end if;
            if ddr_done then
               win <= Ack;
            end if;
         
         when Ack =>
            so.ack <= '1';
            if si.stb = '0' then
               win <= Idle;
            end if;
         
      end case;  
   end process;

   wb_reg : process(si.clk)
   begin
      if rising_edge(si.clk) then
         if si.rst = '1' then w <= Initialize; else w <= win; end if;
      end if;
   end process;
   
   -----------------------------------------------------------------------------
   -- Main Controller                                                         --
   -----------------------------------------------------------------------------
   -- main : process(m, si, init)
   main : process(m, init, read_wb, write_wb, si.adr)
   begin

      min <= m;

      -- Refresh counter.
      if m.a = (AR_RATE-1) then
         min.rfsh <= true;
      else
         min.a <= m.a + 1;
      end if;

      wr_en  <= false;                 -- Write state machine enable.
      rd_en  <= false;                 -- Read state machine enable.
      --so.ack <= '0';
      ddr_done <= false;               -- Indicates a successful read or wirte.
      
      case m.s is

         -----------------------------------------------------------------------
         -- Initialization (see process initial).                             --
         -----------------------------------------------------------------------
         when Initialize =>
            min.ba  <= init.ba;
            min.adr <= init.adr;
            min.cmd <= init.cmd;
            if init.done then
               min.a    <= 0;
               min.rfsh <= false;
               min.s    <= Idle;
            end if;

         -----------------------------------------------------------------------
         -- Wait for memory operations or auto refresh.                       --
         -----------------------------------------------------------------------
         when Idle =>
            if m.rfsh then
               min.a    <= 0;
               min.rfsh <= false;
               min.s    <= AutoRefresh;
            -- elsif si.stb = '1' then
            elsif (read_wb or write_wb) then
               min.c <= 0;
               min.s <= Active;
            end if;

         -----------------------------------------------------------------------
         -- Auto Refresh.                                                     --
         -----------------------------------------------------------------------
         when AutoRefresh =>
            min.cmd <= CMD_AUTO_REFRESH;
            min.c   <= 0;
            min.s   <= AutoRefreshWait;

         -- AUTO REFRESH command period tRFC: 72ns
         -- Precharge command cycle + PRECHARGE command period tRP: 15ns
         when AutoRefreshWait =>
            min.cmd <= CMD_NOP;
            if m.c = 1 then
               min.c <= 0;
               min.s <= Idle;
            else
               min.c <= m.c + 1;
            end if;

         -----------------------------------------------------------------------
         -- Activate bank and row.                                            --
         -----------------------------------------------------------------------
         when Active =>
            min.cmd <= CMD_ACTIVE;
            min.ba  <= si.adr(25 downto 24);     -- Select bank.
            min.adr <= si.adr(23 downto 11);     -- Select row.
            min.s   <= ActiveWait;

         -- ACTIVE-to-READ or WRITE delay tRCD: 15ns
         when ActiveWait =>
            min.cmd <= CMD_NOP;
            min.ba  <= "00";                 -- Select bank.
            min.adr <= (others => '0');      -- Select row.
            -- if si.we = '0' then
               -- min.s <= Read;
            -- else
               -- min.s <= Write;
            -- end if;
            if read_wb then
               min.s <= Read;
            elsif write_wb then
               min.s <= Write;
            end if;

         -----------------------------------------------------------------------
         -- Read.                                                             --
         -----------------------------------------------------------------------
         -- At burst length 2 and sequential type, SD_A(0) is zero and the
         -- ordering of the burst access is 0-1.
         when Read =>
            min.cmd             <= CMD_READ;
            min.ba              <= si.adr(25 downto 24);
            min.adr(10)         <= '1';                  -- Auto precharge.
            min.adr(9 downto 1) <= si.adr(10 downto 2); 
            min.s               <= WaitRead;

         -- CL=2
         when WaitRead =>
            min.cmd             <= CMD_NOP;
            min.ba              <= "00"; 
            min.adr(10)         <= '0';
            min.adr(9 downto 1) <= (others => '0');
            rd_en               <= true;
            min.s               <= PrechargeWait;

         -----------------------------------------------------------------------
         -- Write.                                                            --
         -----------------------------------------------------------------------
         -- At burst length 2 and sequential type, SD_A(0) is fixed to zero and
         -- the ordering of the burst accesses is 0-1.
         when Write =>
            min.cmd             <= CMD_WRITE;
            min.ba              <= si.adr(25 downto 24);
            min.adr(10)         <= '1';                  -- Auto precharge.
            min.adr(9 downto 1) <= si.adr(10 downto 2);
            wr_en               <= true;
            min.s               <= RecoverWrite;

         -- Write recovery time tWR: 15 ns
         when RecoverWrite =>
            min.cmd             <= CMD_NOP;
            min.ba              <= "00"; 
            min.adr(10)         <= '0';             
            min.adr(9 downto 1) <= (others => '0');
            if m.c = 1 then
               min.c <= 0;
               min.s <= PrechargeWait;
            else
               min.c <= m.c + 1;
            end if;
           
         -----------------------------------------------------------------------
         -- Auto Precharge.                                                   --
         -----------------------------------------------------------------------
         -- Precharge command cycle + PRECHARGE command period tRP: 15ns
         when PrechargeWait =>
            if m.c = 1 then
               min.c <= 0;
               min.s <= Ack;
            else
               min.c <= m.c + 1;
            end if;

         -----------------------------------------------------------------------
         -- WB Ack                                                            --
         -----------------------------------------------------------------------
         -- NOTE: If the WB master needs too much time to pull strobe low, the 
         --       DDR lacks an autorefresh as this only happens in Idle state!
         when Ack =>
            -- so.ack <= '1';
            -- if si.stb = '0' then
               -- min.s <= Idle;
            -- end if;
            ddr_done <= true;
            min.s    <= Idle;
      end case;
   end process;

   SD_CMD <= m.cmd;
   SD_BA  <= m.ba;
   SD_A   <= m.adr;


   -----------------------------------------------------------------------------
   -- Read                                                                    --
   -----------------------------------------------------------------------------
   rds : process(clk0, rd_en)
      type s_t is (Idle, ReadPreamble, Read);
      variable s : s_t := Idle;
   begin
      if falling_edge(clk0) then
         if si.rst = '1' then
            s := Idle;
         else
            case s is
               when Idle =>
                  rd_en2 <= false;
                  if rd_en then s := ReadPreamble; end if;
               
               when ReadPreamble =>
                  rd_en2 <= false;
                  s      := Read;
               
               when Read =>
                  rd_en2 <= true;
                  s      := Idle;              
            end case;
         end if;
      end if;
   end process;
   
   process(clk0)
   begin
      if rising_edge(clk0) then
         if rd_en2 then rd(31 downto 16) <= SD_DQ; end if;
      end if;
   end process;

   process(clk0)
   begin
      if falling_edge(clk0) then
         if rd_en2 then rd(15 downto 0) <= SD_DQ; end if;
      end if;
   end process;

   so.dat <= rd;


   -----------------------------------------------------------------------------
   -- Write                                                                   --
   -----------------------------------------------------------------------------
   wrs : process(clk90, wr_en, si.dat, si.sel)
      type s_t is (Idle, WritePreamble, Write);
      variable s : s_t := Idle;
   begin
      if rising_edge(clk90) then
         if si.rst = '1' then
            s := Idle;
         else
            case s is
               when Idle =>
                  wr_en2 <= false;
                  if wr_en then s := WritePreamble; end if;
               
               when WritePreamble =>
                  wr_en2 <= false;
                  s      := Write;
               
               when Write =>
                  wr_en2 <= true;
                  s      := Idle;
            end case;
         end if;
      end if;
   end process;

   -- This part is bad design practice! Direct usage of clock signals is
   -- discouraged. The data mask pins can't be populated with ODDR2s. 
   -- DRC gives an error. Could be hacked manually probably.
   mask <= not si.sel;
   dm   <= mask(3 downto 2) when clk90 = '1' else mask(1 downto 0);
   -- dq   <= si.dat(31 downto 16) when clk90 = '1' else si.dat(15 downto 0);
   -- dqs  <= clk90 & clk90;

   DQS_GEN : for i in 1 downto 0 generate begin DQS : ODDR2
      generic map( DDR_ALIGNMENT => "NONE", INIT => '0', SRTYPE => "SYNC" )
      port map (
         Q  => dqs(i),
         C0 => not clk0, C1 => clk0,
         CE => '1',
         D0 => '1', D1 => '0',
         R  => '0', S  => '0'
      );
   end generate;

   -- DM_GEN : for i in 1 downto 0 generate begin DM : ODDR2
      -- generic map( DDR_ALIGNMENT => "NONE", INIT => '0', SRTYPE => "SYNC" )
      -- port map (
         -- Q  => dm(i),
         -- C0 => clk90, C1 => not clk90,
         -- CE => '1',
         -- D0 => mask(2 + i), D1 => mask(i),
         -- R  => '0', S  => '0'
      -- );
   -- end generate;

   DQ_GEN : for i in 15 downto 0 generate begin DQ : ODDR2
      generic map( DDR_ALIGNMENT => "NONE", INIT => '0', SRTYPE => "SYNC" )
      port map (
         Q  => dq(i),
         C0 => clk90, C1 => not clk90,
         CE => '1',
         D0 => si.dat(16 + i), D1 => si.dat(i),
         R  => '0', S  => '0'
      );
   end generate;

   SD_DQS <= dqs when wr_en2 else "ZZ";           -- Bi-directional data strobe.
   SD_DQ  <= dq when wr_en2 else (others => 'Z'); -- Bi-directional data bus.
   SD_DM  <= dm when wr_en2 else "11";

   
   -----------------------------------------------------------------------------
   -- Register                                                                --
   -----------------------------------------------------------------------------
   reg : process(clk0)
   begin
      if rising_edge(clk0) then
         if si.rst = '1' then m <= main_d; else m <= min; end if;
      end if;
   end process;
end rtl;