-------------------------------------------------------------------------------
-- Title      : fft_engine
-- Project    : DP RAM based FFT processor
-------------------------------------------------------------------------------
-- File       : fft_engine.vhd
-- Author     : Wojciech Zabolotny wzab01@gmail.com
-- Company    : 
-- License    : BSD
-- Created    : 2014-01-18
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This file implements a FFT processor based on a dual port RAM
--              This implementation uses a single "butterfly calculation unit"
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

entity fft_engine is
  generic (
    LOG2_FFT_LEN : integer := 8 );
  port (
    din       : in  icpx_number;
    addr_in   : in  integer;
    wr_in     : in  std_logic;
    dout      : out icpx_number;
    addr_out  : in  integer;
    ready     : out std_logic;
    busy      : out std_logic;
    start     : in  std_logic;
    rst_n     : in  std_logic;
    syn_rst_n : in  std_logic;
    clk       : in  std_logic);

end fft_engine;

architecture fft_engine_beh of fft_engine is

  constant ADDR_WIDTH    : integer := LOG2_FFT_LEN;
  constant BTFLY_LATENCY : integer := 0;
  constant FFT_LEN       : integer := 2 ** LOG2_FFT_LEN;

  type T_FFT_STATE is (FFT_STATE_RESET, FFT_STATE_READ, FFT_STATE_PROCESS);

  -- The type below defines the registers used by the state machine
  type T_FFT_REGS is record
    state             : T_FFT_STATE;
    stage             : integer;
    step_in           : integer;
    step_out          : integer;
    stage_out_started : std_logic;
    mem_switch        : std_logic;
    ready             : std_logic;
    busy              : std_logic;
    tf                : icpx_number;
    latency_cnt       : integer;
  end record;

  -- The initial value, set during the reset
  constant fft_regs_init : T_FFT_REGS := (
    state             => FFT_STATE_RESET,
    stage             => 0,
    step_in           => 0,
    step_out          => 0,
    stage_out_started => '0',
    mem_switch        => '0',
    ready             => '0',
    busy              => '0',
    tf                => icpx_zero,
    latency_cnt       => 0
    );

  signal r_o, r_i : T_FFT_REGS := fft_regs_init;

  -- The type below defines the combinatorial outputs of the state machine
  type T_FFT_COMB is record
    dpr0_aa : integer;
    dpr0_ab : integer;
    dpr0_ia : icpx_number;
    dpr0_ib : icpx_number;
    dpr0_wa : std_logic;
    dpr0_wb : std_logic;
    dpr1_aa : integer;
    dpr1_ab : integer;
    dpr1_ia : icpx_number;
    dpr1_ib : icpx_number;
    dpr1_wa : std_logic;
    dpr1_wb : std_logic;
    dout    : icpx_number;
  end record;

  -- The default value. Set at the begining of process to avoid
  -- creation of latches
  constant fft_comb_default : T_FFT_COMB := (
    dpr0_aa => 0,
    dpr0_ab => 0,
    dpr0_ia => icpx_zero,
    dpr0_ib => icpx_zero,
    dpr0_wa => '0',
    dpr0_wb => '0',
    dpr1_aa => 0,
    dpr1_ab => 0,
    dpr1_ia => icpx_zero,
    dpr1_ib => icpx_zero,
    dpr1_wa => '0',
    dpr1_wb => '0',
    dout    => icpx_zero
    );

  signal c : T_FFT_COMB := fft_comb_default;

  -- Function used to convert integer indices to std_logic_vector
  -- used to address the memory
  function i2a (
    constant ia : integer)
    return std_logic_vector is
    variable res : std_logic_vector(ADDR_WIDTH-1 downto 0);
  begin  -- i2a
    res := std_logic_vector(to_unsigned(ia, ADDR_WIDTH));
    return res;
  end i2a;

  -- The function below calculates the address of the argument
  -- used by the particular butterly module in the particular
  -- stage of the algorithm
  function n2k (
    constant stage : integer;           -- stage number
    constant step  : integer;           -- butterfly block number
    constant nin   : integer            -- input number (0 or 1)
    )
    return integer is
    variable k_uns : unsigned(LOG2_FFT_LEN-1 downto 0);
    variable k_int : integer;
  begin
    k_uns := to_unsigned(step, LOG2_FFT_LEN);
    if stage > 0 then
      k_uns(LOG2_FFT_LEN-1 downto LOG2_FFT_LEN-stage) :=
        k_uns(LOG2_FFT_LEN-2 downto LOG2_FFT_LEN-stage-1);
    end if;
    if nin = 0 then
      k_uns(LOG2_FFT_LEN-stage-1) := '0';
    else
      k_uns(LOG2_FFT_LEN-stage-1) := '1';
    end if;
    k_int := to_integer(k_uns);
    return k_int;
  end n2k;

  -- Type used to store twiddle factors
  type T_TF_TABLE is array (0 to FFT_LEN/2-1) of icpx_number;

  -- Function initializing the twiddle factor memory
  -- (during synthesis it is evaluated only during compilation!!!)
  function tf_table_init
    return t_tf_table is
    variable x   : real;
    variable res : t_tf_table;
  begin  -- i1st
    for i in 0 to FFT_LEN/2-1 loop
      x      := -real(i)*MATH_PI*2.0/(2.0 ** LOG2_FFT_LEN);
      res(i) := cplx2icpx(complex'(cos(x), sin(x)));
    end loop;  -- i
    return res;
  end tf_table_init;

  -- Twiddle factors ROM memory
  constant tf_table : T_TF_TABLE := tf_table_init;

  -- Function returning the appropriate twiddle factor
  function tf_select (
    constant step_in : integer;         -- number of the butterfly block
    constant stage   : integer          -- stage of the algorithm
    )
    return integer is
    variable res : integer;
    variable adr : unsigned(LOG2_FFT_LEN-2 downto 0);
  begin  -- tf_select
    adr := to_unsigned(step_in, LOG2_FFT_LEN-1);
    adr := shift_left(adr, stage);
    res := to_integer(adr);
    return res;
  end tf_select;


  component dp_ram_icpx
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

  component butterfly
    port (
      din0  : in  icpx_number;
      din1  : in  icpx_number;
      tf    : in  icpx_number;
      dout0 : out icpx_number;
      dout1 : out icpx_number);
  end component;

  -- signals for inputs and outputs of the dpram
  type icpx_vector is array (0 to LOG2_FFT_LEN) of icpx_number;
  signal dpr0_oa : icpx_number;
  signal dpr0_ob : icpx_number;
  signal dpr1_oa : icpx_number;
  signal dpr1_ob : icpx_number;
  signal din0    : icpx_number;
  signal din1    : icpx_number;
  signal dout0   : icpx_number;
  signal dout1   : icpx_number;

  signal dpr0_aa : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal dpr0_ab : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal dpr1_aa : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal dpr1_ab : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  
begin  -- fft_engine_beh

  dpr0_aa <= i2a(c.dpr0_aa);
  dpr0_ab <= i2a(c.dpr0_ab);
  dpr1_aa <= i2a(c.dpr1_aa);
  dpr1_ab <= i2a(c.dpr1_ab);

  -- To allow fluent operation even in case of butterfly blocks
  -- with non-zero latency, we use two DPRAMs

  dp_ram_0 : dp_ram_icpx
    generic map (
      ADDR_WIDTH => ADDR_WIDTH)
    port map (
      clk    => clk,
      we_a   => c.dpr0_wa,
      addr_a => dpr0_aa,
      data_a => c.dpr0_ia,
      q_a    => dpr0_oa,
      we_b   => c.dpr0_wb,
      addr_b => dpr0_ab,
      data_b => c.dpr0_ib,
      q_b    => dpr0_ob);

  dp_ram_1 : dp_ram_icpx
    generic map (
      ADDR_WIDTH => ADDR_WIDTH)
    port map (
      clk    => clk,
      we_a   => c.dpr1_wa,
      addr_a => dpr1_aa,
      data_a => c.dpr1_ia,
      q_a    => dpr1_oa,
      we_b   => c.dpr1_wb,
      addr_b => dpr1_ab,
      data_b => c.dpr1_ib,
      q_b    => dpr1_ob);

  -- The "butterfly block"
  butterfly_1 : butterfly
    port map (
      din0  => din0,
      din1  => din1,
      tf    => r_o.tf,
      dout0 => dout0,
      dout1 => dout1);

  dout  <= c.dout;
  ready <= r_o.ready;
  busy  <= r_o.busy;


  -- Process routing the input data from the appropriate memory
  process (dpr0_oa, dpr0_ob, dpr1_oa, dpr1_ob, r_o)
  begin  -- process
    if r_o.mem_switch = '0' then
      din0 <= dpr0_oa;
      din1 <= dpr0_ob;
    else
      din0 <= dpr1_oa;
      din1 <= dpr1_ob;
    end if;
  end process;

  -- Combinatorial process of the main state machine
  p1 : process (addr_in, addr_out, din, dout0, dout1, dpr0_ob, dpr1_ob, r_o,
                start, wr_in)
  begin  -- process
    c   <= fft_comb_default;
    r_i <= r_o;
    -- We work, depending on the mode
    case r_o.state is
      when FFT_STATE_RESET =>
        r_i.state <= FFT_STATE_READ;
        r_i.ready <= '1';               -- Signal, the we have left reset
      when FFT_STATE_READ =>
        -- Route input signals to allow writing and reading of data
        -- Writing of new data
        -- Routing of data depends on the state of the flip-flop
        if r_o.mem_switch = '0' then
          -- Write the new data to the memory 0
          c.dpr0_aa <= addr_in;
          c.dpr0_ia <= din;
          c.dpr0_wa <= wr_in;
          -- Read the data from the memory 1
          c.dpr1_ab <= addr_out;
          c.dout    <= dpr1_ob;
        else
          -- Write the new data to the memory 1
          c.dpr1_aa <= addr_in;
          c.dpr1_ia <= din;
          c.dpr1_wa <= wr_in;
          -- Read the data from the memory 0
          c.dpr0_ab <= addr_out;
          c.dout    <= dpr0_ob;
        end if;
        -- Read the data, until the processing is started
        r_i.stage             <= 0;
        r_i.step_in           <= 0;
        r_i.step_out          <= 0;
        r_i.stage_out_started <= '0';
        if start = '1' then
          r_i.state       <= FFT_STATE_PROCESS;
          r_i.ready       <= '0';
          r_i.busy        <= '1';
          r_i.latency_cnt <= BTFLY_LATENCY;  -- start the latency counter
        end if;
      when FFT_STATE_PROCESS =>
        -- First we prepare to read the data
        -- The memory used to read the data depends
        -- on number of stage
        if r_o.mem_switch = '0' then
          c.dpr0_aa <= n2k(r_o.stage, r_o.step_in, 0);
          c.dpr0_ab <= n2k(r_o.stage, r_o.step_in, 1);
        else
          c.dpr1_aa <= n2k(r_o.stage, r_o.step_in, 0);
          c.dpr1_ab <= n2k(r_o.stage, r_o.step_in, 1);
        end if;
        -- data will be available in the next clock
        -- so we need to output the twiddle factor also the next clock
        -- Twiddle factor
        -- Selection of the twiddle factor 
        r_i.tf <= tf_table(tf_select(r_o.step_in, r_o.stage));  -- to be corrected!
        -- Increase number of step in the current stage
        if r_o.step_in < FFT_LEN/2-1 then
          r_i.step_in <= r_o.step_in+1;
        else
          -- Increasing number of the stage is done
          -- in the part, which handles writing of results
          null;
        end if;
        -- Check, if we should start writing of data
        if r_o.latency_cnt > 0 then
          r_i.latency_cnt <= r_o.latency_cnt - 1;
        else
          r_i.stage_out_started <= '1';
        end if;
        -- Now we handle writing of data
        if r_o.stage_out_started = '1' then
          -- First we prepare to write the data
          -- The memory used to read the data depends
          -- on number of stage
          if r_o.mem_switch = '0' then
            c.dpr1_aa <= n2k(r_o.stage, r_o.step_out, 0);
            c.dpr1_ia <= dout0;
            c.dpr1_ab <= n2k(r_o.stage, r_o.step_out, 1);
            c.dpr1_ib <= dout1;
            c.dpr1_wa <= '1';
            c.dpr1_wb <= '1';
          else
            c.dpr0_aa <= n2k(r_o.stage, r_o.step_out, 0);
            c.dpr0_ia <= dout0;
            c.dpr0_ab <= n2k(r_o.stage, r_o.step_out, 1);
            c.dpr0_ib <= dout1;
            c.dpr0_wa <= '1';
            c.dpr0_wb <= '1';
          end if;
          -- Now update the step counter
          if r_o.step_out < FFT_LEN/2-1 then
            r_i.step_out <= r_o.step_out + 1;
          else
            r_i.step_out          <= 0;
            r_i.stage_out_started <= '0';
            if r_o.stage < LOG2_FFT_LEN-1 then
              -- go to the next stage
              r_i.stage             <= r_o.stage + 1;
              r_i.mem_switch        <= not r_o.mem_switch;
              r_i.stage_out_started <= '0';
              r_i.step_in           <= 0;
              r_i.latency_cnt       <= BTFLY_LATENCY;  -- start the latency counter
            else
              -- We have completed all stages, so we can go to the
              -- data read state
              r_i.state <= FFT_STATE_READ;
              r_i.busy  <= '0';
              r_i.ready <= '1';         -- signal, that data may be read
            end if;
          end if;
        end if;
      when others => null;
    end case;
  end process p1;

  p2 : process (clk, rst_n)
  begin  -- process p2
    if rst_n = '0' then                 -- asynchronous reset (active low)
      r_o <= fft_regs_init;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if syn_rst_n = '0' then
        -- We use also synchronous reset, to avoid races
        r_o <= fft_regs_init;
      else
        r_o <= r_i;
      end if;
    end if;
  end process p2;

end fft_engine_beh;
