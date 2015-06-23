--/////////////////////////MT_GET TEST BENCH///////////////////////////////
--Purpose: test bench for MT_GET module
--Created by: Minzhen Ren
--Last Modified by: Minzhen Ren
--Last Modified Date: September 01, 2010
--Lately Updates: File was created
--////////////////////////////////////////////////////////////////////////
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use IEEE.math_real.all;  
library STD;
    use STD.textio.all;
	
entity MT_GET_TB is
end MT_GET_TB;

architecture TB of MT_GET_TB is

	--interface signals
	signal CLK 	 : std_logic;
	signal RESET : std_logic;
	signal PAUSE : std_logic;
	signal OUT_SIG : std_logic;
	signal SEED  : std_logic_vector( 31 downto 0 );
	signal RND_NUM_BIN : std_logic_vector( 31 downto 0 );
	signal RND_NUM_INT : integer;
	signal NUMS  : integer;
	--half of a period defined
	signal HALF_PERIOD : time := 10 ns;
	--FILE I/O
	file INFILE  : TEXT open READ_MODE is "commands.stim";
	file OUTFILE : TEXT open WRITE_MODE is "rnd_num.out";
	--components
	component MT_GET is
		generic(
		DATA_WIDTH : Natural := 32
		);
		port(
			signal CLK     : in  std_logic;
			signal RESET   : in  std_logic;
			signal SEED_IN : in  std_logic_vector( DATA_WIDTH-1 downto 0 );
			signal PAUSE   : in  std_logic;
			signal OUT_SIG : out std_logic;
			signal OUTPUT  : out std_logic_vector( DATA_WIDTH-1 downto 0 )
		);
	end component;
	
	function Slv_To_String(SLV: std_logic_vector(31 downto 0)) return string is
	  variable RET: string(32 downto 1);
	  variable ONEBIT : character;
	begin
	  for I in SLV'range loop
		case SLV(I) is
		  when '1' => RET(I+1) := '1';
		  when '0' => RET(I+1) := '0';
		  when others => null;
		end case;
	  end loop;
	  return(RET);
	end function Slv_To_String;
	
	begin
	-- PAUSE <= '0';
	PAUSE_PROCESS : process
	begin
		PAUSE <= '0';
		wait for 50230 ns;
		PAUSE <= '1' ;
		wait for 80 ns;
		PAUSE <= '0';
		wait for 1 ms;
	end process;
	
	RND_NUM_INT <= to_integer(signed(RND_NUM_BIN));
	
	CLK_PROC : process
	begin
		CLK <= '0';
		wait for HALF_PERIOD;
		CLK <= '1';
		wait for HALF_PERIOD;
	end process;
	
	MT_GET_BLK : MT_GET
	port map(
		CLK => CLK,
		RESET => RESET,
		SEED_IN => SEED,
		PAUSE => PAUSE,
		OUT_SIG => OUT_SIG,
		OUTPUT => RND_NUM_BIN
	);
	
	TB_FLOW : process
	
		variable FILE_LINE_IN   : line; --INFILE LINE
		variable FILE_LINE_OUT  : line;
		variable TEMPINT        : integer;
		variable CMD            : string(5 downto 1);
		
	begin
		
		if (not(ENDFILE(INFILE))) then
			
			READLINE(INFILE, FILE_LINE_IN);
			READ(FILE_LINE_IN, CMD);
			
			if ( CMD = "NUMS " ) then
		  	-- Read the number of outputs
				READ(FILE_LINE_IN, TEMPINT);
				NUMS <= TEMPINT;
				wait until RISING_EDGE(OUT_SIG);
				for j in 1 to NUMS loop
					wait for HALF_PERIOD;
					wait for HALF_PERIOD;
					wait for HALF_PERIOD;
					write(FILE_LINE_OUT, RND_NUM_INT);
					writeline(OUTFILE, FILE_LINE_OUT);
					wait until FALLING_EDGE(OUT_SIG);
					wait until RISING_EDGE(OUT_SIG);
				end loop;				
			elsif ( CMD = "RESET" ) then
				RESET <= '1';
				wait until FALLING_EDGE(CLK);
				wait until FALLING_EDGE(CLK);
				RESET <= '0';
			elsif ( CMD = "SEED " ) then
				READ(FILE_LINE_IN, TEMPINT);
				SEED <= std_logic_vector(to_unsigned(TEMPINT, 32));
			else
				report("Command not recognized");
			end if;
		else
			assert FALSE report("Simulation Completed") severity FAILURE;
		end if;
	end process;
	
	-- END_PROCESS : process
	-- begin
		-- wait for 60000 ns;
		-- assert FALSE report("Simulation Completed") severity FAILURE;
	-- end process;
	
end TB;