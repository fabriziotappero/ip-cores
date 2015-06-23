-------------------------------------------------------------------------------
--
-- $Id: decoder_pack-p.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.t48_pack.word_t;

package t48_decoder_pack is

  -----------------------------------------------------------------------------
  -- The Mnemonics.
  -----------------------------------------------------------------------------
  type mnemonic_t is (MN_ADD,
                      MN_ADD_A_DATA,
                      MN_ANL,
                      MN_ANL_A_DATA,
                      MN_ANL_EXT,
                      MN_CALL,
                      MN_CLR_A,
                      MN_CLR_C,
                      MN_CLR_F,
                      MN_CPL_A,
                      MN_CPL_C,
                      MN_CPL_F,
                      MN_DA,
                      MN_DEC,
                      MN_DIS_EN_I,
                      MN_DIS_EN_TCNTI,
                      MN_DJNZ,
                      MN_ENT0_CLK,
                      MN_IN,
                      MN_INC,
                      MN_INS,
                      MN_JBB,
                      MN_JC,
                      MN_JF,
                      MN_JMP,
                      MN_JMPP,
                      MN_JNI,
                      MN_JT,
                      MN_JTF,
                      MN_JZ,
                      MN_MOV_A_DATA,
                      MN_MOV_A_PSW,
                      MN_MOV_A_RR,
                      MN_MOV_PSW_A,
                      MN_MOV_RR,
                      MN_MOV_RR_DATA,
                      MN_MOV_T,
                      MN_MOVD_A_PP,
                      MN_MOVP,
                      MN_MOVX,
                      MN_NOP,
                      MN_ORL,
                      MN_ORL_A_DATA,
                      MN_ORL_EXT,
                      MN_OUTD_PP_A,
                      MN_OUTL_EXT,
                      MN_RET,
                      MN_RL,
                      MN_RR,
                      MN_SEL_MB,
                      MN_SEL_RB,
                      MN_STOP_TCNT,
                      MN_STRT,
                      MN_SWAP,
                      MN_XCH,
                      MN_XRL,
                      MN_XRL_A_DATA);

  type mnemonic_rec_t is
    record
      mnemonic    : mnemonic_t;
      multi_cycle : boolean;
    end record;

  function decode_opcode_f(opcode : in word_t) return
    mnemonic_rec_t;

end t48_decoder_pack;


package body t48_decoder_pack is

  function decode_opcode_f(opcode : in word_t) return
    mnemonic_rec_t is
    variable mnemonic_v    : mnemonic_t;
    variable multi_cycle_v : boolean;
    variable result_v      : mnemonic_rec_t;
  begin
    -- default assignment
    mnemonic_v    := MN_NOP;
    multi_cycle_v := false;

    case opcode is
      -- Mnemonic ADD ---------------------------------------------------------
      when "01101000" | "01101001" | "01101010" | "01101011" |  -- ADD A, Rr
           "01101100" | "01101101" | "01101110" | "01101111" |  --
           "01100000" | "01100001" |                            -- ADD A, @ Rr
           "01111000" | "01111001" | "01111010" | "01111011" |  -- ADDC A, Rr
           "01111100" | "01111101" | "01111110" | "01111111" |  --
           "01110000" | "01110001" =>                           -- ADDC A, @ Rr
        mnemonic_v    := MN_ADD;

      -- Mnemonic ADD_A_DATA --------------------------------------------------
      when "00000011" |                                         -- ADD A, data
           "00010011" =>                                        -- ADDC A, data
        mnemonic_v    := MN_ADD_A_DATA;
        multi_cycle_v := true;

      -- Mnemonic ANL ---------------------------------------------------------
      when "01011000" | "01011001" | "01011010" | "01011011" |  -- ANL A, Rr
           "01011100" | "01011101" | "01011110" | "01011111" |  --
           "01010000" | "01010001" =>                           -- ANL A, @ Rr
        mnemonic_v    := MN_ANL;

      -- Mnemonic ANL_A_DATA --------------------------------------------------
      when "01010011" =>                                        -- ANL A, data
        mnemonic_v    := MN_ANL_A_DATA;
        multi_cycle_v := true;

      -- Mnemonic ANL_EXT -----------------------------------------------------
      when "10011000" |                                         -- ANL BUS, data
           "10011001" | "10011010" =>                           -- ANL PP, data
        mnemonic_v    := MN_ANL_EXT;
        multi_cycle_v := true;

      -- Mnemonic CALL --------------------------------------------------------
      when "00010100" | "00110100" | "01010100" | "01110100" |  -- CALL addr
           "10010100" | "10110100" | "11010100" | "11110100" => --
        mnemonic_v    := MN_CALL;
        multi_cycle_v := true;

      -- Mnemonic CLR_A -------------------------------------------------------
      when "00100111" =>                                        -- CLR A
        mnemonic_v    := MN_CLR_A;

      -- Mnemonic CLR_C -------------------------------------------------------
      when "10010111" =>                                        -- CLR C
        mnemonic_v    := MN_CLR_C;

      -- Mnemonic CLR_F -------------------------------------------------------
      when "10000101" |                                         -- CLR F0
           "10100101" =>
        mnemonic_v    := MN_CLR_F;

      -- Mnemonic CPL_A -------------------------------------------------------
      when "00110111" =>                                        -- CPL A
        mnemonic_v    := MN_CPL_A;

      -- Mnemonic CPL_C -------------------------------------------------------
      when "10100111" =>                                        -- CPL C
        mnemonic_v    := MN_CPL_C;

      -- Mnemonic CPL_F -------------------------------------------------------
      when "10010101" |                                         -- CPL F0
           "10110101" =>                                        -- CPL F1
        mnemonic_v    := MN_CPL_F;

      -- Mnemonic DA ----------------------------------------------------------
      when "01010111" =>                                        -- DA D
        mnemonic_v    := MN_DA;

      -- Mnemonic DEC ---------------------------------------------------------
      when "11001000" | "11001001" | "11001010" | "11001011" |  -- DEC Rr
           "11001100" | "11001101" | "11001110" | "11001111" |  --
           "00000111" =>                                        -- DEC A
        mnemonic_v    := MN_DEC;

      -- Mnemonic DIS_EN_I ----------------------------------------------------
      when "00010101" |                                         -- DIS I
           "00000101" =>                                        -- EN I
        mnemonic_v    := MN_DIS_EN_I;

      -- Mnemonic DIS_EN_TCNTI ------------------------------------------------
      when "00110101" |                                         -- DIS TCNTI
           "00100101" =>                                        -- EN TCNTI
        mnemonic_v    := MN_DIS_EN_TCNTI;

      -- Mnemonic DJNZ --------------------------------------------------------
      when "11101000" | "11101001" | "11101010" | "11101011" |  -- DJNZ Rr, addr
           "11101100" | "11101101" | "11101110" | "11101111" => --
        mnemonic_v    := MN_DJNZ;
        multi_cycle_v := true;

      -- Mnemonic ENT0_CLK ----------------------------------------------------
      when "01110101" =>                                        -- ENT0 CLK
        mnemonic_v    := MN_ENT0_CLK;

      -- Mnemonic IN ----------------------------------------------------------
      when "00001001" | "00001010" =>                           -- IN A, Pp
        mnemonic_v    := MN_IN;
        multi_cycle_v := true;

      -- Mnemonic INC ---------------------------------------------------------
      when "00010111" |                                         -- INC A
           "00011000" | "00011001" | "00011010" | "00011011" |  -- INC Rr
           "00011100" | "00011101" | "00011110" | "00011111" |  --
           "00010000" | "00010001" =>                           -- INC @ Rr
        mnemonic_v    := MN_INC;

      -- Mnemonic INS ---------------------------------------------------------
      when "00001000" =>                                        -- INS A, BUS
        mnemonic_v    := MN_INS;
        multi_cycle_v := true;

      -- Mnemonic JBB ---------------------------------------------------------
      when "00010010" | "00110010" | "01010010" | "01110010" |  -- JBb addr
           "10010010" | "10110010" | "11010010" | "11110010" => --
        mnemonic_v    := MN_JBB;
        multi_cycle_v := true;

      -- Mnemonic JC ----------------------------------------------------------
      when "11110110" |                                         -- JC addr
           "11100110" =>                                        -- JNC addr
        mnemonic_v    := MN_JC;
        multi_cycle_v := true;

      -- Mnemonic JF ----------------------------------------------------------
      when "10110110" |                                         -- JF0 addr
           "01110110" =>                                        -- JF1 addr
        mnemonic_v    := MN_JF;
        multi_cycle_v := true;

      -- Mnemonic JMP ---------------------------------------------------------
      when "00000100" | "00100100" | "01000100" | "01100100" |  -- JMP addr
           "10000100" | "10100100" | "11000100" | "11100100" => --
        mnemonic_v    := MN_JMP;
        multi_cycle_v := true;

      -- Mnemonic JMPP --------------------------------------------------------
      when "10110011" =>                                        -- JMPP @ A
        mnemonic_v    := MN_JMPP;
        multi_cycle_v := true;

      -- Mnemonic JNI ---------------------------------------------------------
      when "10000110" =>                                        -- JNI addr
        mnemonic_v    := MN_JNI;
        multi_cycle_v := true;

      -- Mnemonic JT ----------------------------------------------------------
      when "00100110" |                                         -- JNT0 addr
           "01000110" |                                         -- JNT1 addr
           "00110110" |                                         -- JT0 addr
           "01010110" =>                                        -- JT1 addr
        mnemonic_v    := MN_JT;
        multi_cycle_v := true;

      -- Mnemonic JTF ---------------------------------------------------------
      when "00010110" =>                                        -- JTF addr
        mnemonic_v    := MN_JTF;
        multi_cycle_v := true;

      -- Mnemonic JZ ----------------------------------------------------------
      when "10010110" |                                         -- JNZ addr
           "11000110" =>                                        -- JZ addr
        mnemonic_v    := MN_JZ;
        multi_cycle_v := true;

      -- Mnemonic MOV_A_DATA --------------------------------------------------
      when "00100011" =>                                        -- MOV A, data
        mnemonic_v    := MN_MOV_A_DATA;
        multi_cycle_v := true;

      -- Mnemonic MOV_A_PSW ---------------------------------------------------
      when "11000111" =>                                        -- MOV A, PSW
        mnemonic_v    := MN_MOV_A_PSW;

      -- Mnemonic MOV_A_RR ----------------------------------------------------
      when "11111000" | "11111001" | "11111010" | "11111011" |  -- MOV A, Rr
           "11111100" | "11111101" | "11111110" | "11111111" |  --
           "11110000" | "11110001" =>                           -- MOV A, @ Rr
        mnemonic_v    := MN_MOV_A_RR;

      -- Mnemonic MOV_PSW_A ---------------------------------------------------
      when "11010111" =>                                        -- MOV PSW, A
        mnemonic_v    := MN_MOV_PSW_A;

      -- Mnemonic MOV_RR ------------------------------------------------------
      when "10101000" | "10101001" | "10101010" | "10101011" |  -- MOV Rr, A
           "10101100" | "10101101" | "10101110" | "10101111" |  --
           "10100000" | "10100001" =>                           -- MOV @ Rr, A
        mnemonic_v    := MN_MOV_RR;

      -- Mnemonic MOV_RR_DATA -------------------------------------------------
      when "10111000" | "10111001" | "10111010" | "10111011" |  -- MOV Rr, data
           "10111100" | "10111101" | "10111110" | "10111111" |  --
           "10110000" | "10110001" =>                           -- MOV @ Rr, data
        mnemonic_v    := MN_MOV_RR_DATA;
        multi_cycle_v := true;

      -- Mnemonic MOV_T -------------------------------------------------------
      when "01100010" |                                         -- MOV T, A
           "01000010" =>                                        -- MOV A, T
        mnemonic_v    := MN_MOV_T;

      -- Mnemonic MOVD_A_PP ---------------------------------------------------
      when "00001100" | "00001101" | "00001110" | "00001111" => -- MOVD A, Pp
        mnemonic_v    := MN_MOVD_A_PP;
        multi_cycle_v := true;

      -- Mnemonic MOVP --------------------------------------------------------
      when "10100011" |                                         -- MOVP A, @ A
           "11100011" =>                                        -- MOVP3 A, @ A
        mnemonic_v    := MN_MOVP;
        multi_cycle_v := true;

      -- Mnemonic MOVX --------------------------------------------------------
      when "10000000" | "10000001" |                            -- MOVX A, @ Rr
           "10010000" | "10010001" =>                           -- MOVX @ Rr, A
        mnemonic_v    := MN_MOVX;
        multi_cycle_v := true;

      -- Mnemonic NOP ---------------------------------------------------------
      when "00000000" =>                                        -- NOP
        mnemonic_v    := MN_NOP;

      -- Mnemonic ORL ---------------------------------------------------------
      when "01001000" | "01001001" | "01001010" | "01001011" |  -- ORL A, Rr
           "01001100" | "01001101" | "01001110" | "01001111" |  --
           "01000000" | "01000001" =>                           -- ORL A, @ Rr
        mnemonic_v    := MN_ORL;

      -- Mnemonic ORL_A_DATA --------------------------------------------------
      when "01000011" =>                                        -- ORL A, data
        mnemonic_v    := MN_ORL_A_DATA;
        multi_cycle_v := true;

      -- Mnemonic ORL_EXT -----------------------------------------------------
      when "10001000" |                                         -- ORL BUS, data
           "10001001" | "10001010" =>                           -- ORL Pp, data
        mnemonic_v    := MN_ORL_EXT;
        multi_cycle_v := true;

      -- Mnemonic OUTD_PP_A ---------------------------------------------------
      when "00111100" | "00111101" | "00111110" | "00111111" |  -- MOVD Pp, A
           "10011100" | "10011101" | "10011110" | "10011111" |  -- ANLD PP, A
           "10001100" | "10001101" | "10001110" | "10001111" => -- ORLD Pp, A
        mnemonic_v    := MN_OUTD_PP_A;
        multi_cycle_v := true;

      -- Mnemonic OUTL_EXT ----------------------------------------------------
      when "00111001" | "00111010" |                            -- OUTL Pp, A
           "00000010" =>                                        -- OUTL BUS, A
        mnemonic_v    := MN_OUTL_EXT;
        multi_cycle_v := true;

      -- Mnemonic RET ---------------------------------------------------------
      when "10000011" |                                         -- RET
           "10010011" =>                                        -- RETR
        mnemonic_v    := MN_RET;
        multi_cycle_v := true;

      -- Mnemonic RL ----------------------------------------------------------
      when "11100111" |                                         -- RL A
           "11110111" =>                                        -- RLC A
        mnemonic_v    := MN_RL;

      -- Mnemonic RR ----------------------------------------------------------
      when "01110111" |                                         -- RR A
           "01100111" =>                                        -- RRC A
        mnemonic_v    := MN_RR;

      -- Mnemonic SEL_MB ------------------------------------------------------
      when "11100101" |                                         -- SEL MB0
           "11110101" =>                                        -- SEL MB1
        mnemonic_v    := MN_SEL_MB;

      -- Mnemonic SEL_RB ------------------------------------------------------
      when "11000101" |                                         -- SEL RB0
           "11010101" =>                                        -- SEL RB1
        mnemonic_v    := MN_SEL_RB;

      -- Mnemonic STOP_TCNT ---------------------------------------------------
      when "01100101" =>                                        -- STOP TCNT
        mnemonic_v    := MN_STOP_TCNT;

      -- Mnemonic START -------------------------------------------------------
      when "01000101" |                                         -- STRT CNT
           "01010101" =>                                        -- STRT T
        mnemonic_v    := MN_STRT;

      -- Mnemonic SWAP --------------------------------------------------------
      when "01000111" =>                                        -- SWAP A
        mnemonic_v    := MN_SWAP;

      -- Mnemonic XCH ---------------------------------------------------------
      when "00101000" | "00101001" | "00101010" | "00101011" |  -- XCH A, Rr
           "00101100" | "00101101" | "00101110" | "00101111" |  --
           "00100000" | "00100001" |                            -- XCH A, @ Rr
           "00110000" | "00110001" =>                           -- XCHD A, @ Rr
        mnemonic_v    := MN_XCH;

      -- Mnemonic XRL ---------------------------------------------------------
      when "11011000" | "11011001" | "11011010" | "11011011" |  -- XRL A, Rr
           "11011100" | "11011101" | "11011110" | "11011111" |  --
           "11010000" | "11010001" =>                           -- XRL A, @ Rr
        mnemonic_v    := MN_XRL;

      -- Mnemonic XRL_A_DATA --------------------------------------------------
      when "11010011" =>                                        -- XRL A, data
        mnemonic_v    := MN_XRL_A_DATA;
        multi_cycle_v := true;

      when others =>
        -- pragma translate_off
        assert now = 0 ns
          report "Unknown opcode."
          severity warning;
        -- pragma translate_on

    end case;

    result_v.mnemonic    := mnemonic_v;
    result_v.multi_cycle := multi_cycle_v;

    return result_v;
  end;

end t48_decoder_pack;
