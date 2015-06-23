
--
-- Grain128 datapath, faster but larger implementation
--
--
--



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity grain128_datapath_fast is
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


architecture behav of grain128_datapath_fast is


-- On Altera devices, this will make things bigger but also faster
-- by stopping Quartus from using memories instead of shift registers
-- (since Altera lacks SLR16 primitives, puh!)
attribute altera_attribute : string;
attribute altera_attribute of behav : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF";

signal lfsr, nfsr : unsigned(0 to 127);
signal func_h, func_g, func_f : std_logic;
																									 

signal tmp1, tmp2, tmp3, tmp4, tmp5 : std_logic;		

begin
	
	-- outputs:
	H_O <= func_h;

	
		
	
			
	-- register balancing:
	-- usualy, you can (should) leave this to the 
	-- synthesizer which does a much better job	
	
	func_h <= tmp1 xor tmp2;		
	func_g <= tmp3 xor tmp4;		
	func_f <= tmp5;
	
	
	retime_proc: process(CLK_I)
	begin
		if rising_edge(CLK_I) then
			if CLKEN_I = '1' then
				tmp1 <= nfsr(37) xor nfsr(46) xor nfsr(65) xor nfsr(74) xor nfsr(90) xor lfsr(94) xor (nfsr(13) and lfsr(9)) xor (lfsr(14) and lfsr(21));
				tmp2 <= nfsr(3) xor nfsr(16) xor (nfsr(96) and lfsr(43)) xor (lfsr(61) and lfsr(80)) xor (nfsr(13) and nfsr(96) and lfsr(96));
						
				tmp3 <= nfsr(27) xor nfsr(57) xor nfsr(92) xor nfsr(97) xor (nfsr(4) and nfsr(68)) xor (nfsr(12) and nfsr(14)) xor (nfsr(18) and nfsr(19));
				tmp4 <= lfsr(1) xor nfsr(1) xor (nfsr(28) and nfsr(60)) xor (nfsr(41) and nfsr(49)) xor (nfsr(62) and nfsr(66))  xor (nfsr(69) and nfsr(85));
				
				tmp5 <= lfsr(1) xor lfsr(8) xor lfsr(39) xor lfsr(71) xor lfsr(82) xor lfsr(97);		
			end if;
		end if;
	end process;			



	-- the shift registers:
	sr_proc : process(CLK_I)
	begin
		if rising_edge(CLK_I) then
			if CLKEN_I = '1' then
				lfsr <= lfsr sll 1;
				nfsr <= nfsr sll 1;
				
				if INJECT_INPUT_I = '1' then
					lfsr(127) <= IV_I or PAD_IV_I;
					nfsr(127) <= KEY_I;
				else
					
					lfsr(127) <= func_f xor (ADD_OUTPUT_I and func_h);
					nfsr(127) <= func_g xor (ADD_OUTPUT_I and func_h);
					
				end if;
			end if;
		end if;
	end process;

end behav;




