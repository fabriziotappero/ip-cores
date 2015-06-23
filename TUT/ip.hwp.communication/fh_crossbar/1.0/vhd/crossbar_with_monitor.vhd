-----------------------------------------------------------------
-- file         : crossbar.vhdl/ crossbar_with_monitor.vhdl
-- Description  : Top level of crossbar. Includes io_block with
--                fifos, arbiter and switch matrix.
-- 
-- Designer     : Erno salminen 19.06.2003
-- last modified
-- Antti Alhonen 09.07.2009 - added monitoring.
-- THIS DOES NOT USE PACKETS!
-----------------------------------------------------------------
-------------------------------------------------------------------------------
-- Copyright (c) 2011 Tampere University of Technology
-------------------------------------------------------------------------------
--  This file is part of Transaction Generator.
--
--  Transaction Generator is free software: you can redistribute it and/or
--  modify it under the terms of the Lesser GNU General Public License as
--  published by the Free Software Foundation, either version 3 of the License,
--  or (at your option) any later version.
--
--  Transaction Generator is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  Lesser GNU General Public License for more details.
--
--  You should have received a copy of the Lesser GNU General Public License
--  along with Transaction Generator.  If not, see
--  <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.mon_pkg.all;

entity crossbar_with_monitor is
  generic (
    n_ag_g          :    integer;
    data_width_g    :    integer;
    pkt_switch_en_g :    integer := 0;  --14.10.06 es
    stfwd_en_g      :    integer := 0;  --14.10.06 es
    max_send_g      :    integer := 9;  -- 0=no limit
    net_freq_g      :    integer := 1;  -- relative crossbar freq
    lut_en_g        :    integer := 1;  -- 19.10.2006 ES
    ip_freq_g       :    integer := 1;  -- relative IP freq
    fifo_depth_g    :    integer;
    sim_dbg_en_g    :    integer := 0;
    dbg_en_g        :    integer := 0;
    dbg_width_g     :    integer
    );
  port (
    rst_n           : in std_logic;
    clk_net         : in std_logic;
    clk_ip          : in std_logic;

    tx_av_in     : in  std_logic_vector (n_ag_g - 1 downto 0);
    tx_data_in   : in  std_logic_vector (n_ag_g * data_width_g - 1 downto 0);
    tx_we_in     : in  std_logic_vector (n_ag_g - 1 downto 0);
    tx_full_out  : out std_logic_vector (n_ag_g - 1 downto 0);
    tx_empty_out : out std_logic_vector (n_ag_g - 1 downto 0);

    rx_av_out    : out std_logic_vector (n_ag_g - 1 downto 0);
    rx_data_out  : out std_logic_vector (n_ag_g * data_width_g - 1 downto 0);
    rx_empty_out : out std_logic_vector (n_ag_g - 1 downto 0);
    rx_full_out  : out std_logic_vector (n_ag_g - 1 downto 0);
    rx_re_in     : in  std_logic_vector (n_ag_g - 1 downto 0);

    dbg_out      : out std_logic_vector (dbg_width_g - 1 downto 0);

    -- MONITOR SIGNALS (AA)
    mon_UART_rx_in  : in  std_logic;
    mon_UART_tx_out : out std_logic;
    mon_command_in  :  in std_logic_vector(mon_command_width_c-1 downto 0)    
    );
end crossbar_with_monitor;

architecture top_level of crossbar_with_monitor is


  function log2(input : integer)
    return integer is
  begin
    for i in 1 to 100 loop
      if (2**i >= input) then
        return(i);
      end if;
    end loop;  -- i
    return 100;
  end log2;

  -- addresses are from 0 to n_ag - 1
  --constant addr_width_c : integer := log2(n_ag_g);
  constant addr_width_c : integer := data_width_g;

  -- switch addresses are from 1 to n_ag, value n_ag= illegal
  constant switch_addr_width_c : integer := log2(n_ag_g + 1);

  component io_block
    generic (
      data_width_g    :    integer;
      fifo_depth_g    :    integer;
      addr_width_g    :    integer;
      pkt_switch_en_g :    integer := 0;  --14.10.06 es
      stfwd_en_g      :    integer := 0;  --14.10.06 es
      max_send_g      :    integer := 9;  -- 0=no limit
      net_freq_g      :    integer;
      sim_dbg_en_g    :    integer;
      ip_freq_g       :    integer
      );
    port (
      clk_net         : in std_logic;
      clk_ip          : in std_logic;
      rst_n           : in std_logic;

      -- Signals from agent
      ip_av_in        : in  std_logic;    -- 15.09.2006 
      ip_data_in      : in  std_logic_vector (data_width_g-1 downto 0);
      ip_we_in        : in  std_logic;
      ip_tx_full_out  : out std_logic;
      ip_tx_empty_out : out std_logic;

      -- Signals to bus and arbiter
      net_av_out       : out std_logic;
      net_flit_out     : out std_logic_vector (data_width_g-1 downto 0);
      net_we_out   : out std_logic;
      net_req_addr_out : out std_logic_vector (addr_width_g  -1 downto 0);
      net_req_out      : out std_logic;
      net_hold_out     : out std_logic;
      net_grant_in     : in  std_logic;
      net_full_in      : in  std_logic;

      -- Signals from bus and arbiter
      net_av_in     : in  std_logic;
      net_data_in   : in  std_logic_vector (data_width_g -1 downto 0);
      net_we_in     : in  std_logic;
      net_full_out  : out std_logic;
      net_empty_out : out std_logic;

      -- Signals to agent
      ip_av_out       : out std_logic;    -- 15.09.2006 
      ip_data_out     : out std_logic_vector (data_width_g -1 downto 0);
      ip_re_in        : in  std_logic;
      ip_rx_full_out  : out std_logic;
      ip_rx_empty_out : out std_logic
      );
  end component;

  component addr_lut
    generic (
      in_addr_w_g  : integer := 32;
      out_addr_w_g : integer := 36;
      cmp_high_g   : integer := 31;
      cmp_low_g    : integer := 0;
      net_type_g   : integer := 0;
      lut_en_g     : integer := 1         -- if disabled, out <= in
      );
    port (
      addr_in  : in  std_logic_vector (in_addr_w_g-1 downto 0);
      addr_out : out std_logic_vector (out_addr_w_g-1 downto 0)
      );
  end component; --addr_lut;

  
  component allocator
    generic (
      n_ag_g              :     integer;
      addr_width_g        :     integer;
      switch_addr_width_g :     integer
      );
    port(
      clk                 : in  std_logic;
      rst_n               : in  std_logic;
      req_addr_in         : in  std_logic_vector (n_ag_g * addr_width_g - 1 downto 0);
      req_in              : in  std_logic_vector (n_ag_g - 1 downto 0);
      hold_in             : in  std_logic_vector (n_ag_g - 1 downto 0);
      grant_out           : out std_logic_vector (n_ag_g - 1 downto 0);
      src_id_out          : out std_logic_vector (n_ag_g * switch_addr_width_g - 1 downto 0)
      );
  end component;

  component switch_matrix
    generic (
      n_ag_g       :     integer;
      data_width_g :     integer;
      addr_width_g :     integer
      );
    port (
      av_in        : in  std_logic_vector (n_ag_g - 1 downto 0);
      data_in      : in  std_logic_vector (n_ag_g * data_width_g - 1 downto 0);
      we_in        : in  std_logic_vector (n_ag_g-1 downto 0);
      we_out       : out std_logic_vector (n_ag_g-1 downto 0);
      av_out       : out std_logic_vector (n_ag_g - 1 downto 0);
      data_out     : out std_logic_vector (n_ag_g * data_width_g - 1 downto 0);
      src_id_in    : in  std_logic_vector (n_ag_g * addr_width_g - 1 downto 0);
      full_in      : in  std_logic_vector (n_ag_g - 1 downto 0);
      full_out     : out std_logic_vector (n_ag_g - 1 downto 0)
      );
  end component;  --switch_matrix;

  component monitor_top_xbar
    generic (
      num_of_links_g : integer);
    port (
      holds_in       : in  std_logic_vector(num_of_links_g-1 downto 0);
      grants_in      : in  std_logic_vector(num_of_links_g-1 downto 0);
      reqs_in        : in  std_logic_vector(num_of_links_g-1 downto 0);
      uart_rx_in     : in  std_logic;
      uart_tx_out    : out std_logic;
      clk            : in  std_logic;
      rst_n          : in  std_logic;
      mon_command_in : in  std_logic_vector(mon_command_width_c-1 downto 0));
  end component;



  type net_flit_type is array (n_ag_g - 1 downto 0) of std_logic_vector (data_width_g -1 downto 0);
  signal net_flit   : net_flit_type;


  -- Arbiter signals
  signal empty_io_arb      : std_logic_vector (n_ag_g-1 downto 0);
  signal grant_arb_io      : std_logic_vector (n_ag_g-1 downto 0);
  signal req_io_arb        : std_logic_vector (n_ag_g-1 downto 0);
  signal hold_io_arb       : std_logic_vector (n_ag_g - 1 downto 0);
  signal ctrl_arb_switches : std_logic_vector (n_ag_g * switch_addr_width_c - 1 downto 0);

  --signal req_addr_io_arb   : std_logic_vector (n_ag_g * addr_width_c - 1 downto 0);
  signal req_addr_io_lut  : std_logic_vector (n_ag_g * addr_width_c - 1 downto 0);
  signal req_addr_lut_arb : std_logic_vector (n_ag_g * switch_addr_width_c - 1 downto 0);


  
  -- IO <-> Switch matrix
  signal av_io_xbar   : std_logic_vector (n_ag_g-1 downto 0);
  signal data_io_xbar : std_logic_vector (n_ag_g * data_width_g - 1 downto 0);
  signal we_io_xbar   : std_logic_vector (n_ag_g-1 downto 0);
  signal full_xbar_io : std_logic_vector (n_ag_g - 1 downto 0);

  signal av_xbar_io   : std_logic_vector (n_ag_g-1 downto 0);
  signal data_xbar_io : std_logic_vector (n_ag_g * data_width_g - 1 downto 0);
  signal we_xbar_io   : std_logic_vector (n_ag_g-1 downto 0);
  signal full_io_xbar : std_logic_vector (n_ag_g - 1 downto 0);

  -- IO -> IP, 28.07
  signal rx_data_from_io  : std_logic_vector (n_ag_g * data_width_g - 1 downto 0);
  signal rx_empty_from_io : std_logic_vector (n_ag_g - 1 downto 0);


  -- Array signals for debugging and visualization
  type net_addr_type is array (n_ag_g - 1 downto 0) of std_logic_vector (addr_width_c-1 downto 0);
  type swi_addr_type is array (n_ag_g - 1 downto 0) of std_logic_vector (switch_addr_width_c-1 downto 0);
  signal req_addr_io_lut_dbg : net_addr_type;
  signal req_addr_arr_dbg : swi_addr_type;
  signal ctrl_arr_dbg     : swi_addr_type;
  signal data_arr_dbg     : net_flit_type;

begin


  debug: if dbg_en_g = 1 generate
      dbg_out <= we_io_xbar and not(full_xbar_io);
  end generate debug;

  gen_net_pkt : for i in 0 to n_ag_g - 1 generate
    data_io_xbar ((i+1)*data_width_g - 1 downto i*data_width_g) <= net_flit(i)(data_width_g - 1 downto 0);

    -- Debug
    req_addr_io_lut_dbg (i) <= req_addr_io_lut ((i+1)*addr_width_c -1 downto i*addr_width_c);
    req_addr_arr_dbg (i)    <= req_addr_lut_arb ((i+1)*switch_addr_width_c -1 downto i*switch_addr_width_c);
    ctrl_arr_dbg (i)        <= ctrl_arb_switches ((i+1)*switch_addr_width_c -1 downto i*switch_addr_width_c);
    data_arr_dbg (i)        <= net_flit (i) (data_width_g-1 downto 0);
  end generate gen_net_pkt;


  -- SWITCH MATRIX
  swi_mtrx : switch_matrix
    generic map (
      n_ag_g       => n_ag_g,
      data_width_g => data_width_g,
      addr_width_g => switch_addr_width_c
      )
    port map(
      av_in        => av_io_xbar,
      data_in      => data_io_xbar,
      we_in        => we_io_xbar,
      full_out     => full_xbar_io,
      av_out       => av_xbar_io,
      data_out     => data_xbar_io,
      we_out       => we_xbar_io,
      src_id_in    => ctrl_arb_switches,
      full_in      => full_io_xbar
      );

  -- IO BLOCKS
  map_io_blocks : for i in 0 to n_ag_g-1 generate
    Blocki      : io_block
      generic map (
        data_width_g    => data_width_g,
        fifo_depth_g    => fifo_depth_g,
        addr_width_g    => addr_width_c,
        pkt_switch_en_g => pkt_switch_en_g,  --14.10.06 
        stfwd_en_g      => stfwd_en_g,       --14.10.06 es
        max_send_g      => max_send_g,       -- 0=no limit
        net_freq_g      => net_freq_g,
        sim_dbg_en_g    => sim_dbg_en_g,
        ip_freq_g       => ip_freq_g
        )
      port map (
        clk_net         => clk_net,
        clk_ip          => clk_ip,
        rst_n           => rst_n,

        ip_av_in        => tx_av_in     (i),
        ip_data_in      => tx_data_in  ((i+1)*data_width_g - 1 downto i*data_width_g),
        ip_we_in        => tx_we_in     (i),
        ip_tx_full_out  => tx_full_out  (i),
        ip_tx_empty_out => tx_empty_out (i),

        net_av_out       => av_io_xbar      (i),
        net_flit_out     => net_flit        (i),
        net_we_out       => we_io_xbar      (i),
        net_req_addr_out => req_addr_io_lut ((i+1) * addr_width_c - 1 downto i * addr_width_c),
        net_req_out      => req_io_arb      (i),
        net_hold_out     => hold_io_arb     (i),
        net_grant_in     => grant_arb_io    (i),
        net_full_in      => full_xbar_io    (i), 

        net_av_in     => av_xbar_io    (i),
        net_data_in   => data_xbar_io ((i+1)*data_width_g - 1 downto i*data_width_g),  --(i),
        net_we_in     => we_xbar_io    (i),
        net_full_out  => full_io_xbar  (i),
        net_empty_out => empty_io_arb  (i),

        ip_av_out       => rx_av_out     (i),
        ip_data_out     => rx_data_from_io ((i+1)*data_width_g - 1 downto i*data_width_g),
        ip_re_in        => rx_re_in      (i),
        ip_rx_empty_out => rx_empty_from_io (i),
        ip_rx_full_out  => rx_full_out   (i)
        );


    -- Addr_lut is connected between io_block and allocator
    ad_lut_i: addr_lut
      generic map(
        in_addr_w_g  => addr_width_c,
        out_addr_w_g => switch_addr_width_c,
        cmp_high_g   => addr_width_c-1,
        cmp_low_g    => 0,
        net_type_g   => 2, --3, depends on lut type. _lut_example:use 2, lut+pkg:use 3
        lut_en_g     => lut_en_g --1         -- if disabled, out <= in
        )
      port map(
        addr_in  => req_addr_io_lut ((i+1) * addr_width_c - 1 downto i * addr_width_c),
        addr_out => req_addr_lut_arb ((i+1) * switch_addr_width_c - 1 downto i * switch_addr_width_c)
        );    
  end generate map_io_blocks;


  -- Allocator controls the switch
  alc : allocator
    generic map (
      n_ag_g              => n_ag_g,
      --addr_width_g        => addr_width_c,
      addr_width_g        => switch_addr_width_c,
      switch_addr_width_g => switch_addr_width_c
      )
    port map (
      clk                 => clk_net,
      rst_n               => rst_n,
      req_addr_in         => req_addr_lut_arb,
      req_in              => req_io_arb,
      hold_in             => hold_io_arb,
      grant_out           => grant_arb_io,
      src_id_out          => ctrl_arb_switches
      );

  -- 28.07
  visualize_rx_data : process (rx_data_from_io, rx_empty_from_io)
  begin  -- process visualize_rx_data
    for a in 0 to n_ag_g-1 loop

      -- Simple "others => '0'" causes problems with design_compiler
      if sim_dbg_en_g = 0 then
        -- This if-clause added 04.12.2006 es
        rx_data_out ((a+1)*data_width_g - 1 downto a*data_width_g) <= rx_data_from_io ((a+1)*data_width_g - 1 downto a*data_width_g);
      else
        -- 04.12.06 this was orig. code, "others" casues problems with design_compiler
        if rx_empty_from_io (a) = '0' then  -- Paketti tulossa
          rx_data_out ((a+1)*data_width_g - 1 downto a*data_width_g) <= rx_data_from_io ((a+1)*data_width_g - 1 downto a*data_width_g);
        else
          rx_data_out ((a+1)*data_width_g - 1 downto a*data_width_g) <= (others => '0');
        end if;

      end if;
      
    end loop;  -- a
      
    

    rx_empty_out <= rx_empty_from_io;
  end process visualize_rx_data;

  -----------------------------------------------------------------------------
  -- MONITOR
  -----------------------------------------------------------------------------
  monitor: monitor_top_xbar
    generic map (
        num_of_links_g => n_ag_g)
    port map (
        holds_in       => hold_io_arb,  -- allocator's hold_in
        grants_in      => grant_arb_io, -- allocator's grant_out
        reqs_in        => req_io_arb,   -- allocator's req_in
        uart_rx_in     => mon_UART_rx_in,
        uart_tx_out    => mon_UART_tx_out,
        clk            => clk_net,
        rst_n          => rst_n,
        mon_command_in => mon_command_in);
  
end top_level;
