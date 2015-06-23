-- File: tb_register_file.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Execute stage
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.RISE_PACK.all;
use work.RISE_PACK_SPECIFIC.all;

entity tb_register_file_vhd is
end tb_register_file_vhd;

architecture behavior of tb_register_file_vhd is

  -- Component Declaration for the Unit Under Test (UUT)
  component register_file
    port(
      clk         : in  std_logic;
      reset       : in  std_logic;
      rx_addr     : in  std_logic_vector(3 downto 0);
      ry_addr     : in  std_logic_vector(3 downto 0);
      rz_addr     : in  std_logic_vector(3 downto 0);
      dreg_addr   : in  std_logic_vector(3 downto 0);
      dreg_write  : in  std_logic_vector(15 downto 0);
      dreg_enable : in  std_logic;
      sr_write    : in  std_logic_vector(15 downto 0);
      sr_enable   : in  std_logic;
      lr_write    : in  std_logic_vector(15 downto 0);
      lr_enable   : in  std_logic;
      pc_write    : in  std_logic_vector(15 downto 0);
      rx_read     : out std_logic_vector(15 downto 0);
      ry_read     : out std_logic_vector(15 downto 0);
      rz_read     : out std_logic_vector(15 downto 0);
      sr_read     : out std_logic_vector(15 downto 0);
      pc_read     : out std_logic_vector(15 downto 0)
      );
  end component;

  --Inputs
  signal clk         : std_logic                     := '0';
  signal reset       : std_logic                     := '0';
  signal rx_addr     : std_logic_vector(3 downto 0)  := (others => '0');
  signal ry_addr     : std_logic_vector(3 downto 0)  := (others => '0');
  signal rz_addr     : std_logic_vector(3 downto 0)  := (others => '0');
  signal dreg_addr   : std_logic_vector(3 downto 0)  := (others => '0');
  signal dreg_write  : std_logic_vector(15 downto 0) := (others => '0');
  signal dreg_enable : std_logic;
  signal sr_write    : std_logic_vector(15 downto 0) := (others => '0');
  signal sr_enable   : std_logic;
  signal lr_write    : std_logic_vector(15 downto 0) := (others => '0');
  signal lr_enable   : std_logic;
  signal pc_write    : std_logic_vector(15 downto 0) := (others => '0');

  --Outputs
  signal rx_read : std_logic_vector(15 downto 0);
  signal ry_read : std_logic_vector(15 downto 0);
  signal rz_read : std_logic_vector(15 downto 0);
  signal sr_read : std_logic_vector(15 downto 0);
  signal pc_read : std_logic_vector(15 downto 0);

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : register_file port map(
    clk         => clk,
    reset       => reset,
    rx_addr     => rx_addr,
    ry_addr     => ry_addr,
    rz_addr     => rz_addr,
    dreg_addr   => dreg_addr,
    dreg_write  => dreg_write,
    dreg_enable => dreg_enable,
    rx_read     => rx_read,
    ry_read     => ry_read,
    rz_read     => rz_read,
    sr_write    => sr_write,
    sr_enable   => sr_enable,
    lr_write    => lr_write,
    lr_enable   => lr_enable,
    pc_write    => pc_write,
    sr_read     => sr_read,
    pc_read     => pc_read
    );

  process                               -- clock process for CLK,
  begin
    CLOCK_LOOP : loop
      clk <= transport '0';
      wait for 10 ns;
      clk <= transport '1';
      wait for 10 ns;

    end loop CLOCK_LOOP;
  end process;


  process
  begin

    reset       <= '0';
    dreg_enable <= '0';
    sr_enable   <= '0';
    lr_enable   <= '0';
    wait for 50 ns;
    dreg_enable <= '1';
    reset       <= '1';
    wait for 10 ns;

    dreg_addr  <= "0101";
    dreg_write <= "1111111111111111";

    rx_addr <= "0101";

    wait for 40 ns;
    dreg_addr  <= "0001";
    dreg_write <= "1111111100000000";

    rx_addr <= "0101";

    wait for 40 ns;
    dreg_enable <= '0';
    wait for 5 ns;
    dreg_addr   <= "0000";
    dreg_write  <= "0000000011111111";

    wait for 40 ns;
    dreg_enable <= '1';
    wait for 5 ns;
    dreg_addr   <= "0010";
    dreg_write  <= "1010101010101010";


    wait for 30 ns;

    rx_addr <= "0010";
    ry_addr <= "0001";
    rz_addr <= "0000";

    dreg_addr  <= "0010";
    dreg_write <= "1111111111111111";

    wait for 20 ns;

    dreg_addr  <= "1110";
    dreg_write <= "1111111100000000";
    pc_write   <= "1010101010101010";

    wait for 20 ns;

    dreg_addr  <= "1111";
    dreg_write <= "1111111100000000";

    sr_enable <= '1';
    sr_write  <= "1010101010101010";

    --wait for

    wait;

  end process;


end;
