----------------------------------------------------------------------
----                                                              ----
---- Ultimate CRC.                                                ----
----                                                              ----
---- This file is part of the ultimate CRC projectt               ----
---- http://www.opencores.org/cores/ultimate_crc/                 ----
----                                                              ----
---- Description                                                  ----
---- Test bench for ultimate crc.                                 ----
----                                                              ----
----                                                              ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Geir Drange, gedra@opencores.org                           ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2005 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU General          ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.0 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU General Public License for more details.----
----                                                              ----
---- You should have received a copy of the GNU General           ----
---- Public License along with this source; if not, download it   ----
---- from http://www.gnu.org/licenses/gpl.txt                     ----
----                                                              ----
----------------------------------------------------------------------
--
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
-- Revision 1.1  2005/05/09 16:07:45  gedra
-- test bench.
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use work.ucrc_pkg.all;
use work.wb_tb_pack.all;

entity tb_crc is

end tb_crc;

architecture behav of tb_crc is

   -- Polynomial under testing
   constant POLYNOMIAL : std_logic_vector(15 downto 0) :=
      "0001000000100001";               -- x^16 + x^12 + x^5 + 1;
   -- Initialization value
   constant INIT_VALUE   : std_logic_vector(15 downto 0) := "1111111111111111";
   -- Data width for the parallel implementation
   constant DATA_WIDTH   : integer                       := 8;
   -- Number of bits 
   constant CODE_LENGTH  : integer                       := 64 / DATA_WIDTH;
   constant EXPECTED_CRC : std_logic_vector(POLYNOMIAL'length - 1 downto 0) :=
      "0110100100110101";  -- this must be updated if any parameter is changed!
   signal clk, rst, d_o, d_v, flush, clken, pd_in : std_logic;
   signal lsfr_reg                                : std_logic_vector(31 downto 0);
   signal cnt                                     : integer range 0 to CODE_LENGTH*DATA_WIDTH+10;
   signal zero, match_s, match_p, chk_in, clken3  : std_logic;
   signal data, par_in                            : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal crc_s, crc_sc, crc_p                    : std_logic_vector(POLYNOMIAL'length - 1 downto 0);
   signal pcnt                                    : integer range 0 to DATA_WIDTH - 1;
   signal one, check, par_clken, clken2, match_p2 : std_logic;
   signal crc_p2                                  : std_logic_vector(31 downto 0);
   signal data3                                   : std_logic_vector(159 downto 0);
   
begin

   zero <= '0';
   one  <= '1';

   ----------------------------------------------------------------------------
   -- LFSR generates random bits as input to the CRC generators
   ----------------------------------------------------------------------------
   LSFR : process (clk, rst)
   begin
      if rst = '1' then
         lsfr_reg <= (others => '1');
      elsif rising_edge(clk) then
         lsfr_reg(0) <= lsfr_reg(31) xor lsfr_reg(6) xor lsfr_reg(4)
                        xor lsfr_reg(2) xor lsfr_reg(1) xor lsfr_reg(0);
         lsfr_reg(31 downto 1) <= lsfr_reg(30 downto 0);
      end if;
   end process;

   ----------------------------------------------------------------------------
   -- Serial to parallel data register, used to feed the parallel implementation
   ----------------------------------------------------------------------------
   pd_in                  <= chk_in;    -- Data plus CRC 
   par_in(DATA_WIDTH - 1) <= pd_in;
   S2P : process (clk, rst)
   begin
      if rst = '1' then
         par_in(DATA_WIDTH - 2 downto 0) <= (others => '0');
         par_clken                       <= '0';
         pcnt                            <= 0;
      elsif rising_edge(clk) then
         if clken = '1' then
            par_in(DATA_WIDTH - 2)          <= pd_in;
            par_in(DATA_WIDTH - 3 downto 0) <= par_in(DATA_WIDTH - 2 downto 1);
            if pcnt < DATA_WIDTH - 1 then
               pcnt <= pcnt + 1;
            else
               pcnt <= 0;
            end if;
            if pcnt = DATA_WIDTH - 2 then
               par_clken <= '1';
            else
               par_clken <= '0';
            end if;
         else
            par_clken <= '0';
         end if;
      end if;
   end process;

   ----------------------------------------------------------------------------
   -- Bit counter and CRC control. Generates clken and flush signals for the
   -- serial generator.
   ---------------------------------------------------------------------------- 
   BCNT : process (clk, rst)
   begin
      if rst = '1' then
         cnt   <= 0;
         flush <= '0';
         clken <= '0';
      elsif rising_edge(clk) then
         if cnt < CODE_LENGTH*DATA_WIDTH+10 then
            cnt <= cnt + 1;
         end if;
         if cnt >= DATA_WIDTH and cnt < CODE_LENGTH*DATA_WIDTH then
            clken <= '1';
         else
            clken <= '0';
         end if;
         if (cnt >= CODE_LENGTH*DATA_WIDTH - POLYNOMIAL'length) and
            (cnt < CODE_LENGTH*DATA_WIDTH) then
            flush <= '1';
         else
            flush <= '0';
         end if;
      end if;
   end process;

   ----------------------------------------------------------------------------
   -- Serial CRC generator. CRC is flushed out after the data block
   ---------------------------------------------------------------------------- 
   SGEN : ucrc_ser
      generic map (
         POLYNOMIAL => POLYNOMIAL,
         INIT_VALUE => INIT_VALUE,
         SYNC_RESET => 1)
      port map (
         clk_i   => clk,
         rst_i   => rst,
         clken_i => clken,
         data_i  => lsfr_reg(0),
         flush_i => flush,
         match_o => open,
         crc_o   => crc_s);

   ----------------------------------------------------------------------------
   -- Serial CRC checker. Takes input from the serial generator, incl. CRC
   ----------------------------------------------------------------------------
   chk_in <= lsfr_reg(0) when flush = '0' else crc_s(POLYNOMIAL'length - 1);
   SCHK : ucrc_ser
      generic map (
         POLYNOMIAL => POLYNOMIAL,
         INIT_VALUE => INIT_VALUE,
         SYNC_RESET => 1)
      port map (
         clk_i   => clk,
         rst_i   => rst,
         clken_i => clken,
         data_i  => chk_in,
         flush_i => zero,
         match_o => match_s,
         crc_o   => crc_sc);

   ----------------------------------------------------------------------------
   -- Parallel CRC generator/checker. Takes input from the serial generator,
   -- including the CRC
   ----------------------------------------------------------------------------
   PGEN : ucrc_par
      generic map (
         POLYNOMIAL => POLYNOMIAL,
         INIT_VALUE => INIT_VALUE,
         DATA_WIDTH => DATA_WIDTH,
         SYNC_RESET => 1)
      port map (
         clk_i   => clk,
         rst_i   => rst,
         clken_i => par_clken,
         data_i  => par_in,
         match_o => match_p,
         crc_o   => crc_p);

   ----------------------------------------------------------------------------
   -- 128bit wide CRC generator
   ----------------------------------------------------------------------------
   iucrc_par : ucrc_par
      generic map (
         POLYNOMIAL => x"00018bb7",
         INIT_VALUE => x"00000000",
         DATA_WIDTH => 128,
         SYNC_RESET => 1)
      port map (
         clk_i   => clk,
         rst_i   => rst,
         clken_i => clken2,
         data_i  => (others => '1'),
         match_o => open,
         crc_o   => crc_p2);

   ----------------------------------------------------------------------------
   -- 160bit wide CRC checker
   ----------------------------------------------------------------------------
   iucrc_par2 : ucrc_par
      generic map (
         POLYNOMIAL => x"00018bb7",
         INIT_VALUE => x"00000000",
         DATA_WIDTH => 160,
         SYNC_RESET => 1)
      port map (
         clk_i   => clk,
         rst_i   => rst,
         clken_i => clken3,
         data_i  => data3,
         match_o => match_p2,
         crc_o   => open);

   data3(127 downto 0) <= (others => '1');
   lCpy : for i in 0 to 31 generate     -- CRC must be MSB first!
      data3(128 + i) <= crc_p2(31 - i);
   end generate lCpy;

   ----------------------------------------------------------------------------
   -- Main test process
   ----------------------------------------------------------------------------
   MAIN : process
   begin
      clken2 <= '0';
      clken3 <= '0';
      message("Simulation starts with a reset.");
      rst    <= '1';
      wait for 18 ns;
      rst    <= '0';
      wait_for_event("Wait for flushing of serial CRC generator", 1 ms, flush);
      wait for 2 ns;
      vector_check("CRC of serial generator", EXPECTED_CRC, crc_s);
      vector_check("CRC of parallel generator", EXPECTED_CRC, crc_p);
      wait_for_event("Wait for flush to finish", 500 ns, flush);
      wait for 2 ns;
      signal_check("Serial CRC match signal", '1', match_s);
      signal_check("Parallel CRC match signal", '1', match_p);
      message("Check 128bit crc:");
      wait until rising_edge(clk);
      clken2 <= '1';
      wait until rising_edge(clk);
      clken2 <= '0';
      wait until rising_edge(clk);
      clken3 <= '1';
      wait until rising_edge(clk);
      clken3 <= '0';
      signal_check("Parallel 128bit CRC check", '1', match_p2);
      sim_report("");
      wait for 100 ns;
      report "End of simulation! (ignore this failure)"
         severity failure;
      wait;
   end process;

   ----------------------------------------------------------------------------
   -- Clock
   ----------------------------------------------------------------------------
   CLOCK : process
   begin
      clk <= '0';
      wait for 5 ns;
      clk <= '1';
      wait for 5 ns;
   end process;
   
end behav;

