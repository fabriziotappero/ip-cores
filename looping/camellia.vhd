
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   02/01/2008
-- Last Update:   03/28/2008
-- Project Name:  camellia-vhdl
-- Description:   Looping version of Camellia
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

entity camellia is
    port    (
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
            
            -- post-synthesis debug
            
            
            );
end camellia;

architecture RTL of camellia is
    
    signal s_clk        : STD_LOGIC;
    signal s_reset      : STD_LOGIC;
    signal s_data_in    : STD_LOGIC_VECTOR (0 to 127);
    signal s_enc_dec    : STD_LOGIC;
    signal s_data_rdy   : STD_LOGIC;
    signal s_data_acq   : STD_LOGIC;
    signal s_key_in     : STD_LOGIC_VECTOR (0 to 255);
    signal s_k_len      : STD_LOGIC_VECTOR (0 to 1);
    signal s_key_rdy    : STD_LOGIC;
    signal s_key_acq    : STD_LOGIC;
    signal s_data_to    : STD_LOGIC_VECTOR (0 to 127);
    signal s_output_rdy : STD_LOGIC;
    signal s_k1         : STD_LOGIC_VECTOR (0 to 63);
    signal s_k2         : STD_LOGIC_VECTOR (0 to 63);
    signal s_newdata    : STD_LOGIC;
    signal s_sel        : STD_LOGIC;
    signal s_pre_xor    : STD_LOGIC_VECTOR (0 to 127);
    signal s_post_xor   : STD_LOGIC_VECTOR (0 to 127);
    signal s_data_from  : STD_LOGIC_VECTOR (0 to 127);

    component datapath is
        port    (
                clk      : in STD_LOGIC;
                reset    : in STD_LOGIC;
                data_in  : in STD_LOGIC_VECTOR (0 to 127);
                k1       : in STD_LOGIC_VECTOR (0 to 63);
                k2       : in STD_LOGIC_VECTOR (0 to 63);
                newdata  : in STD_LOGIC;
                sel      : in STD_LOGIC;
                pre_xor  : in STD_LOGIC_VECTOR (0 to 127);
                post_xor : in STD_LOGIC_VECTOR (0 to 127);
                data_out : out STD_LOGIC_VECTOR (0 to 127)
                );
    end component;

    component control is
        port    (
                clk        : in  STD_LOGIC;
                reset      : in  STD_LOGIC;
                data_in    : in  STD_LOGIC_VECTOR (0 to 127);
                enc_dec    : in  STD_LOGIC;
                data_rdy   : in  STD_LOGIC;
                data_acq   : out STD_LOGIC;
                key_in     : in  STD_LOGIC_VECTOR (0 to 255);
                k_len      : in  STD_LOGIC_VECTOR (0 to 1);
                key_rdy    : in  STD_LOGIC;
                key_acq    : out STD_LOGIC;
                data_to    : out STD_LOGIC_VECTOR (0 to 127);
                output_rdy : out STD_LOGIC;
                k1         : out STD_LOGIC_VECTOR (0 to 63);
                k2         : out STD_LOGIC_VECTOR (0 to 63);
                newdata    : out STD_LOGIC;
                sel        : out STD_LOGIC;
                pre_xor    : out STD_LOGIC_VECTOR (0 to 127);
                post_xor   : out STD_LOGIC_VECTOR (0 to 127);
                data_from  : in  STD_LOGIC_VECTOR (0 to 127)
                );
    end component;

begin

    DP   : datapath
        port map(
                clk      => s_clk,
                reset    => s_reset,
                data_in  => s_data_to,
                k1       => s_k1,
                k2       => s_k2,
                newdata  => s_newdata,
                sel      => s_sel,
                pre_xor  => s_pre_xor,
                post_xor => s_post_xor,
                data_out => s_data_from
        );

    CTRL : control
        port map(
                clk        => s_clk,
                reset      => s_reset,
                data_in    => s_data_in,
                enc_dec    => s_enc_dec,
                data_rdy   => s_data_rdy,
                data_acq   => s_data_acq,
                key_in     => s_key_in,
                k_len      => s_k_len,
                key_rdy    => s_key_rdy,
                key_acq    => s_key_acq,
                data_to    => s_data_to,
                output_rdy => s_output_rdy,
                k1         => s_k1,
                k2         => s_k2,
                newdata    => s_newdata,
                sel        => s_sel,
                pre_xor    => s_pre_xor,
                post_xor   => s_post_xor,
                data_from  => s_data_from
        );

    s_clk       <= clk;
    s_reset     <= reset;
    s_data_in   <= data_in;
    s_enc_dec   <= enc_dec;
    s_data_rdy  <= data_rdy;
    s_key_in    <= key;
    s_k_len     <= k_len;
    s_key_rdy   <= key_rdy;
    
    data_acq    <= s_data_acq;
    key_acq     <= s_key_acq;
    data_out    <= s_data_from(64 to 127) & s_data_from(0 to 63);
    output_rdy  <= s_output_rdy;

end RTL;
