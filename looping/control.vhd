
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   01/31/2008
-- Last Update:   03/28/2008
-- Project Name:  camellia-vhdl
-- Description:   Control unit and key handling
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

entity control is
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
            
            data_to    : out STD_LOGIC_VECTOR (0 to 127); -- data to datapath
            output_rdy : out STD_LOGIC;
            k1         : out STD_LOGIC_VECTOR (0 to 63);
            k2         : out STD_LOGIC_VECTOR (0 to 63);
            newdata    : out STD_LOGIC;
            sel        : out STD_LOGIC;
            pre_xor    : out STD_LOGIC_VECTOR (0 to 127);
            post_xor   : out STD_LOGIC_VECTOR (0 to 127);
            data_from  : in  STD_LOGIC_VECTOR (0 to 127)  -- data from datapath
            );
end control;

architecture RTL of control is

    type STATUS is (KEYa, KEYb, KEYc, KEYd, KEYe, KEYf,
                    SIX1a, SIX1b, SIX1c, SIX1d, SIX1e, SIX1f,
                    FL1,
                    SIX2a, SIX2b, SIX2c, SIX2d, SIX2e, SIX2f,
                    FL2,
                    SIX3a, SIX3b, SIX3c, SIX3d, SIX3e, SIX3f,
                    FL3,
                    SIX4a, SIX4b, SIX4c, SIX4d, SIX4e, SIX4f,
                    WT
                    );
    signal PS, NS    : STATUS;
    
    type K1_TYPE is (SIG1, SIG2, SIG3, SIG4, SIG5, SIG6,
                     KL_L, KL_R, KR_L, KR_R, KA_L, KA_R, KB_L, KB_R);
    signal k1_sel    : K1_TYPE;
    type K2_TYPE is (KL_L, KL_R, KR_L, KR_R, KA_L, KA_R, KB_L, KB_R);
    signal k2_sel    : K2_TYPE;
    type POSTXOR_TYPE is (KL, KA, KB, ZERO);
    signal postxor_sel    : POSTXOR_TYPE;
    type PREXOR_TYPE is (KL, KR, KA, KB, ZERO);
    signal prexor_sel    : PREXOR_TYPE;

    -- keys
    signal reg_kl    : STD_LOGIC_VECTOR (0 to 127);
    signal reg_kr    : STD_LOGIC_VECTOR (0 to 127);
    signal reg_ka    : STD_LOGIC_VECTOR (0 to 127);
    signal reg_kb    : STD_LOGIC_VECTOR (0 to 127);
    --keys shifted each step
    signal reg_kl_s  : STD_LOGIC_VECTOR (0 to 127);
    signal reg_kr_s  : STD_LOGIC_VECTOR (0 to 127);
    signal reg_ka_s  : STD_LOGIC_VECTOR (0 to 127);
    signal reg_kb_s  : STD_LOGIC_VECTOR (0 to 127);
    
    signal reg_k_len   : STD_LOGIC_VECTOR (0 to 1);
    signal reg_enc_dec : STD_LOGIC;

    -- input constant
    constant KLEN_128 : STD_LOGIC_VECTOR (0 to 1) := "00";
    constant KLEN_192 : STD_LOGIC_VECTOR (0 to 1) := "01";
    constant KLEN_256 : STD_LOGIC_VECTOR (0 to 1) := "10";
    constant ENC      : STD_LOGIC := '0';
    constant DEC      : STD_LOGIC := '1';
    constant SEL_F    : STD_LOGIC := '0';
    constant SEL_FL   : STD_LOGIC := '1';

    -- constant keys
    constant sigma1 : STD_LOGIC_VECTOR (0 to 63) := X"A09E667F3BCC908B";
    constant sigma2 : STD_LOGIC_VECTOR (0 to 63) := X"B67AE8584CAA73B2";
    constant sigma3 : STD_LOGIC_VECTOR (0 to 63) := X"C6EF372FE94F82BE";
    constant sigma4 : STD_LOGIC_VECTOR (0 to 63) := X"54FF53A5F1D36F1C";
    constant sigma5 : STD_LOGIC_VECTOR (0 to 63) := X"10E527FADE682D1D";
    constant sigma6 : STD_LOGIC_VECTOR (0 to 63) := X"B05688C2B3E6C1FD";

begin

    with k1_sel select
        k1 <=   sigma1                 when SIG1,
                sigma2                 when SIG2,
                sigma3                 when SIG3,
                sigma4                 when SIG4,
                sigma5                 when SIG5,
                sigma6                 when SIG6,
                reg_kl_s(0 to 63)      when KL_L,
                reg_kl_s(64 to 127)    when KL_R,
                reg_kr_s(0 to 63)      when KR_L,
                reg_kr_s(64 to 127)    when KR_R,
                reg_ka_s(0 to 63)      when KA_L,
                reg_ka_s(64 to 127)    when KA_R,
                reg_kb_s(0 to 63)      when KB_L,
                reg_kb_s(64 to 127)    when others;
    with k2_sel select
        k2 <=   reg_kl_s(0 to 63)      when KL_L,
                reg_kl_s(64 to 127)    when KL_R,
                reg_kr_s(0 to 63)      when KR_L,
                reg_kr_s(64 to 127)    when KR_R,
                reg_ka_s(0 to 63)      when KA_L,
                reg_ka_s(64 to 127)    when KA_R,
                reg_kb_s(0 to 63)      when KB_L,
                reg_kb_s(64 to 127)    when others;
                
    with postxor_sel select
        post_xor <= reg_kl_s(64 to 127) & reg_kl_s(0 to 63)   when KL,  
                    reg_ka_s(64 to 127) & reg_ka_s(0 to 63)   when KA,
                    reg_kb_s(64 to 127) & reg_kb_s(0 to 63)   when KB,
                    (others=>'0')                             when others;
                      
    with prexor_sel select
        pre_xor  <=   reg_kl_s           when KL,
                      reg_kr_s           when KR,
                      reg_ka_s           when KA,
                      reg_kb_s           when KB,
                      (others=>'0')      when others;
                      

    REGISTERS_UPDATE : process(reset, clk)
        variable coming_from_key : STD_LOGIC;
    begin
    if (reset = '1') then
        reg_kl           <= (others=>'0');
        reg_kr           <= (others=>'0');
        reg_ka           <= (others=>'0');
        reg_kb           <= (others=>'0');
        reg_kl_s         <= (others=>'0');
        reg_kr_s         <= (others=>'0');
        reg_ka_s         <= (others=>'0');
        reg_kb_s         <= (others=>'0');
        reg_enc_dec      <= '0';
        reg_k_len        <= (others=>'0');
        output_rdy       <= '0';
        coming_from_key  := '0';
    else
        if (clk'event and clk = '1') then
            case PS is
                when KEYa =>
                    coming_from_key  := '1';
                    reg_kl           <= key_in(0 to 127);
                    reg_kl_s         <= key_in(0 to 127);
                    reg_k_len        <= k_len;
                    case k_len is
                        when KLEN_192 =>
                            reg_kr    <= key_in(128 to 191) & not (key_in(128 to 191));
                            reg_kr_s  <= key_in(128 to 191) & not (key_in(128 to 191));
                        when KLEN_256 =>
                            reg_kr    <= key_in(128 to 255);
                            reg_kr_s  <= key_in(128 to 255);
                        when others =>
                            reg_kr    <= (others=>'0');
                            reg_kr_s  <= (others=>'0');
                    end case;
                    k1_sel    <= SIG1;
                when KEYb =>
                    k1_sel    <= SIG2;
                when KEYc =>
                    k1_sel    <= SIG3;
                when KEYd =>
                    k1_sel    <= SIG4;
                when KEYe =>
                    reg_ka    <= data_from;
                    reg_ka_s  <= data_from;
                    k1_sel    <= SIG5;
                when KEYf =>
                    k1_sel    <= SIG6;
                when SIX1a =>
                    if (enc_dec = ENC) then
                        if (coming_from_key = '1') then
                            if (reg_k_len = KLEN_128) then
                                reg_ka   <= data_from;
                                reg_ka_s <= data_from;
                            else
                                reg_kb   <= data_from;
                                reg_kb_s <= data_from;
                            end if;
                        else
                            reg_ka_s <= reg_ka;
                            reg_kb_s <= reg_kb;
                            reg_kl_s <= reg_kl;
                            reg_kr_s <= reg_kr;
                        end if;
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KA_L;
                        else
                            k1_sel <= KB_L;
                        end if;
                    else -- DEC
                        if (coming_from_key = '1') then
                            if (reg_k_len = KLEN_128) then
                                reg_ka   <= data_from;
                                reg_ka_s <= data_from(111 to 127) & data_from(0 to 110); -- >>> 17
                            else
                                reg_kb   <= data_from;
                                reg_kb_s <= data_from(111 to 127) & data_from(0 to 110); -- >>> 17
                                reg_ka_s <= reg_ka_s(111 to 127) & reg_ka_s(0 to 110); -- >>> 17
                                reg_kr_s <= reg_kr_s(111 to 127) & reg_kr_s(0 to 110); -- >>> 17
                            end if;
                            reg_kl_s  <= reg_kl_s(111 to 127) & reg_kl_s(0 to 110); -- >>> 17
                        else
                            reg_ka_s <= reg_ka(111 to 127) & reg_ka(0 to 110); -- >>> 17
                            reg_kb_s <= reg_kb(111 to 127) & reg_kb(0 to 110); -- >>> 17
                            reg_kl_s <= key_in(111 to 127) & key_in(0 to 110); --kl >>> 17
                            reg_kr_s <= reg_kr(111 to 127) & reg_kr(0 to 110); -- >>> 17
                        end if;
                        k1_sel <= KL_R;
                    end if;
                    reg_enc_dec <= enc_dec;
                when SIX1b =>
                    coming_from_key  := '0';
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KA_R;
                        else
                            k1_sel <= KB_R;
                        end if;
                    else -- DEC
                        k1_sel <= KL_L; -- for each value of reg_k_len
                    end if;
                when SIX1c =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KL_L;
                            reg_kl_s  <= reg_kl_s(15 to 127) & reg_kl_s(0 to 14); -- <<< 15
                        else
                            k1_sel <= KR_L;
                            reg_kr_s  <= reg_kr_s(15 to 127) & reg_kr_s(0 to 14); -- <<< 15
                        end if;
                    else -- DEC
                        reg_ka_s <= reg_ka_s(111 to 127) & reg_ka_s(0 to 110); -- >>> 17
                        k1_sel <= KA_R; -- for each value of reg_k_len
                    end if;
                when SIX1d =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KL_R;
                        else
                            k1_sel <= KR_R;
                        end if;
                    else -- DEC
                        k1_sel <= KA_L; -- for each value of reg_k_len
                    end if;
                when SIX1e =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            reg_ka_s  <= reg_ka_s(15 to 127) & reg_ka_s(0 to 14); -- <<< 15
                        else
                            reg_ka_s  <= reg_ka_s(15 to 127) & reg_ka_s(0 to 14); -- <<< 15
                        end if;
                        k1_sel <= KA_L;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            reg_kl_s <= reg_kl_s(111 to 127) & reg_kl_s(0 to 110); -- >>> 17
                            k1_sel <= KL_R;
                        else
                            reg_kr_s <= reg_kr_s(111 to 127) & reg_kr_s(0 to 110); -- >>> 17
                            k1_sel <= KR_R;
                        end if;
                    end if;
                when SIX1f =>
                    if (reg_enc_dec = ENC) then
                        k1_sel <= KA_R;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KL_L;
                        else
                            k1_sel <= KR_L;
                        end if;
                    end if;
                when FL1 =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KA_L;
                            k2_sel <= KA_R;
                            reg_kl_s  <= reg_kl_s(15 to 127) & reg_kl_s(0 to 14); -- <<< 15
                            reg_ka_s  <= reg_ka_s(15 to 127) & reg_ka_s(0 to 14); -- <<< 15
                        else
                            k1_sel <= KR_L;
                            k2_sel <= KR_R;
                            reg_kb_s  <= reg_kb_s(15 to 127) & reg_kb_s(0 to 14); -- <<< 15
                            reg_kr_s  <= reg_kr_s(15 to 127) & reg_kr_s(0 to 14); -- <<< 15
                        end if;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KL_R;
                            k2_sel <= KL_L;
                        else
                            k1_sel <= KA_R;
                            k2_sel <= KA_L;
                        end if;
                        reg_ka_s <= reg_ka_s(111 to 127) & reg_ka_s(0 to 110); -- >>> 17
                        reg_kl_s <= reg_kl_s(111 to 127) & reg_kl_s(0 to 110); -- >>> 17
                    end if;
                when SIX2a =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KL_L;
                            reg_kl_s  <= reg_kl_s(15 to 127) & reg_kl_s(0 to 14); -- <<< 15
                        else
                            k1_sel <= KB_L;
                            reg_kb_s  <= reg_kb_s(15 to 127) & reg_kb_s(0 to 14); -- <<< 15
                            reg_kl_s  <= reg_kl_s(15 to 127) & reg_kl_s(0 to 14); -- <<< 15
                        end if;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KA_R;
                            reg_ka_s <= reg_ka_s(111 to 127) & reg_ka_s(0 to 110); -- >>> 17
                        else
                            k1_sel <= KL_R;
                            reg_kb_s <= reg_kb_s(111 to 127) & reg_kb_s(0 to 110); -- >>> 17
                            reg_kl_s <= reg_kl_s(111 to 127) & reg_kl_s(0 to 110); -- >>> 17
                        end if;
                    end if;
                when SIX2b =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KL_R;
                        else
                            k1_sel <= KB_R;
                            reg_kl_s  <= reg_kl_s(15 to 127) & reg_kl_s(0 to 14); -- <<< 15
                        end if;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KA_L;
                        else
                            k1_sel <= KL_L;
                            reg_kb_s <= reg_kb_s(111 to 127) & reg_kb_s(0 to 110); -- >>> 17
                        end if;
                    end if;
                when SIX2c =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KA_L;
                            reg_ka_s  <= reg_ka_s(15 to 127) & reg_ka_s(0 to 14); -- <<< 15
                        else
                            k1_sel <= KL_L;
                            reg_kl_s  <= reg_kl_s(15 to 127) & reg_kl_s(0 to 14); -- <<< 15
                        end if;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KL_R;
                            reg_kl_s <= reg_kl_s(111 to 127) & reg_kl_s(0 to 110); -- >>> 17
                        else
                            k1_sel <= KB_R;
                            reg_kb_s <= reg_kb_s(111 to 127) & reg_kb_s(0 to 110); -- >>> 17
                        end if;
                    end if;
                when SIX2d =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            reg_kl_s  <= reg_kl_s(15 to 127) & reg_kl_s(0 to 14); -- <<< 15
                        else
                            reg_ka_s  <= reg_ka_s(15 to 127) & reg_ka_s(0 to 14); -- <<< 15
                        end if;
                        k1_sel <= KL_R;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KA_L;
                            reg_ka_s <= reg_ka_s(113 to 127) & reg_ka_s(0 to 112); -- >>> 15
                        else
                            k1_sel <= KB_L;
                            reg_kr_s <= reg_kr_s(111 to 127) & reg_kr_s(0 to 110); -- >>> 17
                        end if;
                    end if;
                when SIX2e =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            reg_ka_s  <= reg_ka_s(15 to 127) & reg_ka_s(0 to 14); -- <<< 15
                        else
                            reg_ka_s  <= reg_ka_s(15 to 127) & reg_ka_s(0 to 14); -- <<< 15
                        end if;
                        k1_sel <= KA_L;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KL_R;
                            reg_kl_s <= reg_kl_s(113 to 127) & reg_kl_s(0 to 112); -- >>> 15
                        else
                            k1_sel <= KR_R;
                            reg_kr_s <= reg_kr_s(111 to 127) & reg_kr_s(0 to 110); -- >>> 17
                        end if;
                    end if;
                when SIX2f =>
                    if (reg_enc_dec = ENC) then
                        k1_sel <= KA_R;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KL_L;
                        else
                            k1_sel <= KR_L;
                        end if;
                    end if;
                when FL2 =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            reg_kl_s  <= reg_kl_s(17 to 127) & reg_kl_s(0 to 16); -- <<< 17
                        else
                            reg_kr_s  <= reg_kr_s(15 to 127) & reg_kr_s(0 to 14); -- <<< 15
                            reg_kl_s  <= reg_kl_s(15 to 127) & reg_kl_s(0 to 14); -- <<< 15
                        end if;
                        k1_sel <= KL_L;
                        k2_sel <= KL_R;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KA_R;
                            k2_sel <= KA_L;
                            reg_ka_s <= reg_ka_s(113 to 127) & reg_ka_s(0 to 112); -- >>> 15
                        else
                            k1_sel <= KL_R;
                            k2_sel <= KL_L;
                            reg_ka_s <= reg_ka_s(111 to 127) & reg_ka_s(0 to 110); -- >>> 17
                            reg_kl_s <= reg_kl_s(111 to 127) & reg_kl_s(0 to 110); -- >>> 17
                        end if;
                    end if;
                when SIX3a =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KL_L;
                            reg_kl_s  <= reg_kl_s(17 to 127) & reg_kl_s(0 to 16); -- <<< 17
                        else
                            k1_sel <= KR_L;
                            reg_kr_s  <= reg_kr_s(15 to 127) & reg_kr_s(0 to 14); -- <<< 15
                        end if;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KA_R;
                        else
                            k1_sel <= KA_R;
                        end if;
                        reg_ka_s <= reg_ka_s(113 to 127) & reg_ka_s(0 to 112); -- >>> 15
                    end if;
                when SIX3b =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KL_R;
                            reg_ka_s  <= reg_ka_s(17 to 127) & reg_ka_s(0 to 16); -- <<< 17
                        else
                            k1_sel <= KR_R;
                            reg_kb_s  <= reg_kb_s(15 to 127) & reg_kb_s(0 to 14); -- <<< 15
                        end if;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KA_L;
                            reg_kl_s <= reg_kl_s(113 to 127) & reg_kl_s(0 to 112); -- >>> 15
                        else
                            k1_sel <= KA_L;
                        end if;
                    end if;
                when SIX3c =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KA_L;
                            reg_ka_s  <= reg_ka_s(17 to 127) & reg_ka_s(0 to 16); -- <<< 17
                        else
                            k1_sel <= KB_L;
                            reg_kb_s  <= reg_kb_s(15 to 127) & reg_kb_s(0 to 14); -- <<< 15
                        end if;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KL_R;
                        else
                            k1_sel <= KL_R;
                        end if;
                        reg_kl_s <= reg_kl_s(113 to 127) & reg_kl_s(0 to 112); -- >>> 15
                    end if;
                when SIX3d =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KA_R;
                        else
                            k1_sel <= KB_R;
                        end if;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KL_L;
                        else
                            k1_sel <= KL_L;
                            reg_kb_s <= reg_kb_s(113 to 127) & reg_kb_s(0 to 112); -- >>> 15
                        end if;
                    end if;
                when SIX3e =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            reg_kl_s  <= reg_kl_s(17 to 127) & reg_kl_s(0 to 16); -- <<< 17
                        else
                            reg_kl_s  <= reg_kl_s(17 to 127) & reg_kl_s(0 to 16); -- <<< 17
                        end if;
                        k1_sel <= KL_L;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KA_R;
                            reg_ka_s <= reg_ka_s(113 to 127) & reg_ka_s(0 to 112); -- >>> 15
                        else
                            k1_sel <= KB_R;
                            reg_kb_s <= reg_kb_s(113 to 127) & reg_kb_s(0 to 112); -- >>> 15
                        end if;
                    end if;
                when SIX3f =>
                    if (reg_enc_dec = ENC) then
                        if (reg_k_len = KLEN_128) then
                            reg_ka_s  <= reg_ka_s(17 to 127) & reg_ka_s(0 to 16); -- <<< 17
                        else
                            reg_ka_s  <= reg_ka_s(15 to 127) & reg_ka_s(0 to 14); -- <<< 15
                        end if;
                        k1_sel <= KL_R;
                    else -- DEC
                        if (reg_k_len = KLEN_128) then
                            k1_sel <= KA_L;
                            reg_kl_s <= reg_kl_s(113 to 127) & reg_kl_s(0 to 112); -- >>> 15
                        else
                            k1_sel <= KB_L;
                            reg_kr_s <= reg_kr_s(113 to 127) & reg_kr_s(0 to 112); -- >>> 15
                        end if;
                    end if;
                when FL3 =>
                    if (reg_enc_dec = ENC) then
                        k1_sel  <= KA_L;
                        k2_sel  <= KA_R;
                        reg_kr_s  <= reg_kr_s(17 to 127) & reg_kr_s(0 to 16); -- <<< 17
                        reg_ka_s  <= reg_ka_s(17 to 127) & reg_ka_s(0 to 16); -- <<< 17
                    else -- DEC
                        k1_sel  <= KR_R;
                        k2_sel  <= KR_L;
                        reg_ka_s <= reg_ka_s(113 to 127) & reg_ka_s(0 to 112); -- >>> 15
                        reg_kr_s <= reg_kr_s(113 to 127) & reg_kr_s(0 to 112); -- >>> 15
                    end if;
                when SIX4a =>
                    if (reg_enc_dec = ENC) then
                        k1_sel <= KR_L;
                        reg_kr_s  <= reg_kr_s(17 to 127) & reg_kr_s(0 to 16); -- <<< 17
                    else -- DEC
                        k1_sel <= KA_R;
                        reg_ka_s <= reg_ka_s(113 to 127) & reg_ka_s(0 to 112); -- >>> 15
                    end if;
                when SIX4b =>
                    if (reg_enc_dec = ENC) then
                        k1_sel <= KR_R;
                    else -- DEC
                        k1_sel <= KA_L;
                    end if;
                when SIX4c =>
                    if (reg_enc_dec = ENC) then
                        k1_sel <= KA_L;
                        reg_ka_s  <= reg_ka_s(17 to 127) & reg_ka_s(0 to 16); -- <<< 17
                    else -- DEC
                        k1_sel <= KR_R;
                        reg_kr_s <= reg_kr_s(113 to 127) & reg_kr_s(0 to 112); -- >>> 15
                    end if;
                when SIX4d =>
                    if (reg_enc_dec = ENC) then
                        k1_sel <= KA_R;
                        reg_kl_s  <= reg_kl_s(17 to 127) & reg_kl_s(0 to 16); -- <<< 17
                        reg_kb_s  <= reg_kb_s(17 to 127) & reg_kb_s(0 to 16); -- <<< 17
                    else -- DEC
                        k1_sel <= KR_L;
                        reg_kb_s <= reg_kb_s(113 to 127) & reg_kb_s(0 to 112); -- >>> 15
                        reg_kl_s <= reg_kl_s(113 to 127) & reg_kl_s(0 to 112); -- >>> 15
                    end if;
                when SIX4e =>
                    if (reg_enc_dec = ENC) then
                        k1_sel <= KL_L;
                        reg_kl_s  <= reg_kl_s(17 to 127) & reg_kl_s(0 to 16); -- <<< 17
                        reg_kb_s  <= reg_kb_s(17 to 127) & reg_kb_s(0 to 16); -- <<< 17
                    else -- DEC
                        k1_sel <= KB_R;
                        reg_kb_s <= reg_kb_s(113 to 127) & reg_kb_s(0 to 112); -- >>> 15
                        reg_kl_s <= reg_kl_s(113 to 127) & reg_kl_s(0 to 112); -- >>> 15
                    end if;
                when SIX4f =>
                    if (reg_enc_dec = ENC) then
                        k1_sel <= KL_R;
                        reg_kb_s  <= reg_kb_s(17 to 127) & reg_kb_s(0 to 16); -- <<< 17
                    else -- DEC
                        k1_sel <= KB_L;
                        reg_kl_s <= reg_kl_s(113 to 127) & reg_kl_s(0 to 112); -- >>> 15
                    end if;
                when WT =>
                    -- do nothing
            end case;

            if (PS = KEYa) then
                data_to <= key_in(0 to 127); --kl
            else
                data_to <= data_in;
            end if;

            case PS is
                when KEYc =>
                    prexor_sel <= KL;
                when KEYa | KEYe =>
                    prexor_sel <= KR;
                when SIX1a =>
                    if (enc_dec = ENC) then
                        prexor_sel <= KL;
                    else
                        if (reg_k_len = KLEN_128) then
                            prexor_sel <= KA;
                        else
                            prexor_sel <= KB;
                        end if;
                    end if;
                when others =>
                    prexor_sel <= ZERO;
            end case;

            case PS is
                when SIX3f =>
                    if (reg_k_len = KLEN_128) then
                        if (reg_enc_dec = ENC) then
                            postxor_sel <= KA;
                        else
                            postxor_sel <= KL;
                        end if;
                    else
                        postxor_sel <= ZERO;
                    end if;
                when SIX4f =>
                    if (reg_enc_dec = ENC) then
                        postxor_sel <= KB;
                    else
                        postxor_sel <= KL;
                    end if;
                when others =>
                    postxor_sel <= ZERO;
            end case;

            if (PS = SIX1a or PS = KEYa) then
                newdata <= '1';
            else
                newdata <= '0';
            end if;
            
            if ((PS = SIX3f and reg_k_len = KLEN_128) or PS = SIX4f) then
                output_rdy <= '1';
            else
                output_rdy <= '0';
            end if;

            if (PS = FL1 or PS = FL2 or PS = FL3) then
                sel <= SEL_FL;
            else
                sel <= SEL_F;
            end if;
            
            if (PS = KEYb) then
                key_acq   <=  '1';
            else
                key_acq   <=  '0';
            end if;
            
            if (PS = SIX1b) then
                data_acq   <=  '1';
            else
                data_acq   <=  '0';
            end if;
            
        end if;
    end if;
    
    end process;

    STATE_UPDATE: process (reset, clk)
    begin

        if (reset = '1') then
            PS <= KEYa;
        else
            if (clk'event and clk = '1') then
                PS <= NS;
            end if;
        end if;
    end process;
    
    NEXT_STATE: process (PS, data_rdy, key_rdy)
    begin
               case PS is
                when KEYa =>
                    if(key_rdy = '1') then
                        NS <= KEYb;
                    else
                        NS <= KEYa;
                    end if;
                when KEYb =>
                    NS <= KEYc;
                when KEYc =>
                    NS <= KEYd;
                when KEYd =>
                    if (reg_k_len = KLEN_128) then
                        NS <= SIX1a;
                    else
                        NS <= KEYe;
                    end if;
                when KEYe =>
                    NS <= KEYf;
                when KEYf =>
                    NS <= SIX1a;
                when SIX1a =>
                    if(data_rdy = '1') then
                        NS <= SIX1b;
                    else
                        NS <= SIX1a;
                    end if;
                when SIX1b =>
                    NS <= SIX1c;
                when SIX1c =>
                    NS <= SIX1d;
                when SIX1d =>
                    NS <= SIX1e;
                when SIX1e =>
                    NS <= SIX1f;
                when SIX1f =>
                    NS <= FL1;
                when FL1 =>
                    NS <= SIX2a;
                when SIX2a =>
                    NS <= SIX2b;
                when SIX2b =>
                    NS <= SIX2c;
                when SIX2c =>
                    NS <= SIX2d;
                when SIX2d =>
                    NS <= SIX2e;
                when SIX2e =>
                    NS <= SIX2f;
                when SIX2f =>
                    NS <= FL2;
                when FL2 =>
                    NS <= SIX3a;
                when SIX3a =>
                    NS <= SIX3b;
                when SIX3b =>
                    NS <= SIX3c;
                when SIX3c =>
                    NS <= SIX3d;
                when SIX3d =>
                    NS <= SIX3e;
                when SIX3e =>
                    NS <= SIX3f;
                when SIX3f =>
                    if (reg_k_len = KLEN_128) then
                        if (key_rdy = '1') then
                            NS <= KEYa;
                        else
                            if (data_rdy = '1') then
                                NS <= SIX1a;
                            else
                                NS <= WT;
                            end if;
                        end if;
                    else
                        NS <= FL3;
                    end if;
                when FL3 =>
                    NS <= SIX4a;
                when SIX4a =>
                    NS <= SIX4b;
                when SIX4b =>
                    NS <= SIX4c;
                when SIX4c =>
                    NS <= SIX4d;
                when SIX4d =>
                    NS <= SIX4e;
                when SIX4e =>
                    NS <= SIX4f;
                when SIX4f =>
                    if (key_rdy = '1') then
                        NS <= KEYa;
                    else
                        if (data_rdy = '1') then
                            NS <= SIX1a;
                        else
                            NS <= WT;
                        end if;
                    end if;
                when WT =>
                    if (key_rdy = '1') then
                        NS <= KEYa;
                    else
                        if (data_rdy = '1') then
                            NS <= SIX1a;
                        else
                            NS <= WT;
                        end if;
                    end if;
            end case;
    end process;

end RTL;
