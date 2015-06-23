
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   03/25/2008
-- Last Update:   04/02/2008
-- Project Name:  camellia-vhdl
-- Description:   Interface to the Camellia core
--
-- Copyright (C) 2008  Paolo Fulgoni
-- This file is part of camellia-vhdl.
-- camellia-vhdl is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
-- camellia-vhdl is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- The Camellia cipher algorithm is 128 bit cipher developed by NTT and
-- Mitsubishi Electric researchers.
-- http://info.isl.ntt.co.jp/crypt/eng/camellia/
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity CAMELLIA_IF is
    port    (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            data_in   : in  STD_LOGIC_VECTOR (0 to 15);
            enc_dec   : in  STD_LOGIC;
            en_data   : in  STD_LOGIC;
            next_data : out STD_LOGIC;
            key_in    : in  STD_LOGIC_VECTOR (0 to 15);
            k_len     : in  STD_LOGIC_VECTOR (0 to 1);
            en_key    : in  STD_LOGIC;
            next_key  : out STD_LOGIC;
            data_out  : out STD_LOGIC_VECTOR (0 to 15);
            out_rdy   : out STD_LOGIC
            );
end CAMELLIA_IF;

architecture RTL of CAMELLIA_IF is

    component CAMELLIA is
        port  (
                clk        : in  STD_LOGIC;
                reset      : in  STD_LOGIC;
                data_in    : in  STD_LOGIC_VECTOR (0 to 127);
                enc_dec    : in  STD_LOGIC;
                data_rdy   : in  STD_LOGIC;
                data_acq   : out STD_LOGIC;
                key        : in  STD_LOGIC_VECTOR (0 to 255);
                k_len      : in  STD_LOGIC_VECTOR (0 to 1);
                key_rdy    : in  STD_LOGIC;
                key_acq    : out STD_LOGIC;
                data_out   : out STD_LOGIC_VECTOR (0 to 127);
                output_rdy : out STD_LOGIC
                );
    end component;

    signal  s_clk        : STD_LOGIC;
    signal  s_reset      : STD_LOGIC;
    signal  s_data_in    : STD_LOGIC_VECTOR (0 to 127);
    signal  s_enc_dec    : STD_LOGIC;
    signal  s_data_rdy   : STD_LOGIC;
    signal  s_data_acq   : STD_LOGIC;
    signal  s_key        : STD_LOGIC_VECTOR (0 to 255);
    signal  s_k_len      : STD_LOGIC_VECTOR (0 to 1);
    signal  s_key_rdy    : STD_LOGIC;
    signal  s_key_acq    : STD_LOGIC;
    signal  s_data_out   : STD_LOGIC_VECTOR (0 to 127);
    signal  s_output_rdy : STD_LOGIC;
    
    signal  key_count     : STD_LOGIC_VECTOR (3 downto 0);
    signal  din_count     : STD_LOGIC_VECTOR (2 downto 0);
    signal  dout_count    : STD_LOGIC_VECTOR (2 downto 0);
    
    signal  reg_key       : STD_LOGIC_VECTOR (0 to 255);
    signal  reg_din       : STD_LOGIC_VECTOR (0 to 127);
    signal  reg_dout      : STD_LOGIC_VECTOR (0 to 127);
    signal  reg_next_data : STD_LOGIC;
    signal  reg_next_key  : STD_LOGIC;
    
    signal  int_out_rdy   : STD_LOGIC;
    
    -- input constant
    constant KLEN_128 : STD_LOGIC_VECTOR (0 to 1) := "00";
    constant KLEN_192 : STD_LOGIC_VECTOR (0 to 1) := "01";
    constant KLEN_256 : STD_LOGIC_VECTOR (0 to 1) := "10";

begin

    -- S-FUNCTION
    core : CAMELLIA
        port map(s_clk, s_reset, s_data_in, s_enc_dec, s_data_rdy,
                 s_data_acq, s_key, s_k_len, s_key_rdy, s_key_acq,
                 s_data_out, s_output_rdy);

    KEY_PROC: process (reset, clk)
    begin
        
        if (reset = '1') then
            reg_next_key  <= '1';
            key_count <= "0000";
            reg_key   <= (others=>'0');
            s_key_rdy <= '0';
        elsif (clk'event and clk = '1') then
        
            if (en_key = '1') then
                reg_next_key <= '0';
                key_count <= key_count + "0001";
                case k_len is
                    when KLEN_128 =>
                        reg_key <= reg_key(16 to 127) & key_in & X"00000000000000000000000000000000";
                    when KLEN_192 =>
                        reg_key <= reg_key(16 to 191) & key_in & X"0000000000000000";
                    when others =>
                        reg_key <= reg_key(16 to 255) & key_in;
                end case;
            else
                key_count <= "0000";
                if (s_key_acq = '1') then
                    reg_next_key  <= '1';
                else
                    reg_next_key  <= reg_next_key;
                end if;
            end if;  
        
            if ((key_count = "0111" and k_len = KLEN_128) or
                (key_count = "1100" and k_len = KLEN_192) or
                 key_count = "1111") then
                s_key_rdy <= '1';
            elsif (s_key_acq = '1') then
                s_key_rdy <= '0';
            else
                s_key_rdy <= s_key_rdy;
            end if;
                     
        end if;
        
    end process;
    
    DATA_IN_PROC: process (reset, clk)
    begin
        
        if (reset = '1') then
            reg_next_data <= '1';
            din_count <= "000";
            reg_din   <= (others=>'0');
            s_data_rdy <= '0';
        elsif (clk'event and clk = '1') then
            
            if (en_data = '1') then
                reg_next_data <= '0';
                din_count <= din_count + "001";
                reg_din   <= reg_din(16 to 127) & data_in;
            else
                din_count <= "000";
                if (s_data_acq = '1') then
                    reg_next_data  <= '1';
                else
                    reg_next_data  <= reg_next_data;
                end if;
            end if;
            
            if (din_count = "111") then
                s_data_rdy <= '1';
            elsif (s_data_acq = '1') then
                s_data_rdy <= '0';
            else
                s_data_rdy <= s_data_rdy;
            end if;
                     
        end if;
        
    end process;

    DATA_OUT_PROC: process (reset, clk)
    begin
        
        if (reset = '1') then
            dout_count  <= "000";
            int_out_rdy <= '0';
            reg_dout    <= (others=>'0');
        elsif (clk'event and clk = '1') then
            
            if (int_out_rdy = '1') then
                if (dout_count /= "111") then
                    dout_count <= dout_count + "001";
                    reg_dout   <= reg_dout(16 to 127) & X"0000"; -- <<< 16
                else
                    int_out_rdy <= '0';
                end if;
            else
                if (s_output_rdy = '1') then
                    dout_count <= "000";
                    reg_dout <= s_data_out;
                    int_out_rdy<= '1';
                end if;
            end if;
        end if;
    
    end process;

    s_clk     <= clk;
    s_reset   <= reset;
    s_data_in <= reg_din;
    s_enc_dec <= enc_dec;
    s_key     <= reg_key;
    s_k_len   <= k_len;
    data_out  <= reg_dout(0 to 15);
    out_rdy   <= int_out_rdy;
    next_key  <= reg_next_key;
    next_data <= reg_next_data;
    
end RTL;

