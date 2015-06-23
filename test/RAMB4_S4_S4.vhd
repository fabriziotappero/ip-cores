-------------------------------------------------------------------------------
-- 
-- Copyright (C) 2009, 2010 Dr. Juergen Sauermann
-- 
--  This code is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This code is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this code (see the file named COPYING).
--  If not, see http://www.gnu.org/licenses/.
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- Module Name:    prog_mem - Behavioral 
-- Create Date:    14:09:04 10/30/2009 
-- Description:    a block memory module
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAMB4_S4_S4 is
    generic(INIT_00 : bit_vector := X"00000000000000000000000000000000"
                                  &  "00000000000000000000000000000000";
            INIT_01 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_02 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_03 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_04 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_05 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_06 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_07 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_08 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_09 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_0A : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_0B : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_0C : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_0D : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_0E : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_0F : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000");

    port(   ADDRA   : in  std_logic_vector(9 downto 0);
            ADDRB   : in  std_logic_vector(9 downto 0);
            CLKA    : in  std_ulogic;
            CLKB    : in  std_ulogic;
            DIA     : in  std_logic_vector(3 downto 0);
            DIB     : in  std_logic_vector(3 downto 0);
            ENA     : in  std_ulogic;
            ENB     : in  std_ulogic;
            RSTA    : in  std_ulogic;
            RSTB    : in  std_ulogic;
            WEA     : in  std_ulogic;
            WEB     : in  std_ulogic;

            DOA     : out std_logic_vector(3 downto 0);
            DOB     : out std_logic_vector(3 downto 0));
end RAMB4_S4_S4;

architecture Behavioral of RAMB4_S4_S4 is

function cv(A : bit) return std_logic is
begin
   if (A = '1') then return '1';
   else              return '0';
   end if;
end;

function cv1(A : std_logic) return bit is
begin
   if (A = '1') then return '1';
   else              return '0';
   end if;
end;

signal DATA : bit_vector(4095 downto 0) :=
    INIT_0F & INIT_0E & INIT_0D & INIT_0C & INIT_0B & INIT_0A & INIT_09 & INIT_08 & 
    INIT_07 & INIT_06 & INIT_05 & INIT_04 & INIT_03 & INIT_02 & INIT_01 & INIT_00;

begin

    process(CLKA, CLKB)
    begin
        if (rising_edge(CLKA)) then
            if (ENA = '1') then
                DOA(3) <= cv(DATA(conv_integer(ADDRA & "11")));
                DOA(2) <= cv(DATA(conv_integer(ADDRA & "10")));
                DOA(1) <= cv(DATA(conv_integer(ADDRA & "01")));
                DOA(0) <= cv(DATA(conv_integer(ADDRA & "00")));
                if (WEA = '1') then
                    DATA(conv_integer(ADDRA & "11")) <= cv1(DIA(3));
                    DATA(conv_integer(ADDRA & "10")) <= cv1(DIA(2));
                    DATA(conv_integer(ADDRA & "01")) <= cv1(DIA(1));
                    DATA(conv_integer(ADDRA & "00")) <= cv1(DIA(0));
                end if;
           end if;
        end if;

        if (rising_edge(CLKB)) then
            if (ENB = '1') then
                DOB(3) <= cv(DATA(conv_integer(ADDRB & "11")));
                DOB(2) <= cv(DATA(conv_integer(ADDRB & "10")));
                DOB(1) <= cv(DATA(conv_integer(ADDRB & "01")));
                DOB(0) <= cv(DATA(conv_integer(ADDRB & "00")));
                if (WEB = '1') then
                    DATA(conv_integer(ADDRB & "11")) <= cv1(DIB(3));
                    DATA(conv_integer(ADDRB & "10")) <= cv1(DIB(2));
                    DATA(conv_integer(ADDRB & "01")) <= cv1(DIB(1));
                    DATA(conv_integer(ADDRB & "00")) <= cv1(DIB(0));
                end if;
            end if;
        end if;
    end process;

end Behavioral;

