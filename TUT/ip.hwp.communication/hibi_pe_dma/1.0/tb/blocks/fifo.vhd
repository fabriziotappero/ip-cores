-------------------------------------------------------------------------------
-- File        : fifo.vhdl
-- Description : Fifo buffer for hibi interface
-- Author      : Erno Salminen
-- e-mail      : erno.salminen@tut.fi
-- Project     : mikälie
-- Design      : Do not use term design when you mean system
-- Date        : 29.04.2002
-- Modified    : 30.04.2002 Vesa Lahtinen Optimized for synthesis
--
-- 15.12.04     ES: names changed
-------------------------------------------------------------------------------
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

entity fifo is

  generic (
    data_width_g :    integer := 32;
    depth_g      :    integer := 5
    );
  port (
    clk          : in std_logic;
    rst_n        : in std_logic;

    data_in   : in  std_logic_vector (data_width_g-1 downto 0);
    we_in     : in  std_logic;
    full_out  : out std_logic;
    one_p_out : out std_logic;

    re_in     : in  std_logic;
    data_out  : out std_logic_vector (data_width_g-1 downto 0);
    empty_out : out std_logic;
    one_d_out : out std_logic
    );

end fifo;

architecture behavioral of fifo is


  -- Registers
  signal full_r        : std_logic;
  signal empty_r       : std_logic;
  signal one_d_r       : std_logic;
  signal one_p_r       : std_logic;
  signal data_amount_r : std_logic_vector (depth_g-1 downto 0);

  signal in_ptr_r  : integer range 0 to depth_g-1;
  signal out_ptr_r : integer range 0 to depth_g-1;

  type data_arr_type is array (depth_g-1 downto 0) of std_logic_vector (data_width_g-1 downto 0);
  signal fifo_buffer_r : data_arr_type;


begin  -- behavioral

  -- Continuous assignments
  -- Assigns register values to outputs
  full_out  <= full_r;
  empty_out <= empty_r;
  one_d_out <= one_d_r;
  one_p_out <= one_p_r;
  data_out  <= fifo_buffer_r (out_ptr_r);   -- mux at output!
  -- Note! There is some old value in data output when fifo is empty.

  
Main : process (clk, rst_n)
begin  -- process Main
  if rst_n = '0' then                   -- asynchronous reset (active low)

    -- Reset all registers
    -- Fifo is empty at first
    full_r        <= '0';
    empty_r       <= '1';
    one_d_r       <= '0';
    in_ptr_r      <= 0;
    out_ptr_r     <= 0;
    data_amount_r <= (others => '0');

    if depth_g =1 then                    -- 30.07
      one_p_r <= '1';
    else
      one_p_r <= '0';      
    end if;

    for i in 0 to depth_g-1 loop
      fifo_buffer_r (i) <= (others => '0');
    end loop;  -- i

  elsif clk'event and clk = '1' then    -- rising clock edge


    -- 1) Write data to fifo
    if we_in = '1' and re_in = '0' then

      if full_r = '0' then
        empty_r                <= '0';
        if (in_ptr_r = (depth_g-1)) then
          in_ptr_r               <= 0;
        else
          in_ptr_r               <= in_ptr_r + 1;
        end if;
        out_ptr_r                <= out_ptr_r;
        data_amount_r          <= data_amount_r +1;
        fifo_buffer_r (in_ptr_r) <= data_in;

        -- Check if the fifo is getting full
        if data_amount_r + 2 = depth_g then
          full_r  <= '0';
          one_p_r <= '1';
        elsif data_amount_r +1 = depth_g then
          full_r  <= '1';
          one_p_r <= '0';
        else
          full_r  <= '0';
          one_p_r <= '0';
        end if;

        -- If fifo was empty, it has now one data 
        if empty_r = '1' then
          one_d_r <= '1';
        else
          one_d_r <= '0';
        end if;

      else
        in_ptr_r        <= in_ptr_r;
        out_ptr_r       <= out_ptr_r;
        full_r        <= full_r;
        empty_r       <= empty_r;
        fifo_buffer_r <= fifo_buffer_r;
        data_amount_r <= data_amount_r;
        one_d_r       <= one_d_r;
        one_p_r       <= one_p_r;
      end if;

      
    -- 2) Read data from fifo  
    elsif we_in = '0' and re_in = '1' then

      if empty_r = '0' then
        in_ptr_r        <= in_ptr_r;
        if (out_ptr_r = (depth_g-1)) then
          out_ptr_r     <= 0;
        else
          out_ptr_r     <= out_ptr_r + 1;
        end if;
        full_r        <= '0';
        data_amount_r <= data_amount_r -1;

        -- Debug
        -- fifo_buffer_r (out_ptr_r) <= (others => '1');

        -- Check if the fifo is getting empty
        if data_amount_r = 2 then
          empty_r <= '0';
          one_d_r <= '1';
        elsif data_amount_r = 1 then
          empty_r <= '1';
          one_d_r <= '0';
        else
          empty_r <= '0';
          one_d_r <= '0';
        end if;

        -- If fifo was full, it is no more 
        if full_r = '1' then
          one_p_r <= '1';
        else
          one_p_r <= '0';
        end if;

      else
        in_ptr_r        <= in_ptr_r;
        out_ptr_r       <= out_ptr_r;
        full_r        <= full_r;
        empty_r       <= empty_r;
        fifo_buffer_r <= fifo_buffer_r;
        data_amount_r <= data_amount_r;
        one_d_r       <= one_d_r;
        one_p_r       <= one_p_r;
      end if;


    -- 3) Write and read at the same time  
    elsif we_in = '1' and re_in = '1' then
      

      if full_r = '0' and empty_r = '0' then
        if (in_ptr_r = (depth_g-1)) then
          in_ptr_r    <= 0;
        else
          in_ptr_r    <= in_ptr_r + 1;
        end if;
        if (out_ptr_r = (depth_g-1)) then
          out_ptr_r   <= 0;
        else
          out_ptr_r   <= out_ptr_r + 1;
        end if;
        full_r        <= '0';
        empty_r       <= '0';
        data_amount_r <= data_amount_r;
        one_d_r       <= one_d_r;
        one_p_r       <= one_p_r;

        fifo_buffer_r (in_ptr_r)  <= data_in;
        -- fifo_buffer_r (out_ptr_r) <= (others => '1');  --debug


      elsif full_r = '1' and empty_r = '0' then
        -- Fifo is full, only reading is possible
        in_ptr_r        <= in_ptr_r;
        if (out_ptr_r = (depth_g-1)) then
          out_ptr_r     <= 0;
        else
          out_ptr_r     <= out_ptr_r + 1;
        end if;
        full_r        <= '0';
        one_p_r       <= '1';
        --fifo_buffer_r (out_ptr_r) <= (others => '1');  -- Debug
        data_amount_r <= data_amount_r -1;

        -- Check if the fifo is getting empty
        if data_amount_r = 2 then
          empty_r <= '0';
          one_d_r <= '1';
        elsif data_amount_r = 1 then
          empty_r <= '1';
          one_d_r <= '0';
        else
          empty_r <= '0';
          one_d_r <= '0';
        end if;


      elsif full_r = '0' and empty_r = '1' then
        -- Fifo is empty, only writing is possible
        if (in_ptr_r = (depth_g-1)) then
          in_ptr_r               <= 0;
        else
          in_ptr_r               <= in_ptr_r + 1;
        end if;
        out_ptr_r                <= out_ptr_r;
        empty_r                  <= '0';
        one_d_r                  <= '1';
        fifo_buffer_r (in_ptr_r) <= data_in;
        data_amount_r            <= data_amount_r +1;

        -- Check if the fifo is getting full
        if data_amount_r + 2 = depth_g then
          full_r  <= '0';
          one_p_r <= '1';
        elsif data_amount_r +1 = depth_g then
          full_r  <= '1';
          one_p_r <= '0';
        else
          full_r  <= '0';
          one_p_r <= '0';
        end if;


      -- 4) Do nothing, fifo remains idle 
      else

        in_ptr_r      <= in_ptr_r;
        out_ptr_r     <= out_ptr_r;
        full_r        <= full_r;
        empty_r       <= empty_r;
        fifo_buffer_r <= fifo_buffer_r;
        data_amount_r <= data_amount_r;
        one_d_r       <= one_d_r;
        one_p_r       <= one_p_r;
      end if;

    else
      -- Fifo is idle
      in_ptr_r      <= in_ptr_r;
      out_ptr_r     <= out_ptr_r;
      full_r        <= full_r;
      empty_r       <= empty_r;
      fifo_buffer_r <= fifo_buffer_r;
      data_amount_r <= data_amount_r;
      one_d_r       <= one_d_r;
      one_p_r       <= one_p_r;
    end if;

  end if;
end process Main;

end behavioral;
