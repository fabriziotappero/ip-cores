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
-- filename: wbs_gpio.vhd
-- description: synthesizable wishbone slave general purpose i/o module
-- todo4user: add more i/o ports as needed
-- version: 0.0.0
-- changelog: - 0.0.0, initial release
--            - ...
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity wbs_gpio is
  port
  (
    rst : in std_logic;
    clk : in std_logic;
    
    wbs_cyc_i : in std_logic;
    wbs_stb_i : in std_logic;
    wbs_we_i : in std_logic;
    wbs_adr_i : in std_logic_vector(7 downto 0);
    wbs_dat_m2s_i : in std_logic_vector(7 downto 0);
    wbs_dat_s2m_o : out std_logic_vector(7 downto 0);
    wbs_ack_o : out std_logic;
    
    gpio_in_i : in std_logic_vector(7 downto 0);
    gpio_out_o : out std_logic_vector(7 downto 0);
    gpio_oe_o : out std_logic_vector(7 downto 0)
  );
end wbs_gpio;


architecture rtl of wbs_gpio is

  signal wbs_dat_s2m : std_logic_vector(7 downto 0) := (others => '0');
  signal wbs_ack : std_logic := '0';
  
  signal gpio_out : std_logic_vector(7 downto 0) := (others => '0');
  signal gpio_oe : std_logic_vector(7 downto 0) := (others => '0');
  
  signal wb_reg_we : std_logic := '0';
  
  signal gpio_in : std_logic_vector(7 downto 0) := (others => '0');
  
  constant IS_INPUT : std_logic := '0';
  constant IS_OUTPUT : std_logic := not IS_INPUT;
    
  constant ADDR_MSB : natural := 0;
  constant GPIO_IO_ADDR : std_logic_vector(7 downto 0) := x"00";
  constant GPIO_OE_ADDR : std_logic_vector(7 downto 0) := x"01";
  
begin

  wbs_dat_s2m_o <= wbs_dat_s2m;
  wbs_ack_o <= wbs_ack;
  
  gpio_out_o <= gpio_out;
  gpio_oe_o <= gpio_oe;
  
  -- internal register write enable signal
  wb_reg_we <= wbs_cyc_i and wbs_stb_i and wbs_we_i;
 
  process(clk) 
  begin
    if clk'event and clk = '1' then
    
      gpio_in <= gpio_in_i;
    
      wbs_dat_s2m <= (others => '0');
      -- registered wishbone slave handshake
      wbs_ack <= wbs_cyc_i and wbs_stb_i and (not wbs_ack);
      
      case wbs_adr_i(ADDR_MSB downto 0) is
        -- i/o register access
        when GPIO_IO_ADDR(ADDR_MSB downto 0) =>
          if wb_reg_we = '1' then
            gpio_out <= wbs_dat_m2s_i;
          end if;
          wbs_dat_s2m <= gpio_in;
        -- output enable register access
        when GPIO_OE_ADDR(ADDR_MSB downto 0) =>
          if wb_reg_we = '1' then
            gpio_oe <= wbs_dat_m2s_i;
          end if;
          wbs_dat_s2m <= gpio_oe;
        when others => null;
      end case;
    
      if rst = '1' then
        wbs_ack <= '0';
        gpio_oe <= (others => IS_INPUT);
      end if;
    
    end if;
  end process;

end rtl;
