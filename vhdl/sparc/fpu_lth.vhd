-------------------------------------------------------------------------------
--  Copyright (C) 2002 Martin Kasprzyk <m_kasprzyk@altavista.com>
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
-------------------------------------------------------------------------------
-- File       : fpu.vhd
-- Author     : Martin Kasprzyk <e00mk@efd.lth.se>
-------------------------------------------------------------------------------
-- Description: A IEEE754 floating point unit for the LEON SPARC processor
-------------------------------------------------------------------------------
-- Modfied by Jiri Gaisler to:
-- * be VHDL-87 compatible 
-- * remove ambiguity for std_logic +,-, and > operands.
-- * supress 'X' warnings from std_logic_arith packages
-- * added bug fixes from Albert Wang (5 Dec 2002)
-- * added bug fixes from Albert Wang (16 Dec 2002)
-------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned."-";
use ieee.std_logic_unsigned."+";
use ieee.std_logic_unsigned.">";
use work.leon_iface.all;
use work.sparcv8.all;

entity fpu_lth is
  port(
    ss_clock        : in  std_logic;
    FpInst          : in  std_logic_vector(9 downto 0);
    FpOp            : in  std_logic;
    FpLd            : in  std_logic;
    Reset           : in  std_logic;
    fprf_dout1      : in  std_logic_vector(63 downto 0);
    fprf_dout2      : in  std_logic_vector(63 downto 0);
    RoundingMode    : in  std_logic_vector(1 downto 0);
    FpBusy          : out std_logic;
    FracResult      : out std_logic_vector(54 downto 3);
    ExpResult       : out std_logic_vector(10 downto 0);
    SignResult      : out std_logic;
    SNnotDB         : out std_logic;                            -- Not used
    Excep           : out std_logic_vector(5 downto 0);
    ConditionCodes  : out std_logic_vector(1 downto 0);
    ss_scan_mode    : in  std_logic;                            -- Not used
    fp_ctl_scan_in  : in  std_logic;                            -- Not used
    fp_ctl_scan_out : out std_logic                             -- Not used
  );
end;

architecture rtl of fpu_lth is

  constant zero : std_logic_vector(63 downto 0) := (others => '0');

-------------------------------------------------------------------------------
-- Leading zero counter.
-------------------------------------------------------------------------------
  procedure lz_counter (
    in_vect       : in  std_logic_vector(55 downto 0);
    leading_zeros : out std_logic_vector(5 downto 0)) is 
    variable pos_mask : std_logic_vector(55 downto 0);
    variable neg_mask : std_logic_vector(55 downto 0);
    variable leading_one : std_logic_vector(55 downto 0);
    variable nr_zeros : std_logic_vector(5 downto 0);
  begin
    -- Find leading one e.g. if in_vect = 00101101 then pos_mask = 00111111
    -- and neg_mask = "11100000, performing and gives leading_one = 00100000
    pos_mask(55) := in_vect(55);
    for i in 54 downto 0 loop
      pos_mask(i) := pos_mask(i+1) or in_vect(i);
    end loop;
    neg_mask := "1" & (not pos_mask(55 downto 1));
    leading_one := pos_mask and neg_mask;

    -- Get number of leading zeros from the leading_one vector
    nr_zeros := "000000";
 
    for i in 1 to 55 loop
      if (i / 32) /= 0 then
        nr_zeros(5) := nr_zeros(5) or leading_one(55-i);
      end if;

      if ((i mod 32) / 16) /= 0  then
        nr_zeros(4) := nr_zeros(4) or leading_one(55-i);
      end if;

      if (((i mod 32) mod 16) / 8) /= 0 then
        nr_zeros(3) := nr_zeros(3) or leading_one(55-i);
      end if;

      if ((((i mod 32) mod 16) mod 8) / 4) /= 0 then
        nr_zeros(2) := nr_zeros(2) or leading_one(55-i);
      end if;

      if (((((i mod 32) mod 16) mod 8) mod 4) / 2) /= 0 then
        nr_zeros(1) := nr_zeros(1) or leading_one(55-i);
      end if;
      
      if (i mod 2) /= 0 then
        nr_zeros(0) := nr_zeros(0) or leading_one(55-i);
      end if;
    end loop;

    -- Return result
    leading_zeros := nr_zeros;
  end lz_counter;
  
-------------------------------------------------------------------------------
-- Variable amount right shifter with sticky bit calculation.
-------------------------------------------------------------------------------
  procedure right_shifter_sticky (
    in_vect    : in  std_logic_vector(54 downto 0);
    amount     : in  std_logic_vector(5 downto 0);
    out_vect   : out std_logic_vector(54 downto 0);
    sticky_bit : out std_logic) is
    variable after32  : std_logic_vector(54 downto 0);
    variable after16  : std_logic_vector(54 downto 0);
    variable after8   : std_logic_vector(54 downto 0);
    variable after4   : std_logic_vector(54 downto 0);
    variable after2   : std_logic_vector(54 downto 0);
    variable after1   : std_logic_vector(54 downto 0);
    variable sticky32 : std_logic;
    variable sticky16 : std_logic;
    variable sticky8  : std_logic;
    variable sticky4  : std_logic;
    variable sticky2  : std_logic;
    variable sticky1  : std_logic;
  begin
    -- If amount(5) = '1' then shift vector 32 positions right
    if amount(5) = '1' then
      after32 := zero(31 downto 0) & in_vect(54 downto 32);
      if in_vect(31 downto 0) /= zero(31 downto 0) then
        sticky32 := '1';
      else
        sticky32 := '0';
      end if;
    else
      after32 := in_vect;
      sticky32 := '0';
    end if;

    -- If amount(4) = '1' then shift vector 16 positions right
    if amount(4) = '1' then
      after16 := zero(15 downto 0) & after32(54 downto 16);
      if after32(15 downto 0) /= zero(15 downto 0) then
        sticky16 := '1';
      else
        sticky16 := '0';
      end if;
    else
      after16 := after32;
      sticky16 := '0';
    end if;

    -- If amount(3) = '1' then shift vector 8 positions right
    if amount(3) = '1' then
      after8 := zero(7 downto 0) & after16(54 downto 8);
      if after16(7 downto 0) /= zero(7 downto 0) then
        sticky8 := '1';
      else
        sticky8 := '0';
      end if;
    else
      after8 := after16;
      sticky8 := '0';
    end if;

    -- If amount(2) = '1' then shift vector 4 positions right
    if amount(2) = '1' then
      after4 := zero(3 downto 0) & after8(54 downto 4);
      if after8(3 downto 0) /= zero(3 downto 0) then
        sticky4 := '1';
      else
        sticky4 := '0';
      end if;
    else
      after4 := after8;
      sticky4 := '0';
    end if;

    -- If amount(1) = '1' then shift vector 2 positions right
    if amount(1) = '1' then
      after2 := "00" & after4(54 downto 2);
      if after4(1 downto 0) /= "00" then
        sticky2 := '1';
      else
        sticky2 := '0';
      end if;
    else
      after2 := after4;
      sticky2 := '0';
    end if;

    -- If amount(0) = '1' then shift vector 1 positions right
    if amount(0) = '1' then
      after1 := "0" & after2(54 downto 1);
      sticky1 := after2(0);
    else
      after1 := after2;
      sticky1 := '0';
    end if;

    -- Return values
    out_vect := after1;
    sticky_bit := sticky32 or sticky16 or sticky8 or sticky4 or sticky2 or
                 sticky1;
  end right_shifter_sticky;

-------------------------------------------------------------------------------
-- Variable amount left shifter
-------------------------------------------------------------------------------
  procedure left_shifter (
    in_vect  : in  std_logic_vector(56 downto 0);
    amount   : in  std_logic_vector(5 downto 0);
    out_vect : out std_logic_vector(56 downto 0)) is
    variable after32 : std_logic_vector(56 downto 0);
    variable after16 : std_logic_vector(56 downto 0);
    variable after8  : std_logic_vector(56 downto 0);
    variable after4  : std_logic_vector(56 downto 0);
    variable after2  : std_logic_vector(56 downto 0);
    variable after1  : std_logic_vector(56 downto 0);
  begin
    -- If amount(5) = '1' then shift vector 32 positions left
    if amount(5) = '1' then
      after32 := in_vect(24 downto 0) & zero(31 downto 0);
    else
      after32 := in_vect;
    end if;

    -- If amount(4) = '1' then shift vector 16 positions left
    if amount(4) = '1' then
      after16 :=  after32(40 downto 0) & zero(15 downto 0);
    else
      after16 := after32;
    end if;

    -- If amount(3) = '1' then shift vector 8 positions left
    if amount(3) = '1' then
      after8 := after16(48 downto 0) & zero(7 downto 0);
    else
      after8 := after16;
    end if;

    -- If amount(2) = '1' then shift vector 4 positions left
    if amount(2) = '1' then
      after4 := after8(52 downto 0) & zero(3 downto 0);
    else
      after4 := after8;
    end if;

    -- If amount(1) = '1' then shift vector 2 positions left
    if amount(1) = '1' then
      after2 := after4(54 downto 0) & "00";
    else
      after2 := after4;
    end if;

    -- If amount(0) = '1' then shift vector 1 positions left
    if amount(0) = '1' then
      after1 := after2(55 downto 0) & "0";
    else
      after1 := after2;
    end if;

    -- Return value
    out_vect := after1;
  end left_shifter;
  
-------------------------------------------------------------------------------
-- Declaration of record types used to pass signals between pipeline stages.
-------------------------------------------------------------------------------
type op_decode_stage_type is record     -- input <-> op_decode
  opcode : std_logic_vector(9 downto 0);
end record;

type prenorm_stage_type is record       -- op_decode <-> prenorm
  sign1      : std_logic;
  exp1       : std_logic_vector(10 downto 0);
  frac1     : std_logic_vector(51 downto 0);
  sign2      : std_logic;
  exp2       : std_logic_vector(10 downto 0);
  frac2     : std_logic_vector(51 downto 0);
  single     : std_logic;               -- Single precision
  comp       : std_logic;               -- Compare and set cc
  gen_ex     : std_logic;               -- Generate exception if unordered 
  op1_denorm : std_logic;
  op2_denorm : std_logic;
  op1_inf    : std_logic;
  op2_inf    : std_logic;
  op1_NaN    : std_logic;
  op2_NaN    : std_logic;
  op1_SNaN   : std_logic;
  op2_SNaN   : std_logic;
end record;

type addsub_stage_type is record        -- prenorm <-> addsub
  sign_a   : std_logic;
  a        : std_logic_vector(56 downto 0);
  sign_b   : std_logic;
  b        : std_logic_vector(56 downto 0);
  exp      : std_logic_vector(10 downto 0);
  single   : std_logic;                 -- Single precision
  comp     : std_logic;                 -- Compare and set cc
  gen_ex   : std_logic;                 -- Generate exception if unordered 
  swaped   : std_logic;                 -- Operands swaped during pre_norm
  op1_inf  : std_logic;
  op2_inf  : std_logic;
  op1_NaN  : std_logic;
  op2_NaN  : std_logic;
  op1_SNaN : std_logic;
  op2_SNaN : std_logic;
end record;

type postnorm_stage_type is record      -- addsub <-> postnorm
  frac     : std_logic_vector(56 downto 0);
  exp      : std_logic_vector(10 downto 0);
  sign     : std_logic;
  single   : std_logic;                         -- Single precision
  comp     : std_logic;                         -- Compare and set cc  
  cc       : std_logic_vector(1 downto 0);      -- Condition codes
  exc      : std_logic_vector(4 downto 0);      -- Exceptions
  res_inf  : std_logic;
  res_NaN  : std_logic;
  res_SNaN : std_logic;
  res_zero : std_logic;
end record;

type roundnorm_stage_type is record     -- postnorm <-> roundnorm
  frac     : std_logic_vector(56 downto 0);
  exp      : std_logic_vector(10 downto 0);
  sign     : std_logic;
  single   : std_logic;                         -- Single precision
  comp     : std_logic;                         -- Compare and set cc  
  cc       : std_logic_vector(1 downto 0);      -- Condition codes
  exc      : std_logic_vector(4 downto 0);      -- Exceptions
  res_inf  : std_logic;
  res_NaN  : std_logic;
  res_SNaN : std_logic;
end record;

type fpu_result_type is record          -- roundnorm <-> out
  frac : std_logic_vector(51 downto 0);
  exp  : std_logic_vector(10 downto 0);
  sign : std_logic;
  cc   : std_logic_vector(1 downto 0);
  exc  : std_logic_vector(5 downto 0);
end record;

-------------------------------------------------------------------------------
-- Declaration of input and output signal from the different pipeline
-- registers.
-------------------------------------------------------------------------------
signal de, de_in : op_decode_stage_type;
signal pren, pren_in : prenorm_stage_type;
signal as, as_in : addsub_stage_type;
signal posn, posn_in : postnorm_stage_type;
signal rnd, rnd_in : roundnorm_stage_type;
signal rnd_out : fpu_result_type;

-------------------------------------------------------------------------------
-- Type and signals used by generate busy process. In the fututure this process
-- might be integrated into the pipeline but for now a seperat process is used.
-------------------------------------------------------------------------------
type fpu_state is (start, get_operand, pre_norm, add_sub, post_norm,
                   rnd_norm, hold_val);
signal state, next_state : fpu_state;
signal result_ready : std_logic;

begin  -- rtl

  de_in.opcode <= FpInst;
  
-------------------------------------------------------------------------------
-- Opcode decode and unpacking stage
-------------------------------------------------------------------------------
  decode_stage: process (de, fprf_dout1, fprf_dout2)
    variable single : std_logic;
    variable exp1 : std_logic_vector(10 downto 0);
    variable exp2 : std_logic_vector(10 downto 0);
    variable frac1 : std_logic_vector(51 downto 0);
    variable frac2 : std_logic_vector(51 downto 0);
    variable frac1_zero : std_logic;
    variable frac2_zero : std_logic;
    variable exp1_max : std_logic;
    variable exp2_max : std_logic;
    variable exp1_min : std_logic;
    variable exp2_min : std_logic;
  begin
    -- Get sign bit for op1
    pren_in.sign1 <= fprf_dout1(63);

    -- Unpack exponent and fraction depending on the precision mode. Note that
    -- if single precision is used som bit filling must be done for the
    -- exponent and fraction since double precision is used internally.
    if de.opcode(1 downto 0) = "01" then -- If single precision
      single := '1';
      exp1 := "000" & fprf_dout1(62 downto 55);
      frac1 := "0" & zero(27 downto 0) & fprf_dout1(54 downto 32);
      exp2 := "000" & fprf_dout2(62 downto 55);
      frac2 := "0" & zero(27 downto 0) & fprf_dout2(54 downto 32);
    else
      -- If double precision
      single := '0';
      exp1 := fprf_dout1(62 downto 52);
      frac1 := fprf_dout1(51 downto 0);
      exp2 := fprf_dout2(62 downto 52);
      frac2 := fprf_dout2(51 downto 0);      
    end if;

    -- Check if fracions zero
    if frac1 = zero(51 downto 0) then
      frac1_zero := '1';
    else
      frac1_zero := '0';
    end if;

    if frac2 = zero(51 downto 0) then
      frac2_zero := '1';
    else
      frac2_zero := '0';
    end if;

    -- Check if exp is max or min
    if (exp1(7 downto 0) = "11111111") and
       ((single = '1') or (exp1(10 downto 8) = "111")) then
      exp1_max := '1';
      exp1_min := '0';
    elsif exp1 = "00000000000" then
      exp1_max := '0';
      exp1_min := '1';
    else
      exp1_max := '0';
      exp1_min := '0';
    end if;

    if (exp2(7 downto 0) = "11111111") and
       ((single = '1') or (exp2(10 downto 8) = "111")) then
      exp2_max := '1';
      exp2_min := '0';
    elsif exp2 = "00000000000" then
      exp2_max := '0';
      exp2_min := '1';
    else
      exp2_max := '0';
      exp2_min := '0';
    end if;

    -- Detect special numbers
    pren_in.op1_denorm <= exp1_min;
    pren_in.op2_denorm <= exp2_min;
    pren_in.op1_inf <= exp1_max and frac1_zero;
    pren_in.op2_inf <= exp2_max and frac2_zero;
    pren_in.op1_SNaN <= exp1_max and (not frac1_zero) and
                        not (frac1(51) or (frac1(22) and single));
    pren_in.op2_SNaN <= exp2_max and (not frac2_zero) and
                        not (frac2(51) or (frac2(22) and single));
    pren_in.op1_NaN <= exp1_max and (not frac1_zero) and
                       (frac1(51) or (frac1(22) and single));
    pren_in.op2_NaN <= exp2_max and (not frac2_zero) and
                       (frac2(51) or (frac2(22) and single));
    
    -- Decode instruction. If operation is sub or cmp then negate op2 sign.
    -- Unimplemented opcodes will result in addition.
    case de.opcode(8 downto 0) is
      when FSUBS | FSUBD =>     pren_in.sign2 <= not fprf_dout2(63);
                                pren_in.comp <= '0';
                                pren_in.gen_ex <= '0';
      when FCMPS | FCMPD =>     pren_in.sign2 <= not fprf_dout2(63);
                                pren_in.comp <= '1';
                                pren_in.gen_ex <= '0';
      when FCMPES | FCMPED =>   pren_in.sign2 <= not fprf_dout2(63);
                                pren_in.comp <= '1';
                                pren_in.gen_ex <= '1';
      when others =>            pren_in.sign2 <= fprf_dout2(63);
                                pren_in.comp <= '0';
                                pren_in.gen_ex <= '0';
    end case;

    pren_in.single <= single;
    pren_in.frac1 <= frac1;
    pren_in.exp1 <= exp1;
    pren_in.frac2 <= frac2;
    pren_in.exp2 <= exp2;
  end process decode_stage;

-------------------------------------------------------------------------------
-- Prenorm stage
-------------------------------------------------------------------------------
  prenorm_stage: process (pren)
    variable switch_ops : std_logic;
    variable sign_diff : std_logic_vector(11 downto 0);
    variable abs_diff : std_logic_vector(11 downto 0);
    variable all_zero : std_logic_vector(11 downto 0);
    variable shift_amount : std_logic_vector(5 downto 0);
    variable adj_op : std_logic_vector(54 downto 0);
    variable shifted_op : std_logic_vector(54 downto 0);
    variable sticky_bit : std_logic;
  begin
    all_zero := (others => '0');
    
    -- Calculate differens
-- pragma translate_off
    if not is_x(pren.exp1 & pren.exp2) then
-- pragma translate_on
      sign_diff := ("0" & pren.exp1) - ("0" & pren.exp2);
-- pragma translate_off
    end if;
-- pragma translate_on
    switch_ops := sign_diff(11);        -- Switch needed

    -- If negative get absolute value
    if sign_diff(11) = '1' then
-- pragma translate_off
      if not is_x(all_zero & sign_diff) then
-- pragma translate_on
        abs_diff := all_zero - sign_diff;
-- pragma translate_off
      end if;
-- pragma translate_on
    else
      abs_diff := sign_diff(11 downto 0);
    end if;

    -- Not needed to shift more then the length of the fraction
-- pragma translate_off
    if not is_x(abs_diff) then
-- pragma translate_on
      if abs_diff > 52 then
        shift_amount := "110100";
      else
        shift_amount := abs_diff(5 downto 0);
      end if;
-- pragma translate_off
    end if;
-- pragma translate_on
    
    -- Do switch of operands if needed. Then retrieve the hidden bit for the
    -- larger operand and append overflow, guard, round and sticky bit. For the
    -- smaller operand retrive hidden bit and append guard and round bit. 
    if switch_ops = '1' then
      if (pren.single='1') then   -- single precision
        as_in.a <=zero(29 downto 0) & (not pren.op2_denorm) & pren.frac2(22 downto 0) & "000";
        adj_op := zero(28 downto 0) & (not pren.op1_denorm) & pren.frac1(22 downto 0) & "00";
      else
        as_in.a <= "0" & (not pren.op2_denorm) & pren.frac2 & "000";
        adj_op := (not pren.op1_denorm) & pren.frac1 & "00";
      end if;
      as_in.exp <= pren.exp2;
      as_in.sign_a <= pren.sign2;
      as_in.sign_b <= pren.sign1;
    else
      if (pren.single='1') then   -- single precision
        as_in.a <=zero(29 downto 0) & (not pren.op1_denorm) & pren.frac1(22 downto 0) & "000";
        adj_op := zero(28 downto 0) & (not pren.op2_denorm) & pren.frac2(22 downto 0) & "00";
      else
        as_in.a <= "0" & (not pren.op1_denorm) & pren.frac1 & "000";
        adj_op := (not pren.op2_denorm) & pren.frac2 & "00";
      end if;
      as_in.exp <= pren.exp1;
      as_in.sign_a <= pren.sign1;
      as_in.sign_b <= pren.sign2;
    end if;
    
    -- Shift smaller operand right and get sticky bit.
    right_shifter_sticky(adj_op,shift_amount,shifted_op,sticky_bit);

    -- Add overflow and sticky bit for shifted smaller operand.
    as_in.b <= "0" & shifted_op & sticky_bit;
    
    as_in.swaped <= switch_ops;
    as_in.op1_inf <= pren.op1_inf;
    as_in.op2_inf <= pren.op2_inf;
    as_in.op1_NaN <= pren.op1_NaN;
    as_in.op2_NaN <= pren.op2_Nan;
    as_in.op1_SNaN <= pren.op1_SNaN;
    as_in.op2_SNaN <= pren.op2_SNaN;
    as_in.single <= pren.single;
    as_in.comp <= pren_in.comp;
    as_in.gen_ex <= pren_in.gen_ex;
  end process prenorm_stage;

-------------------------------------------------------------------------------
-- Add/Sub stage
-------------------------------------------------------------------------------
  addsub_stage: process (as)
    variable signs : std_logic_vector(1 downto 0);
    variable result : std_logic_vector(56 downto 0);
    variable temp : std_logic_vector(56 downto 0);
    variable neg_value : std_logic;
    variable all_zero : std_logic_vector(56 downto 0);
    variable unordered : std_logic;
    variable zero_fraction : std_logic;
    variable cc_bit0 : std_logic;
    variable cc_bit1 : std_logic;
    variable SNaN : std_logic;
    variable NaN : std_logic;
    variable inf : std_logic;
  begin
    all_zero := (others => '0');
    
    signs := as.sign_a & as.sign_b;

    -- Perform operation based on the sign of the operands
    case signs is
      when "00" => 
-- pragma translate_off
		if not is_x(as.a & as.b) then
-- pragma translate_on
		   result := as.a + as.b;
-- pragma translate_off
		end if;
-- pragma translate_on
                   posn_in.sign <= '0';
                   neg_value := '0';
      when "01" =>
-- pragma translate_off
		if not is_x(as.a & as.b) then
-- pragma translate_on
                   result := as.a - as.b;
-- pragma translate_off
		end if;
-- pragma translate_on
                   posn_in.sign <= result(56);
                   neg_value := result(56); 
      when "10" =>
-- pragma translate_off
		if not is_x(as.a & as.b) then
-- pragma translate_on
                   result := as.a - as.b;
-- pragma translate_off
		end if;
-- pragma translate_on
                   posn_in.sign <= not result(56);
                   neg_value := result(56);
      when "11" =>
-- pragma translate_off
		if not is_x(as.a & as.b) then
-- pragma translate_on
                   result := as.a + as.b;
-- pragma translate_off
		end if;
-- pragma translate_on
                   posn_in.sign <= '1';
                   neg_value := '0';
      when others => null;
    end case;

    -- If result is negative set fraction = -result else set fraction = result
-- pragma translate_off
    if not is_x(all_zero & result) then
-- pragma translate_on
      temp := all_zero - result;
-- pragma translate_off
    end if;
-- pragma translate_on
    if neg_value = '1' then
      posn_in.frac <= temp(56 downto 0);
    else
      posn_in.frac <= result(56 downto 0);
    end if;

    -- Check if result is zero
    if result = all_zero then
      zero_fraction := '1';
      posn_in.exp <= "00000000000";
    else
      zero_fraction := '0';
      posn_in.exp <= as.exp;
    end if;

    -- Check if unordered operands i.e. any operand is some sort of NaN
    unordered := as.op1_NaN or as.op2_NaN or as.op1_SNaN or as.op2_SNaN;

    -- Check if result should be a SNaN.
    SNaN := as.op1_SNaN or as.op2_SNaN or (unordered and as.gen_ex);

    -- Check if result should be a NaN i.e. unordered opearands that don't
    -- result in a SNaN or two inf values with different signs.
    NaN := (unordered and (not SNaN)) or
           (as.op1_inf and as.op2_inf and (signs(1) xor signs(0)));
    
    -- Check if result should be inf.
    inf := (as.op1_inf or as.op2_inf) and (not NaN) and (not SNaN);
    
    -- Calculate condition codes.
    cc_bit1 := ((not zero_fraction) and (not neg_value) and (not as.swaped)) or
               unordered;
    cc_bit0 := ((not zero_fraction) and
                (as.swaped or (neg_value and (not as.swaped)))) or unordered;

    -- Set condition codes if comp signal is 1.
    if as.comp = '1' then
      posn_in.cc <= cc_bit1 & cc_bit0;
    else
      posn_in.cc <= (others => '0');
    end if;

    -- Set exceptions
    posn_in.exc <= SNaN & inf & "000";
    
    -- Check if operation results in specal value
    posn_in.res_SNaN <= SNaN;
    posn_in.res_NaN <= NaN;
    posn_in.res_inf <= inf;
    posn_in.single <= as.single;
    posn_in.res_zero <= zero_fraction;
    posn_in.comp <= as.comp;
  end process addsub_stage;

-------------------------------------------------------------------------------
-- Postnorm stage
-------------------------------------------------------------------------------
  posnorm_stage: process (posn)
    variable mask : std_logic_vector(55 downto 0);
    variable leading_one : std_logic_vector(55 downto 0);
    variable leading_zeros : std_logic_vector(55 downto 0);
    variable shifts_needed : std_logic_vector(5 downto 0);
    variable shift_amount : std_logic_vector(5 downto 0);
    variable exp : std_logic_vector(10 downto 0);
    variable frac : std_logic_vector(56 downto 0);
    variable overflow : std_logic;
    variable underflow : std_logic;
  begin
    -- If supernormal (overflow bit set) shift left by one step and inc exp
    if ((posn.single = '1') and (posn.frac(27) = '1')) or
       (posn.frac(56) = '1') then
      frac := "0" & posn.frac(56 downto 1);
-- pragma translate_off
      if not is_x(posn.exp) then
-- pragma translate_on
        exp := posn.exp + 1;
-- pragma translate_off
      end if;
-- pragma translate_on
      underflow := '0';
    else
      -- Get number of leading zeros, if single precision is used don't count
      -- leading 29 zeroes. (Overflow bit is not counted)
      if posn.single = '1' then
        lz_counter((posn.frac(26 downto 0) & "0" & zero(27 downto 0)),shifts_needed);
      else
        lz_counter(posn.frac(55 downto 0),shifts_needed);
      end if;

      -- If the shift amount needed is larger then the exponent then underflow
      -- has occured, check that fraction is not zero.
-- pragma translate_off
      if not is_x(shifts_needed & posn.exp) then
-- pragma translate_on
        if (unsigned(shifts_needed) > unsigned(posn.exp)) and (posn.res_zero = '0') then
            shift_amount := posn.exp(5 downto 0);
          exp := (others => '0');
          underflow := '1';
        else
          shift_amount := shifts_needed;
-- pragma translate_off
          if not is_x( posn.exp & shift_amount) then
-- pragma translate_on
            exp := posn.exp - shift_amount;
-- pragma translate_off
          end if;
-- pragma translate_on
          underflow := '0';
        end if;
-- pragma translate_off
      end if;
-- pragma translate_on

      -- Perform left shift
      left_shifter(posn.frac,shift_amount,frac);
    end if;

    -- Check if overflow has occured, also check that result is not any NaN
    if (exp(7 downto 0) = "11111111") and
       ((posn.single = '1') or (exp(10 downto 8) = "111")) and
       (posn.res_SNaN = '0') and (posn.res_NaN = '0') then
      overflow := '1';
    else
      overflow := '0';
    end if;

    -- If operation is not some sort of compare set overflow/underflow
    -- exceptions caused in this pipeline stage
    if (posn.comp = '0') then
      rnd_in.exc <= posn.exc(4) & overflow & underflow & posn.exc(1 downto 0);
    else
      rnd_in.exc <= posn.exc(4) & "00" & posn.exc(1 downto 0);
    end if;
    
    rnd_in.frac <= frac;
    rnd_in.exp <= exp;
    rnd_in.cc <= posn.cc;
    rnd_in.res_NaN <= posn.res_NaN;
    rnd_in.res_SNaN <= posn.res_SNaN;
    rnd_in.res_inf <= posn.res_inf or overflow;
    rnd_in.single <= posn.single;
    rnd_in.comp <= posn.comp;
    rnd_in.sign <= posn.sign;
  end process posnorm_stage;

  
-------------------------------------------------------------------------------
-- Round and normalize stage
-------------------------------------------------------------------------------
  roundnorm_stage: process (rnd, RoundingMode)
    variable rounded_value : std_logic_vector(53 downto 0);
    variable rounded_norm_value : std_logic_vector(52 downto 0);
    variable exp_norm : std_logic_vector(10 downto 0);
    variable exp : std_logic_vector(10 downto 0);
    variable fraction : std_logic_vector(51 downto 0);
    variable all_zero : std_logic_vector(51 downto 0);
    variable overflow : std_logic;
    variable inexact : std_logic;
    variable NaNs : std_logic;
  begin
    all_zero := (others => '0');

    -- Perform rounding according to selected rounding mode
    case RoundingMode is
      when "00" => if rnd.frac(2) = '1' and
                      rnd.frac(3 downto 0) /=  "0000" then
-- pragma translate_off
      		     if not is_x(rnd.frac(56 downto 3)) then
-- pragma translate_on
                       rounded_value := rnd.frac(56 downto 3) + 1;
-- pragma translate_off
      		     end if;
-- pragma translate_on
                   else
                     rounded_value := rnd.frac(56 downto 3);
                   end if;
      when "01" => rounded_value := rnd.frac(56 downto 3);
      when "10" => if rnd.sign = '0' and rnd.frac(2) = '1' then
-- pragma translate_off
      		     if not is_x(rnd.frac(56 downto 3)) then
-- pragma translate_on
                       rounded_value := rnd.frac(56 downto 3) + 1;
-- pragma translate_off
      		     end if;
-- pragma translate_on
                   else
                     rounded_value := rnd.frac(56 downto 3);
                   end if;
      when "11" => if rnd.sign = '1' and rnd.frac(2) = '1' then
-- pragma translate_off
      		     if not is_x(rnd.frac(56 downto 3)) then
-- pragma translate_on
                       rounded_value := rnd.frac(56 downto 3) + 1;
-- pragma translate_off
      		     end if;
-- pragma translate_on
                   else
                     rounded_value := rnd.frac(56 downto 3);
                   end if;
      when others => null;
    end case;

    -- Normalize if needed i.e. if overflow bit set shift fraction one step
    -- left and inc exp.
    if (rnd.single = '1' and rounded_value(24) = '1') or
       rounded_value(36) = '1' then
      rounded_norm_value := rounded_value(53 downto 1);
-- pragma translate_off
      if not is_x(rnd.exp) then
-- pragma translate_on
        exp_norm := rnd.exp + 1;
-- pragma translate_off
      end if;
-- pragma translate_on
    else
      rounded_norm_value := rounded_value(52 downto 0);
      exp_norm := rnd.exp;
    end if;

    -- Check if overflow has occured
    if (exp_norm(7 downto 0) = "11111111") and
       ((rnd.single = '1') or (exp_norm(10 downto 8) = "111")) and
       (rnd.res_SNaN = '0') and (rnd.res_NaN = '0') then
      overflow := '1';
    else
      overflow := '0';
    end if;

    -- Check if result is inexact
    inexact := (rnd.frac(2) or rnd.frac(1) or rnd.frac(0)) and (not rnd.comp);

    -- Check if result is some sort of NaN
    NaNs := rnd.res_NaN or rnd.res_SNaN;
    
    -- Set fraction and exponent.
    if NaNs = '1' then
      fraction := rnd.res_NaN & "1" & all_zero(49 downto 0);
      exp := (others => '1');
    elsif overflow = '1' or rnd.res_inf = '1' then
      fraction := (others => '0');
      exp := (others => '1');
    else
      fraction := rounded_norm_value(51 downto 0);
      exp := exp_norm;
    end if;

    -- Set exception bits. If operaration is some sort of compare then
    -- overflow, underflow and inexact interrupt can not occure. 
    if rnd.comp = '1' then
      rnd_out.exc <= "0" & rnd.exc(4) & "0000";
    else
      rnd_out.exc <= "0" & rnd.exc(4) & (overflow or rnd.exc(3)) &
                     rnd.exc(2 downto 1) & inexact;
    end if;
    
    -- Put out result
    if rnd.single = '1' then
      rnd_out.frac <= fraction(22 downto 0) & "0" & zero(27 downto 0); 
    else
      rnd_out.frac <= fraction;
    end if;

    rnd_out.exp <= exp;
    rnd_out.sign <= rnd.sign;
    rnd_out.cc <= rnd.cc;
  end process roundnorm_stage;

-------------------------------------------------------------------------------
-- FPU busy signal generation process
-------------------------------------------------------------------------------
  gen_busy: process (state, FpOp, FpLd)
  begin
    -- Default assignments
    FpBusy <= '0';
    next_state <= state;
    result_ready <= '0';

    -- Calculate nextstate and output
    case state is
      when start       => if FpOp = '1' then
                            next_state <= get_operand;
                          end if;
      when get_operand => FpBusy <= '1';
                          if FpLd = '1' then
                            next_state <= pre_norm;
                          end if;
      when pre_norm    => FpBusy <= '1';
                          next_state <= add_sub;
      when add_sub     => FpBusy <= '1';
                          next_state <= post_norm;
      when post_norm   => FpBusy <= '1';
                          next_state <= rnd_norm;
      when rnd_norm    => result_ready <= '1';
                          if FpOp = '1' then
                            next_state <= get_operand;
                          else
                            next_state <= hold_val;
                          end if;
      when hold_val    => if FpOp = '1' then
                            next_state <= get_operand;
                          end if;
      when others      => null;
    end case;
  end process gen_busy;

  process (ss_clock, Reset)
  begin
    if Reset = '1' then
      state <= start;
    elsif ss_clock = '1' and ss_clock'event then
      state <= next_state;
    end if;
  end process;

-------------------------------------------------------------------------------
-- Pipeline registers
-------------------------------------------------------------------------------

  -- Gated ff holding opcode
  de_gated : process (ss_clock, FpOp)  
  begin
    if ss_clock = '1' and ss_clock'event then
      if FpOp = '1' then
        de <= de_in;
      end if;
    end if;
  end process de_gated;

  -- Gated ff holding unpacked operands and control signals
  pren_gated : process (ss_clock, FpLd)
  begin
    if ss_clock = '1' and ss_clock'event then
      if FpLd = '1' then
        pren <= pren_in;
      end if;
    end if;
  end process pren_gated;

  -- Normal ff for the other pipeline stages
  pipe_regs: process (ss_clock)
  begin  -- process pipe_regs
    if ss_clock = '1' and ss_clock'event then
      as <= as_in;
      posn <= posn_in;
      rnd <= rnd_in;
    end if;
  end process pipe_regs;

  -- Gated ff with asynchronous reset holding the FPU output values
  out_gated_reset: process (ss_clock, Reset, result_ready)
  begin  -- process out_gated_reset
    if Reset = '1' then
      FracResult <= (others => '0');
      ExpResult <= (others => '0');
      SignResult <= '0';
      Excep <= (others => '0');
      ConditionCodes <= (others => '0');
    elsif ss_clock = '1' and ss_clock'event then
      if result_ready = '1' then
        FracResult <= rnd_out.frac;
        ExpResult <= rnd_out.exp;
        SignResult <= rnd_out.sign;
        Excep <= rnd_out.exc;
        ConditionCodes <= rnd_out.cc;
      end if;
    end if;
  end process out_gated_reset;
  
end rtl;
