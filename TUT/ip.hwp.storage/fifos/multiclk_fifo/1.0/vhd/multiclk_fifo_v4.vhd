-------------------------------------------------------------------------------
-- Title      : Multiclock FIFO
-- Project    : 
-------------------------------------------------------------------------------
-- File       : multiclk_fifo.vhd
-- Author     : kulmala3
-- Created    : 16.12.2005
-- Last update: 16.08.2006
-- Description: Synchronous multi-clock FIFO. Note that clock frequencies MUST
-- be related (synchronized) in order to avoid metastability.
-- Clocks that are asynchronous wrt. each other do not work.
--
-- Note! data must be ready in the data in wrt. faster clock when writing!
-- same applies for re and we
--
-- This one uses slow full and empty for the corresponding slower clock (i.e.
-- reader is slower -> empty is delayed). eg. empty transition from 1->0 is
-- delayed.
--
-- In this implementation we really utilize both clocks, whch can be a problem
-- in some systems (routing the another clock).
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 16.12.2005  1.0      AK      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity multiclk_fifo is
  
  generic (
    re_freq_g    : integer := 1;        -- integer multiple of clk_we
    we_freq_g    : integer := 1;        -- or vice versa
    depth_g      : integer := 0;
    data_width_g : integer := 0
    );
  port (
    clk_re : in std_logic;
    clk_we : in std_logic;
    rst_n  : in std_logic;

    data_in   : in  std_logic_vector (data_width_g-1 downto 0);
    we_in     : in  std_logic;
    full_out  : out std_logic;
    one_p_out : out std_logic;

    re_in     : in  std_logic;
    data_out  : out std_logic_vector (data_width_g-1 downto 0);
    empty_out : out std_logic;
    one_d_out : out std_logic
    );
end multiclk_fifo;

architecture rtl of multiclk_fifo is

  component fifo
    generic (
      data_width_g : integer;
      depth_g      : integer);
    port (
      clk       : in  std_logic;
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

  constant re_per_we_c : integer := re_freq_g / we_freq_g;
  constant we_per_re_c : integer := we_freq_g / re_freq_g;

  -- no 0 to x-1, cuz otherwise range 0 to -1 is possible
  signal re_cnt_r : integer range 0 to re_per_we_c;
  signal we_cnt_r : integer range 0 to we_per_re_c;

  signal data_to_fifo    : std_logic_vector (data_width_g-1 downto 0);
  signal we_to_fifo      : std_logic;
  signal full_from_fifo  : std_logic;
  signal one_p_from_fifo : std_logic;
  signal re_to_fifo      : std_logic;
  signal data_from_fifo  : std_logic_vector (data_width_g-1 downto 0);
  signal empty_from_fifo : std_logic;
  signal one_d_from_fifo : std_logic;
  signal empty_out_r : std_logic;
  signal full_out_r : std_logic;
  
  signal clk_fifo : std_logic;
  signal slow_r : std_logic;            -- frequncy halver for slower clock
  signal slow_was_r : std_logic;
  signal rst_cnt : std_logic;
  signal clk_slow : std_logic;
begin  -- rtl

  data_to_fifo <= data_in;
  full_out     <= full_out_r; --from_fifo;
  one_p_out    <= one_p_from_fifo;
  data_out     <= data_from_fifo;
  empty_out    <= empty_out_r; --empty_from_fifo;
  one_d_out    <= one_d_from_fifo;

    regular_fifo: fifo
      generic map (
        data_width_g => data_width_g,
        depth_g      => depth_g)
      port map (
        clk       => clk_fifo,            -- this is the difference
        rst_n     => rst_n,
        data_in   => data_to_fifo,
        we_in     => we_to_fifo,
        full_out  => full_from_fifo,
        one_p_out => one_p_from_fifo,
        re_in     => re_to_fifo,
        data_out  => data_from_fifo,
        empty_out => empty_from_fifo,
        one_d_out => one_d_from_fifo
        );

  process (clk_slow, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      slow_r <= '0';
    elsif clk_slow'event and clk_slow = '1' then  -- rising clock edge
      slow_r <= not slow_r;
    end if;
  end process;

  process (clk_fifo, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      slow_was_r <= '0';
    elsif clk_fifo'event and clk_fifo = '1' then  -- rising clock edge
      slow_was_r <= slow_r;
    end if;
  end process;
  
  nullify: process (slow_r, slow_was_r)
  begin  -- process nullify
    rst_cnt <= slow_was_r xor slow_r;
  end process nullify;
  
  re_gt_we : if re_freq_g >= we_freq_g generate
    clk_fifo <= clk_re;
    clk_slow <= clk_we;
    
    re_to_fifo <= re_in;

    equal : if re_per_we_c = 1 generate
      we_to_fifo <= we_in;
      empty_out_r <= empty_from_fifo;
      full_out_r <= full_from_fifo;
    end generate equal;

    greater : if re_per_we_c > 1 generate
      -- re clk is faster than we
      
      gen_we : process (re_cnt_r, we_in, rst_cnt)
      begin  -- process gen_we
        if we_in = '1' then
          if re_cnt_r = re_per_we_c-2 and rst_cnt = '0' then
            we_to_fifo <= '1';
          else
            we_to_fifo <= '0';
          end if;
        else
          we_to_fifo <= '0';
        end if;
      end process gen_we;

      empty_out_r <= empty_from_fifo;
      
      process (clk_re, rst_n)
      begin  -- process
        if rst_n = '0' then             -- asynchronous reset (active low)
          re_cnt_r <= 0;
          
        elsif clk_re'event and clk_re = '1' then  -- rising clock edge
          if rst_cnt = '1' then
            re_cnt_r <= 0;
          else
            re_cnt_r <= re_cnt_r+1;
          end if;

          if re_cnt_r = 0 then
            full_out_r <= full_from_fifo;
          else
            full_out_r <= full_out_r;
          end if;
                    
        end if;
      end process;
      
      
    end generate greater;

    
  end generate re_gt_we;

  we_gt_re : if re_freq_g < we_freq_g generate

    clk_fifo <= clk_we;
    clk_slow <= clk_re;
    we_to_fifo <= we_in;

    -- we clk is faster than re
      gen_we : process (we_cnt_r, re_in, rst_cnt)
      begin  -- process gen_we
        if re_in = '1' then
          if we_cnt_r = we_per_re_c-2 and rst_cnt = '0' then
            re_to_fifo <= '1';
          else
            re_to_fifo <= '0';
          end if;
        else
          re_to_fifo <= '0';
        end if;

      end process gen_we;

    full_out_r <= full_from_fifo;
    
      process (clk_we, rst_n)
      begin  -- process
        if rst_n = '0' then             -- asynchronous reset (active low)
          we_cnt_r <= 0;
          empty_out_r <= '1';
          
        elsif clk_we'event and clk_we = '1' then  -- rising clock edge
          if rst_cnt = '1' then
            we_cnt_r <= 0;
          else
            we_cnt_r <= we_cnt_r+1;
          end if;

          if we_cnt_r = 0 then
            empty_out_r <= empty_from_fifo;
          else
            empty_out_r <= empty_out_r;
          end if;
          
        end if;
      end process;
      

  end generate we_gt_re;
  
end rtl;
