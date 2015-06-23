-----------------------------------------------------------------------------
--	Copyright (C) 2009 José Rodríguez-Navarro
--
-- This code is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
--  Identify single/double ones/zeros based on length 
--  of time data_i is high/low
--
--  Revision  Date        Author                Comment
--  --------  ----------  --------------------  ----------------
--  1.0       20/02/09    J. Rodriguez-Navarro  Initial revision
--  1.1       21/06/09    M. Thiagarajan        Modified with FSM
--  1.2       25/06/09    M. Thiagarajan        Modified Nxt State Logic
--                                              to avoid inferring latch
--  Future revisions tracked in Subversion at OpenCores.org
--  under the manchesterwireless project
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.globals.all;

--------------------------------------------------------------------------------

entity singleDouble is
  port (
    clk_i   :  in  std_logic;
    ce_i    :  in  std_logic;    
    rst_i   :  in  std_logic;
    data_i  :  in  std_logic;
    q_o     :  out std_logic_vector(3 downto 0);
    ready_o :  out std_logic
  );
end;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

architecture behavioral of singleDouble is

  signal single_one:      std_logic;
  signal double_one:      std_logic;
  signal single_zero:     std_logic;
  signal double_zero:     std_logic;
  signal count_ones    : integer range 0 to INTERVAL_MAX_DOUBLE;
  signal count_zeros   : integer range 0 to INTERVAL_MAX_DOUBLE;

  signal data_i_d  :         std_logic;
  signal data_i_d2 :         std_logic;

  signal    ct_state, nxt_state  : bit_vector(2 downto 0);
  signal    ce_i_RT, data_i_RT, data_i_FT : std_logic;
  signal    ce_i_d, ce_i_d2               : std_logic;
  signal    count_zeros_en, count_ones_en : std_logic;
  constant  IDLE: bit_vector(2 downto 0) := "001";
  constant  CNT0: bit_vector(2 downto 0) := "010";
  constant  CNT1: bit_vector(2 downto 0) := "100";

  begin
    process (clk_i,rst_i)
    begin
      if (rst_i = '1') then
        ce_i_d  <= '0';
        ce_i_d2 <= '0';
      elsif (clk_i'event and clk_i = '1') then
        ce_i_d    <= ce_i;
        ce_i_d2  <= ce_i_d;
      end if;
    end process;
    ce_i_RT   <= ce_i_d and (not(ce_i_d2));  --CE rising edge

    process (clk_i,rst_i)
    begin
      if (rst_i = '1') then
        data_i_d  <= '0';
        data_i_d2 <= '0';
      elsif (clk_i'event and clk_i = '1') then
        data_i_d  <= data_i;
        data_i_d2  <= data_i_d;
      end if;
    end process;
    data_i_RT   <= data_i_d and (not(data_i_d2));  --Data rising edge
    data_i_FT   <= (not data_i_d) and data_i_d2;  --Data falling edge

    ready_o     <= ((data_i_RT or data_i_FT) and ce_i) or ce_i_RT;

    process (clk_i,rst_i)  --State register
    begin
      if (rst_i = '1') then
        ct_state <= IDLE;
      elsif (clk_i'event and clk_i = '1') then
        ct_state <= nxt_state;
      end if;
    end process;

    process (ct_state,ce_i_RT,data_i,ce_i,data_i_FT,data_i_RT)  --Next State logic
    begin
      case ct_state is
          when IDLE   =>
            if ((ce_i_RT = '1') and (data_i = '0'))then
              nxt_State <= CNT0;
            elsif ((ce_i_RT = '1') and (data_i = '1')) then
              nxt_state <= CNT1;
            else
              nxt_state <= IDLE;
            end if;

          when CNT0   =>
            if (ce_i = '0') then
              nxt_state <= IDLE;
            elsif (data_i_RT = '1') then
              nxt_state <= CNT1;
            else
              nxt_state <= CNT0;
            end if;

          when CNT1   =>
            if (ce_i = '0') then
              nxt_state <= IDLE;
            elsif (data_i_FT = '1') then
              nxt_state <= CNT0;
            else
              nxt_state <= CNT1;
            end if;

          when others   =>
            nxt_state <=  IDLE;
      end case;
    end process;

    process (ct_state)  --State output logic
    begin
      case ct_state is
        when IDLE   =>
          count_ones_en    <= '0';
          count_zeros_en   <= '0';

        when CNT0   =>
          count_ones_en    <= '0';
          count_zeros_en   <= '1';

        when CNT1   =>
          count_ones_en    <= '1';
          count_zeros_en   <= '0';
        --when others    => null;
        when others    => 
          count_ones_en    <= '0';
          count_zeros_en   <= '0';
    end case;
  end process;

  process (clk_i,rst_i)  --counters
  begin
    if (rst_i = '1') then
      count_ones    <=  0;
      count_zeros   <=  0;
    elsif (clk_i'event and clk_i = '1') then
      if (count_zeros_en = '1') then
        count_zeros   <= count_zeros + 1;
        count_ones    <= 0;
      elsif (count_ones_en = '1') then
        count_ones   <= count_ones + 1;
        count_zeros    <= 0;
      end if;
    end if;
  end process;

  process(count_ones)
  begin
    if (count_ones >= INTERVAL_MIN_DOUBLE) and (count_ones <= INTERVAL_MAX_DOUBLE) then
      double_one <= '1';
    else
      double_one <= '0';
    end if;
    if (count_ones >= INTERVAL_MIN_SINGLE) and (count_ones <= INTERVAL_MAX_SINGLE) then
      single_one <= '1';
    else
      single_one <= '0';
    end if;
  end process;

  process(count_zeros)
  begin
    if (count_zeros >= INTERVAL_MIN_DOUBLE) and (count_zeros <= INTERVAL_MAX_DOUBLE) then
      double_zero <= '1';
    else
      double_zero <= '0';
    end if;
    if (count_zeros >= INTERVAL_MIN_SINGLE) and (count_zeros <= INTERVAL_MAX_SINGLE) then
      single_zero <= '1';
    else
      single_zero <= '0';
    end if;
  end process;

  process (rst_i,data_i_RT,data_i_FT,double_zero,single_zero,double_one,single_one)
  begin
    if (rst_i = '1') then
      q_o   <= "0000";
    else
      q_o   <= double_zero & single_zero & double_one & single_one;
    end if;
  end process;
end;
