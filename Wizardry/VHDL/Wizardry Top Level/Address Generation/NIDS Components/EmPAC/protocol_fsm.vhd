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
-- Module Name: protocol_fsm - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Contains FSM that classifies the phy data, providing a corresponding 
-- field identifier called "field_type".  This is the "brains" of EmPAC.
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.empac_constants.all;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity protocol_fsm is
port(clock : in std_logic;
	  reset : in std_logic;
	  EmPAC_leds : out std_logic_vector(8 downto 0);
	  phy_data_valid : in std_logic;
	  field_data_early : in std_logic_vector(31 downto 0);
	  opt : in std_logic;
	  length1 : in std_logic_vector(17 downto 0);--teger;
	  TCP_type : in std_logic;
	  UDP_type : in std_logic;
	  icmp_type : in std_logic;
	  protocol_ind : out std_logic;
	  length_ind : out std_logic;
	  port_ind : out std_logic;
	  field_type_out : out std_logic_vector(7 downto 0);
	  field_type_early : out std_logic_vector(7 downto 0);
	  data_ready : out std_logic;
	  field_data : out std_logic_vector(31 downto 0);
	  end_of_frame : out std_logic);
end protocol_fsm;

architecture Behavioral of protocol_fsm is

signal CurrentState,NextState : StateType;
--signal data_tmp : std_logic_vector(31 downto 0);
signal field_width : std_logic_vector(1 downto 0);
signal length_s : integer;
signal fw : integer;
signal count : integer;
signal vlf : std_logic;
signal field_data_s : std_logic_Vector(31 downto 0);
signal data_ready_off : std_logic;
signal rst : std_logic;
signal data_ready_s : std_logic;
signal phy_data_valid_reg : std_logic;
signal field_type : std_logic_vector(7 downto 0);

begin
field_type_early <= field_type;
fw <= conv_integer(field_width);
length_s <= conv_integer(length1-1);
----data_tmp <= field_data_early;
--data_ready <= data_ready_s or vlf;
process(clock)
begin
	if rising_edge(clock) then
		field_type_out <= field_type;
	end if;
end process;

process(clock)
begin
	if rising_edge(clock) then
		field_data <= field_data_s;
	end if;
end process;

process(clock)
begin
	if rising_edge(clock) then
		phy_data_valid_reg <= phy_data_valid;
	end if;
end process;

--cnt : process(reset,clock,fw,length_s,rst)
--begin
----if reset = '1' then
----	count <= 0;
--if rising_edge(clock) then
--	if reset = '1' then
--		count <= 0;
--	else
--		if rst = '1' then
--			count <= 0;
--		elsif vlf = '1' then
--			if (count = length_s)then-- - 1) then-- or (count = fw)) then
--				count <= 0;
--			else
--				count <= count + 1;
--			end if;
--		else
--			if (count = fw) then
--				count <= 0;
--	--			data_ready <= '1';
--			else
--				count <= count + 1;
--	--			data_ready <= '0';
--			end if;
--		end if;
--	end if;
--end if;
--end process;
cnt : process(reset,clock,fw,length_s,phy_data_valid,vlf,count)
begin
--if reset = '1' then
--	count <= 0;
if rising_edge(clock) then
	if reset = '1' then
		count <= 0;
	else
		if phy_data_valid = '1' then
			if vlf = '1' then
				if (count = length_s) then
					count <= 0;
				else
					count <= count + 1;
				end if;
			elsif (count = fw) then
				count <= 0;
			else
				count <= count + 1;
			end if;
		else
			count <= 0;
		end if;
	end if;
end if;
end process;

process(clock,reset,vlf,data_ready_off,fw,count)
begin
	if rising_edge(clock) then
		if reset = '1' then
			data_ready <= '0';
		else
			if data_ready_off = '1' then
				data_ready <= '0';
			elsif vlf = '1' then
				data_ready <= '1';
			elsif count = fw then
				data_ready <= '1';
			else
				data_ready <= '0';
			end if;
		end if;
	end if;
end process;

--process(count,clock,vlf,reset,fw,data_ready_off,length_s)
--variable  cnt_v : integer := 0;
--begin
--	if rising_edge(clock) then
--		if reset = '1' then
--			data_ready_s <= '0';
--			cnt_v := 0;
--		else--if rising_edge(clock) then
--			if data_ready_off = '1' then
--				data_ready_s <= '0';
--				cnt_v := 0;
--			elsif vlf = '1' then
--				if cnt_v = 3 then
--					cnt_v := 0;
--					data_ready_s <= '1';
--				elsif count = length_s then--conv_integer(length1_s) then--cnt_v = conv_integer(length1) then -- -1) then
--					data_ready_s <= '1';
--				else
--					data_ready_s <= '0';
--					cnt_v := cnt_v + 1;
--				end if;
--			else
--				if  count = fw then -- -1 then
--					data_ready_s <= '1';
--				else
--					data_ready_s <= '0';
--				end if;
--			end if;
--		end if;
--	end if;
--end process;

--process(clock)
--begin
----wait until clock'event and clock = '1';
--	if rising_edge(clock) then
--		field_data <= field_data_s;
--	end if;
--end process;

fsm : process(CurrentState,phy_data_valid,phy_data_valid_reg,count,field_data_early,TCP_type,UDP_type,opt,length_s,icmp_type)--,field_data_early)
begin
	case CurrentState is
		when ftreset =>
				if phy_data_valid = '1' then 
					NextState <= ft2;
				else 
					NextState <= ftreset;
				end if;
				field_width <= "11";
--				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= "00000000000000000000000000000000";--field_data_early;
				field_type <= X"00";
				data_ready_off <= '1';
				rst <= '1';
				EmPAC_leds <= "110000000";
				end_of_frame <= '1';
		       
--		when ft0 =>
--				if count = 3 then
--					NextState <= ft1;
--				else
--					NextState <= ft0;
--				end if;
--				field_width <= "11";
----				 
--				protocol_ind <= '0';
--				length_ind <= '0';
--				port_ind <= '0';
--				vlf <= '0';
--				field_data_s <= field_data_early;
--				field_type <= X"00";
--		      data_ready_off <= '0';
--				EmPAC_leds <= "000000000";
--		when ft1 =>
--				if count = 3 then
--					NextState <= ft2;
--				else
--					NextState <= ft1;
--				end if;
--				field_width <= "11";
----				 
--				protocol_ind <= '0';
--				length_ind <= '0';
--				port_ind <= '0';
--				vlf <= '0';
--				field_data_s <= field_data_early;
--				field_type <= X"01";
--		      data_ready_off <= '0';
--				EmPAC_leds <= "000000001";
				
		when ft2 =>
				if count = 3 then
					NextState <= ft3;
				else
					NextState <= ft2;
				end if;
				field_width <= "11";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
				field_type <= X"02";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000000010";
				end_of_frame <= '0';
		      
		when ft3 =>
				if count = 1 then
					NextState <= ft4;
				else
					NextState <= ft3;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
				field_type <= X"03";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000000011";
				end_of_frame <= '0';
				
		when ft4 =>
				if count = 3 then
					NextState <= ft5;
				else
					NextState <= ft4;
				end if;
				field_width <= "11";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
				field_type <= X"04";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000000100";
				end_of_frame <= '0';
				
		when ft5 =>
				if count = 1 then
					NextState <= ft6;
				else
					NextState <= ft5;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
				field_type <= X"05";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000000101";
				end_of_frame <= '0';
				
		when ft6 =>
--			if count = 1 then
				if count = 1 and field_data_early(15 downto 0) = X"0800" then
					NextState <= ft19;
				elsif count = 1 and field_data_early(15 downto 0) = X"86DD" then
					NextState <= ft33;
				elsif count = 1 and field_data_early(15 downto 0) = X"0806" then
					NextState <= ft7;
				elsif count = 1 then
					NextState <= unknown_protocol;
				elsif count = 0 then
					NextState <= ft6;
				else
					NextState <= ft6;
				end if;
--			end if;
			field_width <= "01";
			protocol_ind <= '1';
			length_ind <= '0';
			port_ind <= '0';
			vlf <= '0';
			field_data_s <= X"0000" & field_data_early(15 downto 0);
         field_type <= X"06";
		   data_ready_off <= '0';
			rst <= '0';
			EmPAC_leds <= "000000110";
			end_of_frame <= '0';
				   		
		when ft7 =>
				if count = 1 then
					NextState <= ft8;
				else
					NextState <= ft7;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"07";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000000111";
				end_of_frame <= '0';
				
		when ft8 =>
				if count = 1 then
					NextState <= ft9;
				else
					NextState <= ft8;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"08";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000001000";
				end_of_frame <= '0';
				   
		when ft9 =>
				if count = 0 then
					NextState <= ftA;
				else
					NextState <= ft9;
				end if;
				field_width <= "00";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"000000" & field_data_early(7 downto 0);
		      field_type <= X"09";
		      data_ready_off <= '0';
				rst <= '0';
				 EmPAC_leds <= "000001001";
				end_of_frame <= '0';
		when ftA =>
				if count = 0 then
					NextState <= ftB;
				else
					NextState <= ftA;
				end if;
				field_width <= "00";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"000000" & field_data_early(7 downto 0);
		      field_type <= X"0A";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000001010";
				end_of_frame <= '0';
				
		when ftB =>
				if count = 1 then
					NextState <= ft_C;
				else
					NextState <= ftB;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"0B";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000001011";
				end_of_frame <= '0';
				
		when ft_C  =>
				if count = 3 then
					NextState <= ftD;
				else
					NextState <= ft_C;
				end if;
				field_width <= "11";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
		      field_type <= X"0C";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000001100";
				end_of_frame <= '0';
				
		when ftD =>
				if count = 1 then
					NextState <= ftE;
				else
					NextState <= ftD;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"0D";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000001101";
				end_of_frame <= '0';
				
		when ftE =>
				if count = 3 then
					NextState <= ftF;
				else
					NextState <= ftE;
				end if;
				field_width <= "11";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
		      field_type <= X"0E";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000001110";
				end_of_frame <= '0';
				
		when ftF =>
				if count = 3 then
					NextState <= ft10;
				else
					NextState <= ftF;
				end if;
				field_width <= "11";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
		      field_type <= X"0F";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000001111";
				end_of_frame <= '0';
				
		when ft10 =>
				if count = 1 then
					NextState <= ft11;
				else
					NextState <= ft10;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"10";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000010000";
				end_of_frame <= '0';
				
		when ft11 =>
				if count = 3 then
					NextState <= ft12;
				else
					NextState <= ft11;
				end if;
				field_width <= "11";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
		      field_type <= X"11";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000010001";
				end_of_frame <= '0';
				
		when ft12 =>
				if count = 3 then
					NextState <= ft13;
				else
					NextState <= ft12;
				end if;
				field_width <= "11";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
		      field_type <= X"12";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000010010";
				end_of_frame <= '0';
				
		when ft13 =>
				if count = 3 then
					NextState <= ft14;
				else
					NextState <= ft13;
				end if;
				field_width <= "11";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
		      field_type <= X"13";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000010011";
				end_of_frame <= '0';
				
		when ft14 =>
				if count = 3 then
					NextState <= ft15;
				else
					NextState <= ft14;
				end if;
				field_width <= "11";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
		      field_type <= X"14";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000010100";
				end_of_frame <= '0';
				
		when ft15 =>
				if count = 3 then
					NextState <= ft16;
				else
					NextState <= ft15;
				end if;
				field_width <= "11";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
		      field_type <= X"15";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000010101";
				end_of_frame <= '0';
				
		when ft16 =>
				if count = 1 then
					NextState <= ft17;
				else
					NextState <= ft16;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"16";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000010110";
				end_of_frame <= '0';
				
		when ft17 =>
				if count = 3 then
					NextState <= ft18;
				else
					NextState <= ft17;
				end if;
				field_width <= "11";
				 
				protocol_ind <= '0';
				length_ind <= '1';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
		      field_type <= X"17";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000010111";
				end_of_frame <= '0';
		when ft18 =>
--				if phy_data_valid = '0' then
					NextState <= ftreset;
--				elsif count = 0 then
--					NextState <= ft2;
--				else
--					NextState <= ft18;
--				end if;
				field_width <= "00";
				--branch_ind <= '1';
				protocol_ind <= '1';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"000000" & field_data_early(7 downto 0);
		      field_type <= X"18";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000011000";
				end_of_frame <= '0';
				
		when ft19 =>
				if count = 0 then
					NextState <= ft1A;
				else
					NextState <= ft19;
				end if;
				field_width <= "00";
				 
				protocol_ind <= '0';
				length_ind <= '1';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"000000" & field_data_early(7 downto 0);
		      field_type <= X"19";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000011001";
				end_of_frame <= '0';
				
		when ft1A =>
				if count = 0 then
					NextState <= ft1B;
				else
					NextState <= ft1A;
				end if;
				field_width <= "00";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"000000" & field_data_early(7 downto 0);
		      field_type <= X"1A";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000011010";
				end_of_frame <= '0';
				
		when ft1B =>
				if count = 1 then
					NextState <= ft1C;
				else
					NextState <= ft1B;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '1';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"1B";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000011011";
				end_of_frame <= '0';
				
		when ft1C =>
				if count = 1 then
					NextState <= ft1D;
				else
					NextState <= ft1C;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"1C";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000011100";
				end_of_frame <= '0';
				
		when ft1D =>
				if count = 1 then
					NextState <= ft1E;
				else
					NextState <= ft1D;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"1D";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000011101";
				end_of_frame <= '0';
				
		when ft1E =>
				if count = 0 then
					NextState <= ft1F;
				else
					NextState <= ft1E;
				end if;
				field_width <= "00";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"000000" & field_data_early(7 downto 0);
		      field_type <= X"1E";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000011110";
				end_of_frame <= '0';
				
		when ft1F =>
				if count = 0 then
					NextState <= ft20;
				else
					NextState <= ft1F;
				end if;
				field_width <= "00";
				 
				protocol_ind <= '1';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"000000" & field_data_early(7 downto 0);
		      field_type <= X"1F";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000011111";
				end_of_frame <= '0';
				
		when ft20 =>
				if count = 1 then
					NextState <= ft21;
				else
					NextState <= ft20;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"20";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000100000";
				end_of_frame <= '0';
				
		when ft21 =>
				if count = 3 then
					NextState <= ft22;
				else
					NextState <= ft21;
				end if;
				field_width <= "11";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
		      field_type <= X"21";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000100001";
				end_of_frame <= '0';
				
		when ft22 =>
--				if (count = 3 and opt = '1') then
----					if opt = '1' then--IPv4_header_len > "000000000000010100" then
--						NextState <= ft23;
--					elsif (count = 3 and TCP_type = '1') then--field_data_early(15 downto 0) = X"06" then--protocol_type = X"06" then
--						NextState <= ft24;
--					elsif (count = 3 and UDP_type = '1') then--field_data_early(15 downto 0) = X"11" then --protocol_type = X"11" then
--						NextState <= ft2E;
--					elsif (count = 3 and opt='0' and TCP_type = '0' and UDP_type = '0') then
--						NextState <=  unknown_protocol;
----					end if;
--				else
--					NextState <= ft22;
--				end if;
				if (count = 3) then
					if (opt = '1') then
						NextState <= ft23;
					elsif (TCP_type = '1') then
						NextState <= ft24;
					elsif (UDP_type = '1') then
						NextState <= ft2E;
					elsif (ICMP_type =  '1') then
						Nextstate <= icmp_protocol;
					else --if ((opt = '0') and (TCP_type = '0') and (UDP_type = '0') ) then
						NextState <= unknown_protocol;
					end if;
				else
					NextState <= ft22;
				end if;
				field_width <= "11";
				--branch_ind <= '1';
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
		      field_type <= X"22";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000100010";
				end_of_frame <= '0';
				
		when ft23 =>
				if (count = length_s)then---1) then
					NextState <= ft17;
				else
					NextState <= ft23;
				end if;
				field_width <= "XX";
				--branch_ind <= '1';
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '1';
				field_data_s <= field_data_early;
		      field_type <= X"23";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000100011";
				end_of_frame <= '0';
				
		when ft24 =>
				if count = 1 then
					NextState <= ft25;
				else
					NextState <= ft24;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '1';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"24";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000100100";
				end_of_frame <= '0';
				
		when ft25 =>
				if count = 1 then
					NextState <= ft26;
				else
					NextState <= ft25;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '1';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"25";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000100101";
				end_of_frame <= '0';
				
		when ft26 =>
				if count = 3 then
					NextState <= ft27;
				else
					NextState <= ft26;
				end if;
				field_width <= "11";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
		      field_type <= X"26";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000100110";
				end_of_frame <= '0';
				
		when ft27 =>
				if count = 3 then
					NextState <= ft28;
				else
					NextState <= ft27;
				end if;
				field_width <= "11";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
		      field_type <= X"27";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000100111";
				end_of_frame <= '0';
				
		when ft28 =>
				if count = 1 then
					NextState <= ft29;
				else
					NextState <= ft28;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '1';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"28";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000101000";
				end_of_frame <= '0';
				
		when ft29 =>
				if count = 1 then
					NextState <= ft2A;
				else
					NextState <= ft29;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"29";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000101001";
				end_of_frame <= '0';
				
		when ft2A =>
				if count = 1 then
					NextState <= ft2B;
				else
					NextState <= ft2A;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"2A";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000101010";
				end_of_frame <= '0';
				
		when ft2B =>
				if count = 1 and opt = '1' then
					--if opt = '1' then
						NextState <= ft2C;
				elsif count = 1 and opt = '0' then
						NextState <= ft2D;
--					end if;
				else
					NextState <= ft2B;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"2B";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000101011";
				end_of_frame <= '0';
				
		when ft2C =>
				if (count = length_s)then---1 then
					NextState <= ft17;
				else
					NextState <= ft2C;
				end if;
				field_width <= "XX";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '1';
				field_data_s <= field_data_early;
		      field_type <= X"2C";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000101100";
				end_of_frame <= '0';
				
		when ft2D =>
				if (count = length_s)then-- - 1 then
					NextState <= ft17;
				else
					NextState <= ft2D;
				end if;
				field_width <= "XX";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '1';
				field_data_s <= field_data_early;
		      field_type <= X"2D";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000101101";
				end_of_frame <= '0';
				
		when ft2E =>
				if count = 1 then
					NextState <= ft2F;
				else
					NextState <= ft2E;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '1';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"2E";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000101110";
				end_of_frame <= '0';
		when ft2F =>
				if count = 1 then
					NextState <= ft30;
				else
					NextState <= ft2F;
				end if;
				field_width <= "01";
				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '1';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"2F";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000101111";
				end_of_frame <= '0';
				
		when ft30 =>
				if count = 1 then
					NextState <= ft31;
				else
					NextState <= ft30;
				end if;
				field_width <= "01";
--				 
				protocol_ind <= '0';
				length_ind <= '1';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"30";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000110000";
				end_of_frame <= '0';
				
		when ft31 =>
				if count = 1 then
					NextState <= ft32;
				else
					NextState <= ft31;
				end if;
				field_width <= "01";
--				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
		      field_type <= X"31";
		      data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000110001";
				end_of_frame <= '0';
				
		when ft32 =>
				if (count = length_s)then-- -1 then
					NextState <= ft17;
				else
					NextState <= ft32;
				end if;
				field_width <= "XX";
--				 
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '1';
				field_data_s <= field_data_early;
		      field_type <= X"32";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000110010";
				end_of_frame <= '0';
				
		when ft33 =>
				if count = 0 then 
					NextState <= ft34;
				else
					NextState <= ft33;
				end if;
				field_width <= "00";
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
				field_type <= X"33";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000110011";
				end_of_frame <= '0';
				
		when ft34 =>
				if count = 0 then 
					NextState <= ft35;
				else
					NextState <= ft34;
				end if;
				field_width <= "00";
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
				field_type <= X"34";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000110100";
				end_of_frame <= '0';
				
		when ft35 =>
				if count = 1 then 
					NextState <= ft36;
				else
					NextState <= ft35;
				end if;
				field_width <= "01";
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
				field_type <= X"35";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000110101";
				end_of_frame <= '0';
		
		when ft36 =>
				if count = 1 then 
					NextState <= ft37;
				else
					NextState <= ft36;
				end if;
				field_width <= "01";
				protocol_ind <= '0';
				length_ind <= '1';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"0000" & field_data_early(15 downto 0);
				field_type <= X"36";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000110110";
				end_of_frame <= '0';
				
		when ft37 =>
				if count = 0 then 
					NextState <= ft38;
				else
					NextState <= ft37;
				end if;
				field_width <= "00";
				protocol_ind <= '1';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= X"000000" & field_data_early(7 downto 0);
				field_type <= X"37";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000110111";
				end_of_frame <= '0';
				
		when ft38 =>
				if count = 0 then 
					NextState <= ft39;
				else
					NextState <= ft38;
				end if;
				field_width <= "00";
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
				field_type <= X"38";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000111000";
				end_of_frame <= '0';
				
		when ft39 =>
				if count = 3 then 
					NextState <= ft3A;
				else
					NextState <= ft39;
				end if;
				field_width <= "11";
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
				field_type <= X"39";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000111001";
				end_of_frame <= '0';
				
		when ft3A =>
				if count = 3 then 
					NextState <= ft3B;
				else
					NextState <= ft3A;
				end if;
				field_width <= "11";
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
				field_type <= X"3A";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000111010";
				end_of_frame <= '0';
				
		when ft3B =>
				if count = 3 then 
					NextState <= ft3C;
				else
					NextState <= ft3B;
				end if;
				field_width <= "11";
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
				field_type <= X"3B";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000111011";
				end_of_frame <= '0';
				
		when ft3C =>
				if count = 3 then 
					NextState <= ft3D;
				else
					NextState <= ft3C;
				end if;
				field_width <= "11";
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
				field_type <= X"3C";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000111100";
				end_of_frame <= '0';
				
		when ft3D =>
				if count = 3 then 
					NextState <= ft3E;
				else
					NextState <= ft3D;
				end if;
				field_width <= "11";
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
				field_type <= X"3D";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000111101";
				end_of_frame <= '0';
				
		when ft3E =>
				if count = 3 then 
					NextState <= ft3F;
				else
					NextState <= ft3E;
				end if;
				field_width <= "11";
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
				field_type <= X"3E";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000111110";
				end_of_frame <= '0';
				
		when ft3F =>
				if count = 3 then 
					NextState <= ft40;
				else
					NextState <= ft3F;
				end if;
				field_width <= "11";
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
				field_type <= X"3F";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "000111111";
				end_of_frame <= '0';
				
---------------------------------------------------------------------------------------------------		
		when ft40 =>
				if count = 3 and opt = '1' then
--					if opt = '1' then--IPv4_header_len > "000000000000010100" then
						NextState <= ft41;
					elsif count = 3 and TCP_type = '1' then--field_data_early(15 downto 0) = X"06" then--protocol_type = X"06" then
						NextState <= ft24;
					elsif count = 3 and UDP_type = '1' then--field_data_early(15 downto 0) = X"11" then --protocol_type = X"11" then
						NextState <= ft2E;
					elsif count = 3 and opt='0' and TCP_type = '0' and UDP_type = '0' then
						NextState <=  unknown_protocol;
--					end if;
				else
					NextState <= ft40;
				end if;
				field_width <= "11";
				protocol_ind <= '0';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '0';
				field_data_s <= field_data_early;
				field_type <= X"40";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "001000000";
				end_of_frame <= '0';
				
--------------------------------------------------------------------------------------------------				
		
		when ft41 =>
				if (count = length_s) then-- -1 then
					NextState <= ft17;
				else
					NextState <= ft41;
				end if;
				field_width <= "XX";
				protocol_ind <= '1';
				length_ind <= '0';
				port_ind <= '0';
				vlf <= '1';
				field_data_s <= field_data_early;
				field_type <= X"41";
				data_ready_off <= '0';
				rst <= '0';
				EmPAC_leds <= "001000001";
				end_of_frame <= '0';
				
		when unknown_protocol =>
			if phy_data_valid = '0' then---was if phy_data_valid_reg = 0
				NextState <= ftreset;
			else 
				NextState <= unknown_protocol;
			end if;
			field_width <= "XX";
			protocol_ind <= '0';
			length_ind <= '0';
			port_ind <= '0';
			vlf <= '1';
			field_data_s <= field_data_early;
			field_type <= X"42";
			data_ready_off <= '0';
			rst <= '0';
			EmPAC_leds <= "001000010";
			end_of_frame <= '0';
		
		when icmp_protocol =>
--			if phy_data_valid = '0' then---was if phy_data_valid_reg = 0
--				NextState <= ftreset;
--			else 
				NextState <= unknown_protocol;
--			end if;
			field_width <= "XX";
			protocol_ind <= '0';
			length_ind <= '0';
			port_ind <= '0';
			vlf <= '1';
			field_data_s <= field_data_early;
			field_type <= X"43";
			data_ready_off <= '0';
			rst <= '0';
			EmPAC_leds <= "001000010";
			end_of_frame <= '0';
			
		when others =>
			NextState <= unknown_protocol;
			field_width <= "XX";
--			 
			protocol_ind <= '0';
			length_ind <= '0';
			port_ind <= '0';
			vlf <= '0';
			field_data_s <= X"00000000";
			field_type <= "XXXXXXXX";
			data_ready_off <= '0';
			rst <= '0';
			EmPAC_leds <= "001000011";
			end_of_frame <= '0';
						
	end case;
end process;

nxt_state_logic:process(clock,reset)--(clock,reset)
begin
	if rising_Edge(clock) then
		if reset = '1' then
			currentstate <= ftreset;
		else
			currentstate <= nextstate;
		end if;
	end if;
end process;

end Behavioral;

