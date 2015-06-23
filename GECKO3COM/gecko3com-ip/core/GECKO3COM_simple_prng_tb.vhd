--  GECKO3COM IP Core
--
--  Copyright (C) 2009 by
--   ___    ___   _   _
--  (  _ \ (  __)( ) ( )
--  | (_) )| (   | |_| |   Bern University of Applied Sciences
--  |  _ < |  _) |  _  |   School of Engineering and
--  | (_) )| |   | | | |   Information Technology
--  (____/ (_)   (_) (_)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details. 
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
--  URL to the project description: 
--    http://labs.ti.bfh.ch/gecko/wiki/systems/gecko3com/start
--------------------------------------------------------------------------------
--
--  Author:  Christoph Zimmermann
--  Date of creation: 26. February 2010
--  Description:
--      Small testbench to simulate the pseudo random number generator used in
--      the GECKO3COM_simple_test module.
--
--      The file output is not usable for our case. To compare the data we
--      receive through USB we use the output from GECKO3COM_simple_prng_tb.c
--
--  Tool versions:      11.1
--  Dependencies:
--
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library std;
use std.textio.all;


entity GECKO3COM_simple_prng_tb is
end GECKO3COM_simple_prng_tb;

architecture simulation of GECKO3COM_simple_prng_tb is

  -- simulation constants
  constant C_SIM_DURATION : time := 80080 ns;  -- duration of simulation
  constant CLK_PERIOD     : time := 20 ns;
  

  -- signals
  signal sim_stoped      : boolean := false;
  signal sim_clk         : std_logic;
  signal sim_rst         : std_logic;
  signal s_prng_en       : std_logic;
  signal s_prng_feedback : std_logic;
  signal s_prng_data     : std_logic_vector(31 downto 0);


begin  -- simulation

  sim_stoped <= true after C_SIM_DURATION;

  -----------------------------------------------------------------------------
  -- Design maps
  ----------------------------------------------------------------------------- 

  sim_prng_en : process (sim_clk, sim_rst)
  begin
    if sim_rst = '0' then               -- asynchronous reset (active low)
      s_prng_en <= '0';
    elsif sim_clk'event and sim_clk = '1' then  -- rising clock edge
      s_prng_en <= '1';
    end if;
  end process sim_prng_en;


  -- purpose: linear shift register for the pseude random number
  --          generator (PRNG)
  -- type   : sequential
  -- inputs : i_sysclk, i_nReset, s_prng_en, s_prng_feedback
  -- outputs: s_prng_data
  prng_shiftregister : process (sim_clk, sim_rst)
  begin  -- process prng_shiftregister
    if sim_rst = '0' then               -- asynchronous reset (active low)
      s_prng_data <= "01010101010101010101010101010101";
    elsif sim_clk'event and sim_clk = '1' then  -- rising clock edge
      if s_prng_en = '1' then
        s_prng_data(31 downto 1) <= s_prng_data(30 downto 0);
        s_prng_data(0)           <= s_prng_feedback;
      end if;
    end if;
  end process prng_shiftregister;

  -- purpose: feedback polynom for the pseudo random number generator (PRNG)
  -- inputs : s_prng_data
  -- outputs: s_prng_feedback
  s_prng_feedback <= s_prng_data(15) xor s_prng_data(13) xor s_prng_data(12)
                     xor s_prng_data(10);



  -----------------------------------------------------------------------------
  -- CLK process
  -----------------------------------------------------------------------------
  clk_process : process
  begin
    sim_clk <= '0';
    wait for CLK_PERIOD/2;
    sim_clk <= '1';
    wait for CLK_PERIOD/2;
    if sim_stoped then
      wait;
    end if;
  end process;

  rst_process : process
  begin
    sim_rst <= '0';
    wait for 2*CLK_PERIOD;
    sim_rst <= '1';
    wait;
  end process;

  -----------------------------------------------------------------------------
  -- write file process
  -----------------------------------------------------------------------------

  write_input : process
    type bin_file is file of bit_vector(31 downto 0);
    file c_file_handle  : bin_file;
    --type char_file is file of character;
    --file c_file_handle  : char_file;
    variable C          : character := 'W';
    variable char_count : integer   := 0;
  begin
    file_open(c_file_handle, "GECKO3COM_simple_prng_tb.txt", write_mode);

    while sim_stoped = false loop
      write(c_file_handle, to_bitvector(s_prng_data));
      --write(c_file_handle, C);
      char_count := char_count + 1;
      wait until sim_clk = '1';
    end loop;
    
    file_close(c_file_handle);
    
  end process;

end simulation;
