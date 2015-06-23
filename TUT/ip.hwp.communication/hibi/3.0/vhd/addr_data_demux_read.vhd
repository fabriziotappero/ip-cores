-------------------------------------------------------------------------------
-- File :       addr_data_demux_read.vdh
-- Description: Reads addr and data sequentially and outputs them in parallel.
--              Can be used, e.g., in interfacing HIBI with IP.
--
-- Project:
-- Author:     Erno Salminen
-- Date :      2003
-- Modified:
-- 06.08.2004   ES, one_data_in/out removed
--
-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This file is part of HIBI
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


entity addr_data_demux_read is

  generic (
    data_width_g : integer := 0;
    addr_width_g : integer := 0;
    comm_width_g : integer := 0
    );
  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    av_in    : in  std_logic;
    data_in  : in  std_logic_vector (data_width_g-1 downto 0);
    comm_in  : in  std_logic_vector (comm_width_g-1 downto 0);
    empty_in : in  std_logic;
    re_out   : out std_logic;

    re_in     : in  std_logic;
    addr_out  : out std_logic_vector (addr_width_g-1 downto 0);
    data_out  : out std_logic_vector (data_width_g-1 downto 0);
    comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
    empty_out : out std_logic
    );

end addr_data_demux_read;


architecture rtl of addr_data_demux_read is

  signal addr_r   : std_logic_vector (addr_width_g-1 downto 0);
  signal re_r     : std_logic;
  signal rd_rdy_r : std_logic;

  
begin  -- rtl

  -- 1) COMB PROC
  Read_fifo : process (re_in, re_r, empty_in, av_in)
  begin  -- process Read_fifo

    -- 21.01.2003 kokeilukorjaus, saa n‰hd‰ toimiiko jos IP pit‰‰ koko ajan re=1
    if empty_in = '1' then
      -- Fifossa ei ole mitaan
      re_out <= '0';
    else
      if av_in = '1' then
        -- Demux reads addr
        re_out <= re_r;
      else
        -- IP reads data
        re_out <= re_in;
      end if;
    end if;
    
  end process Read_fifo;


  -- 2) COMB PROC
  Assign_empty_out : process (empty_in, av_in)
  begin  -- process Assign_empty_out
    -- addr must read to register before it is tramsferred to reader.
    -- Therefore, empty_out is asserted until addr is read from fifo. 
    
    if empty_in = '1' then
      -- Fifossa ei ole mitaan
      empty_out <= '1';
    else
      if av_in = '1' then
        empty_out <= '1';
      else
        empty_out <= '0';
      end if;
    end if;
  end process Assign_empty_out;


  -- 3) COMB PROC
  Demux_addr_data : process (data_in, av_in, comm_in,
                             addr_r, empty_in)
  begin  -- process Demux_addr_data
    -- Fifo outputs are directed outputs when addr has been read to register
    -- and there is data coming from fifo

    
    if empty_in = '0' and av_in = '0' then
      -- data coming from fifo
      data_out <= data_in;
      addr_out <= addr_r;
      comm_out <= comm_in;
    else
      -- addr coming fifo or fifo empty 
      data_out <= (others => '0');
      addr_out <= (others => '0');
      comm_out <= (others => '0');
    end if;
  end process Demux_addr_data;


  -- 4) SEQ PROC
  Store_addr : process (clk, rst_n)
  begin  -- process Store_addr
    -- Reads addr from fifo to register
    -- read_ready goes 1 after each fifo read operation, either initiated
    --  + by demux (=addr read). 
    --  + by reader ip (=data read).
    -- read_ready remains 1, if fifo became empty
    --  
    --  Read goes 0 if fifo is not empty and no read operation is performed,
    --  see above.

    
    if rst_n = '0' then                 -- asynchronous reset (active low)
      addr_r   <= (others => '0');
      re_r     <= '0';
      rd_rdy_r <= '1';

    elsif clk'event and clk = '1' then  -- rising clock edge

      if empty_in = '1' then
        -- Fifo is empty, keep state
        addr_r   <= addr_r;
        re_r     <= '0';
        rd_rdy_r <= rd_rdy_r;

      else
        -- Fifo not empty

        if av_in = '1' then
          -- Fifo has addr, read it
          addr_r <= data_in(addr_width_g-1 downto 0);

          -- Keep RE=1 for one cycle
          if re_r = '0' then
            re_r     <= '1';
            rd_rdy_r <= '0';
          else
            re_r     <= '0';
            rd_rdy_r <= '1';
          end if;  --re_r

          --assert false report "New addr in fifo" severity note;

        else
          -- Fifossa on lukematon data
          addr_r <= addr_r;
          re_r   <= '0';

          if re_in = '1' then
            -- Reader ip perfroms read operation
            rd_rdy_r <= '1';
            --assert false report "IP reads addr+data" severity note;
          else
            -- Wait, until read ip performs read operation
            rd_rdy_r <= '0';
            --assert false report "Wait for IP to read addr+data" severity note;            
          end if;  --re_in

        end if;  --av        
      end if;  --empty_in
    end if;  --rst_n    
  end process Store_addr;
  
end rtl;  --addr_data_demux_read
