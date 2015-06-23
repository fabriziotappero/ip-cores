
--
-- Grain datapath, slow and small implementation
--
--
--



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity grain_datapath_slow is
generic (
	DEBUG : boolean := false			-- output debug information
);
port (
	CLK_I : in std_logic;
	CLKEN_I : in std_logic := '1';
	ARESET_I : in std_logic;
	
	KEY_I : in std_logic;
	IV_I  : in std_logic;
								 
	INJECT_INPUT_I : in std_logic;
	PAD_IV_I : in std_logic;
	ADD_OUTPUT_I : in std_logic;
	
	H_O : out std_logic
);
end entity;


architecture behav of grain_datapath_slow is

signal lfsr, nfsr : unsigned(0 to 79);

signal func_h, func_g, func_f : std_logic;
begin
	
	-- outputs:
	H_O <= func_h;

	
	func_h <= 
		nfsr(1) xor nfsr(2) xor nfsr(4) xor nfsr(10) xor nfsr(31) xor nfsr(43) xor nfsr(56) xor
		lfsr(25) xor nfsr(63) xor 
		(lfsr(3) and lfsr(64)) xor 
		(lfsr(46) and lfsr(64)) xor 
		(lfsr(64) and nfsr(63)) xor 
		(lfsr(3) and lfsr(25) and lfsr(46)) xor 
		(lfsr(3) and lfsr(46) and lfsr(64)) xor 
		(lfsr(3) and lfsr(46) and nfsr(63)) xor 
		(lfsr(25) and lfsr(46) and nfsr(63)) xor 
		(lfsr(46) and lfsr(64)and nfsr(63));


	func_g <=
		lfsr(0) xor 
		nfsr(62) xor nfsr(60) xor nfsr(52) xor nfsr(45) xor nfsr(37) xor nfsr(33) xor nfsr(28) xor nfsr(21) xor nfsr(14) xor nfsr(9) xor nfsr(0) xor
		(nfsr(63) and nfsr(60)) xor  
		(nfsr(37) and nfsr(33)) xor  
		(nfsr(15) and nfsr(9)) xor 
		(nfsr(60) and nfsr(52) and nfsr(45)) xor  
		(nfsr(33) and nfsr(28) and nfsr(21)) xor  
		(nfsr(63) and nfsr(45) and nfsr(28) and nfsr(9)) xor 
		(nfsr(60) and nfsr(52) and nfsr(37) and nfsr(33)) xor  
		(nfsr(63) and nfsr(60) and nfsr(21) and nfsr(15)) xor 
		(nfsr(63) and nfsr(60) and nfsr(52) and nfsr(45) and nfsr(37)) xor  
		(nfsr(33) and nfsr(28) and nfsr(21) and nfsr(15) and nfsr(9)) xor 
		(nfsr(52) and nfsr(45) and nfsr(37) and nfsr(33) and nfsr(28) and nfsr(21));
	 	
	func_f <= 
		lfsr(62) xor lfsr(51) xor lfsr(38) xor lfsr(23) xor lfsr(13) xor lfsr(0);
	
	
	

	-- the shift registers:
	sr_proc : process(CLK_I)
	begin
		if rising_edge(CLK_I) then
			if CLKEN_I = '1' then
				lfsr <= lfsr sll 1;
				nfsr <= nfsr sll 1;
				
				if INJECT_INPUT_I = '1' then
					lfsr(79) <= IV_I or PAD_IV_I;
					nfsr(79) <= KEY_I;
				else
					
					lfsr(79) <= func_f xor (ADD_OUTPUT_I and func_h);
					nfsr(79) <= func_g xor (ADD_OUTPUT_I and func_h);
					
				end if;
			end if;
		end if;
	end process;

end behav;

