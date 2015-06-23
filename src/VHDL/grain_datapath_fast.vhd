
--
-- Grain datapath, faster but larger implementation
--
--
--



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity grain_datapath_fast is
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


architecture behav of grain_datapath_fast is


-- On Altera devices, this will make things bigger but also faster
-- by stopping Quartus from using memories instead of shift registers
-- (since Altera lacks SLR16 primitives, puh!)
attribute altera_attribute : string;
attribute altera_attribute of behav : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF";

signal lfsr, nfsr : unsigned(0 to 79);

signal func_h, func_g, func_f : std_logic;
																									 

signal tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7 : std_logic;		

begin
	
	-- outputs:
	H_O <= func_h;

	
		
	
			
	-- register balancing:
	-- 
	-- this is just a dumb example I made up, you should instead
	-- use your synthesizer which does a much better job!
	-- 
	func_h <= tmp1 xor tmp2;		
	func_g <= tmp3 xor tmp4 xor tmp5 xor tmp6;		
	func_f <= tmp7;
	
	
	retime_proc: process(CLK_I)
		variable nfsr_e, lfsr_e : unsigned(0 to 79);
	begin
		if rising_edge(CLK_I) then
			if CLKEN_I = '1' then
				nfsr_e := nfsr sll 1;
				lfsr_e := lfsr sll 1;
				
				-- H (well, Z really)
				tmp1 <= 
					nfsr_e(1) xor nfsr_e(2) xor nfsr_e(4) xor nfsr_e(10) xor nfsr_e(31) xor nfsr_e(43) xor nfsr_e(56) xor
					lfsr_e(25) xor nfsr_e(63);
				
				tmp2 <= 
					(lfsr_e(3) and lfsr_e(64)) xor
					(lfsr_e(46) and lfsr_e(64)) xor 
					(lfsr_e(64) and nfsr_e(63)) xor 
					(lfsr_e(3) and lfsr_e(25) and lfsr_e(46)) xor 
					(lfsr_e(3) and lfsr_e(46) and lfsr_e(64)) xor 
					(lfsr_e(3) and lfsr_e(46) and nfsr_e(63)) xor 
					(lfsr_e(25) and lfsr_e(46) and nfsr_e(63)) xor 
					(lfsr_e(46) and lfsr_e(64) and nfsr_e(63));
	
				
				-- G
				tmp3 <= 
					lfsr_e(0) xor nfsr_e(37) xor 
					nfsr_e(33) xor nfsr_e(28) xor nfsr_e(21) xor nfsr_e(14) xor nfsr_e(9) xor nfsr_e(0);
			
			
				tmp4 <= 					
					(nfsr_e(63) and nfsr_e(60)) xor (nfsr_e(37) and nfsr_e(33)) xor  
					(nfsr_e(15) and nfsr_e(9)) xor 
					(nfsr_e(60) and nfsr_e(52) and nfsr_e(45));
				
				tmp5<= 					
					(nfsr_e(33) and nfsr_e(28) and nfsr_e(21)) xor  
					(nfsr_e(63) and nfsr_e(45) and nfsr_e(28) and nfsr_e(9)) xor 
					(nfsr_e(60) and nfsr_e(52) and nfsr_e(37) and nfsr_e(33)) xor  
					(nfsr_e(63) and nfsr_e(60) and nfsr_e(21) and nfsr_e(15));
				
				tmp6 <= 
					nfsr_e(62) xor nfsr_e(60) xor nfsr_e(52) xor nfsr_e(45) xor 
					(nfsr_e(63) and nfsr_e(60) and nfsr_e(52) and nfsr_e(45) and nfsr_e(37)) xor  
					(nfsr_e(33) and nfsr_e(28) and nfsr_e(21) and nfsr_e(15) and nfsr_e(9)) xor 
					(nfsr_e(52) and nfsr_e(45) and nfsr_e(37) and nfsr_e(33) and nfsr_e(28) and nfsr_e(21));
		 	
				-- F
				tmp7 <= 
					lfsr_e(62) xor lfsr_e(51) xor lfsr_e(38) xor lfsr_e(23) xor lfsr_e(13) xor lfsr_e(0);
			
			
	

			
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





