--
-- Grain128
--
--
--



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity grain128 is
generic (
	DEBUG : boolean := false;		-- output debug information
	FAST : boolean := false			-- attempt manual register balancing
);
port (
	CLK_I : in std_logic;
	CLKEN_I : in std_logic := '1';
	ARESET_I : in std_logic;

	KEY_I : in std_logic;
	IV_I  : in std_logic;
	INIT_I: in std_logic;
	
	KEYSTREAM_O : out std_logic;
	KEYSTREAM_VALID_O : out std_logic	
);
end entity;


architecture behav of grain128 is
type state_t is (IDLE, INIT_KEYIV, INIT_RUN);
signal state : state_t;
signal cnt : unsigned(8 downto 0);

signal inject_input, set_injected_iv , allow_output : std_logic;
signal add_output : std_logic;

signal output_bit, output_bit_d, allow_output_d : std_logic;


begin

	KEYSTREAM_O       <= output_bit_d;
	KEYSTREAM_VALID_O <= allow_output_d;
	
		 
		 
	slow_design: if FAST = false generate
	begin	
		functions0: entity work.grain128_datapath_slow
		generic map ( DEBUG => DEBUG )
		port map (
			CLK_I    => CLK_I,
			CLKEN_I  => CLKEN_I,
			ARESET_I => ARESET_I,

			KEY_I => KEY_I,
			IV_I  => IV_I,								 
			INJECT_INPUT_I => inject_input,
			PAD_IV_I       => set_injected_iv,
			ADD_OUTPUT_I   => add_output,
			H_O => output_bit
		);
	end generate;
	
	
	fast_design: if FAST = true generate				
	begin	
		functions1: entity work.grain128_datapath_fast
		generic map ( DEBUG => DEBUG )
		port map (
			CLK_I    => CLK_I,
			CLKEN_I  => CLKEN_I,
			ARESET_I => ARESET_I,

			KEY_I => KEY_I,
			IV_I  => IV_I,								 
			INJECT_INPUT_I => inject_input,
			PAD_IV_I       => set_injected_iv,
			ADD_OUTPUT_I   => add_output,
			H_O => output_bit
		);
	end generate;


 


	-- output registers:
	-- (in case the "user" forgets this is at 
	--  his end and kills my fmax)
	-- 
	output_reg: process(CLK_I, ARESET_I)
	begin
		if ARESET_I = '1' then
			output_bit_d   <= '0';
			allow_output_d <= '0';
		elsif rising_edge(CLK_I) then
			if CLKEN_I = '1' then
				output_bit_d   <= output_bit;
				allow_output_d <= allow_output;
			end if;
		end if;
	end process;
		
	
	
	

	-- the counter:
	cnt_proc: process(CLK_I)
	begin
		if rising_edge(CLK_I) then
			if CLKEN_I = '1' then
				if state = IDLE then
					cnt <= b"0_0000_0001";
				else					
					cnt <= cnt + 1;
				end if;
			end if;
			
		end if;
	end process;
	
	-- the controller fsm:
	ctrl_proc: process(CLK_I, ARESET_I)
	begin
		if ARESET_I = '1' then
			state <= IDLE; 
			
			inject_input <= '0';
			set_injected_iv <= '0';
			add_output <= '0';
			allow_output <= '0';
		elsif rising_edge(CLK_I) then
			if CLKEN_I = '1' then
				
				
				
				case state is
					when IDLE =>
					if INIT_I = '1' then
						state <= INIT_KEYIV;
						inject_input <= '1';
						set_injected_iv <= '0';
						allow_output <= '0';
					end if;
					
					when INIT_KEYIV =>					
					if cnt(6 downto 5) = "11" then
						set_injected_iv <= '1';
					end if;
										
					if cnt(7) = '1' then
						state <= INIT_RUN;
						inject_input <= '0';
						add_output <= '1';
					end if;
					
					when INIT_RUN =>					
					if cnt(8 downto 7) = "11" then
						state <= IDLE;
						add_output <= '0';
						allow_output <= '1';
					end if;										
					
					when others => state <= IDLE;
				end case;
				
			end if;
		end if;
	end process;
	
	
end behav;
