-----------------------------------------------------------------------------
-- serial_divide_uu.v  -- Serial division module
--
--
-- Description: See description below (which suffices for IP core
--                                     specification document.)
--
-- Copyright (C) 2002 John Clayton and OPENCORES.ORG (this Verilog version)
--
-- This source file may be used and distributed without restriction provided
-- that this copyright statement is not removed from the file and that any
-- derivative work contains the original copyright notice and the associated
-- disclaimer.
--
-- This source file is free software; you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published
-- by the Free Software Foundation;  either version 2.1 of the License, or
-- (at your option) any later version.
--
-- This source is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
-- License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this source.
-- If not, download it from http:--www.opencores.org/lgpl.shtml
--
-------------------------------------------------------------------------------
--
-- Author: John Clayton
-- Date  : Jan. 30, 2003
-- Update: Jan. 30, 2003  Copied this file from "vga_crosshair.v"
--                        Stripped out extraneous stuff.
-- Update: Mar. 14, 2003  Added S_PP parameter, made some simple changes to
--                        implement quotient leading zero "skip" feature.
-- Update: Mar. 24, 2003  Updated comments to improve readability.
-- Update: Jul. 29, 2009  Verilog to VHDL translation (by David Sala)
--
-------------------------------------------------------------------------------
-- Description:
--
-- This module performs a division operation serially, producing one bit of the
-- answer per clock cycle.  The dividend and the divisor are both taken to be
-- unsigned quantities.  The divider is conceived as an integer divider (as
-- opposed to a divider for fractional quantities) but the user can configure
-- the divider to divide fractional quantities as long as the position of the
-- binary point is carefully monitored.
--
-- The widths of the signals are configurable by parameters, as follows:
--
-- M_PP = Bit width of the dividend
-- N_PP = Bit width of the divisor
-- R_PP = Remainder bits desired
-- S_PP = Skipped quotient bits
--
-- The skipped quotient bits parameter provides a way to prevent the divider
-- from calculating the full M_PP+R_PP output bits, in case some of the leading
-- bits are already known to be zero.  This is the case, for example, when
-- dividing two quantities to obtain a result that is a fraction between 0 and 1
-- (as when measuring PWM signals).  In that case the integer portion of the
-- quotient is always zero, and therefore it need not be calculated.
--
-- The divide operation is begun by providing a pulse on the divide_i input.
-- The quotient is provided (M_PP+R_PP-S_PP) clock cycles later.
-- The divide_i pulse stores the input parameters in registers, so they do
-- not need to be maintained at the inputs throughout the operation of the module.
-- If a divide_i pulse is given to the serial_divide_uu module during the time
-- when it is already working on a previous divide operation, it will abort the
-- operation it was doing, and begin working on the new one.
--
-- The user is responsible for treating the results correctly.  The position
-- of the binary point is not given, but it is understood that the integer part
-- of the result is the M_PP most significant bits of the quotient output.
-- The remaining R_PP least significant bits are the fractional part.
--
-- This is illustrated graphically:
--
--     [ M_PP bits ][    R_PP bits]
--     [ S_PP bits    ][quotient_o]
--
-- The quotient will consist of whatever bits are left after removing the S_PP
-- most significant bits from the (M_PP+R_PP) result bits.
--
-- Attempting to divide by zero will simply produce a result of all ones.
-- This core is so simple, that no checking for this condition is provided.
-- If the user is concerned about a possible divide by zero condition, he should
-- compare the divisor to zero and flag that condition himself!
--
-- The COUNT_WIDTH_PP parameter must be sized so that 2^COUNT_WIDTH_PP-1 is >=
-- M_PP+R_PP-S_PP-1.  The unit terminates the divide operation when the count
-- is equal to M_PP+R_PP-S_PP-1.
--
-- The HELD_OUTPUT_PP parameter causes the unit to keep its output result in
-- a register other than the one which it uses to compute the quotient.  This
-- is useful for applications where the divider is used repeatedly and the
-- previous divide result (quotient) must be stable during the computation of the
-- next divide result.  Using the additional output register does incur some
-- additional utilization of resources.
--
-------------------------------------------------------------------------------
library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use ieee.math_real.log;
use ieee.math_real.ceil;


entity serial_divide_uu is
  generic ( M_PP : integer := 16;           -- Size of dividend
            N_PP : integer := 8;            -- Size of divisor
            R_PP : integer := 0;            -- Size of remainder
            S_PP : integer := 0;            -- Skip this many bits (known leading zeros)
--            COUNT_WIDTH_PP : integer := 5;  -- 2^COUNT_WIDTH_PP-1 >= (M_PP+R_PP-S_PP-1)
            HELD_OUTPUT_PP : integer := 0); -- Set to 1 if stable output should be held
                                            -- from previous operation, during current
                                            -- operation.  Using this option will increase
                                            -- the resource utilization (costs extra d-flip-flops.)
    port(   clk_i      : in  std_logic;
            clk_en_i   : in  std_logic;
            rst_i      : in  std_logic;
            divide_i   : in  std_logic;
            dividend_i : in  std_logic_vector(M_PP-1 downto 0);
            divisor_i  : in  std_logic_vector(N_PP-1 downto 0);
            quotient_o : out std_logic_vector(M_PP+R_PP-S_PP-1 downto 0);
            done_o     : out std_logic
    );
end serial_divide_uu;


architecture behavior of serial_divide_uu is

   constant COUNT_WIDTH_PP    : integer := integer(ceil(log(real(M_PP+R_PP-S_PP),2.0)));

   signal done_s         : std_logic;

-- Internal signal declarations
   signal grand_dividend : std_logic_vector(M_PP+R_PP-1 downto 0)     ;
   signal grand_divisor  : std_logic_vector(M_PP+N_PP+R_PP-2 downto 0);
   signal quotient       : std_logic_vector(M_PP+R_PP-S_PP-1 downto 0);
   signal quotient_reg   : std_logic_vector(M_PP+R_PP-1 downto 0)     ;
   signal divide_count   : std_logic_vector(COUNT_WIDTH_PP-1 downto 0);

   signal subtract_node  : std_logic_vector(M_PP+N_PP+R_PP-1 downto 0); -- Subtract node has extra "sign" bit
   signal quotient_node  : std_logic_vector(M_PP+R_PP-1 downto 0)     ; -- Shifted version of quotient
   signal divisor_node   : std_logic_vector(M_PP+N_PP+R_PP-2 downto 0); -- Shifted version of grand divisor

begin

   done_o <= done_s;

----------------------------------------------------------------------------
-- Module code

   P_SERIAL_DIVIDING_MODULE: process (clk_i)
      begin
         if rising_edge(clk_i) then
            if rst_i='1' then
                grand_dividend <= (others=>'0');
                grand_divisor <= (others=>'0');
                divide_count <= (others=>'0');
                quotient <= (others=>'0');
                done_s <= '0';
            elsif clk_en_i='1' then
                done_s <= '0';
                if divide_i='1' then       -- Start a new division
                    quotient <= (others=>'0');
                    divide_count <= (others=>'0');
                    -- dividend placed initially so that remainder bits are zero...
                    grand_dividend <= (others=>'0');
                    grand_dividend (M_PP+R_PP-1 downto R_PP)<= dividend_i;
                    -- divisor placed initially for a 1 bit overlap with dividend...
                    -- But adjust it back by S_PP, to account for bits that are known
                    -- to be leading zeros in the quotient.
                    grand_divisor <= (others=>'0');
                    grand_divisor (M_PP+N_PP+R_PP-2 downto M_PP+R_PP-1) <= divisor_i;
                elsif (divide_count = M_PP+R_PP-S_PP-1) then
                    done_s <= '1';                    -- Indicate done, just sit
                    if done_s='0' then
                        quotient <= quotient_node;      -- final shift...
                        quotient_reg <= quotient_node;  -- final shift (held output)
                    end if;
                else                -- Division in progress
                    -- If the subtraction yields a positive result, then store that result
                    if subtract_node(M_PP+N_PP+R_PP-1)='0' then
                        grand_dividend <= subtract_node(M_PP+R_PP-1 downto 0);
                    end if;
                    -- If the subtraction yields a positive result, then a 1 bit goes into
                    -- the quotient, via a shift register
                    quotient <= quotient_node;
                    -- shift the grand divisor to the right, to cut it in half next clock cycle
                    grand_divisor <= divisor_node;
                    -- Advance the counter
                    divide_count <= divide_count + 1;
                end if;
            end if;
         end if;
     end process;

    subtract_node <= ('0' & grand_dividend) - ('0' & grand_divisor);
    quotient_node <= quotient(M_PP+R_PP-S_PP-2 downto 0) & not(subtract_node(M_PP+N_PP+R_PP-1));
    divisor_node  <= '0' & grand_divisor(M_PP+N_PP+R_PP-2 downto 1);
    quotient_o    <= quotient when HELD_OUTPUT_PP = 0 else quotient_reg;

end behavior;
