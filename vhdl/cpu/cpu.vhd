
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:54:11 02/07/2007 
-- Design Name: 
-- Module Name:    test - Behavioral 
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
use UNISIM.Vcomponents.ALL;


entity cpu is
    Port ( clk_in : in STD_LOGIC;
           reset_in : in STD_LOGIC;
			  
			  paddr: out std_logic_VECTOR(9 downto 0);
			  pdin: in slv_16;
			  
			  extrd: out std_logic;
			  extwr: out std_logic;
			  extaddr: out slv_16;			
			  extdout: out slv_16;
			  extdin: in slv_16				  
			);
end cpu;

architecture Behavioral of cpu is


component fetch is
    Port ( clk : in STD_LOGIC;
			  reset : in STD_LOGIC;
			  pc : out slv_32;
			  brzero: in std_logic_vector(2 downto 0);          
			  newpc: in slv_32;  			  
			  testv: in slv_32;	
			  result: in slv_32;
			  fw: in std_logic;
			  fw2_pc: in std_logic;
			  
			  instr : out slv_16;			  
			  
				paddr: out std_logic_VECTOR(9 downto 0);
				pdin: in slv_16  
			);
end component;



component decode
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
  			  pc : in slv_32;
			  brzero: out std_logic_vector(2 downto 0);       
			  newpc: out slv_32;  
			  
			  instr : in slv_16;
--			  instr_out : out slv_16;
			  op1 : out slv_32;
			  fwop1: out std_logic;			  
			  op2 : out slv_32;
  			  fwop2: out std_logic;
  			  fw_pc: out std_logic;

			  fwshiftop: out std_logic;
			  destreg : out std_logic_VECTOR(3 downto 0);
			  
			  regaddr : in std_logic_VECTOR(3 downto 0);
			  result : in slv_32;
			  big_op : out std_logic_VECTOR(15 downto 0)
			);
end component;

component execute
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
end component;

signal pc: slv_32;
signal brzero: std_logic_vector(2 downto 0);        
signal newpc: slv_32;  
			  
signal instrf: slv_16;
--signal instrd: slv_16;

signal op1: slv_32;
signal fwop1: std_logic;
signal op2: slv_32;
signal fwop2: std_logic;
signal fw_pc: std_logic;
signal fwshiftop: std_logic;
signal destreg: std_logic_VECTOR(3 downto 0);

signal big_op : std_logic_VECTOR(15 downto 0);

signal regaddr : std_logic_VECTOR(3 downto 0);
signal result : slv_32;
signal fb_result : slv_32;

signal testv: slv_32;

begin

		  
--	instr <= instr;

testv <= op1;

pipestage1: fetch
	port map( clk => clk_in, reset => reset_in, 
		pc => pc, brzero => brzero, newpc => newpc, testv => testv,
		result => fb_result, fw => fwop1, fw2_pc => fw_pc, 
		instr => instrf,		
		paddr => paddr, pdin => pdin
	);
	
	
pipestage2: decode
	port map( clk => clk_in, reset => reset_in, 
		pc => pc, brzero => brzero, newpc => newpc, 
		instr => instrf, 
		op1 => op1, fwop1 => fwop1, op2 => op2, fwop2 => fwop2, fwshiftop => fwshiftop, fw_pc => fw_pc,
		destreg => destreg, 
		
		result => result, regaddr => regaddr, big_op => big_op 
	);
	
	
pipestage3: execute
	port map( clk => clk_in, reset => reset_in, 
	   op1 => op1, fwop1 => fwop1, op2 => op2, fwop2 => fwop2, fwshiftop => fwshiftop,
	   destreg => destreg, result => result, regaddr => regaddr, big_op => big_op, 
		fb_result => fb_result,
		extrd => extrd,
		extwr => extwr,
		extaddr => extaddr,			
		extdin => extdin,
		extdout => extdout
	);


--process (clk_in, reset_in)
--	begin
--		if (reset_in='0') then 
--		   counter <= (others => '0'); 
--			c <= (others => '0');
--     elsif rising_edge(clk_in) then
--			counter <= counter + 1;
--			c <= std_logic_vector(counter);
--		end if;
--	end process;
	


end Behavioral;
