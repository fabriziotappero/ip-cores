-------------------------------------------------------------------------------
-- Title      : fft_top
-- Project    : Pipelined, DP RAM based FFT processor
-------------------------------------------------------------------------------
-- File       : fft_switch.vhd
-- Author     : Wojciech Zabolotny
-- Company    : 
-- Licanse    : BSD
-- Created    : 2014-01-18
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This file implements a data switching block connecting
--              consecutive stages of the FFT processor based on a dual
--              port RAM
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-01-18  1.0      wzab    Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.math_complex.all;
library work;
use work.icpx.all;
use work.fft_support_pkg.all;

entity fft_data_switch is

  generic (
    LOG2_FFT_LEN : integer := 4;
    STAGE        : integer := 2
    );
  port (
    in0    : in  icpx_number;
    in1    : in  icpx_number;
    out0   : out icpx_number;
    out1   : out icpx_number;
    enable : in  std_logic;
    rst_n  : in  std_logic;
    clk    : in  std_logic);

end fft_data_switch;

architecture fft_s_beh of fft_data_switch is

  constant LOG2_STAGE_N : integer := LOG2_FFT_LEN-STAGE-1;
  constant STAGE_N      : integer := 2 ** LOG2_STAGE_N;
  constant STAGE_N2     : integer := 2 ** (LOG2_STAGE_N-1);
  constant ADDR_WIDTH   : integer := LOG2_STAGE_N;
  constant STEP_LIMIT   : integer := 2**(LOG2_FFT_LEN-2-STAGE)-1;
  constant CYCLE_LIMIT  : integer := 2**STAGE-1;

  signal in0_del, in1_del      : icpx_number := icpx_zero;
  signal phase_del, phase_del2 : integer range 0 to 1;

  signal step, step_del : integer range 0 to STEP_LIMIT;
  signal phase          : integer range 0 to 1;
  signal cycle          : integer range 0 to CYCLE_LIMIT;


  component dp_ram_rbw_icpx
    generic (
      ADDR_WIDTH : integer);
    port (
      clk    : in  std_logic;
      we_a   : in  std_logic;
      addr_a : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      data_a : in  icpx_number;
      q_a    : out icpx_number;
      we_b   : in  std_logic;
      addr_b : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      data_b : in  icpx_number;
      q_b    : out icpx_number);
  end component;

  signal dpr_wa, dpr_wb                 : std_logic                               := '0';
  signal dpr_aa, dpr_ab                 : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal dpr_ia, dpr_ib, dpr_qa, dpr_qb : icpx_number;
  
begin  -- fft_top_beh

  dp_ram_1 : dp_ram_rbw_icpx
    generic map (
      ADDR_WIDTH => ADDR_WIDTH)
    port map (
      clk    => clk,
      we_a   => dpr_wa,
      addr_a => dpr_aa,
      data_a => dpr_ia,
      q_a    => dpr_qa,
      we_b   => dpr_wb,
      addr_b => dpr_ab,
      data_b => dpr_ib,
      q_b    => dpr_qb);

  dpr_aa <= std_logic_vector(to_unsigned(step, ADDR_WIDTH));
  -- It is important, that synthesis tool recognizes the addition below
  -- as a simple bit operation!
  dpr_ab <= std_logic_vector(to_unsigned(step+STAGE_N2, ADDR_WIDTH));

  -- Output values router.
  dr1 : process (dpr_qa, dpr_qb, in0_del, phase_del) is
  begin  -- process dr1
    if phase_del = 0 then
      out0 <= dpr_qb;
      out1 <= dpr_qa;
    else
      out1 <= in0_del;
      out0 <= dpr_qa;
    end if;
  end process dr1;

  -- purpose: main state machine
  -- type   : combinational
  st1 : process (in0, in1, phase) is
  begin  -- process st1
    dpr_wa <= '0';
    dpr_wb <= '0';
    dpr_ia <= icpx_zero;
    dpr_ib <= icpx_zero;
    if phase = 0 then
      dpr_ia <= in0;
      dpr_ib <= in1;
      dpr_wa <= '1';
      dpr_wb <= '1';
    else
      -- phase = 1
      dpr_ia <= in1;
      dpr_wa <= '1';
    end if;
  end process st1;

  -- We always access data on addresses:
  -- "step" and "step+N/2"

  -- Main process of our router
  -- This block always introduces latency of one cycle!
  process (clk, rst_n) is
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      in0_del    <= icpx_zero;
      in1_del    <= icpx_zero;
      phase_del  <= 0;
      phase_del2 <= 0;
      step_del   <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- prepare the delayed version of control signals
      in0_del    <= in0;
      in1_del    <= in1;
      phase_del  <= phase;
      phase_del2 <= phase_del;
      step_del   <= step;
    end if;
  end process;

  st2 : process (clk, rst_n) is
  begin  -- process st2
    if rst_n = '0' then                 -- asynchronous reset (active low)
      step  <= 0;
      phase <= 0;
      cycle <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if enable = '1' then
        if step = STEP_LIMIT then
          step <= 0;
          if phase = 1 then
            phase <= 0;
            if cycle = CYCLE_LIMIT then
              cycle <= 0;
            else
              cycle <= cycle+1;
            end if;
          else
            phase <= 1;
          end if;
        else
          step <= step+1;
        end if;
      end if;
    end if;
  end process st2;
  

end fft_s_beh;
