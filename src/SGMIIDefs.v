/*
	Copyright � 2012 JeffLieu-lieumychuong@gmail.com
	
	This file is part of SGMII-IP-Core.
    SGMII-IP-Core is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SGMII-IP-Core is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with SGMII-IP-Core.  If not, see <http://www.gnu.org/licenses/>.


File		:
Description	:

Remarks		:

Revision	:
	Date	Author	Description

*/
	

`define cSystemClkPeriod	8

`define cXmitCONFIG		3'b010
`define cXmitIDLE		3'b001
`define cXmitDATA		3'b100

`define D0_0	8'h00
`define D21_5	8'hB5
`define D2_2	8'h42
`define D5_6	8'hC5
`define D16_2	8'h50
`define K28_5	8'hBC
`define K23_7	8'hF7	//R/
`define K27_7	8'hFB	//S/
`define K29_7	8'hFD	//T/
`define K30_7	8'hFE	//V/

`define cReg4Default 	16'h0000
`define cReg0Default	16'h1000
`define cRegXDefault	16'h0003
`define cRegLinkTimerDefault	(10_000_000/8)

`define cLcAbility_FD	16'h0020	
`define cLcAbility_HD	16'h0040	
`define cLcAbility_PS1	16'h0080
`define cLcAbility_PS2	16'h0100
`define cLcAbility_RF1	16'h1000
`define cLcAbility_RF2	16'h2000


	