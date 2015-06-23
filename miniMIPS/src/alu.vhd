------------------------------------------------------------------------------------
--                                                                                --
--    Copyright (c) 2004, Hangouet Samuel                                         --
--                  , Jan Sebastien                                               --
--                  , Mouton Louis-Marie                                          --
--                  , Schneider Olivier     all rights reserved                   --
--                                                                                --
--    This file is part of miniMIPS.                                              --
--                                                                                --
--    miniMIPS is free software; you can redistribute it and/or modify            --
--    it under the terms of the GNU Lesser General Public License as published by --
--    the Free Software Foundation; either version 2.1 of the License, or         --
--    (at your option) any later version.                                         --
--                                                                                --
--    miniMIPS is distributed in the hope that it will be useful,                 --
--    but WITHOUT ANY WARRANTY; without even the implied warranty of              --
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               --
--    GNU Lesser General Public License for more details.                         --
--                                                                                --
--    You should have received a copy of the GNU Lesser General Public License    --
--    along with miniMIPS; if not, write to the Free Software                     --
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   --
--                                                                                --
------------------------------------------------------------------------------------


-- If you encountered any problem, please contact :
--
--   lmouton@enserg.fr
--   oschneid@enserg.fr
--   shangoue@enserg.fr
--



--------------------------------------------------------------------------
--                                                                      --
--                                                                      --
--        miniMIPS Processor : Arithmetical and logical unit            --
--                                                                      --
--                                                                      --
--                                                                      --
-- Authors : Hangouet  Samuel                                           --
--           Jan       Sébastien                                        --
--           Mouton    Louis-Marie                                      --
--           Schneider Olivier                                          --
--                                                                      --
--                                                          june 2003   --
--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.pack_mips.all;

entity alu is
port
(
    clock : in bus1;
    reset : in bus1;
    op1 : in bus32;            -- Operand 1
    op2 : in bus32;            -- Operand 2
    ctrl : in alu_ctrl_type;   -- Opearator control

    res : out bus32;           -- The result is 32 bit long
    overflow : out bus1        -- Overflow of the result
);
end alu;


architecture rtl of alu is

    -- Signals to pre-process the operands
    signal efct_op1, efct_op2 : bus33;        -- Effective operands of the adder (33 bits)
    signal comp_op2 : bus1;                   -- Select the opposite of operand 2
    signal igno_op2 : bus1;                   -- Ignore op 2 (put zeros)
    signal sign_op1 : bus1;                   -- High bit of op 1
    signal sign_op2 : bus1;                   -- High bit of op 2
    signal signe : bus1;                      -- Signed operation (bit sign extension)
    signal shift_val : natural range 0 to 31; -- Value of the shift

    -- Signals for internal results
    signal res_shl, res_shr : bus32; -- Results of left and right shifter
    signal res_lui : bus32;          -- Result of Load Upper Immediate
    signal res_add : bus33;          -- Result of the adder
    signal carry : bus33;            -- Carry for the adder
    signal nul : bus1;               -- Check if the adder result is zero
    signal hilo : bus64;             -- Internal registers to store the multiplication operation
    signal tmp_hilo : bus64;         -- Internal registers to store the multiplication operation (synchronised)

begin

    --  Process if the operation is signed compliant
    signe <= '1' when (ctrl=OP_ADD or ctrl=OP_SUB or ctrl=OP_SLT or ctrl=OP_SNEG or ctrl=OP_SPOS or ctrl=OP_LNEG or ctrl=OP_LPOS)
                 else
             '0';

    sign_op1 <= signe and op1(31);
    sign_op2 <= signe and op2(31);

    -- Selection of the value of the second operand : op2 or -op2 (ie not op2 + 1)
    comp_op2 <= '1' when -- The opposite of op2 is used
                           (ctrl=OP_SUB or ctrl=OP_SUBU) -- Opposite of the operand 2 to obtain a substraction
                        or (ctrl=OP_SLT or ctrl=OP_SLTU) -- Process the difference to check the lesser than operation for the operands
                        or (ctrl=OP_EQU or ctrl=OP_NEQU) -- Process the difference to check the equality of the operands
                    else
                '0'; -- by default, op2 is used

    igno_op2 <= '1' when -- Op 2 will be zero (when comp_op2='0')
                           (ctrl=OP_SPOS or ctrl=OP_LNEG) -- Process if the op1 is nul with op1+0
                    else
                '0';

    -- Effective signals for the adder
    efct_op2 <= not (sign_op2 & op2) when (comp_op2='1') else -- We take the opposite of op2 to get -op2 (we will add 1 with the carry)
                (others => '0')  when (igno_op2='1') else     -- Op2 is zero
                (sign_op2 & op2);                             -- by default we use op2 (33 bits long)

    efct_op1 <= sign_op1 & op1;

    -- Execution of the addition
    carry <= X"00000000" & comp_op2; -- Carry to one when -op2 is needed
    res_add <= std_logic_vector(unsigned(efct_op1) + unsigned(efct_op2) + unsigned(carry));

    nul <= '1' when (res_add(31 downto 0)=X"00000000") else '0'; -- Check the nullity of the result

    -- Value of the shift for the programmable shifter
    shift_val <= to_integer(unsigned(op1(4 downto 0)));

    res_shl <= bus32(shift_left(unsigned(op2), shift_val));
    res_shr <= not bus32(shift_right(unsigned(not op2) , shift_val)) when (ctrl=OP_SRA and op2(31)='1') else
               bus32(shift_right(unsigned(op2), shift_val));
    res_lui <= op2(15 downto 0) & X"0000";

    -- Affectation of the hilo register if necessary
    tmp_hilo <= std_logic_vector(signed(op1)*signed(op2)) when (ctrl=OP_MULT) else
                std_logic_vector(unsigned(op1)*unsigned(op2)) when (ctrl=OP_MULTU) else
                op1 & hilo(31 downto 0) when (ctrl=OP_MTHI) else
                hilo(63 downto 32) & op1 when (ctrl=OP_MTLO) else
                (others => '0');

    -- Check the overflows
    overflow <= '1' when ((ctrl=OP_ADD and op1(31)=efct_op2(31) and op1(31)/=res_add(31))
                      or  (ctrl=OP_SUB and op1(31)/=op2(31) and op1(31)/=res_add(31))) else
                '0'; -- Only ADD and SUB can overflow

    -- Result affectation
    res <=
        -- Arithmetical operations
        res_add(31 downto 0)                     when (ctrl=OP_ADD or ctrl=OP_ADDU or ctrl=OP_SUB or ctrl=OP_SUBU) else
        -- Logical operations
        op1 and op2                              when (ctrl=OP_AND)  else
        op1 or op2                               when (ctrl=OP_OR)   else
        op1 nor op2                              when (ctrl=OP_NOR)  else
        op1 xor op2                              when (ctrl=OP_XOR)  else
        -- Different tests : the result is one when the test is succesful
        (0 => res_add(32), others=>'0')          when (ctrl=OP_SLTU or ctrl=OP_SLT) else
        (0 => nul, others=>'0')                  when (ctrl=OP_EQU)  else
        (0 => not nul, others=>'0')              when (ctrl=OP_NEQU) else
        (0 => op1(31), others=>'0')              when (ctrl=OP_SNEG) else
        (0 => not (op1(31) or nul), others=>'0') when (ctrl=OP_SPOS) else
        (0 => (op1(31) or nul), others=>'0')     when (ctrl=OP_LNEG) else
        (0 => not op1(31), others=>'0')          when (ctrl=OP_LPOS) else
        -- Shifts
        res_shl                                  when (ctrl=OP_SLL)  else
        res_shr                                  when (ctrl=OP_SRL or ctrl=OP_SRA)  else
        res_lui                                  when (ctrl=OP_LUI)  else
        -- Internal registers
        hilo(63 downto 32)                       when (ctrl=OP_MFHI) else
        hilo(31 downto 0)                        when (ctrl=OP_MFLO or ctrl=OP_MULT or ctrl=OP_MULTU) else
        op1                                      when (ctrl=OP_MTHI or ctrl=OP_MTLO) else
        op2                                      when (ctrl=OP_OP2) else
        -- Always true
        X"00000001"                              when (ctrl=OP_OUI) else
        -- Unknown operation or nul result desired
        (others => '0');

    -- Save the hilo register
    process (clock)
    begin
        if clock = '1' and clock'event then
            if reset = '1' then
                hilo <= (others => '0');
            elsif (ctrl = OP_MULT) or (ctrl = OP_MULTU) or (ctrl = OP_MTLO) or (ctrl = OP_MTHI) then
                 hilo <= tmp_hilo;
            end if;
        end if;
    end process;
end rtl;
