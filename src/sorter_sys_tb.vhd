-------------------------------------------------------------------------------
-- Title      : Testbench for design "heap-sorter"
-- Project    : heap-sorter
-------------------------------------------------------------------------------
-- File       : sorter_sys_tb.vhd
-- Author     : Wojciech M. Zabolotny <wzab@ise.pw.edu.pl>
-- Company    : 
-- Created    : 2010-05-14
-- Last update: 2011-07-06
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 Wojciech M. Zabolotny
-- This file is published under the BSD license, so you can freely adapt
-- it for your own purposes.
-- Additionally this design has been described in my article:
--    Wojciech M. Zabolotny, "Dual port memory based Heapsort implementation
--    for FPGA", Proc. SPIE 8008, 80080E (2011); doi:10.1117/12.905281
-- I'd be glad if you cite this article when you publish something based
-- on my design.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-05-14  1.0      wzab    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
library work;
use work.sys_config.all;
use work.sorter_pkg.all;


-------------------------------------------------------------------------------

entity sorter_sys_tb is

end entity sorter_sys_tb;

-------------------------------------------------------------------------------

architecture sort_tb_beh of sorter_sys_tb is

  constant NLEVELS : integer := SYS_NLEVELS;
  -- component ports
  signal din   : T_DATA_REC := DATA_REC_INIT_DATA;
  signal dout  : T_DATA_REC;
  signal we    : std_logic  := '0';
  signal dav   : std_logic  := '0';
  signal rst_n : std_logic  := '0';
  signal ready : std_logic  := '0';

  component sorter_sys
    generic (
      NADDRBITS : integer);
    port (
      din   : in  T_DATA_REC;
      we    : in  std_logic;
      dout  : out T_DATA_REC;
      dav   : out std_logic;
      clk   : in  std_logic;
      rst_n : in  std_logic;
      ready : out std_logic);
  end component;
  -- clock
  signal Clk : std_logic := '1';

  signal end_sim : boolean              := false;
  signal div     : integer range 0 to 8 := 0;
  
begin  -- architecture sort_tb_beh

  -- component instantiation
  DUT : entity work.sorter_sys
    generic map (
      NLEVELS => NLEVELS)
    port map (
      din   => din,
      we    => we,
      dout  => dout,
      dav   => dav,
      clk   => clk,
      rst_n => rst_n,
      ready => ready);

  -- clock generation
  Clk <= not Clk after 10 ns when end_sim = false else '0';

  -- waveform generation
  WaveGen_Proc : process
    file events_in       : text open read_mode is "events.in";
    variable input_line  : line;
    file events_out      : text open write_mode is "events.out";
    variable output_line : line;
    variable rec         : T_DATA_REC;
    variable skey       : std_logic_vector(DATA_REC_SORT_KEY_WIDTH-1 downto 0);
    variable spayload : std_logic_vector(DATA_REC_PAYLOAD_WIDTH-1 downto 0);
  begin
    -- insert signal assignments here

    wait until Clk = '1';
    wait for 31 ns;
    rst_n <= '1';
    wait until ready = '1';
    loop
      wait until Clk = '0';
      wait until Clk = '1';
      we <= '0';
      if div = 3 then
        div        <= 0;
        exit when endfile(events_in);
        readline(events_in, input_line);
        read(input_line, rec.init);
        read(input_line, rec.valid);
        read(input_line, skey);
        read(input_line, spayload);
        rec.d_key := unsigned(skey);
        rec.d_payload := spayload;
        din        <= rec;
        we         <= '1';
      else
        div <= div+1;
      end if;
      if dav = '1' then
        -- Process read event
        rec := dout;
        write(output_line, rec.init);
        write(output_line, rec.valid);
        write(output_line,string'(" "));
        write(output_line, std_logic_vector(rec.d_key));
        write(output_line,string'(" "));
        write(output_line, std_logic_vector(rec.d_payload));
        writeline(events_out, output_line);
      end if;
    end loop;
    end_sim   <= true;
    rec.valid := '0';
    din       <= rec;
    wait;
  end process WaveGen_Proc;

  

end architecture sort_tb_beh;

-------------------------------------------------------------------------------

configuration sorter_sys_tb_sort_tb_beh_cfg of sorter_sys_tb is
  for sort_tb_beh
  end for;
end sorter_sys_tb_sort_tb_beh_cfg;

-------------------------------------------------------------------------------
