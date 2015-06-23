----------------------------------------------------------------------------
---- Create Date:    14:30:08 07/28/2010 											----		
---- Design Name: lfsr_pkg														   	----				
---- Project Name: lfsr_randgen													   ----	
---- Description: 																		----	
----  This is the package file used in the lfsr_randgen project.The     ----
----  package contain the function for XORing bits from various tap     ----
----  locations depending on the generic parameter(width of lfsr )      ----	
----																							----	
----------------------------------------------------------------------------
----                                                                    ----
---- This file is a part of the lfsr_randgen project at                 ----
---- http://www.opencores.org/						                        ----
----                                                                    ----
---- Author(s):                                                         ----
----   Vipin Lal, lalnitt@gmail.com                                     ----
----                                                                    ----
----------------------------------------------------------------------------
----                                                                    ----
---- Copyright (C) 2010 Authors and OPENCORES.ORG                       ----
----                                                                    ----
---- This source file may be used and distributed without               ----
---- restriction provided that this copyright statement is not          ----
---- removed from the file and that any derivative work contains        ----
---- the original copyright notice and the associated disclaimer.       ----
----                                                                    ----
---- This source file is free software; you can redistribute it         ----
---- and/or modify it under the terms of the GNU Lesser General         ----
---- Public License as published by the Free Software Foundation;       ----
---- either version 2.1 of the License, or (at your option) any         ----
---- later version.                                                     ----
----                                                                    ----
---- This source is distributed in the hope that it will be             ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied         ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR            ----
---- PURPOSE. See the GNU Lesser General Public License for more        ----
---- details.                                                           ----
----                                                                    ----
---- You should have received a copy of the GNU Lesser General          ----
---- Public License along with this source; if not, download it         ----
---- from http://www.opencores.org/lgpl.shtml                           ----
----                                                                    ----
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package lfsr_pkg is

function xor_gates( random : std_logic_vector) return std_logic;

end lfsr_pkg;

--Package body starts from here.
package body lfsr_pkg is

--function for XORing from tap values.
function xor_gates( random : std_logic_vector ) return std_logic is

variable xor_out : std_logic:='0';
variable rand : std_logic_vector(random'length-1 downto 0):=random;

begin
if(rand'length = 3) then           --3
xor_out := rand(2) xor rand(1);
elsif(rand'length = 4) then		  --4	
xor_out := rand(3) xor rand(2);
elsif(rand'length = 5) then		  --5
xor_out := rand(4) xor rand(2);
elsif(rand'length = 6) then		  --6
xor_out := rand(5) xor rand(4);
elsif(rand'length = 7) then		  --7	
xor_out := rand(6) xor rand(5);
elsif(rand'length = 8) then		  --8
xor_out := rand(7) xor rand(5) xor rand(4) xor rand(3);  
elsif(rand'length = 9) then		  --9	
xor_out := rand(8) xor rand(4);
elsif(rand'length = 10)then		  --10	
xor_out := rand(9) xor rand(6);
elsif(rand'length =11) then		  --11
xor_out := rand(10) xor rand(8);
elsif(rand'length = 12) then		  --12
xor_out := rand(11) xor rand(5) xor rand(3) xor rand(0);
elsif(rand'length = 13) then		  --13	
xor_out := rand(12) xor rand(3) xor rand(2) xor rand(0);
elsif(rand'length = 14) then		  --14	
xor_out := rand(13) xor rand(4) xor rand(2) xor rand(0);
elsif(rand'length = 15) then		  --15
xor_out := rand(14) xor rand(13);
elsif(rand'length = 16) then		  --16
xor_out := rand(15) xor rand(14) xor rand(12) xor rand(3);
elsif(rand'length = 17) then		  --17
xor_out := rand(16) xor rand(13);
elsif(rand'length = 18) then		  --18
xor_out := rand(17) xor rand(10);
elsif(rand'length = 19) then		  --19
xor_out := rand(18) xor rand(5) xor rand(1) xor rand(0);
elsif(rand'length = 20) then		  --20
xor_out := rand(19) xor rand(16);
elsif(rand'length = 21) then		  --21
xor_out := rand(20) xor rand(18);
elsif(rand'length = 22) then		  --22
xor_out := rand(21) xor rand(20);
elsif(rand'length = 23) then		  --23
xor_out := rand(22) xor rand(17);
elsif(rand'length = 24) then		  --24
xor_out := rand(23) xor rand(22) xor rand(21) xor rand(16);
elsif(rand'length = 25) then		  --25
xor_out := rand(24) xor rand(21);
elsif(rand'length = 26) then		  --26
xor_out := rand(25) xor rand(5) xor rand(1) xor rand(0);
elsif(rand'length = 27) then		  --27
xor_out := rand(26) xor rand(4) xor rand(1) xor rand(0);
elsif(rand'length = 28) then		  --28
xor_out := rand(27) xor rand(24);
elsif(rand'length = 29) then		  --29
xor_out := rand(28) xor rand(26);
elsif(rand'length = 30) then		  --30
xor_out := rand(29) xor rand(5) xor rand(3) xor rand(0);
elsif(rand'length = 31) then		  --31
xor_out := rand(30) xor rand(27);
elsif(rand'length = 32) then		  --32
xor_out := rand(31) xor rand(21) xor rand(1) xor rand(0);
elsif(rand'length = 33) then		  --33
xor_out := rand(32) xor rand(19);
elsif(rand'length = 34) then		  --34
xor_out := rand(33) xor rand(26) xor rand(1) xor rand(0);
elsif(rand'length = 35) then		  --35
xor_out := rand(34) xor rand(32);
elsif(rand'length = 36) then		  --36
xor_out := rand(35) xor rand(24);
elsif(rand'length = 37) then		  --37
xor_out := rand(36) xor rand(4) xor rand(3) xor rand(2) xor rand(1) xor rand(0);
elsif(rand'length = 38) then		  --38
xor_out := rand(37) xor rand(5) xor rand(4) xor rand(0);
elsif(rand'length = 39) then		  --39
xor_out := rand(38) xor rand(34);
elsif(rand'length = 40) then		  --40
xor_out := rand(39) xor rand(37) xor rand(20) xor rand(18);
elsif(rand'length = 41) then		  --41
xor_out := rand(40) xor rand(37);
elsif(rand'length = 42) then		  --42
xor_out := rand(41) xor rand(40) xor rand(19) xor rand(18);
elsif(rand'length = 43) then		  --43
xor_out := rand(42) xor rand(41) xor rand(37) xor rand(36);
elsif(rand'length = 44) then		  --44
xor_out := rand(43) xor rand(42) xor rand(17) xor rand(16);
elsif(rand'length = 45) then		  --45
xor_out := rand(44) xor rand(43) xor rand(41) xor rand(40);
elsif(rand'length = 46) then		  --46
xor_out := rand(45) xor rand(44) xor rand(25) xor rand(24);
elsif(rand'length = 47) then		  --47
xor_out := rand(46) xor rand(41);
elsif(rand'length = 48) then		  --48
xor_out := rand(47) xor rand(46) xor rand(20) xor rand(19);
elsif(rand'length = 49) then		  --49
xor_out := rand(48) xor rand(39);
elsif(rand'length = 50) then		  --50
xor_out := rand(49) xor rand(48) xor rand(23) xor rand(22);
elsif(rand'length = 51) then		  --51
xor_out := rand(50) xor rand(49) xor rand(35) xor rand(34);
elsif(rand'length = 52) then		  --52
xor_out := rand(51) xor rand(48);
elsif(rand'length = 53) then		  --53
xor_out := rand(52) xor rand(51) xor rand(37) xor rand(36);
elsif(rand'length = 54) then		  --54
xor_out := rand(53) xor rand(52) xor rand(17) xor rand(16);
elsif(rand'length = 55) then		  --55
xor_out := rand(54) xor rand(30);
elsif(rand'length = 56) then		  --56
xor_out := rand(55) xor rand(54) xor rand(34) xor rand(33);
elsif(rand'length = 57) then		  --57
xor_out := rand(56) xor rand(49);
elsif(rand'length = 58) then		  --58
xor_out := rand(57) xor rand(38);
elsif(rand'length = 59) then		  --59
xor_out := rand(58) xor rand(57) xor rand(37) xor rand(36);
elsif(rand'length = 60) then		  --60
xor_out := rand(59) xor rand(58);
elsif(rand'length = 61) then		  --61
xor_out := rand(60) xor rand(59) xor rand(45) xor rand(44);
elsif(rand'length = 62) then		  --62
xor_out := rand(61) xor rand(60) xor rand(5) xor rand(4);
elsif(rand'length = 63) then		  --63
xor_out := rand(62) xor rand(61);
elsif(rand'length = 64) then		  --64
xor_out := rand(63) xor rand(62) xor rand(60) xor rand(59);
elsif(rand'length = 65) then		  --65
xor_out := rand(64) xor rand(46);
elsif(rand'length = 66) then		  --66
xor_out := rand(65) xor rand(64) xor rand(56) xor rand(55);
elsif(rand'length = 67) then		  --67
xor_out := rand(66) xor rand(65) xor rand(57) xor rand(56);
elsif(rand'length = 68) then		  --68
xor_out := rand(67) xor rand(58);
elsif(rand'length = 69) then		  --69
xor_out := rand(68) xor rand(66) xor rand(41) xor rand(39);
elsif(rand'length = 70) then		  --70
xor_out := rand(69) xor rand(68) xor rand(54) xor rand(53);
elsif(rand'length = 71) then		  --71
xor_out := rand(70) xor rand(64);
elsif(rand'length = 72) then		  --72
xor_out := rand(71) xor rand(65) xor rand(24) xor rand(18);
elsif(rand'length = 73) then		  --73
xor_out := rand(72) xor rand(47);
elsif(rand'length = 74) then		  --74
xor_out := rand(73) xor rand(72) xor rand(58) xor rand(57);
elsif(rand'length = 75) then		  --75
xor_out := rand(74) xor rand(73) xor rand(64) xor rand(63);
elsif(rand'length = 76) then		  --76
xor_out := rand(75) xor rand(74) xor rand(40) xor rand(39);
elsif(rand'length = 77) then		  --77
xor_out := rand(76) xor rand(75) xor rand(46) xor rand(45);
elsif(rand'length = 78) then		  --78
xor_out := rand(77) xor rand(76) xor rand(58) xor rand(57);
elsif(rand'length = 79) then		  --79
xor_out := rand(78) xor rand(69);
elsif(rand'length = 80) then		  --80
xor_out := rand(79) xor rand(78) xor rand(42) xor rand(41);
elsif(rand'length = 81) then		  --81
xor_out := rand(80) xor rand(76);
elsif(rand'length = 82) then		  --82
xor_out := rand(81) xor rand(78) xor rand(46) xor rand(43);
elsif(rand'length = 83) then		  --83
xor_out := rand(82) xor rand(81) xor rand(37) xor rand(36);
elsif(rand'length = 84) then		  --84
xor_out := rand(83) xor rand(70);
elsif(rand'length = 85) then		  --85
xor_out := rand(84) xor rand(83) xor rand(57) xor rand(56);
elsif(rand'length = 86) then		  --86
xor_out := rand(85) xor rand(84) xor rand(73) xor rand(72);
elsif(rand'length = 87) then		  --87
xor_out := rand(86) xor rand(73);
elsif(rand'length = 88) then		  --88
xor_out := rand(87) xor rand(86) xor rand(16) xor rand(15);
elsif(rand'length = 89) then		  --89
xor_out := rand(88) xor rand(50);
elsif(rand'length = 90) then		  --90
xor_out := rand(89) xor rand(88) xor rand(71) xor rand(70);
elsif(rand'length = 91) then		  --91
xor_out := rand(90) xor rand(89) xor rand(7) xor rand(6);
elsif(rand'length = 92) then		  --92
xor_out := rand(91) xor rand(90) xor rand(79) xor rand(78);
elsif(rand'length = 93) then		  --93
xor_out := rand(92) xor rand(90);
elsif(rand'length = 94) then		  --94
xor_out := rand(93) xor rand(72);
elsif(rand'length = 95) then		  --95
xor_out := rand(94) xor rand(83);
elsif(rand'length = 96) then		  --96
xor_out := rand(95) xor rand(93) xor rand(48) xor rand(46);
elsif(rand'length = 97) then		  --97
xor_out := rand(96) xor rand(90);
elsif(rand'length = 98) then		  --98
xor_out := rand(97) xor rand(86);
elsif(rand'length = 99) then		  --99
xor_out := rand(98) xor rand(96) xor rand(53) xor rand(51);
elsif(rand'length = 100) then		  --100
xor_out := rand(99) xor rand(62);
elsif(rand'length = 101) then		  --101
xor_out := rand(100) xor rand(99) xor rand(94) xor rand(93);
elsif(rand'length = 102) then		  --102
xor_out := rand(101) xor rand(100) xor rand(35) xor rand(34);
elsif(rand'length = 103) then		  --103
xor_out := rand(102) xor rand(93);
elsif(rand'length = 104) then		  --104	
xor_out := rand(103) xor rand(102) xor rand(93) xor rand(92);
elsif(rand'length = 105) then		  --105
xor_out := rand(104) xor rand(88);
elsif(rand'length = 106) then		  --106
xor_out := rand(105) xor rand(90);
elsif(rand'length = 107) then		  --107	
xor_out := rand(106) xor rand(104) xor rand(43) xor rand(41);
elsif(rand'length = 108) then		  --108
xor_out := rand(107) xor rand(76);
elsif(rand'length = 109) then		  --109	
xor_out := rand(108) xor rand(107) xor rand(102) xor rand(101);
elsif(rand'length = 110)then		  --110	
xor_out := rand(109) xor rand(108) xor rand(97) xor rand(96);
elsif(rand'length = 111) then		  --111
xor_out := rand(110) xor rand(100);
elsif(rand'length = 112) then		  --112
xor_out := rand(111) xor rand(109) xor rand(68) xor rand(66);
elsif(rand'length = 113) then		  --113	
xor_out := rand(112) xor rand(103);
elsif(rand'length = 114) then		  --114	
xor_out := rand(113) xor rand(112) xor rand(32) xor rand(31);
elsif(rand'length = 115) then		  --115
xor_out := rand(114) xor rand(113) xor rand(100) xor rand(99);
elsif(rand'length = 116) then		  --116
xor_out := rand(115) xor rand(114) xor rand(45) xor rand(44);
elsif(rand'length = 117) then		  --117
xor_out := rand(116) xor rand(114) xor rand(98) xor rand(96);
elsif(rand'length = 118) then		  --118
xor_out := rand(117) xor rand(84);
elsif(rand'length = 119) then		  --119
xor_out := rand(118) xor rand(110);
elsif(rand'length = 120) then		  --120
xor_out := rand(119) xor rand(112) xor rand(8) xor rand(1);
elsif(rand'length = 121) then		  --121
xor_out := rand(120) xor rand(102);
elsif(rand'length = 122) then		  --122
xor_out := rand(121) xor rand(120) xor rand(62) xor rand(61);
elsif(rand'length = 123) then		  --123
xor_out := rand(122) xor rand(120);
elsif(rand'length = 124) then		  --124
xor_out := rand(123) xor rand(86);
elsif(rand'length = 125) then		  --125
xor_out := rand(124) xor rand(123) xor rand(17) xor rand(16);
elsif(rand'length = 126) then		  --126
xor_out := rand(125) xor rand(124) xor rand(89) xor rand(88);
elsif(rand'length = 127) then		  --127
xor_out := rand(126) xor rand(125);
elsif(rand'length = 128) then		  --128
xor_out := rand(127) xor rand(125) xor rand(100) xor rand(98);
elsif(rand'length = 129) then		  --129
xor_out := rand(128) xor rand(123);
elsif(rand'length = 130) then		  --130
xor_out := rand(129) xor rand(126);
elsif(rand'length = 131) then		  --131
xor_out := rand(130) xor rand(129) xor rand(83) xor rand(82);
elsif(rand'length = 132) then		  --132
xor_out := rand(131) xor rand(102);
elsif(rand'length = 133) then		  --133
xor_out := rand(132) xor rand(131) xor rand(81) xor rand(80);
elsif(rand'length = 134) then		  --134
xor_out := rand(133) xor rand(76);
elsif(rand'length = 135) then		  --135
xor_out := rand(134) xor rand(123);
elsif(rand'length = 136) then		  --136
xor_out := rand(135) xor rand(134) xor rand(10) xor rand(9);
elsif(rand'length = 137) then		  --137
xor_out := rand(136) xor rand(115);
elsif(rand'length = 138) then		  --138
xor_out := rand(137) xor rand(136) xor rand(130) xor rand(129);
elsif(rand'length = 139) then		  --139
xor_out := rand(138) xor rand(135) xor rand(133) xor rand(130);
elsif(rand'length = 140) then		  --140
xor_out := rand(139) xor rand(110);
elsif(rand'length = 141) then		  --141
xor_out := rand(140) xor rand(139) xor rand(109) xor rand(108);
elsif(rand'length = 142) then		  --142
xor_out := rand(141) xor rand(120);
elsif(rand'length = 143) then		  --143
xor_out := rand(142) xor rand(141) xor rand(122) xor rand(121);
elsif(rand'length = 144) then		  --144
xor_out := rand(143) xor rand(142) xor rand(74) xor rand(73);
elsif(rand'length = 145) then		  --145
xor_out := rand(144) xor rand(92);
elsif(rand'length = 146) then		  --146
xor_out := rand(145) xor rand(144) xor rand(86) xor rand(85);
elsif(rand'length = 147) then		  --147
xor_out := rand(146) xor rand(145) xor rand(109) xor rand(108);
elsif(rand'length = 148) then		  --148
xor_out := rand(147) xor rand(120);
elsif(rand'length = 149) then		  --149
xor_out := rand(148) xor rand(147) xor rand(39) xor rand(38);
elsif(rand'length = 150) then		  --150
xor_out := rand(149) xor rand(96);
elsif(rand'length = 151) then		  --151
xor_out := rand(150) xor rand(147);
elsif(rand'length = 152) then		  --152
xor_out := rand(151) xor rand(150) xor rand(86) xor rand(85);
elsif(rand'length = 153) then		  --153
xor_out := rand(152) xor rand(151);
elsif(rand'length = 154) then		  --154
xor_out := rand(153) xor rand(151) xor rand(26) xor rand(24);
elsif(rand'length = 155) then		  --155
xor_out := rand(154) xor rand(153) xor rand(123) xor rand(122);
elsif(rand'length = 156) then		  --156
xor_out := rand(155) xor rand(154) xor rand(40) xor rand(39);
elsif(rand'length = 157) then		  --157
xor_out := rand(156) xor rand(155) xor rand(130) xor rand(129);
elsif(rand'length = 158) then		  --158
xor_out := rand(157) xor rand(156) xor rand(131) xor rand(130);
elsif(rand'length = 159) then		  --159
xor_out := rand(158) xor rand(127);
elsif(rand'length = 160) then		  --160
xor_out := rand(159) xor rand(158) xor rand(141) xor rand(140);
elsif(rand'length = 161) then		  --161
xor_out := rand(160) xor rand(142);
elsif(rand'length = 162) then		  --162
xor_out := rand(161) xor rand(160) xor rand(74) xor rand(73);
elsif(rand'length = 163) then		  --163
xor_out := rand(162) xor rand(161) xor rand(103) xor rand(102);
elsif(rand'length = 164) then		  --164
xor_out := rand(163) xor rand(162) xor rand(150) xor rand(149);
elsif(rand'length = 165) then		  --165
xor_out := rand(164) xor rand(163) xor rand(134) xor rand(133);
elsif(rand'length = 166) then		  --166
xor_out := rand(165) xor rand(164) xor rand(127) xor rand(126);
elsif(rand'length = 167) then		  --167
xor_out := rand(166) xor rand(160);
elsif(rand'length = 168) then		  --168
xor_out := rand(167) xor rand(165) xor rand(152) xor rand(150);
end if;

return xor_out;
end xor_gates;
--END function for XORing using tap values.

end lfsr_pkg;
--End of the package.