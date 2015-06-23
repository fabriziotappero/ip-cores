-------------------------------------------------------------------------------
-- Title      : Router for 2D mesh mk1 by ase
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ase_mesh1_router.vhdl
-- Author     : Lasse Lehtonen (ase)
-- Company    : 
-- Created    : 2010-04-06
-- Last update: 2012-03-22
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Router has connections to 4 neighbors and to IP. Neighbors are
--              are named as compass points: north, east, south and west.
--              Routing is fixed to YX routing and arbitration has fixed prio-
--              rities among the input ports. Addresses are expressed as number
--              of hops, e.g. 2 up and then 3 to the right.
--              Flow control needs 2 bits downstream (da+av) and 1 upstream (stall)
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-04-06  1.0      ase     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.log2_pkg.all;

entity ase_mesh1_router is
  generic (
    n_rows_g    : positive;             -- Number of rows
    n_cols_g    : positive;             -- Number of columns
    bus_width_g : positive              -- Width of the data bus in bits
    );                         
  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    -- Agent interface
    a_data_in   : in  std_logic_vector(bus_width_g-1 downto 0);
    a_da_in     : in  std_logic;        -- data available = not empty = either addr or data
    a_av_in     : in  std_logic;        -- addr valid
    a_stall_out : out std_logic;

    a_data_out  : out std_logic_vector(bus_width_g-1 downto 0);
    a_da_out    : out std_logic;
    a_av_out    : out std_logic;
    a_stall_in  : in  std_logic;

    -- North interface
    n_data_in   : in  std_logic_vector(bus_width_g-1 downto 0);
    n_da_in     : in  std_logic;
    n_av_in     : in  std_logic;
    n_stall_out : out std_logic;
    n_data_out  : out std_logic_vector(bus_width_g-1 downto 0);
    n_da_out    : out std_logic;
    n_av_out    : out std_logic;
    n_stall_in  : in  std_logic;

    -- East interface
    e_data_in   : in  std_logic_vector(bus_width_g-1 downto 0);
    e_da_in     : in  std_logic;
    e_av_in     : in  std_logic;
    e_stall_out : out std_logic;
    e_data_out  : out std_logic_vector(bus_width_g-1 downto 0);
    e_da_out    : out std_logic;
    e_av_out    : out std_logic;
    e_stall_in  : in  std_logic;

    -- South interface
    s_data_in   : in  std_logic_vector(bus_width_g-1 downto 0);
    s_da_in     : in  std_logic;
    s_av_in     : in  std_logic;
    s_stall_out : out std_logic;
    s_data_out  : out std_logic_vector(bus_width_g-1 downto 0);
    s_da_out    : out std_logic;
    s_av_out    : out std_logic;
    s_stall_in  : in  std_logic;

    -- West interface
    w_data_in   : in  std_logic_vector(bus_width_g-1 downto 0);
    w_da_in     : in  std_logic;
    w_av_in     : in  std_logic;
    w_stall_out : out std_logic;
    w_data_out  : out std_logic_vector(bus_width_g-1 downto 0);
    w_da_out    : out std_logic;
    w_av_out    : out std_logic;
    w_stall_in  : in  std_logic
    );

end entity ase_mesh1_router;


-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------

architecture rtl of ase_mesh1_router is

  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------

  -- Num of hops are stored into the lowest bits of the flit
  constant r_addr_width_c  : positive := log2_ceil(n_rows_g-1);
  constant c_addr_width_c  : positive := log2_ceil(n_cols_g-1);
  -- 4 additional bits are used for routing.
  --  1b telling go to left or right?,
  --  1b already in the right column? (called "here"), 
  --  2b for where to go first when data comes from ip
  constant lr_index_c      : positive := r_addr_width_c + c_addr_width_c;
  constant here_index_c    : positive := r_addr_width_c + c_addr_width_c + 1;
  constant first_index_h_c : positive := r_addr_width_c + c_addr_width_c + 3;
  constant first_index_l_c : positive := r_addr_width_c + c_addr_width_c + 2;

  -----------------------------------------------------------------------------
  -- REGISTERS
  -----------------------------------------------------------------------------

  -- Output registers
  signal a_stall_out_r : std_logic;
  signal a_data_out_r  : std_logic_vector(bus_width_g-1 downto 0);
  signal a_da_out_r    : std_logic;
  signal a_av_out_r    : std_logic;
  signal n_stall_out_r : std_logic;
  signal n_data_out_r  : std_logic_vector(bus_width_g-1 downto 0);
  signal n_da_out_r    : std_logic;
  signal n_av_out_r    : std_logic;
  signal e_stall_out_r : std_logic;
  signal e_data_out_r  : std_logic_vector(bus_width_g-1 downto 0);
  signal e_da_out_r    : std_logic;
  signal e_av_out_r    : std_logic;
  signal s_stall_out_r : std_logic;
  signal s_data_out_r  : std_logic_vector(bus_width_g-1 downto 0);
  signal s_da_out_r    : std_logic;
  signal s_av_out_r    : std_logic;
  signal w_stall_out_r : std_logic;
  signal w_data_out_r  : std_logic_vector(bus_width_g-1 downto 0);
  signal w_da_out_r    : std_logic;
  signal w_av_out_r    : std_logic;

  -- Input registers
  signal a_data_in_r : std_logic_vector(bus_width_g-1 downto 0);
  signal a_av_in_r   : std_logic;
  signal a_da_in_r   : std_logic;
  signal n_data_in_r : std_logic_vector(bus_width_g-1 downto 0);
  signal n_av_in_r   : std_logic;
  signal n_da_in_r   : std_logic;
  signal e_data_in_r : std_logic_vector(bus_width_g-1 downto 0);
  signal e_av_in_r   : std_logic;
  signal e_da_in_r   : std_logic;
  signal s_data_in_r : std_logic_vector(bus_width_g-1 downto 0);
  signal s_av_in_r   : std_logic;
  signal s_da_in_r   : std_logic;
  signal w_data_in_r : std_logic_vector(bus_width_g-1 downto 0);
  signal w_av_in_r   : std_logic;
  signal w_da_in_r   : std_logic;

  -- Other registers
  signal reroute_n_r : std_logic;       -- Data from n(orht) makes a turn or not?
  signal reroute_e_r : std_logic;
  signal reroute_s_r : std_logic;
  signal reroute_w_r : std_logic;

  signal grant_s_n_r : std_logic;       -- Output n(orht) granted for data from s(outh)
  signal grant_a_n_r : std_logic;

  signal grant_n_e_r : std_logic;       
  signal grant_s_e_r : std_logic;
  signal grant_w_e_r : std_logic;
  signal grant_a_e_r : std_logic;

  signal grant_n_s_r : std_logic;
  signal grant_a_s_r : std_logic;

  signal grant_n_w_r : std_logic;
  signal grant_e_w_r : std_logic;
  signal grant_s_w_r : std_logic;
  signal grant_a_w_r : std_logic;

  signal grant_n_a_r : std_logic;
  signal grant_e_a_r : std_logic;
  signal grant_s_a_r : std_logic;
  signal grant_w_a_r : std_logic;

  -- Address = num of hops is incremented on every router. When row or col bit
  -- overflow packet has reached the right row or column. Note that this
  -- addition performed also for data flits. Therefore, 
  
  signal add_ar_r : std_logic_vector(r_addr_width_c-1 downto 0);
  signal add_ac_r : std_logic_vector(c_addr_width_c-1 downto 0);

  -----------------------------------------------------------------------------
  -- COMBINATIORIAL SIGNALS
  -----------------------------------------------------------------------------
  signal add_n : std_logic_vector(r_addr_width_c downto 0);
  signal add_e : std_logic_vector(c_addr_width_c downto 0);
  signal add_s : std_logic_vector(r_addr_width_c downto 0);
  signal add_w : std_logic_vector(c_addr_width_c downto 0);

  signal data_n : std_logic_vector(bus_width_g-1 downto 0);
  signal data_e : std_logic_vector(bus_width_g-1 downto 0);
  signal data_s : std_logic_vector(bus_width_g-1 downto 0);
  signal data_w : std_logic_vector(bus_width_g-1 downto 0);
  signal data_a : std_logic_vector(bus_width_g-1 downto 0);

  signal reroute_n : std_logic;
  signal reroute_e : std_logic;
  signal reroute_s : std_logic;
  signal reroute_w : std_logic;

  signal here_n      : std_logic;
  signal here_s      : std_logic;
  signal here_n_prev : std_logic;
  signal here_s_prev : std_logic;

  signal lr_n      : std_logic;
  signal lr_s      : std_logic;
  signal lr_n_prev : std_logic;
  signal lr_s_prev : std_logic;

  signal a_first_hi      : std_logic;
  signal a_first_lo      : std_logic;
  signal a_first_hi_prev : std_logic;
  signal a_first_lo_prev : std_logic;

  signal req_n_e : std_logic;
  signal req_n_s : std_logic;
  signal req_n_w : std_logic;
  signal req_n_a : std_logic;

  signal req_e_w : std_logic;
  signal req_e_a : std_logic;

  signal req_s_n : std_logic;
  signal req_s_e : std_logic;
  signal req_s_w : std_logic;
  signal req_s_a : std_logic;

  signal req_w_e : std_logic;
  signal req_w_a : std_logic;

  signal req_a_n : std_logic;
  signal req_a_e : std_logic;
  signal req_a_s : std_logic;
  signal req_a_w : std_logic;

  signal grant_s_n : std_logic;
  signal grant_a_n : std_logic;

  signal grant_n_e : std_logic;
  signal grant_s_e : std_logic;
  signal grant_w_e : std_logic;
  signal grant_a_e : std_logic;

  signal grant_n_s : std_logic;
  signal grant_a_s : std_logic;

  signal grant_n_w : std_logic;
  signal grant_e_w : std_logic;
  signal grant_s_w : std_logic;
  signal grant_a_w : std_logic;

  signal grant_n_a : std_logic;
  signal grant_e_a : std_logic;
  signal grant_s_a : std_logic;
  signal grant_w_a : std_logic;

  signal stall_n : std_logic;
  signal stall_e : std_logic;
  signal stall_s : std_logic;
  signal stall_w : std_logic;
  signal stall_a : std_logic;
  
  
begin  -- architecture rtl

  -----------------------------------------------------------------------------
  -- CONNECT OUTPUT REGISTERS TO OUTPUT PORTS
  -----------------------------------------------------------------------------
  a_stall_out <= a_stall_out_r;
  a_data_out  <= a_data_out_r;
  a_da_out    <= a_da_out_r;
  a_av_out    <= a_av_out_r;

  n_stall_out <= n_stall_out_r;
  n_data_out  <= n_data_out_r;
  n_da_out    <= n_da_out_r;
  n_av_out    <= n_av_out_r;

  e_stall_out <= e_stall_out_r;
  e_data_out  <= e_data_out_r;
  e_da_out    <= e_da_out_r;
  e_av_out    <= e_av_out_r;

  s_stall_out <= s_stall_out_r;
  s_data_out  <= s_data_out_r;
  s_da_out    <= s_da_out_r;
  s_av_out    <= s_av_out_r;

  w_stall_out <= w_stall_out_r;
  w_data_out  <= w_data_out_r;
  w_da_out    <= w_da_out_r;
  w_av_out    <= w_av_out_r;

  -----------------------------------------------------------------------------
  -- COMINATORIAL SIGNALS
  -----------------------------------------------------------------------------

  -- Always increment the incoming flits
  add_n <=
    std_logic_vector(resize(unsigned(n_data_in(r_addr_width_c-1 downto 0)),
                            r_addr_width_c+1)
                     + to_unsigned(1, r_addr_width_c+1));
  add_e <=
    std_logic_vector(resize(unsigned(
      e_data_in(c_addr_width_c + r_addr_width_c-1 downto r_addr_width_c)),
                            c_addr_width_c+1)
                     + to_unsigned(1, c_addr_width_c+1));
  add_s <=
    std_logic_vector(resize(unsigned(s_data_in(r_addr_width_c-1 downto 0)),
                            r_addr_width_c+1)
                     + to_unsigned(1, r_addr_width_c+1));
  add_w <=
    std_logic_vector(resize(unsigned(
      w_data_in(c_addr_width_c + r_addr_width_c-1 downto r_addr_width_c)),
                            c_addr_width_c+1)
                     + to_unsigned(1, c_addr_width_c+1));

  -- Forward the data to the agent (=IP block) and other outputs
  with a_av_in select
    data_a <=
    a_data_in when '1',
    a_data_in(bus_width_g-1 downto c_addr_width_c+r_addr_width_c) &
    std_logic_vector(unsigned(a_data_in(c_addr_width_c+r_addr_width_c-1
                                        downto r_addr_width_c)) +
                     unsigned(add_ac_r)) &
    std_logic_vector(unsigned(a_data_in(r_addr_width_c-1 downto 0)) +
                     unsigned(add_ar_r)) when others;

  data_n <= n_data_in(bus_width_g-1 downto r_addr_width_c) &
            add_n(r_addr_width_c-1 downto 0);
  data_e <= e_data_in(bus_width_g-1 downto c_addr_width_c + r_addr_width_c) &
            add_e(c_addr_width_c-1 downto 0) &
            e_data_in(r_addr_width_c-1 downto 0);
  data_s <= s_data_in(bus_width_g-1 downto r_addr_width_c) &
            add_s(r_addr_width_c-1 downto 0);
  data_w <= w_data_in(bus_width_g-1 downto c_addr_width_c + r_addr_width_c) &
            add_w(c_addr_width_c-1 downto 0) &
            w_data_in(r_addr_width_c-1 downto 0);


  
  -- Short-hand notations: for detecting if a turn is needed (reroute),
  -- has the right column been reached, whether to go left or right, and where
  -- to go first when entering the network.
  reroute_n <= add_n(r_addr_width_c);
  reroute_e <= add_e(c_addr_width_c);
  reroute_s <= add_s(r_addr_width_c);
  reroute_w <= add_w(c_addr_width_c);

  here_n      <= n_data_in(here_index_c);
  here_s      <= s_data_in(here_index_c);
  here_n_prev <= n_data_in_r(here_index_c);
  here_s_prev <= s_data_in_r(here_index_c);

  lr_n      <= n_data_in(lr_index_c);
  lr_s      <= s_data_in(lr_index_c);
  lr_n_prev <= n_data_in_r(lr_index_c);
  lr_s_prev <= s_data_in_r(lr_index_c);

  a_first_hi      <= a_data_in(first_index_h_c);
  a_first_lo      <= a_data_in(first_index_l_c);
  a_first_hi_prev <= a_data_in_r(first_index_h_c);
  a_first_lo_prev <= a_data_in_r(first_index_l_c);


  -- Arbitrate for outputs. Routing algorithm decides with output to "request"
  -- and fixed-priority algorithm "grants" the output to one of the requestors
  req_n_e <= ((n_av_in and not n_stall_out_r) and reroute_n and (not here_n) and
              (not lr_n)) or
             (n_av_in_r and reroute_n_r and (not here_n_prev) and
              (not lr_n_prev));
  req_n_s <= ((n_av_in and not n_stall_out_r) and (not reroute_n)) or
             (n_av_in_r and (not reroute_n_r));
  req_n_w <= ((n_av_in and not n_stall_out_r) and reroute_n and (not here_n) and
              (lr_n)) or
             (n_av_in_r and reroute_n_r and (not here_n_prev) and
              (lr_n_prev));
  req_n_a <= ((n_av_in and not n_stall_out_r) and reroute_n and here_n) or
             (n_av_in_r and reroute_n_r and here_n_prev);
  
  req_e_w <= ((e_av_in and not e_stall_out_r) and (not reroute_e)) or
             (e_av_in_r and (not reroute_e_r));
  req_e_a <= ((e_av_in and not e_stall_out_r) and reroute_e) or
             (e_av_in_r and reroute_e_r);
  
  req_s_n <= ((s_av_in and not s_stall_out_r) and (not reroute_s)) or
             (s_av_in_r and (not reroute_s_r));
  req_s_e <= ((s_av_in and not s_stall_out_r) and reroute_s and (not here_s) and
              (not lr_s)) or
             (s_av_in_r and reroute_s_r and (not here_s_prev) and
              (not lr_s_prev));  
  req_s_w <= ((s_av_in and not s_stall_out_r) and reroute_s and (not here_s) and
              (lr_s)) or
             (s_av_in_r and reroute_s_r and (not here_s_prev) and
              (lr_s_prev));
  req_s_a <= ((s_av_in and not s_stall_out_r) and reroute_s and here_s) or
             (s_av_in_r and reroute_s_r and here_s_prev);

  -- (was just w_av_in              )
  req_w_e <= ((w_av_in and not w_stall_out_r) and (not reroute_w)) or
             (w_av_in_r and (not reroute_w_r));
  req_w_a <= ((w_av_in and not w_stall_out_r) and reroute_w) or
             (w_av_in_r and reroute_w_r);

  -- ( was just a_av_in       )
  req_a_n <= ((a_av_in and not a_stall_out_r) and (not a_first_hi)
              and (not a_first_lo)) or
             (a_av_in_r and (not a_first_hi_prev)
              and (not a_first_lo_prev));
  req_a_e <= ((a_av_in and not a_stall_out_r) and (not a_first_hi)
              and a_first_lo) or
             (a_av_in_r and (not a_first_hi_prev)
              and a_first_lo_prev);
  req_a_s <= ((a_av_in and not a_stall_out_r) and a_first_hi
              and (not a_first_lo)) or
             (a_av_in_r and a_first_hi_prev
              and (not a_first_lo_prev));
  req_a_w <= ((a_av_in and not a_stall_out_r) and a_first_hi
              and a_first_lo) or
             (a_av_in_r and a_first_hi_prev
              and a_first_lo_prev);

  grant_s_n <= (req_s_n
                and (not (grant_a_n_r and a_da_in and (not a_av_in)))
                and (not (grant_a_n_r and a_da_in_r and (not a_av_in_r)))) or
               (s_da_in and (not s_av_in) and grant_s_n_r) or
               (s_da_in_r and (not s_av_in_r) and grant_s_n_r);
  grant_a_n <= (req_a_n
                and (not (grant_s_n))) or
               (a_da_in and (not a_av_in) and grant_a_n_r) or
               (a_da_in_r and (not a_av_in_r) and grant_a_n_r);
  
  grant_n_e <= (req_n_e
                and (not (s_da_in and (not s_av_in) and grant_s_e_r))
                and (not (s_da_in_r and (not s_av_in_r) and grant_s_e_r))
                and (not (w_da_in and (not w_av_in) and grant_w_e_r))
                and (not (w_da_in_r and (not w_av_in_r) and grant_w_e_r))
                and (not (a_da_in and (not a_av_in) and grant_a_e_r))
                and (not (a_da_in_r and (not a_av_in_r) and grant_a_e_r))) or
               (n_da_in and (not n_av_in) and grant_n_e_r) or
               (n_da_in_r and (not n_av_in_r) and grant_n_e_r);
  grant_s_e <= (req_s_e
                and (not (grant_n_e))
                and (not (w_da_in and (not w_av_in) and grant_w_e_r))
                and (not (w_da_in_r and (not w_av_in_r) and grant_w_e_r))
                and (not (a_da_in and (not a_av_in) and grant_a_e_r))
                and (not (a_da_in_r and (not a_av_in_r) and grant_a_e_r))) or
               (s_da_in and (not s_av_in) and grant_s_e_r) or
               (s_da_in_r and (not s_av_in_r) and grant_s_e_r);
  grant_w_e <= (req_w_e
                and (not (grant_n_e))
                and (not (grant_s_e))
                and (not (a_da_in and (not a_av_in) and grant_a_e_r))
                and (not (a_da_in_r and (not a_av_in_r) and grant_a_e_r))) or
               (w_da_in and (not w_av_in) and grant_w_e_r) or
               (w_da_in_r and (not w_av_in_r) and grant_w_e_r);
  grant_a_e <= (req_a_e
                and (not (grant_n_e))
                and (not (grant_s_e))
                and (not (grant_w_e))) or
               (a_da_in and (not a_av_in) and grant_a_e_r) or
               (a_da_in_r and (not a_av_in_r) and grant_a_e_r);

  grant_n_s <= (req_n_s
                and (not (a_da_in and (not a_av_in) and grant_a_s_r))
                and (not (a_da_in_r and (not a_av_in_r) and grant_a_s_r))) or
               (n_da_in and (not n_av_in) and grant_n_s_r) or
               (n_da_in_r and (not n_av_in_r) and grant_n_s_r);
  grant_a_s <= (req_a_s
                and (not (grant_n_s))) or
               (a_da_in and (not a_av_in) and grant_a_s_r) or
               (a_da_in_r and (not a_av_in_r) and grant_a_s_r);

  grant_n_w <= (req_n_w
                and (not (s_da_in and (not s_av_in) and grant_s_w_r))
                and (not (s_da_in_r and (not s_av_in_r) and grant_s_w_r))
                and (not (e_da_in and (not e_av_in) and grant_e_w_r))
                and (not (e_da_in_r and (not e_av_in_r) and grant_e_w_r))
                and (not (a_da_in and (not a_av_in) and grant_a_w_r))
                and (not (a_da_in_r and (not a_av_in_r) and grant_a_w_r))) or
               (n_da_in and (not n_av_in) and grant_n_w_r) or
               (n_da_in_r and (not n_av_in_r) and grant_n_w_r);
  grant_e_w <= (req_e_w
                and (not (grant_n_w))
                and (not (s_da_in and (not s_av_in) and grant_s_w_r))
                and (not (s_da_in_r and (not s_av_in_r) and grant_s_w_r))
                and (not (a_da_in and (not a_av_in) and grant_a_w_r))
                and (not (a_da_in_r and (not a_av_in_r) and grant_a_w_r))) or
               (e_da_in and (not e_av_in) and grant_e_w_r) or
               (e_da_in_r and (not e_av_in_r) and grant_e_w_r);
  grant_s_w <= (req_s_w
                and (not (grant_n_w))
                and (not (grant_e_w))
                and (not (a_da_in and (not a_av_in) and grant_a_w_r))
                and (not (a_da_in_r and (not a_av_in_r) and grant_a_w_r))) or
               (s_da_in and (not s_av_in) and grant_s_w_r) or
               (s_da_in_r and (not s_av_in_r) and grant_s_w_r);
  grant_a_w <= (req_a_w
                and (not (grant_n_w))
                and (not (grant_s_w))
                and (not (grant_e_w))) or
               (a_da_in and (not a_av_in) and grant_a_w_r) or
               (a_da_in_r and (not a_av_in_r) and grant_a_w_r);

  grant_n_a <= (req_n_a
                and (not (s_da_in and (not s_av_in) and grant_s_a_r))
                and (not (s_da_in_r and (not s_av_in_r) and grant_s_a_r))
                and (not (w_da_in and (not w_av_in) and grant_w_a_r))
                and (not (w_da_in_r and (not w_av_in_r) and grant_w_a_r))
                and (not (e_da_in and (not e_av_in) and grant_e_a_r))
                and (not (e_da_in_r and (not e_av_in_r) and grant_e_a_r))) or
               (n_da_in and (not n_av_in) and grant_n_a_r) or
               (n_da_in_r and (not n_av_in_r) and grant_n_a_r);
               
  grant_e_a <= (req_e_a
                and (not (grant_n_a))
                and (not (s_da_in and (not s_av_in) and grant_s_a_r))
                and (not (s_da_in_r and (not s_av_in_r) and grant_s_a_r))
                and (not (w_da_in and (not w_av_in) and grant_w_a_r))
                and (not (w_da_in_r and (not w_av_in_r) and grant_w_a_r))) or
               (e_da_in and (not e_av_in) and grant_e_a_r) or
               (e_da_in_r and (not e_av_in_r) and grant_e_a_r);
  grant_s_a <= (req_s_a
                and (not (grant_n_a))
                and (not (grant_e_a))
                and (not (w_da_in and (not w_av_in) and grant_w_a_r))
                and (not (w_da_in_r and (not w_av_in_r) and grant_w_a_r))) or
               (s_da_in and (not s_av_in) and grant_s_a_r) or
               (s_da_in_r and (not s_av_in_r) and grant_s_a_r);
  grant_w_a <= (req_w_a
                and (not (grant_n_a))
                and (not (grant_e_a))
                and (not (grant_s_a))) or
               (w_da_in and (not w_av_in) and grant_w_a_r) or
               (w_da_in_r and (not w_av_in_r) and grant_w_a_r);

  -- Flow control. Stall the incoming data if it cannot be forwarded.
  stall_n <= (req_n_e and (not grant_n_e or e_stall_in)) or
             (grant_n_e_r and e_stall_in and grant_n_e) or  -- last added
             (req_n_s and (not grant_n_s or s_stall_in)) or
             (grant_n_s_r and s_stall_in and grant_n_s) or
             (req_n_w and (not grant_n_w or w_stall_in)) or
             (grant_n_w_r and w_stall_in and grant_n_w) or
             (req_n_a and (not grant_n_a or a_stall_in)) or
             (grant_n_a_r and a_stall_in and grant_n_a);
  stall_e <= (req_e_w and (not grant_e_w or w_stall_in)) or
             (grant_e_w_r and w_stall_in and grant_e_w) or
             (req_e_a and (not grant_e_a or a_stall_in)) or
             (grant_e_a_r and a_stall_in and grant_e_a);
  stall_s <= (req_s_e and (not grant_s_e or e_stall_in)) or
             (grant_s_e_r and e_stall_in and grant_s_e) or
             (req_s_n and (not grant_s_n or n_stall_in)) or
             (grant_s_n_r and n_stall_in and grant_s_n) or
             (req_s_w and (not grant_s_w or w_stall_in)) or
             (grant_s_w_r and w_stall_in and grant_s_w) or
             (req_s_a and (not grant_s_a or a_stall_in)) or
             (grant_s_a_r and a_stall_in and grant_s_a);
  stall_w <= (req_w_e and (not grant_w_e or e_stall_in)) or
             (grant_w_e_r and e_stall_in and grant_w_e) or
             (req_w_a and (not grant_w_a or a_stall_in)) or
             (grant_w_a_r and a_stall_in and grant_w_a);
  stall_a <= (req_a_n and (not grant_a_n or n_stall_in)) or
             (grant_a_n_r and n_stall_in and grant_a_n) or
             (req_a_e and (not grant_a_e or e_stall_in)) or
             (grant_a_e_r and e_stall_in and grant_a_e) or
             (req_a_s and (not grant_a_s or s_stall_in)) or
             (grant_a_s_r and s_stall_in and grant_a_s) or
             (req_a_w and (not grant_a_w or w_stall_in)) or
             (grant_a_w_r and w_stall_in and grant_a_w);



  -----------------------------------------------------------------------------
  -- SYNCHRONOUS SIGNALS
  -----------------------------------------------------------------------------

  regs_p : process (clk, rst_n) is
  begin  -- process regs_p
    if rst_n = '0' then                 -- asynchronous reset (active low)

      n_stall_out_r <= '0';
      n_da_out_r    <= '0';
      n_av_out_r    <= '0';
      e_stall_out_r <= '0';
      e_da_out_r    <= '0';
      e_av_out_r    <= '0';
      s_stall_out_r <= '0';
      s_da_out_r    <= '0';
      s_av_out_r    <= '0';
      w_stall_out_r <= '0';
      w_da_out_r    <= '0';
      w_av_out_r    <= '0';
      a_stall_out_r <= '0';
      a_da_out_r    <= '0';
      a_av_out_r    <= '0';

      n_data_out_r <= (others => '0');
      e_data_out_r <= (others => '0');
      s_data_out_r <= (others => '0');
      w_data_out_r <= (others => '0');
      a_data_out_r <= (others => '0');

      n_data_in_r <= (others => '0');
      n_av_in_r   <= '0';
      n_da_in_r   <= '0';
      e_data_in_r <= (others => '0');
      e_av_in_r   <= '0';
      e_da_in_r   <= '0';
      s_data_in_r <= (others => '0');
      s_av_in_r   <= '0';
      s_da_in_r   <= '0';
      w_data_in_r <= (others => '0');
      w_av_in_r   <= '0';
      w_da_in_r   <= '0';
      a_data_in_r <= (others => '0');
      a_av_in_r   <= '0';
      a_da_in_r   <= '0';

      reroute_n_r <= '0';
      reroute_e_r <= '0';
      reroute_s_r <= '0';
      reroute_w_r <= '0';

      grant_s_n_r <= '0';
      grant_a_n_r <= '0';
      grant_n_e_r <= '0';
      grant_s_e_r <= '0';
      grant_w_e_r <= '0';
      grant_a_e_r <= '0';
      grant_n_s_r <= '0';
      grant_a_s_r <= '0';
      grant_n_w_r <= '0';
      grant_e_w_r <= '0';
      grant_s_w_r <= '0';
      grant_a_w_r <= '0';
      grant_n_a_r <= '0';
      grant_e_a_r <= '0';
      grant_s_a_r <= '0';
      grant_w_a_r <= '0';

      add_ar_r <= (others => '0');
      add_ac_r <= (others => '0');
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      n_stall_out_r <= stall_n;
      e_stall_out_r <= stall_e;
      s_stall_out_r <= stall_s;
      w_stall_out_r <= stall_w;
      a_stall_out_r <= stall_a;

      grant_s_n_r <= grant_s_n;
      grant_a_n_r <= grant_a_n;
      grant_n_e_r <= grant_n_e;
      grant_s_e_r <= grant_s_e;
      grant_w_e_r <= grant_w_e;
      grant_a_e_r <= grant_a_e;
      grant_n_s_r <= grant_n_s;
      grant_a_s_r <= grant_a_s;
      grant_n_w_r <= grant_n_w;
      grant_e_w_r <= grant_e_w;
      grant_s_w_r <= grant_s_w;
      grant_a_w_r <= grant_a_w;
      grant_n_a_r <= grant_n_a;
      grant_e_a_r <= grant_e_a;
      grant_s_a_r <= grant_s_a;
      grant_w_a_r <= grant_w_a;

      if a_av_in = '1' then
        add_ar_r <= a_data_in(r_addr_width_c-1 downto 0);
        add_ac_r <= a_data_in(c_addr_width_c+r_addr_width_c-1 downto
                              r_addr_width_c);
      end if;

      if stall_n = '1' and n_stall_out_r = '0' then
        n_data_in_r <= data_n;
        n_da_in_r   <= n_da_in;
        n_av_in_r   <= n_av_in;
        reroute_n_r <= reroute_n;
      elsif stall_n = '0' and n_stall_out_r = '1' then
        n_data_in_r <= (others => '0');
        n_da_in_r   <= '0';
        n_av_in_r   <= '0';
        reroute_n_r <= '0';
      end if;

      if stall_e = '1' and e_stall_out_r = '0' then
        e_data_in_r <= data_e;
        e_da_in_r   <= e_da_in;
        e_av_in_r   <= e_av_in;
        reroute_e_r <= reroute_e;
      elsif stall_e = '0' and e_stall_out_r = '1' then
        e_data_in_r <= (others => '0');
        e_da_in_r   <= '0';
        e_av_in_r   <= '0';
        reroute_e_r <= '0';
      end if;

      if stall_s = '1' and s_stall_out_r = '0' then
        s_data_in_r <= data_s;
        s_da_in_r   <= s_da_in;
        s_av_in_r   <= s_av_in;
        reroute_s_r <= reroute_s;
      elsif stall_s = '0' and s_stall_out_r = '1' then
        s_data_in_r <= (others => '0');
        s_da_in_r   <= '0';
        s_av_in_r   <= '0';
        reroute_s_r <= '0';
      end if;

      if stall_w = '1' and w_stall_out_r = '0' then
        w_data_in_r <= data_w;
        w_da_in_r   <= w_da_in;
        w_av_in_r   <= w_av_in;
        reroute_w_r <= reroute_w;
      elsif stall_w = '0' and w_stall_out_r = '1' then
        w_data_in_r <= (others => '0');
        w_da_in_r   <= '0';
        w_av_in_r   <= '0';
        reroute_w_r <= '0';
      end if;

      if stall_a = '1' and a_stall_out_r = '0' then
        a_data_in_r <= data_a;
        a_da_in_r   <= a_da_in;
        a_av_in_r   <= a_av_in;
      elsif stall_a = '0' and a_stall_out_r = '1' then
        a_data_in_r <= (others => '0');
        a_da_in_r   <= '0';
        a_av_in_r   <= '0';
      end if;

      if e_stall_in = '1' then

      elsif grant_n_e = '1' and e_stall_in = '0' and n_stall_out_r = '0' then
        e_data_out_r <= data_n;
        e_da_out_r   <= n_da_in;
        e_av_out_r   <= n_av_in;
      elsif grant_n_e = '1' and e_stall_in = '0' and n_stall_out_r = '1' then
        e_data_out_r <= n_data_in_r;
        e_da_out_r   <= n_da_in_r;
        e_av_out_r   <= n_av_in_r;
      elsif grant_s_e = '1' and e_stall_in = '0' and s_stall_out_r = '0' then
        e_data_out_r <= data_s;
        e_da_out_r   <= s_da_in;
        e_av_out_r   <= s_av_in;
      elsif grant_s_e = '1' and e_stall_in = '0' and s_stall_out_r = '1' then
        e_data_out_r <= s_data_in_r;
        e_da_out_r   <= s_da_in_r;
        e_av_out_r   <= s_av_in_r;
      elsif grant_w_e = '1' and e_stall_in = '0' and w_stall_out_r = '0' then
        e_data_out_r <= data_w;
        e_da_out_r   <= w_da_in;
        e_av_out_r   <= w_av_in;
      elsif grant_w_e = '1' and e_stall_in = '0' and w_stall_out_r = '1' then
        e_data_out_r <= w_data_in_r;
        e_da_out_r   <= w_da_in_r;
        e_av_out_r   <= w_av_in_r;
      elsif grant_a_e = '1' and e_stall_in = '0' and a_stall_out_r = '0' then
        e_data_out_r <= data_a;
        e_da_out_r   <= a_da_in;
        e_av_out_r   <= a_av_in;
      elsif grant_a_e = '1' and e_stall_in = '0' and a_stall_out_r = '1' then
        e_data_out_r <= a_data_in_r;
        e_da_out_r   <= a_da_in_r;
        e_av_out_r   <= a_av_in_r;
      elsif grant_n_e = '0' and grant_s_e = '0'
        and grant_w_e = '0' and grant_a_e = '0' then
        e_data_out_r <= (others => '0');
        e_da_out_r   <= '0';
        e_av_out_r   <= '0';
      end if;

      if s_stall_in = '1' then

      elsif grant_n_s = '1' and s_stall_in = '0' and n_stall_out_r = '0' then
        s_data_out_r <= data_n;
        s_da_out_r   <= n_da_in;
        s_av_out_r   <= n_av_in;
      elsif grant_n_s = '1' and s_stall_in = '0' and n_stall_out_r = '1' then
        s_data_out_r <= n_data_in_r;
        s_da_out_r   <= n_da_in_r;
        s_av_out_r   <= n_av_in_r;
      elsif grant_a_s = '1' and s_stall_in = '0' and a_stall_out_r = '0' then
        s_data_out_r <= data_a;
        s_da_out_r   <= a_da_in;
        s_av_out_r   <= a_av_in;
      elsif grant_a_s = '1' and s_stall_in = '0' and a_stall_out_r = '1' then
        s_data_out_r <= a_data_in_r;
        s_da_out_r   <= a_da_in_r;
        s_av_out_r   <= a_av_in_r;
      elsif grant_n_s = '0' and grant_a_s = '0' then
        s_data_out_r <= (others => '0');
        s_da_out_r   <= '0';
        s_av_out_r   <= '0';
      end if;

      if w_stall_in = '1' then

      elsif grant_n_w = '1' and w_stall_in = '0' and n_stall_out_r = '0' then
        w_data_out_r <= data_n;
        w_da_out_r   <= n_da_in;
        w_av_out_r   <= n_av_in;
      elsif grant_n_w = '1' and w_stall_in = '0' and n_stall_out_r = '1' then
        w_data_out_r <= n_data_in_r;
        w_da_out_r   <= n_da_in_r;
        w_av_out_r   <= n_av_in_r;
      elsif grant_s_w = '1' and w_stall_in = '0' and s_stall_out_r = '0' then
        w_data_out_r <= data_s;
        w_da_out_r   <= s_da_in;
        w_av_out_r   <= s_av_in;
      elsif grant_s_w = '1' and w_stall_in = '0' and s_stall_out_r = '1' then
        w_data_out_r <= s_data_in_r;
        w_da_out_r   <= s_da_in_r;
        w_av_out_r   <= s_av_in_r;
      elsif grant_e_w = '1' and w_stall_in = '0' and e_stall_out_r = '0' then
        w_data_out_r <= data_e;
        w_da_out_r   <= e_da_in;
        w_av_out_r   <= e_av_in;
      elsif grant_e_w = '1' and w_stall_in = '0' and e_stall_out_r = '1' then
        w_data_out_r <= e_data_in_r;
        w_da_out_r   <= e_da_in_r;
        w_av_out_r   <= e_av_in_r;
      elsif grant_a_w = '1' and w_stall_in = '0' and a_stall_out_r = '0' then
        w_data_out_r <= data_a;
        w_da_out_r   <= a_da_in;
        w_av_out_r   <= a_av_in;
      elsif grant_a_w = '1' and w_stall_in = '0' and a_stall_out_r = '1' then
        w_data_out_r <= a_data_in_r;
        w_da_out_r   <= a_da_in_r;
        w_av_out_r   <= a_av_in_r;
      elsif grant_n_w = '0' and grant_e_w = '0'
        and grant_s_w = '0' and grant_a_w = '0' then
        w_data_out_r <= (others => '0');
        w_da_out_r   <= '0';
        w_av_out_r   <= '0';
      end if;

      
      if n_stall_in = '1' then

      elsif grant_s_n = '1' and n_stall_in = '0' and s_stall_out_r = '0' then
        n_data_out_r <= data_s;
        n_da_out_r   <= s_da_in;
        n_av_out_r   <= s_av_in;
      elsif grant_s_n = '1' and n_stall_in = '0' and s_stall_out_r = '1' then
        n_data_out_r <= s_data_in_r;
        n_da_out_r   <= s_da_in_r;
        n_av_out_r   <= s_av_in_r;
      elsif grant_a_n = '1' and n_stall_in = '0' and a_stall_out_r = '0' then
        n_data_out_r <= data_a;
        n_da_out_r   <= a_da_in;
        n_av_out_r   <= a_av_in;
      elsif grant_a_n = '1' and n_stall_in = '0' and a_stall_out_r = '1' then
        n_data_out_r <= a_data_in_r;
        n_da_out_r   <= a_da_in_r;
        n_av_out_r   <= a_av_in_r;
      elsif grant_s_n = '0' and grant_a_n = '0' then
        n_data_out_r <= (others => '0');
        n_da_out_r   <= '0';
        n_av_out_r   <= '0';
      end if;

      if a_stall_in = '1' then

      elsif grant_n_a = '1' and a_stall_in = '0' and n_stall_out_r = '0' then
        a_data_out_r <= data_n;
        a_da_out_r   <= n_da_in;
        a_av_out_r   <= n_av_in;
      elsif grant_n_a = '1' and a_stall_in = '0' and n_stall_out_r = '1' then
        a_data_out_r <= n_data_in_r;
        a_da_out_r   <= n_da_in_r;
        a_av_out_r   <= n_av_in_r;
      elsif grant_s_a = '1' and a_stall_in = '0' and s_stall_out_r = '0' then
        a_data_out_r <= data_s;
        a_da_out_r   <= s_da_in;
        a_av_out_r   <= s_av_in;
      elsif grant_s_a = '1' and a_stall_in = '0' and s_stall_out_r = '1' then
        a_data_out_r <= s_data_in_r;
        a_da_out_r   <= s_da_in_r;
        a_av_out_r   <= s_av_in_r;
      elsif grant_e_a = '1' and a_stall_in = '0' and e_stall_out_r = '0' then
        a_data_out_r <= data_e;
        a_da_out_r   <= e_da_in;
        a_av_out_r   <= e_av_in;
      elsif grant_e_a = '1' and a_stall_in = '0' and e_stall_out_r = '1' then
        a_data_out_r <= e_data_in_r;
        a_da_out_r   <= e_da_in_r;
        a_av_out_r   <= e_av_in_r;
      elsif grant_w_a = '1' and a_stall_in = '0' and w_stall_out_r = '0' then
        a_data_out_r <= data_w;
        a_da_out_r   <= w_da_in;
        a_av_out_r   <= w_av_in;
      elsif grant_w_a = '1' and a_stall_in = '0' and w_stall_out_r = '1' then
        a_data_out_r <= w_data_in_r;
        a_da_out_r   <= w_da_in_r;
        a_av_out_r   <= w_av_in_r;
      elsif grant_n_a = '0' and grant_e_a = '0'
        and grant_s_a = '0' and grant_w_a = '0' then
        a_data_out_r <= (others => '0');
        a_da_out_r   <= '0';
        a_av_out_r   <= '0';
      end if;
      
    end if;
  end process regs_p;


end architecture rtl;
