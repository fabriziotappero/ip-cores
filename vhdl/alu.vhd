--  This file is part of the marca processor.
--  Copyright (C) 2007 Wolfgang Puffitsch

--  This program is free software; you can redistribute it and/or modify it
--  under the terms of the GNU Library General Public License as published
--  by the Free Software Foundation; either version 2, or (at your option)
--  any later version.

--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  Library General Public License for more details.

--  You should have received a copy of the GNU Library General Public
--  License along with this program; if not, write to the Free Software
--  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

-------------------------------------------------------------------------------
-- MARCA ALU
-------------------------------------------------------------------------------
-- architecture for the ALU
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.marca_pkg.all;

architecture behaviour of alu is

  type WAIT_STATE is (WAIT_NONE, WAIT_MULT, WAIT_DIV, WAIT_UDIV, WAIT_MOD, WAIT_UMOD);
  signal state      : WAIT_STATE;
  signal next_state : WAIT_STATE;

  signal flags      : std_logic_vector(REG_WIDTH-1 downto 0);
  signal next_flags : std_logic_vector(REG_WIDTH-1 downto 0);

  signal shflags      : std_logic_vector(REG_WIDTH-1 downto 0);
  signal next_shflags : std_logic_vector(REG_WIDTH-1 downto 0);

  signal old_sgna, old_sgnb : std_logic;
  signal sgna, sgnb         : std_logic;

  component multiplier is
                         generic (
                           width : integer := REG_WIDTH);
                       port (
                         clock    : in std_logic;
                         reset    : in std_logic;
                         trigger  : in std_logic;
                         operand1 : in std_logic_vector(width-1 downto 0);
                         operand2 : in std_logic_vector(width-1 downto 0);
                         busy     : out std_logic;
                         product  : out std_logic_vector(width downto 0));
  end component;

  signal mult_op1     : std_logic_vector(REG_WIDTH-1 downto 0);
  signal mult_op2     : std_logic_vector(REG_WIDTH-1 downto 0);
  signal mult_trigger : std_logic;
  signal mult_busy    : std_logic;
  signal mult_result  : std_logic_vector(REG_WIDTH downto 0);


  component divider is
                      generic (
                        width : integer := REG_WIDTH);
                    port (
                      clock    : in std_logic;
                      reset    : in std_logic;
                      trigger  : in std_logic;
                      denom    : in std_logic_vector(width-1 downto 0);
                      numer    : in std_logic_vector(width-1 downto 0);
                      exc      : out std_logic;
                      busy     : out std_logic;
                      quotient : out std_logic_vector(width-1 downto 0);
                      remain   : out std_logic_vector(width-1 downto 0));
  end component;

  signal udiv_op1     : std_logic_vector(REG_WIDTH-1 downto 0);
  signal udiv_op2     : std_logic_vector(REG_WIDTH-1 downto 0);
  signal udiv_trigger : std_logic;
  signal udiv_exc     : std_logic;
  signal udiv_busy    : std_logic;
  signal udiv_result  : std_logic_vector(REG_WIDTH-1 downto 0);
  signal umod_result  : std_logic_vector(REG_WIDTH-1 downto 0);


  signal adder_op1    : std_logic_vector(REG_WIDTH downto 0);
  signal adder_op2    : std_logic_vector(REG_WIDTH downto 0);
  signal adder_op3    : std_logic;
  signal adder_result : std_logic_vector(REG_WIDTH downto 0);


  function shift_left (a : std_logic_vector;
                       b : std_logic_vector)
    return std_logic_vector is
    variable result : std_logic_vector(a'length-1 downto 0);
    variable i : integer;
  begin
    for i in 0 to a'length-1 loop
      if i < to_integer(unsigned(b)) then
        result(i) := '0';
      else
        result(i) := a(i - to_integer(unsigned(b)));
      end if;
    end loop;  
    return result;
  end;

  function shift_right (a : std_logic_vector;
                        b : std_logic_vector)
    return std_logic_vector is
    variable result : std_logic_vector(a'length-1 downto 0);
    variable i : integer;
  begin
    for i in 0 to a'length-1 loop
      if i < to_integer(unsigned(b)) then
        result(i) := a(i + to_integer(unsigned(b)));
      elsif i < a'length-1 then       
        result(i) := '0';
      else
        result(i) := a(to_integer(unsigned(b)) - 1);
      end if;
    end loop;
    return result;
  end;

  function shift_aright (a : std_logic_vector;
                         b : std_logic_vector)
    return std_logic_vector is
    variable result : std_logic_vector(a'length-1 downto 0);
    variable i : integer;
  begin
    for i in 0 to a'length-1 loop
      if i < to_integer(unsigned(b)) then
        result(i) := a(i + to_integer(unsigned(b)));
      elsif i < a'length-1 then       
        result(i) := a(a'length-1);
      else
        result(i) := a(to_integer(unsigned(b)) - 1);
      end if;
    end loop;
    return result;
  end;

  function rotate_left (a : std_logic_vector;
                        b : std_logic_vector;
                        c : std_logic)
    return std_logic_vector is
    variable result : std_logic_vector(a'length-1 downto 0);
    variable i : integer;
  begin
    for i in 0 to a'length-1 loop
      if i < to_integer(unsigned(b)) - 1 then
        result(i) := a(a'length - to_integer(unsigned(b)) + i);
      elsif i = to_integer(unsigned(b)) - 1 then
        result(i) := c;
      else
        result(i) := a(i - to_integer(unsigned(b)));
      end if;
    end loop;  
    return result;
  end;

  function rotate_right(a : std_logic_vector;
                        b : std_logic_vector;
                        c : std_logic)
    return std_logic_vector is
    variable result : std_logic_vector(a'length-1 downto 0);
    variable i : integer;
  begin
    for i in 0 to a'length-1 loop
      if i < a'length - to_integer(unsigned(b)) then
        result(i) := a(to_integer(unsigned(b)) + i);
      elsif i = a'length - to_integer(unsigned(b)) - 1 then
        result(i) := c;
      else
        result(i) := a(i - a'length - to_integer(unsigned(b)));
      end if;    
    end loop;
    return result;
  end;

  function to_unsigned(a : std_logic)
    return unsigned is
    variable result : unsigned(0 downto 0);
  begin  -- to_unsigned
    if a = '1' then
      result := "1";
    else
      result := "0";
    end if;
    return result;
  end to_unsigned;

  function parity(a : std_logic_vector)
    return std_logic is
    variable result : std_logic;
    variable i : integer;
  begin
    result := '1';
    for i in a'low to a'high loop
      result := result xor a(i);
    end loop;
    return result;
  end;

begin  -- behaviour

  -- hardwire the interrupt enable flag
  iena <= flags(FLAG_I);
  -- and the exception signal to the divider
  exc <= udiv_exc;
  
  mult_unit : multiplier
    port map (
      clock    => clock,
      reset    => reset,
      trigger  => mult_trigger,
      operand1 => mult_op1,
      operand2 => mult_op2,
      busy     => mult_busy,
      product  => mult_result);

  udiv_unit : divider
    port map (
      clock    => clock,
      reset    => reset,
      trigger  => udiv_trigger,
      numer    => udiv_op1,
      denom    => udiv_op2,
      exc      => udiv_exc,
      busy     => udiv_busy,
      quotient => udiv_result,
      remain   => umod_result);
  
  syn_proc: process (clock, reset)
  begin  -- process syn_proc
    if reset = RESET_ACTIVE then                 -- asynchronous reset (active low)
      flags <= (others => '0');
      shflags <= (others => '0');
      state <= WAIT_NONE;
      old_sgna <= '0';
      old_sgnb <= '0';
    elsif clock'event and clock = '1' then  -- rising clock edge
      flags <= next_flags;
      shflags <= next_shflags;
      state <= next_state;
      old_sgna <= sgna;
      old_sgnb <= sgnb;
    end if;
  end process syn_proc;

  business: process(next_state)
  begin  -- process business
    if next_state /= WAIT_NONE then
      busy <= '1';
    else
      busy <= '0';
    end if;
  end process business;

  adder: process (adder_op1, adder_op2, adder_op3)
  begin  -- process adder
    adder_result <= std_logic_vector(unsigned(adder_op1) + unsigned(adder_op2)
                                     + to_unsigned(adder_op3));
  end process adder;
  
  compute: process (state, op, a, b, i, pc, flags, shflags,
                    intr,
                    sgna, sgnb, old_sgna, old_sgnb,
                    mult_busy, mult_result,
                    udiv_busy, udiv_result, umod_result,
                    adder_result)

    variable wr_flags : std_logic;
    variable tmp : std_logic_vector(REG_WIDTH downto 0);
    
  begin
    wr_flags := '1';
    tmp := (others => '0');

    next_flags <= flags;
    next_shflags <= shflags;
    next_state <= state;

    sgna <= a(REG_WIDTH-1);
    sgnb <= b(REG_WIDTH-1);

    mult_op1 <= (others => '0');
    mult_op2 <= (others => '0');
    mult_trigger <= '0';

    udiv_op1 <= (others => '0');
    udiv_op2 <= (others => '0');
    udiv_trigger <= '0';

    adder_op1 <= (others => '0');
    adder_op2 <= (others => '0');
    adder_op3 <= '0';
    
    pcchg <= '0';

    case state is
      when WAIT_MULT =>
        sgna <= old_sgna;
        sgnb <= old_sgnb;
        tmp := mult_result;
        if mult_busy = '0' then
          next_state <= WAIT_NONE;
        end if;
      when WAIT_DIV =>
        sgna <= old_sgna;
        sgnb <= old_sgnb;
        if sgna = sgnb then
          tmp(REG_WIDTH-1 downto 0) := udiv_result;
        else
          tmp(REG_WIDTH-1 downto 0) := std_logic_vector(-signed(udiv_result));
        end if;
        if udiv_busy = '0' then
          next_state <= WAIT_NONE;
        end if;
      when WAIT_UDIV =>
        sgna <= old_sgna;
        sgnb <= old_sgnb;
        tmp(REG_WIDTH-1 downto 0) := udiv_result;
        if udiv_busy = '0' then
          next_state <= WAIT_NONE;
        end if;
      when WAIT_MOD =>
        sgna <= old_sgna;
        sgnb <= old_sgnb;
        if sgna = sgnb then
          tmp(REG_WIDTH-1 downto 0) := umod_result;
        else
          tmp(REG_WIDTH-1 downto 0) := std_logic_vector(-signed(umod_result));
        end if;
        if udiv_busy = '0' then
          next_state <= WAIT_NONE;
        end if;
      when WAIT_UMOD =>
        sgna <= old_sgna;
        sgnb <= old_sgnb;
        tmp(REG_WIDTH-1 downto 0) := umod_result;
        if udiv_busy = '0' then
          next_state <= WAIT_NONE;
        end if;
      when WAIT_NONE =>
        case op is
          when ALU_ADD  => adder_op1 <= std_logic_vector(resize(unsigned(a), REG_WIDTH+1));
                           adder_op2 <= std_logic_vector(resize(unsigned(b), REG_WIDTH+1));
                           tmp := adder_result;
          when ALU_SUB  => adder_op1 <= std_logic_vector(resize(unsigned(a), REG_WIDTH+1));
                           adder_op2 <= not std_logic_vector(resize(unsigned(b), REG_WIDTH+1));
                           adder_op3 <= '1';
                           tmp := adder_result;
          when ALU_ADDC => adder_op1 <= std_logic_vector(resize(unsigned(a), REG_WIDTH+1));
                           adder_op2 <= std_logic_vector(resize(unsigned(b), REG_WIDTH+1));
                           adder_op3 <= flags(FLAG_C);
                           tmp := adder_result;
          when ALU_SUBC => adder_op1 <= std_logic_vector(resize(unsigned(a), REG_WIDTH+1));
                           adder_op2 <= not std_logic_vector(resize(unsigned(b), REG_WIDTH+1));
                           adder_op3 <= not flags(FLAG_C);
                           tmp := adder_result;
          when ALU_AND  => tmp(REG_WIDTH-1 downto 0) := a and b;
          when ALU_OR   => tmp(REG_WIDTH-1 downto 0) := a or b;
          when ALU_XOR  => tmp(REG_WIDTH-1 downto 0) := a xor b;
-------------------------------------------------------------------------------                       
          when ALU_MUL  => mult_trigger <= '1';
                           mult_op1 <= a;
                           mult_op2 <= b;
                           next_state <= WAIT_MULT;
          when ALU_DIV  => udiv_trigger <= '1';
                           udiv_op1 <= std_logic_vector(abs(signed(a)));
                           udiv_op2 <= std_logic_vector(abs(signed(b)));
                           next_state <= WAIT_DIV;
          when ALU_UDIV => udiv_trigger <= '1';
                           udiv_op1 <= a;
                           udiv_op2 <= b;
                           next_state <= WAIT_UDIV;
          when ALU_MOD  => udiv_trigger <= '1';
                           udiv_op1 <= std_logic_vector(abs(signed(a)));
                           udiv_op2 <= std_logic_vector(abs(signed(b)));
                           next_state <= WAIT_MOD;
          when ALU_UMOD => udiv_trigger <= '1';
                           udiv_op1 <= a;
                           udiv_op2 <= b;
                           next_state <= WAIT_UMOD;
-------------------------------------------------------------------------------                       
          when ALU_LDIL => tmp(REG_WIDTH-1 downto 0) := a(REG_WIDTH-1 downto REG_WIDTH/2) & i(REG_WIDTH/2-1 downto 0);
          when ALU_LDIH => tmp(REG_WIDTH-1 downto 0) := i(REG_WIDTH/2-1 downto 0) & a(REG_WIDTH/2-1 downto 0);
          when ALU_LDIB => tmp(REG_WIDTH-1 downto 0) := i;
-------------------------------------------------------------------------------                       
          when ALU_MOV  => tmp(REG_WIDTH-1 downto 0) := b;
          when ALU_NOT  => tmp(REG_WIDTH-1 downto 0) := not b;
          when ALU_NEG  => adder_op1 <= (others => '0');
                           adder_op2 <= not std_logic_vector(resize(unsigned(b), REG_WIDTH+1));
                           adder_op3 <= '1';
                           tmp := adder_result;
          when ALU_ADDI => adder_op1 <= std_logic_vector(resize(unsigned(a), REG_WIDTH+1));
                           adder_op2 <= std_logic_vector(resize(unsigned(i), REG_WIDTH+1));
                           tmp := adder_result;
                           sgnb <= i(REG_WIDTH-1);
          when ALU_CMPI => adder_op1 <= std_logic_vector(resize(unsigned(a), REG_WIDTH+1));
                           adder_op2 <= not std_logic_vector(resize(unsigned(i), REG_WIDTH+1));
                           adder_op3 <= '1';
                           tmp := adder_result;
                           sgnb <= i(REG_WIDTH-1);
          when ALU_SHL  => tmp := shift_left   (std_logic_vector(resize(unsigned(a), REG_WIDTH+1)), b);
          when ALU_SHR  => tmp := shift_right  (std_logic_vector(resize(unsigned(a), REG_WIDTH+1)), b);
          when ALU_SAR  => tmp := shift_aright (std_logic_vector(resize(  signed(a), REG_WIDTH+1)), b);
          when ALU_ROLC => tmp := rotate_left  (std_logic_vector(resize(unsigned(a), REG_WIDTH+1)), b(REG_WIDTH_LOG-1 downto 0), flags(FLAG_C));
          when ALU_RORC => tmp := rotate_right (std_logic_vector(resize(unsigned(a), REG_WIDTH+1)), b(REG_WIDTH_LOG-1 downto 0), flags(FLAG_C));
          when ALU_BSET => tmp(REG_WIDTH-1 downto 0) := a; tmp(to_integer(unsigned(i))) := '1';
          when ALU_BCLR => tmp(REG_WIDTH-1 downto 0) := a; tmp(to_integer(unsigned(i))) := '0';
          when ALU_BTEST => tmp := (others => '0'); tmp(0) := a(to_integer(unsigned(i)));
          when ALU_SEXT => tmp(REG_WIDTH-1 downto 0) := std_logic_vector(resize(signed(a(REG_WIDTH/2-1 downto 0)), REG_WIDTH));
-------------------------------------------------------------------------------
          when ALU_BRZ  => adder_op1 <= std_logic_vector(resize(unsigned(pc), REG_WIDTH+1));
                           if flags(FLAG_Z) = '1' then
                             adder_op2 <= std_logic_vector(resize(unsigned(i), REG_WIDTH+1));
                             pcchg <= '1';
                           end if;
                           tmp := adder_result;
                           wr_flags := '0';
          when ALU_BRNZ => adder_op1 <= std_logic_vector(resize(unsigned(pc), REG_WIDTH+1));
                           if flags(FLAG_Z) = '0' then
                             adder_op2 <= std_logic_vector(resize(unsigned(i), REG_WIDTH+1));
                             pcchg <= '1';
                           end if;
                           tmp := adder_result;
                           wr_flags := '0';
          when ALU_BRLE => adder_op1 <= std_logic_vector(resize(unsigned(pc), REG_WIDTH+1));
                           if flags(FLAG_Z) = '1' or flags(FLAG_N) /= flags(FLAG_V) then
                             adder_op2 <= std_logic_vector(resize(unsigned(i), REG_WIDTH+1));
                             pcchg <= '1';
                           end if;
                           tmp := adder_result;
                           wr_flags := '0';
          when ALU_BRLT => adder_op1 <= std_logic_vector(resize(unsigned(pc), REG_WIDTH+1));
                           if flags(FLAG_Z) = '0' and flags(FLAG_N) /= flags(FLAG_V) then
                             adder_op2 <= std_logic_vector(resize(unsigned(i), REG_WIDTH+1));
                             pcchg <= '1';
                           end if;
                           tmp := adder_result;
                           wr_flags := '0';
          when ALU_BRGE => adder_op1 <= std_logic_vector(resize(unsigned(pc), REG_WIDTH+1));
                           if flags(FLAG_Z) = '1' or flags(FLAG_N) = flags(FLAG_V) then
                             adder_op2 <= std_logic_vector(resize(unsigned(i), REG_WIDTH+1));
                             pcchg <= '1';
                           end if;
                           tmp := adder_result;
                           wr_flags := '0';
          when ALU_BRGT => adder_op1 <= std_logic_vector(resize(unsigned(pc), REG_WIDTH+1));
                           if flags(FLAG_Z) = '0' and flags(FLAG_N) = flags(FLAG_V) then
                             adder_op2 <= std_logic_vector(resize(unsigned(i), REG_WIDTH+1));
                             pcchg <= '1';
                           end if;
                           tmp := adder_result;
                           wr_flags := '0';
          when ALU_BRULE => adder_op1 <= std_logic_vector(resize(unsigned(pc), REG_WIDTH+1));
                            if flags(FLAG_Z) = '1' or flags(FLAG_C) = '1' then
                              adder_op2 <= std_logic_vector(resize(unsigned(i), REG_WIDTH+1));
                              pcchg <= '1';
                            end if;
                            tmp := adder_result;
                            wr_flags := '0';
          when ALU_BRULT => adder_op1 <= std_logic_vector(resize(unsigned(pc), REG_WIDTH+1));
                            if flags(FLAG_Z) = '0' and flags(FLAG_C) = '1' then
                              adder_op2 <= std_logic_vector(resize(unsigned(i), REG_WIDTH+1));
                              pcchg <= '1';
                            end if;
                            tmp := adder_result;
                            wr_flags := '0';
          when ALU_BRUGE => adder_op1 <= std_logic_vector(resize(unsigned(pc), REG_WIDTH+1));
                            if flags(FLAG_Z) = '1' or flags(FLAG_C) = '0' then
                              adder_op2 <= std_logic_vector(resize(unsigned(i), REG_WIDTH+1));
                              pcchg <= '1';
                            end if;
                            tmp := adder_result;
                            wr_flags := '0';
          when ALU_BRUGT => adder_op1 <= std_logic_vector(resize(unsigned(pc), REG_WIDTH+1));
                            if flags(FLAG_Z) = '0' and flags(FLAG_C) = '0' then                              
                              adder_op2 <= std_logic_vector(resize(unsigned(i), REG_WIDTH+1));
                              pcchg <= '1';
                            end if;
                            tmp := adder_result;
                            wr_flags := '0';
-------------------------------------------------------------------------------
          when ALU_JMP   => tmp(REG_WIDTH-1 downto 0) := a;
                            pcchg <= '1';
                            wr_flags := '0';
          when ALU_JMPZ  => if flags(FLAG_Z) = '1' then
                              tmp(REG_WIDTH-1 downto 0) := a;
                              pcchg <= '1';
                            else
                              tmp(REG_WIDTH-1 downto 0) := pc;
                            end if;
                            wr_flags := '0';
          when ALU_JMPNZ => if flags(FLAG_Z) = '0' then
                              tmp(REG_WIDTH-1 downto 0) := a;
                              pcchg <= '1';
                            else
                              tmp(REG_WIDTH-1 downto 0) := pc;
                            end if;
                            wr_flags := '0';
          when ALU_JMPLE => if flags(FLAG_Z) = '1' or flags(FLAG_N) /= flags(FLAG_V) then
                              tmp(REG_WIDTH-1 downto 0) := a; 
                              pcchg <= '1';
                            else
                              tmp(REG_WIDTH-1 downto 0) := pc; 
                            end if;
                            wr_flags := '0';
          when ALU_JMPLT => if flags(FLAG_Z) = '0' and flags(FLAG_N) /= flags(FLAG_V) then
                              tmp(REG_WIDTH-1 downto 0) := a;
                              pcchg <= '1';
                            else
                              tmp(REG_WIDTH-1 downto 0) := pc; 
                            end if;
                            wr_flags := '0';
          when ALU_JMPGE => if flags(FLAG_Z) = '1' or flags(FLAG_N) = flags(FLAG_V) then
                              tmp(REG_WIDTH-1 downto 0) := a; 
                              pcchg <= '1';
                            else
                              tmp(REG_WIDTH-1 downto 0) := pc; 
                            end if;
                            wr_flags := '0';
          when ALU_JMPGT => if flags(FLAG_Z) = '0' and flags(FLAG_N) = flags(FLAG_V) then
                              tmp(REG_WIDTH-1 downto 0) := a; 
                              pcchg <= '1';
                            else
                              tmp(REG_WIDTH-1 downto 0) := pc; 
                            end if;
                            wr_flags := '0';
          when ALU_JMPULE => if flags(FLAG_Z) = '1' or flags(FLAG_C) = '1' then
                               tmp(REG_WIDTH-1 downto 0) := a; 
                               pcchg <= '1';
                             else
                               tmp(REG_WIDTH-1 downto 0) := pc; 
                             end if;
                             wr_flags := '0';
          when ALU_JMPULT => if flags(FLAG_Z) = '0' and flags(FLAG_C) = '1' then
                               tmp(REG_WIDTH-1 downto 0) := a; 
                               pcchg <= '1';
                             else
                               tmp(REG_WIDTH-1 downto 0) := pc; 
                             end if;
                             wr_flags := '0';
          when ALU_JMPUGE => if flags(FLAG_Z) = '1' or flags(FLAG_C) = '0' then
                               tmp(REG_WIDTH-1 downto 0) := a; 
                               pcchg <= '1';
                             else
                               tmp(REG_WIDTH-1 downto 0) := pc; 
                             end if;
                             wr_flags := '0';
          when ALU_JMPUGT => if flags(FLAG_Z) = '0' and flags(FLAG_C) = '0' then
                               tmp(REG_WIDTH-1 downto 0) := a; 
                               pcchg <= '1';
                             else
                               tmp(REG_WIDTH-1 downto 0) := pc; 
                             end if;
                             wr_flags := '0';
-------------------------------------------------------------------------------
          when ALU_GETFL => tmp(REG_WIDTH-1 downto 0) := flags;
                            wr_flags := '0';
          when ALU_SETFL => next_flags <= a;
                            wr_flags := '0';
          when ALU_GETSHFL => tmp(REG_WIDTH-1 downto 0) := shflags;
                              wr_flags := '0';
          when ALU_SETSHFL => next_shflags <= a;
                              wr_flags := '0';
          when ALU_INTR => next_shflags <= flags;
                           next_flags(FLAG_I) <= '0';
                           wr_flags := '0';
          when ALU_RETI => next_flags <= shflags;
                           wr_flags := '0';
          when ALU_SEI => next_flags(FLAG_I) <= '1';
                          wr_flags := '0';
          when ALU_CLI => next_flags(FLAG_I) <= '0';
                          wr_flags := '0';
-------------------------------------------------------------------------------
          when ALU_NOP => wr_flags := '0';
          when others => null;
        end case;
      when others => null;
    end case;

    -- if the result is to be ignored, it will be ignored in the write-back stage
    result <= tmp(REG_WIDTH-1 downto 0);

    -- the flags do not make sense with all instructions yet
    if wr_flags = '1' then
      next_flags(FLAG_C) <= tmp(REG_WIDTH);
      next_flags(FLAG_N) <= tmp(REG_WIDTH-1);
      next_flags(FLAG_Z) <= zero(tmp(REG_WIDTH-1 downto 0));
      next_flags(FLAG_V) <= sgna xor sgnb xor tmp(REG_WIDTH) xor tmp(REG_WIDTH-1);
      next_flags(FLAG_P) <= parity(tmp(REG_WIDTH-1 downto 0));
    end if;

    if intr = '1' then
      next_shflags <= flags;
      next_flags(FLAG_I) <= '0';
    end if;
    
  end process compute;

end behaviour;
