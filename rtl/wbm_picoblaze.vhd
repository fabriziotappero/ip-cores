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
-- filename: wbm_picoblaze.vhd
-- description: synthesizable wishbone master adapter for PicoBlaze (TM),
--              working together with "wb_wr" and "wb_rd" assembler subroutines
-- todo4user: module should not be changed!
-- version: 0.0.0
-- changelog: - 0.0.0, initial release
--            - ...
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity wbm_picoblaze is
  port
  (
    rst : in std_logic;
    clk : in std_logic;
    
    wbm_cyc_o : out std_logic;
    wbm_stb_o : out std_logic;
    wbm_we_o : out std_logic;
    wbm_adr_o : out std_logic_vector(7 downto 0);
    wbm_dat_m2s_o : out std_logic_vector(7 downto 0);
    wbm_dat_s2m_i : in std_logic_vector(7 downto 0);
    wbm_ack_i : in std_logic;
    
    pb_port_id_i : in std_logic_vector(7 downto 0);
    pb_write_strobe_i : in std_logic;
    pb_out_port_i : in std_logic_vector(7 downto 0);
    pb_read_strobe_i : in std_logic;
    pb_in_port_o : out std_logic_vector(7 downto 0)
  );
end wbm_picoblaze;


architecture rtl of wbm_picoblaze is

  signal wbm_cyc : std_logic := '0';
  signal wbm_stb : std_logic := '0';
  signal wbm_we : std_logic := '0';
  signal wbm_adr : std_logic_vector(7 downto 0) := (others => '0');
  signal wbm_dat_m2s : std_logic_vector(7 downto 0) := (others => '0');
  
  signal pb_in_port : std_logic_vector(7 downto 0) := (others => '0');
  
  signal wb_buffer : std_logic_vector(7 downto 0) := (others => '0');
  
  constant WB_ACK_FLAG : std_logic_vector(7 downto 0) := x"01";
  
  type t_states is
  (
    S_IDLE,
    S_WAIT_ON_WB_ACK,
    S_SOFTWARE_HANDSHAKE,
    S_SOFTWARE_READ
  );
  signal state : t_states := S_IDLE;

begin

  wbm_cyc_o <= wbm_cyc;
  wbm_stb_o <= wbm_stb;
  wbm_we_o <= wbm_we;
  wbm_adr_o <= wbm_adr;
  wbm_dat_m2s_o <= wbm_dat_m2s;
  
  pb_in_port_o <= pb_in_port;
  
  wbm_cyc <= wbm_stb;
  
  process(clk)
  begin
    if clk'event and clk = '1' then
    
      case state is
        when S_IDLE =>
          -- setting up wishbone address, data and control signals from 
          -- PicoBlaze (TM) signals
          if pb_write_strobe_i = '1' then
            wbm_stb <= '1';
            wbm_we <= '1';
            wbm_adr <= pb_port_id_i;
            wbm_dat_m2s <= pb_out_port_i;
            state <= S_WAIT_ON_WB_ACK;
          elsif pb_read_strobe_i = '1' then
            wbm_stb <= '1';
            wbm_we <= '0';
            wbm_adr <= pb_port_id_i;
            state <= S_WAIT_ON_WB_ACK;
          end if;
        when S_WAIT_ON_WB_ACK =>
          -- waiting on slave peripheral to complete wishbone transfer cycle
          if wbm_ack_i = '1' then
            wbm_stb <= '0';
            wb_buffer <= wbm_dat_s2m_i;
            pb_in_port <= WB_ACK_FLAG;
            state <= S_SOFTWARE_HANDSHAKE;
          end if;
        when S_SOFTWARE_HANDSHAKE =>
          -- software recognition of wishbone handshake
          if pb_read_strobe_i = '1' then
            -- transfer complete for a write access
            if wbm_we = '1' then
              pb_in_port <= (others => '0');
              state <= S_IDLE;
            -- presenting valid wishbone data to PicoBlaze (TM) port in read 
            -- access
            else
              pb_in_port <= wb_buffer;
              state <= S_SOFTWARE_READ;
            end if;
          end if;
        when S_SOFTWARE_READ =>
          -- transfer complete for a read access after software recognition of
          -- wishbone data
          if pb_read_strobe_i = '1' then
            pb_in_port <= (others => '0');
            state <= S_IDLE;
          end if;
        when others => null;
      end case;
    
      if rst = '1' then
        wbm_stb <= '0';
        pb_in_port <= (others => '0');
        state <= S_IDLE;
      end if;
      
    end if;
  end process;

end rtl;
