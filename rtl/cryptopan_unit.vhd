--
-- This file is part of the Crypto-PAn core.
--
-- Copyright (c) 2007 The University of Waikato, Hamilton, New Zealand.
-- Authors: Anthony Blake (tonyb33@opencores.org)
--          
-- All rights reserved.
--
-- This code has been developed by the University of Waikato WAND 
-- research group. For further information please see http://www.wand.net.nz/
--
-- This source file is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This source is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with libtrace; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.cryptopan.all;

entity cryptopan_unit is

  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    ready    : out std_logic;
    key      : in  std_logic_vector(255 downto 0);
    key_wren : in  std_logic;
    ip_in    : in  std_logic_vector(31 downto 0);
    ip_wren  : in  std_logic;
    ip_out   : out std_logic_vector(31 downto 0);
    ip_dv    : out std_logic
    );

end cryptopan_unit;

architecture rtl of cryptopan_unit is

  component aes_encrypt_unit
    port (
      key_in    : in  std_logic_vector(127 downto 0);
      key_wren  : in  std_logic;
      ready     : out std_logic;
      data_in   : in  std_logic_vector(127 downto 0);
      data_wren : in  std_logic;
      data_dv   : out std_logic;
      data_out  : out std_logic_vector(127 downto 0);
      clk       : in  std_logic;
      reset     : in  std_logic);
  end component;

  signal aes_din, aes_dout         : std_logic_vector(127 downto 0);
  signal aes_din_wren, aes_dout_dv : std_logic;
  signal ready_int                 : std_logic;
  signal m_pad                     : std_logic_vector(127 downto 0);

  signal ip_reg      : std_logic_vector(31 downto 0);
  signal read_ip_reg : std_logic_vector(31 downto 0);

  type states is (INIT, INITWAIT, IDLE, BUSY);
  signal state : states;

  type read_states is (INIT, IDLE, BUSY);
  signal read_state : read_states;

  type output_states is (IDLE, BUSY);
  signal output_state : output_states;

--  signal shift_counter : std_logic_vector(31 downto 0);
  signal output_counter : std_logic_vector(4 downto 0);
  
  
  signal first4bytes_pad   : std_logic_vector(31 downto 0);
  signal first4bytes_input : std_logic_vector(31 downto 0);

  signal mask_onehot     : std_logic_vector(31 downto 0);
  signal mask_onehot_inv : std_logic_vector(31 downto 0);

  signal ip_out_int : std_logic_vector(31 downto 0);
  
begin

  mask_onehot_inv <= not mask_onehot;

  with state select
    ready <=
    '1' when IDLE,
    '0' when others;

  first4bytes_pad   <= m_pad(127 downto 96);
  first4bytes_input <= (ip_reg and mask_onehot_inv) or (first4bytes_pad and mask_onehot);


  LOAD_UNIT_LOGIC : process (clk, reset)
  begin
    if reset = '1' then
      state        <= INIT;
      aes_din_wren <= '0';
      aes_din      <= (others => '0');
      mask_onehot  <= (others => '0');
      ip_reg       <= (others => '0');
    elsif clk'event and clk = '1' then
      mask_onehot  <= (others => '1');
      aes_din_wren <= '0';

      if state = INIT and ready_int = '1' then
        aes_din      <= key(255 downto 128);
        aes_din_wren <= '1';
        state        <= INITWAIT;
      elsif state = INITWAIT and aes_dout_dv = '1' then
        state        <= IDLE;
      elsif state = IDLE and ip_wren = '1' then
        state        <= BUSY;
        ip_reg       <= ip_in;
      elsif state = BUSY then

        if mask_onehot(0) = '1' then
          aes_din_wren <= '1';
          aes_din      <= first4bytes_input & m_pad(95 downto 0);
        else
          state        <= IDLE;
        end if;

        mask_onehot(31)  <= '0';
        for i in 30 downto 0 loop
          mask_onehot(i) <= mask_onehot(i+1);
        end loop;

      end if;

    end if;
  end process LOAD_UNIT_LOGIC;

  
  READ_UNIT_LOGIC : process (clk, reset)
  begin
    if reset = '1' then
      m_pad          <= (others => '0');

      read_state     <= INIT;
      ip_out         <= (others => '0');
      ip_dv          <= '0';
      output_state   <= IDLE;
      read_ip_reg    <= (others => '0');
      output_counter <= (others => '1');
    elsif clk'event and clk = '1' then

      ip_dv <= '0';
      
      if read_state = INIT then
        if aes_dout_dv = '1' then
          m_pad      <= aes_dout;
          read_state <= IDLE;
        end if;


      elsif read_state = IDLE then

        if aes_dout_dv = '1' then
          if output_counter = "11111" then
            read_ip_reg <= ip_reg;
          end if;
          output_counter <= output_counter - 1;

          ip_out_int <= ip_out_int(30 downto 0) & aes_dout(127);
          
        end if;
        if output_counter = "00000" then
          output_state <= BUSY;
        end if;

      end if;

      if output_state = BUSY then
        output_state <= IDLE;
        ip_dv        <= '1';
        ip_out       <= ip_out_int xor read_ip_reg;
      end if;

    end if;
  end process READ_UNIT_LOGIC;

-- OUTPUT_UNIT_LOGIC : process (clk, reset)
-- begin
-- if reset = '1' then
-- ip_out <= (others => '0');
-- ip_dv <= '0';
-- output_state <= IDLE;
-- elsif clk'event and clk = '1' then

-- end if;
-- end process OUTPUT_UNIT_LOGIC;

  AES0 : aes_encrypt_unit
    port map (
      key_in    => key(127 downto 0),
      key_wren  => key_wren,
      ready     => ready_int,
      data_in   => aes_din,
      data_wren => aes_din_wren,
      data_dv   => aes_dout_dv,
      data_out  => aes_dout,
      clk       => clk,
      reset     => reset);



end rtl;
