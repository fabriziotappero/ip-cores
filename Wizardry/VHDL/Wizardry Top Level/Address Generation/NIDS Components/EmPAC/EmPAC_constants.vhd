----------------------------------------------------------------------------------
--
--  This file is a part of Technica Corporation Wizardry Project
--
--  Copyright (C) 2004-2009, Technica Corporation  
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Module Name: EmPAC_constants - Package file 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: 
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
package EmPAC_constants is

 	type StateType is (ftreset,ft0,ft1,ft2,ft3,	ft4,	ft5,	ft6,	ft7,	ft8,	ft9,	ftA,	ftB,	ft_C,	ftD,	ftE,
	ftF,	ft10,	ft11,	ft12,	ft13,	ft14,	ft15,	ft16,	ft17,	ft18,
	ft19,	ft1A,	ft1B,	ft1C,	ft1D,	ft1E,	ft1F,	ft20,	ft21,	ft22,
	ft23,	ft24,	ft25,	ft26,	ft27,	ft28,	ft29,	ft2A,	ft2B,	ft2C,
	ft2D,	ft2E,	ft2F,	ft30,	ft31,	ft32,	ft33,	ft34,	ft35,	ft36,
	ft37,	ft38,	ft39,	ft3A,	ft3B,	ft3C,	ft3D,	ft3E,	ft3F,	ft40,ft41,unknown_protocol,icmp_protocol); 

constant init_00 : std_logic_vector(5 downto 0) := "000000";
constant init_02 : std_logic_vector(5 downto 0) := "000010";
constant init_04 : std_logic_vector(5 downto 0) := "000100";
constant init_0C : std_logic_vector(5 downto 0) := "001100";
constant init_10 : std_logic_vector(5 downto 0) := "010000";
constant init_12 : std_logic_vector(5 downto 0) := "010010";
constant init_1C : std_logic_vector(5 downto 0) := "011100";
constant init_30 : std_logic_vector(5 downto 0) := "110000";
constant init_38 : std_logic_vector(5 downto 0) := "111000";
constant init_x1 : std_logic_vector(5 downto 0) := "XX0001";
constant init_x9 : std_logic_vector(5 downto 0) := "XX1001";
constant init_x5 : std_logic_vector(5 downto 0) := "XX0101";
constant init_xD : std_logic_vector(5 downto 0) := "XX1101";

constant init_eth : std_logic_vector(11 downto 0) := "000000000000";
constant init_arp : std_logic_vector(11 downto 0) := "000000000111";
constant init_ip  : std_logic_vector(11 downto 0) := "000000011000";
constant init_tcp : std_logic_vector(11 downto 0) := "000000100011";
constant init_udp : std_logic_vector(11 downto 0) := "000000101101";
constant zero : std_logic_vector(3 downto 0) := "0000";
constant one : std_logic_vector(3 downto 0) := "0001";
constant two : std_logic_vector(3 downto 0) := "0010";
constant three : std_logic_vector(3 downto 0) := "0011";
constant four : std_logic_vector(3 downto 0) := "0100";
constant five : std_logic_vector(3 downto 0) := "0101";
constant eight : std_logic_vector(3 downto 0) := "1000";
constant nine : std_logic_vector(3 downto 0) := "1001";
constant A : std_logic_vector(3 downto 0) := "1010";
constant B : std_logic_vector(3 downto 0) := "1011";
constant C : std_logic_vector(3 downto 0) := "1100";
constant D : std_logic_vector(3 downto 0) := "1101";

constant data_0 : std_logic_vector(3 downto 0) := zero;
constant data_1 : std_logic_vector(3 downto 0) := one;
constant data_2 : std_logic_vector(3 downto 0) := two;--when dram_data(3 downto 0) = two else
constant data_3 : std_logic_vector(3 downto 0) := three;
constant data_4 : std_logic_vector(3 downto 0) := four;
constant data_5 : std_logic_vector(3 downto 0) := five;
constant data_8 : std_logic_vector(3 downto 0) := eight;
constant data_9 : std_logic_vector(3 downto 0) := nine;
constant data_A : std_logic_vector(3 downto 0) := A;
constant data_B : std_logic_vector(3 downto 0) := B;
constant data_C : std_logic_vector(3 downto 0) := C;
constant data_D : std_logic_vector(3 downto 0) := D;

constant zero_u : std_logic_vector(2 downto 0) := "000";
constant one_u : std_logic_vector(2 downto 0) := "001";
constant two_u : std_logic_vector(2 downto 0) := "010";
constant three_u : std_logic_vector(2 downto 0) := "011";
constant four_u : std_logic_vector(2 downto 0) := "100";

constant ETH : std_logic_vector(15 downto 0) := X"0000";-- => jump_addr_s <= init_eth;--X"0000";--ETH
constant ARP : std_logic_vector(15 downto 0) := X"0806";
constant IPv4 : std_logic_vector(15 downto 0) := X"0800";
constant IPv6 : std_logic_vector(15 downto 0) := X"86DD";
constant TCP : std_logic_vector(15 downto 0) := X"0006";
constant UDP : std_logic_vector(15 downto 0) := X"0011";
constant reg_num : integer := 128;
constant port_0 : std_logic_vector(15 downto 0) := X"0000";--0--0000
constant port_1 : std_logic_vector(15 downto 0) := X"0001";--1--0001
constant port_2 : std_logic_vector(15 downto 0) := X"0005";--5--0005
constant port_3 : std_logic_vector(15 downto 0) := X"0007";--7--0007
constant port_4 : std_logic_vector(15 downto 0) := X"0009";--9--0009
constant port_5 : std_logic_vector(15 downto 0) := X"000B";--11--000B
constant port_6 : std_logic_vector(15 downto 0) := X"000D";--13--000D
constant port_7 : std_logic_vector(15 downto 0) := X"0013";--19--0013
constant port_8 : std_logic_vector(15 downto 0) := X"0014";--20--0014
constant port_9 : std_logic_vector(15 downto 0) := X"0015";--21--0015
constant port_10 : std_logic_vector(15 downto 0) := X"0016";--22--0016
constant port_11 : std_logic_vector(15 downto 0) := X"0017";--23--0017
constant port_12 : std_logic_vector(15 downto 0) := X"0019";--25--0019
constant port_13 : std_logic_vector(15 downto 0) := X"0025";--37--0025
constant port_14 : std_logic_vector(15 downto 0) := X"0029";--41--0029
constant port_15 : std_logic_vector(15 downto 0) := X"002A";--42--002A
constant port_16 : std_logic_vector(15 downto 0) := X"002B";--43--002B
constant port_17 : std_logic_vector(15 downto 0) := X"0031";--49--0031
constant port_18 : std_logic_vector(15 downto 0) := X"0035";--53--0035
constant port_19 : std_logic_vector(15 downto 0) := X"0039";--57--0039
constant port_20 : std_logic_vector(15 downto 0) := X"0043";--67--0043
constant port_21 : std_logic_vector(15 downto 0) := X"0044";--68--0044
constant port_22 : std_logic_vector(15 downto 0) := X"0045";--69--0045
constant port_23 : std_logic_vector(15 downto 0) := X"0046";--70--0046
constant port_24 : std_logic_vector(15 downto 0) := X"004F";--79--004F
constant port_25 : std_logic_vector(15 downto 0) := X"0050";--80--0050
constant port_26 : std_logic_vector(15 downto 0) := X"0058";--88--0058
constant port_27 : std_logic_vector(15 downto 0) := X"0065";--101--0065
constant port_28 : std_logic_vector(15 downto 0) := X"006B";--107--006B
constant port_29 : std_logic_vector(15 downto 0) := X"006D";--109--006D
constant port_30 : std_logic_vector(15 downto 0) := X"006E";--110--006E
constant port_31 : std_logic_vector(15 downto 0) := X"0076";--118--0076
constant port_32 : std_logic_vector(15 downto 0) := X"0077";--119--0077
constant port_33 : std_logic_vector(15 downto 0) := X"007B";--123--007B
constant port_34 : std_logic_vector(15 downto 0) := X"008F";--143--008F
constant port_35 : std_logic_vector(15 downto 0) := X"009C";--156--009C
constant port_36 : std_logic_vector(15 downto 0) := X"00A1";--161--00A1
constant port_37 : std_logic_vector(15 downto 0) := X"00A2";--162--00A2
constant port_38 : std_logic_vector(15 downto 0) := X"00B3";--179--00B3
constant port_39 : std_logic_vector(15 downto 0) := X"00C2";--194--00C2
constant port_40 : std_logic_vector(15 downto 0) := X"016E";--366--016E
constant port_41 : std_logic_vector(15 downto 0) := X"0171";--369--0171
constant port_42 : std_logic_vector(15 downto 0) := X"0185";--389--0185
constant port_43 : std_logic_vector(15 downto 0) := X"01AB";--427--01AB
constant port_44 : std_logic_vector(15 downto 0) := X"01BB";--443--01BB
constant port_45 : std_logic_vector(15 downto 0) := X"01BD";--445--01BD
constant port_46 : std_logic_vector(15 downto 0) := X"01D0";--464--01D0
constant port_47 : std_logic_vector(15 downto 0) := X"0201";--513--0201
constant port_48 : std_logic_vector(15 downto 0) := X"0202";--514--0202
constant port_49 : std_logic_vector(15 downto 0) := X"021C";--540--021C
constant port_50 : std_logic_vector(15 downto 0) := X"021F";--543--021F
constant port_51 : std_logic_vector(15 downto 0) := X"0220";--544--0220
constant port_52 : std_logic_vector(15 downto 0) := X"0222";--546--0222
constant port_53 : std_logic_vector(15 downto 0) := X"0223";--547--0223
constant port_54 : std_logic_vector(15 downto 0) := X"022A";--554--022A
constant port_55 : std_logic_vector(15 downto 0) := X"0251";--593--0251
constant port_56 : std_logic_vector(15 downto 0) := X"027C";--636--027C
constant port_57 : std_logic_vector(15 downto 0) := X"0286";--646--0286
constant port_58 : std_logic_vector(15 downto 0) := X"0287";--647--0287
constant port_59 : std_logic_vector(15 downto 0) := X"02B3";--691--02B3
constant port_60 : std_logic_vector(15 downto 0) := X"02ED";--749--02ED
constant port_61 : std_logic_vector(15 downto 0) := X"02EE";--750--02EE
constant port_62 : std_logic_vector(15 downto 0) := X"030E";--782--030E
constant port_63 : std_logic_vector(15 downto 0) := X"033D";--829--033D
constant port_64 : std_logic_vector(15 downto 0) := X"0369";--873--0369
constant port_65 : std_logic_vector(15 downto 0) := X"03DD";--989--03DD
constant port_66 : std_logic_vector(15 downto 0) := X"03DE";--990--03DE
constant port_67 : std_logic_vector(15 downto 0) := X"03E0";--992--03E0
constant port_68 : std_logic_vector(15 downto 0) := X"03E1";--993--03E1
constant port_69 : std_logic_vector(15 downto 0) := X"03E3";--995--03E3


  function count  (signal cnt : in std_logic_vector) return std_logic_vector;
  function minus (signal a : in std_logic_vector; signal b: in std_logic_vector) return std_logic_vector;
  function power (signal count : in integer range 0 to 30) return std_logic_vector;
  function myxor (signal l : in std_logic_vector; signal r : in std_logic_vector)return std_logic;

--  procedure <procedure_name>	(<type_declaration> <constant_name>	: in <type_declaration>);
--
end EmPAC_constants;
--
--
package body EmPAC_constants is
--
---- Example 1
  function count  (signal cnt : in std_logic_vector  ) return std_logic_vector is
    variable counter     : std_logic_vector(17 downto 0);
  begin
    counter := (unsigned(cnt) - '1');
    return counter; 
  end count;
  
  
  
  function minus (signal a : in std_logic_vector; signal b: in std_logic_vector) return std_logic_vector is
		variable av : std_logic_vector(15 downto 0);
		variable bv : std_logic_vector(15 downto 0);
		variable result : std_logic_vector(15 downto 0);
	begin
		av := a;
		bv := b;
		result := av-bv;
		return result;
  end minus;
  
  function power (signal count : in integer range 0 to 30) return std_logic_vector is
	variable cnt : integer range 0 to 30;
	variable value : integer;
	begin
		cnt := count;
		value := 2 ** count;
		return conv_STD_LOGIC_VECTOR(value,31);
	end power;
	
	function myxor (signal l : in std_logic_vector; signal r : in std_logic_vector) return std_logic is
	  variable result : std_logic_vector(15 downto 0);
	  variable out_s : std_logic;
	  variable lv : std_logic_vector(15 downto 0);
	  variable rv : std_logic_vector(15 downto 0);
	  begin  -- "xor"
	  for i in 0 to 15 loop
			result(i) := l(i) xor r(i);
	  end loop;
	  if (result = X"0000") then
		out_s := '1';
	  else out_s := '0';
	  end if;
		return out_s;
	end myxor;  

-- 
end EmPAC_constants;
