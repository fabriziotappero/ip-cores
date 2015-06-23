-------------------------------------------------------------------------------
-- File        : ring_router.vhdl
-- Description : Routes packets in Ring network.
--               Four io channels,
--                 i.e. two to neighbor routers, one for opposite neighbor
--                 and one for processing element.
--
--               Neighbor connections have identifiers: fwd, rev, and diag
--               referring to direction in ring
--               
--               All output channels have one fifo buffer.
--               Routers are identified with three-part address
--                two-part ring id (direction and distance from center ring)
--                router id within the ring
--
--               Size of packet (including address) is the same as fifo_depth_g
--
--               
-- Author      : Jussi Nieminen after Erno Salminen's Octagon router
-- Date        : 10.04.2006
-- Modified    : 12.02.2009     JN      Forked from the Octagon router.

-------------------------------------------------------------------------------

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
use ieee.std_logic_unsigned.all;


entity ring_router is

  generic (
    nbr_of_routers_g   : integer := 8;
    data_width_g       : integer := 0;
    dateline_en_g      : integer := 0;
    stfwd_en_g         : integer := 1;
    pkt_len_g          : integer;
    len_flit_en_g      : integer := 0;
    oaddr_flit_en_g    : integer := 0;
    fifo_depth_g       : integer;
    router_id_g        : integer := 0;
    diag_en_g          : integer := 1;
    net_freq_g         : integer;
    ip_freq_g          : integer;
    sim_dbg_ena_g      : integer := 0
    );
  port (
    clk_net : in std_logic;
    clk_ip  : in std_logic;
    rst_n   : in std_logic;

    data_fwd_in  : in  std_logic_vector (data_width_g-1 downto 0);
    re_fwd_out   : out std_logic;
    empty_fwd_in : in  std_logic;
    full_fwd_in  : in  std_logic;

    data_rev_in  : in  std_logic_vector (data_width_g-1 downto 0);
    re_rev_out   : out std_logic;
    empty_rev_in : in  std_logic;
    full_rev_in  : in  std_logic;

    -- diag ports enabled with generic
    data_diag_in  : in  std_logic_vector (data_width_g-1 downto 0);
    re_diag_out   : out std_logic;
    empty_diag_in : in  std_logic;
    full_diag_in  : in  std_logic;

    data_ip_tx_in   : in  std_logic_vector (data_width_g-1 downto 0);
    we_ip_tx_in     : in  std_logic;
    empty_ip_tx_out : out std_logic;
    full_ip_tx_out  : out std_logic;

    data_fwd_out  : out std_logic_vector (data_width_g-1 downto 0);
    re_fwd_in     : in  std_logic;
    empty_fwd_out : out std_logic;
    full_fwd_out  : out std_logic;

    data_rev_out  : out std_logic_vector (data_width_g-1 downto 0);
    re_rev_in     : in  std_logic;
    empty_rev_out : out std_logic;
    full_rev_out  : out std_logic;

    -- diag ports enabled with generic
    data_diag_out  : out std_logic_vector (data_width_g-1 downto 0);
    re_diag_in     : in  std_logic;
    empty_diag_out : out std_logic;
    full_diag_out  : out std_logic;

    data_ip_rx_out  : out std_logic_vector (data_width_g-1 downto 0);
    re_ip_rx_in     : in  std_logic;
    full_ip_rx_out  : out std_logic;
    empty_ip_rx_out : out std_logic
    );

end ring_router;



architecture rtl of ring_router is


  -- Set dbg_level=0 for synthesis
  constant dbg_level_c : integer range 0 to 3 := 0;

  type dbg_value_arr is array (0 to 1) of std_logic;
  constant dbg_value_c : dbg_value_arr := ('0', 'Z');


  -- this should be made generic later..?
  constant addr_width_c : integer := 15;

  -- There are always at least 3 bidir ports: IP, clockwise, counterclkwise
  -- Possibly also; diagonal port
  constant n_ports_c  : integer range 0 to 5 := 3 + diag_en_g;
  signal n_ports_dbgr : integer              := n_ports_c;

  -- Constants for accessing arrays (e.g. state_regs)
  constant ip_c     : integer := 0;
  constant fwd_c    : integer := 1;
  constant rev_c    : integer := 2;
  constant diag_c   : integer := 3;
  constant no_dir_c : integer := n_ports_c;           -- Illegal index

  component multiclk_fifo
    generic (
      re_freq_g    : integer;
      we_freq_g    : integer;
      depth_g      : integer;
      data_width_g : integer);
    port (
      clk_re    : in  std_logic;
      clk_we    : in  std_logic;
      rst_n     : in  std_logic;
      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      we_in     : in  std_logic;
      full_out  : out std_logic;
      one_p_out : out std_logic;
      re_in     : in  std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      empty_out : out std_logic;
      one_d_out : out std_logic);
  end component;

  component fifo
    generic (
      data_width_g : integer := 0;
      depth_g      : integer := 0);
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      we_in     : in  std_logic;
      one_p_out : out std_logic;
      full_out  : out std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      re_in     : in  std_logic;
      empty_out : out std_logic;
      one_d_out : out std_logic
      );
  end component;  --fifo;


  -- Function that decides shortest to reach target within the ring
  function router_func (
    constant dst_addr   : integer;      --std_logic_vector ( 3-1 downto 0);
    constant own_addr   : integer)
    return integer is
    variable rel_addr_v : integer range -nbr_of_routers_g+1 to nbr_of_routers_g;
  begin  -- router_func

    -- address relative to this router, target's distance from
    -- this router when going forward
    -- (e.g. nbr_of_routers - 1 means target is the next router backwards)
    rel_addr_v := (dst_addr - own_addr);
    if rel_addr_v < 0 then
      rel_addr_v := rel_addr_v + nbr_of_routers_g;
    end if;

    if (rel_addr_v = 0) then
      -- right dst
      return ip_c;

    elsif (rel_addr_v <= nbr_of_routers_g / 4) then
      return fwd_c;

    elsif (rel_addr_v >= nbr_of_routers_g - nbr_of_routers_g / 4) then
      return rev_c;

    else
      if diag_en_g = 1 then
        return diag_c;
      elsif rel_addr_v > nbr_of_routers_g / 2 then
        return rev_c;
      else
        return fwd_c;
      end if;
    end if;

  end router_func;



  -- Internal types and signals. Thse are mapped to router's inputs
  -- Arrays are easier to handle than names with direction identification
  -- (e.g. data_arr(i) vs. data_fwd)
  type data_arr_type is array (n_ports_c-1 downto 0) of std_logic_vector (data_width_g-1 downto 0);
  type ctrl_arr_type is array (n_ports_c-1 downto 0) of std_logic;
  type source_type is array (n_ports_c-1 downto 0) of integer range 0 to 5;
  type counter_arr_type is array (n_ports_c-1 downto 0) of integer range 0 to pkt_len_g;  --fifo_depth_g;
  type channel_arr_type is array (n_ports_c-1 downto 0) of integer range 0 to 1;


  signal Incoming_data  : data_arr_type;
  signal Incoming_empty : ctrl_arr_type;
  signal Incoming_full  : ctrl_arr_type;
  signal send_counter_r : counter_arr_type;
  signal pkt_len_arr_r  : counter_arr_type;

  -- From fifos. Mapped directly to outputs pins 
  signal data_from_fifo  : data_arr_type;
  signal full_from_fifo  : ctrl_arr_type;
  signal empty_from_fifo : ctrl_arr_type;  -- this goes also to ctrl

  -- signals to and from fwd and rev fifos
  signal data_from_fwd0 : std_logic_vector( data_width_g - 1 downto 0 );
  signal data_from_fwd1 : std_logic_vector( data_width_g - 1 downto 0 );
  signal data_from_rev0 : std_logic_vector( data_width_g - 1 downto 0 );
  signal data_from_rev1 : std_logic_vector( data_width_g - 1 downto 0 );
  signal full_from_fwd0 : std_logic;
  signal full_from_fwd1 : std_logic;
  signal full_from_rev0 : std_logic;
  signal full_from_rev1 : std_logic;
  signal empty_from_fwd0 : std_logic;
  signal empty_from_fwd1 : std_logic;
  signal empty_from_rev0 : std_logic;
  signal empty_from_rev1 : std_logic;
  signal empty_from_fwd : std_logic;
  signal empty_from_rev : std_logic;
  signal we_fwd0 : std_logic;
  signal we_fwd1 : std_logic;
  signal we_rev0 : std_logic;
  signal we_rev1 : std_logic;
  signal re_fwd0 : std_logic;
  signal re_fwd1 : std_logic;
  signal re_rev0 : std_logic;
  signal re_rev1 : std_logic;

  -- controlling outputs from fwd and rev
  signal fwd_pkt_counter_r : integer;
  signal rev_pkt_counter_r : integer;
  signal fwd_chan_sel_r : std_logic;
  signal rev_chan_sel_r : std_logic;

  signal fwd_pkt_len_r : integer;
  signal rev_pkt_len_r : integer;

  -- From ctrl
  signal data_ctrl_fifo_r : data_arr_type;
  signal we_ctrl_fifo_r   : ctrl_arr_type;
  signal re_r             : ctrl_arr_type;

  -- 2006/10/23 Try wormhole, combinatorial enable signals
  signal re_tmp : ctrl_arr_type;
  signal we_tmp : ctrl_arr_type;

  signal data_reg_valid_r   : ctrl_arr_type;  -- 2006/10/26
  signal data_ctrl_fifo_dbg : data_arr_type;


  -- State registers
  signal State_writing_r : std_logic_vector (n_ports_c-1 downto 0);  -- 0=ip,1=
  signal State_reading_r : std_logic_vector (n_ports_c-1 downto 0);  -- 0=ip,1=

  -- state_src_r(i) tells which port the source for output port i
  signal state_src_r : source_type;     -- 0=ip,1=

  -- state_dst_r(i) tells which port the destination for input port i
  signal state_dst_r : source_type;

  -- state_channel_r(i) tells which channel to use for output i
  signal state_channel_r : channel_arr_type;


  -- Marks which input is checked on current cycle
  --signal curr_src_r : integer range 0 to n_ports_c-1;

  -- Decoded address in input port pointed by curr_src_r, _not_ a register!
  --signal curr_dst : integer range 0 to n_ports_c;
  -- new type 2006/10/23, ES
  type dst_arr_type is array (n_ports_c-1 downto 0) of integer range 0 to n_ports_c;
  signal curr_dst          : dst_arr_type;
  signal curr_dst_resolved : dst_arr_type;
  signal n_req_dbgr        : dst_arr_type;
  signal curr_channel      : channel_arr_type;



  type addr_arr_type is array (n_ports_c-1 downto 0) of integer;

  signal router_addr : addr_arr_type;


  signal start_idx_r : integer range 0 to n_ports_c-1;  -- 28.11 for round-robin resolution

  -- this should be generic...
  constant len_width_c : integer := 8;
  
-----------------------------------------------------------------------------
begin  -- rtl
-----------------------------------------------------------------------------
  

  -- Concurrent assignments
  -- Connect fifo status signals to outputs
  empty_fwd_out   <= empty_from_fwd;
  empty_rev_out   <= empty_from_rev;
  empty_ip_rx_out <= empty_from_fifo (ip_c);  -- from ip_rx_fifo 

  full_fwd_out   <= full_from_fifo (fwd_c);
  full_rev_out   <= full_from_fifo (rev_c);
  full_ip_rx_out <= full_from_fifo (ip_c);  -- from ip_rx_fifo 

  -- Separate arrays signals into outputs
  re_fwd_out <= re_tmp (fwd_c);         -- 2006/10/23 re_r (fwd_c);
  re_rev_out <= re_tmp (rev_c);         -- 2006/10/23 re_r (rev_c);


  -- Collect inputs into array
  Incoming_data (fwd_c) <= data_fwd_in;
  Incoming_data (rev_c) <= data_rev_in;
  -- incoming_data/empty/full (ip_c) comes directly from rx-fifo

  Incoming_empty (fwd_c) <= empty_fwd_in;
  Incoming_empty (rev_c) <= empty_rev_in;
  empty_ip_tx_out        <= Incoming_empty (ip_c);  -- from ip_tx_fifo

  Incoming_full (fwd_c) <= full_fwd_in;
  Incoming_full (rev_c) <= full_rev_in;
  full_ip_tx_out        <= Incoming_full (ip_c);  -- from ip_tx_fifo



  connect_diag_signals : if diag_en_g = 1 generate
    data_diag_out           <= data_from_fifo (diag_c);  -- when (dbg_level_c = 0 or empty_from_fifo (fwd_c) = '0') else (others => 'Z');
    empty_diag_out          <= empty_from_fifo (diag_c);
    full_diag_out           <= full_from_fifo (diag_c);
    re_diag_out             <= re_tmp (diag_c);  -- 2006/10/23 re_r (diag_c);
    Incoming_data (diag_c)  <= data_diag_in;
    Incoming_empty (diag_c) <= empty_diag_in;
    Incoming_full (diag_c)  <= full_diag_in;
  end generate connect_diag_signals;

  not_map_diag_fifo : if diag_en_g = 0 generate
    data_diag_out  <= (others => dbg_value_c(sim_dbg_ena_g));  --(others => 'Z');
    empty_diag_out <= '1';
    full_diag_out  <= '1';
    re_diag_out    <= '0';
  end generate not_map_diag_fifo;



  -- Debug
  -- Easier to trace if outputs are 'Z' when output fifo is empty
  -- (Comment out the "when part" for synthesis
  -- e.g."data_fwd_out <= data_from_fifo (fwd_c);  -- when data_from_fifo and so on")
  -- Done with if-generate, 08.06.2006 es

--   dbg_tristate_off: if dbg_level_c = 0 generate
--     data_fwd_out   <= data_from_fifo (fwd_c);
--     data_rev_out   <= data_from_fifo (rev_c); 
--     data_ip_rx_out <= data_from_fifo (ip_c); 
--   end generate dbg_tristate_off;

--  dbg_tristate_on : if dbg_level_c > 0 generate
  data_fwd_out   <= data_from_fifo (fwd_c);  -- when (dbg_level_c = 0 or empty_from_fifo (fwd_c) = '0') else (others => 'Z');
  data_rev_out   <= data_from_fifo (rev_c);  -- when (dbg_level_c = 0 or empty_from_fifo (fwd_c) = '0') else (others => 'Z');
  data_ip_rx_out <= data_from_fifo (ip_c);  --  when (dbg_level_c = 0 or empty_from_fifo (fwd_c) = '0') else (others => '0');
--  end generate dbg_tristate_on;



  -----------------------------------------------------------------------------
  -- Component mappings
  -----------------------------------------------------------------------------

  -- Fifo data outputs are connected to router's outputs (via intermediate signal, though)

  -- 4 FIFOS are always included to outports
  -- Data going to ip, multiclk
  Ip_fifo_rx : multiclk_fifo
    generic map (
      re_freq_g    => ip_freq_g,
      we_freq_g    => net_freq_g,
      data_width_g => data_width_g,
      depth_g      => fifo_depth_g
      )
    port map (
      clk_re    => clk_ip,
      clk_we    => clk_net,
      rst_n     => rst_n,
      data_in   => data_ctrl_fifo_r (ip_c),
      we_in     => we_tmp (ip_c),
      full_out  => full_from_fifo (ip_c),
      data_out  => data_from_fifo (ip_c),
      re_in     => re_ip_rx_in,            -- router input
      empty_out => empty_from_fifo (ip_c)  --,
      );

  -- Data coming from ip, multiclk
  Ip_fifo_tx : multiclk_fifo
    generic map (
      re_freq_g    => net_freq_g,
      we_freq_g    => ip_freq_g,
      data_width_g => data_width_g,
      depth_g      => fifo_depth_g
      )
    port map (
      clk_re   => clk_net,
      clk_we   => clk_ip,
      rst_n    => rst_n,
      -- Fifo inputs come straight router inputs (=from ip)
      data_in  => data_ip_tx_in,
      full_out => Incoming_full (ip_c),
      we_in    => we_ip_Tx_in,

      -- Fifo outputs go ctrl logic
      data_out  => Incoming_data (ip_c),
      empty_out => Incoming_empty (ip_c),
      re_in     => re_tmp (ip_c)        --re_r (ip_c)
      );


  -- two forward fifos to enable two channels
  fwd_fifo_0 : fifo
    generic map (
      data_width_g => data_width_g,
      depth_g      => fifo_depth_g
      )
    port map (
      clk       => clk_net,
      rst_n     => rst_n,
      data_in   => data_ctrl_fifo_r (fwd_c),
      we_in     => we_fwd0,
      full_out  => full_from_fwd0,
      data_out  => data_from_fwd0,
      re_in     => re_fwd0,           -- router input
      empty_out => empty_from_fwd0
      );

  fwd_fifo_1 : fifo
    generic map (
      data_width_g => data_width_g,
      depth_g      => fifo_depth_g
      )
    port map (
      clk       => clk_net,
      rst_n     => rst_n,
      data_in   => data_ctrl_fifo_r (fwd_c),
      we_in     => we_fwd1,
      full_out  => full_from_fwd1,
      data_out  => data_from_fwd1,
      re_in     => re_fwd1,           -- router input
      empty_out => empty_from_fwd1
      );

  -- two rev fifos
  rev_fifo_0 : fifo
    generic map (
      data_width_g => data_width_g,
      depth_g      => fifo_depth_g
      )
    port map (
      clk       => clk_net,
      rst_n     => rst_n,
      data_in   => data_ctrl_fifo_r (rev_c),
      we_in     => we_rev0,
      full_out  => full_from_rev0,
      data_out  => data_from_rev0,
      re_in     => re_rev0,
      empty_out => empty_from_rev0
      );

  rev_fifo_1 : fifo
    generic map (
      data_width_g => data_width_g,
      depth_g      => fifo_depth_g
      )
    port map (
      clk       => clk_net,
      rst_n     => rst_n,
      data_in   => data_ctrl_fifo_r (rev_c),
      we_in     => we_rev1,
      full_out  => full_from_rev1,
      data_out  => data_from_rev1,
      re_in     => re_rev1,
      empty_out => empty_from_rev1
      );

  -- 2 Optional fifos
  map_diag_fifo : if diag_en_g = 1 generate
    diag_fifo : fifo
      generic map (
        data_width_g => data_width_g,
        depth_g      => fifo_depth_g
        )
      port map (
        clk       => clk_net,
        rst_n     => rst_n,
        data_in   => data_ctrl_fifo_r (diag_c),
        we_in     => we_tmp (diag_c),
        full_out  => full_from_fifo (diag_c),
        data_out  => data_from_fifo (diag_c),
        re_in     => re_diag_in,        -- router input
        empty_out => empty_from_fifo (diag_c)
        );
  end generate map_diag_fifo;


  -----------------------------------------------------------------------------
  read_en_tmp : process (we_ctrl_fifo_r, re_r,
                        data_reg_valid_r,
                        state_src_r, state_dst_r,
                        full_from_fifo,
                        Incoming_empty --,
                        --send_counter_r
                         )

  begin  -- process read_en_tmp
    for i in 0 to n_ports_c-1 loop

      -- i viittaa kohteeseen (fifo)
      if state_src_r (i) = no_dir_c then
        we_tmp (i) <= '0';

      else
        we_tmp (i) <= we_ctrl_fifo_r (i)
                      and data_reg_valid_r (i)
                      and (not (full_from_fifo (i)));
      end if;

      -- i viittaa lähteeseen (=input_port)
      if state_dst_r (i) = no_dir_c then
        -- sisääntulossa i ei ole järkevää dataa
        re_tmp (i) <= '0';
      else
        -- ei lueta sisääntulosta i ellei
        --  a) tilakone ole lukemass sieltä (re_r pitää olla 1)
        --  b) sisääntulossa on validia dataa  (empty pitää olla 0)
        --  c) kohde ei ole varattu
        re_tmp (i) <= re_r (i)
                      and (not Incoming_empty (i))
                      and (not full_from_fifo (state_dst_r (i)));
      end if;
      
    end loop;  -- i
  end process read_en_tmp;


  -----------------------------------------------------------------------------
  -- select right fifo according to channel
  select_channels: process (we_tmp, state_channel_r,
                            data_from_fwd0, data_from_fwd1,
                            data_from_rev0, data_from_rev1,
                            empty_from_fwd0, empty_from_fwd1,
                            empty_from_rev0, empty_from_rev1,
                            full_from_fwd0, full_from_fwd1,
                            full_from_rev0, full_from_rev1,
                            re_fwd_in, re_rev_in,
                            fwd_chan_sel_r, rev_chan_sel_r)
  begin  -- process select_channels


    -- decide which fifo will get the data:
    -- if there's channel 1 data coming, we have to direct out
    -- signals from the fifo 1
    if state_channel_r(fwd_c) = 1 then
      we_fwd1 <= we_tmp(fwd_c);
      we_fwd0 <= '0';
      empty_from_fifo(fwd_c) <= empty_from_fwd1;
      full_from_fifo(fwd_c)  <= full_from_fwd1;
    else
      we_fwd0 <= we_tmp(fwd_c);
      we_fwd1 <= '0';
      empty_from_fifo(fwd_c) <= empty_from_fwd0;
      full_from_fifo(fwd_c)  <= full_from_fwd0;
    end if;

    if state_channel_r(rev_c) = 1 then
      we_rev1 <= we_tmp(rev_c);
      we_rev0 <= '0';
      full_from_fifo(rev_c)  <= full_from_rev1;
      empty_from_fifo(rev_c) <= empty_from_rev1;
    else
      we_rev0 <= we_tmp(rev_c);
      we_rev1 <= '0';
      full_from_fifo(rev_c)  <= full_from_rev0;
      empty_from_fifo(rev_c) <= empty_from_rev0;
    end if;

    

    -- decide from which fifo the data goes out
    if fwd_chan_sel_r = '1' then
      data_from_fifo(fwd_c)  <= data_from_fwd1;
      re_fwd1                <= re_fwd_in;
      re_fwd0                <= '0';
      empty_from_fwd         <= empty_from_fwd1;
    else
      data_from_fifo(fwd_c)  <= data_from_fwd0;
      re_fwd0                <= re_fwd_in;
      re_fwd1                <= '0';
      empty_from_fwd         <= empty_from_fwd0;
    end if;

    -- same for the rev fifo
    if rev_chan_sel_r = '1' then
      data_from_fifo(rev_c)  <= data_from_rev1;
      re_rev1                <= re_rev_in;
      re_rev0                <= '0';
      empty_from_rev         <= empty_from_rev1;
    else
      data_from_fifo(rev_c)  <= data_from_rev0;
      re_rev0                <= re_rev_in;
      re_rev1                <= '0';
      empty_from_rev         <= empty_from_rev0;
    end if;


  end process select_channels;




  ------------------------------------------------------------------------------
  -- Parallel routing (all ports prt cycle)
  ------------------------------------------------------------------------------
  -- !!! without postponed Incoming_data is not updated
  --     before this process and overflow occurs on
  --     router_addr !!! 11.9.2006 HP
  -- PROC
  -- Check where the incoming packet is heading
  -- Input ports are handled one per clock cycle
  Check_dst : postponed
    process (State_reading_r,
             router_addr,
             Incoming_data,
             Incoming_empty,
             Incoming_full)

      variable resolved_dest_v : integer range 0 to n_ports_c - 1;
      variable incoming_channel_v : std_logic;
      
    begin  -- process Check_dst

      -- 1) if (No read operation yet on the curr source port)
      --      and (Complete packet coming from curr src port)  -- store_and-forward
      --      and (there is data (=addr) on curr src port)  -- cut-through
      --      
      --      2) if (packet is going to right direction from center ring)
      --         3) if (target column)          => data goes to ip
      --         3) elsif (toward west)
      --         3) else (toward east)
      --
      --      2) else wrong direction
      --          away from center
      --          towards center
      -- 1) else                         => no packet arriving on curr src port

      for src_i in 0 to n_ports_c-1 loop

        router_addr (src_i) <= no_dir_c;  --0;

        if State_reading_r (src_i) = '0'
          and ((Incoming_full (src_i) = '1' and stfwd_en_g = 1)
               or
               (Incoming_empty (src_i) = '0'and stfwd_en_g = 0))
        then                            -- 1)

          router_addr(src_i) <= conv_integer (unsigned (Incoming_data (src_i) (addr_width_c - 1 downto 0)));

          incoming_channel_v := Incoming_data(src_i)(addr_width_c);
          
          resolved_dest_v := router_func (router_addr(src_i), router_id_g);
          curr_dst (src_i) <= resolved_dest_v;
          
          -- channel handling:
          -- if packet is going to fwd or rev directions and it's either coming
          -- trough channel 1 or this is the one router with datelines around it,
          -- we put the packet to channel 1
          if (resolved_dest_v = fwd_c or resolved_dest_v = rev_c)
            and (dateline_en_g = 1 or incoming_channel_v = '1')
          then
            curr_channel(src_i) <= 1;
          else
            curr_channel(src_i) <= 0;
          end if;

          
        else                            --1)
          -- No packet on curr src port or read operation already started
          curr_dst (src_i) <= no_dir_c;
          curr_channel (src_i) <= 0;
        end if;  -- State_reading_r
        
      end loop;  -- i

    end process Check_dst;


  -----------------------------------------------------------------------------
  resolve_conflicts : process (curr_dst, start_idx_r)
    variable hi_port_v : integer range 0 to n_ports_c;
    variable lo_port_v : integer range 0 to n_ports_c;
  begin  -- process resolve_conflicts

    curr_dst_resolved <= curr_dst;

    -- 1) Go through all destination ports
    -- 2) Use start_idx_r to separate high and low priotities
    -- 3) Give turn to inport with smallest id in high side, and if there's no
    -- requests there, inport with smallest id in low side
    for dst_i in 0 to n_ports_c-1 loop
      hi_port_v := no_dir_c;
      lo_port_v := no_dir_c;

      for src_i in 0 to n_ports_c-1 loop

        if curr_dst(src_i) = dst_i then
          -- src_i wants to send to dst_i
          
          if src_i > start_idx_r-1 then
            -- this is hi priority side
            if hi_port_v /= no_dir_c then
              curr_dst_resolved(src_i) <= no_dir_c;
            else
              hi_port_v := src_i;
            end if;

          else
            -- low priority side

            if lo_port_v /= no_dir_c then
              curr_dst_resolved(src_i) <= no_dir_c;
            else
              lo_port_v := src_i;
            end if;
            
          end if;
        end if;
      end loop;  -- src_i

      if hi_port_v /= no_dir_c and lo_port_v /= no_dir_c then
        curr_dst_resolved(lo_port_v) <= no_dir_c;
      end if;

    end loop;  -- dst_i
    
  end process resolve_conflicts;


  -----------------------------------------------------------------------------
  incr_start_idx : process (clk_net, rst_n)
  begin  -- process incr_start_idx
    if rst_n = '0' then                 -- asynchronous reset (active low)
      start_idx_r <= 0;
    elsif clk_net'event and clk_net = '1' then  -- rising clock edge
      if start_idx_r = n_ports_c-1 then
        start_idx_r <= 0;
      else
        start_idx_r <= start_idx_r +1;
      end if;
    end if;
  end process incr_start_idx;


  -------------------------------------------------------------------------------
  data_dbg : for i in 0 to n_ports_c-1 generate
    data_ctrl_fifo_dbg (i) <= data_ctrl_fifo_r (i) when data_reg_valid_r (i) = '1'
                              else (others => dbg_value_c(sim_dbg_ena_g));  --(others => 'Z');
  end generate data_dbg;

  -----------------------------------------------------------------------------
  -- enable channel 1
  out_channel: process (clk_net, rst_n)
  begin  -- process out_channel
    if rst_n = '0' then                 -- asynchronous reset (active low)
      fwd_chan_sel_r <= '0';
      rev_chan_sel_r <= '0';
      fwd_pkt_counter_r <= 0;
      rev_pkt_counter_r <= 0;
      fwd_pkt_len_r <= 0;
      rev_pkt_len_r <= 0;
      
    elsif clk_net'event and clk_net = '1' then  -- rising clock edge

      -- get the pkt length
      if state_src_r(fwd_c) /= no_dir_c then
        fwd_pkt_len_r <= pkt_len_arr_r(state_src_r(fwd_c));
      end if;
  
      -- if read enable is up, receiving router is reading a flit
      if re_fwd_in = '1' then

        -- last flit about to be read?
        if fwd_pkt_counter_r = fwd_pkt_len_r - 1 then
          fwd_pkt_counter_r <= 0;
        else
          fwd_pkt_counter_r <= fwd_pkt_counter_r + 1;
        end if;
        
      end if;


      -- if no packet is yet being sent or if one packet has
      -- just been completed, we can change the fifos
      if (fwd_pkt_counter_r = 0 and re_fwd_in = '0')
        or (fwd_pkt_counter_r = fwd_pkt_len_r - 1 and re_fwd_in = '1')
      then
        
        -- if fifo1 not empty, switch to it
        if empty_from_fwd1 = '0' then
          fwd_chan_sel_r <= '1';
        else
          -- falling back to channel 0
          fwd_chan_sel_r <= '0';
        end if;
        
      end if;


      -- same for the rev
      if state_src_r(rev_c) /= no_dir_c then
        rev_pkt_len_r <= pkt_len_arr_r(state_src_r(rev_c));
      end if;

      if re_rev_in = '1' then
        
        if rev_pkt_counter_r = rev_pkt_len_r - 1 then
          rev_pkt_counter_r <= 0;
        else
          rev_pkt_counter_r <= rev_pkt_counter_r + 1;
        end if;
      end if;

      if (rev_pkt_counter_r = 0 and re_rev_in = '0') or
        (rev_pkt_counter_r = rev_pkt_len_r - 1 and re_rev_in = '1')
      then
        -- if fifo1 not empty, switch to it
        if empty_from_rev1 = '0' then
          rev_chan_sel_r <= '1';
        else
          -- falling back to channel 0
          rev_chan_sel_r <= '0';
        end if;
      end if;
            
    end if;
  end process out_channel;

  -----------------------------------------------------------------------------
  Main_control : process (clk_net, rst_n)
  begin  -- process Main_control
    if rst_n = '0' then                 -- asynchronous reset (active low)
      for i in 0 to n_ports_c-1 loop
        data_ctrl_fifo_r (i) <= (others => '0');  --'0');
        send_counter_r (i)   <= 0;
        pkt_len_arr_r(i) <= pkt_len_g;
      end loop;  -- i

      we_ctrl_fifo_r  <= (others => '0');
      re_r            <= (others => '0');
      State_writing_r <= (others => '0');
      State_reading_r <= (others => '0');
      state_src_r     <= (others => no_dir_c);
      state_dst_r     <= (others => no_dir_c);
      state_channel_r <= (others => 0);

      data_reg_valid_r <= (others => '1');

      if stfwd_en_g = 1 then
        assert fifo_depth_g = pkt_len_g report "Store-and-forward assumes fifo_depth equal to packet_length" severity failure;
      end if;
      
    elsif clk_net'event and clk_net = '1' then  -- rising clock edge

      
      for i in 0 to n_ports_c-1 loop
        -- Handle all directions


        -- From now on, loop variable i refers to source port
        
        if State_reading_r (i) = '1' then
          -- Already reading from direction i 

          -- Use counters to enable cut-through switching.
          -- The same thing works also with store-and-forward switching
          if send_counter_r (i) = pkt_len_arr_r(i)
          then
            -- stop

            if full_from_fifo (state_dst_r (i)) = '0' then

              we_ctrl_fifo_r (state_dst_r (i)) <= '0';
              re_r (i)                         <= '0';

              State_writing_r (state_dst_r (i)) <= '0';
              State_reading_r (i)               <= '0';
              state_src_r (state_dst_r (i))     <= no_dir_c;
              state_dst_r (i)                   <= no_dir_c;
              --assert false report "Tx to north fifo completed" severity note;
              state_channel_r(state_dst_r(i))   <= 0;

              send_counter_r (i)                 <= 0;
              data_ctrl_fifo_r (state_dst_r (i)) <= (others => dbg_value_c(sim_dbg_ena_g));
              data_reg_valid_r (state_dst_r (i)) <= '0';

              pkt_len_arr_r(i) <= pkt_len_g;

            --assert state_dst_r(i)/=4 report "Stop" severity note;
            else
            --assert  state_dst_r(i)/=4 report "Wait until last data fits into fifo" severity note;
            end if;

          else
            -- Packet transfer not yet complete
            -- Continue transfer
            we_ctrl_fifo_r (state_dst_r (i)) <= '1';

            State_writing_r (state_dst_r (i)) <= State_writing_r (state_dst_r (i));
            State_reading_r (i)               <= State_reading_r (i);
            state_src_r (state_dst_r (i))     <= state_src_r (state_dst_r (i));
            state_dst_r (i)                   <= state_dst_r (i);
            state_channel_r (state_dst_r(i))  <= state_channel_r (state_dst_r (i));
            --assert false report "Tx to north fifo in progress" severity note;


            -- i = source
            if data_reg_valid_r (state_dst_r(i)) = '0' then
              -- data_reg empty
              
              if re_tmp (i) = '1' then
                data_reg_valid_r (state_dst_r(i))  <= '1';  -- read new value
                send_counter_r (i)                 <= send_counter_r (i) +1;
                data_ctrl_fifo_r (state_dst_r (i)) <= Incoming_data (i);
                
              else
                data_reg_valid_r (state_dst_r(i)) <= '0';  -- stay empty                
              end if;
              
            else
              -- data_reg full

              if full_from_fifo (state_dst_r (i)) = '0' then
                -- write old to fifo
                if re_tmp (i) = '1' then
                  data_reg_valid_r (state_dst_r(i))  <= '1';  -- write old, read new value
                  send_counter_r (i)                 <= send_counter_r (i) +1;
                  data_ctrl_fifo_r (state_dst_r (i)) <= Incoming_data (i);
                else
                  data_reg_valid_r (state_dst_r(i)) <= '0';  -- write old, now empty               
                end if;

              else
                -- cannot write old
                data_reg_valid_r (state_dst_r(i)) <= '1';
                assert re_tmp (i) = '0' report "reading not allowed now" severity error;
              end if;
              
            end if;

            -- if address hasn't been read, put in the channel bit
            if send_counter_r(i) = 0 then
              if state_channel_r(state_dst_r(i)) = 1 then
                data_ctrl_fifo_r(state_dst_r(i))(addr_width_c) <= '1';
              else
                data_ctrl_fifo_r(state_dst_r(i))(addr_width_c) <= '0';
              end if;
            end if;


            -- Reading the pkt length
            if len_flit_en_g = 0 and re_tmp(i) = '1' and send_counter_r(i) = 0 then
              -- +1 at the end: address flit
              pkt_len_arr_r(i) <= conv_integer( unsigned( Incoming_data(i)(data_width_g-1 downto data_width_g-len_width_c))) + 1;
            elsif len_flit_en_g = 1 and re_tmp(i) = '1' and send_counter_r(i) = 1 then
              -- +2: address and len flits
              pkt_len_arr_r(i) <= conv_integer( unsigned( Incoming_data(i) )) + 2;
            end if;
            
            
            -- Stop reading little bit earlier than writing stops
            if send_counter_r (i) = pkt_len_arr_r(i) - 1
              and Incoming_empty (i) = '0'  -- 2006/10/24
              and full_from_fifo (state_dst_r(i)) = '0'
            then
              re_r (i) <= '0';
            else
              re_r (i) <= '1';
            end if;

            
          end if;

        else
          -- Not yet reading from direction i 

          -- Direction i has to be current source,
          -- there must be valid address on port i
          -- and target fifo has to be empty (i.e. it is not full or reserved)
          -- also state_channel must match the curr_channel so that
          -- empty_from_fifo signal comes from the right fifo
          if                            -- curr_src_r = i and
            curr_dst_resolved (i) /= no_dir_c
            and empty_from_fifo (curr_dst_resolved (i)) = '1'
            and State_writing_r (curr_dst_resolved (i)) = '0'
            and curr_channel(i) = state_channel_r(curr_dst_resolved(i))
          then
            -- Start reading

            we_ctrl_fifo_r (curr_dst_resolved (i))  <= '0';
            -- WE not yet '1' because RE is just being asserted to one
            -- Otherwise, the first data (i.e.) would be written twice and the
            -- last data would be discarded
            State_writing_r (curr_dst_resolved (i)) <= '1';

            re_r (i)                              <= '1';
            State_reading_r (i)                   <= '1';
            state_src_r (curr_dst_resolved (i))   <= i;
            state_dst_r (i)                       <= curr_dst_resolved (i);
            
            send_counter_r (i)                       <= send_counter_r (i);  --??
            data_ctrl_fifo_r (curr_dst_resolved (i)) <= Incoming_data (i);

            -- if writing address, include the current channel bit
            if state_channel_r(curr_dst_resolved(i)) = 1 then
              data_ctrl_fifo_r(curr_dst_resolved(i))(addr_width_c) <= '1';
            else
              data_ctrl_fifo_r(curr_dst_resolved(i))(addr_width_c) <= '0';
            end if;

            
            data_reg_valid_r (curr_dst_resolved (i)) <= '1';

          --else
          -- Can't start reading from current source
          -- Do nothing
            
          end if;  --State_reading_r = i

          -- set the channel register when address is valid
          if curr_dst_resolved(i) /= no_dir_c
            and State_writing_r(curr_dst_resolved(i)) = '0'
          then
            state_channel_r(curr_dst_resolved(i)) <= curr_channel(i);
          end if;
          
        end if;  --State_reading_r(i)=1
        
      end loop;  -- i

    end if;  --Rst_n/Clk'event
  end process Main_control;

end rtl;
