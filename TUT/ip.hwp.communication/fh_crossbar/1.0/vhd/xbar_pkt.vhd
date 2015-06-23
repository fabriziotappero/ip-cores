-------------------------------------------------------------------------------
-- File        : xbar_pkt.vhd
-- Description : Simple crossbar switch. based on mesh_router.
--              Actually, this is simple router with arbitrary number of ports.
--               Crossbar uses packets.
-- Author      : Erno Salminen
-- Date        : 28.08.2006
-- Modified    : 
-- 28.08.2006   ES Derived from mesh_router
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

entity xbar_pkt is
  generic (
    stfwd_en_g   :    integer := 1;     --24.08.2006 es
    n_ag_g       :    integer;
    data_width_g :    integer;
    pkt_len_g    :    integer;          -- 2006/10/25, depth must be > 2 words
    fifo_depth_g :    integer;
    ip_freq_g    :    integer := 1;     -- relative IP frequency
    net_freq_g   :    integer := 1      --relative router frequency
    );
  port (
    clk_ip       : in std_logic;
    clk_net      : in std_logic;
    rst_n        : in std_logic;

    tx_data_in    : in  std_logic_vector(n_ag_g * data_width_g - 1 downto 0);
    tx_we_in      : in  std_logic_vector(n_ag_g - 1 downto 0);
    tx_empty_out  : out std_logic_vector(n_ag_g - 1 downto 0);
    tx_full_out   : out std_logic_vector(n_ag_g - 1 downto 0);

    rx_data_out  : out std_logic_vector(n_ag_g * data_width_g - 1 downto 0);
    rx_re_in     : in  std_logic_vector(n_ag_g - 1 downto 0);
    rx_empty_out : out std_logic_vector(n_ag_g - 1 downto 0);
    rx_full_out  : out std_logic_vector(n_ag_g - 1 downto 0)
    );
end xbar_pkt;



architecture rtl of xbar_pkt is


  constant addr_width_c : integer := data_width_g;
  
  -- Constants for accessing arrays (e.g. state_regs)
  constant N      : integer := 0;
  constant W      : integer := 1;
  constant S      : integer := 2;
  constant E      : integer := 3;
  constant Ip     : integer := 4;
  constant No_dir : integer := n_ag_g;       -- Illegal index



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

  -- Arrays are easier to handle than names with direction identification
  -- (e.g. data_arr(i) vs. data_N)
  type data_arr_type is array (n_ag_g-1 downto 0) of std_logic_vector (data_width_g-1 downto 0);
  type ctrl_arr_type is array (n_ag_g-1 downto 0) of std_logic;
  type source_type is array (n_ag_g-1 downto 0) of integer range 0 to n_ag_g;


  -- 17.03.2006
  type   counter_arr_type is array (n_ag_g-1 downto 0) of integer range 0 to pkt_len_g; --  --fifo_depth_g;
  signal send_counter_r : counter_arr_type;


  -- From fifos. Mapped directly to outputs pins 
  signal data_txf_xbar  : data_arr_type;
  signal data_txf_dbg   : data_arr_type;
  signal full_from_txf  : std_logic_vector (n_ag_g-1 downto 0);
  signal empty_from_txf : std_logic_vector (n_ag_g-1 downto 0);
  signal re_xbar_txf_r  : ctrl_arr_type;

  -- From ctrl
  signal data_xbar_rxf_r : data_arr_type;
  signal we_xbar_rxf_r   : ctrl_arr_type;
  signal full_from_rxf   : std_logic_vector (n_ag_g-1 downto 0);  --ctrl_arr_type;
  signal empty_from_rxf  : std_logic_vector (n_ag_g-1 downto 0);

  -- 24.10.2006. Try wormhole, combinatorial enable signals
  signal re_tmp : ctrl_arr_type;
  signal we_tmp : ctrl_arr_type;

  
  -- State registers
  signal State_writing_r : std_logic_vector (n_ag_g-1 downto 0);
  signal State_reading_r : std_logic_vector (n_ag_g-1 downto 0);

  -- state_src_r(i) tells which port the source for output port i
  signal state_src_r : source_type;

  -- state_dst_r(i) tells which port the destination for input port i
  signal state_dst_r : source_type;

  -- Marks which input is checked on current cycle
  signal curr_src_r : integer range 0 to n_ag_g-1;

  -- Decoded address in input port pointed by curr_src_r, _not_ a register!
  signal curr_dst : integer range 0 to n_ag_g;



  
begin  -- rtl



  map_infifos : for i in 0 to n_ag_g-1 generate
    tx_fifo   : multiclk_fifo
      generic map (
        re_freq_g    => net_freq_g,
        we_freq_g    => ip_freq_g,
        depth_g      => fifo_depth_g,
        data_width_g => data_width_g
        )
      port map (
        clk_re       => clk_net,
        clk_we       => clk_ip,
        rst_n        => rst_n,

        data_in  => tx_data_in ((i+1)*data_width_g-1 downto i*data_width_g),
        full_out => full_from_txf (i),
        we_in    => tx_we_in (i),

        -- Fifo outputs go ctrl logic
        data_out  => data_txf_xbar (i),
        empty_out => empty_from_txf (i),
        re_in     => re_tmp (i) --re_xbar_txf_r (i)
        );


    rx_fifo : multiclk_fifo
      generic map (
        re_freq_g    => ip_freq_g,
        we_freq_g    => net_freq_g,
        depth_g      => fifo_depth_g,
        data_width_g => data_width_g
        )
      port map (
        clk_re       => clk_ip,
        clk_we       => clk_net,
        rst_n        => rst_n,

        data_in  => data_xbar_rxf_r (i),
        full_out => full_from_rxf (i),
        we_in    => we_tmp (i), --we_xbar_rxf_r (i),

        -- Fifo outputs go ctrl logic
        data_out  => rx_data_out ((i+1)*data_width_g-1 downto i*data_width_g),
        empty_out => empty_from_rxf (i),
        re_in     => rx_re_in (i)
        );

    data_txf_dbg (i) <= data_txf_xbar (i) when empty_from_txf (i)='0' else (others => 'Z');
    
  end generate map_infifos;
  tx_empty_out <= empty_from_txf;
  tx_full_out  <= full_from_txf;

  rx_full_out  <= full_from_rxf;
  rx_empty_out <= empty_from_rxf;


  -- 13.09.2006
  read_en_tmp: process (--we_xbar_rxf_r,
                        re_xbar_txf_r,
                        empty_from_txf, --state_src_r,
                        state_dst_r, full_from_rxf)

  begin  -- process read_en_tmp
    for i in 0 to n_ag_g-1 loop

      -- i viittaa kohteeseen (fifo)
--      we_tmp (i) <= we_xbar_rxf_r (i)
--                    and (not (full_from_rxf (i)));


      -- i viittaa llähteeseen (=input_port)
      if state_dst_r (i) = No_dir then
        -- sisääntulossa i ei ole järkevää dataa
        re_tmp (i) <= '0';
      else
        -- ei lueta sisääntulosta i ellei
        --  a) tilakone ole lukemass sieltä (re_xbar_txf_r pitää olla 1)
        --  b) sisääntulossa ole validia dataa  (empty pitää olla 0)
        --  c) kohde ei ole varattu
        re_tmp (i) <= re_xbar_txf_r (i)
                      and (not empty_from_txf (i))
                      and (not full_from_rxf (state_dst_r (i)));
      end if;    
      
    end loop;  -- i
  end process read_en_tmp;

  
  
  -- PROC
  -- Check where the incoming packet is heading
  -- Input ports are handled one per clock cycle

  Check_dst : process (State_reading_r,
                       curr_src_r,
                       data_txf_xbar,
                       empty_from_txf,
                       full_from_txf)
  begin  -- process Check_dst
      
    -- new way
    if State_reading_r (curr_src_r) = '0'
      and ( (full_from_txf  ( curr_src_r) = '1' and stfwd_en_g=1)
           or
            (empty_from_txf (curr_src_r) = '0'and stfwd_en_g=0))
    then                                -- 1)
      curr_dst <= conv_integer (data_txf_xbar (curr_src_r)(addr_width_c-1 downto 0));      

     else                               --1)
       -- No packet on curr src port or read operation already started
      curr_dst <= No_dir;
    end if;


    
  end process Check_dst;



  Main_control : process (clk_net, rst_n)
  begin  -- process Main_control
    if rst_n = '0' then                 -- asynchronous reset (active low)
      for i in 0 to n_ag_g-1 loop
        data_xbar_rxf_r (i) <= (others => '0');  --'0');
        send_counter_r (i)  <= 0;
      end loop;  -- i

      we_xbar_rxf_r   <= (others => '0');
      re_xbar_txf_r   <= (others => '0');
      -- Write/Read_Enable signal seem to be identical
      -- to State_Writing/Reading ? 25.07.2003 
      State_writing_r <= (others => '0');
      State_reading_r <= (others => '0');
      state_src_r     <= (others => No_dir);
      state_dst_r     <= (others => No_dir);
      curr_src_r      <= N;


      we_tmp <= (others => '0');
      
    elsif clk_net'event and clk_net = '1' then  -- rising clock edge

      
      for i in 0 to n_ag_g-1 loop

        -- 2006/10/24
        -- i =target
        if state_src_r(i) = No_dir then
          we_tmp (i)  <= '0';
        else
          we_tmp(i) <= re_tmp (state_src_r (i));

        end if;

        
        -- Handle all directions
        -- Loop variable i refers to source port

        
        if State_reading_r (i) = '1' then
          -- Already reading from direction i 

          -- 17.03.2006 use counters to enable cut-through switching.
          -- The same thing works also with store-and-forward switching
          if send_counter_r (i) = pkt_len_g --fifo_depth_g
          then
            -- stop
            we_xbar_rxf_r (state_dst_r (i))   <= '0';
            re_xbar_txf_r (i)                 <= '0';
            data_xbar_rxf_r (state_dst_r (i)) <= (others => '0');  --Z');
            State_writing_r (state_dst_r (i)) <= '0';
            State_reading_r (i)               <= '0';
            state_src_r (state_dst_r (i))     <= No_dir;
            state_dst_r (i)                   <= No_dir;
            --assert false report "tx to north fifo completed" severity note;

            send_counter_r (i) <= 0;


          else
            -- Packet transfer not yet complete
            -- Continue transfer
            we_xbar_rxf_r (state_dst_r (i))   <= '1';
            State_writing_r (state_dst_r (i)) <= State_writing_r (state_dst_r (i));
            State_reading_r (i)               <= State_reading_r (i);
            state_src_r (state_dst_r (i))     <= state_src_r (state_dst_r (i));
            state_dst_r (i)                   <= state_dst_r (i);
            --assert false report "tx to north fifo in progress" severity note;

            --data_xbar_rxf_r (state_dst_r (i)) <= data_txf_xbar (i);
            --send_counter_r (i) <= send_counter_r (i) +1;
            -- 24.10.2006 ES
            if re_tmp (i) = '1' then
              send_counter_r (i)                <= send_counter_r (i) +1;
              data_xbar_rxf_r (state_dst_r (i)) <= data_txf_xbar (i);
            end if;

            
            -- if send_counter_r (i) = fifo_depth_g-1
            --  and full_from_rxf (state_dst_r(i)) = '0'
            if send_counter_r (i) = pkt_len_g-1 --fifo_depth_g-1
              and empty_from_txf (i) = '0'  -- 2006/10/24
              and full_from_rxf (state_dst_r(i)) = '0'
            then  
              re_xbar_txf_r (i) <= '0';
            else
              re_xbar_txf_r (i) <= '1';
            end if;

            
          end if;

        else
          -- Not yet reading from direction i 
          -- Check one direction (curr_src_r) per clock cycle
          -- for possible new transfers

          -- Direction i has to be current source,
          -- there must be valid address on port i
          -- and target fifo has to be empty (i.e. it is not full or reserved)
          if curr_src_r = i
            and curr_dst /= No_dir
            and empty_from_rxf (curr_dst) = '1'
            and State_writing_r (curr_dst) = '0'
          then
            -- Start reading

            data_xbar_rxf_r (curr_dst)   <= data_txf_xbar (curr_src_r);
            we_xbar_rxf_r (curr_dst)     <= '0';
            -- WE not yet '1' because RE is just being asserted to one
            -- Otherwise, the first data (i.e.) would be written twice and the
            -- last data would be discarded
            State_writing_r (curr_dst)   <= '1';
            re_xbar_txf_r (curr_src_r)   <= '1';
            State_reading_r (curr_src_r) <= '1';
            state_src_r (curr_dst)       <= curr_src_r;
            state_dst_r (curr_src_r)     <= curr_dst;

            send_counter_r (i) <= send_counter_r (i);  --??

          else
            -- Can't start reading from current source
            -- Do nothing
          end if;  --State_reading_r = i
        end if;  --State_reading_r(i)=1
        
      end loop;  -- i






      if curr_src_r = n_ag_g-1 then
        curr_src_r <= 0;
      else
        curr_src_r <= curr_src_r+1;        
      end if;
--      -- Change currect source for the next cycle
--      case curr_src_r is        
--         when N  => curr_src_r <= W;
--         when W  => curr_src_r <= S;
--         when S  => curr_src_r <= E;
--         when E  => curr_src_r <= Ip;
--         when Ip => curr_src_r <= N;
--         when others => curr_src_r <= N;
--      end case;

      
      
    end if;  --rst_n/clk'event
  end process Main_control;






  
end rtl;
