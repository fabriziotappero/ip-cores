-------------------------------------------------------------------------------
-- Title      : Testbench for design "fifo_8bitx16"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fifo_8bitx16_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2007-09-04
-- Last update: 2007-11-12
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-09-04  1.0      d.koethe        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.all;


library work;
use work.txt_util.all;
-------------------------------------------------------------------------------

entity fifo_tb is

end fifo_tb;

-------------------------------------------------------------------------------

architecture behavior of fifo_tb is
  component fifo
    generic (
      C_FIFO_WIDTH      : integer;
      C_FIFO_SIZE_WIDTH : integer;
      C_SYNC_TO         : string);
    port (
      rst               : in  std_logic;
      wr_clk            : in  std_logic;
      wr_en             : in  std_logic;
      din               : in  std_logic_vector(C_FIFO_WIDTH-1 downto 0);
      rd_clk            : in  std_logic;
      rd_en             : in  std_logic;
      dout              : out std_logic_vector(C_FIFO_WIDTH-1 downto 0);
      empty             : out std_logic;
      full              : out std_logic;
      overflow          : out std_logic;
      underflow         : out std_logic;
      prog_empty_thresh : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
      prog_full_thresh  : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
      prog_empty        : out std_logic;
      prog_full         : out std_logic);
  end component;

-- Testbench
  constant C_FIFO_SIZE   : integer := 15;
  constant C_FIFO_WIDTH      : integer := 8;
  constant C_FIFO_SIZE_WIDTH : integer := 4;

  -- sync to RD
--  constant C_SYNC_TO         : string  := "RD";
--  constant wr_clk_period : time    := 100 ns;
--  constant rd_clk_period : time    := 25 ns;
  
  -- sync to WR
  constant C_SYNC_TO         : string  := "WR";
  constant wr_clk_period : time    := 25 ns;
  constant rd_clk_period : time    := 100 ns;
  
  signal rst               : std_logic;
  signal wr_clk            : std_logic;
  signal wr_en             : std_logic;
  signal din               : std_logic_vector(C_FIFO_WIDTH-1 downto 0);
  signal rd_clk            : std_logic;
  signal rd_en             : std_logic;
  signal dout              : std_logic_vector(C_FIFO_WIDTH-1 downto 0);
  signal empty             : std_logic;
  signal full              : std_logic;
  signal overflow          : std_logic;
  signal underflow         : std_logic;
  signal prog_empty_thresh : std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
  signal prog_full_thresh  : std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
  signal prog_empty        : std_logic;
  signal prog_full         : std_logic;





  signal flags         : std_logic_vector(5 downto 0);
  signal wr_clk_int    : std_logic;
  signal wr_clk_en     : boolean := false;

  signal rd_clk_int    : std_logic;
  signal rd_clk_en     : boolean := false;


  signal wr_off : boolean := false;
  signal rd_off : boolean := false;
  
begin  -- behavior

  process
  begin
    rd_clk_int <= '0';
    wait for rd_clk_period/2;
    rd_clk_int <= '1';
    wait for rd_clk_period/2;
  end process;

  process
  begin
    wr_clk_int <= '0';
    wait for wr_clk_period/2;
    wr_clk_int <= '1';
    wait for wr_clk_period/2;
  end process;

  -- component instantiation


  DUT : fifo
    generic map (
      C_FIFO_WIDTH      => C_FIFO_WIDTH,
      C_FIFO_SIZE_WIDTH => C_FIFO_SIZE_WIDTH,
      C_SYNC_TO         => C_SYNC_TO)
    port map (
      rst               => rst,
      wr_clk            => wr_clk,
      wr_en             => wr_en,
      din               => din,
      rd_clk            => rd_clk,
      rd_en             => rd_en,
      dout              => dout,
      empty             => empty,
      full              => full,
      overflow          => overflow,
      underflow         => underflow,
      prog_empty_thresh => prog_empty_thresh,
      prog_full_thresh  => prog_full_thresh,
      prog_empty        => prog_empty,
      prog_full         => prog_full);

  flags <= prog_empty &
           empty &
           underflow &
           prog_full &
           full &
           overflow;


  wr_off <= false when (C_SYNC_TO = "RD") else true;
  rd_off <= false when (C_SYNC_TO = "WR") else true;

  wr_clk <= wr_clk_int when wr_clk_en else '0';
  rd_clk <= rd_clk_int when rd_clk_en else '0';

  -- waveform generation
  WaveGen_Proc : process
    variable first : std_logic_vector(7 downto 0) := (others => '0');
  begin
     wr_en             <= '0';
    din               <= (others => 'Z');
    rd_en             <= '0';
    -- prog_empty assert 2 cycle delay
    -- prog_empty deassert 1 cycle delay    
    prog_empty_thresh <= X"4";
    -- prog_full assert 2 cycle delay
    -- prog_full deassert 1 cycle delay 
    prog_full_thresh  <= X"B";
    -- rst active
    rst               <= '1';
    wait for 100 ns;
    rst               <= '0';

    -- check reset value
    -- 1: empty/prog_empty
    assert (flags = "110000") report "Flag Reset Value wrong " & str(flags) severity warning;

    -- write

    wait until falling_edge(wr_clk_int);
    wr_clk_en <= true;
    wr_en     <= '1';
    din       <= X"A5";
    wait until falling_edge(wr_clk_int);
    wr_clk_en <= wr_off;
    wr_en     <= '0';
    din       <= (others => 'Z');
    -- check after 1 write 
    -- 1: empty
    assert (flags = "100000") report "Flag after one write wrong " & str(flags) severity warning;

    wait for 100 ns;

    -- read
    wait until falling_edge(rd_clk_int);
    rd_clk_en <= true;
    rd_en     <= '1';
    wait until falling_edge(rd_clk_int);
    rd_en     <= '0';
    rd_clk_en <= rd_off;
    wait for 100 ns;

    -- check reset value
    -- 1: empty/prog_empty
    assert (flags = "110000") report "Flag after one read wrong " & str(flags) severity warning;

    -- write 16 byte
    wait until falling_edge(wr_clk_int);
    for i in 1 to 255 loop
      wr_clk_en <= true;
      wr_en     <= '1';
      din       <= conv_std_logic_vector(i, din'length);
      wait until falling_edge(wr_clk_int);
      wr_en     <= '0';
      din       <= (others => 'Z');
      wr_clk_en <= wr_off;
      -- report threshold for prog_empty
      if (prog_empty = '0' and first(0) = '0') then
        assert (i = conv_integer(prog_empty_thresh))
          report "prog_emtpy deassert after " & integer'image(i) & " writes." severity warning;
        first(0) := '1';
      end if;
      -- report threshold for prog_full      
      if (prog_full = '1' and first(1) = '0') then
        assert (i = conv_integer(prog_full_thresh)+1)
          report "prog_full assert after " & integer'image(i) & " writes." severity warning;
        first(1) := '1';
      end if;
      -- report threshold for full  
      if (full = '1') then
        assert (i = C_FIFO_SIZE) report "full assert after " & integer'image(i) & " writes." severity warning;
        exit;
      end if;
    end loop;  -- i 

    -- read
    wait until falling_edge(rd_clk_int);
    for i in 1 to 255 loop
      rd_clk_en <= true;
      rd_en     <= '1';
      if (empty = '0' and underflow = '0') then
        assert (conv_integer(dout) = i) report "Read failure at " & integer'image(i) severity warning;
      end if;
      wait until falling_edge(rd_clk_int);
      wait for 1 ps;
      rd_clk_en <= rd_off;
      rd_en     <= '0';



      -- report threshold for prog_full
      if (prog_full = '0' and first(2) = '0') then
        assert (C_FIFO_SIZE-i = conv_integer(prog_full_thresh)-1)
          report "prog_full deassert after " & integer'image(i) & " reads." severity warning;
        first(2) := '1';
      end if;
      -- report threshold for prog_empty      

      if (prog_empty = '1' and first(3) = '0') then
        assert (C_FIFO_SIZE-i = conv_integer(prog_empty_thresh)-2)
          report "prog_empty assert after " & integer'image(i) & " reads." severity warning;
        first(3) := '1';
      end if;
      -- report threshold for empty  
      if (empty = '1' and first(4) = '0') then
        assert (i = C_FIFO_SIZE)
          report "empty assert after " & integer'image(i) & " reads." severity warning;
        first(4) := '1';
      end if;
      -- report threshold for underflow  
      if (underflow = '1') then
        assert (i = C_FIFO_SIZE+1)
          report "underflow assert after " & integer'image(i) & " reads." severity warning;
        exit;
      end if;
      
    end loop;  -- i

    wait for 100 ns;

    assert false report "Simulation Sucessful" severity failure;
    
    

    
  end process WaveGen_Proc;

  

end behavior;

-------------------------------------------------------------------------------

configuration fifo_tb_behavior_cfg of fifo_tb is
  for behavior
  end for;
end fifo_tb_behavior_cfg;

-------------------------------------------------------------------------------
