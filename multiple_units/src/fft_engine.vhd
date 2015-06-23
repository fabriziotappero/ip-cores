-------------------------------------------------------------------------------
-- Title      : fft_top
-- Project    : Pipelined, DP RAM based FFT processor
-------------------------------------------------------------------------------
-- File       : fft_top.vhd
-- Author     : Wojciech Zabolotny
-- Company    : 
-- License    : BSD
-- Created    : 2014-01-18
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This file implements a FFT processor based on a dual port RAM
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
use work.fft_len.all;
use work.icpx.all;
use work.fft_support_pkg.all;

entity fft_engine is
  generic (
    LOG2_FFT_LEN : integer := 4);       -- Defines order of FFT
  port (
    -- System interface
    rst_n     : in  std_logic;
    clk       : in  std_logic;
    -- Input memory interface
    din       : in  icpx_number;        -- data input
    valid     : out std_logic;
    saddr     : out unsigned(LOG2_FFT_LEN-2 downto 0);
    saddr_rev : out unsigned(LOG2_FFT_LEN-2 downto 0);
    sout0     : out icpx_number;        -- spectrum output
    sout1     : out icpx_number         -- spectrum output
    );

end fft_engine;

architecture fft_engine_beh of fft_engine is

  constant MULT_LATENCY : integer := 3;

  -- Type used to store twiddle factors
  type T_TF_TABLE is array (0 to FFT_LEN/2-1) of icpx_number;

  -- Function initializing the twiddle factor memory
  -- (during synthesis it is evaluated only during compilation,
  -- so no floating point arithmetics must be synthesized!)
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

  -- Type used to store the window function
  type T_WINDOW_TABLE is array (0 to FFT_LEN-1) of icpx_number;
  function tw_table_init
    return T_WINDOW_TABLE is
    variable x   : real;
    variable res : T_WINDOW_TABLE;
  begin  -- function tw_table_init
    for i in 0 to FFT_LEN-1 loop
      x      := real(i)*2.0*MATH_PI/real(FFT_LEN-1);
      res(i) := cplx2icpx(complex'(0.5*(1.0-cos(x)), 0.0));
    --s(i) := cplx2icpx(complex'(1.0, 0.0));
    end loop;  -- i
    return res;
  end function tw_table_init;
  -- Window function ROM memory
  constant window_function : T_WINDOW_TABLE := tw_table_init;

  type T_STEP_MULT is array (0 to LOG2_FFT_LEN) of integer;
  function step_mult_init
    return T_STEP_MULT is
    variable res : T_STEP_MULT;
  begin  -- function step_mult_init
    for i in 0 to LOG2_FFT_LEN loop
      res(i) := 2**i;
    end loop;  -- i
    return res;
  end function step_mult_init;

  component icpx_mul is
    generic (
      MULT_LATENCY : integer);
    port (
      din0 : in  icpx_number;
      din1 : in  icpx_number;
      dout : out icpx_number;
      clk  : in  std_logic);
  end component icpx_mul;

  constant BF_DELAY  : integer     := 3;
  -- Table for index multipliers, when geting TF from the table
  constant STEP_MULT : T_STEP_MULT := step_mult_init;

  type T_FFT_STATE is (TFS_IDLE, TFS_RUN);

  -- The input data are stored in the cyclical input buffer of length (?)
  -- Then we feed the data to the first processing unit.

  type T_FFT_DATA_ARRAY is array (LOG2_FFT_LEN downto 0) of icpx_number;
  signal in0, in1, out0, out1, tft : T_FFT_DATA_ARRAY;
  signal r_din0, r_din1, wf0, wf1  : icpx_number := icpx_zero;

  signal s_saddr, dptr0     : unsigned(LOG2_FFT_LEN-2 downto 0);
  signal start0_del         : integer range 0 to MULT_LATENCY := 0;
  signal start0, start0_pre : std_logic                       := '0';


  signal started  : std_logic_vector(LOG2_FFT_LEN downto 0) := (others => '0');
  signal start_dr : std_logic_vector(LOG2_FFT_LEN downto 0) := (others => '0');

  type T_FFT_INTS is array (0 to LOG2_FFT_LEN) of integer;
  signal next_delay  : T_FFT_INTS := (others => 0);
  signal step_bf     : T_FFT_INTS := (others => 0);
  signal start_delay : T_FFT_INTS := (others => 0);

  
begin  -- fft_top_beh

  -- We need something, to synchronize all stages after reset...
  -- This mechanism should consider the processing latency...
  g0 : for i in 0 to LOG2_FFT_LEN-2 generate
    next_delay(i) <= 2**(LOG2_FFT_LEN-2-i);
  end generate g0;


  -- Processing of input data -- using the window function!
  dp_ram_rbw_icpx_1 : entity work.dp_ram_rbw_icpx
    generic map (
      ADDR_WIDTH => LOG2_FFT_LEN-1)
    port map (
      clk    => clk,
      we_a   => '1',
      addr_a => std_logic_vector(dptr0),
      data_a => din,
      q_a    => r_din0,
      we_b   => '0',
      addr_b => std_logic_vector(dptr0),
      data_b => din,
      q_b    => open);


  -- Process reading the input data (directly, and from delay line)
  -- Additionally we consider the delay associated with multiplication
  -- by the window function
  ip1 : process (clk, rst_n) is
  begin  -- process st2
    if rst_n = '0' then                 -- asynchronous reset (active low)
      dptr0  <= (others => '0');
      r_din1 <= icpx_zero;
      start0 <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      r_din1 <= din;
      if dptr0 < (2**(LOG2_FFT_LEN-1))-1 then
        dptr0 <= dptr0+1;
      else
        dptr0      <= (others => '0');
        start0_pre <= '1';
      end if;
      if start0_pre = '1' then
        if start0_del = MULT_LATENCY-1 then
          start0 <= '1';
        else
          start0_del <= start0_del + 1;
        end if;
      end if;
    end if;
  end process ip1;

  -- Process providing the values of the window function
  mw1 : process (clk) is
  begin  -- process mw1
    if clk'event and clk = '1' then     -- rising clock edge
      wf0 <= window_function(to_integer(dptr0));
      wf1 <= window_function(to_integer(dptr0)+FFT_LEN/2);
    end if;
  end process mw1;
  -- Now connect the output signals to the multipliers
  icpx_mul_1 : entity work.icpx_mul
    generic map (
      MULT_LATENCY => MULT_LATENCY)
    port map (
      din0 => r_din0,
      din1 => wf0,
      dout => in0(0),
      rst_n => rst_n,
      clk  => clk);
  icpx_mul_2 : entity work.icpx_mul
    generic map (
      MULT_LATENCY => MULT_LATENCY)
    port map (
      din0 => r_din1,
      din1 => wf1,
      dout => in1(0),
      rst_n => rst_n,
      clk  => clk);

  started(0) <= start0;
  -- Now we generate blocks for different stages
  -- For each stage we must maintain three counters
  -- phase - 0 or 1
  -- step - 0 to 2**(STAGE_N)
  -- cycle - jak to nazwac?

  g1 : for st in 0 to LOG2_FFT_LEN-1 generate
    -- Here we generate structures for a single stage of FFT
    -- First the butterfly unit
    butterfly_1 : entity work.butterfly
    generic map (
      LATENCY => BF_DELAY)
    port map (
      din0  => in0(st),
      din1  => in1(st),
      tf    => tft(st),
      dout0 => out0(st),
      dout1 => out1(st),
      clk   => clk,
      rst_n => rst_n
      );

    -- Process controlling selection of twiddle factor for the butterfly unit
    -- after our stage is started, we increase the twiddle factor cyclically
    -- Process also delays starting of data switch

    process (clk, rst_n) is
      constant STEP_BF_LIMIT : integer := 2**(LOG2_FFT_LEN-st-1)-1;
    begin  -- process
      if rst_n = '0' then                 -- asynchronous reset (active low)
        step_bf(st)     <= 0;
        start_delay(st) <= 0;
        start_dr(st)    <= '0';
      elsif clk'event and clk = '1' then  -- rising clock edge
        if started(st) = '1' then
          if start_delay(st) = BF_DELAY then
            start_dr(st) <= '1';          -- start the "data switch"
          end if;
          if start_delay(st) = BF_DELAY+next_delay(st) then
            started(st+1) <= '1';         -- start the next stage
          end if;
          if start_delay(st) /= BF_DELAY+next_delay(st) then
            start_delay(st) <= start_delay(st)+1;
          end if;
          if step_bf(st) < STEP_BF_LIMIT then
            step_bf(st) <= step_bf(st) + 1;
          else
            step_bf(st) <= 0;
          end if;
        end if;
      end if;
    end process;

    -- Twiddle factor ROM
    process (clk) is
    begin  -- process
      if clk'event and clk = '1' then   -- rising clock edge
        tft(st) <= tf_table(step_bf(st)*STEP_MULT(st));
      end if;
    end process;

    -- Next the data switch, but not for the last stage!
    i3 : if st /= LOG2_FFT_LEN-1 generate
      fft_switch_1 : entity work.fft_data_switch
        generic map (
          LOG2_FFT_LEN => LOG2_FFT_LEN,
          STAGE        => st)
        port map (
          in0    => out0(st),
          in1    => out1(st),
          out0   => in0(st+1),
          out1   => in1(st+1),
          enable => start_dr(st),
          rst_n  => rst_n,
          clk    => clk);      
    end generate i3;
    -- In the last stage, we simply count the output samples
    i4 : if st = LOG2_FFT_LEN-1 generate
      process (clk, rst_n) is
      begin  -- process
        if rst_n = '0' then                 -- asynchronous reset (active low)
          s_saddr <= (others => '0');
        elsif clk'event and clk = '1' then  -- rising clock edge
          if start_dr(st) = '1' then
            if s_saddr = FFT_LEN/2-1 then
              s_saddr <= (others => '0');
            else
              s_saddr <= s_saddr+1;
            end if;
          end if;
        end if;
      end process;
    end generate i4;

  end generate g1;
  valid <= started(LOG2_FFT_LEN);
  saddr     <= s_saddr;
  saddr_rev <= rev(s_saddr);
  sout0     <= out0(LOG2_FFT_LEN-1);
  sout1     <= out1(LOG2_FFT_LEN-1);
  
end fft_engine_beh;
