-------------------------------------------------------------------------------
-- File        : packet_decoder_ctrl.vhdl
-- Description : Control of the packet encoder
--
-- Author      : Vesa Lahtinen
-- Date        : 23.10.2003
-- Modified    : 
-- 28.04.2005    ES Names changed
-- 03.05.2005    ES use at max 32bits for conv_integer parameter
-- 25.01.0226    ES Removed unnecessary generics, changed amount from latch to reg
-- 07.08.2006    AR Removed decoder_format_g, changed src_id to dst_addr
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity packet_decoder_ctrl is

  generic (
    data_width_g    : integer := 36;
    addr_width_g    : integer := 32;
    --decoder_format_g      : INTEGER := 0;  -- are headers forwarded to fifo
    pkt_len_g       : integer := 0;
    -- write_counter_max_g   : INTEGER := 0;
    -- amount_max_g          : INTEGER := 0;  -- NOT USED !!!
    fill_packet_g   : integer := 0;
    len_flit_en_g   : integer := 1;     -- 2007/08/03 where to place a pkt_len
    oaddr_flit_en_g : integer := 1;     -- 2007/08/03 whether to send the orig address
    dbg_en_g        : integer := 0;
    dbg_width_g     : integer := 1
    );

  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    net_data_in  : in  std_logic_vector (data_width_g-1 downto 0);
    net_empty_in : in  std_logic;
    net_re_out   : out std_logic;

    fifo_full_in  : in  std_logic;
    fifo_av_out   : out std_logic;
    fifo_data_out : out std_logic_vector (data_width_g-1 downto 0);
    fifo_we_out   : out std_logic;
    dbg_out       : out std_logic_vector(dbg_width_g - 1  downto 0)
    );

end packet_decoder_ctrl;


architecture rtl of packet_decoder_ctrl is

  type   state_type is (start, read_address, read_amount, read_dst_addr, read_data);
  signal curr_state_r, next_state : state_type;

  -- SIGNAL write_counter_r   : INTEGER RANGE 0 TO write_counter_max_g;
  signal write_counter_r : integer range 0 to pkt_len_g;

  signal amount_r : integer range 0 to pkt_len_g;

  -- 2007/08/06
  constant len_width_c : integer := 8;  -- bits needed for pkt_len, will be generic someday?

  
begin

-- purpose: Clocked process for changing the state
-- type   : sequential
-- inputs : clk, rst_n, next_state
-- outputs: curr_state_r, write_counter_r
  
  sync : process (clk, rst_n)

  begin  -- PROCESS sync

    if rst_n = '0' then
      curr_state_r    <= start;
      write_counter_r <= 0;
      
    elsif clk = '1' and clk'event then
      curr_state_r <= next_state;

      amount_r        <= 0;
      write_counter_r <= 0;

      case curr_state_r is

        when read_address =>
          -- 2007/08/06
          if len_flit_en_g = 0 and net_empty_in = '0' then
              amount_r <= conv_integer(net_data_in (data_width_g - 1 downto data_width_g - len_width_c))- oaddr_flit_en_g;  -- 2007/08/03
          end if;
              
        
        when read_amount =>

          if len_flit_en_g = 1 and net_empty_in = '0' then -- 25.08.2006 AK 
            
            if data_width_g < 32 then
              -- amount_r <= conv_integer(net_data_in)-1;  -- orig
              amount_r <= conv_integer(net_data_in)- oaddr_flit_en_g;  -- 2007/08/03
            else
              -- Otherwise integer overflow may occur. 03.05.2005 ES
              -- amount_r <= conv_integer(net_data_in (32-1 downto 0))-1;  -- orig
              amount_r <= conv_integer(net_data_in (32-1 downto 0))- oaddr_flit_en_g;  -- 2007/08/03
            end if;

          else
            amount_r <= amount_r;
          end if;

        when read_dst_addr =>
          amount_r <= amount_r;

        when read_data =>
          amount_r <= amount_r;

          if (fifo_full_in = '0')          -- then
            and (net_empty_in = '0') then  --this condition 23.08.2006
            -- IF (write_counter_r = write_counter_max_g) THEN
            if (write_counter_r = pkt_len_g) then
              write_counter_r <= write_counter_r;
            else
              write_counter_r <= write_counter_r + 1;
            end if;
          else
            write_counter_r <= write_counter_r;
          end if;

        when others => null;
      end case;
      
      
    end if;

  end process sync;

  -- purpose: Asynchronous process for generating outputs and the next state
  -- type   : combinational
  -- inputs : net_data_in, net_empty_in,
  --          fifo_full_in, curr_state_r
  -- outputs: net_re_out, fifo_data_out, fifo_av_out,
  --          fifo_we_out, write_counter_r
  
  async : process (net_data_in, net_empty_in, fifo_full_in,
                   write_counter_r, amount_r, curr_state_r)

  begin  -- PROCESS async

    case curr_state_r is

      when start =>

        net_re_out    <= '0';
        fifo_data_out <= (others => '0');
        fifo_av_out   <= '0';
        fifo_we_out   <= '0';

        if (net_empty_in = '0' and fifo_full_in = '0') then
          next_state <= read_address;
        else
          next_state <= start;
        end if;

        
      when read_address =>


        fifo_data_out (data_width_g -1 downto data_width_g - len_width_c) <= (others => '0');
        fifo_data_out (data_width_g - len_width_c -1 downto 0)            <= net_data_in (data_width_g - len_width_c -1 downto 0);
        -- fifo_data_out <= net_data_in;

        if oaddr_flit_en_g = 0 then
          -- One address must be written to fifo
          -- It is this if orig_addr is disbaled
          fifo_av_out <= '1';
          fifo_we_out <= '1';
        end if;

        if (fifo_full_in = '0' and net_empty_in = '0') then
            next_state    <= read_amount;
            net_re_out    <= '1';

        else
          next_state  <= read_address;
          net_re_out  <= '0';
          fifo_we_out <= '0';
        end if;


      when read_amount =>

        fifo_data_out <= net_data_in;
        fifo_av_out   <= '0';


        if (net_empty_in = '0' and fifo_full_in = '0') then

          fifo_we_out <= '0';
          
          if len_flit_en_g = 1 then
            net_re_out  <= '1';
          else
            net_re_out  <= '0';            
          end if;

          -- Brach 2007/08/03
          if oaddr_flit_en_g = 1 then
            next_state  <= read_dst_addr;
          else
            next_state  <= read_data;
          end if;

        else
          next_state  <= read_amount;
          fifo_we_out <= '0';
          net_re_out  <= '0';
        end if;
        
        
      when read_dst_addr =>

        fifo_data_out <= net_data_in;
        fifo_av_out   <= '1';

        if (fifo_full_in = '0' and net_empty_in = '0') then
          next_state  <= read_data;
          net_re_out  <= '1';
          fifo_we_out <= '1';

        else
          next_state  <= read_dst_addr;
          net_re_out  <= '0';
          fifo_we_out <= '0';
        end if;


        
      when read_data =>                 -- read_data

        fifo_data_out <= net_data_in;
        fifo_av_out   <= '0';



        -- 23.08.2006, es
        --  - added check for net_empty=0
        --  - moved definition of next_state inside above if-else
        --  - changed pkt_len-3 to pkt_len-4
        --  Seems to work at least with tb_hemres_lat
        if (fifo_full_in = '0')         --  then
          and net_empty_in = '0' then   -- this condition 23.08.2006


          -- 20.10.2006 testailua hermesta varten
          if ((write_counter_r = amount_r-1 and fill_packet_g = 0)
              or
              --(write_counter_r = pkt_len_g-4 and fill_packet_g = 1)
              (write_counter_r = pkt_len_g-1-1-len_flit_en_g-oaddr_flit_en_g and fill_packet_g = 1)
              ) then
            next_state <= start;
          else
            next_state <= read_data;
          end if;


          if (write_counter_r < amount_r) then
            -- Verkosta luetaan vakiomäärä
            -- eli vaikka siellä oleva fifo olisikin tyhjä
            fifo_we_out <= '1';
            net_re_out  <= '1';
          else
            fifo_we_out <= '0';
            net_re_out  <= '1';

          end if;

        else
          fifo_we_out <= '0';
          net_re_out  <= '0';
          next_state  <= read_data;     -- 23.03.2006
        end if;
        
        
    end case;
    

  end process async;
  
end rtl;
