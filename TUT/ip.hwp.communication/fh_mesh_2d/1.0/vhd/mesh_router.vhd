-------------------------------------------------------------------------------
-- File        : mesh_fast_router.vhdl
-- Description : Routes packets in 2D mesh network.
--               Five io channels, four to neighbor routers.
--               All output channels have fifo buffers.
--               Routers are identified with two-part address
--               row address (top bits) and columns address (lowest bits).
--               Port names (N/W/S/E/Ip) refer to their _location_
--               on the router (instead of signal direction).
--               
--               Routers wait for complete packet before forwarding it.
--               Packets reach first the right row and then the right column
--               (YX routing or dimension-order routing, such deterministic
--               scheme assures in-order pkt delivery).
--               
--               Size of packet (including address) don't have to be
--               the same as Fifo_depth anymore
--
--               
-- Author      : Erno Salminen
-- Date        : 10.06.2003
-------------------------------------------------------------------------------
--  This file is part of Transaction Generator.
--
--  Transaction Generator is free software: you can redistribute it and/or modify
--  it under the terms of the Lesser GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  Transaction Generator is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  Lesser GNU General Public License for more details.
--
--  You should have received a copy of the Lesser GNU General Public License
--  along with Transaction Generator.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------
-- Modified    : 
-- 25.07.2003   ES full signal added, finalizing
-- 11.08.2003   ES fifo added to router, it stores data coming from ip
--              ports definitions modified at the same time
-- 05.11.2003   ES full_ip_tx fixed
-- 29.04.2005   ES Internal naming changed
-- 21.08.2006   AK multiclk support and naming convention change
-- 15.10.2006   ES Fifo_size independent from pkt_len (if stfwd=0)
--                 and routing is done in single cycle for all ports
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mesh_router is

  generic (
    stfwd_en_g      : integer := 1;     --24.08.2006 es
    data_width_g    : integer := 0;
    addr_width_g    : integer := 0;     -- at least two bits, A = row & col
    fifo_depth_g    : integer := 0;
    pkt_len_g       : integer := 5;
    len_flit_en_g   : integer := 1;     -- 2007/08/03 where to place a pkt_len
    oaddr_flit_en_g : integer := 1;     -- 2007/08/03 whether to send the orig address

    ip_freq_g    :    integer := 1;     -- relative IP frequency
    mesh_freq_g  :    integer := 1;     --relative router frequency
    col_addr_g   :    integer := 0;
    row_addr_g   :    integer := 0;
    num_cols_g   :    integer := -1;    -- if used, outer fifos are not
    num_rows_g   :    integer := -1     -- mapped
    );
  port (
    clk_ip       : in std_logic;
    clk_mesh     : in std_logic;
    rst_n        : in std_logic;

    data_n_in        : in std_logic_vector (data_width_g-1 downto 0);
    empty_n_in       : in std_logic;
    full_n_in        : in std_logic;
    re_n_in : in std_logic;
    data_s_in        : in std_logic_vector (data_width_g-1 downto 0);
    empty_s_in       : in std_logic;
    full_s_in        : in std_logic;
    re_s_in : in std_logic;
    data_w_in        : in std_logic_vector (data_width_g-1 downto 0);
    empty_w_in       : in std_logic;
    full_w_in        : in std_logic;
    re_w_in : in std_logic;
    data_e_in        : in std_logic_vector (data_width_g-1 downto 0);
    empty_e_in       : in std_logic;
    full_e_in        : in std_logic;
    re_e_in : in std_logic;

    -- Ip signals modified 11.08.03
    data_ip_Tx_in         : in  std_logic_vector (data_width_g-1 downto 0);
    we_ip_Tx_in : in  std_logic;
    empty_ip_Tx_Out       : out std_logic;
    full_ip_Tx_Out        : out std_logic;

    data_n_Out        : out std_logic_vector (data_width_g-1 downto 0);
    empty_n_Out       : out std_logic;
    full_n_Out        : out std_logic;
    re_n_Out : out std_logic;
    data_s_Out        : out std_logic_vector (data_width_g-1 downto 0);
    empty_s_Out       : out std_logic;
    full_s_Out        : out std_logic;
    re_s_Out : out std_logic;
    data_w_Out        : out std_logic_vector (data_width_g-1 downto 0);
    empty_w_Out       : out std_logic;
    full_w_Out        : out std_logic;
    re_w_Out : out std_logic;
    data_e_Out        : out std_logic_vector (data_width_g-1 downto 0);
    empty_e_Out       : out std_logic;
    full_e_Out        : out std_logic;
    re_e_Out : out std_logic;

    -- Ip signals modified 11.08.03
    data_ip_Rx_Out       : out std_logic_vector (data_width_g-1 downto 0);
    re_ip_Rx_in : in  std_logic;
    full_ip_Rx_Out       : out std_logic;
    empty_ip_Rx_Out      : out std_logic
    );

end mesh_router;


architecture rtl of mesh_router is

  -- Constants for accessing arrays (e.g. state_regs)
  constant N      : integer := 0;
  constant W      : integer := 1;
  constant S      : integer := 2;
  constant E      : integer := 3;
  constant Ip     : integer := 4;
  constant no_dir_c : integer := 5;       -- Illegal index



  component fifo
    generic (
      data_width_g : integer := 0;
      depth_g      : integer := 0
      );
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

  component multiclk_fifo
    generic (
      re_freq_g    : integer;
      we_freq_g    : integer;
      depth_g      : integer;
      data_width_g : integer
      );
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
      one_d_out : out std_logic
      );
  end component;

  -- Arrays are easier to handle than names with direction identification
  -- (e.g. data_arr(i) vs. data_n)
  type data_arr_type is array (4 downto 0) of std_logic_vector (data_width_g-1 downto 0);
  type ctrl_arr_type is array (4 downto 0) of std_logic;
  type source_type is array (4 downto 0) of integer range 0 to 5;
  type counter_arr_type is array (4 downto 0) of integer range 0 to pkt_len_g;  --  --fifo_depth_g;

  -- 2007/08/02 Start implementing variable-length packets
  signal pkt_len_arr_r : counter_arr_type;  --2007/08/02

  -- Internal types and signals. Thse are mapped to router's inputs
  signal Incoming_data  : data_arr_type;
  signal Incoming_empty : ctrl_arr_type;
  signal Incoming_full  : ctrl_arr_type;

  -- From fifos. Mapped directly to outputs pins 
  signal data_from_fifo  : data_arr_type;
  signal full_from_fifo  : ctrl_arr_type;
  signal empty_from_fifo : ctrl_arr_type;  -- this goes also to ctrl

  -- From ctrl
  signal data_ctrl_fifo_r : data_arr_type;
  signal we_ctrl_fifo_r   : ctrl_arr_type;
  signal re_r             : ctrl_arr_type;
  signal send_counter_r   : counter_arr_type;

  -- 13.09.2006. Try wormhole, combinatorial enable signals
  signal re_tmp : ctrl_arr_type;
  signal we_tmp : ctrl_arr_type;

  signal data_reg_valid_r   : ctrl_arr_type;  -- 2006/10/26
  signal data_ctrl_fifo_dbg : data_arr_type;

  
  -- State registers
  signal State_writing_r : std_logic_vector (4 downto 0);  -- 0=N,1=W,2=S,3=E,4=Ip
  signal State_reading_r : std_logic_vector (4 downto 0);  -- 0=N,1=W,2=S,3=E,4=Ip

  -- state_src_r(i) tells which port the source for output port i
  signal state_src_r : source_type;     -- 0=N,1=W,2=S,3=E,4=Ip

  -- state_dst_r(i) tells which port the destination for input port i
  signal state_dst_r : source_type;     -- 0=N,1=W,2=S,3=E,4=Ip



  -- Marks which input is checked on current cycle
  signal curr_src_r : integer range 0 to 4;

  -- Decoded address in input port pointed by curr_src_r, _not_ a register!
  --signal curr_dst : integer range 0 to 5;
  -- new type 13.09.2006, ES
  type dst_arr_type is array (5-1 downto 0) of integer range 0 to 5;
  signal curr_dst          : dst_arr_type;
  signal curr_dst_resolved : dst_arr_type;
  signal n_req_dbgr        : dst_arr_type;

  -- 2007/08/06
  constant len_width_c : integer := 8;  -- bits needed for pkt_len, will be generic someday?

  
begin  -- rtl

  assert addr_width_g > 1 report "Mesh addr must be at least 2 bits wide. addr = row & column" severity failure;
  assert addr_width_g < (data_width_g+1) report "Mesh addr cannot be wider than data" severity failure;



  -- Concurrent assignments
  -- Connect fifo status signals to outputs
  empty_n_Out     <= empty_from_fifo (N);
  empty_w_Out     <= empty_from_fifo (W);
  empty_s_Out     <= empty_from_fifo (S);
  empty_e_Out     <= empty_from_fifo (E);
  empty_ip_Rx_Out <= empty_from_fifo (Ip);  -- from ip_rx_fifo 

  full_n_Out     <= full_from_fifo (N);
  full_w_Out     <= full_from_fifo (W);
  full_s_Out     <= full_from_fifo (S);
  full_e_Out     <= full_from_fifo (E);
  full_ip_Rx_Out <= full_from_fifo (Ip);  --  -- from ip_rx_fifo 


  -- Collect inputs into array
  Incoming_data (N) <= data_n_in;
  Incoming_data (W) <= data_w_in;
  Incoming_data (S) <= data_s_in;
  Incoming_data (E) <= data_e_in;

  Incoming_empty (N) <= empty_n_in;
  Incoming_empty (W) <= empty_w_in;
  Incoming_empty (S) <= empty_s_in;
  Incoming_empty (E) <= empty_e_in;
  empty_ip_Tx_Out    <= Incoming_empty (Ip);  -- from ip_tx_fifo

  Incoming_full (N) <= full_n_in;
  Incoming_full (W) <= full_w_in;
  Incoming_full (S) <= full_s_in;
  Incoming_full (E) <= full_e_in;
  full_ip_Tx_Out    <= Incoming_full (Ip);  -- from ip_tx_fifo


  -- Separate arrays signals into outputs
  re_n_Out <= re_tmp (N); -- re_r (N);
  re_w_Out <= re_tmp (W); -- re_r (W);
  re_s_Out <= re_tmp (S); -- re_r (S);
  re_e_Out <= re_tmp (E); -- re_r (E);


  -- Debug
  -- Easier to trace if outputs are 'Z' when output fifo is empty
  -- (Comment out the "when part" for synthesis
  -- e.g."data_n_Out <= data_from_fifo (N);  -- when data_from_fifo and so on")
  data_n_Out     <= data_from_fifo (N);  --   when empty_from_fifo (N) = '0'  else (others   => 'Z');
  data_w_Out     <= data_from_fifo (W);  --  when empty_from_fifo (W) = '0'  else (others   => 'Z');
  data_s_Out     <= data_from_fifo (S);  --  when empty_from_fifo (S) = '0'  else (others   => 'Z');
  data_e_Out     <= data_from_fifo (E);  --  when empty_from_fifo (E) = '0'  else (others   => 'Z');
  data_ip_Rx_Out <= data_from_fifo (Ip);  -- when empty_from_fifo (Ip) = '0' else (others => '0');

  -- 13.09.2006
  read_en_tmp: process (we_ctrl_fifo_r, re_r,
                        data_reg_valid_r,
                        Incoming_empty,
                        state_dst_r, state_src_r,
                        full_from_fifo)

  begin  -- process read_en_tmp
    for i in 0 to 5-1 loop

      -- i viittaa kohteeseen (fifo)
      if state_src_r (i) = no_dir_c then
        we_tmp (i) <=  '0';
       else          
          we_tmp (i) <= we_ctrl_fifo_r (i)
                        and data_reg_valid_r (i)
                        and (not (full_from_fifo (i)));
      end if;

      
      -- i viittaa llähteeseen (=input_port)
      if state_dst_r (i) = no_dir_c then
        -- sisääntulossa i ei ole järkevää dataa
        re_tmp (i) <= '0';
      else
        -- ei lueta sisääntulosta i ellei
        --  a) tilakone ole lukemass sieltä (re_r pitää olla 1)
        --  b) sisääntulossa ole validia dataa  (empty pitää olla 0)
        --  c) kohde ei ole varattu
        re_tmp (i) <= re_r (i)
                      and (not Incoming_empty (i))
                      and (not full_from_fifo (state_dst_r (i)));
      end if;    
      
    end loop;  -- i
  end process read_en_tmp;



  
  not_map_north_row : if row_addr_g = 0 generate
    full_from_fifo(N)  <= '0';
    data_from_fifo(N)  <= (others => '0');
    empty_from_fifo(N) <= '1';
  end generate not_map_north_row;

  map_north_row : if row_addr_g /= 0 generate

    North_fifo : fifo
      generic map (
        data_width_g => data_width_g,
        depth_g      => fifo_depth_g
        )
      port map (
        clk          => clk_Mesh,
        rst_n        => rst_n,
        data_in      => data_ctrl_fifo_r (N),
        we_in        => we_tmp (N),          -- we_ctrl_fifo_r (N),
        --one_p_out    => one_p_from_fifo (N),
        full_out     => full_from_fifo (N),
        data_Out     => data_from_fifo (N),
        re_in        => re_n_in,             -- router input
        empty_out    => empty_from_fifo (N)  --,
        --one_d_out    => one_d_from_fifo (N)
        );

  end generate map_north_row;

  -- Component mappings

  not_map_south_row : if row_addr_g = num_rows_g-1 generate
    full_from_fifo(S)  <= '0';
    data_from_fifo(S)  <= (others => '0');
    empty_from_fifo(S) <= '1';
  end generate not_map_south_row;

  map_south_row : if row_addr_g /= num_rows_g-1 generate

    South_fifo : fifo
      generic map (
        data_width_g => data_width_g,
        depth_g      => fifo_depth_g
        )
      port map (
        clk          => clk_Mesh,
        rst_n        => rst_n,
        data_in      => data_ctrl_fifo_r (S),
        we_in        => we_tmp (S),          -- we_ctrl_fifo_r (S),
        --one_p_out    => one_p_from_fifo (S),
        full_out     => full_from_fifo (S),
        data_Out     => data_from_fifo (S),
        re_in        => re_s_in,             -- router input
        empty_out    => empty_from_fifo (S)  --,
        --one_d_out    => one_d_from_fifo (S)
        );
  end generate map_south_row;

  not_map_west_col : if col_addr_g = 0 generate
    full_from_fifo(W)  <= '0';
    data_from_fifo(W)  <= (others => '0');
    empty_from_fifo(W) <= '1';
  end generate not_map_west_col;

  map_west_col : if col_addr_g /= 0 generate
    West_fifo  : fifo
      generic map (
        data_width_g => data_width_g,
        depth_g      => fifo_depth_g
        )
      port map (
        clk          => clk_Mesh,
        rst_n        => rst_n,
        data_in      => data_ctrl_fifo_r (W),
        we_in        => we_tmp (W),          --we_ctrl_fifo_r (W),
        --one_p_out    => one_p_from_fifo (W),
        full_out     => full_from_fifo (W),
        data_Out     => data_from_fifo (W),
        re_in        => re_w_in,             -- router input
        empty_out    => empty_from_fifo (W)  --,
        --one_d_out    => one_d_from_fifo (W)
        );
  end generate map_west_col;

  not_map_east_col : if col_addr_g = num_cols_g-1 generate
    full_from_fifo(E)  <= '0';
    data_from_fifo(E)  <= (others => '0');
    empty_from_fifo(E) <= '1';
  end generate not_map_east_col;

  map_east_col : if col_addr_g /= num_cols_g-1 generate
    East_fifo  : fifo
      generic map (
        data_width_g => data_width_g,
        depth_g      => fifo_depth_g
        )
      port map (
        clk          => clk_Mesh,
        rst_n        => rst_n,
        data_in      => data_ctrl_fifo_r (E),
        we_in        => we_tmp (E),          --we_ctrl_fifo_r (E),
        --one_p_out    => one_p_from_fifo (E),
        full_out     => full_from_fifo (E),
        data_Out     => data_from_fifo (E),
        re_in        => re_e_in,             -- router input
        empty_out    => empty_from_fifo (E)  --,
        --one_d_out    => one_d_from_fifo (E)
        );
  end generate map_east_col;


  -- data going to IP
  ip_fifo_rx : multiclk_fifo
    generic map (
      re_freq_g    => ip_freq_g,
      we_freq_g    => mesh_freq_g,
      depth_g      => fifo_depth_g,
      data_width_g => data_width_g)
    port map (
      clk_re => clk_ip,
      clk_we => clk_mesh,

      rst_n     => rst_n,
      data_in   => data_ctrl_fifo_r (Ip),
      we_in     => we_tmp (Ip),          --we_ctrl_fifo_r (Ip),
      --one_p_out    => one_p_from_fifo (Ip),
      full_out  => full_from_fifo (Ip),
      data_Out  => data_from_fifo (Ip),
      re_in     => re_ip_Rx_in,          -- router input
      empty_out => empty_from_fifo (Ip)  --,
      --one_d_out    => one_d_from_fifo (Ip)
      );



  -- Added 11.08.03
  -- data coming from ip
  ip_fifo_tx : multiclk_fifo
    generic map (
      re_freq_g    => mesh_freq_g,
      we_freq_g    => ip_freq_g,
      depth_g      => fifo_depth_g,
      data_width_g => data_width_g
      )
    port map (
      clk_re   => clk_mesh,
      clk_we   => clk_ip,
      rst_n    => rst_n,
      -- Fifo inputs come straight router inputs (=from ip)
      data_in  => data_ip_Tx_in,
      full_out => Incoming_full (Ip),
      we_in    => we_ip_Tx_in,

      -- Fifo outputs go ctrl logic
      data_Out  => Incoming_data (Ip),
      empty_out => Incoming_empty (Ip),
      re_in     => re_tmp (Ip) -- re_r (Ip)
      );


   Check_dst : process (State_reading_r,
                       --curr_src_r,
                       Incoming_data,
                       Incoming_empty,
                       Incoming_full
                        )
  begin  -- process Check_dst

    -- 1) if (No read operation yet on the curr source port)
    --      and (there is data (=addr) on curr src port)  --possibly unnecessary check
    --      and (Complete packet coming from curr src port)
    --      
    --      2) if (packet has reached target row)
    --         3) if (target column)          => data goes to ip
    --         3) elsif (toward west)
    --         3) else (toward east)
    --
    --      2) elsif toward north
    --      2) else (toward south)
    -- 1) else                         => no packet arriving on curr src port

    for src_i in 0 to 5-1 loop
      
      -- new way
      if State_reading_r (src_i) = '0'
        and ((Incoming_full (src_i) = '1' and stfwd_en_g = 1)
             or
             (Incoming_empty (src_i) = '0'and stfwd_en_g = 0))
      then                                -- 1)

        --if Incoming_data (src_i) (addr_width_g-1 downto addr_width_g/2) = row_addr_g then  -- 2)orig 
        if Incoming_data (src_i) (addr_width_g-len_width_c-1 downto addr_width_g/2) = row_addr_g then  -- 2)2007/08/06

          -- Correct row
          if Incoming_data (src_i) (addr_width_g/2-1 downto 0) = col_addr_g then  -- 3)
            -- Correct row and column
            curr_dst (src_i) <= Ip;
          elsif Incoming_data (src_i) (addr_width_g/2-1 downto 0) < col_addr_g then
            -- Packet is on the right row, going west (to left)
            curr_dst (src_i) <= W;
          else
            -- Right row, packet going east (to right)
            curr_dst (src_i) <= E;
          end if;

        -- elsif Incoming_data (src_i) (addr_width_g-1 downto addr_width_g/2) < row_addr_g then  --2)orig
        elsif Incoming_data (src_i) (addr_width_g-len_width_c-1 downto addr_width_g/2) < row_addr_g then  --2)2007/08/06
          -- Packet going north (upward)
          curr_dst (src_i) <= N;
        else
          -- Packet going south (downward)
          curr_dst (src_i) <= S;
        end if;


      else                              --1)
        -- No packet on curr src port or read operation already started
        curr_dst (src_i) <= no_dir_c;
      end if;

    end loop;  -- i


    
  end process Check_dst;
 

  data_dbg: for i in 0 to 5-1 generate
    data_ctrl_fifo_dbg (i) <= data_ctrl_fifo_r (i) when data_reg_valid_r (i)='1'
                              else (others => '0');
  end generate data_dbg;

 debug_proc: process (we_tmp, data_ctrl_fifo_dbg)
 begin  -- process debug_proc
   for i in 0 to 5-1 loop
     if we_tmp (i) = '1' then
       assert (data_ctrl_fifo_dbg (i)(0) /= 'Z') report "" severity FAILURE;
     end if;
   end loop;  -- i
 end process debug_proc;
                       

                       
  -- Why this was postponed??? -AK 13.06.2007
  -- Intuitively, it should not be, because it is not in testbench, is combinational and
  -- possibly would yield different results with synthesis tools

  --  resolve_conflicts: postponed process (curr_dst)
  resolve_conflicts: process (curr_dst)
    variable n_req_v : integer;         -- num of req for this outport
  begin  -- process resolve_conflicts

    curr_dst_resolved <= curr_dst;
    
     -- 1) Go through all curr_dst values
     -- 2) Count requests for the same 
     -- 3) Give turn to inport with smallest id (simple but unfair scheme)
     for dst_i in 0 to 5-1 loop
       n_req_v :=0;
       for src_i in 0 to 5-1 loop

         if curr_dst (src_i) = dst_i then
           -- src_i haluaisi lähettää outporttiin dst_i

           if n_req_v > 0 then
             -- Katsotaan onko muita halukkaita
             curr_dst_resolved (src_i) <= no_dir_c;
             --assert false report "Conflict for outport. Inport with smallest index will be selected" severity note;  
            end if;
           n_req_v := n_req_v +1;
         end if;
       end loop;  -- src_i

      n_req_dbgr (dst_i) <= n_req_v;
    end loop;  -- dst_i
    
  end process resolve_conflicts;

  -- Kopioi octagonista pikkuisen reilumpi konfliktinselvityskoodi!!!


  Main_control : process (clk_Mesh, rst_n)
  begin  -- process Main_control
    if rst_n = '0' then                 -- asynchronous reset (active low)
      for i in 0 to 4 loop
        data_ctrl_fifo_r (i) <= (others => '0');  --'0');
        send_counter_r (i)   <= 0;
        pkt_len_arr_r (i)    <= pkt_len_g;  -- 2007/08/02
      end loop;  -- i

      we_ctrl_fifo_r  <= (others => '0');
      re_r            <= (others => '0');
      State_writing_r <= (others => '0');
      State_reading_r <= (others => '0');
      state_src_r     <= (others => no_dir_c);
      state_dst_r     <= (others => no_dir_c);

      data_reg_valid_r <= (others => '0');

      
    elsif clk_Mesh'event and clk_Mesh = '1' then  -- rising clock edge
      
      for i in 0 to 5-1 loop        
        -- Handle all directions

        -- From now on, loop variable i refers to source port
        
        if State_reading_r (i) = '1' then
          -- Already reading from direction i 

          -- 17.03.2006 use counters to enable cut-through switching.
          -- The same thing works also with store-and-forward switching
          -- 2007/08/02: allow variable-length packets
          --if send_counter_r (i) = pkt_len_g  --fixed-len pkt
          if send_counter_r (i) = pkt_len_arr_r (i) --variable-_len pkt
          then
            -- stop

            if full_from_fifo (state_dst_r (i)) = '0' then
              
              we_ctrl_fifo_r (state_dst_r (i))   <= '0';
              re_r (i)                           <= '0';
              State_writing_r (state_dst_r (i))  <= '0';
              State_reading_r (i)                <= '0';
              state_src_r (state_dst_r (i))      <= no_dir_c;
              state_dst_r (i)                    <= no_dir_c;
              --assert false report "Tx to north fifo completed" severity note;

              send_counter_r (i)                 <= 0;
              data_ctrl_fifo_r (state_dst_r (i)) <= (others => 'X');  --Z');
              data_reg_valid_r (state_dst_r (i)) <= '0';

              pkt_len_arr_r (i) <=  pkt_len_g; -- 2007/08/02
              
              --assert state_dst_r(i)/=4 report "Stop" severity note;
            else
              --assert  state_dst_r(i)/=4 report "Wait until last data fits into fifo" severity note;
            end if;
            
            
          else
            -- Packet transfer not yet complete
            -- Continue transfer
            we_ctrl_fifo_r (state_dst_r (i))   <= '1';
            State_writing_r (state_dst_r (i))  <= State_writing_r (state_dst_r (i));
            State_reading_r (i)                <= State_reading_r (i);
            state_src_r (state_dst_r (i))      <= state_src_r (state_dst_r (i));
            state_dst_r (i)                    <= state_dst_r (i);

            -- i = source
            if data_reg_valid_r (state_dst_r(i)) = '0' then
              -- data_reg empty
              
              if re_tmp (i) = '1' then
                data_reg_valid_r (state_dst_r(i))  <= '1';  -- read new value
                send_counter_r (i)                 <= send_counter_r (i) +1;
                data_ctrl_fifo_r (state_dst_r (i)) <= Incoming_data (i);
                --assert i/=1 report "v=0, re=1" severity note;
              else
                data_reg_valid_r (state_dst_r(i))  <= '0';  -- stay empty                
                --assert i/=1 report "v=0, re=0" severity note;
              end if;
              
            else
              -- data_reg full

              if full_from_fifo (state_dst_r (i)) = '0' then
                -- write old to fifo
                if re_tmp (i) = '1' then
                  data_reg_valid_r (state_dst_r(i))  <= '1';  -- write old, read new value
                  send_counter_r (i)                 <= send_counter_r (i) +1;
                  data_ctrl_fifo_r (state_dst_r (i)) <= Incoming_data (i);
                  --assert i/=1 report "v = 1, re = 1, fu=0" severity note;
                else
                  data_reg_valid_r (state_dst_r(i))  <= '0';  -- write old, now empty               
                  --assert i/=1 report "v = 1, re = 0, f=0" severity note;
                end if;

              else
                -- cannot write old
                data_reg_valid_r  (state_dst_r(i)) <= '1';
                --assert i/=1 report "v=1, re=0, f=1" severity note;
                assert re_tmp (i) = '0' report "reading not allowed now" severity error;
              end if;
              
            end if;

              -- len-value in pkt does not include addr. If needed, add
              --  + length flit itself
              --  + orig_addr flit
              if stfwd_en_g = 1 then
                -- oletetaan, että tällöin paketit täytetään
                pkt_len_arr_r (i) <= pkt_len_g;
                -- Nythän pärjättäis pelkällä else-haaralla
                -- => Täytynee lisätä generic "fill_pkt_en_g", koska
                -- voi olla st-fwd mutta vaihtelevan mittaiset paketit
              else
                -- Len does not include len_flit itself nor network_address
                -- => add their length to len value
                -- Orig_address (if present) is already included own_addr_g value, it dont have to be added

                if (len_flit_en_g = 0 and (re_tmp (i) = '1') and send_counter_r (i) = 0) then
                  pkt_len_arr_r (i) <= conv_integer (unsigned(Incoming_data (i)(data_width_g-1 downto data_width_g-len_width_c)))+ len_flit_en_g +1;
                  --assert false report "Read pkt_len from the pkt_header (addr- flit)" severity note;

                elsif (len_flit_en_g = 1 and(re_tmp (i) = '1') and send_counter_r (i) = 1) then
                  pkt_len_arr_r (i) <= conv_integer (unsigned(Incoming_data (i)(len_width_c-1 downto 0)))+ len_flit_en_g +1;
                  --assert false report "Read pkt_len from the pkt_header (own len flit)" severity note;
                else
                  pkt_len_arr_r (i) <= pkt_len_arr_r (i);
                end if;

--             -- 2007/08/02 Take pkt_len from the header (2nd flit of pkt)
--             if (re_tmp (i) = '1') and send_counter_r (i) = 1 then
--               -- len-value in pkt does not include addr. If needed, add
--               --  + length flit itself
--               --  + orig_addr flit
--               if stfwd_en_g = 1 then
--                 -- oletetaan, että tällöin paketit täytetään
--                 pkt_len_arr_r (i) <= pkt_len_g;
--                 -- Nythän pärjättäis pelkällä else-haaralla
--                 -- => Täytynee lisätä generic "fill_pkt_en_g", koska
--                 -- voi olla st-fwd mutta vaihtelevan mittaiset paketit
--               else
--                 -- Len does not include len_flit itself nor network_address
--                 -- => add their length to len value
--                 -- Orig_address (if present) is already included own_addr_g value, it dont have to be added
--                 pkt_len_arr_r (i) <= conv_integer (unsigned(Incoming_data (i)))+ len_flit_en_g +1;
--                 --assert false report "Read pkt_len from the pkt_header" severity note;                
--               end if;

              
            end if;
            
            if send_counter_r (i) = pkt_len_arr_r (i) -1
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
          -- Check one direction (curr_src_r) per clock cycle
          -- for possible new transfers

          -- Direction i has to be current source,
          -- there must be valid address on port i
          -- and target fifo has to be empty (i.e. it is not full or reserved)
          if 
            curr_dst_resolved (i) /= no_dir_c
            and empty_from_fifo (curr_dst_resolved (i)) = '1'
            and State_writing_r (curr_dst_resolved (i)) = '0'  --25.07.2003
          then
            -- Start reading

            we_ctrl_fifo_r (curr_dst_resolved (i))   <= '0';
            -- WE not yet '1' because RE is just being asserted to one
            -- Otherwise, the first data (i.e.) would be written twice and the
            -- last data would be discarded
            State_writing_r (curr_dst_resolved (i))  <= '1';
            re_r (i)                                 <= '1';
            State_reading_r (i)                      <= '1';
            state_src_r (curr_dst_resolved (i))      <= i;
            state_dst_r (i)                          <= curr_dst_resolved (i);

            send_counter_r (i)                       <= send_counter_r (i);  --??
            data_ctrl_fifo_r (curr_dst_resolved (i)) <= Incoming_data (i);
            data_reg_valid_r (curr_dst_resolved (i)) <= '1';

            --assert i/=1 report "Start" severity note;
            
          else
            -- Can't start reading from current source
            -- Do nothing
          end if;  --State_reading_r = i
        end if;  --State_reading_r(i)=1
        
      end loop;  -- i



      
    end if;  --rst_n/clk'event
  end process Main_control;






  
end rtl;
