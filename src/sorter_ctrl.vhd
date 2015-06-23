-------------------------------------------------------------------------------
-- Title      : Sorting node controller for heap-sorter
-- Project    : heap-sorter
-------------------------------------------------------------------------------
-- File       : sorter_ctrl.vhd
-- Author     : Wojciech M. Zabolotny <wzab@ise.pw.edu.pl>
-- Company    : 
-- Created    : 2010-05-14
-- Last update: 2013-07-04
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 Wojciech M. Zabolotny
-- This file is published under the BSD license, so you can freely adapt
-- it for your own purposes.
-- Additionally this design has been described in my article:
--    Wojciech M. Zabolotny, "Dual port memory based Heapsort implementation
--    for FPGA", Proc. SPIE 8008, 80080E (2011); doi:10.1117/12.905281
-- I'd be glad if you cite this article when you publish something based
-- on my design.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-05-14  1.0      wzab    Created
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- The sorter controller is connected with three dual port memories.
-- The first dual port memory tm_... provides the "upstream data"
-- The second dual port memory lm_... provides the "left branch of downstream data"
-- The third dual port memory rm_... provides the "right branch of downstream data"
-- The controller is notified about availability of the new data by the
-- "update" signal.
-- However in this architecture we need to service two upstream memories!
-- That's because we want to save one cycle, and to be able to issue
--
-- Important feature of each controller is the ability to clear the memory
-- after reset.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
library work;
use work.sorter_pkg.all;
use work.sys_config.all;

entity sorter_ctrl is
  
  generic (
    NLEVELS   : integer;                -- number of levels (max number of
                                        -- address bits
    NADDRBITS : integer                 -- number of used address bits
    );

  port (
    -- Top memory connections
    tm_din       : in  T_DATA_REC;
    tm_dout      : out T_DATA_REC;
    tm_addr      : out std_logic_vector(NLEVELS-1 downto 0);
    tm_we        : out std_logic;
    -- Left memory connections
    lm_din       : in  T_DATA_REC;
    lm_dout      : out T_DATA_REC;
    lm_addr      : out std_logic_vector(NLEVELS-1 downto 0);
    lm_we        : out std_logic;
    -- Right memory connections
    rm_din       : in  T_DATA_REC;
    rm_dout      : out T_DATA_REC;
    rm_addr      : out std_logic_vector(NLEVELS-1 downto 0);
    rm_we        : out std_logic;
    -- Upper level controller connections
    up_in        : in  std_logic;
    up_in_val    : in  T_DATA_REC;
    up_in_addr   : in  std_logic_vector(NLEVELS-1 downto 0);
    -- Upper level update notifier
    up_out       : out std_logic;
    up_out_val   : out T_DATA_REC;
    up_out_addr  : out std_logic_vector(NLEVELS-1 downto 0);
    -- Lower level controller connections
    low_out      : out std_logic;
    low_out_val  : out T_DATA_REC;
    low_out_addr : out std_logic_vector(NLEVELS-1 downto 0);
    low_in       : in  std_logic;
    low_in_val   : in  T_DATA_REC;
    low_in_addr  : in  std_logic_vector(NLEVELS-1 downto 0);
    -- Lower level update notifier
    -- System connections
    clk          : in  std_logic;
    clk_en       : in  std_logic;
    ready_in     : in  std_logic;
    ready_out    : out std_logic;       -- signals, when memory is cleared
                                        -- after reset
    rst_n        : in  std_logic);
end sorter_ctrl;

architecture sorter_ctrl_arch1 of sorter_ctrl is

  type T_CTRL_STATE is (CTRL_RESET, CTRL_CLEAR, CTRL_IDLE, CTRL_S1, CTRL_S0);
  signal ctrl_state, ctrl_state_next    : T_CTRL_STATE := CTRL_IDLE;
  signal addr, addr_i                   : std_logic_vector(NLEVELS-1 downto 0);
  signal s_low_in_addr, s_low_in_addr_i : std_logic_vector(NLEVELS-1 downto 0);
  signal s_up_in_addr, s_up_in_addr_i   : std_logic_vector(NLEVELS-1 downto 0);
  signal s_ready_out, s_ready_out_i     : std_logic;
  signal s_low_in, s_low_in_i           : std_logic;
  signal s_addr_out                     : std_logic_vector(NLEVELS-1 downto 0);
  signal s_tm_dout                      : T_DATA_REC;
  signal s_up_in_val_i, s_up_in_val     : T_DATA_REC   := DATA_REC_INIT_DATA;
  signal s_low_in_val_i, s_low_in_val   : T_DATA_REC   := DATA_REC_INIT_DATA;


  constant ADDR_MAX : std_logic_vector(NLEVELS-1 downto 0) := std_logic_vector(to_unsigned(2**NADDRBITS-1, NLEVELS));

begin

  tm_dout <= s_tm_dout;
-- We have the two-process state machine.
  p1 : process (addr, ctrl_state, lm_din, low_in, low_in_addr, low_in_val,
                ready_in, rm_din, s_addr_out, s_low_in, s_low_in_addr,
                s_low_in_val, s_ready_out, s_up_in_val, up_in, up_in_addr,
                up_in_val)
    variable rline : line;
    variable l_val : T_DATA_REC;
    variable r_val : T_DATA_REC;
    
  begin  -- process p1
    -- defaults
    ctrl_state_next <= ctrl_state;
    tm_we           <= '0';
    rm_we           <= '0';
    lm_we           <= '0';
    lm_addr         <= (others => '0');
    rm_addr         <= (others => '0');
    tm_addr         <= (others => '0');
    s_ready_out_i   <= s_ready_out;
    addr_i          <= addr;
    up_out_val      <= DATA_REC_INIT_DATA;  -- to avoid latches
    low_out_val     <= DATA_REC_INIT_DATA;  -- to avoid latches
    s_low_in_addr_i <= s_low_in_addr;
    s_low_in_i      <= low_in;
    low_out         <= '0';
    up_out          <= '0';
    up_out_addr     <= (others => '0');
    s_up_in_val_i   <= s_up_in_val;
    s_low_in_val_i  <= s_low_in_val;
    lm_dout         <= DATA_REC_INIT_DATA;
    rm_dout         <= DATA_REC_INIT_DATA;
    s_tm_dout       <= DATA_REC_INIT_DATA;
    s_addr_out      <= (others => '0');
    case ctrl_state is
      when CTRL_RESET =>
        addr_i          <= (others => '0');
        s_ready_out_i   <= '0';
        ctrl_state_next <= CTRL_CLEAR;
      when CTRL_CLEAR =>
        lm_addr <= addr;
        rm_addr <= addr;
        lm_dout <= DATA_REC_INIT_DATA;
        rm_dout <= DATA_REC_INIT_DATA;
        lm_we   <= '1';
        rm_we   <= '1';
        if addr = ADDR_MAX then
          if ready_in = '1' then
            s_ready_out_i   <= '1';
            ctrl_state_next <= CTRL_IDLE;
          end if;
        else
          addr_i <= std_logic_vector(unsigned(addr)+1);
        end if;
      when CTRL_IDLE =>
        -- We read "down" memories ("upper" value is provided by the ``bypass channel'')
        if up_in = '1' then
          ctrl_state_next <= CTRL_S1;
          tm_addr         <= up_in_addr;
          lm_addr         <= up_in_addr;
          rm_addr         <= up_in_addr;
          addr_i          <= up_in_addr;
          s_up_in_val_i   <= up_in_val;
          if low_in = '1' then
            s_low_in_val_i  <= low_in_val;
            s_low_in_addr_i <= low_in_addr;
          end if;
        end if;
      when CTRL_S1 =>
        -- In this cycle we can compare data
        -- Debug output!
        if SORT_DEBUG then
          write(rline, string'("CMP "));
          write(rline, NADDRBITS);
          write(rline, string'(" U:"));
          wrstlv(rline, tdrec2stlv(s_up_in_val));
        end if;
        l_val := lm_din;
        r_val := rm_din;
        -- Check, if we need to take value from lower ``bypass channel''
        if s_low_in = '1' then
          if SORT_DEBUG then
            write(rline, string'(" x! "));
          end if;
          if (addr(NADDRBITS-1 downto 0) = s_low_in_addr(NADDRBITS-1 downto 0)) then
            -- We are reading a value which was just updated, so we need to get it
            -- from ``bypass channel'' instead of memory
            if SORT_DEBUG then
              write(rline, string'(" y! "));
            end if;
            if s_low_in_addr(NADDRBITS) = '1' then
              l_val := s_low_in_val;
            else
              r_val := s_low_in_val;
            end if;
          end if;
        end if;
        if SORT_DEBUG then
          write(rline, string'(" L:"));
          wrstlv(rline, tdrec2stlv(l_val));
          write(rline, string'(" R:"));
          wrstlv(rline, tdrec2stlv(r_val));
          write(rline, string'(" A:"));
        end if;
        if sort_cmp_lt(l_val, s_up_in_val) and sort_cmp_lt(l_val, r_val) then
          -- The L-ram value is the smallest
          -- Output the value from the L-ram and put the new value into the L-ram
          s_tm_dout <= l_val;
          tm_addr   <= addr;
          tm_we     <= '1';

          up_out_val  <= l_val;
          up_out      <= '1';
          up_out_addr <= addr;

          lm_addr <= addr;
          lm_dout <= s_up_in_val;
          lm_we   <= '1';

          low_out               <= '1';
          low_out_val           <= s_up_in_val;
          s_addr_out(NADDRBITS) <= '1';

          if NADDRBITS > 0 then
            s_addr_out(NADDRBITS-1 downto 0) <= addr(NADDRBITS-1 downto 0);
          end if;
          wrstlv(rline, s_addr_out);
          ctrl_state_next <= CTRL_IDLE;
          if SORT_DEBUG then
            write(rline, string'(" T<->L"));
          end if;
        elsif sort_cmp_lt(r_val, s_up_in_val) then
          -- The R-ram value is the smallest
          -- Output the value from the R-ram and put the new value into the R-ram
          s_tm_dout <= r_val;
          tm_addr   <= addr;
          tm_we     <= '1';

          up_out_val  <= r_val;
          up_out      <= '1';
          up_out_addr <= addr;

          rm_addr <= addr;
          rm_dout <= s_up_in_val;
          rm_we   <= '1';

          low_out     <= '1';
          low_out_val <= s_up_in_val;

          s_addr_out(NADDRBITS) <= '0';
          if NADDRBITS > 0 then
            s_addr_out(NADDRBITS-1 downto 0) <= addr(NADDRBITS-1 downto 0);
          end if;
          ctrl_state_next <= CTRL_IDLE;
          if SORT_DEBUG then
            wrstlv(rline, s_addr_out);
            write(rline, string'(" T<->R"));
          end if;
        else
          -- The new value is the smallest
          -- Nothing to do, no update downstream
          s_tm_dout <= s_up_in_val;
          tm_we     <= '1';
          tm_addr   <= addr;

          up_out_val  <= s_up_in_val;
          up_out      <= '1';
          up_out_addr <= addr;

          ctrl_state_next <= CTRL_IDLE;
          wrstlv(rline, up_in_addr);
          if SORT_DEBUG then
            write(rline, string'(" T===T"));
          end if;
        end if;
        if SORT_DEBUG then
          writeline(reports, rline);
        end if;
      when others => null;
    end case;
  end process p1;

  p2 : process (clk, rst_n) is
  begin  -- process p2
    if rst_n = '0' then                 -- asynchronous reset (active low)
      ctrl_state    <= CTRL_RESET;
      s_ready_out   <= '0';
      addr          <= (others => '0');
      s_low_in_addr <= (others => '0');
      s_low_in      <= '0';
      s_low_in_val  <= DATA_REC_INIT_DATA;
      s_up_in_val   <= DATA_REC_INIT_DATA;
      --update_out  <= '0';
      --addr_out    <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      s_ready_out   <= s_ready_out_i;
      ctrl_state    <= ctrl_state_next;
      addr          <= addr_i;
      s_low_in_addr <= s_low_in_addr_i;
      s_low_in_val  <= s_low_in_val_i;
      s_up_in_val   <= s_up_in_val_i;
      s_low_in      <= s_low_in_i;
    end if;
  end process p2;
  ready_out    <= s_ready_out;
  low_out_addr <= s_addr_out;
end sorter_ctrl_arch1;
