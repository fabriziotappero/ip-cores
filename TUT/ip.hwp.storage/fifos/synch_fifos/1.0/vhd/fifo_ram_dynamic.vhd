-------------------------------------------------------------------------------
-- Title      : fifo
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fifo_ram_dynamic.vhd
-- Author     : 
-- Company    : 
-- Created    : 2005-05-26
-- Last update: 2006-03-02
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Fifo w/dynamic depth implemented with dual port RAM
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2005-05-26  1.0      penttin5        Created
-------------------------------------------------------------------------------
--
-- NOTE! generic depth_g is the maximum depth of fifo
-- NOTE! Precision RTL synthesisis 2004c.45 doesn't infer the RAM with
--       asynchronous read for Stratix 1 S40F780C5.
--       Quartus II 4.2 infers RAM with asynchronic read but gives old RAM
--       value when reading and writing simultaneusly to/from same address.
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
    data_width_g : integer := 32;
    depth_g      : integer := 10        -- this is the maximum depth of fifo!
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

  -- this is the configuration RAM which holds the
  -- dynamic depth value at address 0
  component conf_ram
    port (
      address : in  std_logic_vector(3 downto 0);
      clock   : in  std_logic;
      q       : out std_logic_vector(7 downto 0)
      );
  end component;

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

  signal conf_ram_addr       : std_logic_vector(3 downto 0);
  signal depth_from_conf_ram : std_logic_vector(7 downto 0);
  signal dynamic_depth_r     : integer range 0 to depth_g;
  signal full_out_r          : std_logic;

begin  -- rtl

  conf_ram_inst : conf_ram
    port map (
      address => (others => '0'),
      clock   => clk,
      q       => depth_from_conf_ram
      );

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

  full_out <= full_out_r;
  -- write to fifo when write enabled and fifo not full
  we_ram <= we_in when full_out_r = '0'--write_read_count_r < dynamic_depth_r
            else '0';

  data_out <= ram_data_out_i;

--  one_d_out <= '1' when write_read_count_r = 1 else
--               '0';
--  one_p_out <= '1' when write_read_count_r = dynamic_depth_r - 1 else
--               '0';
--  empty_out <= '1' when write_read_count_r = 0 else
--               '0';
--  full_out <= '1' when write_read_count_r >= dynamic_depth_r else
--              '0';

  update_flags: process (clk, rst_n)
  begin  -- process update_flags
    if rst_n = '0' then                 -- asynchronous reset (active low)
      one_d_out <= '0';
      one_p_out <= '0';
      empty_out <= '1';
      full_out_r  <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge

      if (we_in = '0' and re_in = '0' and write_read_count_r = 1) or
        (we_in = '1' and re_in = '1' and write_read_count_r = 1) or
        (we_in = '1' and re_in = '0' and write_read_count_r = 0) or
        (we_in = '0' and re_in = '1' and write_read_count_r = 2) then
        one_d_out <= '1';
      else
        one_d_out <= '0';
      end if;

      if (we_in = '0' and re_in = '0' and write_read_count_r = dynamic_depth_r - 1) or
        (we_in = '1' and re_in = '1' and write_read_count_r = dynamic_depth_r - 1) or
        (we_in = '1' and re_in = '0' and write_read_count_r = dynamic_depth_r - 2) or
        (we_in = '0' and re_in = '1' and write_read_count_r = dynamic_depth_r) then

        one_p_out <= '1';
      else
        one_p_out <= '0';
      end if;

      if (we_in = '0' and re_in = '0' and write_read_count_r = 0) or
        (we_in = '0' and re_in = '1' and write_read_count_r = 0) or
        (we_in = '0' and re_in = '1' and write_read_count_r = 1) then

        empty_out <= '1';
      else
        empty_out <= '0';
      end if;

      if (we_in = '0' and re_in = '0' and write_read_count_r = dynamic_depth_r) or
        (we_in = '1' and re_in = '0' and write_read_count_r = dynamic_depth_r) or
        (we_in = '1' and re_in = '0' and write_read_count_r = dynamic_depth_r - 1) or
        (write_read_count_r > dynamic_depth_r) then

        full_out_r <= '1';
      else
        full_out_r <= '0';
      end if;

    end if;
  end process update_flags;

  -----------------------------------------------------------------------------
  -- Update dynamic depth
  -----------------------------------------------------------------------------
  update_dynamic_depth_r : process (clk, rst_n)
  begin  -- process update_dynamic_depth_r
    if rst_n = '0' then                 -- asynchronous reset (active low)
      dynamic_depth_r <= depth_g;
      conf_ram_addr   <= (others => '0');

    elsif clk'event and clk = '1' then  -- rising clock edge
      conf_ram_addr <= (others => '0');

      if conv_integer(depth_from_conf_ram) > depth_g
        or depth_from_conf_ram =

        -- dynamic depth is bigger than maximum depth or
        -- it's not defined(zero) => Use the maximum depth
        conv_std_logic_vector(0, depth_from_conf_ram'length) then
        dynamic_depth_r <= depth_g;

      else

        -- update dynamic depth
        dynamic_depth_r <=
          conv_integer(depth_from_conf_ram);
      end if;

    end if;
  end process update_dynamic_depth_r;

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
                          or (we_in = '1'
                              and write_read_count_r = dynamic_depth_r)) then

        write_read_count_r <= write_read_count_r - 1;

        if read_address_r = dynamic_depth_r - 1 then
          read_address_r <= 0;
        else
          read_address_r <= read_address_r + 1;
        end if;
        write_address_r <= write_address_r;

        -- write if we_in = '1' and fifo not full or
        --          simultaneus read and write and fifo empty
      elsif we_in = '1' and ((re_in = '0' and
                              write_read_count_r /= dynamic_depth_r)
                             or (re_in = '1' and write_read_count_r = 0)) then
        write_read_count_r <= write_read_count_r + 1;
        read_address_r     <= read_address_r;
        if write_address_r = dynamic_depth_r - 1 then
          write_address_r <= 0;
        else
          write_address_r <= write_address_r + 1;
        end if;

        -- write and read at the same time if re_in = '1' and we_in = '1' and
        -- fifo not empty or full
      elsif re_in = '1' and we_in = '1'
        and write_read_count_r /= dynamic_depth_r
        and write_read_count_r /= 0 then
        write_read_count_r <= write_read_count_r;
        if read_address_r = dynamic_depth_r - 1 then
          read_address_r <= 0;
        else
          read_address_r <= read_address_r + 1;
        end if;
        if write_address_r = dynamic_depth_r - 1 then
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
