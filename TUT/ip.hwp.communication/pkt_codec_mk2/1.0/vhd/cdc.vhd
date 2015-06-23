-------------------------------------------------------------------------------
-- Title      : CDC (Clock Domain Crossing)
-- Project    : 
-------------------------------------------------------------------------------
-- File       : cdc.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2011-10-12
-- Last update: 2012-06-14
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
--
-- Generics:
-- 
-- clock_mode_g 0 : single clock
-- clock_mode_g 1 : two asynchronous clocks
--
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-10-12  1.0      lehton87        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity cdc is
  
  generic (
    cmd_width_g  : positive;
    data_width_g : positive;
    clock_mode_g : natural;
    len_width_g  : natural;
    fifo_depth_g : natural);

  port (
    clk_ip  : in std_logic;
    clk_net : in std_logic;
    rst_n   : in std_logic;

    ip_cmd_out  : out std_logic_vector(cmd_width_g-1 downto 0);
    ip_data_out : out std_logic_vector(data_width_g-1 downto 0);
    ip_stall_in : in  std_logic;

    ip_cmd_in    : in  std_logic_vector(cmd_width_g-1 downto 0);
    ip_data_in   : in  std_logic_vector(data_width_g-1 downto 0);
    ip_stall_out : out std_logic;

    ip_len_in : in std_logic_vector(len_width_g-1 downto 0);  -- 2012-05-04

    net_cmd_out  : out std_logic_vector(cmd_width_g-1 downto 0);
    net_data_out : out std_logic_vector(data_width_g-1 downto 0);
    net_stall_in : in  std_logic;

    net_len_out : out std_logic_vector(len_width_g-1 downto 0);  -- 2012-05-04

    net_cmd_in    : in  std_logic_vector(cmd_width_g-1 downto 0);
    net_data_in   : in  std_logic_vector(data_width_g-1 downto 0);
    net_stall_out : out std_logic);

end cdc;


architecture rtl of cdc is

  signal ip_in_cd     : std_logic_vector(cmd_width_g+data_width_g-1 downto 0);
  signal net_in_cd    : std_logic_vector(cmd_width_g+data_width_g-1 downto 0);
  signal ip_out_cd    : std_logic_vector(cmd_width_g+data_width_g-1 downto 0);
  signal net_out_cd   : std_logic_vector(cmd_width_g+data_width_g-1 downto 0);
  signal ip_out_cd_r  : std_logic_vector(cmd_width_g+data_width_g-1 downto 0);
  signal net_out_cd_r : std_logic_vector(cmd_width_g+data_width_g-1 downto 0);
  signal ip_we        : std_logic;
  signal net_we       : std_logic;
  signal ip_re        : std_logic;
  signal net_re       : std_logic;
  signal ip_empty     : std_logic;
  signal net_empty    : std_logic;

  signal out_len   : std_logic_vector(len_width_g-1 downto 0);  -- 2012-05-04
  signal out_len_r : std_logic_vector(len_width_g-1 downto 0);  -- 2012-05-04
  
begin  -- rtl

  -----------------------------------------------------------------------------
  -- ONE CLOCK
  --
  -- Just a direct combinatorial connection
  -----------------------------------------------------------------------------
  clock_mode_0 : if clock_mode_g = 0 generate

    ip_cmd_out    <= net_cmd_in;
    ip_data_out   <= net_data_in;
    net_stall_out <= ip_stall_in;

    net_cmd_out  <= ip_cmd_in;
    net_data_out <= ip_data_in;
    ip_stall_out <= net_stall_in;

    net_len_out <= ip_len_in;           -- 2012-05-04
    
  end generate clock_mode_0;

  -----------------------------------------------------------------------------
  -- TWO ASYNCHRONOUS CLOCKS
  -----------------------------------------------------------------------------
  clock_mode_1 : if clock_mode_g = 1 generate

    ---------------------------------------------------------------------------
    -- FROM IP TO NET
    ---------------------------------------------------------------------------
    ip_in_cd <= ip_cmd_in & ip_data_in;
    net_re   <= not net_stall_in;

    ip_we_p : process (ip_cmd_in)
    begin  -- process ip_we_p
      if ip_cmd_in /= "00" then
        ip_we <= '1';
      else
        ip_we <= '0';
      end if;
    end process ip_we_p;

    fifo_ip2net : entity work.fifo_2clk
      generic map (
        data_width_g => cmd_width_g+data_width_g,
        depth_g      => fifo_depth_g)
      port map (
        rst_n => rst_n,

        clk_wr   => clk_ip,
        we_in    => ip_we,
        data_in  => ip_in_cd,
        full_out => ip_stall_out,

        clk_rd    => clk_net,
        re_in     => net_re,
        data_out  => net_out_cd,
        empty_out => net_empty);

    fifo_len2net : entity work.fifo_2clk  -- 2012-05-04
      generic map (
        data_width_g => len_width_g,
        depth_g      => fifo_depth_g)
      port map (
        rst_n => rst_n,

        clk_wr   => clk_ip,
        we_in    => ip_we,
        data_in  => ip_len_in,
        full_out => open,

        clk_rd    => clk_net,
        re_in     => net_re,
        data_out  => out_len,
        empty_out => open);

    sto1_p : process (clk_net, rst_n)
    begin  -- process sto1_p
      if rst_n = '0' then               -- asynchronous reset (active low)
        net_out_cd_r <= (others => '0');
        out_len_r <= (others => '0'); -- 2012-05-04
      elsif clk_net'event and clk_net = '1' then  -- rising clock edge
        if net_stall_in = '0' and net_empty = '0' then
          net_out_cd_r <= net_out_cd;
          out_len_r    <= out_len;      -- 2012-05-04
        end if;
      end if;
    end process sto1_p;

    net_outs_p : process (net_empty, net_out_cd, net_out_cd_r, net_stall_in,
                          out_len, out_len_r)
    begin  -- process net_outs_p
      if net_stall_in = '1' then
        net_cmd_out <= net_out_cd_r(cmd_width_g+data_width_g-1 downto
                                    data_width_g);
        net_data_out <= net_out_cd_r(data_width_g-1 downto 0);
        net_len_out  <= out_len_r;      -- 2012-05-04
      elsif net_empty = '1' then
        net_cmd_out  <= (others => '0');
        net_data_out <= (others => '0');
        net_len_out  <= (others => '0');  -- 2012-05-04
      else
        net_cmd_out <= net_out_cd(cmd_width_g+data_width_g-1 downto
                                  data_width_g);
        net_data_out <= net_out_cd(data_width_g-1 downto 0);
        net_len_out  <= out_len;      -- 2012-05-04
      end if;
    end process net_outs_p;

    ---------------------------------------------------------------------------
    -- FROM NET TO IP
    ---------------------------------------------------------------------------
    net_in_cd <= net_cmd_in & net_data_in;
    ip_re     <= not ip_stall_in;

    net_we_p : process (net_cmd_in)
    begin  -- process ip_we_p
      if net_cmd_in /= "00" then
        net_we <= '1';
      else
        net_we <= '0';
      end if;
    end process net_we_p;

    fifo_net2ip : entity work.fifo_2clk
      generic map (
        data_width_g => cmd_width_g+data_width_g,
        depth_g      => fifo_depth_g)
      port map (
        rst_n => rst_n,

        clk_wr   => clk_net,
        we_in    => net_we,
        data_in  => net_in_cd,
        full_out => net_stall_out,

        clk_rd    => clk_ip,
        re_in     => ip_re,
        data_out  => ip_out_cd,
        empty_out => ip_empty);

    sto2_p : process (clk_ip, rst_n)
    begin  -- process sto1_p
      if rst_n = '0' then               -- asynchronous reset (active low)
        ip_out_cd_r <= (others => '0');
      elsif clk_ip'event and clk_ip = '1' then  -- rising clock edge
        if ip_stall_in = '0' and ip_empty = '0' then
          ip_out_cd_r <= ip_out_cd;
        end if;
      end if;
    end process sto2_p;

    ip_outs_p : process (ip_empty, ip_out_cd, ip_out_cd_r, ip_stall_in)
    begin  -- process net_outs_p
      if ip_stall_in = '1' then
        ip_cmd_out <= ip_out_cd_r(cmd_width_g+data_width_g-1 downto
                                  data_width_g);
        ip_data_out <= ip_out_cd_r(data_width_g-1 downto 0);
      elsif ip_empty = '1' then
        ip_cmd_out  <= (others => '0');
        ip_data_out <= (others => '0');
      else
        ip_cmd_out <= ip_out_cd(cmd_width_g+data_width_g-1 downto
                                data_width_g);
        ip_data_out <= ip_out_cd(data_width_g-1 downto 0);
      end if;
    end process ip_outs_p;
    
  end generate clock_mode_1;
  
end rtl;
