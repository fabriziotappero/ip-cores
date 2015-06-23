----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:32:09 02/11/2007 
-- Design Name: 
-- Module Name:    execute - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;

entity execute is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
			  big_op : in std_logic_VECTOR(15 downto 0);
			  op1 : in slv_32;
			  fwop1: in std_logic;			  
			  op2 : in slv_32;
  			  fwop2: in std_logic;	
           fwshiftop: in std_logic;
			  
			  destreg : in std_logic_VECTOR(3 downto 0);
			  regaddr : out std_logic_VECTOR(3 downto 0);
			  result : out slv_32;
			  fb_result : out slv_32;
			  
			  extrd: out std_logic;
			  extwr: out std_logic;
			  extaddr: out slv_16;			
			  extdin: in slv_16;
			  extdout: out slv_16
			);
end execute;

architecture Behavioral of execute is

component dmem
	port (
		addr: IN std_logic_VECTOR(9 downto 0);
		clk: IN std_logic;
		din: IN std_logic_VECTOR(31 downto 0);
		dout: OUT std_logic_VECTOR(31 downto 0);
		we: IN std_logic
	);
end component;

component alu is
	port (
		clk: IN std_logic;
		reset: in std_logic;
		alu_op : in std_logic_VECTOR(10 downto 0);
		a: IN slv_32;
		b: IN slv_32;
		s: OUT slv_32
	);
end component;


signal ain: slv_32;
signal bin: slv_32;
signal r: slv_32;
signal selected_r: slv_32;
signal feedback_r: slv_32;


signal memr: slv_32;
signal extr: slv_32;

signal wasmem: std_logic;
signal wasext: std_logic;


begin


cdmem: dmem 
	port map( clk => clk, addr => ain(9 downto 0), dout => memr, din => bin, we => big_op(12));
calu: alu
	port map( clk => clk, reset => reset, alu_op => big_op(10 downto 0), a => ain, b => bin, s => r);

	extr(15 downto 0) <= extdin;
	extr(31 downto 16) <= (others => '0');

	-- forward result
	process (extr, r, memr, fwop1, fwop2, fwshiftop, selected_r, feedback_r, op2, op1, extdin, wasmem, wasext)
	begin
		if (wasext = '1') then selected_r <= extr;
		elsif (wasmem = '1') then selected_r <= memr;
--		elsif (needain = '1') then selected_r <= oldain;
		else selected_r <= r(31 downto 0);
		end if;

--		if (needain = '1') then feedback_r <= oldain;
		feedback_r <= r(31 downto 0);
--		end if;
		

		if (fwop2='1') then ain <= feedback_r(31 downto 0);
		elsif (fwshiftop='1') then 
			ain(31 downto 8) <= feedback_r(23 downto 0);
			ain(7 downto 0) <= (others => '0');
		else
			ain <= op2;
		end if;
		
		if (fwop1='1') then bin <= feedback_r(31 downto 0);
		else bin <= op1; end if;
  end process;

	
	extrd <= big_op(13);
	extwr <= big_op(11);
	extaddr <= ain(15 downto 0);
	extdout <= bin(15 downto 0);
	
	result <= selected_r;
	fb_result <= feedback_r;

	process (clk, reset)
	begin
		if (reset='0') then 
		   regaddr <= (others => '0');
			wasmem <= '0';
			wasext <= '0';
		elsif(rising_edge(clk)) then
			regaddr <= destreg;
			wasmem <= big_op(14);
			wasext <= big_op(13);
		end if;
	end process;
end Behavioral;

