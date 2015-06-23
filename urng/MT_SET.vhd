--/////////////////////////MT BLOCK///////////////////////////////
--Purpose: to produce functionality equivalent to following C code
--         excluding a momry module
-- 			void mt_set (void *vstate, unsigned long int s)
-- 			{
-- 				mt_state_t *state = (mt_state_t *) vstate;
-- 				int i;
-- 				if (s == 0)
-- 				s = 4357;	/* the default seed is 4357 */
-- 	#define LCG(x) ((69069 * x) + 1) &0xffffffffUL
-- 				for (i = 0; i < N; i++)
-- 				{
-- 					state->mt[i] = s & 0xffff0000UL;
-- 					s = LCG(s);
-- 					state->mt[i] |= (s &0xffff0000UL) >> 16;
-- 					s = LCG(s);
-- 				}
-- 				state->mti = i;
-- 			}
--Created by: Minzhen Ren
--Last Modified by: Minzhen Ren
--Last Modified Date: Auguest 28, 2010
--Lately Updates: 
--/////////////////////////////////////////////////////////////////
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use ieee.math_real.all;
	
entity MT_SET is
	generic(
		DATA_WIDTH : Natural := 32
	);
	port(
		signal CLK      : in  std_logic;
		signal RESET    : in  std_logic;
		signal IDLE_SIG : in  std_logic;
		signal S_IN     : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
		signal S_OUT    : out std_logic_vector( DATA_WIDTH-1 downto 0 )
	);
end MT_SET;

architecture BEHAV of MT_SET is
	
	--state machine
	type STATE_TYPE is (INITIAL, RUNNING, IDLE);
	signal CS : STATE_TYPE;
	signal NS : STATE_TYPE;
	signal INNER_STATE  : std_logic_vector(2 downto 0);
	
	signal MASK 		: std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal S_D  		: std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal S_Q  		: std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal IDLE_IN      : std_logic;
		
	signal S_LCG1   : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal S_LCG1_Q : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal S_LCG2   : std_logic_vector( DATA_WIDTH-1 downto 0 );
	
	signal S_OP1_D  : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal S_OP1_Q  : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal S_OP2 	: std_logic_vector( DATA_WIDTH-1 downto 0 );
	
	component REG is
		generic(
			BIT_WIDTH : Natural := 32
		);
		port(
			CLK       : in  std_logic;
			RESET     : in  std_logic; -- high asserted
			DATA_IN   : in  std_logic_vector( BIT_WIDTH-1 downto 0 );
			DATA_OUT  : out std_logic_vector( BIT_WIDTH-1 downto 0 )
		);
	end component;
	
	component LCG is
		generic(
			DATA_WIDTH : Natural := 32
		);
		port(
			CLK   : in  std_logic;
			RESET : in  std_logic;
			X_IN  : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
			X_OUT : out std_logic_vector( DATA_WIDTH-1 downto 0 )
		);
	end component;

	begin
	
	MASK <= "11111111111111110000000000000000"; --0xffffffffUL
	IDLE_IN <= IDLE_SIG;
	
	CURRENT_STATE : process(CLK, RESET)
	begin
		if RESET = '1' then
			CS <=INITIAL;
		elsif CLK='1' and CLK'event then
			CS <= NS;
		end if;
	end process;
	
	NEXT_STATE : process(CS, IDLE_IN)
	begin
		if CS = INITIAL then
			NS <= RUNNING;
		elsif CS = RUNNING then
			if IDLE_IN = '1' then
				NS <= IDLE;
			else
				NS <= CS;
			end if;
		elsif CS = IDLE then
			if IDLE_IN = '0' then
				NS <= RUNNING;
			else
				NS <= CS;
			end if;
		else
			NS <= CS;
		end if;

	end process;
	
	INNER_STATE_PROCESS : process(RESET, CLK)
	begin
		if RESET = '1' then
			INNER_STATE <= (others => '0');
		elsif CLK'event and CLK='1' then
			if INNER_STATE(2) = '0' then
				INNER_STATE <= INNER_STATE + 1;
			else
				INNER_STATE <= "001";
			end if;
		end if;
	end process;
	
	--input mux
	S_D <= 	S_IN when CS = INITIAL else
			S_Q when CS = IDLE else
			S_LCG2 when INNER_STATE(2) = '1' else
			S_Q;
		
	S_IN_REG : REG
	port map(
		CLK => CLK,
		RESET => RESET,
		DATA_IN => S_D,
		DATA_OUT => S_Q
	);
	
	S_OP1_D <= S_Q and MASK;
	
	S_OP1_REG : REG
    port map(
		CLK => CLK,
		RESET => RESET,
		DATA_IN => S_OP1_D,
		DATA_OUT => S_OP1_Q
	);
	
	LCG1 : LCG
	port map(
		CLK => CLK,
		RESET => RESET,
		X_IN => S_Q,
		X_OUT => S_LCG1
	);
	
	S_OP2 <= S_LCG1 and MASK;
	S_OUT <= S_OP1_Q or ("0000000000000000" & S_OP2(31 downto 16));
		
	S_LCG1_REG : REG
    port map(
		CLK => CLK,
		RESET => RESET,
		DATA_IN => S_LCG1,
		DATA_OUT => S_LCG1_Q
	);	
		
	LCG2 : LCG
	port map(
		CLK => CLK,
		RESET => RESET,
		X_IN => S_LCG1_Q,
		X_OUT => S_LCG2
	);
	
	-- S_OUT_REG1 : REG
    -- port map(
		-- CLK => CLK,
		-- RESET => RESET,
		-- DATA_IN => S_OUT_D,
		-- DATA_OUT => S_OUT_DD
    -- );
	
	-- S_OUT_REG2 : REG
    -- port map(
		-- CLK => CLK,
		-- RESET => RESET,
		-- DATA_IN => S_OUT_DD,
		-- DATA_OUT => S_OUT
    -- );
end BEHAV;