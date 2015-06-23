--------------------------------------------------------------------------------
-- This sourcecode is released under BSD license.
-- Please see http://www.opensource.org/licenses/bsd-license.php for details!
--------------------------------------------------------------------------------
--
-- Copyright (c) 2010, Stefan Fischer <Ste.Fis@OpenCores.org>
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without 
-- modification, are permitted provided that the following conditions are met:
--
--  * Redistributions of source code must retain the above copyright notice, 
--    this list of conditions and the following disclaimer.
--  * Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
-- POSSIBILITY OF SUCH DAMAGE.
--
--------------------------------------------------------------------------------
-- filename: picoblaze_wb_gpio_tb.vhd
-- description: testbench for picoblaze_wb_gpio example
-- todo4user: modify stimulus as needed
-- version: 0.0.0
-- changelog: - 0.0.0, initial release
--            - ...
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity picoblaze_wb_gpio_tb is
end picoblaze_wb_gpio_tb;


architecture behavioral of picoblaze_wb_gpio_tb is

  component picoblaze_wb_gpio is
    port
    (
      p_rst_n_i : in std_logic;
      p_clk_i : in std_logic;
      
      p_gpio_io : inout std_logic_vector(7 downto 0)
    );
  end component;

  signal rst_n : std_logic := '0';
  signal clk : std_logic := '1';
    
  signal gpio : std_logic_vector(7 downto 0) := (others => 'Z');
  
  constant PERIOD : time := 20 ns;

  signal test_data_in : std_logic_vector(7 downto 4) := (others => '0');
  
begin

  -- system signal generation
  rst_n <= '1' after PERIOD*2;
  clk <= not clk after PERIOD/2;
  
  -- 4 bit counting data, changing after some micro seconds
  test_data_in <= std_logic_vector(unsigned(test_data_in) + 1) after 3000 ns;
  -- stimulus at upper gpio nibble
  gpio(7 downto 4) <= test_data_in;
  
  -- design under test instance
  dut : picoblaze_wb_gpio
    port map
    (
      p_rst_n_i => rst_n,
      p_clk_i => clk,
      
      p_gpio_io => gpio
    );
  
end behavioral;
