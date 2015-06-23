
--
-- Grain128 datapath, slow and small implementation
--
--
--



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity grain128_datapath_slow is
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


architecture behav of grain128_datapath_slow is

signal lfsr, nfsr : unsigned(0 to 127);

signal func_h, func_g, func_f : std_logic;
begin
	
	-- outputs:
	H_O <= func_h;

	-- copy pasted from grain128.c from Hell	
	func_h <= 
		nfsr(2) xor nfsr(15) xor nfsr(36) xor nfsr(45) xor nfsr(64) xor nfsr(73) 
		xor nfsr(89) xor lfsr(93) xor (nfsr(12) and lfsr(8)) xor (lfsr(13) and lfsr(20)) 
		xor (nfsr(95) and lfsr(42)) xor (lfsr(60) and lfsr(79)) 
		xor (nfsr(12) and nfsr(95) and lfsr(95));

	func_g <=
		lfsr(0) xor nfsr(0) xor nfsr(26) xor nfsr(56) xor nfsr(91) xor nfsr(96) 
		xor (nfsr(3) and nfsr(67)) xor (nfsr(11) and nfsr(13)) xor (nfsr(17) and nfsr(18)) 
		xor (nfsr(27) and nfsr(59)) xor (nfsr(40) and nfsr(48)) xor (nfsr(61) and nfsr(65)) 
		xor (nfsr(68) and nfsr(84));
	 	
	func_f <=
		lfsr(0) xor lfsr(7) xor lfsr(38) xor lfsr(70) xor lfsr(81) xor lfsr(96);	
	
	

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

