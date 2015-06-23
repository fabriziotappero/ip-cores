-------------------------------------------------------------------------------
-- Title      : Basic asynchronous FIFO with two clocks
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fifo_2clk.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2011-01-13
-- Last update: 2011-11-29
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
--   Fully asynchronous fifo.
--
--   Idea from:
--     Cummings et al., Simulation and Synthesis Techniques for Asynchronous
--     FIFO Design with Asynchronous Pointer Comparisons, SNUG San Jose 2002
--
--
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-01-13  1.0      ase     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fifo_2clk is
  
  generic (
    data_width_g : positive;
    depth_g      : positive);

  port (        
    rst_n     : in  std_logic;
    -- Write
    clk_wr    : in  std_logic;
    we_in     : in  std_logic;
    data_in   : in  std_logic_vector(data_width_g-1 downto 0);
    full_out  : out std_logic;
    -- Read
    clk_rd    : in  std_logic;
    re_in     : in  std_logic;
    data_out  : out std_logic_vector(data_width_g-1 downto 0);
    empty_out : out std_logic);

end entity fifo_2clk;


architecture rtl of fifo_2clk is

  -----------------------------------------------------------------------------
  -- FUNCTIONS
  -----------------------------------------------------------------------------
  -- purpose: Return ceiling log 2 of n
  function log2_ceil (
    constant n : positive)
    return positive is
    variable retval : positive := 1;
  begin  -- function log2_ceil
    while 2**retval < n loop
      retval := retval + 1;
    end loop;
    return retval;
  end function log2_ceil;

  -- binary to graycode conversion
  function bin2gray (
    signal num : integer range 0 to depth_g-1)
    return std_logic_vector is
    variable retval : std_logic_vector(log2_ceil(depth_g)-1 downto 0);
    variable d1     : std_logic_vector(log2_ceil(depth_g)-1 downto 0);
  begin
    d1     := std_logic_vector((to_unsigned(num, log2_ceil(depth_g))));
    retval := d1 xor ('0' & d1(log2_ceil(depth_g)-1 downto 1));
    return retval;
  end function bin2gray;

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------
  constant addr_width_c : positive := log2_ceil(depth_g);

  -----------------------------------------------------------------------------
  -- REGISTERS
  -----------------------------------------------------------------------------
  signal wr_addr_r : integer range 0 to depth_g-1;
  signal rd_addr_r : integer range 0 to depth_g-1;
  signal full_1_r  : std_logic;
  signal full_2_r  : std_logic;
  signal empty_1_r : std_logic;
  signal empty_2_r : std_logic;

  -----------------------------------------------------------------------------
  -- COMBINATORIAL SIGNALS
  -----------------------------------------------------------------------------
  signal next_wr_addr : integer range 0 to depth_g-1;
  signal next_rd_addr : integer range 0 to depth_g-1;
  signal wr_addr      : std_logic_vector(addr_width_c-1 downto 0);
  signal rd_addr      : std_logic_vector(addr_width_c-1 downto 0);
  signal we           : std_logic;
  signal dirset_n     : std_logic;
  signal dirclr_n     : std_logic;
  signal direction    : std_logic;
  signal empty_n      : std_logic;
  signal full_n       : std_logic;
  
begin  -- architecture rtl


  full_out  <= full_2_r;
  empty_out <= empty_2_r;

  -----------------------------------------------------------------------------
  -- WRITE
  -----------------------------------------------------------------------------

  write_p : process (clk_wr, rst_n)
  begin  -- process write_p
    if rst_n = '0' then                 -- asynchronous reset (active low)

      wr_addr_r <= 0;
      
    elsif clk_wr'event and clk_wr = '1' then  -- rising clock edge

      if we_in = '1' and full_2_r = '0' then
        wr_addr_r <= next_wr_addr;
      end if;

    end if;
  end process write_p;

  we <= we_in and not full_2_r;

  -----------------------------------------------------------------------------
  -- READ
  -----------------------------------------------------------------------------

  read_p : process (clk_rd, rst_n)
  begin  -- process read_p
    if rst_n = '0' then                 -- asynchronous reset (active low)

      rd_addr_r <= 0;
      
    elsif clk_rd'event and clk_rd = '1' then  -- rising clock edge

      if re_in = '1' and empty_2_r = '0' then
        rd_addr_r <= next_rd_addr;
      end if;
      
    end if;
  end process read_p;

  -----------------------------------------------------------------------------
  -- RAM
  -----------------------------------------------------------------------------

  wr_addr <= std_logic_vector(to_unsigned(wr_addr_r, addr_width_c));
  rd_addr <= std_logic_vector(to_unsigned(rd_addr_r, addr_width_c));

  ram_2clk_1 : entity work.ram_1clk
    generic map (
      data_width_g => data_width_g,
      addr_width_g => addr_width_c,
      depth_g      => depth_g,
      out_reg_en_g => 0)
    port map (
      clk        => clk_wr,
      wr_addr_in => wr_addr,
      rd_addr_in => rd_addr,
      we_in      => we,
      data_in    => data_in,
      data_out   => data_out);

  -----------------------------------------------------------------------------
  -- NEXT ADDRESSES
  -----------------------------------------------------------------------------
  
  next_wr_addr_p : process (wr_addr_r) is
  begin

    if wr_addr_r = depth_g-1 then
      next_wr_addr <= 0;
    else
      next_wr_addr <= wr_addr_r + 1;
    end if;

  end process next_wr_addr_p;

  next_rd_addr_p : process (rd_addr_r) is
  begin

    if rd_addr_r = depth_g-1 then
      next_rd_addr <= 0;
    else
      next_rd_addr <= rd_addr_r + 1;
    end if;
    
  end process next_rd_addr_p;

  -----------------------------------------------------------------------------
  -- ASYNC COMPARISON (FULL AND EMPTY GENERATION)
  -----------------------------------------------------------------------------

  dirgen_p : process (wr_addr_r, rd_addr_r, rst_n)
    variable wr_h1 : std_logic;
    variable wr_h2 : std_logic;
    variable rd_h1 : std_logic;
    variable rd_h2 : std_logic;
  begin  -- process asyncomp_p

    wr_h1 := bin2gray(wr_addr_r)(addr_width_c-1);
    wr_h2 := bin2gray(wr_addr_r)(addr_width_c-2);
    rd_h1 := bin2gray(rd_addr_r)(addr_width_c-1);
    rd_h2 := bin2gray(rd_addr_r)(addr_width_c-2);

    dirset_n <= not ((wr_h1 xor rd_h2) and not (wr_h2 xor rd_h1));
    dirclr_n <= not ((not (wr_h1 xor rd_h2) and (wr_h2 xor rd_h1))
                     or not rst_n);

  end process dirgen_p;

  rs_flop_p : process (dirclr_n, dirset_n, direction)
  begin  -- process rs_flop_p
    if dirclr_n = '0' then
      direction <= '0';
    elsif dirset_n = '0' then
      direction <= '1';
    else
      direction <= direction;
    end if;
  end process rs_flop_p;

  full_empty_s : process (direction, wr_addr_r, rd_addr_r)
    variable match_v : std_logic;
  begin  -- process empty_s
    if rd_addr_r = wr_addr_r then
      match_v := '1';
    else
      match_v := '0';
    end if;
    if match_v = '1' and direction = '1' then
      full_n <= '0';
    else
      full_n <= '1';
    end if;
    if match_v = '1' and direction = '0' then
      empty_n <= '0';
    else
      empty_n <= '1';
    end if;
  end process full_empty_s;

  -----------------------------------------------------------------------------
  -- Two rs-registers to synchronize empty signal
  -----------------------------------------------------------------------------
  
  empty_sync_1p : process (clk_rd, rst_n, empty_n)
  begin  -- process empty_sync_p
    if rst_n = '0' then                 -- asynchronous reset (active low)
      empty_1_r <= '1';
    elsif empty_n = '0' then
      empty_1_r <= not empty_n;
    elsif clk_rd'event and clk_rd = '1' then  -- rising clock edge
      empty_1_r <= not empty_n;
    end if;
  end process empty_sync_1p;

  empty_sync_2p : process (clk_rd, rst_n, empty_n, empty_1_r)
  begin  -- process empty_sync_p
    if rst_n = '0' then                 -- asynchronous reset (active low)
      empty_2_r <= '1';
    elsif empty_n = '0' then
      empty_2_r <= empty_1_r;
    elsif clk_rd'event and clk_rd = '1' then  -- rising clock edge
      empty_2_r <= empty_1_r;
    end if;
  end process empty_sync_2p;

 ------------------------------------------------------------------------------
 -- Two rs-registers to synchronize full signal
 ------------------------------------------------------------------------------

  full_sync_1p : process (clk_wr, rst_n, full_n)
  begin  -- process empty_sync_p
    if rst_n = '0' then                 -- asynchronous reset (active low)
      full_1_r <= '0';
    elsif full_n = '0' then
      full_1_r <= not full_n;
    elsif clk_wr'event and clk_wr = '1' then  -- rising clock edge
      full_1_r <= not full_n;
    end if;
  end process full_sync_1p;

  full_sync_2p : process (clk_wr, rst_n, full_n, full_1_r)
  begin  -- process empty_sync_p
    if rst_n = '0' then                 -- asynchronous reset (active low)
      full_2_r <= '0';
    elsif full_n = '0' then
      full_2_r <= full_1_r;
    elsif clk_wr'event and clk_wr = '1' then  -- rising clock edge
      full_2_r <= full_1_r;
    end if;
  end process full_sync_2p;
  
end architecture rtl;
