--/////////////////////////MT_GET BLOCK///////////////////////////////
--Purpose: to produce functionality equivalent to following C code:
--         
--
--Created by: Minzhen Ren
--Last Modified by: Minzhen Ren
--Last Modified Date: Auguest 30, 2010
--Lately Updates: 
--/////////////////////////////////////////////////////////////////
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use ieee.math_real.all;
	
entity MT_GET is
	generic(
		DATA_WIDTH : Natural := 32
	);
	port(
		signal CLK     		: in  std_logic;
		signal RESET   		: in  std_logic;
		signal SEED_IN 		: in  std_logic_vector( DATA_WIDTH-1 downto 0 );
		signal PAUSE		: in  std_logic;
		signal DONE_INIT  	: out std_logic;
		signal OUT_SIG 		: out std_logic;
		signal OUTPUT  		: out std_logic_vector( DATA_WIDTH-1 downto 0 )
	);
end MT_GET;

architecture BEHAVE of MT_GET is
	--contant
	signal M_CONST : std_logic_vector( 9 downto 0 );
	signal N_CONST : std_logic_vector( 9 downto 0 );
	signal MN_DIFF : std_logic_vector( 9 downto 0 );
	signal M_MINUS : std_logic_vector( 9 downto 0 );
	signal N_MINUS : std_logic_vector( 9 downto 0 );
	
	--MT_SET interface
	signal SEED : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal WRITE_DATA : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal IDLE_SIG : std_logic;
	
	--Memory interface
	signal ADDR_MAX   : std_logic_vector( 8 downto 0 );
	signal WR_ENABLE0 : std_logic;
	signal WR_ADDR0   : std_logic_vector( 8 downto 0 );
	signal WR_ADDR0_Q  	: std_logic_vector( 8 downto 0 );
	signal WR_ADDR0_QQ 	: std_logic_vector( 8 downto 0 );
	signal WR_ADDR0_QQQ : std_logic_vector( 8 downto 0 );
	signal WR_ADDR0_QQQQ : std_logic_vector( 8 downto 0 );
	signal RD_ENABLE0 : std_logic;
	signal RD_ADDR0   : std_logic_vector( 8 downto 0 );
	signal MEM0_IN    : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal MEM0_OUT   : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal WR_ENABLE1 : std_logic;
	signal WR_ADDR1   : std_logic_vector( 8 downto 0 );
	signal RD_ENABLE1 : std_logic;
	signal RD_ADDR1   : std_logic_vector( 8 downto 0 );
	signal MEM1_IN    : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal MEM1_OUT   : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal DATA_MT_GEN : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal ADDR_SHF_IN  : std_logic_vector( 9 downto 0 );
	signal ADDR_SHF_OUT : std_logic_vector( 9 downto 0 );
	signal OPRAND1 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal OPRAND2 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal OPRAND3 : std_logic_vector( DATA_WIDTH-1 downto 0 );
	
	--Counter
	signal KK : std_logic_vector( 9 downto 0 );
	signal INNER_STATE : std_logic_vector( 2 downto 0 );
	signal KK_MAX : std_logic_vector( 9 downto 0 );
	
	--Control signal
	signal MEM_SEL : std_logic;
	
	--State Machine
	type STATE_TYPE is (INITIAL, MEM_INIT, MT_GEN, PAUSE_STATE);
	signal CS : STATE_TYPE;
	signal NS : STATE_TYPE;
	
	component MT_SET is
		generic(
			DATA_WIDTH : Natural := 32
		);
		port(
			signal CLK   : in  std_logic;
			signal RESET : in  std_logic;
			signal IDLE_SIG : in std_logic;
			signal S_IN  : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
			signal S_OUT : out std_logic_vector( DATA_WIDTH-1 downto 0 )
		);
	end component;
		
	component dp_mem is
		generic (
		  Addr_Wdth : Natural := 9;
		  Bit_Wdth  : Natural := 32
		);
	    port (Clock         : in  Std_Logic;
			  Write_Enable  : in  Std_Logic;
			  Write_Address : in  Std_Logic_Vector(Addr_Wdth-1 downto 0);
			  Read_Enable   : in  Std_Logic;
			  Read_Address  : in  Std_Logic_Vector(Addr_Wdth-1 downto 0);
			  Data_In       : in  Std_Logic_Vector(Bit_Wdth-1 downto 0);
			  Data_Out      : out Std_Logic_Vector(Bit_Wdth-1 downto 0));	
	end component;
		
	component MT_PATH is
		generic(
			DATA_WIDTH : Natural := 32
		);
		port(
			signal OPRAND1 : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
			signal OPRAND2 : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
			signal OPRAND3 : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
			signal CLK     : in  std_logic;
			signal RESET   : in  std_logic;
			signal OUTPUT  : out std_logic_vector( DATA_WIDTH-1 downto 0 )
		);
	end component;
	
	component MT_SHIFTING is
		generic(
			DATA_WIDTH : Natural := 32
		);
		port(
			signal INPUT  : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
			signal OUTPUT : out std_logic_vector( DATA_WIDTH-1 downto 0 )
		);
	end component;
	
	begin
	
	MT_BLK : MT_SET
	port map(
		S_IN   	=> SEED,
		S_OUT  	=> WRITE_DATA,
		CLK    	=> CLK,
		RESET  	=> RESET,
		IDLE_SIG => IDLE_SIG
	);
	
	MEM0 : dp_mem
	port map(
		Clock 			=> CLK,
		Write_Enable 	=> WR_ENABLE0,
		Write_Address 	=> WR_ADDR0,
		Read_Enable 	=> RD_ENABLE0,
		Read_Address 	=> RD_ADDR0,
		Data_In 		=> MEM0_IN,
		Data_Out 		=> MEM0_OUT
	);
	
	MEM1 : dp_mem
	port map(
		Clock 			=> CLK,
		Write_Enable 	=> WR_ENABLE1,
		Write_Address 	=> WR_ADDR1,
		Read_Enable 	=> RD_ENABLE1,
		Read_Address 	=> RD_ADDR1,
		Data_In 		=> MEM1_IN,
		Data_Out 		=> MEM1_OUT
	);
	
	CURRENT_STATE : process(CLK, RESET)
	begin
		if RESET = '1' then
			CS <= INITIAL;
		elsif CLK='1' and CLK'event then
			CS <= NS;
		end if;
	end process;
	
	NEXT_STATE : process(CS, KK, N_MINUS, INNER_STATE, PAUSE)
	begin
		if CS = INITIAL then
			NS <= MEM_INIT;
		elsif CS = MEM_INIT then
			if KK = N_MINUS and INNER_STATE(2) = '1' then
				NS <= MT_GEN;
			else
				NS <= CS;
			end if;
		elsif CS <= MT_GEN then
			if PAUSE = '1' then
				NS <= PAUSE_STATE;
			else 
				NS <= MT_GEN;
			end if;
		elsif CS <= PAUSE_STATE then
			if PAUSE = '0' then
				NS <= MT_GEN;
			else
				NS <= PAUSE_STATE;
			end if;
		else
			NS <= INITIAL;
		end if;
	end process;
	
	COUNTER_PROC : process(CLK, RESET)
	begin
		if RESET = '1' then
			KK <= (others => '0');
		elsif CLK'event and CLK='1' then
			if CS = INITIAL then
				KK <= (others => '0');
			elsif CS = MEM_INIT then
				if INNER_STATE(2) = '1' and KK /= N_MINUS then
					KK <= KK + 1;
				elsif INNER_STATE(2) = '1' and KK = N_MINUS then
					KK <= (others => '0');
				else
					KK <= KK;
				end if;
			elsif CS = MT_GEN then
				if INNER_STATE = "011" and KK /= N_MINUS then
					KK <= KK + 1;
				elsif INNER_STATE = "011" and KK = N_MINUS then
					KK <= (others => '0');
				end if;
			elsif CS = PAUSE_STATE then
				KK <= KK;
			else
				KK <= (others => '0');
			end if;
		end if;
	end process;
	
	INNER_STATE_COUNTER : process(CLK, RESET)
	begin
		if RESET = '1' then
			INNER_STATE <= (others => '0');
		elsif CLK'event and CLK='1' then
			if CS = INITIAL then
				INNER_STATE <= (others => '0');
			elsif CS = MEM_INIT then	
				if INNER_STATE(2) = '0' then
					INNER_STATE <= INNER_STATE + '1';
				else
					INNER_STATE <= "001";
				end if;
			elsif CS = MT_GEN then
				if INNER_STATE < "011" then
					INNER_STATE <= INNER_STATE + '1';
				else
					INNER_STATE <= "001";
				end if;
			elsif CS = PAUSE_STATE then
				INNER_STATE <= "001";
			else
				INNER_STATE <= (others => '0');
			end if;			
		end if;
	end process;
	
	IDLE_SIG <= '0' when CS = MEM_INIT and RESET = '0' else '1';
	
	--constants
	N_CONST <= "1001110000"; --624
	M_CONST <= "0110001101"; --397
	MN_DIFF <= "0011100011"; --227
	N_MINUS <= "1001101111"; --623
	M_MINUS <= "0110001100"; --396
	--N_MM    <= "1001101101"; --621
	
	SEED <= "00000000000000000001000100000101" when SEED_IN = 0 else SEED_IN; --default seed
	KK_MAX <= "1001101111"; --623
	ADDR_MAX <= "100110111"; --311
	
	--memory control
	MEM_SEL <= '0' when KK(0) = '0' and CS = MEM_INIT else
			   '1' when KK(0) = '1' and CS = MEM_INIT else
			   '0' when ((to_integer(unsigned(KK))) mod 2) = 0 and RESET = '0' and CS = MT_GEN else
			   '1' when RESET = '0' and CS = MT_GEN else
	           '0';
	
	WR_ENABLE0 	<= '1' when (CS = MEM_INIT and MEM_SEL = '0') or (CS = MT_GEN and INNER_STATE = "011" and MEM_SEL = '0')
				else '0';
	WR_ENABLE1 	<= '1' when (CS = MEM_INIT and MEM_SEL = '1') or (CS = MT_GEN and INNER_STATE = "011" and MEM_SEL = '1')
				else '0';
	RD_ENABLE0 	<= '1' when (NS = MT_GEN)
				else '0';
	RD_ENABLE1 	<= '1' when (NS = MT_GEN)
				else '0';
	
	MEM0_IN <=  WRITE_DATA when MEM_SEL = '0' and CS = MEM_INIT
				else DATA_MT_GEN when MEM_SEL = '0' and CS = MT_GEN and INNER_STATE = "011"
				else ( others => '0' );
	MEM1_IN <=  WRITE_DATA when MEM_SEL = '1' and (CS = MEM_INIT or (CS = MT_GEN and INNER_STATE = "001"))
				else DATA_MT_GEN when MEM_SEL = '1' and CS = MT_GEN and INNER_STATE = "011"
				else ( others => '0' );
	
	MEM0_WR_PROC : process(CLK, RESET)
	begin
		if RESET = '1' then
			WR_ADDR0 <= (others => '0');
		elsif CLK = '1' and CLK'event then
			if CS = MEM_INIT then
				if INNER_STATE(2) = '1' and MEM_SEL = '0' and WR_ADDR0 /= ADDR_MAX then
					WR_ADDR0 <= WR_ADDR0 + 1;
				elsif INNER_STATE(2) = '1' and MEM_SEL = '0' and WR_ADDR0 = ADDR_MAX then
					WR_ADDR0 <= (others => '0');
				else
					WR_ADDR0 <= WR_ADDR0;
				end if;
			elsif CS = MT_GEN then
				if WR_ADDR0 /= ADDR_MAX and INNER_STATE = "011" and MEM_SEL = '0' then
					WR_ADDR0 <= WR_ADDR0 + 1;
				elsif WR_ADDR0 = ADDR_MAX and MEM_SEL = '0' and INNER_STATE = "011" then 
					WR_ADDR0 <= (others => '0');
				else
					WR_ADDR0 <= WR_ADDR0;
				end if;
			elsif CS = PAUSE_STATE then
				WR_ADDR0 <= WR_ADDR0;
			else
				WR_ADDR0 <= (others => '0');
			end if;
		end if;	
	end process;
	
	MEM0_WR_DELAY : process (CLK, RESET)
	begin
		if RESET = '1' then
			WR_ADDR0_Q <= (others => '0');
			WR_ADDR0_QQ <= (others => '0');
			WR_ADDR0_QQQ <= (others => '0');
			WR_ADDR0_QQQQ <= (others => '0');
		elsif CLK='1' and CLK'event then
			WR_ADDR0_Q <= WR_ADDR0;
			WR_ADDR0_QQ <= WR_ADDR0_Q;
			WR_ADDR0_QQQ <= WR_ADDR0_QQ;
			WR_ADDR0_QQQQ <= WR_ADDR0_QQQ;
		end if;
	end process;
	
	WR_ADDR1 <= WR_ADDR0_QQQQ when CS = MEM_INIT else
				WR_ADDR0_QQQ when CS = MT_GEN;
	
	ADDR_SHF_IN <= KK + M_CONST when KK < MN_DIFF and CS = MT_GEN else
				   KK - MN_DIFF when (KK >= MN_DIFF and KK < N_MINUS) and CS = MT_GEN else
				   M_MINUS when KK = N_MINUS and CS = MT_GEN
				   else (others => '0');
	
	ADDR_SHF_OUT <= '0' & ADDR_SHF_IN(9 downto 1);
	
	MEM0_RD_PROC : process(CS, INNER_STATE, MEM_SEL, ADDR_SHF_OUT, WR_ADDR0)
	begin
		if CS = MT_GEN then
			if INNER_STATE = "001" then
				RD_ADDR0 <= WR_ADDR0;
			elsif INNER_STATE = "010" and MEM_SEL = '1' then
				RD_ADDR0 <= ADDR_SHF_OUT( 8 downto 0 );
            else
			    RD_ADDR0<= WR_ADDR0;
			end if;
		else
			RD_ADDR0 <= (others => '0');
		end if;
	end process;
	
	MEM1_RD_PROC : process(CS, INNER_STATE, MEM_SEL, ADDR_SHF_OUT, WR_ADDR1)
	begin
		if CS = MT_GEN then 
			if INNER_STATE = "001" then
		    	RD_ADDR1 <= WR_ADDR1;
			elsif INNER_STATE = "010" and MEM_SEL = '0' then
				RD_ADDR1 <= ADDR_SHF_OUT( 8 downto 0 );
			else
			    RD_ADDR1 <= WR_ADDR1;
			end if;
		else
			RD_ADDR1 <= (others => '0');
		end if;
	end process;
	
	OPRAND1 <= MEM0_OUT when MEM_SEL = '0' and CS = MT_GEN and INNER_STATE = "010"
				else MEM1_OUT when MEM_SEL = '1' and CS = MT_GEN and INNER_STATE = "010"
				else (others =>'0');
	
	OPRAND2 <= MEM0_OUT when MEM_SEL = '1' and CS = MT_GEN and INNER_STATE = "010"
				else MEM1_OUT when MEM_SEL = '0' and CS = MT_GEN and INNER_STATE = "010"
				else (others=>'0');
	
	OPRAND3 <= MEM0_OUT when MEM_SEL = '1' and CS = MT_GEN and INNER_STATE = "011"
				else MEM1_OUT when MEM_SEL = '0' and CS = MT_GEN and INNER_STATE = "011"
				else (others =>'0');
				
	
	MT_DATAPATH : MT_PATH
	port map(
		OPRAND1 => OPRAND1,
		OPRAND2 => OPRAND2,
		OPRAND3 => OPRAND3,
		CLK => CLK,
		RESET => RESET,
		OUTPUT => DATA_MT_GEN
	);
	
	MT_RN_GEN : MT_SHIFTING
	port map(
		INPUT 	=> DATA_MT_GEN,
		OUTPUT 	=> OUTPUT 
	);
	
	DONE_INIT <= '0' when NS = MEM_INIT else '1';
	OUT_SIG <= '1' when CS = MT_GEN and (INNER_STATE = "010" or INNER_STATE = "011") else '0';
	
end BEHAVE;