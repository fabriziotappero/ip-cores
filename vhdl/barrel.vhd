-------------------------------------------------------------------------------
-- File: ex_stage.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Barrel shifter
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use WORK.RISE_PACK.all;
use WORK.RISE_PACK_SPECIFIC.all;

library UNISIM;
use UNISIM.VComponents.all;


use WORK.RISE_PACK.all;
use work.RISE_PACK_SPECIFIC.all;

entity barrel_shifter is
  port (reg_a      : in  std_logic_vector(15 downto 0);
        reg_b      : in  REGISTER_T;
        left       : in  std_logic;
        arithmetic : in  std_logic;
        reg_q      : out REGISTER_T);
end barrel_shifter;


architecture barrel_shifter_rtl of barrel_shifter is
  signal shifter_value : REGISTER_T;
  signal mult_b_in     : std_logic_vector(17 downto 0);
  signal mult_a_in     : std_logic_vector(17 downto 0);
  signal mult_p_out    : std_logic_vector(35 downto 0);

  component MULT18X18
    port (A : in  std_logic_vector(17 downto 0);
          B : in  std_logic_vector(17 downto 0);
          P : out std_logic_vector(35 downto 0)
          );
  end component;

  function reverse_register (reg_in : REGISTER_T) return REGISTER_T is
    variable reversed : REGISTER_T;
  begin
    for i in 0 to (ARCHITECTURE_WIDTH - 1) loop
      reversed(i) := reg_in (ARCHITECTURE_WIDTH - 1 - i);
    end loop;
    return reversed;
  end reverse_register;
  
begin
  MULT18X18_inst : MULT18X18
    port map (
      P => mult_p_out,                  -- 36-bit multiplier output
      A => mult_b_in,                   -- 18-bit multiplier input
      B => mult_a_in                    -- 18-bit multiplier input
      );

  process(reg_b)
    variable index : integer range 0 to 15;
  begin
    shifter_value        <= x"0000";
    index                := to_integer(ieee.numeric_std.unsigned(reg_b(3 downto 0)));
    shifter_value(index) <= '1';
  end process;

  process(shifter_value, reg_a, left)
  begin
    mult_b_in <= "00" & shifter_value;
    if left = '1' then
      mult_a_in <= "00" & reg_a;
    else
      mult_a_in <= "00" & reverse_register(reg_a);
    end if;
  end process;

  process(mult_p_out, left, arithmetic, reg_a, reg_b)
  begin
    if left = '1' then
      reg_q <= mult_p_out(ARCHITECTURE_WIDTH - 1 downto 0);
    else
      reg_q <= reverse_register(mult_p_out(ARCHITECTURE_WIDTH - 1 downto 0));
      if arithmetic = '1' and reg_a(ARCHITECTURE_WIDTH - 1) = '1' then
        for index in 0 to ARCHITECTURE_WIDTH - 1 loop
          if index < reg_b then
            reg_q(ARCHITECTURE_WIDTH - 1 - index) <= '1';
          end if;
        end loop;
      end if;
    end if;
  end process;
  
end architecture;
