-------------------------------------------------------------------------------
-- Title      : fifo
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fifo_ram.vhd
-- Author     : 
-- Company    : 
-- Created    : 2005-05-26
-- Last update: 2005-05-31
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: fifo implemented with dual port RAM with asynchronous read
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2005-05-26  1.0      penttin5        Created
-------------------------------------------------------------------------------
--
-- NOTE! Precision RTL synthesisis 2004c.45 doesn't infer the RAM with
--       asynchronous read for Stratix 1 S40F780C5.
--       Quartus II 4.2 infers RAM with asynchronic read but gives old RAM value
--       when reading and writing simultaneusly to/from same address.
--       That doesn't matter because FIFO doesn't read and write in the same
--       address at the same time.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fifo is
  
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

end fifo;

architecture rtl of fifo is

  component dual_ram_async_read
    generic (
      ram_width : integer := 0;
      ram_depth : integer := 0);
    port
      (
        clock1        : in  std_logic;
        clock2        : in  std_logic;
        data          : in  std_logic_vector(0 to ram_width - 1);
        write_address : in  integer range 0 to ram_depth - 1;
        read_address  : in  integer range 0 to ram_depth - 1;
        we            : in  std_logic;
        q             : out std_logic_vector(0 to ram_width - 1)
        );
  end component;  -- dual_ram_async_read

  signal write_address_r    : integer range 0 to depth_g - 1;
  signal read_address_r     : integer range 0 to depth_g - 1;
  signal write_read_count_r : integer range 0 to depth_g;
  signal ram_data_out_i     : std_logic_vector(0 to data_width_g - 1);
  signal we_ram             : std_logic;
  attribute dont_touch : boolean;
  attribute dont_touch of gen_dual_ram: label is true;
begin  -- rtl
  
  gen_dual_ram : dual_ram_async_read
    generic map (
      ram_width => data_width_g,
      ram_depth => depth_g
      )
    port map (
      clock1        => clk,
      clock2        => clk,
      data          => data_in,
      write_address => write_address_r,
      read_address  => read_address_r,
      we            => we_ram,
      q             => ram_data_out_i
      );

  -- write to fifo when write enabled and fifo not full
  we_ram <= we_in when write_read_count_r /= depth_g
            else '0';

  data_out <= ram_data_out_i;

  one_d_out <= '1' when write_read_count_r = 1 else
               '0';
  one_p_out <= '1' when write_read_count_r = depth_g - 1 else
               '0';
  empty_out <= '1' when write_read_count_r = 0 else
               '0';
  full_out <= '1' when write_read_count_r = depth_g else
              '0';

  -----------------------------------------------------------------------------
  -- Update read and write addresses
  -----------------------------------------------------------------------------
  fifo_read_and_write : process (clk, rst_n)

  begin  -- process fifo_read_and_write

    if rst_n = '0' then                 -- asynchronous reset (active low)
      write_read_count_r <= 0;
      read_address_r     <= 0;
      write_address_r    <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- read if re_in = '1' and fifo not empty or
      --         simultaneus read and write and fifo full
      if re_in = '1' and ((we_in = '0' and write_read_count_r /= 0)
                          or (we_in = '1' and write_read_count_r = depth_g)) then
        write_read_count_r <= write_read_count_r - 1;
        if read_address_r = depth_g - 1 then
          read_address_r <= 0;
        else
          read_address_r <= read_address_r + 1;
        end if;
        write_address_r <= write_address_r;

      -- write if we_in = '1' and fifo not full or
      --          simultaneus read and write and fifo empty
      elsif we_in = '1' and ((re_in = '0' and write_read_count_r /= depth_g)
                             or (re_in = '1' and write_read_count_r = 0)) then
        write_read_count_r <= write_read_count_r + 1;
        read_address_r     <= read_address_r;
        if write_address_r = depth_g - 1 then
          write_address_r <= 0;
        else
          write_address_r <= write_address_r + 1;
        end if;

      -- write and read at the same time if re_in = '1' and we_in = '1' and
      -- fifo not empty or full
      elsif re_in = '1' and we_in = '1' and write_read_count_r /= depth_g and write_read_count_r /= 0 then
        write_read_count_r <= write_read_count_r;
        if read_address_r = depth_g - 1 then
          read_address_r <= 0;
        else
          read_address_r <= read_address_r + 1;
        end if;
        if write_address_r = depth_g - 1 then
          write_address_r <= 0;
        else
          write_address_r <= write_address_r + 1;
        end if;
      else
        write_read_count_r <= write_read_count_r;
        read_address_r     <= read_address_r;
        write_address_r    <= write_address_r;
      end if;
    end if;
  end process fifo_read_and_write;

end rtl;
