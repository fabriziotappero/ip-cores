----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:14:05 02/11/2007 
-- Design Name: 
-- Module Name:    alu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.types.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
	port (
		clk: IN std_logic;
		reset: in std_logic;
		alu_op : in std_logic_VECTOR(10 downto 0);
		a: IN slv_32;
		b: IN slv_32;
		s: OUT slv_32
	);
end alu;



architecture Behavioral of alu is

component barrel is
	port (
		--clk: IN std_logic;
		--reset: in std_logic;
		a: IN slv_32;
		b: IN std_logic_vector(5 downto 0);
		s: OUT slv_32
	);
end component;


signal aa: unsigned(31 downto 0);
signal bb: unsigned(31 downto 0);

signal shift_result: slv_32;
signal shift_in: std_logic_vector(5 downto 0);



begin
	
	shift_in(5) <= b(31);
	shift_in(4 downto 0) <= b(4 downto 0);
	cbarrel: barrel
	port map( a => a, b => shift_in, s => shift_result);


	
	aa(31 downto 0) <= unsigned(a);
	bb(31 downto 0) <= unsigned(b);
	
	process (clk, reset)
		variable te: unsigned(31 downto 0) := (others => '0');
	begin
	
		if(reset='0') then
			s <= (others => '0');
		elsif(rising_edge(clk)) then 
	
			case alu_op is
				when "00000000001" => 
					te := aa + bb;
					s <= std_logic_vector(te);
				when "00000000010" => 
					te := aa - bb;
					s <= std_logic_vector(te);
				when "00000000100" => 
					s <= a and b;
				when "00000001000" => 
					s <= a or b;
				when "00000010000" => 
					s <= a xor b;
				when "00000100000" => 
					s <= shift_result;   -- shift
				when "00001000000" => 
					if unsigned(a) < unsigned(b) then
						s <= (0 => '1', others => '0');
					else 
						s <= (others => '0');						
					end if;
				when "00010000000" => 
					if signed(a) < signed(b) then
						s <= (0 => '1', others => '0');
					else 
						s <= (others => '0');						
					end if;
				when "00100000000" => 
					s <= b;
				when "01000000000" => 
					s <= (others => 'X');
				when "10000000000" => 
					s <= (others => 'X');
				when others =>
					s <= (others => 'X');
			end case;
		end if;
	end process;
end Behavioral;

